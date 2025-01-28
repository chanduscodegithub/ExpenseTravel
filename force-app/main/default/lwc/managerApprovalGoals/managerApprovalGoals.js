import { LightningElement, track, api, wire } from 'lwc';
import getReportingManager from '@salesforce/apex/pmsGoalSettingCmpCtrl.getReportiesAndCCM';
import getReporteesOfCurrentUser from '@salesforce/apex/pmsGoalSettingCmpCtrl.getReporteesOfCurrentUser';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS_DEFINITION_BASIC = [
    {
        type: 'text',
        fieldName: 'name',
        label: 'Employee Name'
    },
    {
        type: 'text',
        fieldName: 'EmployeeId',
        label: 'Employee Id'
    },
    {
        type: 'text',
        fieldName: 'Status',
        label: 'Status',
        actions: [
            { label: 'All', checked: true, name: 'All' },
            { label: 'Submitted', checked: false, name: 'Submitted' },
            { label: 'Not Submitted', checked: false, name: 'Not Submitted' },
            { label: 'CCM Approved', checked: false, name: 'CCM Approved' },
            { label: 'Manager Approved', checked: false, name: 'Manager Approved' },
            { label: 'Manager Rejected', checked: false, name: 'Manager Rejected' },
            { label: 'CCM Rejected', checked: false, name: 'CCM Rejected' }
        ]
    },
    {
        label: 'View',
        type: 'button-icon',
        initialWidth: 80,
        typeAttributes: {
            iconName: 'action:preview',
            title: 'Preview',
            variant: '',
            alternativeText: 'View'
        }
    }
];

export default class ManagerApprovalGoals extends LightningElement {

    //GOAL SETTING TRACKS BELOW***********************************------------------------------------------------------------->
    wiresGoalSettingResult;
    @track reportingData;
    @track showSelectedReporties = false;
    @track onclickBy = '';
    @track empRecord = '';
    @track isLoaded = true;

    @track activeSectionMessage;
    @track defaultTabValue = 'one';
    @api defaultAccordian = 'A';

    //sorting
    @track sortedDirection;
    @track sortedColumn;
    @track sortedDirectionCCM;
    @track sortedColumnCCM;
    @track nameSortIcon;
    @track nameSortIconCCM;

    @track isAsc;
    @track isDsc;
    @track idSortIcon;
    @track rmSortIcon;
    @track statusSortIcon;

    @track view = false;

    @track gridColumns = COLUMNS_DEFINITION_BASIC;
    @track hierarchy;
    hierarchyClone;
    @track activeFilter = 'All';
    @track checkHierarchy = false;

    //BELOW JS IS GOAL SETTING Hierarchy START HERE------------------------------------------------->
    @wire(getReporteesOfCurrentUser)
    wiredHierarchy({ data, error }) {
        if (data) {
            this.hierarchy = data;
            this.hierarchyClone = data;
            if (this.hierarchyClone.length > 0) {
                this.checkHierarchy = true;
            }
            //console.log('hierarchy::' + JSON.stringify(this.hierarchy));
        } else if (error) {
            console.error('Error fetching hierarchy:', error);
        }
    }

    handleHeaderAction(event) {
        const actionName = event.detail.action.name;
        console.log('event.detail.action.name::' + event.detail.action.name);
        let columns = this.gridColumns;
        const activeFilter = this.activeFilter;


        if (actionName !== activeFilter) {
            var actions = columns[2].actions;
            actions.forEach((action) => {
                console.log('actions::' + actionName);
                action.checked = action.name === actionName;
            });
            columns[2].actions = actions;
            this.activeFilter = actionName;
            this.gridColumns = columns;
            this.updateRows();
        }
    }

    updateRows() {
        const rows = this.hierarchyClone;
        let filteredRows = rows;
        const activeFilter = this.activeFilter;

        if (activeFilter !== 'All') {
            filteredRows = rows.filter(function (row) {
                return (activeFilter === row.Status);
            });
        }
        this.hierarchy = filteredRows;
    }

    handleRowAction(event) {
        const dataRow = event.detail.row.Status;
        if (dataRow === 'CCM Approved') {
            const value = {
                onclickBy: 'Preview',
                empRecord: event.detail.row.EmployeeId,
                defaultAccordian: this.defaultAccordian
            };

            this.dispatchEvent(new CustomEvent('showreportee', {
                detail: {
                    message: value,
                }
            }));
        } else {
            this.toastMsg('Goals not yet CCM approved it is not able to preview', '', 'error');
        }
    }
    //BELOW JS IS GOAL SETTING Hierarchy ENDS HERE------------------------------------------------->


    //BELOW JS IS GOAL SETTING START HERE------------------------------------------------->
    @wire(getReportingManager)
    wiredReportingManager(value) {

        this.wiresGoalSettingResult = value;
        const { data, error } = value;
        if (data) {
            this.reportingData = data;
            this.isLoaded = false;
        } else if (error) {
            console.log(JSON.stringify('Error::' + error));
            this.isLoaded = false;
        }
    }

    handleToggleSection(event) {
        this.activeSectionMessage = event.detail.openSections;
    }

    handleSelectedEmp(event) {
        if (event.target.name === 'RM') {
            this.onclickBy = 'RM';
            this.empRecord = this.reportingData.ReportingManager[event.currentTarget.dataset.index].EmployeeID__c;
        } else if (event.target.name === 'CCM') {
            this.onclickBy = 'CCM';
            this.empRecord = this.reportingData.ReportingCCM[event.currentTarget.dataset.index].EmployeeID__c;
        }
        this.showSelectedReporties = true;
        this.myReporteesFlage = false;
        this.defaultAccordian = this.activeSectionMessage;

        const value = {
            onclickBy: this.onclickBy,
            empRecord: this.empRecord,
            defaultAccordian: this.defaultAccordian
        };

        this.dispatchEvent(new CustomEvent('showreportee', {
            detail: {
                message: value,
            }
        }));
    }

    @api refreshData() {
        this.defaultTabValue = 'one';
        return refreshApex(this.wiresGoalSettingResult);
    }

    @api navigateHierarchy() {
        this.defaultTabValue = 'two';
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('callback', {
            detail: {
                message: 'callback',

            }
        }));
    }

    sortRecsRM(event) {

        let colName = event.target.name;
        if (this.sortedColumn === colName) {
            this.sortedDirection = (this.sortedDirection === 'asc' ? 'desc' : 'asc');
        }
        else {
            this.sortedDirection = 'asc';
        }

        if (this.sortedDirection === 'asc') {
            this.nameSortIcon = 'utility:arrowup';
        } else {
            this.nameSortIcon = 'utility:arrowdown';
        }


        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        this.sortedColumn = colName;

        // sort the data reportingData.ReportingManager
        const sortedRecords = [...this.reportingData.ReportingManager].sort((a, b) => {
            let aValue, bValue;

            if (colName === 'ReportingTo__r.Name') {
                aValue = a.ReportingTo__r ? a.ReportingTo__r.Name.toLowerCase() : '';
                bValue = b.ReportingTo__r ? b.ReportingTo__r.Name.toLowerCase() : '';
            } else if (colName === 'Goal_Settings__r.Status__c') {
                aValue = a.Goal_Settings__r && a.Goal_Settings__r.length > 0 ? a.Goal_Settings__r[0].Status__c.toLowerCase() : '';
                bValue = b.Goal_Settings__r && b.Goal_Settings__r.length > 0 ? b.Goal_Settings__r[0].Status__c.toLowerCase() : '';
            } else {
                aValue = a[colName] ? a[colName].toLowerCase() : '';
                bValue = b[colName] ? b[colName].toLowerCase() : '';
            }
            return aValue.localeCompare(bValue) * isReverse;

        });

        this.reportingData = {
            ...this.reportingData,
            ReportingManager: sortedRecords
        };

        //console.log('Updated data:', JSON.stringify(this.reportingData));

    }

    sortRecsCCM(event) {

        let colName = event.target.name;

        if (this.sortedColumnCCM === colName) {
            this.sortedDirectionCCM = (this.sortedDirectionCCM === 'asc' ? 'desc' : 'asc');
        }
        else {
            this.sortedDirectionCCM = 'asc';
        }

        if (this.sortedDirectionCCM === 'asc') {
            this.nameSortIconCCM = 'utility:arrowup';
        } else {
            this.nameSortIconCCM = 'utility:arrowdown';
        }


        let isReverse = this.sortedDirectionCCM === 'asc' ? 1 : -1;

        this.sortedColumnCCM = colName;

        const sortedRecords = [...this.reportingData.ReportingCCM].sort((a, b) => {
            let aValue, bValue;

            if (colName === 'ReportingTo__r.Name') {
                aValue = a.ReportingTo__r ? a.ReportingTo__r.Name.toLowerCase() : '';
                bValue = b.ReportingTo__r ? b.ReportingTo__r.Name.toLowerCase() : '';
            } else if (colName === 'Goal_Settings__r.Status__c') {
                aValue = a.Goal_Settings__r && a.Goal_Settings__r.length > 0 ? a.Goal_Settings__r[0].Status__c.toLowerCase() : '';
                bValue = b.Goal_Settings__r && b.Goal_Settings__r.length > 0 ? b.Goal_Settings__r[0].Status__c.toLowerCase() : '';
            } else {
                aValue = a[colName] ? a[colName].toLowerCase() : '';
                bValue = b[colName] ? b[colName].toLowerCase() : '';
            }

            return aValue.localeCompare(bValue) * isReverse;

        });

        this.reportingData = {
            ...this.reportingData,
            ReportingCCM: sortedRecords
        };
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