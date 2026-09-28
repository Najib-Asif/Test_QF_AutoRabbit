/*----------------------------------------------------------------------------------------------------------------------
    Author:        Jay
    Company:       TCS
    Description:   To restrict sales performance manager action on future invoice (Channel Payment)
    Inputs:
    Test Class:    PaymentTriggerHandlerTest
    ************************************************************************************************
    History
    ************************************************************************************************
    09-Oct-2019      Jay                        futureInvoiceRestrictionMethod
-----------------------------------------------------------------------------------------------------------------------*/

trigger PaymentsTrigger on Invoices__c (After Update) {
    
    try{
        if(Trigger.isAfter && Trigger.isUpdate){
            PaymentTriggerHandler.futureInvoiceRestrictionMethod(Trigger.new, Trigger.oldMap);
            
        }
        
    }catch(Exception e){
        System.debug('Error Occured From Payments  Trigger: '+e.getMessage());
    }
}