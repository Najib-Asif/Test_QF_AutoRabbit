/*-------------------------------------------------------------------------------------------------------------------------------
Author:        Abhijeet Pimpalgaonkar
Company:       TCS
Description:   Trigger on QuoteLineItem, for underlying functionalities specified below 
                1. To Populate custom fields from OpportunityLineItem to QuoteLineItem
Test Class:    QuoteLineItemTriggerTest
*********************************************************************************************************************************
*********************************************************************************************************************************
History
********************************************************************************************************************************/


trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update) {
    
    QuoteLineItemTriggerHelper triggerHelper = new QuoteLineItemTriggerHelper();
    
    if(Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate )){
        triggerHelper.insertOrUpdateQuoteLineItems(Trigger.New);
    }
    
}