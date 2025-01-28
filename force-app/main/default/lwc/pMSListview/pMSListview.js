import { LightningElement, wire, api } from 'lwc';
import getReporties from '@salesforce/apex/PMS_Controller.getReporties';
import getAllLoginUserEmployees from '@salesforce/apex/PMS_Controller.getAllLoginUserEmployees';
//import getAllRoleHirarchy from '@salesforce/apex/HierarchyController.getAllRoleHirarchy';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
const COLUMNS_DEFINITION_BASIC = [
    {
        type: 'url',
        fieldName: 'empPMSurl',
        label: 'Employee Name',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_self'},
        sortable: true
    },
    {
        type: 'Integer',
        fieldName: 'Year',
        label: 'Year',
    },
    {
        type: 'text',
        fieldName: 'Quarter',
        label: 'Recent Quarter',
    },
    {
        type: 'text',
        fieldName: 'Status',
        label: 'Status',
    },
     
];
export default class PMSListview extends LightningElement {

    hierarchyMap; treeData;
    @api gridColumns = COLUMNS_DEFINITION_BASIC;
    @api primaryKey = 'Id';
    type="view";
    activetabContents;
    isdisable;
    year;


    @wire(CurrentPageReference)
    getPageReferenceParameters(CurrentPageReference) {
        //console.log('~~currentPageReference.state : ', CurrentPageReference.state);
        this.myReporteesFlage = (CurrentPageReference.state.c__prId != null || CurrentPageReference.state.c__prId != undefined) ? false : true;
    }

    connectedCallback() {
        this.year=new Date().getFullYear();
        getAllLoginUserEmployees().then(result => {
            //console.log('~~result : ', result);
            this.parseResult(result);
        }).catch(error => {
            //console.log('error', error, JSON.stringify(error));
        });
    }

    parseResult(result) {
        this.hierarchyMap = [];
        result.superParentList.forEach(element => {

            this.hierarchyMap.push(this.findChildrenNode(element, result));
        });
        this.hierarchyMap = JSON.parse(JSON.stringify(this.hierarchyMap));
        this.treeData = this.hierarchyMap[0]['_children'];
        //console.log('~~hierarchyMap : ', this.hierarchyMap);
        //console.log('~~treeData : ', this.treeData);
    }

    findChildrenNode(element, result) {
        for (var key in result.parentMap) {
            if (key == element[this.primaryKey]) {
                //console.log('~~result.parentMap[key] : ', result.parentMap[key]);
                element["_children"] = result.parentMap[key];
                element["_children"].forEach(child => {
                    this.findChildrenNode(child, result);
                });
            }
        }
        return element;
    }

    handleRowAction(event) {
        console.log('HIII:::');
        const row = event.detail.row;
        console.log('row:::',row);
    }


    @api recordId;
    Employees = [];
    DelegatedEmployees = [];

    myReporteesFlage = true;
    loggedInEmpId = '';
    isSpinner = true;

    //showPopUp = false; popUpBody; popupTitle;
    wrapperData = [];

    empTree = [];
    appraisalCycleId;

    @wire(getReporties) getData(result) {
        if (result.data) {
            this.wrapperData = result.data;
            //console.log('~~ListView Data  ', result.data);
            //console.log('~~employeeTreeData  ', result.data.employeeTreeData);
            this.Employees = result.data.reportiesData;
            this.DelegatedEmployees = result.data.delegateReportiesData;
            this.loggedInEmpId = result.data.loggedInEmpId;
            this.isSpinner = false;
            //console.log('~~ListView Data  ', this.wrapperData.chkManagerSubmissionEndDate,this.wrapperData.chkManagerSubmissionStartDate);

        if(this.wrapperData.chkManagerSubmissionEndDate==false )
        {
            this.isdisable=true;
        }
            // let currentEmail = result.data.logInUserEmail;
            // let JSempEmailData = result.data.employeeEmailTree;

            // let parentEmail = result.data.logInUserEmail;


        }
        else if (result.error) {
            this.isSpinner = false;
            //console.log('~~Error : ', result.error);
        }
    }
    flage = false; EMPID = ''; prId = ''; MgId = ''; deleMgId = ''; deleMgId2 = '';

    pushData(email, obj) {

    }
    handleCancel() {
        this.showPopUp = false;
    }

    handleClick(event) {
        this.type='preportee';
        console.log('this.type',this.type,this.wrapperData.chkManagerSubmissionEndDate,event.currentTarget.dataset.title == 'DelegatedEmps');
        //if (this.wrapperData.chkManagerSubmissionStartDate && this.wrapperData.chkManagerSubmissionEndDate) {
        if (this.wrapperData.chkManagerSubmissionEndDate) {
            this.myReporteesFlage = false;
            let emps = event.currentTarget.dataset.title == 'DelegatedEmps' ? this.DelegatedEmployees : this.Employees;
            this.EMPID = emps[event.currentTarget.dataset.index].Employee__c;

            this.prId = emps[event.currentTarget.dataset.index].Id;
            console.log('~~prId123 : ', this.prId);
            this.MgId = emps[event.currentTarget.dataset.index].Manager__c;
            this.deleMgId = emps[event.currentTarget.dataset.index].Delegated_Manager__c;
            this.deleMgId2 = emps[event.currentTarget.dataset.index].Delegated_Manager2__c;
        }
        else {
            // if (!this.wrapperData.chkManagerSubmissionStartDate) {
            //     this.showToast('Manager Rating is not yet started');
            // } 
            if (!this.wrapperData.chkManagerSubmissionEndDate) {
                this.showToast('Apprasile cycle for the current quarter is closed , please contact HR');
            }

        }

    }

    showToast(msg) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'Error',
            // mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    goBack() {
        this.myReporteesFlage = true;
    }
    handlemanagerrating() {
        this.myReporteesFlage = false;
    }
     handleActiveTab(event) {
     
    this.activetabContents  = event.target.label;
    //console.log('this.activetabContents',this.activetabContents);
  }
}