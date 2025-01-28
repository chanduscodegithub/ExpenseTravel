import { LightningElement,api,wire,track} from 'lwc';
import getGoalSettingDetail from "@salesforce/apex/pmsGoalSettingCmpCtrl.getGoalSettingDetails";
import {baseData} from "c/formDisplayObject";

export default class PreviewManagerGoalSetting extends LightningElement {
    @api managerRecordId;
    wiredResult;
    checkCCMAndRM;
    @track hideManagerGoal

    @track isLoaded = false;


    @wire(getGoalSettingDetail, { empId: '$managerRecordId', ManagerDetails: 'PreviewRM' })
    wiredGoalSetting(values) {
        this.isLoaded = true;
        this.wiredResult = values;
        const { data, error } = values;
        if (data) {
            this.checkCCMAndRM = data.checkCCMAndRM;
            this.hideManagerGoal = data.hideManagerGoal
            this.allKRA = baseData(data.childRecords);
            this.isLoaded = false;
        } else if (error) {
            console.log('error:::' + JSON.stringify(error));
            this.isLoaded = false;
        }
    }

    hidemodalbox(){
        this.dispatchEvent(new CustomEvent('hidemodalbox', {
            detail: {
                message: 'hidemodalbox'
            }
        }));
    }
}