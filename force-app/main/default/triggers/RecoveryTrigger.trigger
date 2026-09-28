/*----------------------------------------------------------------------------------------------------------------------
Author:        Cyrille
Company:       Capgemini
Description:   Triggers on the recovery object
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
22-Nov-2017      Cyrille               Initial Design
27-Nov-2017      Praveen Sampath       RecoveryTriggerHelper.invokeLoyaltyPostService
12-May-2019      Leslie May Padilla        GRAPHITE-934: Add a condition to check if the user session has permission to bypass trigger which is used for
                                            Data Migration and Transformation activities
-----------------------------------------------------------------------------------------------------------------------*/
trigger RecoveryTrigger on Recovery__c (before insert,before update, after update , after insert) {
    Boolean bypassTrigger = FeatureManagement.checkPermission('QCC_Bypass_Account_Contact_Case_Triggers');
    system.debug('>>>bypassTrigger: ' + bypassTrigger);
    if (!bypassTrigger) {
        if(!RecoveryTriggerHelper.hasRun){
            //CDP2 - 999
            if(Trigger.isafter && trigger.isUpdate){
                RecoveryApproveRejectedNotification.recoveryToPost(trigger.new,trigger.oldmap);
            }
            //CDP2 - 999
            //CDP2-809
            if(Trigger.isbefore && trigger.isUpdate){
                QCC_TravelVoucherCallHelper.checkTravelVoucherNumber(trigger.new,trigger.oldmap);
            }
            // CDP2-809
            if(Trigger_Status__c.getValues('isNotFrequentFlyerMember').Active__c && Trigger.isBefore && Trigger.isUpdate) {
                RecoveryTriggerHelper.isNotFrequentFlyerMember(Trigger.New, Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('isFrequentFlyerMember').Active__c && Trigger.isBefore && Trigger.isUpdate) {
                RecoveryTriggerHelper.isFrequentFlyerMember(Trigger.New, Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('getSuggestedRange').Active__c && Trigger.isBefore && Trigger.isInsert) {
                RecoveryTriggerHelper.getSuggestedRange(Trigger.New);
            }
            
            if(Trigger_Status__c.getValues('updateRecoveryType').Active__c && Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
                RecoveryTriggerHelper.updateRecoveryType(Trigger.New, Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('setFulfilledBy').Active__c && Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
                RecoveryTriggerHelper.setFulfilledBy(Trigger.New, Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('handleRecoveryTrigger').Active__c && Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
                RecoveryTriggerHelper.handleRecoveryTrigger(Trigger.New, Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('RecoveryInvokeLoyaltyPostService').Active__c && Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
                RecoveryTriggerHelper.invokeLoyaltyPostService(Trigger.New, Trigger.oldMap);
            }   
            //CDP2-1202 changes, Changed to invoke this method to afterTrigger
            if(Trigger_Status__c.getValues('RecoveryTriggerUpdateCaseRecoveryValue').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
                RecoveryTriggerHelper.updateCaseRecoveryValue(Trigger.New, Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('RecoveryTriggerPostToChatter').Active__c && Trigger.isBefore && Trigger.isUpdate ){
                RecoveryTriggerHelper.postToChatter(Trigger.New , Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('routeCaseOnRecoveryPaymentUpdate').Active__c && Trigger.isBefore && (Trigger.isInsert ||Trigger.isUpdate)){
                RecoveryTriggerHelper.routeCaseOnRecoveryPaymentUpdate(Trigger.New, Trigger.oldMap);
            }
            
            if(Trigger_Status__c.getValues('RecoveryTriggerUpdateCaseRecoveryEvent').Active__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
                RecoveryTriggerHelper.updateCaseStatusRecoveryEvent(Trigger.New);
            }
            // CDP2-197 CDP2-339 - Added IsInsert
            if(Trigger.isAfter &&  (Trigger.isInsert || Trigger.isUpdate)) {
                CaseStatusUpdateHandler.handleRecoveryStatusUpdate(Trigger.new,Trigger.oldmap);    
            }
            // CDP2-197
            // CDP2 - 995 -- not neede
            /*
            if(Trigger.isbefore &&  Trigger.isInsert ) {
                CaseHierarchyHelper.getTopParentCasesForRecoveries(Trigger.new);    
            }*/
            // CDP2 - 995
            //RecoveryTriggerHelper.hasRun = true;
        }
        if(Trigger_Status__c.getValues('RecoveryTriggerSubmitForFinalisation').Active__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            RecoveryTriggerHelper.invokeOPLAAPIForLoungePass(Trigger.New, Trigger.oldMap);
        }
        
    }
    
}