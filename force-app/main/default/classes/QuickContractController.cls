/*----------------------------------------------------------------------------------------------------------------------
Author:        Capgemini
Company:       Capgemini
Description:   Class to be invoked from GenerateContract Lightning Component
Inputs: 
************************************************************************************************
History
************************************************************************************************
25-09-2017    Capgemini             Initial Design
07-11-2017    Capgemini             [QLSF-330] Loyalty: Added code to update Quote Status to "Accepted"
 
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class QuickContractController {

    /*---------------------------------------------------------------------------------------------------------------      
    Method Name:        getQuote
    Description:        Retrieves Quote record from the Id passed
    ---------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Quote getQuote(Id quoteId) {
        
        return [SELECT Name, OpportunityId, Opportunity.Name, AccountId, Price_Per_Point__c, Amount__c, 
                Participant_Program_Manager__c, Program_Fee__c, SLA__c, Rebates_and_Payment_Terms__c,
                Additional_Legal_Information__c, OwnerId, Start_Date__c, Contract_End_Date__c, Contract_From_Button_Technical__c
                FROM Quote WHERE Id = :quoteId];
        
       
    }
    
    /*---------------------------------------------------------------------------------------------------------------      
    Method Name:        saveContractWithQuote
    Description:        Creates a Contract record with some of the fields pre-populated from Quote
    ---------------------------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Contract__c saveContractWithQuote(Contract__c con, Quote quote) {
        try{
            con.Quote__c = quote.Id;
            con.Opportunity__c = quote.OpportunityId;
            con.Account__c = quote.AccountId;
            con.Price_Per_Point__c = quote.Price_Per_Point__c;
            con.Proposed_Revenue_Amount__c = quote.Amount__c;
            con.Participant_Program_Manager__c = quote.Participant_Program_Manager__c;
            con.Program_Participation_Fee_excl_GST__c = quote.Program_Fee__c;
            con.SLA__c = quote.SLA__c;
            con.Rebates_and_Payment_Terms__c = quote.Rebates_and_Payment_Terms__c;
            con.Additional_Legal_Information__c = quote.Additional_Legal_Information__c;
            con.Contract_Owner__c = quote.OwnerId;
            con.Contract_Start_Date__c= quote.Start_Date__c;
            con.Contract_End_Date__c = quote.Contract_End_Date__c;
            insert con;

            Quote quoteToUpdate=new Quote(id=quote.Id, status='Accepted', Contract_From_Button_Technical__c=!quote.Contract_From_Button_Technical__c);
            update quoteToUpdate; 
            
            return con;
       } catch (Exception ex){
          throw new AuraHandledException('Error: ' + ex.getMessage());
       }
    }

}