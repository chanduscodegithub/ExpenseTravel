({
	myAction : function(component, event, helper) {
		
	},
    EditPOli : function(component, event, helper){
        //alert('hi???');
        component.set('v.IsTAEdit',true);
      
    },
    closeModal : function(component, event, helper){
        component.set('v.IsTAEdit',false);
    }
})