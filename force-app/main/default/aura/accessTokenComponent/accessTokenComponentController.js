({
    doInit : function(component, event, helper) {
        
    },
   openSmallWindow : function(component, event, helper) {
        var action = component.get("c.createAuthURL");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var authUrl = response.getReturnValue();
                console.log('authUrl@@' + authUrl);

                var urlToOpen = response.getReturnValue();
                var windowWidth = 400;
                var windowHeight = 400;
                var left = (screen.width - windowWidth) / 2;
                var top = (screen.height - windowHeight) / 2;
                var windowFeatures = 'width=' + windowWidth + ',height=' + windowHeight + ',left=' + left + ',top=' + top + ',resizable=yes,scrollbars=yes';

                var newWindow = window.open(urlToOpen, '_blank', windowFeatures);

                // Add event listener for window message
                window.addEventListener('message', function(event) {
                    if (event.data === 'AccessTokenSaved') {
                        // Handle successful access token saving
                        helper.handleAccessTokenSaved(component);
                    } else {
                        // Handle other messages if needed
                    }
                }, false);
            }
        });

        $A.enqueueAction(action);
    },
    
    
     openModal: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   },
  
   closeModal: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
  
    
    executeBatch : function (component, event, helper){
       
         component.set("v.isModalOpen", true);
		  component.set("v.apexJob",null);

        var action = component.get("c.executeBatchJob");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "The Job has been successfully initiated."
                });
                toastEvent.fire();
			
           
                if (state === "SUCCESS"){
                    var isToastShown = false;
                    var interval = setInterval($A.getCallback(function () {
                        var jobStatus = component.get("c.getBatchJobStatus");
                        if(jobStatus != null){
                            jobStatus.setParams({ jobID : response.getReturnValue()});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    component.set('v.apexJob',job);
                                   
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    var progress = component.get('v.progress');
                                    component.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                }
                                 if(job.TotalJobItems == 0 && !isToastShown){
                                       var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "type": "Info",
                                            "title": "Note:",
                                            "message": "There are no Timesheet Approval Files to be Purged."
                                        });
               						 	toastEvent.fire(); 
                                     	isToastShown = true;
                                    }
                            });
                            $A.enqueueAction(jobStatus);
                        }
                    }), 2000);
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }

})