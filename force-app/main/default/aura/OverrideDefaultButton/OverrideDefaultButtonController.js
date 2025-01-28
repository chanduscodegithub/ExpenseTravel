({
    doInit: function (component, event, helper) {
        
         var action = component.get("c.getCurrentUserProfileName");
         action.setCallback(this, function(response) {
            var state = response.getState();
            // alert('state>>'+state);
             // alert('res>>'+response.getReturnValue());
            if (state === "SUCCESS") {
                component.set("v.profileName", response.getReturnValue());
                localStorage.removeItem("curRecId");
        
        const recID = component.get('v.recordId');
        const profileName= component.get("v.profileName");
        if (recID != null && recID != undefined) {
            localStorage.setItem("curRecId", recID);
        }
        
        if(profileName == 'Partner Community Login Contractors'){
               let strURL = window.location.href;
       // alert('strURL>'+strURL);
        let locURL = strURL.split('CRMITPRCommunity/s/');
      //  alert('locURL>'+locURL);
        let backtoListTimesheet = locURL[0] + 'CRMITPRCommunity/s/timesheet';
       // alert('backtoListTimesheet>'+backtoListTimesheet);
        window.open(backtoListTimesheet, "_self");
        }
        else {
               let strURL = window.location.href;
        //alert('strURL>'+strURL);
        let locURL = strURL.split('CRMITCommunity/s/');
       // alert('locURL>'+locURL);
        let backtoListTimesheet = locURL[0] + 'CRMITCommunity/s/timesheet';
       // alert('backtoListTimesheet>'+backtoListTimesheet);
        window.open(backtoListTimesheet, "_self");  
        }
            }
            // Handle any error scenarios here, if needed
        });

        $A.enqueueAction(action);
        
      
    }
})