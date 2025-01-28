({
    
    doInit : function(component, event, helper) {
        //debugger;
        component.set('v.isEmail',false);
        var parameter = decodeURIComponent(window.location.hash); //You get the part of the URL as String including # and everything after that.
        console.log('parameter - '+parameter);
        var parameterArray = new Array();
        if(parameter.includes(',')){
            parameterArray = parameter.split(',');
        }
        
        var idToken = parameterArray[0].substring(1); //Removing # in the String we got from URL.
        if(idToken!=null){
            component.set('v.idToken',idToken);
        }
        
        var agreeDateTime = new Date(parameterArray[1]);
        var optInDateTimeString = agreeDateTime.getDate()+'/'+(agreeDateTime.getMonth()+1)+'/'+agreeDateTime.getFullYear()+' '+agreeDateTime.getHours()+':'+agreeDateTime.getMinutes();
        
        var employeeComingToOfficeToday = parameterArray[2];
        
        console.log('agreeDateTime - '+agreeDateTime);
        console.log('optInDateTimeString - '+optInDateTimeString);
        console.log('employeeComingToOfficeToday - '+employeeComingToOfficeToday);
        console.log('Component Value - '+component.get('v.idToken'));
        component.set('v.optInDateTimeString',optInDateTimeString);
        component.set('v.employeeComingToOfficeToday',employeeComingToOfficeToday);
        helper.fetchQuestionsHelper(component,event);
    },
    
    onSubmit : function(component,event,helper){
        //debugger;
        
        //To check If an Employee has answered all the questions in the Assessment.
        if(Object.entries(component.get('v.resultMap')).length == component.get('v.indexQuestionList').length && (!component.get('v.isPicklistExist') || component.get('v.allowSubmit'))){
            var score = component.get('v.totalWeightage');
            
            //Covid-19 Assessment Risk Profiles.
            var covid19AssessmentResultList = component.get('v.covid19AssessmentResultList');
            component.set('v.topScore',covid19AssessmentResultList[covid19AssessmentResultList.length-1].Upper_Limit__c);
            
            //Match the upperlimit properly based on the Employee's Assessment Score to get the following values.
            for(var i=0;i<covid19AssessmentResultList.length;i++){
                if(score <= covid19AssessmentResultList[i].Upper_Limit__c){
                    component.set('v.risk',covid19AssessmentResultList[i].Risk_Rating_Value__c);
                    component.set('v.recommendation',covid19AssessmentResultList[i].Recommendation__c);
                    component.set('v.riskLabel',covid19AssessmentResultList[i].Risk_Rating_Label__c);
                    component.set('v.riskScoreLabel',covid19AssessmentResultList[i].Risk_Score_Label__c);
                    component.set('v.color','color:'+covid19AssessmentResultList[i].Color__c+';');
                    break;
                }
            }
            component.set('v.isPopUp',true);
            helper.submitResults(component,event);
            //component.set('v.confirmAlert',true);
        }else{
            //Show Toast message to tell Employee to answer all of the questions in the Assessment.
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error",
                type: "error",
                message: 'Answer all the questions to proceed',
                mode : "sticky"
            });
            toastEvent.fire();
        }
    },
    
    closeModal : function(component,event,helper){
        window.location.reload()
        
    },
    
    submitEmail : function(component,event,helper){
        //debugger;
        //This code shall be used to when No Authentication is requires such as G-Sign In or ADFS
        //The below code just takes Email as input and proceeds with the operation.
        var email = component.find("email").get('v.value');
        if(email==null||email==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Invalid Input",
                type: "error",
                message: 'Enter your Email Id',
                mode : "sticky"
            });
            toastEvent.fire();
        }
        else{
            component.set('v.email',email);
            component.set('v.isEmail',false);
        }
    },
    
    confirmMessage : function(component,event,helper){
        component.set('v.isPopUp',true);
        helper.submitResults(component,event);
    },
    
    CancelMessage : function(component,event,helper){
        component.set('v.confirmAlert',false);
    },
    
    loadURL : function(component,event,helper){
        window.location.replace(component.get('v.serviceResourceURL'));
    },
    
})