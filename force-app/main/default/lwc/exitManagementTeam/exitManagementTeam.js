import { LightningElement, api, wire } from 'lwc';
import getTeamResignationRecords from '@salesforce/apex/ExitManagementController.getTeamResignationRecords';
import getAllResignationRecords from '@salesforce/apex/ExitManagementController.getAllResignationRecords';
import checkHR from '@salesforce/apex/ExitManagementController.checkHR';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getErrorBody } from './utils';

export default class ExitManagementTeam extends LightningElement {
    loaded = false;
    resignations = [];
    error;
    selectedRow = null;
    showRecord = false;
    showList = false;
    _empData;
    isHR;


    @api set empData(value) {
        this._empData = value;
    }
    get empData() {
        return this._empData;
    }

    @wire(checkHR)
    wiredCheckHR({ error, data }) {
        if (data) {
            this.isHR = data;
            if (this.isHR === 'Yes') {
               this.getTeamResignationRecAsHR();
                console.log('AS HR');
            } else {
                this.getTeamResignationRecAsCCMorManager();
                console.log('AS Manager');
            }
        }
        if (error) {
            console.log(error);
            this.error = error;
            this.dispatchEvent(new ShowToastEvent(getErrorBody(error, 'sticky')));
        }
    }
    async getTeamResignationRecAsCCMorManager() {
        try {
            let data = await getTeamResignationRecords();
            this.resignations = data.map((record, index) => {
                return {
                    ...record, serialNumber: index + 1
                }
            });
            this.loaded = true;
            this.showList = true;
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent(getErrorBody(error, 'sticky')));
        }
    }

    async getTeamResignationRecAsHR() {
        try {
            let data = await getAllResignationRecords();
            this.resignations = data.map((record, index) => {
                return {
                    ...record, serialNumber: index + 1
                }
            });
            this.loaded = true;
            this.showList = true;
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent(getErrorBody(error, 'sticky')));
        }
    }

    handleRowClick(event) {
        console.log(event.currentTarget.dataset.id);
        const recordId = event.currentTarget.dataset.id;
        this.selectedRow = this.resignations.find(resignation => resignation.Id === recordId);
        if (this.selectedRow !== null) {
            this.showRecord = true;
            this.showList = false;
        }
    }

    closeDetail(e) {
        this.selectedRow = null;
        this.showRecord = false;
        this.showList = true;
    }
}