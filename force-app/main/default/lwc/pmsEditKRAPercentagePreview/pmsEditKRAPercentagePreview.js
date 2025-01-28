import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PmsEditKRAPercentagePreview extends LightningElement {
    @api allKRAparent;
    @api userId;
    @api empId;
    @api empName;
    @api appraisalCycleId;
    @track allKRA;
    @track totalWeightage = 0;
    @track isLoaded = false;

    @track textColor;

    connectedCallback() {
        this.allKRA = JSON.parse(JSON.stringify(this.allKRAparent));
        this.calculateTotalWeightage();
    }

    @api turnOffLoader() {
        this.isLoaded = false
    }

    handleKeyPress(event) {
        const allowedChars = /^[0-9]*$/;
        if (!allowedChars.test(event.key)) {
            event.preventDefault();
        }
    }

    calculateTotalWeightage() {
        this.totalWeightage = 0;
        this.allKRA.forEach(item => {
            this.totalWeightage += parseFloat(item.MaximunKRAWieghtage);
        });
        if (this.totalWeightage === 100) {
            this.textColor = 'text-green';
        } else {
            this.textColor = 'text-red';
        }
    }

    handleChangeHandler(event) {
        if (event.target.value !== "") {
            this.allKRA[event.currentTarget.dataset.index].MaximunKRAWieghtage = event.target.value;
        } else {
            this.allKRA[event.currentTarget.dataset.index].MaximunKRAWieghtage = 0;
        }
        this.calculateTotalWeightage();
    }

    handleSubmit() {
        this.isLoaded = true;
        if (this.totalWeightage !== 100 && this.totalWeightage !== 0) {
            this.toastMsg('Total KRA weightage should be 100%', 'KRA weightage should be 100%', 'Error');
            this.isLoaded = false;
            return;
        }
        var array = [];
        var validate = false;
        this.allKRA.forEach(item => {
            if (item.MaximunKRAWieghtage === '' || parseInt(item.MaximunKRAWieghtage) === 0 || item.MaximunKRAWieghtage === undefined) {
                this.toastMsg('Please fill the required field', 'KRA Weightage cannot be blank or zero', 'Error');
                this.isLoaded = false;
                validate = true;
                return;
            }

            if (validate == true) {
                return;
            }

            try {
                var todayDate = new Date();
                const record = {};
                if (item.goalSettingId == "") {
                    record.Appraisal_Cycle__c = this.appraisalCycleId;
                    record.Goal_Repository__c = item.goalRespository.Id;
                    record.Employee__c = this.empId;
                } else {
                    record.Id = item.goalSettingId;
                }
                record.KRA_Weightage__c = parseInt(item.MaximunKRAWieghtage);
                record.Is_KRA_Weightage_Edited__c = true;
                record.KRA_Weightage_Edited_By__c = this.userId;
                record.KRA_Weightage_Edited_Date__c = todayDate.getFullYear() + '-' + (todayDate.getMonth() + 1) + '-' + todayDate.getDate();
                array.push(record);
            } catch (error) {
                // Handle the exception or error here
                console.error('An error occurred:', error.message);
            }
        });

        //console.log('data:::' + JSON.stringify(array));
        this.dispatchEvent(new CustomEvent('callparent', {
            detail: {
                message: array
            }
        }));

    }

    hideModalBox() {
        this.dispatchEvent(new CustomEvent('callparent', {
            detail: {
                message: 'hidemodalbox'
            }
        }));
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
}