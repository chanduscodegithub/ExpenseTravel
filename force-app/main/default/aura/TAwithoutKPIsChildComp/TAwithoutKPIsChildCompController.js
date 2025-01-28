({
	doInit : function(component, event, helper) {
        var RecordId = component.get("v.TAList.Id");
       
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var FinalURL=baseURL+'/s/teamallocation/'+RecordId;
        component.set("v.TAURL",FinalURL);
    },
    EditPOli : function(component, event, helper){
        //alert('hi???');
        component.set('v.IsTAEdit',true);
      
    },
    closeModal : function(component, event, helper){
        component.set('v.IsTAEdit',false);
    }
})