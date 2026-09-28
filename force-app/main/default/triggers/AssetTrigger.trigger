/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Trigger on Asset for Insert/Update Events
Test Class:    
*********************************************************************************************************************************
Modified By : Ajay Bharathan
Purpose : TO include Channel functionality , and update TMC Info records during asset insertion

Modified Date   : 30/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4813
Version         : Deregistration - Update PCC GDS status in Salesforce
**********************************************************************************************************************************/
trigger AssetTrigger on Asset (before update, before insert, after insert, after update) 
{

    if(Trigger_Status__c.getValues('AssetCalculateFeesandDiscounts') != null && Trigger_Status__c.getValues('AssetCalculateFeesandDiscounts').Active__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ){
        AssetTriggerHelper.calculateAssetFeesandDiscounts(trigger.new, trigger.oldMap);
    }
    
    
    if(Trigger_Status__c.getValues('AssetConvertingAssetType') != null && Trigger_Status__c.getValues('AssetConvertingAssetType').Active__c && Trigger.isBefore && Trigger.isUpdate ){
        //CRM-3838 -> AssetTrigger Issues Fixes
        if(IsRecursive.runOnce()){
        AssetTriggerHelper.convertingAssetType(trigger.newMap, trigger.oldMap);
        
    }
    }

    // changes added by Ajay - For Channel requirements
    if(Trigger_Status__c.getValues('AssetChannel') != null && Trigger_Status__c.getValues('AssetChannel').Active__c){
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        {
            // to include duplicate check on records    
            AssetHandler.QCH_checkDuplicates(trigger.new, trigger.oldMap);
        }
        // changes added by Vinoth - After Update
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            // to update the records on TMC Info Object
            AssetHandler.QCH_doTMCInfoUpdate(trigger.new, trigger.oldMap);
        }
    }
    // changes ended 
}