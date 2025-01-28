({
    /*renderPage : function(component) {
        var records =component.get("v.teamInfo");
         console.log("============="+records);
       var pNumber=component.get("v.pageNumber");
         console.log("0000000000000"+pNumber);
        var pRecords=records.slice((pNumber-1)*5,pNumber*5);
         console.log("+++===============++++"+pRecords);
		component.set("v.teamInfoWrapper",pRecords);
         console.log(pRecords);
	}*/
    
    getCommunityUrl: function (component) {
        var action = component.get("c.retrieveCommunityURL");
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.communityUrl', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    handleSubAccordionToggle: function (component, attributeName, event) {
        const openSections = event.getParam('openSections');
        if (openSections.length > 0) {
            component.set("v." + attributeName, openSections[0]);
        }
    }
});