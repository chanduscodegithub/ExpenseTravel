({
    doChildInit : function(component, event, helper) {
        var detailsMap = new Map(component.get('v.radioButtonDetails'));
        var key = component.get('v.key');
        if(detailsMap.get(key)[0].type=='Picklist'){
            component.set('v.isBodyTemp',true);
            component.set('v.picklistValues',detailsMap.get(key)[0].picklistValues);
            component.set('v.isPicklistExist',true);
            if(component.get('v.areYouVaccinated')!=undefined && component.get('v.areYouVaccinated')!=null && component.get('v.areYouVaccinated')!=''){
                var resultMap = new Map();
                var objectRecordName = key;
                var value = component.get('v.areYouVaccinated');
                if(component.get('v.resultMap')!=null){
                    resultMap = component.get('v.resultMap');
                } 
                resultMap[objectRecordName]=value;
                var totalWeightage=0;
                var addWeight=component.get('v.addWeight');
                if(component.get('v.totalWeightage')!=null){
                    totalWeightage = component.get('v.totalWeightage');
                }
                
                if(detailsMap.get(objectRecordName)[0].picklistValuesWeightage.split(',').includes(value) && addWeight==true){
                    totalWeightage = totalWeightage + parseInt(detailsMap.get(objectRecordName)[0].weight);
                    addWeight = false;
                }
                
                else if(resultMap[objectRecordName]!=undefined && resultMap[objectRecordName]!=null && addWeight==false && !detailsMap.get(objectRecordName)[0].picklistValuesWeightage.split(',').includes(value)){
                    totalWeightage = totalWeightage - parseInt(detailsMap.get(objectRecordName)[0].weight);
                    addWeight = true;
                }
                component.set('v.allowSubmit',true);
                component.set('v.addWeight',addWeight);
                component.set('v.totalWeightage',totalWeightage);
                component.set('v.resultMap',resultMap);
                console.log('Total Weightage - '+totalWeightage);
                console.log('Result Map - '+JSON.stringify(resultMap));
            }
        }
        else{
            component.set('v.isBodyTemp',false);
        }
        var mapValue = detailsMap.get(key);
        component.set('v.listRadioButtons',mapValue);
    },
    
    handleRadioButtonValue : function(component, event, helper) {
        //debugger;
        var objectRecordName = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');
        var detailsMap = new Map(component.get('v.radioButtonDetails'));
        var resultMap = new Map();
        if(component.get('v.resultMap')!=null){
            resultMap = component.get('v.resultMap');            
        }
        console.log(objectRecordName +'  '+value);
        
        var finalValues = new Object();
        finalValues['weight'] = component.get('v.totalWeightage');
        
        //finalValues['value']=value;
        if(value == 'Yes'){
            finalValues['weight'] = finalValues['weight'] + parseInt(detailsMap.get(objectRecordName)[0].weight);
        }
        else if(resultMap[objectRecordName]!=undefined && resultMap[objectRecordName]!=null){
            finalValues['weight'] = finalValues['weight'] - parseInt(detailsMap.get(objectRecordName)[0].weight);
        }            
        
        
        resultMap[objectRecordName]=value;
        component.set('v.finalValues',finalValues);
        component.set('v.totalWeightage',finalValues['weight']);
        component.set('v.resultMap',resultMap);
        console.log('Total Weightage - '+JSON.stringify(finalValues['weight']));
        console.log('Result Map - '+JSON.stringify(resultMap));
        //console.log('Map - '+JSON.stringify(resultMap));
        //alert('Total weightage - '+component.get('v.totalWeightage'));
    },
    pickListChange : function(component, event, helper) {
        debugger;
        
        var detailsMap = new Map(component.get('v.radioButtonDetails'));
        var objectRecordName = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');
        
        var resultMap = new Map();
        if(component.get('v.resultMap')!=null){
            resultMap = component.get('v.resultMap');
        }
        
        //var finalValues = new Object();
        resultMap[objectRecordName]=value;
        if(value=='' || value==null){
            component.set('v.allowSubmit',false);
        }
        else{
            component.set('v.allowSubmit',true);
        }
        var totalWeightage=0;
        var addWeight=component.get('v.addWeight');
        if(component.get('v.totalWeightage')!=null){
            totalWeightage = component.get('v.totalWeightage');
        }
        
        if(detailsMap.get(objectRecordName)[0].picklistValuesWeightage.split(',').includes(value) && addWeight==true){
            totalWeightage = totalWeightage + parseInt(detailsMap.get(objectRecordName)[0].weight);
            addWeight = false;
        }
        
        else if(resultMap[objectRecordName]!=undefined && resultMap[objectRecordName]!=null && addWeight==false && !detailsMap.get(objectRecordName)[0].picklistValuesWeightage.split(',').includes(value)){
            totalWeightage = totalWeightage - parseInt(detailsMap.get(objectRecordName)[0].weight);
            addWeight = true;
        }
        component.set('v.addWeight',addWeight);
        component.set('v.totalWeightage',totalWeightage);
        component.set('v.resultMap',resultMap);
        console.log('Total Weightage - '+totalWeightage);
        console.log('Result Map - '+JSON.stringify(resultMap));
    }
})