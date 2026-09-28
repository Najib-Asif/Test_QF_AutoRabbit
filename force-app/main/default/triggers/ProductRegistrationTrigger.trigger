/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Trigger on Product Registration for Insert/Update/Delete Events
Test Class:    
*********************************************************************************************************************************
*********************************************************************************************************************************
History
*********************************************************************************************************************************

**********************************************************************************************************************************/

trigger ProductRegistrationTrigger on Product_Registration__c (before insert, after insert, before update, after update, after delete) {
    
    if(Trigger_Status__c.getValues('CreateOpportunities').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        ProductRegistrationTriggerHelper.processAccountAndOpportunity(Trigger.new);
    }

    if(Trigger_Status__c.getValues('PrdRegCalculateAMEXAcceptRejectCode').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) ){
        ProductRegistrationTriggerHelper.calculateAMEXAcceptRejectCode(Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('PrdRegUpdateAmexDetailsOnAquire').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) ){
        ProductRegistrationTriggerHelper.updateAmexDetailsOnAquire(trigger.new);
    }

    if(Trigger_Status__c.getValues('PrdRegUpdateRelatedAquireMembers').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) ){
        ProductRegistrationTriggerHelper.updateRelatedAquireMembers(trigger.newMap);
    } 

    if(Trigger_Status__c.getValues('PrdRegUpdateMembershipNumberonAccount').Active__c &&  Trigger.isAfter){
        ProductRegistrationTriggerHelper.updateMembershipNumberonAccount(Trigger.newMap, Trigger.oldMap);
    }

    /* Trigger to invoke the Case Creation on MultipleActive QBR Products under an Account*/
    if(Trigger_Status__c.getValues('PrdRegMultipleQBRCaseCreation').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) ) {
        ProductRegistrationTriggerHelper.createCaseOnMultipleActiveQBR(Trigger.newMap, Trigger.oldMap);
    }

    /* Trigger to invoke the Production registration Validation on Amex Products under an Account*/
    if(Trigger_Status__c.getValues('PrdRegAmexProdRegValidation').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        ProductRegistrationTriggerHelper.amexProdRegValidation(Trigger.newMap, Trigger.oldMap);
    }
}