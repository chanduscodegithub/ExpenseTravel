({
    fetchQuestionsHelper : function(cmp,event) {
        //debugger;
        
        //Call Apex function to fetch Question set.
        var action = cmp.get("c.fetchSymptomQuestions");
        //Pass the idToken which you got from Google Auth.
        action.setParams({ idToken : cmp.get("v.idToken") });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //Checking if the Employee is registered in the System.
                var isServiceResource = response.getReturnValue().isServiceResource;
                
                //Checking if the Employee is Patient/Suspect or Not.
                var isCovid19Patient = response.getReturnValue().isCovid19Patient;
                if(isCovid19Patient==false && isServiceResource==true){
                    cmp.set('v.areYouVaccinated',response.getReturnValue().areYouVaccinated);
                    cmp.set('v.covid19AssessmentResultList',response.getReturnValue().covid19AssessmentResultList);
                    //cmp.set('v.serviceResourceURL',response.getReturnValue().serviceResourceURL);
                    cmp.set('v.covidQuestionnaire',response.getReturnValue().covidQuestionnaire);
                    cmp.set('v.headerNote',response.getReturnValue().headerNote);
                    cmp.set('v.showRiskScore',response.getReturnValue().showRiskScore);
                    var dateString = response.getReturnValue().todayDate.split('-');
                    var dateString1 = dateString[1]+'/'+dateString[2]+'/'+dateString[0];
                    cmp.set('v.todayDate',dateString1);
                    cmp.set('v.currentYear',dateString[0]);
                    var responseData = response.getReturnValue().questionSet;
                    var detailsMap = new Map(); 
                    var indexQuestionList = [];
                    
                    // Manipulating the questions to support the format of Checklist/Picklist Values.
                    for(var i=0;i<responseData.length;i++){
                        if(responseData[i].type == 'Picklist'){
                            for(var y=0;y<responseData[i].picklistValues.length;y++){
                                responseData[i].picklistValues[y] = responseData[i].picklistValues[y].trim();
                            }
                            if(responseData[i].picklistValuesWeightage.includes(',')){
                                var splitPicklistValuesWeightage = responseData[i].picklistValuesWeightage.split(',');
                                for(var y=0;y<splitPicklistValuesWeightage.length;y++){
                                    splitPicklistValuesWeightage[y] = splitPicklistValuesWeightage[y].trim();
                                }
                                responseData[i].picklistValuesWeightage = splitPicklistValuesWeightage.join(',');
                            }                            
                        }
                        var options = [];
                        var tempOption = new Object();
                        tempOption['name']=responseData[i].apiName;
                        tempOption['label']='Yes';
                        tempOption['value']=false;
                        tempOption['weight'] = responseData[i].weightage;
                        tempOption['type'] = responseData[i].type;
                        tempOption['picklistValues'] = responseData[i].picklistValues;
                        tempOption['picklistValuesWeightage'] = responseData[i].picklistValuesWeightage;
                        options.push(tempOption);
                        tempOption = new Object();
                        tempOption['name']=responseData[i].apiName;
                        tempOption['label']='No';
                        tempOption['value']=true;
                        tempOption['weight'] = responseData[i].weightage;
                        tempOption['type'] = responseData[i].type;
                        tempOption['picklistValues'] = responseData[i].picklistValues;
                        tempOption['picklistValuesWeightage'] = responseData[i].picklistValuesWeightage;
                        options.push(tempOption);
                        detailsMap.set(responseData[i].apiName,options);
                        var indexQuestion = new Object();
                        indexQuestion['question'] =  responseData[i].question;
                        indexQuestion['index'] = i+1;
                        indexQuestion['label'] = responseData[i].apiName;
                        indexQuestionList.push(indexQuestion);
                        
                    }
                    cmp.set('v.radioButtonDetails',detailsMap);
                    cmp.set('v.indexQuestionList',indexQuestionList);
                    
                    //var keysTemp = detailsMap.keys();
                    var keysTemp=Array.from(detailsMap.entries());
                    var keys=[];
                    for(var i=0;i<keysTemp.length;i++){
                        keys.push(keysTemp[i][0]);
                    }
                    cmp.set('v.isServiceResource',true);
                    cmp.set('v.isCovid19Patient',false);
                    cmp.set('v.keys',keys);
                    cmp.set('v.checkList',responseData);
                    cmp.set('v.isSpin',false);
                }else if(isCovid19Patient == true){
                    cmp.set('v.isCovid19Patient',true);
                    cmp.set('v.message','Given the high risk you were at, from your last assessment, you were requested to seek medical advice and also need to get in immediate touch with the HR team to understand the next steps. Until then, follow the Covid-19 appropriate behavior as prescribed by your doctor and stay safe!');
                    cmp.set('v.isSpin',false);
                }else if(isServiceResource == false){
                    cmp.set('v.isCovid19Patient',false);
                    cmp.set('v.isServiceResource',false);
                    cmp.set('v.message','Your Email Id has not been registered in our System. Please contact the System Admin.');
                    cmp.set('v.isSpin',false);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Error",
                                type: "error",
                                message: errors[0].message,
                                mode : "sticky"
                            });
                            toastEvent.fire();
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        // optionally set storable, abortable, background flag here
        
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    
    submitResults : function(cmp,event) {
        //debugger;
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var resultMap = cmp.get("v.resultMap");
        var action = cmp.get("c.storeTechAssessmentResults");
        action.setParams({ resultDetailsMap : resultMap, score : cmp.get('v.totalWeightage'), risk : cmp.get('v.risk'), recommendation : cmp.get('v.recommendation'),idToken : cmp.get("v.idToken"),covidQuestionnaire:cmp.get('v.covidQuestionnaire'),covid19AssessmentResultList:cmp.get('v.covid19AssessmentResultList'),optInDateTimeString:cmp.get('v.optInDateTimeString'),employeeComingToOfficeToday:cmp.get('v.employeeComingToOfficeToday') });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()=='success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Success",
                        type: "success",
                        message: 'Your Assessment is successfully submitted.',
                        mode : "sticky"
                    });
                    toastEvent.fire();
                    console.log('Successfully Submitted.');
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Error",
                                type: "error",
                                message: errors[0].message,
                                mode : "sticky"
                            });
                            toastEvent.fire();
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        // optionally set storable, abortable, background flag here
        
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
})