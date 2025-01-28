import { LightningElement, track,wire } from 'lwc';
// import awards_rewards from '@salesforce/apex/AwardsAndRewards.rewardsMethod';
import getAwardDetailsOfEmp from '@salesforce/apex/AwardsAndRewards.getAwardDetailsOfEmp';
import getHolidayList from '@salesforce/apex/AwardsAndRewards.getHolidayList';
//import getHolidayList from '@salesforce/apex/HolidayHandler.getHolidays';

import getRewardsList from '@salesforce/apex/AwardsAndRewards.getRewardsList';
import getBannerText from '@salesforce/apex/AwardsAndRewards.getBannerText';
import AvishkaarHomeImage from '@salesforce/resourceUrl/AvishkaarHomeImage';
import whiteIcon from '@salesforce/resourceUrl/Crmit';
const awardsFields = ['	Name', 'Awards__c', 'Months__c', 'Rewards__c'];
export default class AvishkaarLandingPageContracters extends LightningElement {
    @track AwardeArray;
    @track holidayArray;
    @track rewardeArray;
    @track isSpinner;

    @track selectedValue = '';

    BannerTxt;
    whiteIcon = whiteIcon;

    get options() {
        return [
            { label: 'India', value: 'IND' },
            { label: 'USA', value: 'US' },
            { label: 'Australia', value: 'ANZ' }
        ];
    };

    handleChangeRegion(event) {
        this.selectedValue = event.target.value;
    }


    connectedCallback() {
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