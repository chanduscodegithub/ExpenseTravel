import { LightningElement,api ,wire,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//import { getRecord} from "lightning/uiRecordApi";
import PRdetails from '@salesforce/apex/Performanceratingrelatedlistclass.getDetailsOfpr';
import getCommunityURL from '@salesforce/apex/Performanceratingrelatedlistclass.getCommunityURL';

import profileChk from '@salesforce/apex/Performanceratingrelatedlistclass.profileChk';
export default class PerformancerRatingrelatedlist extends NavigationMixin(LightningElement) {
@api recordId;
@track Name;
@track manager;
@track status;
@track urlpath=[];
@track path;
communityURL;
isFullAccessOrHRmngLogin=false;

async connectedCallback(){
        try{
            this.isFullAccessOrHRmngLogin = await profileChk();
            this.communityURL = await getCommunityURL();
            console.log('~~communityURL : ',this.communityURL);
        }catch(er){
            console.log('~~Error : ',er);
        }
       
       

    }

handleclick()
{
    this.urlpath = window.location.pathname.split( '/' );
//this.path= window.location.origin+'/'+this.urlpath[1]+'/'+this.urlpath[2]+'/'+'appraisal-form';
       // console.log('this.path',this.path);
if(this.urlpath[1]=='CRMITCommunity')
    {
         //https://sftd1--pms.sandbox.lightning.force.com/lightning/r/appraisal-form
        this.path= this.communityURL+'/s/appraisal-form?c__recId='+this.recordId;
        console.log('this.path',this.path);
        window.open(this.path,'_self');
    }
    else{
        this[NavigationMixin.Navigate]({
        type: 'standard__navItemPage',
        attributes: {
            apiName: 'Appraisal_Review_Clone'
        },
        state: {
            c__recId: this.recordId
        }
    });
    
    }
    


}


@wire(PRdetails, { recordId: "$recordId"})
account({ error, data }) {
    
    if (data) {
        console.log('url', window.location.origin);
         console.log('~~',window.location.pathname.split( '/' ))
    
 console.log('this.path',this.path);
        this.Name=data.Name;
        this.manager=data.Employee__r.ReportingTo__r.Name;
        this.status=data.Status__c;

    } else if (error) {
        console.log(error);
        this.error = error;
    }
    }

}