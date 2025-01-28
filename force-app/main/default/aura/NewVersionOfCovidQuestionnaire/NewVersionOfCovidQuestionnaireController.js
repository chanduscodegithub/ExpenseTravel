({
    init : function(component, event, helper){
        debugger;
        var action1 = component.get("c.createNewVersionOfQuestionnaire"); 
        action1.setParams({
            "recordId" : component.get("v.recordId"),
        });
        action1.setCallback(this , function(response){
            if(response.getState() === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                console.log(response.getReturnValue());
                if(response.getReturnValue() == "success" || response.getReturnValue() == "Success"){
                    console.log('success');
                    toastEvent.setParams({
                        title: "Success",
                        type: "success",
                        message: "New Version Successfully Created."
                    });
                    window.location.reload();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    toastEvent.setParams({
                        title: "Error",
                        type: "error",
                        message: response.getReturnValue(),
                        mode : "sticky"
                    });
                    console.log(response.getReturnValue());
                }
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action1);
    },
    
    closeWindow : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
    
})