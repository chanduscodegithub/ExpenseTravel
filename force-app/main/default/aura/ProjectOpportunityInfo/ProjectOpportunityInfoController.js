({
    doInit : function(component, event, helper) {
        var action =component.get('c.getOpprotunityInfo');
        action.setParams({ProjId:component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set('v.oppotunitydetails',response.getReturnValue());
                console.log( component.get('v.oppotunitydetails'));
                console.log(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
        
    }
})