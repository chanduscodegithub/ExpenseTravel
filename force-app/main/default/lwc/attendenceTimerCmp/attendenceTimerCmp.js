import { LightningElement, track, wire } from 'lwc';
import attendenceTimerData from "@salesforce/apex/attendenceTimerCmpCtrl.getLoginDetails";
import updateCheckInOut from "@salesforce/apex/attendenceTimerCmpCtrl.updateCheckInOut";
import employeDetails from "@salesforce/apex/attendenceTimerCmpCtrl.employeDetails";
import getEmpDetails from "@salesforce/apex/attendenceTimerCmpCtrl.getEmpDetails";
import { refreshApex } from '@salesforce/apex';
import Id from "@salesforce/user/Id";
import formFactorPropertyName from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getLocationService } from 'lightning/mobileCapabilities';

export default class AttendenceTimerCmp extends LightningElement {
    @track checkInFlag;
    @track takeCurrentTime = false;

    @track curhour = '00';
    @track curmin = '00';
    @track cursec = '00';

    @track currentDetails = {};
    @track lastLoginDetails = {};

    @track currentDayNameAbbreviation;
    @track currentDay;
    @track currentTime;
    @track browserDetails = false;

    @track spinner = false;

    @track accessToCurtainUser = false;
    @track formFactor = formFactorPropertyName;



    intervalId;
    @track refreshCurrentDetails;
    attendanceId;
    userId = Id;

    //geo location
    lstMarkers = [];
    zoomlevel = "1";
    currentDate;

    //search employee tracks list
    @track isSearchLoading = false;
    @track empList;
    @track isModalOpen = false;
    @track isModalOpenConfirm = false;
    @track selectedRecId;
    @track reportingManager;
    @track costcenterManager;
    @track empDesignation;

    @track searchResult;
    @track timezone;

    @track disableWfa = true;
    commmunityURL = 'https://sftd1.my.site.com/CRMITCommunity/s/';

    //ind to aus
    hour;
    min;

    connectedCallback() {
        this.timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
        //this.timezone = 'Australia/Sydney';
        console.log('Time Zone Preference in Salesforce ORG :' + this.timezone);

        getEmpDetails({})
            .then(result => {
                if (result === true) {
                    this.disableWfa = true;
                } else {
                    this.disableWfa = false;
                }
            }).catch(error => {
                console.log('error::' + error);
                this.disableWfa = true;
            })
        //console.log('navigator::' + this.browserDetails);
        /*if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;

                // Add Latitude and Longitude to the markers list.
                this.lstMarkers = [{
                    location: {
                        Latitude: latitude,
                        Longitude: longitude
                    },
                    title: 'You are here'
                }];
                this.zoomlevel = "4";
            });
        }*/
        if (this.timezone === 'Australia/Sydney') {
            this.offIndToAus();
        }

        this.updateCurrentTime();
        this.updateCurrentDay();
        setInterval(() => {
            this.updateCurrentTime();
            this.updateCurrentDay();
        }, 1000);
    }

    updateCurrentDay() {
        this.currentDate = new Date();
        if (this.timezone !== 'Asia/Calcutta') {
            var oldcurDate = new Date().toLocaleString("en-US", { timeZone: this.timezone });
            this.currentDate = new Date(oldcurDate);
        }
        //this.currentDay = this.currentDate.getDay().toString().padStart(2, '0') + '-' + this.currentDate.getMonth().toString().padStart(2, '0') + '-' + this.currentDate.getFullYear();
        const options = { weekday: 'long' };
        this.currentDayNameAbbreviation = this.currentDate.toLocaleDateString('en-US', options).slice(0, 3);

        this.currentDay = this.currentDate.toLocaleDateString('en-GB', {
            day: 'numeric', month: 'short', year: 'numeric'
        }).replace(/ /g, '-');
        //this.currentDayNameAbbreviation = presentDay.slice(0, 3);*/
    }

    updateCurrentTime() {
        var todayDate = new Date();
        if (this.timezone !== 'Asia/Calcutta' && this.timezone !== 'Australia/Sydney') {
            var oldcurDate = new Date().toLocaleString("en-US", { timeZone: this.timezone });
            todayDate = new Date(oldcurDate);
        }
        if (this.timezone === 'Australia/Sydney') {
            //var oldcurDate = new Date().toLocaleString("en-AU", { timeZone: this.timezone });
            //todayDate = new Date(oldcurDate);
            todayDate = new Date();
            //todayDate = new Date(todayDate.getTime() + (5 * 60 * 60 * 1000 + 30 * 60 * 1000));
        }
        this.currentTime = todayDate.getHours().toString().padStart(2, '0') + ':' + todayDate.getMinutes().toString().padStart(2, '0');
    }

    @wire(attendenceTimerData)
    getWiredResult(values) {
        this.refreshCurrentDetails = values;
        const { data, error } = this.refreshCurrentDetails;
        if (data === null) {
            this.checkInFlag = true;
            return;
        }
        if (data) {
            if (data.Action_Type__c === 'Check Out' && data.Attendance__r.Duration_In_Min_Date_and_Time__c != null) {
                this.attendanceId = data.Attendance__c;
                this.curhour = data.Attendance__r.Duration_In_Min_Date_and_Time__c.split(":")[0].padStart(2, '0');
                this.curmin = data.Attendance__r.Duration_In_Min_Date_and_Time__c.split(":")[1].padStart(2, '0');
                this.cursec = data.Attendance__r.Duration_In_Min_Date_and_Time__c.split(":")[2].padStart(2, '0');
                this.checkInFlag = true;
            } else if (data.Action_Type__c === 'Check Out' && data.Attendance__r.Duration_In_Min_Date_and_Time__c == null) {
                this.attendanceId = data.Attendance__c;
                this.checkInFlag = true;
            } else if (data.Action_Type__c === 'Check In') {
                this.spinner = true;
                this.attendanceId = data.Attendance__c;
                var curDate = new Date();
                //console.log('FirstCheckIn::::'+data.Attendance__r.First_Check_In_Date_and_Time__c);
                var lastdate = new Date(data.Attendance__r.First_Check_In_Date_and_Time__c);
                if (this.timezone !== 'Asia/Calcutta' && this.timezone !== 'Australia/Sydney') {
                    var oldcurDate = new Date().toLocaleString("en-US", { timeZone: this.timezone });
                    curDate = new Date(oldcurDate);
                    var lastCheckInTime = lastdate.toLocaleString("en-US", { timeZone: 'Asia/Calcutta' });
                    lastdate = new Date(lastCheckInTime);
                }
                if (this.timezone === 'Australia/Sydney') {
                    if (this.hour === undefined || this.min === undefined) {
                        this.offIndToAus();
                    }
                    /*
                    var ausTime = new Date().toLocaleString("en-AU", { timeZone: 'Australia/Sydney' });
                    curDate = new Date(ausTime);*/

                    const finalString = data.Attendance__r.First_Check_In_Date_and_Time__c.replace('T', ' ').replace('Z', '');
                    var dateObj = new Date(finalString);
                    //lastdate = new Date(dateObj.getTime() + ((this.hour !== undefined ? this.hour : 5) * 60 * 60 * 1000 + (this.min !== undefined ? this.min : 5) * 60 * 1000));
                    lastdate = new Date(dateObj.getTime() + (this.hour * 60 * 60 * 1000 + this.min * 60 * 1000));
                    //console.log('lastdate::' + lastdate); // Adding 10 hours
                }
                const result = this.minutesDiff(lastdate, curDate);
                this.timeConvert(result);
                if (parseInt(this.curhour) < 15) {
                    this.updateClock();
                    this.spinner = false;
                    this.setIntervalFunc();
                    this.checkInFlag = false;
                } else {
                    this.spinner = false;
                    this.curhour = '00';
                    this.curmin = '00';
                    this.cursec = '00';
                    this.checkInFlag = true;
                }

            }

        } else if (error) {
            console.log('errorhi::' + JSON.stringify(error));
            this.disableWfa = true;
        }
    }

    handleRefreshView() {
        window.open(this.commmunityURL, "_self");
        //return refreshApex(this.refreshCurrentDetails);
    }

    setIntervalFunc() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
        var intId = setInterval(() => {
            if (this.checkInFlag) {
                clearInterval(this.intervalId);
            } else {
                this.updateClock();
            }
        }, 1000);
        this.intervalId = intId;

    }

    offIndToAus() {
        const indiaTimeZone = 'Asia/Kolkata';
        const australiaTimeZone = 'Australia/Sydney';
        const indiaTime = new Date().toLocaleString('en-US', { timeZone: indiaTimeZone });
        const australiaTime = new Date().toLocaleString('en-US', { timeZone: australiaTimeZone });
        const indiaDateTime = new Date(indiaTime);
        const australiaDateTime = new Date(australiaTime);
        const timeDiff = australiaDateTime - indiaDateTime;
        this.hour = Math.floor(timeDiff / 3600000); // 1 hour = 3600000 milliseconds
        this.min = Math.floor((timeDiff % 3600000) / 60000);
    }

    handlePopupConfirm() {
        this.isModalOpenConfirm = true;
    }

    hideModalBox() {
        this.isModalOpenConfirm = false;
    }

    handleCheckInOut() {
        this.isModalOpenConfirm = false;
        if (this.formFactor === 'Small' || this.formFactor === 'Medium') {
            this.toastEventFire('Check In/Check Out is disabled', 'Check In Or Check Out Disabled in mobile and Tab', 'error');
            return;
        }

        if (this.disableWfa === true) {
            this.toastEventFire('Check In/Check Out is disabled', 'Check In Or Check Out Disabled', 'error');
            return;
        }

        if (this.spinner == true) {
            return;
        }
        this.spinner = true;

        this.checkInFlag = !this.checkInFlag;

        var currenDateTime = new Date();
        const activityResult = {};

        if (this.attendanceId != undefined) {
            activityResult.Attendance__c = this.attendanceId;
        }

        if (this.checkInFlag === false) {
            this.updateClock();
            this.setIntervalFunc();
            activityResult.Mode__c = 'Online';
            activityResult.Action_Time__c = currenDateTime.getHours() + ':' + currenDateTime.getMinutes() + ':' + currenDateTime.getSeconds() + '.' + currenDateTime.getMilliseconds().toString().padStart(3, '0') + 'Z';
            activityResult.Action_Type__c = 'Check In';
        } else {
            activityResult.Mode__c = 'Online';
            activityResult.Action_Time__c = currenDateTime.getHours() + ':' + currenDateTime.getMinutes() + ':' + currenDateTime.getSeconds() + '.' + currenDateTime.getMilliseconds().toString().padStart(3, '0') + 'Z';
            activityResult.Action_Type__c = 'Check Out';
        }

        updateCheckInOut({ atdId: (this.attendanceId != undefined ? this.attendanceId : null), attendenceActivity: JSON.stringify(activityResult) })
            .then(result => {
                this.spinner = false;
                if (result !== 'success') {
                    this.attendanceId = result;
                }
                if (result === 'Record Exist') {
                    this.toastEventFire('Record Already Exist', 'For Today Your Record Already Exist PLease Check My Attendence', 'error');
                    return;
                } if (result === 'access denied') {
                    this.toastEventFire('Check In/Check Out is disabled', 'Check In Or Check Out Disabled', 'error');
                    return;
                }
                refreshApex(this.refreshCurrentDetails);

            }).catch(error => {
                console.log(error);
                this.spinner = false;
                if (error === 'Employee dont have a access') {
                    this.toastEventFire('Check In/Check Out is disabled', 'Check In Or Check Out Disabled', 'error');
                    return;
                } else {
                    this.toastEventFire('Opps Failed To Create Record', 'Opps Failed To Create Record Please Check Admin', 'error');
                    return;
                }
            })
    }

    padTo2Digits(num) {
        return num.toString().padStart(2, '0');
    }

    padInteger(num) {
        return parseInt(num);
    }


    msToTime(duration) {
        var milliseconds = Math.floor((duration % 1000) / 100),
            seconds = Math.floor((duration / 1000) % 60),
            minutes = Math.floor((duration / (1000 * 60)) % 60),
            hours = Math.floor((duration / (1000 * 60 * 60)) % 24),

            hours = (hours < 10) ? "0" + hours : hours;
        minutes = (minutes < 10) ? "0" + minutes : minutes;
        seconds = (seconds < 10) ? "0" + seconds : seconds;
        return hours + ":" + minutes + ":" + seconds + "." + milliseconds;
    }




    updateClock() {

        var hour = this.padInteger(this.curhour);
        var minute = this.padInteger(this.curmin);
        var second = this.padInteger(this.cursec);

        if (second === 59) {
            second = 0;
        } else {
            second += 1;
        }

        if (second === 0) {
            if (minute === 59) {
                minute = 0;
            } else {
                minute += 1;
            }
        }

        if (minute === 0 && second === 0) {
            hour += 1;
            if (hour === 15) {
                this.checkInFlag = true;
                refreshApex(this.refreshCurrentDetails);
            }
        }

        this.curhour = this.padTo2Digits(hour);
        this.curmin = this.padTo2Digits(minute);
        this.cursec = this.padTo2Digits(second);

    }


    minutesDiff(dateTimeValue1, dateTimeValue2) {
        var differenceValue = (dateTimeValue2.getTime() - dateTimeValue1.getTime()) / 1000;
        differenceValue /= 60;
        return Math.abs(Math.round(differenceValue));
    }

    timeConvert(min) {
        var num = min;
        var hours = (num / 60);
        var rhours = Math.floor(hours);
        var minutes = (hours - rhours) * 60;
        var rminutes = Math.round(minutes);
        var rsecounds = Math.round((rminutes % 1) * 100);
        this.curhour = this.padTo2Digits(rhours);
        this.curmin = this.padTo2Digits(rminutes);
        this.cursec = this.padTo2Digits(rsecounds);
    }

    //employee handle seach

    handleEmployeeSearch(event) {
        this.searchResult = event.target.value;
        this.isSearchLoading = true;
        //console.log('event.target.value:::' + event.target.value.length);
        if (event.target.value.length === 0) {
            //console.log('event.target.value2:::' + event.target.value);
            this.empList = undefined;
            this.isSearchLoading = false;
            //console.log('event.target.value2:::' + JSON.stringify(this.empList));
            return;
        }
        //console.log('event.target.value3:::' + event.target.value);

        employeDetails({ empName: event.target.value })
            .then(result => {
                //console.log('result:::' + JSON.stringify(this.empList));
                this.empList = result;
                this.isSearchLoading = false;
                if (this.searchResult.length === 0) {
                    this.empList = undefined;
                }

            }).catch(error => {
                console.log('error:::' + error);
                this.empList = undefined;
            })
    }

    closeModal() {
        this.isModalOpen = false;
        this.empList = undefined;
    }

    handelSelectedRecord(event) {
        var index = event.target.getAttribute('data-recid');
        this.selectedRecId = this.empList[index].Id;

        this.empDesignation = this.empList[index]?.Designation__r.Name;
        this.reportingManager = this.empList[index]?.ReportingTo__c != undefined ? this.empList[index].ReportingTo__r?.Name : '';
        this.costcenterManager = this.empList[index]?.BU_Head__c != undefined ? this.empList[index].BU_Head__r?.Name : '';

        this.isModalOpen = true;
        this.searchResult = undefined;
    }

    toastEventFire(title, msg, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'dismissable',
        });
        this.dispatchEvent(toastEvent);
    }

}