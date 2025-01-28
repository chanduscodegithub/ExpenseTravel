export default function (arrayObject, empId, appraisalCycle, buttonClicked, isCCMOrRM, validateRMandCCM) {

    const objectArray = [];
    return new Promise((resolve, reject) => {

        arrayObject.forEach(item => {
            var record = {
                Goal_Repository__c: item.goalRespository.Id,
                Employee__c: empId.Id,
                Appraisal_Cycle__c: appraisalCycle.Id
            };
            if (item.goalSettingId != '') {
                record.Id = item.goalSettingId;
            }

            if (buttonClicked === 'submitToManager') {
                record.Status__c = 'Submitted';
            }

            if (buttonClicked !== 'saveAsDraft') {
                if (isCCMOrRM === 'RM') {
                    record.Status__c = 'Manager Approved';
                } else if(isCCMOrRM === 'CCM') {
                    record.Status__c = 'CCM Approved';
                }
                if (validateRMandCCM === true && isCCMOrRM != '') {
                    record.Status__c = 'CCM Approved';
                }
            }


            if (item.goalSettingArray.length > 0) {
                item.goalSettingArray.forEach((kpi, index) => {
                    //console.log("index::" + index);
                    if (index === 0) {
                        record.KPI_1__c = kpi.KPI;
                        record.KPI_1_Weightage__c = kpi.KPIWieghtage != '' ? kpi.KPIWieghtage : 0;
                    } else if (index === 1) {
                        record.KPI_2__c = kpi.KPI;
                        record.KPI_2_Weightage__c = kpi.KPIWieghtage != '' ? kpi.KPIWieghtage : 0;
                    } else if (index === 2) {
                        record.KPI_3__c = kpi.KPI;
                        record.KPI_3_Weightage__c = kpi.KPIWieghtage != '' ? kpi.KPIWieghtage : 0;
                    } else if (index === 3) {
                        record.KPI_4__c = kpi.KPI;
                        record.KPI_4_Weightage__c = kpi.KPIWieghtage != '' ? kpi.KPIWieghtage : 0;
                    } else if (index === 4) {
                        record.KPI_5__c = kpi.KPI;
                        record.KPI_5_Weightage__c = kpi.KPIWieghtage != '' ? kpi.KPIWieghtage : 0;
                    }
                });

                if (item.goalSettingArray.length < 5) {
                    for (let index = 4; index >= item.goalSettingArray.length; index--) {
                        if (index === 4) {
                            record.KPI_5__c = '';
                            record.KPI_5_Weightage__c = 0;
                        } else if (index === 3) {
                            record.KPI_4__c = '';
                            record.KPI_4_Weightage__c = 0;
                        } else if (index === 2) {
                            record.KPI_3__c = '';
                            record.KPI_3_Weightage__c = 0;
                        } else if (index === 1) {
                            record.KPI_2__c = '';
                            record.KPI_2_Weightage__c = 0;
                        }
                    }
                }
            }
            if ((item.goalSettingId == '' || item.goalSettingId == null) && ((record.KPI_1__c == null || record.KPI_1__c === '') && record.KPI_1__c == 0)) {

            } else {
                objectArray.push(record);
            }
        });
        resolve(objectArray);
    });

}