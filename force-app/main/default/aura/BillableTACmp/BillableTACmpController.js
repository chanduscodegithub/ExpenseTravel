({
    doInit : function(component, event, helper) {
        
        component.set('v.columns', [
            {label: 'Employee Name', fieldName: 'empURL', type: 'url',
             typeAttributes: { label: {
                     fieldName: 'empName'
                 }}, target: '_blank'},
           
            {label: 'Allocation Percentage(%)', fieldName: 'allocationPercentage', type: 'text'},
            {label: 'Billable Hours Allocated', fieldName: 'Billable_Hours_Allocated__c', type: 'number'},
            {label: 'End Date', fieldName: 'EndDate__c', type: 'date',typeAttributes:{
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            } }]);
        var billTAList = component.get("v.billableTAList");
        if(billTAList != null){
            var noOfPages =Math.floor((billTAList.length)/component.get('v.pagesize'));
            if (noOfPages==0)
                noOfPages = noOfPages+1;
            //console.log("noOfPages=="+noOfPages);
            component.set("v.maxpage",noOfPages);
            // console.log("---------------"+billTAList);
            helper.renderPage(component);
        }
    },
   
    renderPage : function(component, event, helper) {
        helper.renderPage(component);
    }
})