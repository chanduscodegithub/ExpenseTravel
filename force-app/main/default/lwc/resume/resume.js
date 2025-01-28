import { LightningElement, api, track } from "lwc";
import getResumeInsightRecord from "@salesforce/apex/ResumeController.getResumeInsightRecord";
import updateSummaryOpened from "@salesforce/apex/ResumeController.updateSummaryOpened";

export default class Resume extends LightningElement {
@track resumeInsightRecord;
@track _recordId;
@track isHybridWorkModelExpected = false;
@track workedInBangalore = false;
@track showModal = false;
@track accountSummary = "";
@track showAskQuestion = false;
@track leftCardHeading = "";
@track rightCardHeading = "";
@track rrfLocation='';
techskillsFound = [];
certificationList = [];
companyList = [];
// parts = [];
linkedin = "";
trailhead = "";

get recordId() {
  return this._recordId;
}
@api set recordId(value) {
  console.log('test');
  (this._recordId = value), this.handleResumeInsights();
}
get getCurrentCardClass() {
  return `card${this.currentIndex + 1}`;
}

get totalWorkExpClass() {
  if (
    this.data?.performanceIndicator?.totalWorkExp == undefined ||
    this.data?.performanceIndicator?.totalWorkExp == null ||
    this.data?.performanceIndicator?.totalWorkExp == ""
  )
    return "totalexp";
  else if (
    this.data?.minTotalWorkExpJobRole == undefined ||
    this.data?.minTotalWorkExpJobRole == null ||
    this.data?.minTotalWorkExpJobRole == "" ||
    this.data?.maxTotalWorkExpJobRole == undefined ||
    this.data?.maxTotalWorkExpJobRole == null ||
    this.data?.maxTotalWorkExpJobRole == ""
  )
    return "totalexp";
  else if (
    this.data.performanceIndicator.totalWorkExp <
    this.data.minTotalWorkExpJobRole
  )
    return "totalexp orange";
  /* else if(this.data.performanceIndicator.totalWorkExp>this.data.maxTotalWorkExpJobRole)
    return 'totalexp green';
  else if(this.data.performanceIndicator.totalWorkExp<=this.data.maxTotalWorkExpJobRole && this.data.performanceIndicator.totalWorkExp>=this.data.minTotalWorkExpJobRole)
    return 'totalexp orange'; */ else if (
    this.data.performanceIndicator.totalWorkExp >=
    this.data.minTotalWorkExpJobRole
  )
    return "totalexp green";
}

get minTenureClass() {
  if (
    this.data?.performanceIndicator?.minTenure == undefined ||
    this.data?.performanceIndicator?.minTenure == null ||
    this.data?.performanceIndicator?.minTenure == ""
  )
    return "minMaxAvgTenure";
  else if (
    this.data?.minTenureJobRole == undefined ||
    this.data?.minTenureJobRole == null ||
    this.data?.minTenureJobRole == ""
  )
    return "minMaxAvgTenure";
  else if (
    this.data.performanceIndicator.minTenure < this.data.minTenureJobRole
  )
    return "minMaxAvgTenure orange";
  else if (
    this.data.performanceIndicator.minTenure >= this.data.minTenureJobRole
  )
    return "minMaxAvgTenure green";
}

get maxTenureClass() {
  if (
    this.data?.performanceIndicator?.maxTenure == undefined ||
    this.data?.performanceIndicator?.maxTenure == null ||
    this.data?.performanceIndicator?.maxTenure == ""
  )
    return "minMaxAvgTenure";
  else if (
    this.data?.minTenureJobRole == undefined ||
    this.data?.minTenureJobRole == null ||
    this.data?.minTenureJobRole == ""
  )
    return "minMaxAvgTenure";
  else if (
    this.data.performanceIndicator.maxTenure < this.data.minTenureJobRole
  )
    return "minMaxAvgTenure orange";
  else if (
    this.data.performanceIndicator.maxTenure >= this.data.minTenureJobRole
  )
    return "minMaxAvgTenure green";
}

get avgTenureClass() {
  if (
    this.data?.performanceIndicator?.avgTenure == undefined ||
    this.data?.performanceIndicator?.avgTenure == null ||
    this.data?.performanceIndicator?.avgTenure == ""
  )
    return "minMaxAvgTenure";
  else if (
    this.data?.avgTenureJobRole == undefined ||
    this.data?.avgTenureJobRole == null ||
    this.data?.avgTenureJobRole == ""
  )
    return "minMaxAvgTenure";
  else if (
    this.data.performanceIndicator.avgTenure < this.data.avgTenureJobRole
  )
    return "minMaxAvgTenure orange";
  else if (
    this.data.performanceIndicator.avgTenure >= this.data.avgTenureJobRole
  )
    return "minMaxAvgTenure green";
}

get numberOfCompaniesWorkedFor()
{
  if(this.companyData==null || this.companyData==undefined || this.companyData=='') return '';
  else return this.companyData.length;
}

showPreviousCard() {
  if (this.currentIndex > 0) {
    this.currentIndex--;
  }
}

showNextCard() {
  if (this.currentIndex < this.totalNumberOfCards - 1) {
    this.currentIndex++;
  }
}

handleAskQuestion() {
  this.showAskQuestion = true;
}

handleCloseAskQuestion() {
  this.showAskQuestion = false;
}

calculateInYears(numberOfMonths)
{
  let year=parseInt(numberOfMonths/12);
  let month=parseInt(numberOfMonths%12);
  /* let duration='';
  if(year!=0) duration=`${year}y `;
  if(month!=0) duration=duration+`${month}m`;
  return duration.trim(); */
  let duration={
    'year':(year!=0)?year:null,
    'month':(month!=0)?month:null
  }
  return duration;
}

handleResumeInsights() {
  console.log('Rdas');
  getResumeInsightRecord({ recordId: this.recordId })
    .then((res) => {
      console.log('Res--'+JSON.stringify(res));
      this.resumeInsightRecord = res;
      if (!(res.Expertise_and_Experience_Summary__c === undefined)) {
        this.accountSummary = res.Expertise_and_Experience_Summary__c;
      }
if (res.Companies_Worked_for__c) {
this.companyList =
  this.resumeInsightRecord.Companies_Worked_for__c.split(";");
this.monthsArray = [];
this.companyNameArray = [];
this.domainArray = []; // Add this line

this.companyList.forEach((each) => {
  /* let substr = each.split("-");
  let companyInfo = substr[0].split("["); // Split by "[" to get company name and domain
  let companyName = companyInfo[0].trim();
  let domain = companyInfo[1] ? companyInfo[1].replace("]", "") : ""; // Remove "]" from the domain
  this.monthsArray.push(substr[1]);
  this.companyNameArray.push(companyName);
  this.domainArray.push(domain); // Push the domain into the array */

  let monthsStart=each.lastIndexOf('-');
  let domainEnd=each.lastIndexOf(']');
  let domainStart=each.indexOf('[');
  let months=each.substring(monthsStart+1);
  let companyName=each.substring(0,domainStart);
  let domain=each.substring(domainStart+1,domainEnd);

  this.monthsArray.push(months.trim());
  this.companyNameArray.push(companyName.trim());
  this.domainArray.push(domain.trim()); // Push the domain into the array
});

this.companyData = this.companyNameArray.map((company, index) => ({
  id: index + 1,
  name: company,
  domain: this.domainArray[index], // Add domain to the object
  /* month: this.monthsArray[index], */
  month:this.calculateInYears(parseInt(this.monthsArray[index].replace('Months','').trim()))
}));
}


      if (res.LinkedIn_Url__c === "Not Provided" || !res.LinkedIn_Url__c) {
        this.linkedin = undefined;
      } else if(res.LinkedIn_Url__c.includes("https://")|| res.LinkedIn_Url__c.includes("http://")){
        this.linkedin = res.LinkedIn_Url__c;
      }
      else{
        this.linkedin="https://"+res.LinkedIn_Url__c;
      }
      if (res.Trailhead_Url__c === "Not Provided" || !res.Trailhead_Url__c) {
        this.trailhead = undefined;
      } else {
        this.trailhead = res.Trailhead_Url__c;
      }
      if (
        res.Current_Location__c === "Not Provided" ||
        !res.Current_Location__c
      ) {
        this.location = undefined;
      } else {
        this.location = res.Current_Location__c;
      }
      if (
        res.Worked_in_Banglore_Before__c === "Not Provided" ||
        !res.Worked_in_Banglore_Before__c
      ) {
        this.workedBangalore = undefined;
      } else {
        this.workedBangalore = res.Worked_in_Banglore_Before__c;
      }
      if (
        res.Expecting_a_Hybrid_Work_Model__c === "Not Provided" ||
        !res.Expecting_a_Hybrid_Work_Model__c
      ) {
        this.hybrid = undefined;
      } else {
        this.hybrid = res.Expecting_a_Hybrid_Work_Model__c;
      }
      if (res.Email_Address__c === "Not Provided" || !res.Email_Address__c) {
        this.Email = undefined;
        var element = document.querySelector(".lightningemail");
        element.classList.add("newclass");
        // Remove the "lightningemail" class
        element.classList.remove("lightningemail");
      }
      
/******************************Technical Skills*********************************************************/


/*const techSkillsData = res.Essential_Tech_Skills_Analysis__c+";"+res.Advanced_Tech_Skills_Analysis__c;
const foundTechSkills = [];
const notfoundTechSkills = [];
const skillSections = techSkillsData.split(';');
skillSections.forEach(section => {
const [skill, status] = section.split(' - ');
if (status === 'Found') {
  foundTechSkills.push(skill.trim());
} else if (status === 'Not Found') {
  notfoundTechSkills.push(skill.trim());
}
});
*/
let techSkills='';
let missingTechSkills='';
if(res.Essential_Tech_Skills_Analysis__c!=null && res.Essential_Tech_Skills_Analysis__c!= undefined)
{
  techSkills=res.Essential_Tech_Skills_Analysis__c+';';
}
if(res.Advanced_Tech_Skills_Analysis__c!=null && res.Advanced_Tech_Skills_Analysis__c!=undefined)
{
  techSkills=techSkills+res.Advanced_Tech_Skills_Analysis__c;
}
else
{
  techSkills=techSkills.slice(0,-1);
}
//For not found tech skills
if(res.Missing_Tech_Skills__c!=null && res.Missing_Tech_Skills__c!= undefined)
{
  missingTechSkills = res.Missing_Tech_Skills__c+';';
}
if(res.Missing_Tech_Skills_Additional__c!= null && res.Missing_Tech_Skills_Additional__c!= undefined)
{
  missingTechSkills = missingTechSkills+ res.Missing_Tech_Skills_Additional__c;
}
else
{
  missingTechSkills = missingTechSkills.slice(0,-1);
}
const techSkillsData = techSkills;
const missingTechSkillsData = missingTechSkills;
const foundTechSkills = [];
const notfoundTechSkills = [];
const techSkill = techSkillsData.split(';');
if(techSkills!='')
{
  techSkill.forEach(section => {
    foundTechSkills.push(section.trim());
  });
}

const missingTechSkill = missingTechSkillsData.split(';');
if(missingTechSkills!='')
{
  missingTechSkill.forEach(section => {
    notfoundTechSkills.push(section.trim());
  });
}
/******************************Admin Skills*********************************************************/
let adminSkills='';
let missingAdminSkills='';
if(res.Essential_Admin_Skills_Analysis__c!=null && res.Essential_Admin_Skills_Analysis__c!= undefined)
{
  adminSkills=res.Essential_Admin_Skills_Analysis__c+';';
}
if(res.Advanced_Admin_Skills_Analysis__c!=null && res.Advanced_Admin_Skills_Analysis__c!=undefined)
{
  adminSkills=adminSkills+res.Advanced_Admin_Skills_Analysis__c;
}
else
{
  adminSkills=adminSkills.slice(0,-1);
}
//For not found admin skills
if(res.Missing_Admin_Skills__c!=null && res.Missing_Admin_Skills__c!= undefined)
{
  missingAdminSkills = res.Missing_Admin_Skills__c+';';
}
if(res.Missing_Admin_Skills_Additional__c!= null && res.Missing_Admin_Skills_Additional__c!= undefined)
{
  missingAdminSkills = missingAdminSkills+ res.Missing_Admin_Skills_Additional__c;
}
else
{
  missingAdminSkills=missingAdminSkills.slice(0,-1);
}
const adminSkillsData = adminSkills;
const missingAdminSkillsData = missingAdminSkills;
const foundAdminSkills = [];
const notfoundAdminSkills = [];
const adminSkill = adminSkillsData.split(';');
if(adminSkills!='')
{
  adminSkill.forEach(section => {
    foundAdminSkills.push(section.trim());
  });
}


const missingAdminSkill = missingAdminSkillsData.split(';');
if(missingAdminSkills!='')
{
  missingAdminSkill.forEach(section => {
    notfoundAdminSkills.push(section.trim());
  });
}


/****************************** Tools*********************************************************/

/*const toolsData = res.Essential_Tools_Analysis__c+";"+res.Advanced_Tools_Analysis__c;
const foundTools = [];
const notfoundTools = [];
const tools = toolsData.split(';');
tools.forEach(section => {
const [skill, status] = section.split(' - ');
if (status === 'Found') {
  foundTools.push(skill.trim());
} else if (status === 'Not Found') {
  notfoundTools.push(skill.trim());
}
});
*/

let toolsknown='';
let missingTools='';
if(res.Essential_Tools_Analysis__c!=null && res.Essential_Tools_Analysis__c!= undefined)
{
  toolsknown=res.Essential_Tools_Analysis__c+';';
}
if(res.Advanced_Tools_Analysis__c!=null && res.Advanced_Tools_Analysis__c!=undefined)
{
  toolsknown=toolsknown+res.Advanced_Tools_Analysis__c;
}
else
{
  toolsknown=toolsknown.slice(0,-1);
}
//For not found tools
if(res.Missing_Tools__c!=null && res.Missing_Tools__c!= undefined)
{
  missingTools = res.Missing_Tools__c+';';
}
if(res.Missing_Tools_Additional__c!= null && res.Missing_Tools_Additional__c!= undefined)
{
  missingTools = missingTools+ res.Missing_Tools_Additional__c;
}
else
{
  missingTools=missingTools.slice(0,-1);
}
const toolsData = toolsknown;
const missingToolsData = missingTools;
const foundTools = [];
const notfoundTools = [];
const tool = toolsData.split(';');
if(toolsknown!='')
{
  tool.forEach(section => {
    foundTools.push(section.trim());
  });
}


const missingTool = missingToolsData.split(';');
if(missingTools!='')
{
  missingTool.forEach(section => {
    notfoundTools.push(section.trim());
  });
}

/****************************** Cloud*********************************************************/

/*const cloudData = res.Salesforce_Clouds_Analysis__c+";";
const foundCloud = [];
const notfoundCloud = [];
const cloud = cloudData.split(';');
cloud.forEach(section => {
const [skill, status] = section.split(' - ');
if (status === 'Found') {
  foundCloud.push(skill.trim());
} else if (status === 'Not Found') {
  notfoundCloud.push(skill.trim());
}
});
*/
let cloud='';
let missingCloud='';
if(res.Salesforce_Clouds_Analysis__c!=null && res.Salesforce_Clouds_Analysis__c!= undefined)
{
  cloud=res.Salesforce_Clouds_Analysis__c;
}
if(res.Missing_Clouds__c!=null && res.Missing_Clouds__c!= undefined)
{
  missingCloud = res.Missing_Clouds__c;
}
const foundCloud = [];
const notfoundCloud = [];
const clouds = cloud.split(';');
if(cloud!='')
{
  clouds.forEach(section => {
    foundCloud.push(section.trim());
  });
}


const missingClouds = missingCloud.split(';');
if(missingCloud!='')
{
  missingClouds.forEach(section => {
    notfoundCloud.push(section.trim());
  });
}
/****************************** Certifications*********************************************************/
/*
const adminCertData = res.Essential_Certifications_Analysis__c+";"+res.Advanced_Certitfications_Analysis__c;
const foundCertificate = [];
const notfoundCertificate = [];
const certificate = adminCertData.split(';');
certificate.forEach(section => {
const [skill, status] = section.split(' - ');
if (status === 'Found') {
  foundCertificate.push(skill.trim());
} else if (status === 'Not Found') {
  notfoundCertificate.push(skill.trim());
}
});
*/

let certDone='';
let missingCert='';
if(res.Essential_Certifications_Analysis__c!=null && res.Essential_Certifications_Analysis__c!= undefined)
{
  certDone=res.Essential_Certifications_Analysis__c+';';
}
if(res.Advanced_Certitfications_Analysis__c!=null && res.Advanced_Certitfications_Analysis__c!=undefined)
{
  certDone=certDone+res.Advanced_Certitfications_Analysis__c;
}
else
{
  certDone=certDone.slice(0,-1);
}
//For not found certificates
if(res.Missing_Certifications__c!=null && res.Missing_Certifications__c!= undefined)
{
  missingCert = res.Missing_Certifications__c+';';
}
if(res.Missing_Certifications_Additional__c!= null && res.Missing_Certifications_Additional__c!= undefined)
{
  missingCert = missingCert+ res.Missing_Certifications_Additional__c;
}
else
{
  missingCert=missingCert.slice(0,-1);
}
const certsData = certDone;
const missingCertsData = missingCert;
const foundCertificate = [];
const notfoundCertificate = [];
const cert = certsData.split(';');
if(certDone!='')
{
  cert.forEach(section => {
    foundCertificate.push(section.trim());
  });
}


const missingCertificate = missingCertsData.split(';');
if(missingCert!='')
{
  missingCertificate.forEach(section => {
    notfoundCertificate.push(section.trim());
  });
}

      
      if(res?.Job_Application__r?.Position__r?.Location__c == 'India - Bangalore')
        this.rrfLocation='Bangalore';
        else if(res?.Job_Application__r?.Position__r?.Location__c == 'USA_Onsite')
        this.rrfLocation='USA';
        else if(res?.Job_Application__r?.Position__r?.Location__c == 'USA - Offshore')
        this.rrfLocation='USA';
        else if(res?.Job_Application__r?.Position__r?.Location__c == 'ANZ - Offshore')
        this.rrfLocation='Australia';
        else if(res?.Job_Application__r?.Position__r?.Location__c == 'ANZ - Sydney')
        this.rrfLocation='Sydney';
        else if(res?.Job_Application__r?.Position__r?.Location__c == 'ANZ - Melbourne')
        this.rrfLocation='Melbourne';
        else if(res?.Job_Application__r?.Position__r?.Location__c == 'India - Anywhere')
        this.rrfLocation='India';
        else if(res?.Job_Application__r?.Position__r?.Location__c == 'Singapore')
        this.rrfLocation='Singapore';
      this.data = {
        Name: res.Candidate_Name__c,
        LatestRole: res.Latest_Role__c,
        Email: res.Email_Address__c,
        Phone: res.Phone_Number__c,
        Location: this.location,
        LinkedIn: this.linkedin,
        Trailhead: this.trailhead,
        techScore:((parseFloat(res.Essential_Tech_Score__c)+parseFloat(res.Advanced_Tech_Score__c))/10).toFixed(2),
        adminScore:((parseFloat(res.Essential_Administration_Skills_Score__c)+parseFloat(res.Advanced_Administration_Skills_Score__c))/10).toFixed(2),
        toolScore:((parseFloat(res.Advanced_Tools_Score__c)+parseFloat(res.Essental_Tools_Score__c))/10).toFixed(2),
        certScore:((parseFloat(res.Advanced_Certifications_Score__c)+parseFloat(res.Essential_Certifications_Score__c))/10).toFixed(2),
        verticalsScore:((parseFloat(res.Verticals_Score__c))/10).toFixed(2),
        cloudScore:((parseFloat(res.Salesforce_Clouds_Score__c))/10).toFixed(2),
        workedInBangalore: this.workedBangalore,
        hybridModel: this.hybrid,
        performanceIndicator: {
          totalWorkExp: res.Total_Experience_Months__c,
          totalWorkExpInYears:this.calculateInYears(res.Total_Experience_Months__c),
          minTenure: res.Min_Time_Spent_in_a_Company__c,
          /* minTenureInYears:this.calculateInYears(res.Min_Time_Spent_in_a_Company__c), */
          maxTenure: res.Max_Time_Spent_in_a_Company__c,
          /* maxTenureInYears:this.calculateInYears(res.Max_Time_Spent_in_a_Company__c), */
          avgTenure: Math.round(res.Average_Tenure__c),
          /* avgTenureInYears:this.calculateInYears(res.Average_Tenure__c), */
        },
        minTotalWorkExpJobRole:
          res.Job_Application__r?.Position__r?.Job_Role__r
            ?.Min_Months_of_Experience__c,
        maxTotalWorkExpJobRole:
          res.Job_Application__r?.Position__r?.Job_Role__r
            ?.Max_Months_of_Experience__c,
        minTenureJobRole: parseInt(
          res.Job_Application__r?.Position__r?.Job_Role__r
            ?.Min_Tenure_in_a_Company__c
        ),
        //maxTenureJobRole:parseInt(res.Job_Application__r?.Position__r?.Job_Role__r?.Max_Tenure_in_a_Company__c),
        avgTenureJobRole: parseFloat(
          res.Job_Application__r?.Position__r?.Job_Role__r
            ?.Avg_Tenure_in_a_Company__c
        ),
        companiesWorkedFor: this.companyData,
        overallScore:(res.Overall_Score__c/10).toFixed(2),
        technicalSkills: {
          Found:foundTechSkills,
          notFound: notfoundTechSkills
        },
        adminSkills: {
          Found: foundAdminSkills,
          notFound: notfoundAdminSkills
        },
        certifications: {
          Found: foundCertificate,
          notFound: notfoundCertificate
        },
        tools: {
          Found: foundTools,
          notFound: notfoundTools
        },
        sfClouds: {
          Found: foundCloud,
          notFound:notfoundCloud
        },
      };

      console.log("Res-" + JSON.stringify(res));
      console.log("Res-" + JSON.stringify(this.data));
    })

    .catch((error) => {
      console.log("Error-" + JSON.stringify(error.stack));
    });
}
showPopup() {
  this.showModal = true;
  updateSummaryOpened({jobApplicationRecordId:this.recordId});
}

closeModal() {
  this.showModal = false;
}
handleRightClick(event) {
  console.log("Right Click");
  this.handleArrowClick(event);
  const cards = this.template.querySelectorAll(".carousel_cards .card4");
  let index;
  cards.forEach((each, idx) => {
    if (each.classList.contains("right__card")) {
      index = idx;
    }
  });
  console.log("Index: " + index);
  if (index > 1 && index < cards.length - 1) {
    cards[index + 1].classList.add("right__card");
    cards[index + 1].classList.remove("hidden__card");
    cards[index].classList.remove("right__card");
    cards[index - 1].classList.add("left__card");
    cards[index - 2].classList.add("hidden__card");
    cards[index - 2].classList.remove("left__card");
  } else if (index === cards.length - 1) {
    cards[index].classList.remove("right__card");
    cards[0].classList.add("right__card");
    cards[0].classList.remove("hidden__card");
    cards[index - 1].classList.add("left__card");
    cards[index - 2].classList.remove("left__card");
    cards[index - 2].classList.add("hidden__card");
  } else if (index === 0) {
    cards[index].classList.remove("right__card");
    cards[index + 1].classList.add("right__card");
    cards[index + 1].classList.remove("hidden__card");
    cards[cards.length - 1].classList.add("left__card");
    cards[cards.length - 2].classList.remove("left__card");
    cards[cards.length - 2].classList.add("hidden__card");
  } else if (index === 1) {
    cards[cards.length - 1].classList.remove("left__card");
    cards[cards.length - 1].classList.add("hidden__card");
    cards[index - 1].classList.add("left__card");
    cards[index].classList.remove("right__card");
    cards[index + 1].classList.add("right__card");
    cards[index + 1].classList.remove("hidden__card");
  }
}
handleLeftClick(event) {
  console.log("Left Click");
  this.handleArrowClick(event);
  const cards = this.template.querySelectorAll(".carousel_cards .card4");
  let currentIndex;
  cards.forEach((each, idx) => {
    if (each.classList.contains("left__card")) {
      currentIndex = idx;
    }
  });
  if (currentIndex > 0 && currentIndex < cards.length - 2) {
    cards[currentIndex].classList.remove("left__card");
    cards[currentIndex - 1].classList.add("left__card");
    cards[currentIndex - 1].classList.remove("hidden__card");
    cards[currentIndex + 1].classList.add("right__card");
    cards[currentIndex + 2].classList.remove("right__card");
    cards[currentIndex + 2].classList.add("hidden__card");
  } else if (currentIndex === 0) {
    cards[currentIndex].classList.remove("left__card");
    cards[cards.length - 1].classList.add("left__card");
    cards[cards.length - 1].classList.remove("hidden__card");
    cards[currentIndex + 1].classList.add("right__card");
    cards[currentIndex + 2].classList.remove("right__card");
    cards[currentIndex + 2].classList.add("hidden__card");
  } else if (currentIndex === cards.length - 1) {
    cards[currentIndex].classList.remove("left__card");
    cards[currentIndex - 1].classList.add("left__card");
    cards[currentIndex - 1].classList.remove("hidden__card");
    cards[0].classList.add("right__card");
    cards[1].classList.remove("right__card");
    cards[1].classList.add("hidden__card");
  } else if (currentIndex === cards.length - 2) {
    cards[currentIndex].classList.remove("left__card");
    cards[currentIndex - 1].classList.add("left__card");
    cards[currentIndex - 1].classList.remove("hidden__card");
    cards[currentIndex + 1].classList.add("right__card");
    cards[0].classList.remove("right__card");
    cards[0].classList.add("hidden__card");
  }
}
renderedCallback() {
  if (!this.initialized) {
    const cardsContainer = this.template.querySelector(".carousel_cards");
    const svg=this.template.querySelector(".overallscoreHover");
    const popupContainer=this.template.querySelector(".score-container");
    const a=this.template.querySelector(".info");
    const aContainer=this.template.querySelector(".sContainer");
    console.log("svg--",svg);
    console.log("cardsss--",cardsContainer);
    if (cardsContainer) {
      const cards = cardsContainer.querySelectorAll(".card4");
      if (cards.length > 0) {
        const leftCardHeading = cards[0]
          .querySelector(".headingContent1")
          .childNodes[1].nodeValue.trim();
        const rightCardHeading = cards[2]
          .querySelector(".headingContent1")
          .childNodes[1].nodeValue.trim();
        this.leftCardHeading = leftCardHeading;
        this.rightCardHeading = rightCardHeading;
        this.initialized = true;
      }
    }
    if(svg && popupContainer ){
     svg.addEventListener('mouseover', () => {
        svg.style.cursor = 'pointer';
        popupContainer.style.display = 'block';
    });

    // Add event listener to hide the popup on mouseout
    svg.addEventListener('mouseout', () => {
        popupContainer.style.display = 'none';
    });

         a.addEventListener('mouseover', () => {
        a.style.cursor = 'pointer';
        aContainer.style.display = 'block';
    });

    // Add event listener to hide the popup on mouseout
    a.addEventListener('mouseout', () => {
        aContainer.style.display = 'none';
    });
  }
  }
}

handleArrowClick(event) {
  const arrowDirection = event.currentTarget.dataset.direction;
  const cards = this.template.querySelectorAll(".carousel_cards .card4");
  let currentCardIndex;
  cards.forEach((card, index) => {
    if (
      (arrowDirection === "left" && card.classList.contains("left__card")) ||
      (arrowDirection === "right" && card.classList.contains("right__card"))
    ) {
      currentCardIndex = index;
    }
  });

  if (currentCardIndex !== undefined) {
    const totalCards = cards.length;
    const leftCardIndex = (currentCardIndex - 1 + totalCards) % totalCards;
    const rightCardIndex = (currentCardIndex + 1) % totalCards;

    const leftCardHeading = cards[leftCardIndex]
      .querySelector(".headingContent1")
      .childNodes[1].nodeValue.trim();
    const rightCardHeading = cards[rightCardIndex]
      .querySelector(".headingContent1")
      .childNodes[1].nodeValue.trim();

    this.leftCardHeading = leftCardHeading;
    this.rightCardHeading = rightCardHeading;
    console.log(`Left Card Heading:`, leftCardHeading);
    console.log(`Right Card Heading:`, rightCardHeading);
    const cardHeadingCaraousel = this.template.querySelector(
      ".cardHeadingCaraousel"
    );
    cardHeadingCaraousel.classList.add("animate");
  }
}
}