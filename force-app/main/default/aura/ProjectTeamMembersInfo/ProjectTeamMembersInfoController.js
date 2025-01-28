({
    doInit: function (component, event, helper) {
        helper.getCommunityUrl(component);
        var action = component.get('c.getTeamMembers');
        action.setParams({ ProjectId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tmListWrapper = response.getReturnValue();

                // Initialize categorized lists
                var billableActive = [], billableYetToAssign = [], billableCompleted = [];
                var nonBillableActive = [], nonBillableYetToAssign = [], nonBillableCompleted = [];
 				var avishkaarActive = [], avishkaarYetToAssign = [], avishkaarCompleted = [];

                var today = new Date();

                // Categorize Billable Members
                if (tmListWrapper.billableTAList != null) {
                    tmListWrapper.billableTAList.forEach(row => {
                        if (row.EmployeeName__c) {
                            row.empName = row.EmployeeName__r.Name;
                            row.empURL = component.get("v.communityUrl")
                                ? `${component.get("v.communityUrl")}/s/employee/${row.EmployeeName__c}`
                                : `/${row.EmployeeName__c}`;
                        }
                        row.reporterName = row.ReportingTo__r ? row.ReportingTo__r.Name : '';
                        row.allocationPercentage = row.AllocationPercentage__c ? row.AllocationPercentage__c + '%' : '';

                        // Categorization logic
                        if (row.StartDate__c && new Date(row.StartDate__c) > today) {
                            billableYetToAssign.push(row);
                        } else if (row.EndDate__c && new Date(row.EndDate__c) < today) {
                            billableCompleted.push(row);
                        } else {
                            billableActive.push(row);
                        }
                    });
                }

                // Categorize Non-Billable Members
                if (tmListWrapper.nonBillableTAList != null) {
                    tmListWrapper.nonBillableTAList.forEach(row => {
                        if (row.EmployeeName__c) {
                            row.empName = row.EmployeeName__r.Name;
                            row.empURL = component.get("v.communityUrl")
                                ? `${component.get("v.communityUrl")}/s/employee/${row.EmployeeName__c}`
                                : `/${row.EmployeeName__c}`;
                        }
                        row.reporterName = row.ReportingTo__r ? row.ReportingTo__r.Name : '';
                        row.allocationPercentage = row.AllocationPercentage__c ? row.AllocationPercentage__c + '%' : '';

                        // Categorization logic
                        if (row.StartDate__c && new Date(row.StartDate__c) > today) {
                            nonBillableYetToAssign.push(row);
                        } else if (row.EndDate__c && new Date(row.EndDate__c) < today) {
                            nonBillableCompleted.push(row);
                        } else {
                            nonBillableActive.push(row);
                        }
                    });
                }

                // Categorize Avishkaar Members
                if (tmListWrapper.avishkaarTAList != null) {
                    tmListWrapper.avishkaarTAList.forEach(row => {
                        if (row.EmployeeName__c) {
                            row.empName = row.EmployeeName__r.Name;
                            row.empURL = component.get("v.communityUrl")
                                ? `${component.get("v.communityUrl")}/s/employee/${row.EmployeeName__c}`
                                : `/${row.EmployeeName__c}`;
                        }
                        row.reporterName = row.ReportingTo__r ? row.ReportingTo__r.Name : '';
                        row.allocationPercentage = row.AllocationPercentage__c ? row.AllocationPercentage__c + '%' : '';

                        // Categorization logic
                        if (row.StartDate__c && new Date(row.StartDate__c) > today) {
                            avishkaarYetToAssign.push(row);
                        } else if (row.EndDate__c && new Date(row.EndDate__c) < today) {
                            avishkaarCompleted.push(row);
                        } else {
                            avishkaarActive.push(row);
                        }
                    });
                }
          
                // Set categorized data to attributes
                component.set('v.billableActive', billableActive);
                component.set('v.billableYetToAssign', billableYetToAssign);
                component.set('v.billableCompleted', billableCompleted);
                component.set('v.nonBillableActive', nonBillableActive);
                component.set('v.nonBillableYetToAssign', nonBillableYetToAssign);
                component.set('v.nonBillableCompleted', nonBillableCompleted);
                component.set('v.avishkaarActive', avishkaarActive);
                component.set('v.avishkaarYetToAssign', avishkaarYetToAssign);
                component.set('v.avishkaarCompleted', avishkaarCompleted);
            }
        });

        $A.enqueueAction(action);
    },
            handleMainAccordionToggle: function (component, event, helper) {
        const openSections = event.getParam('openSections');
        if (openSections.length > 0) {
            component.set("v.activeMainSection", openSections[0]);
        }
    },

    handleBillableSubAccordionToggle: function (component, event, helper) {
        helper.handleSubAccordionToggle(component, "activeSubSectionBillable", event);
    },

    handleNonBillableSubAccordionToggle: function (component, event, helper) {
        helper.handleSubAccordionToggle(component, "activeSubSectionNonBillable", event);
    },

    handleAvishkaarSubAccordionToggle: function (component, event, helper) {
        helper.handleSubAccordionToggle(component, "activeSubSectionAvishkaar", event);
    }
});