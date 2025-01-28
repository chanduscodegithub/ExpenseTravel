// Core Imports
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Server Imports
import IMAGES from '@salesforce/resourceUrl/iconsleave';

// Local Imports
import celebrate from './celebrate.js';

function debouncer() {
  let timeout;
  return function (fn, ms) {
    clearTimeout(timeout);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    timeout = setTimeout(() => {
      fn();
    }, ms);
  }
}

import {
  CASUAL_HTML_ATTR,
  SICK_HTML_ATTR,
  PAID_HTML_ATTR,
  CELEBRATION_HTML_ATTR,
  MATERNITY_HTML_ATTR,
  PATERNITY_HTML_ATTR,
  BEREAVEMENT_HTML_ATTR,
  RESTRICTED_HTML_ATTR,
  LOP_HTML_ATTR,
  LONG_HTML_ATTR,
  WFH_HTML_ATTR,
  PAIDADJ_HTML_ATTR
} from 'c/leaveConfig';

export default class LeaveCards extends LightningElement {
  @api empData;
  @api casualLimit;
  @api casualBalance;
  @api casualEligible;
  @api sickLimit;
  @api sickBalance;
  @api sickEligible;
  @api privilegeLimit;
  @api privilegeBalance;
  @api privilegeEligible;
  @api bereavementLimit;
  @api bereavementBalance;
  @api bereavementEligible;
  @api celebrationLimit;
  @api celebrationBalance;
  @api celebrationEligible;
  @api maternityLimit;
  @api maternityBalance;
  @api maternityEligible;
  @api paternityLimit;
  @api paternityBalance;
  @api paternityEligible;
  @api restrictedLimit;
  @api restrictedBalance;
  @api restrictedEligible;
  @api lossOfPayLimit;
  @api lossOfPayBalance;
  @api lossOfPayEligible;
  @api lossOfPayTook;
  @api longLimit;
  @api longBalance;
  @api longEligible;
  @api workFromHomeLimit;
  @api workFromHomeBalance;
  @api workFromHomeEligible;
  @api paidAdjLimit;
  @api paidAdjustmentBalance;
  @api paidAdjEligible;
  paidLeaveTitle = '';

  casualBind = CASUAL_HTML_ATTR;
  sickBind = SICK_HTML_ATTR;
  paidBind = PAID_HTML_ATTR;
  celebrationBind = CELEBRATION_HTML_ATTR;
  restrictedBind = RESTRICTED_HTML_ATTR;
  maternityBind = MATERNITY_HTML_ATTR;
  paternityBind = PATERNITY_HTML_ATTR;
  bereavementBind = BEREAVEMENT_HTML_ATTR;
  wfhBind = WFH_HTML_ATTR;
  paidAdjBind = PAIDADJ_HTML_ATTR;
  lopBind = LOP_HTML_ATTR;
  longBind = LONG_HTML_ATTR;

  get regionBaseBody(){
    return this.empData.Region__c == 'IND' ? 'Privilege Leave' : 'Annual Leave';
  }

  get casualClasses() {
    if(this.empData.Region__c != 'IND'){
      return 'leave__tile hideCard'
    }
    if (this.casualEligible) {
      return this.casualBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.casualBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get wfhClasses() {
    if(this.empData.Region__c != 'IND'){
      return 'leave__tile hideCard'
    }
    if (this.workFromHomeEligible) {
      return this.workFromHomeBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.workFromHomeBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get paidAdjClasses() {
    if (this.paidAdjEligible) {
      return this.paidAdjustmentBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.paidAdjustmentBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get sickClasses() {
    if (this.sickEligible) {
      return this.sickBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.sickBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get paidClasses() {
    if (this.privilegeEligible) {
      return this.privilegeBalance > 0 ? 'leave__tile leave__popup' : 'leave__tile grayscale';
    } else if (this.privilegeBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get celebrationClasses() {
    if(this.empData.Region__c == 'US'){
      return 'leave__tile hideCard'
    }
    if (this.celebrationEligible) {
      return this.celebrationBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.celebrationBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get maternityClasses() {
    if(this.empData.Region__c != 'IND'){
      return 'leave__tile hideCard'
    }
    if (this.maternityEligible) {
      return this.maternityBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.maternityBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get paternityClasses() {
    if(this.empData.Region__c == 'US'){
      return 'leave__tile hideCard'
    }
     
    if (this.paternityEligible) {
      return this.paternityBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.paternityBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get bereavementClasses() {
    if(this.empData.Region__c != 'IND'){
      return 'leave__tile hideCard'
    }
    if (this.bereavementEligible) {
      return this.bereavementBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.bereavementBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get restrictedClasses() {
    if(this.empData.Region__c != 'IND'){
      return 'leave__tile hideCard'
    }
    if (this.restrictedEligible) {
      return this.restrictedBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.restrictedBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }
  get lopClasses() {
    if (this.lossOfPayEligible) {
      return 'leave__tile';
    }
    return 'leave__tile grayscale';
  }
  get longClasses() {
    if (this.longEligible) {
      return this.longBalance > 0 ? 'leave__tile' : 'leave__tile grayscale';
    } else if (this.longBalance > 0) {
      return 'leave__tile grayscale';
    }
    return 'leave__tile hideCard';
  }

  casualLogo = IMAGES + '/iconsleave/case.png';
  sickLogo = IMAGES + '/iconsleave/sick.png';
  privilegeLogo = IMAGES + '/iconsleave/paid.png';
  partyLogo = IMAGES + '/iconsleave/party.png';
  maternityLogo = IMAGES + '/iconsleave/kid.png';
  paternityLogo = IMAGES + '/iconsleave/dad.png';
  brokenLogo = IMAGES + '/iconsleave/broken.png';
  restrictLogo = IMAGES + '/iconsleave/restricted.png';
  longLeave = IMAGES + '/iconsleave/long.png';
  lop = IMAGES + '/iconsleave/lop.png';
  wfhLogo = IMAGES + '/iconsleave/home.png';
  plAdjLogo = IMAGES + '/iconsleave/vacationTree.png';

  debounceHandler = debouncer();

  handleCardClick(e) {
    try {
      let selectedCard = e.currentTarget.dataset.type;
      let cardDOMToken = e.currentTarget;
      let balance;
      switch (selectedCard) {
        case CASUAL_HTML_ATTR:
          balance = this.casualEligible ? this.casualBalance : 0;
          break;
        case WFH_HTML_ATTR:
          balance = this.workFromHomeEligible ? this.workFromHomeBalance : 0;
          break;
        case PAIDADJ_HTML_ATTR:
          balance = this.paidAdjEligible ? this.paidAdjustmentBalance : 0;
          break;
        case SICK_HTML_ATTR:
          balance = this.sickEligible ? this.sickBalance : 0;
          break;
        case PAID_HTML_ATTR:
          balance = this.privilegeEligible ? this.privilegeBalance : 0;
          break;
        case CELEBRATION_HTML_ATTR:
          balance = this.celebrationEligible ? this.celebrationBalance : 0;
          break;
        case MATERNITY_HTML_ATTR:
          balance = this.maternityEligible ? this.maternityBalance : 0;
          break;
        case PATERNITY_HTML_ATTR:
          balance = this.paternityEligible ? this.paternityBalance : 0;
          break;
        case BEREAVEMENT_HTML_ATTR:
          balance = this.bereavementEligible ? this.bereavementBalance : 0;
          break;
        case RESTRICTED_HTML_ATTR:
          balance = this.restrictedEligible ? this.restrictedBalance : 0;
          break;
        case LOP_HTML_ATTR:
          balance = this.lossOfPayEligible ? this.lossOfPayBalance : 0;
          break;
        case LONG_HTML_ATTR:
          balance = this.longEligible ? this.longBalance : 0;
          break;
        default:
          throw new Error('Error: Invalid Leave Type');
      }
      if ((selectedCard === PATERNITY_HTML_ATTR || selectedCard === MATERNITY_HTML_ATTR || selectedCard === CELEBRATION_HTML_ATTR || selectedCard === RESTRICTED_HTML_ATTR) && balance > 0) {
        celebrate(e);
      }
      if (balance <= 0) {
        selectedCard = '';
        cardDOMToken.classList.add('shrug');
        this.debounceHandler(() => {
          cardDOMToken.classList.remove('shrug');
        }, 600);
      }
      this.dispatchEvent(new CustomEvent('cardclick', {
        detail: {
          actionType: selectedCard
        }
      }));
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error!',
          message: `${error}`,
          variant: 'error'
        }));
    }
  }
}