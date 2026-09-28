/*----------------------------------------------------------------------------------------------------------------------
Author:        Capgemini
Company:       Capgemini
Description:   Class to be invoked from QuoteTrigger
Inputs: 
************************************************************************************************
History
************************************************************************************************
21-09-2017    Capgemini             Initial Design
07-11-2017    Capgemini             Populate Start Date and Contract End Date from Quote when creating Contract
-----------------------------------------------------------------------------------------------------------------------*/
public class QuoteTriggerHelper {
    public static Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Quote', 'Loyalty Commercial');
    public static Id contractRecordTypeId= GenericUtils.getObjectRecordTypeId('Contract__C', 'Loyalty Commercial');
    
    public static void quoteHandler(List<Quote> newQuotes, Map<Id, Quote> oldQtMap) {
        
        List<Quote> changedQuotesList = new List<Quote>{};
        List<Contract__c> contractList = new List<Contract__c>{};
        Map<Id, Quote> relatedQuotesToOpps = new Map<Id, Quote>{};
        Set<Id> oppid=new Set<Id>();
    
            
        for(Quote newQt: newQuotes) {
            Quote oldQuote = oldQtMap.get(newQt.Id);
            
            if(newQt.RecordTypeId == LoyaltyRecordTypeId) {
                
                if(newQt.Price_Per_Point__c != oldQuote.Price_Per_Point__c ||
                   newQt.Proposed_Term_of_Agreement__c != oldQuote.Proposed_Term_of_Agreement__c ||
                   newQt.Start_Date__c != oldQuote.Start_Date__c ||
                   newQt.Minimum_Spend_Commitment__c != oldQuote.Minimum_Spend_Commitment__c ) {
                       changedQuotesList.add(newQt);                       
                       relatedQuotesToOpps.put(newQt.OpportunityId, newQt);
                }
                
                if(newQt.Status == 'Accepted' && oldQuote.Status != 'Accepted'){
                    oppid.add(newQt.OpportunityId);
                }
            }
        }
        
        if(!oppid.isEmpty()){
            Map<Id,Opportunity> mapopportunity=new Map<Id,Opportunity>([Select Id,AccountId from Opportunity Where Id IN : oppid]);
            if(!mapopportunity.isEmpty()){
             
                for(Quote newQt:newQuotes){
                    Quote oldQuote = oldQtMap.get(newQt.Id);
                    Opportunity opp;
                    
                    if(mapopportunity.containsKey(newQt.OpportunityId)){
                          opp =  mapopportunity.get(newQt.OpportunityId);
                    }
                    
                    if(newQt.Status == 'Accepted' && oldQuote.Status != 'Accepted'){
                        if (oldQuote.Contract_From_Button_Technical__c==newQt.Contract_From_Button_Technical__c){
                            Contract__c  contract = new Contract__c();
                            contract.Quote__c = newQt.Id;
                            contract.Opportunity__c = newQt.OpportunityId;
                            contract.Account__c = opp.AccountId;
                            contract.Price_Per_Point__c = newQt.Price_Per_Point__c;
                            contract.Proposed_Revenue_Amount__c = newQt.Amount__c;
                            contract.Participant_Program_Manager__c = newQt.Participant_Program_Manager__c;
                            contract.Program_Participation_Fee_excl_GST__c = newQt.Program_Fee__c;
                            contract.SLA__c = newQt.SLA__c;
                            contract.Rebates_and_Payment_Terms__c = newQt.Rebates_and_Payment_Terms__c;
                            contract.Additional_Legal_Information__c = newQt.Additional_Legal_Information__c;
                            contract.Contract_Owner__c  =newQt.OwnerId;
                            contract.Name  = newQt.Name;
                            contract.RecordTypeId = contractRecordTypeId;
                            contract.Contract_Start_Date__c= newQt.Start_Date__c;
                            contract.Contract_End_Date__c = newQt.Contract_End_Date__c;
                            contractList.add(contract);
                        }
                        futureMethodsClass.closeOpp(newQt.OpportunityId, newQt.Contract_End_Date__c);
                    }
                }
            }
        }
        
        if(changedQuotesList.size() > 0) {
            updateOnOpportunity(relatedQuotesToOpps);
        }
        
        
        if(contractList.size() > 0){
            insert contractList;
        }
    }
    
    /*---------------------------------------------------------------------------------------------------------------      
    Method Name:        updateOnOpportunity
    Description:        Performs update on Opportunity
    ---------------------------------------------------------------------------------------------------------------*/    
    private static void updateOnOpportunity(Map<Id, Quote> oppQuote) {
        
        List<Opportunity> opptys = [SELECT Id, Price_Per_Point__c, Proposed_Term_of_Agreement__c, 
                                    Start_Date__c, Minimum_Spend_Commitment__c
                                    FROM Opportunity
                                    WHERE Id = :oppQuote.keySet()];
        for(Opportunity opp: opptys) {
            Quote qt = oppQuote.get(opp.Id);
            opp.Price_Per_Point__c = qt.Price_Per_Point__c;
            opp.Start_Date__c = qt.Start_Date__c;
            opp.Proposed_Term_of_Agreement__c = qt.Proposed_Term_of_Agreement__c;
            opp.Minimum_Spend_Commitment__c = qt.Minimum_Spend_Commitment__c;
        }
        
        if(opptys.size() > 0) {
            update opptys;
        }
    }
    
    /*---------------------------------------------------------------------------------------------------------------      
    Method Name:        inActivateQuote
    Description:        Unchecks the Active flag on Quote
    ---------------------------------------------------------------------------------------------------------------*/
    public static void inActivateQuote(List<Quote> quotes) {
        List<Id> opps = new List<Id>{};
        
        for(Quote q: quotes) {
            opps.add(q.OpportunityId);
        }
        
        List<Quote> existQuoteList = [SELECT Id, Active__c, OpportunityId FROM Quote WHERE OpportunityId in :opps AND Active__c = true AND RecordTypeId = :LoyaltyRecordTypeId];
        for(Quote q : existQuoteList) {
            q.Active__c = false;
        }
        if(existQuoteList.size() > 0)
            update existQuoteList;
    }
}