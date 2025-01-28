import { LightningElement, track, wire } from 'lwc';
import getUserRecords from '@salesforce/apex/starRouterClass.getUserRecords';
import getEmailGroupRecords from '@salesforce/apex/starRouterClass.getEmailGroupRecords';
import insertAwardRecord from '@salesforce/apex/starRouterClass.insertAwardRecord';
import starwars_image from '@salesforce/resourceUrl/starwars_image';
import avatar_image from '@salesforce/resourceUrl/avatar';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import allOtherEmployees from '@salesforce/apex/LeaveHandler.allOtherEmployees';
import { recordNotifyChange } from 'lightning/uiRecordApi';
import getInformSuggestionsDetails from '@salesforce/apex/starAwardController.getInformSuggestionsDetails';


export default class StarAwardContainer extends LightningElement {

    _awardStarTo = [];
    _awardStarNotify = [];
    _informTo = [];

    toUser = [];
    informToUser = [];
    confirmationModal=false;
    informToList = [];
    emailGroups = [];
    @track awardToSelected = [];
    @track awardToNotify = [];
    searchTerm = "";
    isGroup=false;
    lstOfUser;
    userOptions;
    defaultValue = 'Gold';

    STARWAR_IMAGE = starwars_image;

    @track resetValues = false;

    @track awardSearchKey = '';
    @track filteredAwardEmployees = [];
    @track selectedAwardEmployees = [];
    selectedAwardFromSuggestions=[];
    @track showAwardDropdown = false;
    @track noAwardEmployeesFound = false;
    tooltipVisible = false;

    // Inform To variables
    @track informSearchKey = '';
    @track filteredInformEmployees = [];
    @track selectedInformEmployees = [];
    selectedInformFromSuggestions=[];
    @track showInformDropdown = false;
    @track noInformEmployeesFound = false;
    commentError = '';
    currentTooltip = ''; // Stores the email for the hovered item


    informSuggestions = [];

    connectedCallback() {
        // Fetch the suggestions when the component is initialized
        this.fetchInformSuggestions();
    }


    fetchInformSuggestions() {
        getInformSuggestionsDetails()
            .then((result) => {
                if (result) {
                    const suggestions = JSON.parse(result);
                    // Map the suggestions to the format you need
                    this.informSuggestions = suggestions.map((item) => ({
                        id: item.id,
                        name: item.name, // Use Name for Users, Name__c for Email Groups
                        email: item.email, // Use Email for Users, Email__c for Email Groups
                    }));
                } else {
                    console.error('No suggestions returned from Apex.');
                }
            })
            .catch((error) => {
                console.error('Error fetching inform suggestions:', error);
            });
    }

    handleClose(){
        this.confirmationModal=false;
    }

    // Fetch employees from Apex
    @wire(allOtherEmployees)
    wiredEmployees({ error, data }) {
        if (data) {
            this.employees = data.map(emp => ({ id: emp.Id, sfUserId: emp.SF_User__r?.Id, name: emp.Name, email: emp.Email_ID__c, employeeId: emp.EmployeeID__c, avatar: emp.SF_User__r?.FullPhotoUrl || avatar_image ,isGroup:false}));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.employees = [];
        }
    }

    get tooltipClass() {
        return this.tooltipVisible ? 'visible' : 'tooltiptext';
    }

    // Handle Award To search
    handleAwardSearchChange(event) {
        this.awardSearchKey = event.target.value.toLowerCase();
        // Filter employees not already selected
        const unselectedEmployees = this.employees.filter(emp =>
            !this.selectedAwardEmployees.some(selectedEmp => selectedEmp.id === emp.id)
        );
        // Filter based on the search key
        this.filteredAwardEmployees = unselectedEmployees.filter(emp =>
            emp.name.toLowerCase().includes(this.awardSearchKey)
        );
        this.noAwardEmployeesFound = this.filteredAwardEmployees.length === 0;
        this.showAwardDropdown = !!this.awardSearchKey;
    }

    validateComment(event) {
        const commentField = event.target;
        const commentValue = commentField.value.trim();

        if (!commentValue) {
            // If the textarea is blank, clear the error
            this.commentError = '';
            commentField.classList.remove('has-error'); // Remove error class
        } else {
            const wordCount = commentValue.split(/\s+/).filter(word => word).length;
            const charCount = commentValue.length;

            if (charCount < 100) {
                // Show the error if criteria are not met
                this.commentError = 'Comment must contain at least 100 characters.';
                commentField.classList.add('has-error');
            } else {
                // Clear the error if criteria are met
                this.commentError = '';
                commentField.classList.remove('has-error');
            }
        }
    }

    removeError(event) {
        const commentField = event.target;

        // Clear the error message and styling unconditionally
        this.commentError = '';
        commentField.classList.remove('has-error');
    }

    openToolTip(event) {
        event.stopPropagation(); 
        // Use closest to find the parent button
        const buttonElement = event.target.closest('button');    
        if (!buttonElement) {
            return;
        }    
        // Get the data-id from the button
        const employeeId = buttonElement.dataset.id;
        if (!employeeId) {
            return;
        }
        // Find the employee by ID
        const employee = this.informSuggestions.find(emp => emp.id === employeeId);

        if (employee) {
            this.currentTooltip = employee.email;
        }
        
        this.tooltipVisible = true;
    }

    closeToolTip(event){
        event.stopPropagation(); 
        this.currentTooltip = ''; // Clear tooltip content
        this.tooltipVisible = false;
    }

    // Handle Inform To search
    handleInformSearchChange(event) {
        this.informSearchKey = event.target.value.toLowerCase();
         // Combine employees and email groups into one array
        const allInformOptions = [...this.employees, ...this.emailGroups];
        // Filter employees not already selected
        const unselectedEmployees = allInformOptions.filter(emp =>
            !this.selectedInformEmployees.some(selectedEmp => selectedEmp.id === emp.id)
        );
        // Filter based on the search key
        this.filteredInformEmployees = unselectedEmployees.filter(emp =>
            emp.name.toLowerCase().includes(this.informSearchKey)
        );
        this.noInformEmployeesFound = this.filteredInformEmployees.length === 0;
        this.showInformDropdown = !!this.informSearchKey;
    }

    get truncatedInformSuggestions() {
        return this.informSuggestions.map((employee) => ({
            ...employee,
            displayName:
                employee.name.length > 8 // You can adjust this length limit
                    ? employee.name.slice(0, 8) + '..'
                    : employee.name,
        }));
    }

    // Select employee for Award To
    handleAwardSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedEmployee = this.employees.find(emp => emp.id === selectedId);
        if (!this.selectedAwardEmployees.some(emp => emp.id === selectedId)) {
            this.selectedAwardEmployees = [...this.selectedAwardEmployees, selectedEmployee];
        }
        this.awardSearchKey = '';
        this.showAwardDropdown = false;
    }

    // Select employee for Inform To
    handleInformSelect(event) {
        const selectedId = event.currentTarget.dataset.id;
        console.log('selectedId',selectedId);
        const allInformOptions = [...this.employees, ...this.emailGroups];
        const selectedEmployee = allInformOptions.find(emp => emp.id === selectedId);
        if (!this.selectedInformEmployees.some(emp => emp.id === selectedId)) {
            this.selectedInformEmployees = [...this.selectedInformEmployees, selectedEmployee];
            // Track if the employee was selected from suggestions
            if (this.informSuggestions.some(emp => emp.id === selectedId)) {
                this.selectedInformFromSuggestions = [...this.selectedInformFromSuggestions, selectedEmployee];
            }
        }
        this.informSuggestions = this.informSuggestions.filter(emp => emp.id !== selectedEmployee.id);
        this.informSearchKey = '';
        this.showInformDropdown = false;
    }

    // Remove employee from Award To
    handleAwardRemove(event) {
        const removeId = event.currentTarget.dataset.id;
        const employeeToRemove = this.selectedAwardEmployees.find(emp => emp.id === removeId);
        // Remove employee from selectedAwardEmployees
        this.selectedAwardEmployees = this.selectedAwardEmployees.filter(emp => emp.id !== removeId);
        // Only add back to awardSuggestions if the employee was from the suggestions list
        if (employeeToRemove && this.selectedAwardFromSuggestions.some(emp => emp.id === employeeToRemove.id)) {
            this.awardSuggestions = [...this.awardSuggestions, employeeToRemove];
        }
        // Remove from selectedFromSuggestions
        this.selectedAwardFromSuggestions = this.selectedAwardFromSuggestions.filter(emp => emp.id !== removeId);
    }


    // Remove employee from Inform To
    handleInformRemove(event) {
        const removeId = event.currentTarget.dataset.id;
        // Find the employee to be removed
        const employeeToRemove = this.selectedInformEmployees.find(emp => emp.id === removeId);
        this.selectedInformEmployees = this.selectedInformEmployees.filter(emp => emp.id !== removeId);
        // Only add back to awardSuggestions if the employee was from the suggestions list
        if (employeeToRemove && this.selectedInformFromSuggestions.some(emp => emp.id === employeeToRemove.id)) {
            this.informSuggestions = [...this.informSuggestions, employeeToRemove];
        }
        // Remove from selectedFromSuggestions
        this.selectedInformFromSuggestions = this.selectedInformFromSuggestions.filter(emp => emp.id !== removeId);
    }

    get noEmployeesFound() {
        return this.searchKey && this.filteredEmployees.length === 0;
    }


    @wire(getEmailGroupRecords)
    wiredEmailGroupRecords({ error, data }) {
        if (data) {
            this.lstOfUser = JSON.parse(data);
            console.log("Email Groups Data: ", JSON.stringify(this.lstOfUser));
            this.emailGroups = []; // Initialize emailGroups

            // Transform and populate emailGroups
            this.lstOfUser.forEach(ele => {
                if (ele && ele.Name__c && ele.Email__c) { // Ensure the required fields exist
                    this.emailGroups.push({
                        id: ele.Id || null,              // Add the ID if available
                        sfUserId: null,                 // Set to null as per the example
                        name: ele.Name__c,              // Add the Name__c field value
                        email: ele.Email__c,            // Add the Email__c field value
                        employeeId: null,               // EmployeeID__c is null as per the example
                        avatar: avatar_image,         // Use the existing avatar_image value
                        isGroup:true
                    });
                }
            });
        } else if (error) {
            this.error = error;
            console.log('Error in StarAwardContainer - Email Group Records:', error);
        }
    }


    @wire(getUserRecords)
    wiredUserRecords({ error, data }) {
        if (data) {
            this.lstOfUser = [];
            this.lstOfUser = JSON.parse(data);
            let thisOBJ = this;
            console.log('thisOBJ', thisOBJ);
            this.userOptions = [];
            this.lstOfUser.forEach(ele => {
                if (ele && ele.Name) {
                    thisOBJ.userOptions.push({ label: this.camelCase(ele.Name), value: ele.Id })
                }
            });
            this.toUser = [];
            this.informToUser = [];
            this.toUser = Object.assign(this.toUser, thisOBJ.userOptions);
            this.informToUser = Object.assign(this.informToUser, thisOBJ.userOptions);
        } else if (error) {
            this.error = error;
            console.log('Error in StarAwardContainer');
            console.log(error);
        }
    }

    camelCase(str) {
        var splitCamelCaseStr = str.split(".");
        var tempStr = "";
        for (var i = 0; i < splitCamelCaseStr.length; i++) {
            var tempstr1 = this.capatalize(splitCamelCaseStr[i]);
            if (tempStr !== "") {
                tempStr = tempStr + "." + tempstr1;
            } else {
                tempStr = tempstr1;
            }

        }
        console.log("tempStr", tempStr);
        return tempStr;
    }

    capatalize(str) {
        var camelCase = str.substr(0, 1).toUpperCase() + str.substr(1);
        return camelCase;
    }

    get options() {
        if (this.userOptions)
            return this.userOptions;
    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }


    get starOptions() {
        return [
            { label: 'Gold', value: 'Gold' }
        ];
    }

    get getToUser() {
        return this.toUser;
    }

    get getInformToUser() {
        this.informToList = [];
        this.informToUser.forEach(option => {
            this.informToList.push({ label: option.label, value: option.value });
        });
        this.emailGroups.forEach(option => {
            this.informToList.push({ label: option.label, value: option.label });
        });
        this.informToList.sort((a, b) => (a.label > b.label) ? 1 : -1);
        return this.informToList;
    }

    handleChange(e) {
        if (e.currentTarget.name === 'NotifyTo') {
            this._informTo = e.detail.value;
            //console.log("this._informTo",e);
            let selectedValue = e.detail.value;
            //console.log("this._informTo",selectedValue);
            let selectlabels = [];
            selectedValue.forEach(option => {
                console.log("informTo option", option);
                let currentOption = this.options.find(o => o.value === option);
                if (currentOption) {
                    this._awardStarNotify.push({ label: currentOption.label, value: currentOption.value });
                    this.awardToNotify.push(currentOption.label);
                }
                else {
                    let currentOption = this.emailGroups.find(o => o.value === option);
                    if (currentOption) {
                        this._awardStarNotify.push({ label: currentOption.label, value: currentOption.label });
                        this.awardToNotify.push(currentOption.label);
                    }
                }
            });
        } else if (e.currentTarget.name === 'AwardTo') {
            this._awardStarTo = e.detail.value;
            let selectedValue = e.detail.value;
            let selectlabels = [];
            selectedValue.forEach(option => {
                let currentOption = this.options.find(o => o.value === option);
                //  this._awardStarTo.push({label:currentOption.label,value:currentOption.value});
                this.awardToSelected.push(currentOption.label);
            });
        } else if (e.currentTarget.name === 'ToSearch') {
            if (e.detail.value) {
                var searchTerm = e.detail.value;
                var selectedImport = this.awardToSelected;
                var dataImportFields = this.userOptions
                    .filter(
                        item => !searchTerm ||
                            item.value.toLowerCase().includes(searchTerm.toLowerCase()) ||
                            item.label.toLowerCase().includes(searchTerm.toLowerCase()));
                selectedImport.forEach(option => {
                    let currentOption = this.options.find(o => o.label === option);
                    dataImportFields.push({ label: currentOption.label, value: currentOption.value });
                });
                this.toUser = dataImportFields;
            } else {
                this.toUser = [];
                this.toUser = Object.assign(this.toUser, this.userOptions);
            }
        } else if (e.currentTarget.name === 'InformSearch') {
            if (e.detail.value) {
                // const filtered = this.userOptions.filter(record => (record.label.toLowerCase()).includes(e.detail.value.toLowerCase()));
                //   this.informToUser = filtered;
                var searchTerm = e.detail.value;
                var selectedImport = this.awardToNotify;
                var dataImportFields = this.userOptions
                    .filter(
                        item => !searchTerm ||
                            item.value.toLowerCase().includes(searchTerm.toLowerCase()) ||
                            item.label.toLowerCase().includes(searchTerm.toLowerCase()));
                selectedImport.forEach(option => {
                    let currentOption = this.options.find(o => o.label === option);
                    dataImportFields.push({ label: currentOption.label, value: currentOption.value });
                });
                this.informToUser = dataImportFields;
            } else {
                this.informToUser = [];
                this.informToUser = Object.assign(this.informToUser, this.userOptions);
            }
        }
    }

    // handleSubmit(){
    //     const allValid = [...this.template.querySelectorAll('.input-fields')]
    //     .reduce((validSoFar, inputFields) => {
    //         inputFields.reportValidity();
    //         return validSoFar && inputFields.checkValidity();
    //     }, true);


    //     if(this.selectedAwardEmployees && allValid){
    //         let informToMail;
    //         let comment = this.template.querySelector('.comment').value;   
    //         let starType = this.template.querySelector('.star-type').value;     
    //         if(this.selectedInformEmployees){
    //             informToMail = this.getInformToEmail();
    //             console.log('informToMail',informToMail);
    //         }  
    //         let starRecordWrapper=[];
    //         this.selectedAwardEmployees.forEach(ele=>{
    //             console.log('Ele is',ele);
    //             starRecordWrapper.push({StarType:starType,To:ele.email, Comment:comment, InformTo:informToMail, Mail: this.getToMail(ele)})
    //         }) ;   

    //         console.log("starRecordWrapper",starRecordWrapper); 
    //         this.createRecord(JSON.stringify(starRecordWrapper));
    //         this.toUser= Object.assign(this.toUser, this.userOptions);
    //         this.informToUser= Object.assign(this.informToUser, this.userOptions);
    //     }        
    // }

    handleConfirmationModal(){
        const allValid = [...this.template.querySelectorAll('.input-fields')].reduce(
            (validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            },
            true
        ) && this.selectedAwardEmployees.length > 0;


        const commentField = this.template.querySelector('.comment');
        const commentValue = commentField.value.trim();
        const wordCount = commentValue.split(/\s+/).filter(word => word).length;
        const charCount = commentValue.length;

        const isCommentValid = charCount >= 100;
        if (!isCommentValid) {
            this.commentError = 'Comment must contain at least 100 characters.';
            commentField.classList.add('has-error'); // Add error class
        } else {
            this.commentError = '';
            commentField.classList.remove('has-error'); // Add error class
        }

        if (this.selectedAwardEmployees && allValid && isCommentValid) {
            this.confirmationModal=true;
        }else {
            this.showToast({
                detail: {
                    title: 'Validation Error',
                    message: 'Please fill in all required fields, ensure your comment meets the criteria, and select at least one awardee.',
                    variant: 'error'
                }
            });
        }
    }

    handleSubmit() {
            const comment = this.template.querySelector('.comment').value;
            const starType = 'Gold';

            // Prepare informToMail from selectedInformEmployees
            const informToMail = this.selectedInformEmployees
                .map(emp => emp.email)
                .join(';');
            const informToIds = this.selectedInformEmployees
                .map(emp => emp.id)
                .join(';'); // Joining IDs if multiple are needed

            // Prepare starRecordWrapper for submission
            const starRecordWrapper = this.selectedAwardEmployees.map(emp => ({
                StarType: starType,
                To: emp.sfUserId, // Use the ID for backend reference
                Comment: comment,
                InformTo: informToMail,
                InformToId: informToIds, // Corresponding IDs
                Mail: emp.email
            }));

            console.log('starRecordWrapper:', starRecordWrapper);

            // Call createRecord with prepared JSON data
            this.createRecord(JSON.stringify(starRecordWrapper));

            // Resetting selections for Award To and Inform To
            this.selectedAwardEmployees = [];
            this.selectedInformEmployees = [];
            this.awardSearchKey = '';
            this.informSearchKey = '';
            this.confirmationModal=false;
    }

    createRecord(starRecordWrapper) {
        this.awardToSelected = [];
        this.awardToNotify = [];
        insertAwardRecord({ awardRecordJsonString: starRecordWrapper })
            .then(result => {
                console.log("result>>>>", result);
                // Notify LDS of changes
                if (Array.isArray(result)) {
                    const recordIds = result.map(record => ({ recordId: record.Id })); // Extract record IDs
                    recordNotifyChange(recordIds); // Notify LDS
                } else if (result.Id) {
                    recordNotifyChange([{ recordId: result.Id }]); // Single record case
                } else {
                    console.warn('Unexpected result format:', result);
                }
                this.resetValues = true;
                this.refreshTable();
               
                window.clearTimeout(this.timeOut);
                let thisOBJ = this;
                this.timeOut = setTimeout(function () {
                    thisOBJ.resetValues = false;
                }, 500);
                this.fetchInformSuggestions()
                this.showToast({ detail: { title: 'Success', message: 'Successfully Awared Star', variant: 'success' } });
            })
            .catch(error => {
                console.log(error);
                this.showToast({ detail: { title: 'Error', message: JSON.stringify(error), variant: 'error' } });
            });
    }

    getInformToEmail() {
        let emails = [];
        let thisOBJ = this;
        console.log("emailGroup>>", this.emailGroups);
        //console.log("thisOBJ._informTo>>",this.awardToNotify);
        this.emailGroups.forEach(ele => {
            console.log("emailGroups1", ele);
            this.selectedInformEmployees.forEach(eleSub => {
                console.log("emailGroupssub", eleSub);
                if (ele.label === eleSub) {
                    emails.push(ele.value);
                }
            });
        });
        console.log("lstOfUser>>", this.lstOfUser);
        this.lstOfUser.forEach(ele => {
            console.log("lstOfUser", ele);
            this.selectedInformEmployees.forEach(eleSub => {
                console.log("lstOfUsersub", eleSub);
                if (ele.Id === eleSub.id) {
                    emails.push(ele.Email);
                }
            });
        });
        console.log("emails", emails);
        if (emails.length > 0) {
            return emails.join(';');
        } else {
            return '';
        }

    }

    getToMail(toId) {
        const filteredArray = this.lstOfUser.filter(ele => {
            return ele.Id === toId
        });
        if (filteredArray) {
            return filteredArray[0].Email;
        }
    }

    showToast(body) {
        const event = new ShowToastEvent({
            title: body.detail.title,
            message: body.detail.message,
            variant: body.detail.variant

        });
        this.dispatchEvent(event);
    }

    refreshTable() {
        this.template.querySelector('c-list-of-award-star').refreshTable();
    }
}