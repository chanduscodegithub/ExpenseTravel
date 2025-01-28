import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTimeSheetApproval from '@salesforce/apex/ListViewLwcClass.getTimeSheetApproval';
import getRecentlyViewedTSA from '@salesforce/apex/ListViewLwcClass.getRecentlyViewedTSA';
import minutes from '@salesforce/apex/ListViewLwcClass.getTimeSinceLastUpdate';
import getListViews from '@salesforce/apex/ListViewLwcClass.getListViews';
import getTimeSheetActivity from '@salesforce/apex/ListViewLwcClass.getTimeSheetActivity';
import getTSApprovalFile from '@salesforce/apex/ListViewLwcClass.getTSApprovalFile';
import deleteAttachment from '@salesforce/apex/ListViewLwcClass.deleteAttachment';
import approvalStep from '@salesforce/apex/ListViewLwcClass.approvalStep';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import { loadStyle } from 'lightning/platformResourceLoader';
import listViewCSS  from '@salesforce/resourceUrl/listViewCSS';

export default class ListView extends NavigationMixin(LightningElement) {

    @track isModalOpen = false;
    @track timeapprovalid;
    @track timeapproval = [];
    @track approvalStatus; 
    @track sortedDirection = 'desc';
    @track empname;
    isDisabled;
    isLoading = true;
    //ExistingTSData
    existingTTcontinuation;
    spinnerFlag = true;
    showApprovalBox = false;
   
    @api index;

    records;
    sortedColumn;
    
    @track nameUpBool;
    @track nameDWBool = true;
    @track weekUpBool;
    @track weekDWBool;
    @track empUpBool;
    @track empDWBool;
    @track statusUpBool;
    @track statusDWBool;
    @track custEnUpBool;
    @track custEnDWBool;
    @track hoursUpBool;
    @track hoursDWBool;
    @track approUpBool;
    @track approDWBool;
    @track hoveredColumn = null;
    @track hovered = null;
   @track colName = 'Name';

    nameDirection = 'desc';
    weekDirection = 'desc';
    empDirection = 'desc';
    statusDirection = 'desc';
    custDirection = 'desc';
    hoursDirection = 'desc';
    approvalDirection = 'desc';

   
    approId;

       //Review Attachment
  reviewDisabled;
  revatt;
  timesheetId;
  fileContentDocumentId;
  fileTitle;
  showCheckBox = false;
  checkBoxVal =false;

   
    //Hover 
    handleHoverOut() {

        if(this.colName!= this.hoveredColumn){
        switch (this.hoveredColumn) {
            case 'Name':
                this.nameUpBool = false;
                this.nameDWBool = false;
                break;
            case 'Week_Start_Date__c':
                this.weekUpBool = false;
                this.weekDWBool = false;
                break;
            case 'Employee__r.Name':
                this.empUpBool = false;
                this.empDWBool = false;
                break;
            case 'Approval_Status__c':
                this.statusUpBool = false;
                this.statusDWBool = false;
                break;
            case 'Customer_Engagement__r.Name':
               this.custEnUpBool = false;
                this.custEnDWBool = false;
                break;
            case 'Total_Hours__c':
                this.hoursUpBool= false;
                this.hoursDWBool = false;
                break;
            case 'Approver__r.Name':
                this.approUpBool = false;
                this.approDWBool = false;
                break;
            default:
                break;
        }
    }
        this.hoveredColumn = null; // Reset the hovered column
    }
    
    handleHoverIn(event) {
        this.hovered = event.currentTarget.dataset;
        this.hoveredColumn = this.hovered.id;
    
        if (this.hoveredColumn === 'Name') {
            if (this.nameDirection === 'asc') {
                this.nameUpBool = true; 
                this.nameDWBool = false;
            } else {
                this.nameUpBool = false;
                this.nameDWBool = true;
            }
        } else if (this.hoveredColumn === 'Week_Start_Date__c') {
            if (this.weekDirection === 'asc') {
                this.weekUpBool = true;
                this.weekDWBool = false;
            } else {
                this.weekUpBool = false;
                this.weekDWBool = true;
            }

        }else if(this.hoveredColumn == 'Employee__r.Name'){
            if (this.empDirection === 'asc') {
                this.empUpBool = true;
                this.empDWBool = false;
            } else {
                this.empUpBool = false;
                this.empDWBool = true;
            }

           

        }else if(this.hoveredColumn == 'Approval_Status__c'){
            if (this.statusDirection === 'asc') {
                this.statusUpBool = true;
                this.statusDWBool = false;
            } else {
                this.statusUpBool = false;
                this.statusDWBool = true;
            }


        }else if(this.hoveredColumn == 'Customer_Engagement__r.Name'){
            if (this.custDirection === 'asc') {
               this.custEnUpBool = true;
               this.custEnDWBool= false;
            } else {
                this.custEnUpBool= false;
                this.custEnDWBool = true;
            }


        }else if(this.hoveredColumn == 'Total_Hours__c'){
            if (this.hoursDirection === 'asc') {
                this.hoursUpBool = true;
                this.hoursDWBool = false;
            } else {
                this.hoursUpBool= false;
                this.hoursDWBool= true;
            }


        }else if(this.hoveredColumn == 'Approver__r.Name'){
            if (this.approvalDirection === 'asc') {
                this.approUpBool = true;
                this.approDWBool = false;
            } else {
                this.approUpBool = false;
                this.approDWBool = true;
            }

        }

      }

      
    //Sort By Option
    sortRecs(event) {
    this.isLoading = true;
    this.nameUpBool = false;
    this.nameDWBool = false;
    this.weekUpBool = false;
    this.weekDWBool = false;
    this.empUpBool = false;
    this.empDWBool = false;
    this.statusUpBool = false;
    this.statusDWBool = false;
    this.custEnUpBool = false;
    this.custEnDWBool = false;
    this.hoursUpBool = false;
    this.hoursDWBool = false;
    this.approUpBool = false;
    this.approDWBool = false;


    
     
 this.colName =  event.currentTarget.dataset.id;
     
        console.log('Direction>>'+this.sortedDirection)

        if (this.colName){
            this.sortedDirection = ( this.sortedDirection === 'asc' ? 'desc' : 'asc' );
            if(this.colName === 'Name'){
                this.nameDirection = this.sortedDirection;
            

            }else if(this.colName === 'Week_Start_Date__c'){
                this.weekDirection = this.sortedDirection;
                console.log("Weel Di>>> "+this.weekDirection);

            }else if(this.colName === 'Employee__r.Name'){

                this.empDirection = this.sortedDirection;

            }else if(this.colName === 'Approval_Status__c'){
                this.statusDirection = this.sortedDirection;

            }else if(this.colName === 'Customer_Engagement__r.Name'){
                this.custDirection = this.sortedDirection;

            }else if(this.colName === 'Total_Hours__c'){
                this.hoursDirection = this.sortedDirection;

            }else if(this.colName === 'Approver__r.Name'){
                this.approvalDirection = this.sortedDirection;
            }
        }
        else
            this.sortedDirection = 'asc';

        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        if (this.colName )
            this.sortedColumn = this.colName;
        else
            this.colName = this.sortedColumn;

        switch ( this.colName ) {

            case "Name":
            console.log("colName>>"+this.colName);
            if ( this.sortedDirection == 'asc' )
                this.nameUpBool = true;
            else
                this.nameDWBool = true;
            
            break;

            case "Week_Start_Date__c":
            console.log("colName>>"+this.colName);
            if ( this.sortedDirection == 'asc' )
                this.weekUpBool = true;
            else
                this.weekDWBool = true;
            
            break;

            case "Employee__r.Name":
            console.log("colName>>"+this.colName);
            if ( this.sortedDirection == 'asc' )
                this.empUpBool= true;
            else
                this.empDWBool = true;
            
            break;

            case "Approval_Status__c":
            console.log("colName>>"+this.colName);
            if ( this.sortedDirection == 'asc' )
                this.statusUpBool = true;
            else
                this.statusDWBool = true;
            
            break;

            case "Customer_Engagement__r.Name":
                console.log("colName>>"+this.colName);
            if ( this.sortedDirection == 'asc' )
                this.custEnUpBool = true;
            else
                this.custEnDWBool = true;
            
            break;

            case "Total_Hours__c":
                console.log("colName>>"+this.colName);
            if ( this.sortedDirection == 'asc' )
                this.hoursUpBool = true;
            else
                this.hoursDWBool = true;
            
            break;

            case "Approver__r.Name":
                console.log("colName>>"+this.colName);
                if ( this.sortedDirection == 'asc' )
                    this.approUpBool = true;
                else
                    this.approDWBool = true;
                
                break;

        }

       console.log("Selected Value "+this.selectedValue);
       if(this.selectedValue == "recently-viewed"){
        getRecentlyViewedTSA({fieldName: this.colName, sortDirection: this.sortedDirection})
        .then(result => {
         this.isLoading = false; 
         let index = 0;
         this.approvals = result;
         this.approvals = this.approvals.map(approval => {
             index += 1;
             return {
                 ...approval,
                 url: '/CRMITCommunity/s/timesheet-approval/'+approval.Id,
             sno: index,
             eurl: '/CRMITCommunity/s/employee/'+approval.Employee__r.Id,
             turl: '/CRMITCommunity/s/team-timesheet/'+approval.Timesheet__r.Id,
             aurl: '/CRMITCommunity/s/detail/'+approval.Approver__r.Id,
             ceurl: '/CRMITCommunity/s/project/'+approval.Customer_Engagement__r.Id
             };
         });
         this.totalApprovals = this.approvals.length;
         minutes()
             .then(result => {
                 this.minutesSinceLastUpdate = result;
             })
             .catch(error => {
                 console.error(error);
             });
       
     })
     .catch(error => {
         console.error(error);
     });
 
      

       }
       else{
        getTimeSheetApproval({ objType: 'Timesheet_Approval__c', listView: this.selectedValue, fieldName: this.colName, sortDirection: this.sortedDirection })
        .then(result => {
            this.isLoading = false; 
            let index = 0;
            this.approvals = result;
            this.approvals = this.approvals.map(approval => {
                index += 1;
                return {
                    ...approval,
                    url: '/CRMITCommunity/s/timesheet-approval/'+approval.Id,
                sno: index,
                eurl: '/CRMITCommunity/s/employee/'+approval.Employee__r.Id,
                turl: '/CRMITCommunity/s/team-timesheet/'+approval.Timesheet__r.Id,
                aurl: '/CRMITCommunity/s/detail/'+approval.Approver__r.Id,
                ceurl: '/CRMITCommunity/s/project/'+approval.Customer_Engagement__r.Id
                };
            });
            this.totalApprovals = this.approvals.length;
            minutes()
                .then(result => {
                    this.minutesSinceLastUpdate = result;
                })
                .catch(error => {
                    console.error(error);
                });
                this.error = undefined;
        })
        .catch(error => {
            console.error(error);
            this.error = error;
            this.initialRecords = undefined;
            this.records = undefined;
        });
        
    }

    }





    get shouldDisplay() {
        return this.index <= 0;
    }

    
        

    openModal(event) {
      this.isModalOpen = true;
      this.timeapprovalid = event.target.dataset.recordid;
   
      this.approId = event.target.dataset.app;
      
      getTimeSheetActivity({approvalId: this.timeapprovalid })
      .then(result => {
       console.log("Result",JSON.stringify(result));
        this.timeapproval = result;
        this.isDisabled = true; //Approve and Reject is disabled
        this.reviewDisabled = true; //ReviewAttachment button is disabled
        this.approvalStatus = result[0].Timesheet_Approval__r.Approval_Status__c;
        console.log("Status",this.approvalStatus);
        this.loadFileContentDocumentId();
      
        for (let i = 0; i < result.length; i++) {
            this.empname = result[i].Employee_Name__r.Name;
            console.log("empname"+ result[i].Employee_Name__r.Name);
          
          }
        
        
      }).catch(error => {
        console.error('Error', error);
    });
      
      

     
    }

  
    

    closeModal() {
      this.isModalOpen = false;
    }
  
    @track approvals = [];
    @track minutesSinceLastUpdate;
    @track isResizing = false;
    @track totalApprovals = 0;
   
    minWidth;
    maxWidth;
    col;
    table;
    x;
    width;
    @api approval; // Timesheet Approval record
    @track selectedValue = 'Pending_for_Approval';
    @track options = [];

    loadListViews() {
        getListViews({ objectApiName: 'Timesheet_Approval__c' })
            .then(result => {
                if (result && result.length > 0) {
    this.options = [
        ...result.map(listView => ({
            label: listView.Name,
            value: listView.DeveloperName
        })),
        { label: 'Recently Viewed', value: 'recently-viewed' } // Add Recently Viewed option
    ];
} else {
    this.options = [{ label: 'Recently Viewed', value: 'recently-viewed' }]; // If no list views, only show Recently Viewed
}

            })
            .catch(error => {
                console.error('Error retrieving list views:', error);
            });
    }

    handleChange(event) {
        this.isLoading = true;
        this.nameUpBool = false;
        this.nameDWBool = true;
        this.weekUpBool = false;
        this.weekDWBool = false;
        this.empUpBool = false;
        this.empDWBool = false;
        this.statusUpBool = false;
        this.statusDWBool = false;
        this.custEnUpBool = false;
        this.custEnDWBool = false;
        this.hoursUpBool = false;
        this.hoursDWBool = false;
        this.approUpBool = false;
        this.approDWBool = false;
        this.sortedDirection = 'desc';
        this.colName = 'Name'

        this.selectedValue = event.detail.value;
        if (this.selectedValue === 'recently-viewed') {
            console.log(this.selectedValue);
            this.getRecentlyViewedRecords();
    
        } else {
            // Handle other list views
            console.log(this.selectedValue);
        getTimeSheetApproval({ objType:'Timesheet_Approval__c', listView: this.selectedValue, fieldName:'Name',  sortDirection:'DESC'  })
        .then(result => {
            this.isLoading = false; 
            let index = 0;
            this.approvals = result;
            this.approvals = this.approvals.map(approval => {
                index += 1;
                return {
                    ...approval,
                    url: '/CRMITCommunity/s/timesheet-approval/'+approval.Id,
                sno: index,
                eurl: '/CRMITCommunity/s/employee/'+approval.Employee__r.Id,
                turl: '/CRMITCommunity/s/team-timesheet/'+approval.Timesheet__r.Id,
                aurl: '/CRMITCommunity/s/detail/'+approval.Approver__r.Id,
                ceurl: '/CRMITCommunity/s/project/'+approval.Customer_Engagement__r.Id
                };
            });
            this.totalApprovals = this.approvals.length;
            minutes()
                .then(result => {
                    this.minutesSinceLastUpdate = result;
                })
                .catch(error => {
                    console.error(error);
                });
               
          
        })
        .catch(error => {
            console.error(error);
           
        });
    }
        
    }

    getRecentlyViewedRecords() {
       getRecentlyViewedTSA({fieldName: 'LastModifiedDate', sortDirection:'DESC'})
       .then(result => {
        this.isLoading = false; 
        let index = 0;
        this.approvals = result;
        this.approvals = this.approvals.map(approval => {
            index += 1;
            return {
                ...approval,
                url: '/CRMITCommunity/s/timesheet-approval/'+approval.Id,
            sno: index,
            eurl: '/CRMITCommunity/s/employee/'+approval.Employee__r.Id,
            turl: '/CRMITCommunity/s/team-timesheet/'+approval.Timesheet__r.Id,
            aurl: '/CRMITCommunity/s/detail/'+approval.Approver__r.Id,
            ceurl: '/CRMITCommunity/s/project/'+approval.Customer_Engagement__r.Id
            };
        });
        this.totalApprovals = this.approvals.length;
        minutes()
            .then(result => {
                this.minutesSinceLastUpdate = result;
            })
            .catch(error => {
                console.error(error);
            });
      
    })
    .catch(error => {
        console.error(error);
    });

    }
    
        
    
    connectedCallback() {
        this.isLoading = true; 
        setTimeout(() => {
            this.fetchData();
        });
        console.log("Connected Callback",this.selectedValue);
        this.loadListViews();
        if (this.selectedValue === 'recently-viewed') {
            
            this.getRecentlyViewedRecords();
        } else {
        getTimeSheetApproval({ objType:'Timesheet_Approval__c', listView: this.selectedValue, fieldName:'Name',  sortDirection:'DESC'   })
    .then(result => {
        this.isLoading = false; 
        
        let index = 0;
        this.approvals = result;
        this.approvals = this.approvals.map(approval => {
            index += 1;
            return {
                ...approval,
                url: '/CRMITCommunity/s/timesheet-approval/'+approval.Id,
                sno: index,
                eurl: '/CRMITCommunity/s/employee/'+approval.Employee__r.Id,
                turl: '/CRMITCommunity/s/team-timesheet/'+approval.Timesheet__r.Id,
                aurl: '/CRMITCommunity/s/detail/'+approval.Approver__r.Id,
                ceurl: '/CRMITCommunity/s/project/'+approval.Customer_Engagement__r.Id
            };
        });
        
        this.totalApprovals = this.approvals.length;
        minutes()
            .then(result => {
                this.minutesSinceLastUpdate = result;
            })
            .catch(error => {
                console.error(error);
            });
            
    })
    .catch(error => {
        console.error(error);
        
    });

        }
    }

 

    renderedCallback() {
         Promise.all([
            loadStyle(this,listViewCSS)
        ]).then(() => {
            console.log('Files loaded');

        }).catch(error => {
            console.log(error.body.message);
        });

        if (this.isResizing && this.col) {
            document.body.style.cursor = 'col-resize';
            this.width = Math.max(this.minWidth, Math.min(this.maxWidth, this.col.offsetWidth + this.x - this.table.offsetLeft));
            this.col.style.width = this.width + 'px';
        } else {
            document.body.style.cursor = '';
        }
    }
    async handleSearchKeyChange(event) {
        const searchTerm = event.detail.value;
        const searchBox = event.target;
        searchBox.isLoading = true;
        
        const table = this.template.querySelector('table');
        const rows = table.getElementsByTagName('tr');
        
        if (!searchTerm || searchTerm === '') {
          // Show all rows when search term is empty
          for (let i = 1; i < rows.length; i++) {
            const row = rows[i];
            row.style.display = '';
          }
          this.totalApprovals = this.approvals.length;
        } else {
          const filtered = await this.filterRowsBySearchTerm(rows, searchTerm);
          for (let i = 1; i < rows.length; i++) {
            const row = rows[i];
            if (filtered.includes(row)) {
              row.style.display = '';
            } else {
              row.style.display = 'none';
            }
          }
          this.totalApprovals = filtered.length;
        }
        
        searchBox.isLoading = false;
      }
      
      
      
      
      filterRowsBySearchTerm(rows, term) {
        if (!term || term === '') {
          return [];
        }
        const matcher = new RegExp(term, 'i');
        return Promise.resolve(
          [...rows].filter((row) => {
            let matched = false;
            const cells = row.getElementsByTagName('td');
            for (let i = 0; i < cells.length; i++) {
              const cell = cells[i];
              if (matcher.test(cell.innerText)) {
                matched = true;
                break;
              }
            }
            return matched;
          })
        );
      }
      
      
    closeApprovalBox() {
        this.isModalOpen = true;
        this.showApprovalBox = false;
        this.approvalBoxLabel = '';
        this.approvalDescription = '';
        this.approvalBoxHeading = 'Comments';
        this.approvalBoxPlaceholder = 'Comments..'
    }
    handleRejection() {
        this.isModalOpen = false;
        this.approvalBoxHeading = 'Reason for Rejection';
        this.approvalBoxPlaceholder = 'Reason for Rejection here....';
        this.approvalBoxLabel = 'Reject';
        this.showApprovalBox = true;
       
        if(this.reviewDisabled == false){
          
            this.showCheckBox = true;
           

        }
    }
    handleApproval() {
        this.isModalOpen = false;
        this.showCheckBox = false;
        this.approvalBoxLabel = 'Approve';
        this.approvalBoxHeading = 'Approval Comment';
        this.approvalBoxPlaceholder = 'Comments..';
        this.showApprovalBox = true;
        this.approvalDescription = 'Approved';
    }
    handleDescriptionInput(event) {
        this.approvalDescription = event.target.value;
    }
    submitApproval() {
        if (this.approvalDescription == '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Comments are required!',
                    variant: 'error'
                })

            );
            return false;
        }
        this.isLoading = true;
        console.log("Record ID",this.timeapprovalid);
        approvalStep({ reqAction: this.approvalBoxLabel, reqComments: this.approvalDescription, recordId: this.timeapprovalid})
            .then(data => {
                
                if (this.approvalBoxLabel == 'Approve') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Approved!!',
                            message: 'Timesheet approved successfully!',
                            variant: 'success'
                        })
                    );
                } else if (this.approvalBoxLabel == 'Reject') {
                   
                    if(this.checkBoxVal == true){
                        // alert('deleteAttachment');
                         deleteAttachment({contentDocId: this.fileContentDocumentId}).then(() => {
                             console.log('File Deleted');
                         }).catch(() =>{
                             console.error('Error, File not deleted')
                         });
                     }
 
                     this.dispatchEvent(
                         new ShowToastEvent({
                             title: 'Rejected!!',
                             message: 'Timesheet rejected successfully!',
                             variant: 'success'
                         })
                     );
                }
                this.isLoading = true;

                let backtoListTimesheet = '/CRMITCommunity/s/recordlist/Timesheet_Approval__c/00B1K00000AN3gwUAD';
              
                setTimeout(() => {
                    window.location.href = backtoListTimesheet;
                }, 1000)
            })
            .catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                        variant: 'error'
                    })
                );
                this.spinnerFlag = false;
            })
    }

    fetchData() {
        this.table = this.template.querySelector('.slds-table');
        if (this.table) {
            const resizers = this.table.querySelectorAll('.slds-resizable__handle');
            resizers.forEach((resizer) => {
                resizer.addEventListener('mousedown', this.initResize.bind(this));
            });
        } else {
            setTimeout(() => {
                this.fetchData();
            }, 50);
        }
    }
    

    initResize(e) {
        this.col = e.target.closest('th');
        this.x = e.clientX;
        this.width = this.col.offsetWidth;
        this.minWidth = parseInt(window.getComputedStyle(this.col).minWidth) || 0;
        this.maxWidth = parseInt(window.getComputedStyle(this.table).width) || 0;
        this.isResizing = true;
        document.addEventListener('mousemove', this.doResize.bind(this));
        document.addEventListener('mouseup', this.stopResize.bind(this));
    }

    doResize(e) {
        if (this.isResizing && this.col) {
            const dx = e.clientX - this.x;
            if (Math.abs(dx) >= 5) {
                this.width = Math.max(this.minWidth, Math.min(this.maxWidth, this.width + dx));
                this.col.style.width = this.width + 'px';
                this.x = e.clientX;
            }
        }
    }
    

    stopResize() {
        this.isResizing = false;
        document.removeEventListener('mousemove', this.doResize);
        document.removeEventListener('mouseup', this.stopResize);
    }


   //Review Attachment Code


   handleReviewAttachment(){
    console.log('Disabled button check'+this.approvalStatus);

        //Enable Approve and Reject button
        
        this.isDisabled = false;
    
    let baseUrl = window.location.origin;
    let url = baseUrl+'/CRMITCommunity/s/relatedlist/'+this.timeapprovalid+'/CombinedAttachments';
    window.open(url,'_blank');

    

}  


loadFileContentDocumentId() {
console.log('In LoadFileContentDocumentId this.timeapprovalid', this.timeapprovalid);

getTSApprovalFile({ tsapproId: this.timeapprovalid})
    .then(result => {
        //when file is there
        if (result) {
            this.fileContentDocumentId = Object.keys(result)[0];
            this.fileTitle = Object.values(result)[0];
            console.log("lStatus",this.approvalStatus);
            console.log("lfileContentDocumentId",JSON.stringify(this.fileContentDocumentId ));
            //When file is there
            //Enable Review Attachment button when approval Status is "Submitted" AND USER_ID = Approver
            if(this.fileContentDocumentId != null && this.approvalStatus == 'Submitted' &&  USER_ID == this.approId )//The file is visible to the employee and the manager(not checking USER_ID == this.approId)
            {
                
                this.reviewDisabled =false;
                this.isDisabled = true;//Approve and Reject is disabled until RA button is clicked.
                
                
            }

            //When file is not there
            //Disable Review Attachment button
            else{
                //Based on Approval Status Enable Approve and Reject for the Approver
                if(this.approvalStatus == 'Submitted' &&  USER_ID == this.approId ){

                    this.isDisabled = false;
                
                }
            }


            
     }


    })
    .catch(error => {
        console.error('Error loading file:', error);
    });
}


handleCheckbox(event){
this.checkBoxVal = event.target.checked;
//alert(this.checkBoxVal);

}

    
    
    
    

}