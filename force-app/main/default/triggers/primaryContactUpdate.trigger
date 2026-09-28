/********************************************************************************************************************************
* Author: TCS
* Description: To Update PrimaryContact field in ACR and make sure only one ACR is having PrimaryContact checked
* JIRA       :TS-4880
* ******************************************************************************************************************************/
trigger primaryContactUpdate on AccountContactRelation (before insert,after update) {
    
    try{       
        if(Trigger_Status__c.getValues('ACRPrimaryContact').Active__c && !EnableValidationRule__c.getInstance().ACR_Trigger_Bypass__c && !QAC_ACRPrimaryContactUpdate.acrUpdated){
            if(trigger.isinsert)
                QAC_ACRPrimaryContactUpdate.updateACR(trigger.new);
            if(trigger.isupdate)
                QAC_ACRPrimaryContactUpdate.afterupdateACR(trigger.new,trigger.oldMap);
        }
    }
    catch(Exception e){
        System.debug('Error Occured From primaryContactUpdate  Trigger: ' + e.getLineNumber() +e.getMessage());
    }
}