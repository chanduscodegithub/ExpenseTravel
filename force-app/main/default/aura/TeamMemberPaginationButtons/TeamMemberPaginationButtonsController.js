({
    firstPage : function(component, event, helper) {
        
        
        component.set("V.currentpageNumber",1);
    },
    PrevPage : function(component, event, helper) {
        
        var currentpag=component.get("V.currentpageNumber");
        var condition=Math.max(currentpag-1,1);
        component.set("V.currentpageNumber",condition);
        
        
        //component.set("V.currentpageNumber",Math.max(component.get("V.currentpageNumber")-1,1));
        
        
    },
    nextPage : function(component, event, helper) {
        var currentpag=component.get("V.currentpageNumber");
        var maxpag=component.get("V.maxpageNumber");
        var condition =Math.min(currentpag+1,maxpag);
        component.set("V.currentpageNumber",condition);
        
        
        // component.set("V.currentpageNumber",Math.min(component.get("V.currentpageNumber")+1,component.get("V.maxpageNumber")));
        
        
    },
    lastPage : function(component, event, helper) {
        
        var maxpag=component.get("V.maxpageNumber");
        component.set("V.currentpageNumber",maxpag);
        //component.set("V.currentpageNumber",component.get("V.maxpageNumber"));
        
        
    }
})