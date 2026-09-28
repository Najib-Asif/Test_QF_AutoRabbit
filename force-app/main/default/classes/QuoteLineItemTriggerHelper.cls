/*----------------------------------------------------------------------------------------------------------------------
Author:        Abhijeet Pimpalgaonkar
Company:       TCS
Description:   Class to be invoked from QuoteLineItem Trigger
Inputs:
Test Class:     
************************************************************************************************
History

CRM-4167 Raj Sharma 28-02-2020
************************************************************************************************


-----------------------------------------------------------------------------------------------------------------------*/

public class QuoteLineItemTriggerHelper {
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        insertOrUpdateQuoteLineItems
    Description:        It is used for assigning Custom Field values of OpportunityLineItems with QuoteLineItems
    Parameter:          QuoteLineItem (Trigger.New List)
    --------------------------------------------------------------------------------------*/    
    public void insertOrUpdateQuoteLineItems(list<QuoteLineItem> quoteLineItemsNew){
        
        // get the quote record and find the Oppty and match on the OLI that caused the QLI to be created. Set the QLI's course field accordingly...
        // match on product (pricebook?), price and quantity
    
        set<id> quoteIds    = new set<id>();
        Id QuoterectypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Freight_Quote').getRecordTypeId();
          system.debug(QuoterectypeId );
    
        for(QuoteLineItem qli : quoteLineItemsNew){
            quoteIds.add(qli.QuoteId);
        }
    
        map<id,Quote> quoteIdToQuoteMap     = new map<id,Quote>([select id, OpportunityId,recordtypeid from Quote where id in:quoteIds and recordtypeid =: QuoterectypeId]);
    
        set<id> opptyIds    = new set<id>();
        
        for(Quote q : quoteIdToQuoteMap.values()){
            opptyIds.add(q.OpportunityId);
        }
    
        map<id,Opportunity> opptys          = new map<id,Opportunity>([select id, name, (select id, OpportunityId,PricebookEntryId,Product2Id,Quantity,UnitPrice,
                                                                                        Description,Freight_Destination__c,Freight_Origin__c,Freight_Commodity__c,
                                                                                        Freight_Weight_Break_KGs__c,Freight_Commodity_Type__c,Freight_Rate_Type__c,
                                                                                        Freight_Unit_Type__c,Flat_Rate__c,Min_Charge__c,Pivot_Rate__c,Pivot_Weight_Kgs__c
                                                                                        from OpportunityLineItems) from Opportunity where id in:opptyIds]);

        for(QuoteLineItem qli : quoteLineItemsNew){
            if (QuoterectypeId == quoteIdToQuoteMap.get(qli.QuoteId).recordtypeid){
            id opptyId          = ((Quote)quoteIdToQuoteMap.get(qli.QuoteId)).OpportunityId;
    
            Opportunity oppty   = opptys.get(opptyId);
    
            for(OpportunityLineItem oli : oppty.OpportunityLineItems){
                
                    if( oli.Product2Id  == qli.Product2Id && 
                    oli.Description == qli.Description &&
                    oli.UnitPrice   == qli.Unitprice &&
                    oli.Id == qli.OpportunityLineItemId) {
                
                        
                    //Setting the values of QuoteLineItems custom fields.
                    qli.Freight_Origin__c           = oli.Freight_Origin__c;
                    qli.Freight_Destination__c      = oli.Freight_Destination__c;
                    qli.Freight_Commodity__c        = oli.Freight_Commodity__c;
                    qli.Freight_Commodity_Type__c   = oli.Freight_Commodity_Type__c;
                    qli.Freight_Rate_Type__c        = oli.Freight_Rate_Type__c;
                    qli.Freight_Unit_Type__c        = oli.Freight_Unit_Type__c;
                    qli.Freight_Weight_Break_KGs__c = oli.Freight_Weight_Break_KGs__c;
                    qli.Flat_Rate__c                = oli.Flat_Rate__c;
                    qli.Min_Charge__c               = oli.Min_Charge__c;
                    qli.Pivot_Rate__c               = oli.Pivot_Rate__c;    
                    qli.Pivot_Weight_Kgs__c         = oli.Pivot_Weight_Kgs__c;                    
                    break;

                    }
            }
         }
       } 
    } 
}