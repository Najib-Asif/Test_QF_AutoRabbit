/*----------------------------------------------------------------------------------------------------------------------
Author:        Capgemini
Company:       Capgemini
Description:   Class to be invoked from OpportunityTrigger
Inputs: 
************************************************************************************************
History
************************************************************************************************
18-09-2017    Capgemini             Initial Design

Modified By : Venkata Suresh Kumar (TCS Team), 29-May-2026
Desc : Remediated test class failures. Updated createQuote() method. Added required field (Rate_Valid_after_acceptance_until__c) on quote create
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class OpportunityTriggerHandler {
    
    public static Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Quote', 'Loyalty Commercial');
    
    
    public static void getNewQuoteOppotunities (list<Opportunity> opptyList, map<id,Opportunity> oldOpptyMap){
        List<Opportunity> loyaltyNegotiateOpps = new List<Opportunity>{};
        Map<ID,Schema.RecordTypeInfo> rt_Map = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        
        // Getting a list of records with stage updated to 'Negotiate'
        for(Opportunity opp: opptyList) {                
            if(rt_Map.get(opp.recordTypeID).getName().containsIgnoreCase('Loyalty Commercial')) {
                if(opp.StageName != oldOpptyMap.get(opp.Id).get('StageName') && opp.StageName == 'Negotiate') {
                    loyaltyNegotiateOpps.add(opp);                
                }
            }
        }
          
        // Calling the handler to create Quote records
        if(loyaltyNegotiateOpps.size() > 0) {
            OpportunityTriggerHandler.createQuote(loyaltyNegotiateOpps);
        }
    }
    
    /*---------------------------------------------------------------------------------------------------------------      
    Method Name:        createQuote
    Description:        Creates a Quote record with some of the fields pre-populated from Opportunity
                        and makes any existing Quote as Inactive
    ---------------------------------------------------------------------------------------------------------------*/
    public static void createQuote(List<Opportunity> opps) {
        List<Quote> lstQuotes = new List<Quote>{};
        
        List<Quote> existQuoteList = [SELECT Id, Active__c, OpportunityId FROM Quote WHERE OpportunityId in :opps AND Active__c = true AND RecordTypeId = :LoyaltyRecordTypeId];
        
        for(Quote q : existQuoteList) {
            q.Active__c = false;
        }
        
        if(existQuoteList.size() > 0)
            update existQuoteList;
        
        for(Opportunity newOpp : opps) {
            Quote qt = new Quote();
            qt.RecordTypeId = LoyaltyRecordTypeId;
            qt.OpportunityId = newOpp.Id;
            qt.Name = newOpp.Name;
            qt.Start_Date__c = newOpp.Start_Date__c;
            qt.Proposed_Term_of_Agreement__c = newOpp.Proposed_Term_of_Agreement__c;
            qt.Price_Per_Point__c = newOpp.Price_Per_Point__c;
            qt.Points_Per__c = newOpp.Points_Per__c;
            qt.Average_Annual_Spend_Per_Customer__c = newOpp.Average_Spend_Per_Customer__c;
            qt.Turnover__c = newOpp.Turnover__c;
            qt.Assumed_Tag_Rate_at_Maturity__c = newOpp.Assumed_Tag_Rate_at_Maturity__c;
            qt.Amount__c = newOpp.Amount;
            qt.Ramp_up_factor__c = newOpp.Ramp_up_factor__c;
            qt.Minimum_Spend_Commitment__c = newOpp.Minimum_Spend_Commitment__c;
            qt.Total_Points__c = newOpp.Total_Points__c;
            qt.Total_Program_Amount__c = newOpp.Total_Program_Amount__c;
            qt.Program_Fee__c = newOpp.Program_Fee__c;
            qt.Active__c = true;
            qt.Rate_Valid_after_acceptance_until__c = Date.today() - 30; //CRM-11408 - Added as part of Test class fix
            lstQuotes.add(qt);        
        }
        
        if(lstQuotes.size() > 0) {
            insert lstQuotes;
        }
    }
    
    public static void oppPusher(List<Opportunity> opps, Map<Id,Opportunity> oppOldMap){
    
        Date dNewCloseDate;
        Date dOldCloseDate;
        Boolean bPushed=false;
        
        Freight_TriggerRecordTypeUtility recordTypeUtility = new Freight_TriggerRecordTypeUtility();
        map<string,string> mapRecordTypeVsCategory = recordTypeUtility.returnRecordTypeSettingMap('Sales', 'Opportunity');    
        
        System.debug('opps'+opps);
        System.debug('oppOldMap'+oppOldMap);
        for (Opportunity oIterator : opps) { //Bulk trigger handler so that you can mass update opportunities and this fires for all'
            
            if(mapRecordTypeVsCategory.keySet().contains(oIterator.RecordTypeId)){
                system.debug('@@ Pax Record Type @@ ' + oIterator.RecordTypeId);
                // gets new values for updated rows
                dNewCloseDate = oIterator.CloseDate; // get the new closedate 
                System.debug('dNewCloseDate'+dNewCloseDate);
                dOldCloseDate = oppOldMap.get(oIterator.Id).CloseDate; //get the old closedate for this opportunity
                System.debug('dOldCloseDate'+dOldCloseDate);
                if (dOldCloseDate<dNewCloseDate) { //if the new date is after the old one, look if the month numbers are different
                    if (dOldCloseDate.month()<dNewCloseDate.month()) { // the month number is higher, it's been pushed out
                        bPushed=true;
                    }
                    else {
                        if (dOldCloseDate.year()<dNewCloseDate.year()) { // the month wasn't higher, but the year was, pushed!
                            bPushed=true;
                        }
                    }
                    
                }
                if (bPushed==true) { // let's go make them sorry
                    if (oIterator.PushCount__c==null) {
                        oIterator.PushCount__c=1;
                    }
                    else {
                        oIterator.PushCount__c++;           
                    }
                }    
            }
            
        }
    }
}