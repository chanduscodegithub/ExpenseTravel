({
	doInit : function(component, event, helper) {
		var action = component.get('c.getTeamAllocationwithoutKPIs');
     
         action.setParams({employeeId:component.get("v.recordId")})
        action.setCallback(this,function(res){
           var state = res.getState();
            var result = res.getReturnValue(); 
          
            if(state == "SUCCESS"){
             
                if(result.length>0){
                   
                    component.set("v.EmpTAwithoutKPIsList",result);
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