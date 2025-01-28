import { LightningElement } from 'lwc';
import getPendingApprovals from '@salesforce/apex/Expenseclaimclass.getPendingApprovals';
import getbillsdata from '@salesforce/apex/Expenseclaimclass.getbillsdata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MyTeamExpenseclaimview extends LightningElement {
selectedStatus='Pending for Approval';
approvals = [];
button;
showList=false;
    selectedWorkItemId;
    recordId;
    expdate;
    empname;
    curre;
    empcomments;
    depatment;
    tbillamount;
    billsdata;
    fetchPendingApprovals(selectedstatus) {
        getPendingApprovals({ status:selectedstatus  })
            .then((data) => {
              
                if(data)
                {
                console.log('data:', data);
               
                this.approvals = JSON.parse(JSON.stringify(data));
                console.log('this.approvals.length',this.approvals.length);
                 if( this.approvals.length > 0){
                    if(selectedstatus=='Pending for Approval')
                    {
                        this.button=true;
                    }
                    else{
                        this.button=false;
                    }
                 this.showList=true;
                 }
                 else{
                    this.showList=false;
                    console.log( this.showList);
                }
                 console.log('this.noapprovaldata',  this.noapprovaldata);
                console.log('approvals:', this.approvals);
                }
                
            })
            .catch((error) => {
                 this.showList=false;
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
       console.log('  this.expdate');
        console.log('event.detail.row', JSON.stringify(event.currentTarget.dataset));
        this.selectedWorkItemId =event.currentTarget.dataset.workitemid;
        this.recordId = event.currentTarget.dataset.id;
            this.expdate = event.currentTarget.dataset.expdate;
            console.log('  this.expdate', this.expdate);
            this.categry = event.currentTarget.dataset.category;
            console.log('  this.expdate', this.categry);
            this.empname = event.currentTarget.dataset.Employee_Name;
            this.curre = event.currentTarget.dataset.curr;
            this.empcomments = event.currentTarget.dataset.comments;
            this.depatment = event.currentTarget.dataset.department;
            this.tbillamount = event.currentTarget.dataset.billamount;
               
             //this.billsdata(this.recordId);
             if (this.recordId != null) {
            console.log('insidebillsdata');
            try{
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