/*----------------------------------------------------------------------------------------------------------------------
Author:        Capgemini
Company:       Capgemini
Description:   Class to be invoked from GenerateQuote Lightning Component
Inputs: 
************************************************************************************************
History
************************************************************************************************
22-09-2017    Capgemini             Initial Design
 
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class QuickQuoteController {

    /*---------------------------------------------------------------------------------------------------------------      
    Method Name:        getOpp
    Description:        Retrieves Opportunity record from the Id passed
    ---------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static opportunity getOpp(Id oppId) {
        
        return [SELECT Name, Start_Date__c, Proposed_Term_of_Agreement__c, Price_Per_Point__c, Points_Per__c,
                       Average_Spend_Per_Customer__c, Turnover__c, Assumed_Tag_Rate_at_Maturity__c,
                       Amount, Ramp_up_factor__c, Minimum_Spend_Commitment__c, Total_Points__c, 
                       Total_Program_Amount__c, Program_Fee__c
                FROM Opportunity WHERE Id = :oppId];
    }
    
    /*---------------------------------------------------------------------------------------------------------------      
    Method Name:        saveQuoteWithOpp
    Description:        Creates a Quote record with some of the fields pre-populated from Opportunity
    ---------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Quote saveQuoteWithOpp(Quote quote, Opportunity opp) {
        
        quote.OpportunityId = opp.Id;
        quote.Start_Date__c = opp.Start_Date__c;
        quote.Proposed_Term_of_Agreement__c = opp.Proposed_Term_of_Agreement__c;
        quote.Price_Per_Point__c = opp.Price_Per_Point__c;
        quote.Points_Per__c = opp.Points_Per__c;
        quote.Average_Annual_Spend_Per_Customer__c = opp.Average_Spend_Per_Customer__c;
        quote.Turnover__c = opp.Turnover__c;
        quote.Assumed_Tag_Rate_at_Maturity__c = opp.Assumed_Tag_Rate_at_Maturity__c;
        quote.Amount__c = opp.Amount;
        quote.Ramp_up_factor__c = opp.Ramp_up_factor__c;
        quote.Minimum_Spend_Commitment__c = opp.Minimum_Spend_Commitment__c;
        quote.Total_Points__c = opp.Total_Points__c;
        quote.Total_Program_Amount__c = opp.Total_Program_Amount__c;
        quote.Program_Fee__c = opp.Program_Fee__c;        
        quote.Active__c = true;
        insert quote;
        return quote;
    }

}