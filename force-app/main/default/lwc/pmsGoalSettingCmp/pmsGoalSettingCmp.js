import { LightningElement, track, wire, api } from 'lwc';
import getGoalSettingDetail from "@salesforce/apex/pmsGoalSettingCmpCtrl.getGoalSettingDetails";
import createOrUpdateGoalSetting from "@salesforce/apex/pmsGoalSettingCmpCtrl.createOrUpdateGoalSetting";
import rejectGoalSetting from "@salesforce/apex/pmsGoalSettingCmpCtrl.rejectGoalSettingCtrl";
import handleKRAWeightage from "@salesforce/apex/pmsGoalSettingCmpCtrl.handleKRAWeightageCtrl";
import upsertKraDiscription from "@salesforce/apex/pmsGoalSettingCmpCtrl.upsertKraDiscription";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import generateData from "./generateData";
import { baseData } from "c/formDisplayObject";
import LightningConfirm from "lightning/confirm";
import Id from "@salesforce/user/Id";

export default class PmsGoalSettingCmp extends LightningElement {

    @api empId = '';
    @api managerDetails = '';

    wiredResult;
    @track empRecords = {};
    @track appraisalCycle = {};
    @track allKRA = [];
    @track isLoaded = false;
    @track reportingManagerId;
    @track userId = Id;

    //show reporting manager goal setting
    @track showRmGs = true;
    @track editKRA = false;
    @track accessKRAWeightage = false;
    @track editKRAWeightage = false;
    @track inlineEditKRADisp = false;
    @track hideHeader = true;
    @track kraDiscription;
    @track employeeStatus = '';

    @track error = [];

    @track empreportManager;
    @track designation;
    @track ccm;
    @track title = 'Annual Goals';
    @track submitTitle = 'Submit';
    @track careerButtonLabel = 'My Career and Training Plan';

    goalSettingId;

    @track checkCCMAndRM;
    @track disableButton = false;
    @track previewPopUp = false;
    @track previewReportingManagerGS = false;
    @track showTeamAttendence = false;
    @track hideMyGoal = true;
    @track carererAndEnablementPlan = false;
    @track editKRAWeightage = false;

    @track hidebutton = false;
    @track showOrHidereject = 'slds-button slds-button_brand slds-hide';
    @track showAndHidebuttoncss = 'slds-button slds-button_brand slds-hide';
    @track dragStart;
    @track title = 'Set Your Goals For 2024';

    @track defaultAccordian = 'A';

    buttonClicked = 'No Action';

    @wire(getGoalSettingDetail, { empId: '$empId', ManagerDetails: '$managerDetails' })
    wiredGoalSetting(values) {

        if (this.managerDetails != '') {
            this.showRmGs = false;
        } else {
            this.showRmGs = true;
        }
        //manager Edit KRa Discription Logic
        if (this.managerDetails === 'CCM' || this.managerDetails === 'RM') {
            this.editKRA = true;
            this.careerButtonLabel = 'Career and Training Plan'
        } else {
            this.editKRA = false;
            this.submitTitle = 'Submit';
            this.careerButtonLabel = 'My Career and Training Plan'
        }

        if (this.managerDetails === 'RM') {
            this.submitTitle = 'Accept';
        } else if (this.managerDetails === 'CCM') {
            this.submitTitle = 'Approve';
        }

        this.isLoaded = true;
        this.wiredResult = values;
        const { data, error } = values;
        if (data) {
            this.empRecords = data.emp;
            //employee manager Details and designation
            this.empreportManager = this.empRecords?.ReportingTo__r?.Name;
            this.designation = this.empRecords?.Designation__r.Name;
            this.ccm = this.empRecords?.BU_Head__c != undefined ? this.empRecords.BU_Head__r?.Name : '';

            this.reportingManagerId = data.reportingManagerEmpId;
            this.hidebutton = data.goalRespotaryvalidation;
            //console.log('CHECK DISABLE::' + this.hidebutton);

            if (this.hidebutton === true) {
                this.showAndHidebuttoncss = 'slds-button slds-button_brand slds-hide';
            } else {
                this.showAndHidebuttoncss = 'slds-button slds-button_brand bg-color';
            }

            if ((this.managerDetails === 'RM' || this.managerDetails === 'CCM') && this.hidebutton === false) {
                this.showOrHidereject = 'slds-button slds-button_brand bg-color';
            } else {
                this.showOrHidereject = 'slds-button slds-button_brand slds-hide';
            }

            this.appraisalCycle = data.apprailCycle;
            this.checkCCMAndRM = data.checkCCMAndRM;
            this.employeeStatus = data.employeeStatus;
            if ((this.managerDetails === 'RM' || this.managerDetails === 'CCM') && this.checkCCMAndRM === true) {
                this.submitTitle = 'Accept & Approve';
            } if (this.editKRA === true && this.employeeStatus !== 'Not Submitted') {
                this.editKRA = false;
            }

            this.accessKRAWeightage = (
                this.managerDetails === 'CCM' &&
                this.employeeStatus === 'Not Submitted' &&
                this.empRecords?.BU_Head__c !== undefined &&
                this.empRecords.BU_Head__r?.Corporate_Band__c === 'Band 4' &&
                (this.empRecords.BU_Head__r?.Grade__c === 'E2' ||
                    this.empRecords.BU_Head__r?.Grade__c === 'E3' ||
                    this.empRecords.BU_Head__r?.Grade__c === 'E4')) ? true : false;

            if (this.employeeStatus === 'Not Submitted' && this.empRecords.Corporate_Band__c === 'Band 4' && (this.empRecords.Grade__c === 'E2' || this.empRecords.Grade__c === 'E3' || this.empRecords.Grade__c === 'E4')) {
                this.editKRA = true;
                this.accessKRAWeightage = true;
            }
            this.allKRA = baseData(data.childRecords);
            this.isLoaded = false;
        } else if (error) {
            console.log('error:::' + JSON.stringify(error));
            this.isLoaded = false;
        }
    }

    handleEditKraDiscription(event) {
        if (event.target.name === 'goalRespository') {
            this.allKRA[event.currentTarget.dataset.id].editable = true;
            this.allKRA[event.currentTarget.dataset.id].showGrKRADiscription = true;
        } else if (event.target.name === 'goalSetting') {
            this.allKRA[event.currentTarget.dataset.id].editable = true;
            this.allKRA[event.currentTarget.dataset.id].showGrKRADiscription = false;
        }
    }

    handleCareerEnablement() {
        this.hideMyGoal = false;
        this.hideHeader = false;
        this.carererAndEnablementPlan = true;
    }

    handleKRADiscription(event) {
        this.allKRA[event.currentTarget.dataset.id].editedKraDiscription = event.target.value;
    }

    saveAsDraftKRADisp(event) {
        if (this.allKRA[event.currentTarget.dataset.id].editedKraDiscription != null && this.allKRA[event.currentTarget.dataset.id].editedKraDiscription != '') {
            this.isLoaded = true;
            this.upsertKRADiscription(event.currentTarget.dataset.id, 'Draft');
        } else {
            this.toastMsg('Please edit KRA discription', 'There is no change in KRA discription', 'Error');
        }
    }

    //handle edit view starts-------------
    handleEditView(event) {
        this.editKRAWeightage = true;
    }

    handleKRAWeightage(event) {
        if (event.detail.message === 'hidemodalbox') {
            this.editKRAWeightage = false;
        } else {
            const allRecord = event.detail.message;

            handleKRAWeightage({ arrayResult: JSON.stringify(allRecord) })
                .then(result => {
                    //console.log('result:::' + result);
                    if (result === 'success') {
                        this.toastMsg('KRA weightage updated', 'KRA weightage submitted successfully', 'success');
                    } else {
                        this.toastMsg('OOPS.. KRA description failed to updated', 'Please contact admin', 'error');
                    }
                    this.template.querySelector("c-pms-edit-k-r-a-percentage-preview").turnOffLoader();
                    this.editKRAWeightage = false;
                    return refreshApex(this.wiredResult);

                }).catch(error => {
                    console.log("error", JSON.stringify(error));
                    this.toastMsg('OOPS.. Goal setting failed to reject', 'Please contact admin', 'error');
                    this.template.querySelector("c-pms-edit-k-r-a-percentage-preview").turnOffLoader();
                    this.editKRAWeightage = false;
                });
        }
    }
    //end here

    async confirmUpdateKRADisp(event) {

        const eventId = event.currentTarget.dataset.id;

        if (this.allKRA[eventId].editedKraDiscription != null && this.allKRA[eventId].editedKraDiscription != '') {
            //console.log('enter 1:::');
            const result = await LightningConfirm.open({
                message: "Are you sure you want to submit KRA discription?",
                label: "Can you confirm?",
                theme: "warning"
            });
            if (result) {
                this.isLoaded = true;
                this.upsertKRADiscription(eventId, 'Confirmed');
            } else {
                this.isLoaded = false;
            }
        } else if (this.allKRA[eventId].goalSetting.Is_KRA_Edited__c === true) {
            //console.log('enter 2:::');
            const kraDiscription = this.allKRA[eventId].goalSetting.KRA_Discription__c;

            const result = await LightningConfirm.open({
                message: "Are you sure you want to submit KRA discription?",
                label: "Can you confirm?",
                theme: "warning"
            });
            if (result) {
                this.allKRA[eventId].editedKraDiscription = kraDiscription;
                this.isLoaded = true;
                this.upsertKRADiscription(eventId, 'Confirmed');
            } else {
                this.isLoaded = false;
            }
        } else {
            this.toastMsg('Please edit KRA discription', 'There is no change in KRA discription', 'Error');
        }
    }

    cancelKRADisp(event) {
        this.allKRA[event.currentTarget.dataset.id].editable = false;
        this.allKRA[event.currentTarget.dataset.id].showGrKRADiscription = false;
    }

    upsertKRADiscription(eventId, status) {
        var record = {};
        var todayDate = new Date();
        if (this.allKRA[eventId].goalSettingId != "") {
            record.Id = this.allKRA[eventId].goalSettingId;
            record.KRA_Status__c = status;
            record.KRA_Discription__c = this.allKRA[eventId].editedKraDiscription;
            record.Is_KRA_Edited__c = true;
            record.KRA_Edited_By__c = this.userId;
            record.KRA_Edited_Date__c = todayDate.getFullYear() + '-' + (todayDate.getMonth() + 1) + '-' + todayDate.getDate();
        } else {
            record.KRA_Status__c = status;
            record.KRA_Discription__c = this.allKRA[eventId].editedKraDiscription;
            record.Is_KRA_Edited__c = true;
            record.KRA_Edited_By__c = this.userId;
            record.Appraisal_Cycle__c = this.appraisalCycle.Id;
            record.Goal_Repository__c = this.allKRA[eventId].goalRespository.Id;
            record.Employee__c = this.empRecords.Id;
            record.KRA_Edited_Date__c = todayDate.getFullYear() + '-' + (todayDate.getMonth() + 1) + '-' + todayDate.getDate();
        }

        upsertKraDiscription({ arrayResult: JSON.stringify(record) })
            .then(result => {
                if (result === 'success') {
                    if (status === 'Draft') {
                        this.toastMsg('KRA description saved as draft', 'KRA description saved successfully', 'success');
                    } else {
                        this.toastMsg('KRA description submitted', 'KRA description submitted successfully', 'success');
                    }

                } else {
                    this.toastMsg('OOPS.. KRA description failed to updated', 'Please contact admin', 'error');
                }
                this.isLoaded = false;
                refreshApex(this.wiredResult);

            }).catch(error => {
                this.toastMsg('OOPS.. Goal setting failed to reject', 'Please contact admin', 'error');
                console.log("error", JSON.stringify(error));
                this.isLoaded = false;
            });
    }

    handleManagerView() {
        this.showTeamAttendence = true;
        this.hideMyGoal = false;
    }

    toastMsg(title, msg, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant,
            }),
        );
    }

    handleKeyPress(event) {
        const allowedChars = /^[0-9]*$/;
        if (!allowedChars.test(event.key)) {
            event.preventDefault();
        }
    }

    changeHandler(event) {
        if (event.target.name === 'kraName') {
            this.allKRA[event.currentTarget.dataset.id].goalSettingArray[event.currentTarget.dataset.index].KPI = event.target.value;
        } else if (event.target.name === 'kraWieghtage') {
            this.allKRA[event.currentTarget.dataset.id].goalSettingArray[event.currentTarget.dataset.index].KPIWieghtage = event.target.value.toString();
            this.rollupValues(this.allKRA[event.currentTarget.dataset.id].goalSettingArray, event.currentTarget.dataset.id);
        }
        //console.log('dataAf:::' + JSON.stringify(this.allKRA[event.currentTarget.dataset.id].goalSettingArray));

    }

    rollupValues(data, index) {
        var totalKRAweigtage = 0;
        data.forEach(item => {
            if (item.KPIWieghtage !== '') {
                totalKRAweigtage += parseFloat(item.KPIWieghtage);
            } else {
                totalKRAweigtage += 0;
            }
        });
        this.allKRA[index].KRAWieghtage = totalKRAweigtage;
        //console.log('dataAf:::' + JSON.stringify(this.allKRA[index]));
    }

    addRow(event) {
        if (this.hidebutton) {
            this.toastMsg('You cannot add new rows', '', 'Error');
            return;
        }

        var keyIndex = this.allKRA[event.target.accessKey].goalSettingArray.length - 1;
        if (keyIndex === 4 && this.allKRA[event.target.accessKey].goalRespository.Name === 'Core Responsibilities') {
            this.toastMsg('You can add maximum of 5 rows', 'You can add maximum of 5 rows', 'Error');
            return;
        } if (keyIndex === 2 && this.allKRA[event.target.accessKey].goalRespository.Name === 'Value Creation') {
            this.toastMsg('You can add maximum of 3 rows', 'You can add maximum of 3 rows', 'Error');
            return;
        } if (keyIndex === 2 && this.allKRA[event.target.accessKey].goalRespository.Name === 'Continuous Improvement') {
            this.toastMsg('You can add maximum of 3 rows', 'You can add maximum of 3 rows', 'Error');
            return;
        } if (keyIndex === 2 && this.allKRA[event.target.accessKey].goalRespository.Name === 'Compliance') {
            this.toastMsg('You can add maximum of 3 rows', 'You can add maximum of 3 rows', 'Error');
            return;
        }
        this.allKRA[event.target.accessKey].goalSettingArray.push({
            keyIndex: ++keyIndex,
            KPI: '',
            KPIWieghtage: ''
        });
        //console.log('dataAf:::' + JSON.stringify(this.allKRA[event.target.accessKey].goalSettingArray));
    }

    removeRow(event) {
        //this.isLoaded = true;

        var key = event.currentTarget.dataset.index;
        if (this.allKRA[event.currentTarget.dataset.id].goalSettingArray.length > 1) {
            this.allKRA[event.currentTarget.dataset.id].goalSettingArray.splice(key, 1);
            //console.log('dataAf:::' + JSON.stringify(this.allKRA[event.target.accessKey].goalSettingArray));
        } else if (this.allKRA[event.currentTarget.dataset.id].goalSettingArray.length == 1) {
            this.toastMsg('You cannot delete row', 'You cannot delete last row', 'Error');
        }
        this.rollupValues(this.allKRA[event.currentTarget.dataset.id].goalSettingArray, event.currentTarget.dataset.id)
        //console.log('dataAf:::' + JSON.stringify(this.allKRA[event.target.accessKey].goalSettingArray));
    }

    previewHandler() {
        var result = this.valiation();
        if (result === 'NoIssue') {
            this.previewPopUp = true;
        }
    }

    valiation() {
        this.isLoaded = true;
        var lenghtOfKPI = 0;
        let validationFired = false;
        this.allKRA.forEach((item, index) => {
            lenghtOfKPI += item.goalSettingArray.length;
            if (item.goalSettingArray.length > 0) {
                var totalKPIWieghtage = 0;
                item.goalSettingArray.forEach(kpi => {
                    if (validationFired) {
                        return;
                    }
                    if (kpi.KPI == null || kpi.KPI == '') {
                        this.toastMsg('Please fill in the KRA ' + '"' + item.goalRespository.Name + '"' + ', KPIs, and their corresponding weightage', '', 'Error');
                        validationFired = true;
                        this.isLoaded = false;
                        return;
                    }
                    if (kpi.KPIWieghtage == null || kpi.KPIWieghtage == '') {
                        this.toastMsg('Please fill in the KRA ' + '"' + item.goalRespository.Name + '"' + ', KPIs, and their corresponding weightage', '', 'Error');
                        validationFired = true;
                        this.isLoaded = false;
                        return;
                    }
                    totalKPIWieghtage += parseFloat(kpi.KPIWieghtage);
                });

                if (validationFired === false && totalKPIWieghtage !== item.MaximunKRAWieghtage) {
                    //this.toastMsg('Please validate KPI weightage', 'Sum of total KPI weightage should be equal to KRA weightage', 'Error');
                    this.toastMsg('Please validate weightage of KRA ' + '"' + item.goalRespository.Name + '"', 'Sum of total KPI weightage should be equal to KRA weightage', 'Error');
                    validationFired = true;
                    this.isLoaded = false;
                    return;
                }
            }
        });

        if (validationFired) {
            this.isLoaded = false;
            return;
        } else if (lenghtOfKPI > this.appraisalCycle.Total_KPI_Limit__c) {
            this.toastMsg('Maximum 10 KPIs allowed', 'You can enter maximum of 10 KPIs', 'Error');
            this.isLoaded = false;
            return;
        } else {
            this.isLoaded = false;
            return 'NoIssue';
        }
    }

    updateMessage(event) {
        const message = event.detail.message;
        if (message === 'CloseTheHideBox') {
            this.previewPopUp = false;
        } else if (message === 'Submitomanager') {
            this.previewPopUp = false;
            this.buttonClicked = 'submitToManager';
            if (this.isLoaded === true) {
                return;
            }
            this.isLoaded = true;
            this.handleSaveHandler();

        }
    }

    async rejectByManagerOrCCM() {
        this.isLoaded = true;
        const result = await LightningConfirm.open({
            message: "Are you sure you want to reject goal setting(KRA/KPI)?",
            label: "Can you confirm?",
            theme: "warning"
        });

        if (result) {
            var generatedObject = [];
            this.allKRA.forEach(item => {
                generatedObject.push({
                    Id: item.goalSettingId,
                    Status__c: this.managerDetails === 'RM' ? 'Manager Rejected' : (this.managerDetails === 'CCM' ? 'CCM Rejected' : 'Not Submitted')
                });
            });

            rejectGoalSetting({ arrayResult: JSON.stringify(generatedObject) })
                .then(result => {
                    if (result === 'success') {
                        this.toastMsg('Goal setting rejected successfully', 'Goal setting rejected successfully', 'success');
                    } else {
                        this.toastMsg('OOPS.. Goal setting failed to reject', 'Please contact admin', 'error');
                    }
                    this.buttonClicked = 'No Action';
                    this.isLoaded = false;
                    refreshApex(this.wiredResult);

                }).catch(error => {
                    this.toastMsg('OOPS.. Goal setting failed to reject', 'Please contact admin', 'error');
                    console.log("error", JSON.stringify(error));
                    this.isLoaded = false;
                    this.buttonClicked = 'No Action';
                    //refreshApex(this.wiredResult);
                });

        } else {
            this.isLoaded = false;
        }
    }

    saveAsDraftHandler() {
        if (this.isLoaded === true) {
            return;
        }
        this.isLoaded = true;
        this.buttonClicked = 'saveAsDraft';
        this.handleSaveHandler();
    }

    handleSaveHandler() {

        generateData(this.allKRA, this.empRecords, this.appraisalCycle, this.buttonClicked, this.managerDetails, this.checkCCMAndRM)
            .then(resultData => {
                if (resultData.length === 0) {
                    //console.log('HI:::');
                    this.toastMsg('Please fill required field', 'Please fill atleast one KPI and KPI wieghtage', 'error');
                    this.isLoaded = false;
                    return;
                }
                createOrUpdateGoalSetting({ arrayResult: JSON.stringify(resultData), empRecordString: JSON.stringify(this.empRecords), action: this.buttonClicked })
                    .then(result => {
                        if (result === 'success') {
                            if (this.buttonClicked === 'saveAsDraft') {
                                this.toastMsg('Your goals are save as draft', 'Your goals are save as draft successfully', 'success');
                            } else {
                                this.toastMsg('Your goals are submitted', 'Your goals are submitted successfully', 'success');
                            }
                            //this.toastMsg('Your goals are submitted', 'Your goals are submitted successfully', 'success');
                        } else if (result === 'No Career') {
                            this.toastMsg('No record found on Career and Traning Plan', 'Please update your Career and Traning Plan, untill you cannot submit your goals', 'error');
                        } else {
                            this.toastMsg('OOPS.. Goals failed to submit', 'Please contact admin', 'error');
                        }
                        //this.isLoaded = false;
                        this.buttonClicked = 'No Action';
                        //this.isLoaded = false;
                        return refreshApex(this.wiredResult);

                    }).catch(error => {
                        this.toastMsg('OOPS.. Goal setting failed to submit', 'Please contact admin', 'error');
                        console.log("error", JSON.stringify(error));
                        this.isLoaded = false;
                        this.buttonClicked = 'No Action';
                    });
            }).catch(error => {
                console.log("error", JSON.stringify(error));
                this.isLoaded = false;
                return refreshApex(this.wiredResult);
            });
    }

    //manager GS
    hideReportingManagerGS() {
        this.previewReportingManagerGS = false;
    }

    handleCallBack() {
        this.managerDetails = '';
        this.empId = '';
        this.showTeamAttendence = false;
        this.hideMyGoal = true;
    }

    handleDisplayReportee(event) {
        const returnData = event.detail.message;
        this.empId = returnData.empRecord;
        this.managerDetails = returnData.onclickBy;
        this.defaultAccordian = returnData.defaultAccordian;
        this.showTeamAttendence = false;
        this.hideMyGoal = true;
    }

    callcancel() {
        if (this.empId === '') {
            return;
        } else if (this.managerDetails === 'Preview') {
            this.showTeamAttendence = true;
            this.hideMyGoal = false;
            setTimeout(() => {
                this.template.querySelector("c-manager-approval-goals").navigateHierarchy();
            }, 1000);
        } else {
            this.showTeamAttendence = true;
            this.hideMyGoal = false;

            setTimeout(() => {
                this.template.querySelector("c-manager-approval-goals").refreshData();
            }, 5000);
        }
    }

    showManagerGS() {
        this.previewReportingManagerGS = true;
    }

    handleCancelCarrer(event) {
        this.carererAndEnablementPlan = false;
        this.hideMyGoal = true;
        this.hideHeader = true;
    }


    //dragger component
    DragStart(event) {
        if (this.hidebutton) {
            return;
        }
        this.dragStart = event.currentTarget.dataset.index;//event.target.accessKey;
        event.target.classList.add("drag");
    }

    DragOver(event) {
        if (this.hidebutton) {
            return;
        }
        event.preventDefault();
        return false;
    }

    Drop(event) {

        if (this.hidebutton) {
            return;
        }

        event.stopPropagation();
        const DragValName = this.dragStart;
        const DropValName = event.currentTarget.dataset.index;
        if (DragValName === DropValName) {
            return false;
        }
        const currentIndex = DragValName;
        const newIndex = DropValName;
        Array.prototype.move = function (from, to) {
            this.splice(to, 0, this.splice(from, 1)[0]);
        };
        this.allKRA[event.currentTarget.dataset.id].goalSettingArray.move(currentIndex, newIndex);
    }



    /*callcancel() {
        if (this.empId === '') {
            this.dispatchEvent(new CustomEvent('callcancelemp', {
                detail: {
                    message: 'callcancelemp',

                }
            }));
        } else {
            this.dispatchEvent(new CustomEvent('callcancel', {
                detail: {
                    message: 'callcancel',

                }
            }));
        }
    }*/
}