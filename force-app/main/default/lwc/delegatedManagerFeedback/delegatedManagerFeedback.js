import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import searchCoachByName from '@salesforce/apex/PMS_Controller.searchCoachByName';
import submitmanager from '@salesforce/apex/PMS_Controller.updatemanagerdata';
export default class LightningRecordFormCreateExampleLWC extends LightningElement {

@api prId; @api currentQuater;
@api repMgId; @api empId; @api isManagerSubmitted=false ; @api prStatus;
@api showPopUp; @track isLoading = true; showLoading = true; @api delMgname1;@api delMgname2;@api feedBack1;@api feedBack2;

PA1='';
error;
PA2='';
PAname='';
type1='search'

name='';
searchterm;
currentname='';
displayDropDown;
displayDropDown1;
comments1;
comments2;
recentlySearchedListOfDesignations=[];
searchedManagerResultList=[];
@wire( searchCoachByName, { coachName: '$searchterm' } )
wiredDesignationSearchResult({ data, error }){
    if( data ){
        //console.log(data);
        this.recentlySearchedListOfDesignations = [];
        data.forEach( coach => { this.recentlySearchedListOfDesignations.push({ label: coach.Name, value: coach.Id }) } );
        this.searchedManagerResultList = this.recentlySearchedListOfDesignations;
            //console.log( this.searchedManagerResultList);
    } else if( error ){
        this.dispatchEvent( new ShowToastEvent({
            variant: 'error',
            title: 'Failed to fetch search result'
        }));
    }
}
searchForManager(event){
    this.type1='search'
    this.searchterm= event.target.value;
    this.name=event.target.name;
    if( this.name=='Project Associate1')
    {
    this.displayDropDown1=true;
    this.displayDropDown=false;
    }
    else if(this.name=='Project Associate2')
    {
        this.displayDropDown=true;
        this.displayDropDown1=false;
    }
    console.log('this.searchterm',this.displayDropDown1);
}
selectDesignationFromSearchResult(event){
console.log('ajajj');
    if(event.currentTarget.dataset.msg=='Project Associate1')
    {
        this.PAname= event.currentTarget.dataset.label;
        this.PA1= event.currentTarget.dataset.value;
            //console.log('detail',this.PAname);
            this.displayDropDown1=false;
           
        
    }
    else if(event.currentTarget.dataset.msg=='Project Associate2')
    {
           // console.log('detail',this.PA2name);
        this.PA2name=event.currentTarget.dataset.label;
        //console.log('AFTER',this.PA2name);
            this.PA2=event.currentTarget.dataset.value;
        this.displayDropDown=false;
           
        

    }
    
}
entercomments(event)
{
    if (event.target.name=='comment1')
    {
        this.comments1=event.target.value;
    }
        if (event.target.name=='comment2')
    {
        this.comments2=event.target.value;
    }
}

closePopUp() {
    this.showPopUp = false;
    this.dispatchEvent(new CustomEvent('closepop'))
}

handleSearchChange(event)
{
    this.delmg1=event.target.value;
}

connectedCallback() {
    this.PAname=this.delMgname1;
    this.PA2name=this.delMgname2;
    this.comment1=this.feedBack1;
    this.comment2=this.feedBack2;
    this.isLoading = false;
    this.showLoading = false;
    this.type1=(this.isManagerSubmitted?'':'search');
    //console.log('isManagerSubmitted12',this.isManagerSubmitted);
    this.isManagerSubmitted=(this.prStatus=='Reviewer Submitted'?true:this.isManagerSubmitted);
    //console.log('isManagerSubmitted',this.isManagerSubmitted);
    //console.log('~~ Load : ',this.prId,this.currentQuater);
}

handleLoad() {
    //console.log('Loading : ');
    this.isLoading = false;
    this.showLoading = false;
}

handleSubmit() {
    //console.log('hi');
    // event.preventDefault();
    //let delMg = this.template.querySelector('lightning-input-field[data-field="Delegated_Manager__c"]').value;
    //let delMg2 = this.template.querySelector('lightning-input-field[data-field="Delegated_Manager2__c"]').value;
    //console.log(`~~del1 ${delMg} - delMg2 ${delMg2}`);
    if ((this.PA1 != null && this.PA1 != undefined && this.PA1 != '' &&  this.PA2 != '') && (this.PA1 ==  this.PA2)) {
        let title = 'Error';
        let msg = 'Delegate Manager 1 and Delegate Manager 2 should not be same';
        let variant = 'Error';
        this.handleToast(title, msg, variant);
    }
    else if ((this.PA1 != null && this.PA1 != undefined && this.PA1 != '' &&  this.PA2 != '') && (this.repMgId == this.PA1 || this.repMgId ==  this.PA2)) {
        let title = 'Error';
        let msg = 'Delegate Manager and Reporting Manager should not be same';
        let variant = 'Error';
        this.handleToast(title, msg, variant);
    }
    else if ((this.PA1 != null && this.PA1 != undefined && this.PA1 != '' &&  this.PA2 != '') && (this.PA1 == this.empId ||  this.PA1 == this.empId)) {
        let title = 'Error';
        let msg = 'Cuerrent Employee should not be the Delegate Manager';
        let variant = 'Error';
        this.handleToast(title, msg, variant);
    }
    else {
        //console.log('this.PA1',this.PA1,this.PA2,this.comments1,this.comments2,this.prId,this.currentQuater);
        submitmanager({del1:this.PA1,del2:this.PA2,comment1:this.comments1,comment2:this.comments2,pId:this.prId,currentCycle:this.currentQuater})
        .then((result) => {
        this.dispatchEvent(new RefreshEvent());
         this.handleSuccess();
           })
         .catch((error) => {
          this.error = error;
          });

}
}
handleSuccess(event) {
    let title = "Success";
    let msg = "Successfully updated";
    let variant = "success";
    this.handleToast(title, msg, variant);
    this.closePopUp();
}
handleToast(title, msg, variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: msg,
        variant: variant
    });
    this.dispatchEvent(evt);
}
}