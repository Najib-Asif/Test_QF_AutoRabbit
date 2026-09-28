/*----------------------------------------------------------------------------------------------------------------------
Author:        Gourav Bhardwaj 
Company:       Capgemini
Description:   Trigger on Account for Insert/Update/Delete Events
Test Class:    AccountTeamTriggerTest 
*********************************************************************************************************************************
*********************************************************************************************************************************
History
*********************************************************************************************************************************
Gourav Bhardwaj     1787    Add functionality to capture Aquire OverrideFlag Start/End Dates and their change history.           
Gourav Bhardwaj     1898    Create AccountEligibilityLog record when Account record is created      
Praven Sampath              AccountAirlineLevel Discount Code Logic
Praveen Sampath             AccountIneligibility Code Logic
Benazir Amir                DeleteTracker Records Code Logic
Praveen Sampath             Code Revamp
Leslie May Padilla 	G-934	Add a condition to check if the user session has permission to bypass trigger which is used for
							Data Migration and Transformation activities
**********************************************************************************************************************************/

trigger AccountTrigger on Account (before insert,after insert, before update, after update, after delete) {  

    //GRAPHIT-934: Check if the specific user session triggering this event has the permission to bypass triggers
    Boolean bypassTrigger = FeatureManagement.checkPermission('QCC_Bypass_Account_Contact_Case_Triggers');
    system.debug('>>>bypassTrigger: ' + bypassTrigger);
    if (!bypassTrigger) {
        Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
        
        map<Id,Account> newPaxAccountMap = recordTypeUtility.returnAccountTriggerMap(Trigger.NewMap, Label.BusinessCategorySales, 'Account');  
        map<Id,Account> oldPaxAccountMap = recordTypeUtility.returnAccountTriggerMap(Trigger.OldMap, Label.BusinessCategorySales, 'Account');
        
        system.debug('@@ New Map @@1' + newPaxAccountMap);
        system.debug('@@ Old Map @@2' + oldPaxAccountMap);
        for(Account eachAcc : newPaxAccountMap.values()){
            system.debug('@@ New @@ ' + newPaxAccountMap.get(eachAcc.id).RecordTypeId);
            // system.debug('@@ New @@ ' + oldPaxAccountMap.get(eachAcc.id).RecordTypeId);
        }
        //To update Account Owner for Agency Accounts beforeInsert
        if(Trigger_Status__c.getValues('AgencyAccountOwnerUpdate')!=null && Trigger_Status__c.getValues('AgencyAccountOwnerUpdate').Active__c && Trigger.isBefore && Trigger.isInsert) {
            AccountTriggerHelper.beforeInsert(Trigger.new); 
        }
        
        /*For Sales Passanger Records*/
        if(newPaxAccountMap.size() > 0 || oldPaxAccountMap.size() > 0 ){
            System.debug('salespassangerTriggermetod');
            
            /* Assign & create Account team members based on user department*/
            if(Trigger_Status__c.getValues('AccountTeam')!=null && Trigger_Status__c.getValues('AccountTeam').Active__c && Trigger.isUpdate  && Trigger.isBefore ){
                /* Before insert process */
                AccountTriggerHelper.updateAccountTeam(Trigger.newMap, Trigger.oldMap);
            } 
            
            /* Trigger to invoke the AccountIneligibilty Logs AccountEligibilityLogTriggerTracking*/
            if(Trigger_Status__c.getValues('AccountEligibilityLogTrigger')!=null && Trigger_Status__c.getValues('AccountEligibilityLogTrigger').Active__c && Trigger.isAfter && Trigger.isUpdate){
                AccountTriggerHelper.createAccountEligiblityLogs(Trigger.newMap, Trigger.oldMap);
            }
            
            /* Trigger to invoke the DiscountCode Calculations on Products*/
            if(Trigger_Status__c.getValues('AccountAirlineLeveltrigger') !=null && Trigger_Status__c.getValues('AccountAirlineLeveltrigger').Active__c && Trigger.isAfter && Trigger.isUpdate) {
                AccountTriggerHelper.calculateDiscountCode(Trigger.newMap,Trigger.oldMap);
            }
            
            
            /* Trigger to invoke the DeleteAccount Tracking of Records*/
            if(Trigger_Status__c.getValues('AccountDeleteTrigger')!=null && Trigger_Status__c.getValues('AccountDeleteTrigger').Active__c && Trigger.isAfter && Trigger.isDelete) {
                AccountTriggerHelper.createDelAccountLogTracker(Trigger.oldMap); 
            }   
            
            /* Trigger to invoke the updateAccountDetail  before Update to update any account details*/
            if(Trigger_Status__c.getValues('AccountUpdateAccountDetail') !=null && Trigger_Status__c.getValues('AccountUpdateAccountDetail').Active__c && Trigger.isBefore && Trigger.isUpdate) {
                AccountTriggerHelper.updateAccountDetail(Trigger.new, Trigger.oldMap); 
            }
            
            
            //To update Account Owner for Agency Accounts beforeUpdate
            if(Trigger_Status__c.getValues('AgencyAccountOwnerUpdate')!=null && Trigger_Status__c.getValues('AgencyAccountOwnerUpdate').Active__c && Trigger.isBefore && Trigger.isUpdate) {
                AccountTriggerHelper.beforeUpdate(Trigger.new,Trigger.oldMap); 
            }
            
            //Update related records of the Account on Ownerchange CRM-4676
            if(Trigger_Status__c.getValues('updateRelatedRecordsOnOwnerChange')!=null && 
               Trigger_Status__c.getValues('updateRelatedRecordsOnOwnerChange').Active__c && Trigger.isAfter && Trigger.isUpdate) {
                   if(IsRecursive.runAccountafterUpdate())
                   {
                       AccountTriggerHelper.updateRelatedRecordsOnOwnerChange(Trigger.new, Trigger.OldMap); 
                   }
               }
        }
        // Populate Domain from Account Email 
        system.debug('On top of trigger');
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            system.debug('Entered trigger');
            AccountTriggerHelper.updateDomainFromAccountEmail(Trigger.new, Trigger.oldMap);
        }
    }
 
}