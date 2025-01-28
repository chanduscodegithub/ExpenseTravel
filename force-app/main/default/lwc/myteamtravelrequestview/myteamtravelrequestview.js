import { LightningElement } from 'lwc';
import getPendingApprovals from '@salesforce/apex/Travelrequestclass.getPendingApprovals';
import getbillsdata from '@salesforce/apex/Travelrequestclass.getbillsdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Myteamtravelrequestview extends LightningElement {
    selectedStatus = 'Pending for Approval';
    approvals = [];
    button;
    showList = false;
    selectedWorkItemId;
    recordId;
    traveltype1;
    datedep;
    datere;
    dest;
    purposevisit;
    billcus;
    cus;
    dep;
    des;
    curr;
    reqamo;
    existra;
    card;
    empname;


    modetr;
    billsdata;
    fetchPendingApprovals(selectedstatus) {
        getPendingApprovals({ status: selectedstatus })
            .then((data) => {

                if (data) {
                    console.log('data:', data);

                    this.approvals = JSON.parse(JSON.stringify(data));
                    if (this.approvals.length > 0) {
                        if (selectedstatus == 'Pending for Approval') {
                            this.button = true;
                        }
                        else {
                            this.button = false;
                        }
                        this.showList = true;
                    }
                    console.log('this.noapprovaldata', this.noapprovaldata);
                    console.log('approvals:', this.approvals);
                }
                else {
                    this.showList = false;
                }
            })
            .catch((error) => {
                this.showList = false;
                this.showToast('Error', error.body.message, 'error');
                console.error('Error fetching approvals:', error);
            });
        console.log(' this.showList', this.showList);
    }
    handleFilterChange(event) {
        this.selectedStatus = event.target.value;
        this.fetchPendingApprovals(this.selectedStatus);
    }

    async handleRowSelect(event) {

        console.log('event.detail.row', JSON.stringify(event.currentTarget.dataset));
        this.selectedWorkItemId = event.currentTarget.dataset.workitemid;
        this.recordId = event.currentTarget.dataset.Id;
        this.dest = event.currentTarget.dataset.destination;
        this.purposevisit = event.currentTarget.dataset.purposeofvisit;
        this.billcus = event.currentTarget.dataset.billedtocustomer;
        this.cus = event.currentTarget.dataset.customer;
        this.datedep = event.currentTarget.dataset.dateofdeparture;
        this.datere = event.currentTarget.dataset.dateofreturn;
        this.modetr = event.currentTarget.dataset.modeoftransport;
        this.traveltype1 = event.currentTarget.dataset.traveltype;

        this.dep = event.currentTarget.dataset.department;
        this.des = event.currentTarget.dataset.descripton;
        this.curr = event.currentTarget.dataset.currency;
        this.reqamo = event.currentTarget.dataset.requestedamount;
        this.existra = event.currentTarget.dataset.existindtravelcard;
        this.card = event.currentTarget.dataset.cardno;
        this.empname = event.currentTarget.dataset.employeeName;

        //this.billsdata(this.recordId);
        if (this.recordId != null) {
            console.log('insidebillsdata');
            try {
                const result = await getbillsdata({ recordId: this.recordId });
                this.itemList = result;

                console.log('this.itemList', JSON.stringify(this.itemList));
                if (this.itemList.length == 0) {

                    this.billsdata = false;
                }
                else {
                    this.billsdata = true;
                }
                this.error = undefined;
            }
            catch (error) {
                this.error = error;
                console.log('this.error', this.error);
                this.itemList = [];

            }

            this.showRecord = true;
            this.showList = false;

        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    closeDetail(e) {
        this.selectedRow = null;
        this.showRecord = false;
        this.showList = true;
    }
    connectedCallback() {
        console.log('hello');
        this.fetchPendingApprovals(this.selectedStatus);
    }
}