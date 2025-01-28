({
	doInit : function(component, event, helper) {
		component.set('v.IsSpinner',true);
        var action= component.get("c.getTeamAllocationList");
        action.setCallback(this,function(res){
           var state = res.getState();
            var result = res.getReturnValue(); 
           
            if(state == "SUCCESS"){
               
               //component.set("v.TAList",result);
                if(result.length>0){
                   
                    component.set("v.TAList",result);
                     component.set("v.IsNullFlag",true);
                    component.set('v.IsSpinner',false);
                    
                }
                else{
                    
                    component.set("v.IsNullFlag",false);
                   
                     component.set('v.IsSpinner',false);
                   
                }
               
            }
        });
           
       
        $A.enqueueAction(action);
		
	}
})