import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getRatingPicklistValues from '@salesforce/apex/PMS_Controller.getPicklistValues';
import getApexData from '@salesforce/apex/PMS_Controller.getData';
import updatePRI from '@salesforce/apex/PMS_Controller.updatePRI';
import updatereviewer from '@salesforce/apex/PMS_Controller.updatereviewer';
import updateDelegateManagerCommenets from '@salesforce/apex/PMS_Controller.updateDelegateManagerCommenets';
import updateReject from '@salesforce/apex/PMS_Controller.updateReject';
import getPRData from '@salesforce/apex/PMS_Controller.getPRData';
import Id from '@salesforce/user/Id';

import { CurrentPageReference } from 'lightning/navigation';
import  getyearRatingPicklistValues from '@salesforce/apex/PMS_Controller.getyearPicklistValues';

const MANAGER_RATING = 'Manager Rating For ';
const DELEGATE_RATING = 'Project Leader Rating For ';

export default class PMS_Rating extends NavigationMixin(LightningElement) {
    selectedQuarter = ''; selectedYear = '';
    entryPopUp = true;
    displayrating;
    reviewrating=0;
    annualrating=true;
    currentUserId = Id;
    get QPRoptions() {
        return [
            { label: 'QPR-I (Jan-Feb-Mar)', value: 'QPR-I' },
            { label: 'QPR-II (Apr-MAY-JUN)', value: 'QPR-II' },
            { label: 'QPR-III (JUL-AUG-SEP)', value: 'QPR-III' },
            { label: 'QPR-IV (OCT-NOV-DEC)/Annual Review', value: 'Annual Cycle' },
        ];
    }
    get yearOptions() {
        return [
            //{ label: '2021', value: '2021' },
            //{ label: '2022', value: '2022' },
            { label: '2023', value: '2023' },
        ];
    }
    disablereviewer;
    managercomment1;
    managercomment2;
    reviewrating;
    displayCareerPlan;
    disableProceedButton=false;
    feedback1;
    reviewratings;
    
    feedback2;
    RECID;
    isReviewer=false;
    index;
    isSpinner = true;
    showPopUpChild = true;
    ismanageropen = false;
    @track totalKRAScore;
    title = MANAGER_RATING;
    isManager; isDeleManager;
    @track pmsData = [];
    @track priToUpdate = {};
    krasWrapperData = [];
    deleMgname1;
    deleMgname2;
    deleMgComments;
    @track refreshData = [];
    isEditable = false;
    tab;
    isreviewerdone=true;
    ismanagercplted;
    prstatus;




    isManagerSubmitted = false;
    disableButton = false;
    managerEmpFlage = false;


    empLocation = '';
    overallManagerComments = '';
    empOverallRating;
    annualfinalrating;

@track data;
    rejReason;
    @track overallQuaterData;
    reviewercomments;

    disableSaveAsDraftButton = false; isReadonly = false; editRating = false; flageTocr = true; kpiEdit = false; fromEMP = false; finalAlert = false; disableRejectButton = false;

    //pr-id={ prId } rec - id={ loggedInEmpId } mg - id={ MgId } dele - mg - id={ deleMgId } dele - mg - id2={ deleMgId2 } emp - id={ EMPID } appraisal - cycle - id={ wrapperData.appraisalCycleId } current - cycle={ wrapperData.currentQuarter }
    @api recId; @api mgId; @api deleMgId; @api deleMgId2; @api empId; @api prId; @api currentCycle; @api appraisalCycleId; @api from; @api activetabContent; @api currentYear; @api isDisable;

    @api objectApiName;
    @api fieldApiName;
    fieldLabel;
    selectedValue;
    picklistValues = [];
    getyearOptions=[];
    ratingOptions=[];

     @wire(getRatingPicklistValues, {})
    // Define a wired property for rating picklist values
    wiredRatingPicklistValues({ error, data }) {
        // If data is returned from the wire function
        if (data) {
            // Map the data to an array of options
            this.ratingOptions = data.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }
        // If there is an error
        else if (error) {
            // Log the error to the console
            console.error(error);
        }
    }
    @wire(getyearRatingPicklistValues, {})
    // Define a wired property for rating picklist values
    wiredYearRatingPicklistValues({ error, data }) {
        // If data is returned from the wire function
      if(data) {
    // console.log('this.yearOptionsdata', data);
    let currentDate = new Date();
    let currentYear = currentDate.getFullYear();
    // Map the data to an array of options
    this.getyearOptions = data.map(option => {
        if (option.label <= currentYear) {
            return {
                label: option.label,
                value: option.value
            };
        }
        return null; // Returning null for options that don't meet the condition
    }).filter(option => option !== null); // Filtering out null values
    // console.log('this.yearOptions', this.getyearOptions);
}
        // If there is an error
        else if (error) {
            // Log the error to the console
            console.error(error);
        }
    }
    connectedCallback() {
     //console.log('t',this.empId);
      //console.log('e',this.currentCycle);
     //console.log('recId',this.currentYear);
     /*console.log('recId',this.appraisalCycleId);
     console.log('activetabContent',this.activetabContent);*/
     this.tab=(this.activetabContent=='Project Reportees'?true:false);

    //     this.isDeleManager = (this.deleMgId == this.recId || this.deleMgId2 == this.recId) ? true : false;
    //     this.title = (this.isDeleManager == true ? DELEGATE_RATING : MANAGER_RATING) + this.currentCycle + ' - ' + new Date().getFullYear();;
    //     this.fromEMP = this.from == 'EMP' ? true : false;
    //     console.log('~~Title : ', this.title);




    //     //console.log('~~recId cb ', this.recId);


     }
    @wire(CurrentPageReference)
    getPageReferenceParameters(CurrentPageReference) {
        //console.log('eId',CurrentPageReference.state.c__eId);
       
         //console.log('this.empId',this.empId);
        // console.log('~~currentPageReference.state.c__prId : ', CurrentPageReference.state.c__prId);
        // console.log('~~currentPageReference.state.c__ccId : ', CurrentPageReference.state.c__ccId);
        // console.log('~~currentPageReference.state.c__acId : ', CurrentPageReference.state.c__acId);
        if (this.from != 'EMP' && this.from != 'preportee' )
        {
            this.empId=CurrentPageReference.state.c__eId;
            this.prId = (CurrentPageReference.state.c__prId != null || CurrentPageReference.state.c__prId != undefined) ? CurrentPageReference.state.c__prId : '';
            getPRData({ prName: this.prId, userId: this.currentUserId })
                .then(result => {
                    if (result !== null) {
                        this.prId = result;
                    } else {
                        this.showToast('You Dont Have Access To Record', 'You Dont Have Access To Record', 'error');
                        return ;
                    }

                }).catch(error => {
                    console.error('error:::' + error);
                });
        
        }
        else if (this.from == 'view')
               {
             this.entryPopUp = true;
             this.ismanageropen = false;
    }
       else if (this.from == 'EMP' ||this.from == 'preportee')
            {
            
            //console.log('iam insde');
             this.entryPopUp = false;
             this.ismanageropen = true;
             //console.log('this.entryPopUp ',this.entryPopUp , this.ismanageropen );
        ////this.entryPopUp = false;
       // this.ismanageropen = true;
            }
           

        // this.currentCycle = (CurrentPageReference.state.c__ccId != null || CurrentPageReference.state.c__ccId != undefined) ? CurrentPageReference.state.c__ccId : '';
        // this.appraisalCycleId = (CurrentPageReference.state.c__acId != null || CurrentPageReference.state.c__acId != undefined) ? CurrentPageReference.state.c__acId : '';
    }



    noKPIsFlage = false;
    @wire(getApexData, { currentCycle: '$currentCycle', selectedyear:'$currentYear',emplId:'$empId' }) getAllData(result) {
         //console.log('~~Res OUTPUT : ', result.data);
     
      this.refreshData = result;
        this.pmsData = [];
        this.quaterdata=[];
        console.log('~~Res OUTPUT : ', result.data);
        //console.log('this.currentCycle',this.currentCycle);
        //console.log('this.selectedQuarter',this.selectedQuarter);
         //console.log('result.data.Q1selfRating',result.data.Q1selfRating);
       
        if (result.data) {

            //console.log('result.data.Q1selfRating',result.data.Q1selfRating);
           
             this.fromEMP = this.from == 'EMP' ? true : false;
            if((this.currentCycle==='Annual Cycle' && this.selectedQuarter==='Annual Cycle')||(this.currentCycle==='Annual Cycle' &&  this.fromEMP==true))
            {
           if (this.currentCycle==='Annual Cycle')
           {
           this.annualrating=false;
           }
           //console.log(' this.annualrating', result.data.reviewerRating,result.data.finalRating);
        
           this.reviewrating=result.data.reviewerRating;
           this.reviewratings= this.reviewrating;
           this.annualfinalrating=result.data.finalRating;
       // console.log(' this.annualfinalrating', this.annualfinalrating);
           //this.overallQuaterData=JSON.stringify(this.quaterdata);
           }
           this.quaterdata.push({quater:'QPR-I',srating:((result.data.Q1selfRating.toFixed(1).toString())!=null?result.data.Q1selfRating.toFixed(1).toString():'-'),mrating:((result.data.Q1manaRating.toString())!=null?result.data.Q1manaRating.toFixed(1).toString():'-')});
           this.quaterdata.push({quater:'QPR-II',srating:((result.data.Q2selfRating.toFixed(1).toString())!=null?result.data.Q2selfRating.toFixed(1).toString():'-'),mrating:((result.data.Q2manaRating.toString())!=null?result.data.Q2manaRating.toFixed(1).toString():'-')});
           this.quaterdata.push({quater:'QPR-III',srating:((result.data.Q3selfRating.toFixed(1).toString())!=null?result.data.Q3selfRating.toFixed(1).toString():'-'),mrating:((result.data.Q3manaRating.toString())!=null?result.data.Q3manaRating.toFixed(1).toString():'-')});
           this.quaterdata.push({quater:'QPR-IV/Annual Review',srating:((result.data.Q4selfRating.toFixed(1).toString())!=null?result.data.Q4selfRating.toFixed(1).toString():'-'),mrating:((result.data.Q4manaRating.toString())!=null?result.data.Q4manaRating.toFixed(1).toString():'-')});
         // console.log('this.quaterdata',this.quaterdata);
           this.isReviewer= result.data.isReviewer;
           this.disablereviewer=((result.data.status==='Reviewer Submitted'||this.isReviewer===false ||(result.data.status=='QPR-IV/Annual Review Emp Submitted' && this.isReviewer==true))?true:false);
           //console.log(' this.disablereviewer', this.disablereviewer);
           this.prstatus=result.data.status;
           this.reviewercomments=result.data.reviewercommentsdata;
           //console.log('reviewercomments',  this.reviewercomments);
            this.disableProceedButton=false;
            this.krasWrapperData = result.data;
            //this.empId = result.data.employeeId;
            this.isreviewerdone=((this.currentCycle==='QPR-IV/Annual Review'&& result.data.isReviewer===true)?false:true);
           // console.log('~~employeeId : ', this.empId);
            this.deleMgId = result.data.delegateManagerId;
            this.deleMgId2 = result.data.delegateManager2Id;
            this.recId = result.data.loggedInEmpId;
            this.deleMgname1=(result.data.delegateMg1Name!=null && result.data.delegateMg1Name!=''?result.data.delegateMg1Name:'');
            this.deleMgname2=(result.data.delegateMg2Name!=null && result.data.delegateMg2Name!=''?result.data.delegateMg2Name:'');
            this.feedback1=(result.data.delegateManager1FeedBack!=null && result.data.delegateManager1FeedBack!=''?result.data.delegateManager1FeedBack:'');
            this.feedback2=(result.data.delegateManager2FeedBack!=null && result.data.delegateManager2FeedBack!=''?result.data.delegateManager2FeedBack:'');
            this.managercomment1=(result.data.ManagerComments1!=null && result.data.ManagerComments1!=''?result.data.ManagerComments1:'');
            this.managercomment2=(result.data.ManagerComments2!=null && result.data.ManagerComments2!=''?result.data.ManagerComments2:'');
           // console.log('Reportees',this.feedback1);
            this.isDeleManager = ((this.deleMgId == this.recId || this.deleMgId2 == this.recId)&& this.tab==true) ? true : false;
            this.title = (this.isDeleManager == true ? DELEGATE_RATING : MANAGER_RATING) + this.currentCycle + ' - ' + this.currentYear;
           
            //console.log('~~Title : ',  this.feedback2);
            this.ismanagercplted=this.krasWrapperData.isManagerSubmitted
            this.deleMgComments = (this.deleMgId == this.recId) ? result.data.delegateManager1FeedBack : (this.deleMgId2 == this.recId) ? result.data.delegateManager2FeedBack : '';
            this.isEditable = ((this.deleMgId == this.recId) &&  (this.feedback1!='' ) )? result.data.isDelegateMg1Submitted : ((this.deleMgId2 == this.recId) &&(this.feedback2!='' )) ? result.data.isDelegateMg2Submitted : false;
            //console.log('this.isEditable',this.isEditable);
            this.disableButton = (((this.krasWrapperData.isManagerSubmitted == true || result.data.isEmpSubmitted == false || this.isDisable== true)&& this.isReviewer===false)||(result.data.status==='Reviewer Submitted')||(result.data.currentQuarter!=this.selectedQuarter));
            this.managerEmpFlage = (!(this.krasWrapperData.isManagerSubmitted == true || result.data.isEmpSubmitted == true || this.isDeleManager||result.data.status==='Reviewer Submitted'));
            //console.log('this.managerEmpFlage',this.managerEmpFlage);
            //console.log('currentQuarter',result.data.currentQuarter,this.selectedQuarter);
            this.disableSaveAsDraftButton = (((this.krasWrapperData.isManagerSubmitted || this.isDisable== true) && this.isReviewer===false)||(result.data.status==='Reviewer Submitted')||(result.data.currentQuarter!=this.selectedQuarter));
            this.isReadonly = (this.krasWrapperData.isManagerSubmitted || !result.data.isEmpSubmitted);
            this.editRating = (this.krasWrapperData.isManagerSubmitted && result.data.isEmpSubmitted);
            this.kpiEdit = (this.krasWrapperData.isEmpSubmitted || this.krasWrapperData.isManagerSubmitted||result.data.status=='Reviewer Submitted');
            //console.log('  this.kpiEdit',  this.kpiEdit);
             //console.log('this.krasWrapperData.isEmpSubmitted', this.krasWrapperData.isEmpSubmitted);
              //console.log('this.krasWrapperData.isManagerSubmitted', this.krasWrapperData.isManagerSubmitted);
            this.empOverallRating = this.krasWrapperData.empOverallRating.toFixed(1);
            this.totalKRAScore = (this.krasWrapperData.mngOverallRating != null && this.krasWrapperData.mngOverallRating != '') ? this.krasWrapperData.mngOverallRating.toFixed(1) : '';
            this.overallManagerComments = result.data.mngOverallComments;
            this.disableRejectButton = ((!(this.krasWrapperData.isEmpSubmitted && this.selectedQuarter==this.krasWrapperData.AppraisalQuater))||(result.data.isEmpSubmitted == false));
            this.rejReason = this.krasWrapperData.rejectReason;
           
            //console.log('this.empOverallRating', this.empOverallRating);

            if (Object.keys(result.data.KRAS).length > 0) {
                //console.log('~~Data ', result.data.KRAS);
                let i = 1;
                Object.keys(result.data.KRAS).forEach(element => {
                    //console.log('~~KRA Element ', result.data.KRAS[element][0].Goal_Setting__r.Total_KRA_Weightage__c);
                    //let kraWeightage = result.data.KRAS[element][0].Goal_Setting__r.Weightage__c;
                    let kraWeightage = result.data.KRAS[element][0].Goal_Setting__r.Total_KRA_Weightage__c;
                    let kraDescription =result.data.KRAS[element][0].Goal_Setting__r.Goal_Repository__r.Description__c;


                    let tempKPI = [];

                  //console.log('~~ele ');
                 result.data.KRAS[element].forEach(ele => {


                        //console.log('~~ele ', ele);


                        let weightage = (ele.Weightage__c != null && ele.Weightage__c != '') ? ele.Weightage__c : '';
                        let kpi = ele.KPI__c;
                        let kra = ele.Goal_Setting__r.Goal_Repository__r.Name;
                        let empRating = (ele.Employee_Rating__c != null && ele.Employee_Rating__c != '') ? ele.Employee_Rating__c.toString() : '0';
                        let empComments = (ele.Employee_Comments__c != null && ele.Employee_Comments__c != '') ? ele.Employee_Comments__c : '';
                        let mngRating = (ele.Manager_Rating__c != null && ele.Manager_Rating__c != '') ? ele.Manager_Rating__c.toString() : '0';
                        let mngComments = ele.Manager_comments__c;
                        //tempKPI.push({ 'Id': ele.Id, 'weightage': weightage, 'kpi': kpi, 'kra': kra, 'empRating': empRating, 'empComments': empComments, 'mngRating': mngRating, 'mngComments': mngComments, isKpiEdit: false });
                        //let tempObj = { 'managerRating': mngRating, 'managerComments': mngComments, 'kpi': kpi, 'kpiWeightage': weightage, 'kra': kra };
                        //this.priToUpdate[ele.Id] = tempObj;
                         let gsid=ele.Goal_Setting__c;
                        tempKPI.push({ 'Id': ele.Id, 'weightage': weightage, 'kpi': kpi, 'kra': kra, 'empRating': empRating, 'empComments': empComments, 'mngRating': mngRating, 'mngComments': mngComments, isKpiEdit: false,'gsid':gsid});
                        let tempObj = { 'managerRating': mngRating, 'managerComments': mngComments, 'kpi': kpi, 'kpiWeightage': weightage, 'kra': kra,'gsid':gsid };
                        this.priToUpdate[ele.Id] = tempObj;
                    });




                    this.pmsData.push({ KRA: element, id: i, kraWeightage: kraWeightage, kpiData: tempKPI, kraDescription: kraDescription });
                    i += 1;


                });


                // console.log('~~PMSDATA  ', this.pmsData);


            } else {
                this.noKPIsFlage = true;
            }


            this.isSpinner = false;

            /*console.log('~~currentCycle ', this.currentCycle);
            console.log('~~recId ', this.recId)
            console.log('~~from ', this.from)
            console.log('~~deleMgId ', this.deleMgId)
            console.log('~~deleMgId2 ', this.deleMgId2)
            console.log('~~empId ', this.empId)
            console.log('~~prId ', this.prId)
            console.log('~~appraisalCycleId ', this.appraisalCycleId)*/




        }
         else if (result.error) {
         this.ismanageropen=false;
         this.entryPopUp = true;
            console.log('~~An error has occurred:');
            console.log(result.error);
            this.isSpinner = false;
             this.toastMsg('Error', result.error.body.message, 'Error');
            
           
        }
         else {
             //alert('hi');
             //console.log('year',this.selectedYear,this.selectedQuarter);
            this.ismanageropen=false;
            this.entryPopUp = true;
            this.disableProceedButton=true;
        if(this.selectedQuarter!=undefined && this.selectedQuarter!=''){
            //console.log('this.ismanageropen',this.ismanageropen);
            this.toastMsg('Error', 'You dont have any data for the selected quarter', 'Error')
        }
       
        }


    }


    back() {


        if (this.from == 'EMP') {
            const selectedEvent = new CustomEvent(
                'selfrating',
                { detail: 'cancel' }
            );
            this.dispatchEvent(selectedEvent);


        }
        else {
             this.entryPopUp = true;
            this.dispatchEvent(new CustomEvent('goback',{bubbles: true}));
        }


    }


    reject = false;
    handleReject() {
        this.reject = true;
    }


    handleRejectClose() {
        this.reject = false;
    }


    handleRejectSubmit(event) {
        updateReject({ rejReson: this.rejReason, prId: this.prId }).then((res) => {
            this.reject = false;
            this.showToast('Success', 'You have rejected the rating ', 'Success');
            refreshApex(this.refreshData);
        }).catch((err) => {


            this.reject = false;
            console.log('~~Error~~', err);
            this.showToast('Error', 'Failed to save', 'Error');


        });


    }


    handleChange(event) {
        if (event.target.label == 'Manager Comments') {
            this.priToUpdate[(event.currentTarget.dataset.id)].managerComments = event.target.value;
            this.pmsData[event.currentTarget.dataset.kraindex].kpiData[event.currentTarget.dataset.kpiindex].mngComments = event.target.value;
        }
        else if (event.target.title == 'KPI') {
            this.priToUpdate[(event.currentTarget.dataset.id)].kpi = event.target.value;
            this.priToUpdate[(event.currentTarget.dataset.id)].index = event.currentTarget.dataset.index;
            this.priToUpdate[(event.currentTarget.dataset.id)].gsId = event.currentTarget.dataset.gsid;
        }
        else if (event.target.title == 'Project Leaders Comments') {
            this.deleMgComments = event.target.value;
        }
        else if (event.target.title == 'Manager Comments - Overall Summary') {
            this.overallManagerComments = event.target.value;
        }
        else if (event.target.title == 'KPI Weightage') {
            this.priToUpdate[(event.currentTarget.dataset.id)].index = event.currentTarget.dataset.index;
            this.priToUpdate[(event.currentTarget.dataset.id)].gsId = event.currentTarget.dataset.gsid;
            this.priToUpdate[(event.currentTarget.dataset.id)].kpiWeightage = event.target.value;
            this.pmsData[event.currentTarget.dataset.kraindex].kpiData[event.currentTarget.dataset.kpiindex].weightage = event.target.value;
        }
        else if (event.target.label == 'Reject Reason') {
            this.rejReason = event.target.value;
            //console.log('Onchange  : ', event.target.value);
        }
        else if (event.target.title == 'Manager Rating') {
            const data = event.detail;
            this.priToUpdate[(event.currentTarget.dataset.id)].managerRating = data.rating;
            this.pmsData[event.currentTarget.dataset.kraindex].kpiData[event.currentTarget.dataset.kpiindex].mngRating = data.rating;
        }
        else if(event.target.title=='Reviewer Comments')
        {
            this.reviewercomments=event.target.value;
            //console.log('this.reviewerComments',this.reviewercomments);
        }
         else if(event.target.title=='Reviewer Rating')
        {
           const data = event.detail;
           this.reviewrating=data.rating;
           //console.log('this.reviewrating',this.reviewrating);
        }
    }


    submitFlage = false;
    showPopup = false;
    popUpTitle;
    popUpbodyFlage = false;
    popUpbody; viewFeedBack;
    drafitView = false;
    popUpclass = "slds-modal slds-fade-in-open";
    callDelegate = false;


    updatefalge() {
        this.callDelegate = false;
    }
    handlePopUp(event) {
        this.drafitView = false;
        if (event.target.label == 'Give Feedback') {
            this.showPopup = true;
            this.popUpTitle = 'Enter Your Feedback';


        }
        else if (event.target.label == 'Feedback') {
             //console.log('~~isDelegateManagerSubmitted : ', this.krasWrapperData.delegateManager1FeedBack);
            // console.log('~~viewFeedBack : ', this.viewFeedBack);
            if (this.krasWrapperData.isDelegateManagerSubmitted == true &&(this.krasWrapperData.delegateManager1FeedBack!=null ||this.krasWrapperData.delegateManager2FeedBack!=null)) {
                //console.log('~~Inside viewFeedBack : ', this.viewFeedBack);
                this.viewFeedBack = true;
                this.showPopup = true;
                this.popUpTitle = ' Project Leader Feedback';
            }


            else {
                this.callDelegate = true;
            }




        }
        else if (event.target.label == 'Submit') {
            if(this.currentCycle=='Annual Cycle' && this.isReviewer==true && this.ismanagercplted==true)
            {
                //console.log('~~~123',this.currentCycle,this.isReviewer,this.ismanagercplted);
           
                if((this.reviewrating==null || this.reviewrating=='' || this.reviewrating < 0.5)||(this.reviewercomments==null ||this.reviewercomments==''))
                {
                     this.showToast('Error', 'please enter Reviewer ratings and comments', 'Error');
                }
                else{

                
              updatereviewer({prId:this.prId,status: this.prstatus,rating:this.reviewrating,comments:this.reviewercomments,flag:'true'}).then(result => {
                this.data= result;
              
                  this.disableSaveAsDraftButton=true;
                  this.disableButton=true;
                  let msg='reviewer comments and ratings saved sucessfully';
                  this.showToast('Success', msg, 'success');
                  refreshApex(this.refreshData);

                 
                //console.log(this.data);
            })
            .catch(error => {
                console.error(error);
            });
                
              
                } 
            }
            else{
            this.checkRequiredFields();
            if (this.submitFlage) {
                this.popUpTitle = 'Manager Appraisel Overview';
                this.popUpbodyFlage = true;
                this.drafitView = true;
                this.showPopup = true;
            }
            }


        }
        this.popUpclass = this.drafitView === true ? "slds-modal slds-fade-in-open slds-modal_large " : "slds-modal slds-fade-in-open ";


    }


    checkRequiredFields() {
        let count = 0;


        if (this.overallManagerComments == '' || this.overallManagerComments == null) {
            this.showToast('Error', 'Please Give Manager Overall Comments', 'Error');
            return;
        } else {
            Object.keys(this.priToUpdate).every(pri => {


                if (this.priToUpdate[pri].managerRating == '' || this.priToUpdate[pri].managerRating == null || this.priToUpdate[pri].managerRating < 0.5 || this.priToUpdate[pri].managerComments == '' || this.priToUpdate[pri].managerComments == null) {


                    this.showToast('Error', 'Please Give Manager Rating and Comments for all Categories', 'Error');
                    return false;


                }
                count += 1;
                return true;
            });


            if (count == Object.keys(this.priToUpdate).length) {
                this.calculateScore();
                this.submitFlage = true;
            }
        }




    }


    kpiWeightageCheck;
    checkKpiWeightage() {
        Object.keys(this.pmsData).every(pr => {
            let kpiWeightage = 0;
            this.kpiWeightageCheck = true
            Object.keys(this.pmsData[pr].kpiData).every(kpi => {
                kpiWeightage += parseFloat(this.pmsData[pr].kpiData[kpi].weightage);
                return true;
            });
            if (kpiWeightage != this.pmsData[pr].kraWeightage) {
                this.kpiWeightageCheck = false;
                this.showToast('Error', 'Sum of All Kpi Weightage should be equal to the Kra Weightage', 'Error');
                return false;
            }
            return true;
        });


        //return true;


    }


    handleSubmit(flage) {
        this.isSpinner = true;
        updatePRI({ pri2update: this.priToUpdate, statusFlage: flage, prId: this.prId, mngOverallComts: this.overallManagerComments, currentQuarter: this.currentCycle }).then((result) => {
            let msg = flage == true ? 'Your Ratings are Submitted Successfully' : 'Your Ratings are Saved Successfully';
            refreshApex(this.refreshData);
            this.showToast('Success', msg, 'success');
            this.isSpinner = false;
            this.finalAlert = false;


        }).catch((err) => {
            this.showPopup = false;
            //console.log('~~Error~~', err)
            this.isSpinner = false;
            this.finalAlert = false;
        });
    }


    handleSave(event) {
        console.log('label',event.target.label);
        if (event.target.label == 'Save As Draft') {
            this.checkKpiWeightage();


            if (this.kpiWeightageCheck == true) {
                this.handleSubmit(false);
            }
            if(this.currentCycle==='Annual Cycle' && this.isReviewer===true && this.ismanagercplted===true)
            {
              updatereviewer({prId:this.prId,status: this.prstatus,rating:this.reviewrating,comments:this.reviewercomments,flag:'false'})  
            }
        }
        else if (event.target.label == 'Submit') {
            // this.handleFinalAlert();
            // if (this.finalAlert)
            //     this.handleSubmit(true);
           // console.log('~~~',this.currentCycle,this.isReviewer,this.ismanagercplted);
           
             
            
            this.finalAlert = true;
            this.showPopup = false;
            this.drafitView = false;
            
        }
    }


    handleFinalAlert(event) {


        if (event.target.label == 'Proceed') {
            this.handleSubmit(true);
            //this.isSpinner = false;
        }
        else if (event.target.label == 'Cancel') {
            this.finalAlert = false;
            this.showPopup = false;
            this.drafitView = false;
            this.popUpbodyFlage = false;
        }




    }




    handleCancel(event) {
        this.popUpbodyFlage = false;
        this.showPopup = false;
        this.viewFeedBack = false;
        this.drafitView = false;
        this.submitFlage = false;
        this.displayrating=false;


    }
    flage = false;




    updateDelegateManagerCommenets() {
        this.isSpinner = true;
        updateDelegateManagerCommenets({ comments: this.deleMgComments, delMgId: this.recId, quater: this.krasWrapperData.currentQuarter, prId: this.prId, currentQuarter: this.currentCycle }).then((result) => {
            this.showToast('Success', 'Feedback Is Saved Successfully', 'success');
            refreshApex(this.refreshData);
            this.isSpinner = false;
        }).catch((err) => {
            //updateDelegateManagerCommenets
            console.log('~~Error~~', JSON.stringify(err));
            this.isSpinner = false;
        });
        this.showPopup = false;
    }




    careerPlan() {
        this.displayCareerPlan = true;
        this.ismanageropen = false;
        this.dispatchEvent(new CustomEvent('pmslistview', {}));
    }


    kpiEdit = false
    changeToEdit(event) {
        if (event.keyCode === 13 || event.target.title === 'edit') {
            if (event.keyCode === 13 && event.target.title === 'KPI Weightage') {
                this.pmsData[event.currentTarget.dataset.kraindex].kpiData[event.currentTarget.dataset.kpiindex].weightage = event.target.value;
            }
            this.pmsData[event.currentTarget.dataset.kraindex].kpiData[event.currentTarget.dataset.kpiindex].isKpiEdit = !this.pmsData[event.currentTarget.dataset.kraindex].kpiData[event.currentTarget.dataset.kpiindex].isKpiEdit;




        }
        //console.log('~~this.kpiEdit  ', this.pmsData[event.currentTarget.dataset.kraindex].kpiData[event.currentTarget.dataset.kpiindex]);
    }




    calculateScore() {
        this.totalKRAScore = 0;
        Object.keys(this.priToUpdate).forEach(ele => {
            this.totalKRAScore += this.priToUpdate[ele].managerRating != null ? parseFloat(this.priToUpdate[ele].managerRating / 5) * (parseFloat(this.priToUpdate[ele].kpiWeightage) / 100) : 0;
        })
        this.totalKRAScore = (this.totalKRAScore * 5).toFixed(1);
    }




    showToast(tostTitl, msg, variant) {
        const event = new ShowToastEvent({
            title: tostTitl,
            message: msg,
            variant: variant,
            // mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


    handlecareerDevelop() {
        this.displayCareerPlan = false;
        this.ismanageropen = true;


    }
     handleYearChange(e) {
        this.selectedYear = e.detail.value;
        this.currentYear=this.selectedYear;
    }
    handleQPRChange(e) {
        this.selectedQuarter = e.detail.value;
        this.currentCycle= this.selectedQuarter;
    }
    handleEntryPopUpClose(){
        window.open('https://sftd1.my.site.com/CRMITCommunity/s/avishkaar-manager-review',"_self");

        this.entryPopUp = false;
        

    }
    handleEntryPopUp() {
        if (this.selectedQuarter == '' && this.selectedYear == '') { this.toastMsg('Error', 'Please Select Year and QPR', 'Error') }
        else if (this.selectedQuarter == '') { this.toastMsg('Error', 'Please Select QPR', 'Error') }
        else if (this.selectedYear == '') { this.toastMsg('Error', 'Please Select Year', 'Error') }
        else {
            this.entryPopUp = false;
             this.ismanageropen = true;
            //refreshApex(this.wrapperDetailsEmpForRefresh);
        }
        

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
    handlePopUps()
    {
        //console.log(' handlePopUps');
         
            
       this.popUpTitle='OverallRating Performance';
      this.displayrating=true;
      this.showPopup = true;
            
    }
     


}