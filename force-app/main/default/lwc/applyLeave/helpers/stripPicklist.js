import { getPropertyNameEligible, getPropertyName } from '../utils/utils.js';
import { LOP_PICKVAL } from 'c/leaveConfig';

function adjustPicklist(data) {
   this.leaveOptions = data.filter(eachType => {
    if (eachType.value === this.paternityPickValBind && this.empData.Gender__c === 'Female') {
      return false;
    }
    if (eachType.value === this.maternityPickValBind && this.empData.Gender__c === 'Male') {
      return false;
    }
    if(eachType.value === this.privilegePickValBind && this.empData.Region__c !== 'IND'){
      return false;
    }
    if (this.data[getPropertyName(eachType.value)] <= 0 && LOP_PICKVAL !== eachType.value) {
      return false;
    }
       return this.data[getPropertyNameEligible(eachType.value)];
       /* if(eachType.value === this.privilegePickValBind && this.Type__c  === 'Probationer'){
      return false;
    }
    if(eachType.value === this.casualPickValBind && this.Type__c  === 'Probationer'){
      return false;
    }*/
  });
  this.leaveOptions.push({"attributes":null,"label":"Annual Leave","validFor":[],"value": this.privilegePickValBind});
  }
export default adjustPicklist;