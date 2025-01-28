({
	doInit : function(component, event, helper) {
         component.set('v.IsSpinner',true);
        component.set('v.mycolumns', [
            {label: 'Project Name', fieldName: 'Name', type: 'text'},
            {label: 'Start Date', fieldName: 'StartDate__c', type: 'date'},
            {label: 'End Date', fieldName: 'EndDate__c', type: 'date'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'},
            {label: 'Manager', fieldName: 'ProjectManager__c', type: 'text'},
           
            {type: "buttonIcon", typeAttributes: {
                label: 'Edit',
                name: 'Edit',
                title: 'Edit',
                disabled: false,
                value: 'edit',
                iconPosition: 'left'
            }}
        ]);
        var action= component.get("c.getProjectList");
        action.setCallback(this,function(res){
           var state = res.getState();
            var result = res.getReturnValue();       
            if(state == "SUCCESS"){
                 if(result.length>0){
                    component.set("v.ProjectList",result);
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
		
	},
   
})