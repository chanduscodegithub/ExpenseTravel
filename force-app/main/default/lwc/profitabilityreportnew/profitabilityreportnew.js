/**
 * @description       : 
 * @author            : Ambika
 * @group             : 
 * @last modified on  : 04-30-2024
 * @last modified by  : Ambika
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-27-2024   Ambika   Initial Version
**/
// FetchProjectsLWC.js

import { LightningElement, wire, track,api } from 'lwc';
import getProjectss from '@salesforce/apex/profitabilitynewclass.getcalculatesummaryy';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import mystaticrsrce from '@salesforce/resourceUrl/NPlus'; 
import mystaticrsrces from '@salesforce/resourceUrl/NMinus';
import crmitLogo from '@salesforce/resourceUrl/Crmit_logo';
import accountingprd from '@salesforce/apex/Costbreakup.accountingperiodlist'; 
import getParentWrapperList from '@salesforce/apex/Costbreakup.getParentWrapperList';
import getcost from '@salesforce/apex/profitabilitynewclass.getcost';
//import accprd from '@salesforce/apex/costbreakupmonthwise.accountingperiodlist'; 
//import totalcostperhour from '@salesforce/apex/costbreakupmonthwise.totalcostperhour';




export default class profitabilityreportnew extends LightningElement {

  plusimage= mystaticrsrce;
   minusimage=mystaticrsrces;
   @api CrmitLogoo = crmitLogo;

  //  @wire(getProjects) projects
   @api fiscalyear;
 @track yearOptions = [];
  //overalldata=[];
   @track nestedMap = [];
 @track overalldata=[];
 @track data=[];
 @track ttlrevnue=0;
 @track ttlcost=0;
 @track ttlpftmagn;
 @track netprft=0;
 @track transformedData=[];
 @track showSecondTable = false;
 @track acctngprds;
 @track selectedmonth;
 startdate;
 enddate;
 @track costmargin=[];
  @track showSecondTables = false;
  @track selectedTabValue='';
  @track showmonthperiod = false;
  @track showyear = false;
  @track isLoading = false;
   @track isLoadings = false;
   @track  gettotalcostperhour = [];
  @track  monthly=false;
@track  costreport=false;
@track  summaryreoprt=false;
@track costtypespinner=false;
@track newaccprd;
@track costmargins=[];
@track costbymonth=false;




   
  
//  @wire(accprd)
//     accprd({data, error}){
//         if(data){
//           //  alert('inside>>>');
//            // this.acctngprds = data; 
//            this.newaccprd = data.map(item => ({ label: item.Name, value: item.Name }));
//          // this.acctngprds = this.acctngprds.filter(option => option.value !== 'None');
          
//            //this.acctngprds = [{ label: '--None--', value: 'None' }, ...data.map(item => ({ label: item.Name, value: item.Name }))];
//              console.log('slectedprd>>>' + JSON.stringify( this.acctngprds));
//         } else {
//             this.error = error;
//         }
//     }

   handleChanges(event) {
        this.selectedmonths = event.detail.value;
        console.log('this.selectedmonths>>>>'+this.selectedmonths);
          this.costbymonth=true;
        // Check if a month is selected
        if (this.selectedmonths && this.selectedmonths !== 'none') {
            // Assuming the selected month format is YYYY-MM
            const [year, month] = this.selectedmonths.split('-');
            
            // Create start date (assuming first day of the month)
            this.startdate = `${year}-${month}-01`;
            console.log('this.startdate>>>>>'+this.startdate);
            
            // Create end date (assuming last day of the month)
            const lastDay = new Date(year, month, 0).getDate();
            this.enddate = `${year}-${month}-${lastDay}`;
            console.log('this.enddate>>>>>'+this.enddate);
            this.costmargins = [];
            this.sendingmonthdatas()
        } else {
            // No month selected, set start and end dates to null or any default value
            this.startdate = null;
            this.enddate = null;
        }

        // Log the selected month, start date, and end date to the console
        console.log('this.selectedmonths: ' + this.selectedmonths);
        console.log('Start Date: ' + this.startdate);
        console.log('End Date: ' + this.enddate);
    }
 
 @wire(accountingprd)
    getaccprddata({data, error}){
        if(data){
           // this.acctngprds = data; 
           this.acctngprds = data.map(item => ({ label: item.Name, value: item.Name }));
         // this.acctngprds = this.acctngprds.filter(option => option.value !== 'None');
          
           //this.acctngprds = [{ label: '--None--', value: 'None' }, ...data.map(item => ({ label: item.Name, value: item.Name }))];
             console.log('accprd>>>' + JSON.stringify( this.acctngprds));
        } else {
            this.error = error;
        }
    }
    
handleChange(event) {
        this.selectedmonth = event.detail.value;
          this.isLoadings=true;
        // Check if a month is selected
        if (this.selectedmonth && this.selectedmonth !== 'none') {
            // Assuming the selected month format is YYYY-MM
            const [year, month] = this.selectedmonth.split('-');
            
            // Create start date (assuming first day of the month)
            this.startdate = `${year}-${month}-01`;
            
            // Create end date (assuming last day of the month)
            const lastDay = new Date(year, month, 0).getDate();
            this.enddate = `${year}-${month}-${lastDay}`;
            this.sendingmonthdata()
        } else {
            // No month selected, set start and end dates to null or any default value
            this.startdate = null;
            this.enddate = null;
        }

        // Log the selected month, start date, and end date to the console
        console.log('this.selectedmonth: ' + this.selectedmonth);
        console.log('Start Date: ' + this.startdate);
        console.log('End Date: ' + this.enddate);
    }

    handleMouseDown(event) {
        event.stopPropagation();
    }
sendingmonthdatas(){
//    //  alert('callingapex'); && (this.data['Grand Total'] && this.data['Grand Total']['Total'].Billabletotalhours !== 0
//   && this.data['Grand Total'] && this.data['Grand Total']['Total'].Billabletotalcost !== 0
//   && this.data['Grand Total'] && this.data['Grand Total']['Total'].NonBillabletotalhours !== 0
//   && this.data['Grand Total'] && this.data['Grand Total']['Total'].NonBillabletotalcost !== 0)
  totalcostperhour({startdate:this.startdate, enddate:this.enddate})
    .then(response =>{
       console.log('responsssss>>>' + JSON.stringify(response));
   this.data= response;
   
  if (this.data != null && this.data != undefined ){
    this.costmargins = [];
    this.costbymonth=false;
    for (const key in this.data) {
        const innerMap = this.data[key];
        const value = [];

        for (const innerKey in innerMap) {
            const innerValue = innerMap[innerKey];
            value.push({ key: innerKey, value: innerValue });
        }

        this.costmargins.push({ key, value });
    }
    console.log('this.costmargins >>>', JSON.stringify(this.costmargins));
} else {
    // Handle the scenario when data is not available
    this.costbymonth=false;
    this.showToast('No data available for this period', 'warning');
    this.costmargins = null;
    this.isLoadingss = false;
    // You can set a default value or take appropriate action here
}




    })
}

sendingmonthdata(){
  getParentWrapperList({startdate:this.startdate, enddate:this.enddate})
    .then(response =>{
    //  console.log('response123>>>' + response);

 //    this.costmargin= JSON.parse(response);   this.showToast('No data available for this period', 'warning');
 ///console.log('this.costmargin>>>' + JSON.stringify(this.costmargin));

//  let costmarginArray = Object.values(JSON.parse(response));
//  this.costmargin = costmarginArray;
//  console.log('this.costmargin>>>' + JSON.stringify(this.costmargin ));
   let costmarginArray = Object.values(JSON.parse(response));

      if (costmarginArray && costmarginArray.length > 0) {
             this.isLoadings = false;
                // Data is available, proceed with processing
                this.costmargin = costmarginArray;
                console.log('this.costmargin >>>' + JSON.stringify(this.costmargin));
            } else {
                // Data is not available, handle this scenario
               this.showToast('No data available for this period', 'warning');
               this.costmargin= null;
               this.isLoadings = false;
                // You can set a default value or take appropriate action here
            }


    })
}

gettotalcost() {
    getcost({ fiscalYear: this.fiscalyear })
    .then(response => {
        console.log('responsee>>>' + JSON.stringify(response));
        this.data = response;

        if (this.data != null && this.data != undefined && Object.keys(this.data).length !== 0) {
            this.gettotalcostperhour = [];

            // Define the order of the months
            const monthOrder = [
                "April", "May", "June", "July", "August", "September",
                "October", "November", "December", "January", "February", "March", "Total"
            ];

            // Iterate over billing statuses
            for (const key in this.data) {
                const value = [];

                // Add this line to track the "Total" row
                const sortedMonths = Object.keys(this.data[key]).sort((a, b) => monthOrder.indexOf(a) - monthOrder.indexOf(b));
                for (const innerKey of sortedMonths) {
                    value.push({ key: innerKey, value: this.data[key][innerKey] });
                }

                this.gettotalcostperhour.push({ key, value }); // Pass the isTotal flag
                this.costtypespinner = false;
                console.log('this.gettotalcostperhour>>>' + JSON.stringify(this.gettotalcostperhour));
            }
        } else {
            this.showToast('No data available for this fiscal year', 'warning');
            this.costtypespinner = false;
        }
    })
    .catch(error => {
        console.error('Error in getcost:', error);
        this.costtypespinner = false;
        // alert('Error fetching data. Please check the console for details.');
    });
}



apexcalling() {
   getProjectss({ fiscalYear: this.fiscalyear })
    .then(response => {
        this.data = response;
        console.log('data>>>' + JSON.stringify(this.data));

       // if (this.data !== null && Object.keys(this.data).length > 0) 
       if (this.data !== null && Object.keys(this.data).filter(key => key !== 'Totals').length > 0)
        {
            this.nestedMap = [];
            
            for (const key in this.data) {
                const value = [];
                let isTotal = false; // Add this line to track the "Total" row
                let isFirstAccountName = true;
                let isFirstprojectName = true;
                for (const innerKey in this.data[key]) {
                    const opportunity = this.data[key][innerKey];
        const accountName = opportunity["Accountname"];
        const projectname = opportunity["projectname"];

        // Set isFirstAccountName to true for the first occurrence of Accountname
        if (isFirstAccountName && accountName)  {
            opportunity.isFirstAccountName = true;
            isFirstAccountName = false;
        } else {
            opportunity.isFirstAccountName = false;
        }
        if (isFirstprojectName && projectname)  {
            opportunity.isFirstprojectName = true;
            isFirstprojectName = false;
        } else {
            opportunity.isFirstprojectName = false;
        }
                    
                    value.push({ key: innerKey, value: this.data[key][innerKey] });
                }
                this.nestedMap.push({ key, value, isTotal }); // Pass the isTotal flag
            }
                console.log('this.nestedMap>>>' + JSON.stringify(this.nestedMap));
               //  console.log('this.nestedMaps>>>' + JSON.stringify(this.nestedMap.Opptotalrev));

               const opportunityData = this.data;
               console.log('opp data' +opportunityData);

// Function to calculate the sum of ActualRevenue and TimeSheetCost for each account
       const calculateAccountSummary = (opportunityData) => {
  const accountSummary = [];

  for (const [opportunityKey, opportunities] of Object.entries(opportunityData)) {
    for (const [date, opportunity] of Object.entries(opportunities)) {
      const accountName = opportunity["Accountname"];
      const actualRevenue = opportunity["ActualRevenue"];
      const timeSheetCost = opportunity["TimeSheetCost"];
      const profitmargin = opportunity['ProfitMargin'];
      const projectname = opportunity['projectname'];

      
      if (accountName ) {

        const existingAccount = accountSummary.find((account) => account.AccountName === accountName);

        if (!existingAccount) {
          accountSummary.push({
            AccountName: accountName,
            ProjectName :projectname,
            TotalRevenue: 0,
            TotalTimeSheetCost: 0,
            Netprofit: 0,
            Opportunities: [],
          });
        }

        const currentAccount = accountSummary.find((account) => account.AccountName === accountName);
        const existingOpportunity = currentAccount.Opportunities.find((opp) => opp.OpportunityName === opportunity["OpportunityName"]);

        if (!existingOpportunity) {
          currentAccount.TotalRevenue += Math.round(actualRevenue);
          currentAccount.TotalTimeSheetCost += Math.round(timeSheetCost);
          currentAccount.ProfitMargin = calculateProfitMargin(currentAccount.TotalRevenue, currentAccount.TotalTimeSheetCost).toFixed(1);
          currentAccount.Netprofit = Math.round(currentAccount.TotalRevenue - currentAccount.TotalTimeSheetCost);

          currentAccount.Opportunities.push({
            ProjectName :projectname,
            OpportunityName: opportunity["OpportunityName"],
            ActualRevenue: Math.round(actualRevenue),
            TimeSheetCost: Math.round(timeSheetCost),
            Netprofit: Math.round(actualRevenue - timeSheetCost),
            ProfitMargin:calculateProfitMargin(actualRevenue, timeSheetCost).toFixed(1),
          });
        } else {
          existingOpportunity.ActualRevenue = (Math.round(existingOpportunity.ActualRevenue) + Math.round(actualRevenue));
          existingOpportunity.TimeSheetCost = (Math.round(existingOpportunity.TimeSheetCost) + Math.round(timeSheetCost));
          existingOpportunity.Netprofit = (Math.round(existingOpportunity.Netprofit) + Math.round(actualRevenue) - Math.round(timeSheetCost));
          existingOpportunity.ProfitMargin = calculateProfitMargin(existingOpportunity.ActualRevenue, existingOpportunity.TimeSheetCost).toFixed(1);

          currentAccount.TotalRevenue = Math.round(currentAccount.TotalRevenue + actualRevenue);
          currentAccount.TotalTimeSheetCost =Math.round(currentAccount.TotalTimeSheetCost + timeSheetCost);
          currentAccount.Netprofit=Math.round(currentAccount.TotalRevenue - currentAccount.TotalTimeSheetCost);
            currentAccount.ProfitMargin = calculateProfitMargin(currentAccount.TotalRevenue, currentAccount.TotalTimeSheetCost).toFixed(1);
        }
     }
    }
  }

  for (const account of accountSummary) {
    this.ttlrevnue += account.TotalRevenue;
    this.ttlcost += account.TotalTimeSheetCost;
  }

  accountSummary.sort((a, b) => a.AccountName.localeCompare(b.AccountName));

  this.netprft = Math.round(this.ttlrevnue - this.ttlcost);
  this.ttlpftmagn = ((this.ttlrevnue - this.ttlcost) / this.ttlrevnue * 100).toFixed(1);
  console.log('totalMargin',this.ttlpftmagn );
  if(isNaN(this.ttlpftmagn)|| this.ttlpftmagn == 'Infinity' || this.ttlpftmagn == '-Infinity'){
    console.log('inside if');
    this.ttlpftmagn = 0;
  }

  console.log('accountSummary>>>>', accountSummary);
  return accountSummary;
};



// Function to calculate profit margin
const calculateProfitMargin = (revenue, cost) => {
    let Revenue = Math.round(revenue);
     let Cost = Math.round(cost);
  console.log('1111111111111111111111revenue>>>'+Revenue);
  console.log('111111111111111111111111cost>>>'+Cost);

  // if (revenue === 0 || cost === 0) {
  //   return 0;
  // }
  let profitMargin = ((Revenue - Cost) / Revenue) * 100;
  console.log('pm' ,profitMargin);
  if(isNaN(profitMargin)|| profitMargin == 'Infinity' || profitMargin == '-Infinity'){
    console.log('inside if');
    profitMargin = 0;
  }
  return profitMargin
};

// Calculate the formatted data
this.transformedData = calculateAccountSummary(opportunityData);
this.isLoading = false;

// Now, 'formattedData' contains the data in the desired format
console.log('transformedData>>'+JSON.stringify(this.transformedData));

            } else {
             // alert('ytyytytyt')
                this.showToast('No data available for this fiscal year', 'warning');
                this.isLoading = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('error>>' + JSON.stringify(error));
            this.showToast('Error while fetching the data!', 'error');
            this.isLoading = false;
        });
}




showToast(msg, vrnt) {
         // Display a toast message
         const event = new ShowToastEvent({
             title: 'Warning',
             message: msg,
             variant: vrnt,
         });
         this.dispatchEvent(event);
    }

 connectedCallback() {
       const currentYear = new Date().getFullYear();
       for (let startYear = 2019; startYear <= currentYear; startYear++) {
    const endYear = startYear + 1;
    const yearRangeLabel = `${startYear}-${endYear}`;
    this.yearOptions.push({ label: yearRangeLabel, value: yearRangeLabel });
}
 }
 handleYearChange(event) {
   this.isLoading = true;
      //  console.log('Selected Year Before:', this.selectedYear);
        this.selectedYear =String(event.detail.value);
      //  console.log('Selected Year After:', this.selectedYear);
        this.fiscalyear = this.selectedYear;
       // console.log('this.fiscalyearsss>>>'+this.fiscalyear);
       this.ttlrevnue=0;
       this.ttlcost=0;
       this.netprft=0;
       this.ttlpftmagn=null;
       this.nestedMap = [];
        this.overalldata = [];
        this.transformedData=[];
       this.apexcalling(this.fiscalyear);
      // this.gettotalcost(this.fiscalyear);
    }
      
      handlcostcange(event) {
        this.costtypespinner=true;
        this.selectedYears =String(event.detail.value);
        this.fiscalyear = this.selectedYears;
        this.gettotalcostperhour=[];
        this.gettotalcost(this.fiscalyear);
    }



    toggleTable(event){
       // this.showTable = !this.showTable;
        const accountName = event.target.dataset.key;
         console.log('accountName>>'+accountName)
             const account = this.transformedData.find(acc => acc.AccountName === accountName);
                 if (account) {
            account.showSecondTable = !account.showSecondTable;
            //this.plusimage=this.minusimage;
        }
    }

     toggleTables(event){
       // this.showTable = !this.showTable;
        const oppname = event.target.dataset.key;
        console.log('oppname>>'+oppname)
             const ctmmrgn = this.costmargin.find(opp => opp.OpportunityName === oppname);
                 if (ctmmrgn) {
           ctmmrgn.showSecondTables = !ctmmrgn.showSecondTables;
           
        }
    }


    
  

    calculateDifference(Opptotalrev, Opptotalcost) {
        return Opptotalrev - Opptotalcost;
    }

//      exportData() {
//     if (this.transformedData.length === 0) {
//         this.showToast('No data available to export', 'warning');
//         return;
//     }






//     let csvContent = 'data:text/csv;charset=utf-8,';
    
//     // Add headers row
//     const headers = ['Account Name', 'Opportunity Name', 'Actual Revenue', 'TimeSheet Cost', 'Profit Margin', 'Net Profit'];
//     csvContent += headers.join(',') + '\n';

//     // Add data rows
//     this.transformedData.forEach(account => {
//         account.Opportunities.forEach(opportunity => {
//             const rowData = [
//                 account.AccountName,
//                 opportunity.OpportunityName,
//                 opportunity.ActualRevenue,
//                 opportunity.TimeSheetCost,
//                 opportunity.ProfitMargin,
//                 opportunity.Netprofit
//             ];
//             csvContent += rowData.join(',') + '\n';
//         });
//     });

//     // Create download link
//     const encodedUri = encodeURI(csvContent);
//     const link = document.createElement('a');
//     link.setAttribute('href', encodedUri);
//     link.setAttribute('download', 'profitability_report.csv');
//     document.body.appendChild(link);
//     link.click();
//     document.body.removeChild(link);
// }

exportData() {
    if (this.selectedTabValue === 'tab1') {
        this.exportSummaryData();
    } else if (this.selectedTabValue === 'tab2') {
        this.exportMonthlyRevenueData();
    } else if (this.selectedTabValue === 'tab3') {
        this.exportCostBreakupData();
    } else {
        this.showToast('No data available to export for the selected tab', 'warning');
    }
}
exportSummaryData(){
   if (this.transformedData.length === 0) {
        this.showToast('No data available to export', 'warning');
        return;
    }

    let totalRevenue = 0;
    let totalCost = 0;
    let totalNetProfit = 0;
    let totalNetMargin = 0;

    let doc = '<table>';
    doc += '<tr style="background-color: lightblue;"><th style="font-weight: bold;">ACCOUNT NAME</th><th style="font-weight: bold;">REVENUE</th><th style="font-weight: bold;">COST</th><th style="font-weight: bold;">NET PROFIT</th><th style="font-weight: bold;">PROFIT MARGIN</th></tr>';

    this.transformedData.forEach(account => {
        // Account details row
        doc += `<tr><td>${account.AccountName}</td><td>${account.TotalRevenue}</td><td>${account.TotalTimeSheetCost}</td><td>${account.Netprofit}</td><td>${account.ProfitMargin}</td></tr>`;

        // Update total revenue and total cost
        totalRevenue += Math.round(account.TotalRevenue);
        totalCost += Math.round(account.TotalTimeSheetCost);
        totalNetProfit += Math.round(account.Netprofit);
        totalNetMargin += parseFloat(account.ProfitMargin).toFixed(1);

        // Opportunity header row
        doc += '<tr style="background-color: lightblue;"><th style="font-weight: bold;">OPPORTUNITY NAME</th><th style="font-weight: bold;">ACTUAL REVENUE</th><th style="font-weight: bold;">TIME SHEET COST</th><th style="font-weight: bold;">NET PROFIT</th><th style="font-weight: bold;">PROFIT MARGIN</th></tr>';

        // Opportunity data rows
        account.Opportunities.forEach(opportunity => {
            doc += `<tr><td>${opportunity.OpportunityName}</td><td>${opportunity.ActualRevenue}</td><td>${opportunity.TimeSheetCost}</td><td>${opportunity.Netprofit}</td><td>${opportunity.ProfitMargin}</td></tr>`;
        });

        // Add a blank row after each account's opportunities
        doc += '<tr style="height: 10px;"></tr>'; // Adjust height as needed
    });

    doc += '</table>';

    // Total row
    doc += `<table><tr style="background-color: lightblue;"><th style="font-weight: bold;">TOTAL</th><th>${totalRevenue.toFixed(2)}</th><th>${totalCost.toFixed(2)}</th><th>${totalNetProfit.toFixed(2)}</th><th>${totalNetMargin.toFixed(1)}</th></tr></table>`;

    // Create download link
    const encodedUri = 'data:application/vnd.ms-excel;charset=utf-8,' + encodeURIComponent(doc);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', 'profitability_report.xls');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

exportCostBreakupData(){
 
    if (this.costmargin.length === 0) {
        this.showToast('No data available to export', 'warning');
        return;
    }

    let doc = '<table>';
    doc += '<tr style="background-color: lightblue;"><th style="font-weight: bold;">OPPORTUNITY NAME</th><th style="font-weight: bold;">PROJECT NAME</th><th style="font-weight: bold;">HOURS</th><th style="font-weight: bold;">COST</th></tr>';

    this.costmargin.forEach((costData, index) => {
        // Add a blank row before each opportunity starts, except for the first opportunity
        if (index > 0) {
            doc += '<tr style="height: 10px;"></tr>'; // Adjust height as needed
        }

        // Opportunity details row
        doc += `<tr><td>${costData.OpportunityName}</td><td>${costData.ProjectName}</td><td>${costData.Hours}</td><td>${costData.Cost}</td></tr>`;

        // Project header row
        doc += '<tr style="background-color: lightyellow;"><th style="font-weight: bold;">PROJECT NAME</th><th style="font-weight: bold;">RESOURCE NAME</th><th style="font-weight: bold;">HOURS</th><th style="font-weight: bold;">COST/HR</th><th style="font-weight: bold;">AMOUNT</th></tr>';

        // Project data rows
        costData.childList.forEach(project => {
            doc += `<tr><td>${project.ProjectName}</td><td>${project.ResourceName}</td><td>${project.Hours}</td><td>${project.costperemplyi}</td><td>${project.Cost}</td></tr>`;
        });
    });

    doc += '</table>';

    // Create download link
    const encodedUri = 'data:application/vnd.ms-excel;charset=utf-8,' + encodeURIComponent(doc);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', 'opportunities_and_projects_report.xls');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

@api nestedMap;

// Getter method to retrieve the account name
get accountName() {
    if (this.nestedMap && this.nestedMap.length > 0 && this.nestedMap[0].value.length > 0) {
        return this.nestedMap[0].value[0].value.Accountname;
    }
    return '';
}

exportMonthlyRevenueData(){
    
if (this.nestedMap.length === 0) {
        this.showToast('No data available to export', 'warning');
        return;
    }

    let doc = '<table>';
    
   // doc += '</table>';

 doc += '<tr><th>Opportunity Name</th><th>Account Name</th>';

    // Add headers for each month
    const months = ['April', 'May', /* Add more months here if needed */];
    months.forEach(month => {
        doc += `<th>${month} Revenue</th><th>${month} Cost</th><th>${month} Net Profit</th><th>${month} Profit Margin</th>`;
    });
    doc += '</tr>';

    // Add data rows for each opportunity
    this.nestedMap.forEach(mapData => {
        doc += `<tr><td>${mapData.key}</td><td>${mapData.value[0].Accountname}</td>`;
        months.forEach(month => {
            const dataForMonth = mapData.value.find(item => item.month === month);
            if (dataForMonth) {
                doc += `<td>${dataForMonth.revenue}</td><td>${dataForMonth.cost}</td><td>${dataForMonth.netprofit}</td><td>${dataForMonth.profitmargin}</td>`;
            } else {
                doc += '<td></td><td></td><td></td><td></td>';
            }
        });
        doc += '</tr>';
    });

    

    doc += '</table>';
    console.log('nested map is'+this.nestedMap);

    // Create download link
    const encodedUri = 'data:application/vnd.ms-excel;charset=utf-8,' + encodeURIComponent(doc);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', 'monthly_revenue_report.xls');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
}
handleCheckboxChange(event) {
    const isChecked = event.target.checked;
    this.transformedData.forEach(account => {
        account.isChecked = isChecked;
        
        account.showSecondTable = isChecked;
    });
    this.transformedData = [...this.transformedData];
}

expandCostBreakUp(event) {
    const isChecked = event.target.checked;
    this.costmargin.forEach(item => {
        item.showSecondTables = isChecked;
    });
}


 
handleTabChange(event) {
  console.log('tetsingggg>>>>')
        this.selectedTabValue = event.target.value;
        console.log('Selected Tab Value:', this.selectedTabValue);
        if(this.selectedTabValue ==='tab1'){
         this.summaryreoprt=true;
         this.monthly=false;
         this.costreport=false;
         this.showmonthperiod=false;
          this.showmonthperiodcost=false;
         return;
        }if(this.selectedTabValue ==='tab2'){
         this.monthly=true;
         this.costreport=false;
         this.showmonthperiod=false;
         this.summaryreoprt=false;
          this.showmonthperiodcost=false;
            return;
        }if(this.selectedTabValue ==='tab3'){
         this.showmonthperiod=true;
         this.summaryreoprt=false;
         this.monthly=false;
         this.costreport=false;
          this.showmonthperiodcost=false;
            return;
        }if(this.selectedTabValue ==='tab4'){
         this.costreport=true;
         this.showmonthperiod=false;
         this.summaryreoprt=false;
         this.monthly=false;
         this.showmonthperiodcost=false;
            return;
        }if(this.selectedTabValue ==='tab5'){
          this.showmonthperiodcost=true;
         this.costreport=false;
         this.showmonthperiod=false;
         this.summaryreoprt=false;
         this.monthly=false;
            return;
             
    }
             
    }
     


   }