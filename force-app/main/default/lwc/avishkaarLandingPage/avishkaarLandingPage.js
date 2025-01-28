import { LightningElement, track,wire } from 'lwc';
// import awards_rewards from '@salesforce/apex/AwardsAndRewards.rewardsMethod';
import getAwardDetailsOfEmp from '@salesforce/apex/AwardsAndRewards.getAwardDetailsOfEmp';
import getHolidayList from '@salesforce/apex/AwardsAndRewards.getHolidayList';
//import getHolidayList from '@salesforce/apex/HolidayHandler.getHolidays';
import getRewardsList from '@salesforce/apex/AwardsAndRewards.getRewardsList';
import { getRecord } from 'lightning/uiRecordApi';
import getBannerText from '@salesforce/apex/AwardsAndRewards.getBannerText';
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
import AvishkaarHomeImage from '@salesforce/resourceUrl/AvishkaarHomeImage';
import avatar_image from '@salesforce/resourceUrl/avatar';
import whiteIcon from '@salesforce/resourceUrl/Crmit';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';
const awardsFields = ['	Name', 'Awards__c', 'Months__c', 'Rewards__c'];
const Email = 'User.Email';
import { CurrentPageReference } from 'lightning/navigation';
import {NavigationMixin} from "lightning/navigation";

const LOGOUTPAGEREF = {
    type: "comm__loginPage",
    attributes: {
          actionName: "login"
    }
};

export default class AvishkaarLandingPage extends LightningElement {
    @track AwardeArray;
    @track holidayArray;
    @track rewardeArray;
    @track isSpinner;
    @track userProfile;
    @track showProgramBtn=false;
    showModal=true;
    birthdayArray=[];
    currentStep = 1;  // Step 1 or Step 2
    disableButtons = true; // Buttons disabled until scrolled
    scrolledToBottom = false; // Track if scrolled to the bottom

    @track selectedValue = '';
    currentUserEmail;

    BannerTxt;
    whiteIcon = whiteIcon;
    tooltipVisible = false;

    get tooltipClass() {
        return this.tooltipVisible ? 'visible' : 'tooltiptext';
    }

    toggleTooltip(event) {
        event.stopPropagation(); 
        this.tooltipVisible = !this.tooltipVisible;
        console.log('Tool TIp',this.tooltipClass,this.tooltipVisible);
    }

    get options() {
        return [
            { label: 'INDIA - Bangalore', value: 'IND' },
            { label: 'INDIA - Jaipur', value: 'IND' },
            { label: 'USA', value: 'US' },
            { label: 'ANZ - Sydney', value: 'ANZ' },
            { label: 'ANZ - Melbourne', value: 'ANZ - Melbourne' }
           

        ];
    };

        get isStepOne() {
        return this.currentStep === 1;
    }

    get isStepTwo() {
        return this.currentStep === 2;
    }

    // Dynamic header for the modal
    get modalHeader() {
        return this.currentStep === 1 ? 'Important Notice' : 'Addendum';
    }

    // Navigate to Addendum (Step 2)
    goToAddendum() {
        this.currentStep = 2;
    }

    // Handle scroll event in the addendum
    handleScroll(event) {
        const element = event.target;
        console.log('elementScroll',element);
        this.scrolledToBottom = element.scrollHeight - element.scrollTop === element.clientHeight;
        this.disableButtons=!this.scrolledToBottom;
        console.log("thisScrolledBottom",this.scrolledToBottom);

    }

    // Handle Accept button click
    handleAccept() {
        this.showModal = false; // Close the modal
        // Additional logic if needed (e.g., save user acceptance)
    }

    handleReject() {
        const communityDomain = 'https://sftd1--pms.sandbox.my.site.com'; // Make sure to replace this with your correct community domain
        const loginPage = '/CRMITCommunity/s/login'; // Make sure to replace this with your login page URL path
        const logoutUrl = `${communityDomain}/CRMITCommunity/secur/logout.jsp?retUrl=${encodeURIComponent(communityDomain + loginPage)}`;

        // Debugging: check the logout URL
        console.log('Logout URL:', logoutUrl);

        // Perform the redirect to the logout URL
        window.location.replace(logoutUrl);
    }



    handleDocumentClick(event) {
        const tooltipElement = this.template.querySelector('.tooltip');
        if (this.tooltipVisible && tooltipElement && !tooltipElement.contains(event.target)) {
            this.tooltipVisible = false;
        }
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleDocumentClick.bind(this));
    }

    handleChangeRegion(event) {
        this.selectedValue = event.target.value;
    }

    handleClickStarAwards(){
        window.open('https://sftd1--pms.sandbox.my.site.com/CRMITCommunity/s/star-awards');
    }

    @wire(getRecord, { recordId: Id, fields: [ProfileName,Email] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
            console.log( 'this.error', this.error);
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                const specificUserEmails = [
                    'psomnath@crmit.com',
                    'amruta.nayak@crmit.com',
                    'psrinivas@crmit.com',
                    'plokeshbabu@crmit.com',
                    'dinesh.poduval@crmit.com'
                ];
                const currentUserEmail = data.fields.Email.value;
                if(this.userProfileName=='Partner Community Login User_Full Access' || this.userProfileName=='Partner Community Login User_HR Manager'|| this.userProfileName=='Partner Community Login User_Manager'||this.userProfileName=='Partner Community Login User_TA_Manager' || this.userProfileName=='Partner Community Login User_Delivery' ||  specificUserEmails.includes(currentUserEmail) )
                {
                 this.showProgramBtn=true;
                }
                else{
                    this.showProgramBtn=false;
                }
            }
        }
    }

    // fetchLogoutUrl() {
    //     getLogoutUrl()
    //         .then((url) => {
                 
    //             let cleanedUrl = url.replace(/([&?])retUrl=[^&]*/, '');
    //             // Your base community domain
    //             const baseUrl = 'https://sftd1--pms.sandbox.my.site.com';
    //             this.logoutUrl = `${baseUrl}${cleanedUrl}?retUrl=${encodeURIComponent('https://sftd1--pms.sandbox.my.site.com/CRMITCommunity/s/login')}`;
    //             console.log('Logout URL:', this.logoutUrl);
    //         })
    //         .catch((error) => {
    //             console.error('Error fetching logout URL:', error);
    //         });
    // }

    fetchLogoutUrl() {
        this.logoutUrl = '/CRMITCommunity/secur/logout.jsp?retUrl=' +
        encodeURIComponent('https://sftd1--pms.sandbox.my.site.com/CRMITCommunity/s/login');
    }


    connectedCallback() {
        this.fetchLogoutUrl();
        document.addEventListener('click', this.handleDocumentClick.bind(this));
        getAwardDetailsOfEmp()
            .then(result => {
                this.isSpinner = false;
                this.AwardeArray = [];
                result.forEach(ele => {
                    var eachObj = { ...ele };// Spread Operator;
                    if (ele.Name.includes("Preformer")) {
                        eachObj.imgsource = AvishkaarHomeImage + '/RedDecorMedal.png';
                    }
                    else if (ele.Name.includes("Superstar")) {
                        eachObj.imgsource = AvishkaarHomeImage + '/GreenDecorMedal.png';
                    }
                    else if (ele.Name.includes("Sherpa")) {
                        eachObj.imgsource = AvishkaarHomeImage + '/GoldDecorMedal.png';
                    }
                    this.AwardeArray.push(eachObj);
                })
            })
            .catch(error => {
                console.log('Error Occured', error.message);
            });


        /*getHolidayList()
            .then(result => {
                this.holidayArray = [];
                result.forEach(ele => {
                    var eachObj = { ...ele };
                    if (ele.Holiday_Type__c == 'Restricted Holiday') {
                        eachObj.Is_Restricted_Holiday__c = true
                    }
                    this.holidayArray.push(eachObj);
                })

            })
            .catch(error => {
                console.log('Error Occured');
            });*/

        getRewardsList()
            .then(result => {
                //console.log('this.rewardeArray : '+JSON.stringify(result));
                this.rewardeArray = result;
                console.log('this.rewardeArray',this.rewardeArray);
            })
            .catch(error => {
                console.log('Error Occured');
            });
            
        getBannerText()
            .then(result => {
                this.BannerTxt = result;
                //console.log(this.BannerTxt);
            })
            .catch(error => {
                console.log('Error Occured');
            });
    }

    navigateToAllPrograms(event) {
        let currentUrl = window.location.href;
        let urlParts = currentUrl.split('/s/');
        let newUrl = urlParts[0] + '/s/training-program/Training_Program__c/Default?Training_Program__c-filterId=All_Training_Programss'; // Adjust as needed
        window.open(newUrl, "_self");
    }

    navigateToUpcomingSessions(event){

        let currentUrl = window.location.href;
        let urlParts = currentUrl.split('/s/');
        let newUrl = urlParts[0] + '/s/training-session/Training_Session__c/Default?Training_Session__c-filterId=00BKk000001UTntMAG';
        window.open(newUrl, "_self");
    }

    navigateToMyPrograms(event){

        let currentUrl = window.location.href;
        let urlParts = currentUrl.split('/s/');
        let newUrl = urlParts[0] + '/s/training-program/Training_Program__c/Default?Training_Program__c-filterId=All'; // Adjust as needed
        window.open(newUrl, "_self");

    }

    @wire(getHolidayList, { region: '$selectedValue' })
    wiredHolidayList(values) {
        const { data, error } = values;
        if (data) {
            this.holidayArray = [];
            data.forEach(ele => {
                var eachObj = { ...ele };
                if (ele.Holiday_Type__c == 'Restricted Holiday') {
                    eachObj.Is_Restricted_Holiday__c = true
                }
                this.holidayArray.push(eachObj);
            })
        } else if (error) {
            console.log('error:::' + JSON.stringify(error));
        }
    }

}