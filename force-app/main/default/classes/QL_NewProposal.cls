public with sharing class QL_NewProposal {
    
    @AuraEnabled public boolean isSuccess{get;set;}
    @AuraEnabled public String Message{get;set;}
    @AuraEnabled public String RecId{get;set;}
    @AuraEnabled public Proposal__c MyPropObj{get;set;}
    
    @AuraEnabled
    public static String Newproposal(String Oppid)
    {                    
        QL_NewProposal Obj = new QL_NewProposal();       
        
        Opportunity OpportunityObj1 = new Opportunity();
        Opportunity OpportunityObj2 = new Opportunity();
        Map<String,String> PropRecType = new Map<String,String>();
        String RecType;
        Proposal__c PropObj = new Proposal__c();
        
        OpportunityObj2 = [SELECT Id,(SELECT Id, Status__c FROM Proposals__r where Active__c=true AND (Status__c='Accepted by Customer' OR Status__c='Approval Required - Internal' OR Status__c='Acceptance Required - Customer'))
                           FROM Opportunity where Id=:Oppid];
        system.debug('Active Oppoertunity '+OpportunityObj2.Proposals__r);
        OpportunityObj1 = [Select Id, Name, AccountId, Amount, StageName, Category__c, Proposed_Market_Share__c, 
                           Proposed_International_Market_Share__c, Forecast_Charter_Spend__c, Forecast_MCA_Revenue__c,
                           Deal_Type__c, Proposed_MCA_Routes_Market_Share__c, Contact__c from Opportunity where Id=:Oppid];
        
        if(OpportunityObj1.StageName == 'Closed - Accepted' || OpportunityObj1.StageName == 'Closed - Not Accepted')
        {            
            Obj.Message = 'Please note that you cannot create a proposal for a Closed Opportunity.';
            Obj.isSuccess = true;
            return JSON.serialize(Obj);
        }
        else if(!OpportunityObj2.Proposals__r.isEmpty())
        {            
            Obj.Message = 'Please note that you cannot create a new proposal for this opportunity since there is an existing active proposal.';                     
            Obj.isSuccess = true;
            return JSON.serialize(Obj);
        }
        else
        {
            for(RecordType listofRType : [select Id, DeveloperName from RecordType where sObjectType = 'Proposal__C'])
                PropRecType.put(listofRType.DeveloperName, listofRType.Id);
            
            if(OpportunityObj1.Category__c == 'Qantas Business Savings')
                RecType = 'Qantas_Business_Savings';
            else if(OpportunityObj1.Category__c == 'Corporate Airfares')
                RecType = 'Corporate_Airfares';
            else if(OpportunityObj1.Category__c == 'Adhoc')
                RecType = 'Adhoc_Charter_Approval_Required_Customer';
            else if(OpportunityObj1.Category__c == 'Scheduled')
                RecType = 'Adhoc_Charter_Approval_Required_Customer';
            else if(OpportunityObj1.Category__c == 'FIFO Scheduled')
                RecType = 'Adhoc_Charter_Approval_Required_Customer';                      
            
            PropObj.Opportunity__c = OpportunityObj1.Id;
            PropObj.Account__c = OpportunityObj1.AccountId;
            PropObj.Qantas_Annual_Expenditure__c = OpportunityObj1.Amount;
            PropObj.Domestic_Annual_Share__c = OpportunityObj1.Proposed_Market_Share__c;
            PropObj.International_Annual_Share__c = OpportunityObj1.Proposed_International_Market_Share__c;
            PropObj.Forecast_Charter_Spend__c = OpportunityObj1.Forecast_Charter_Spend__c;
            
            if(OpportunityObj1.Forecast_MCA_Revenue__c!=null)
                PropObj.Forecast_MCA_Revenue__c = OpportunityObj1.Forecast_MCA_Revenue__c;
            else
                PropObj.Forecast_MCA_Revenue__c =0.00;
            
            PropObj.Deal_Type__c = OpportunityObj1.Deal_Type__c;
            PropObj.MCA_Routes_Annual_Share__c = OpportunityObj1.Proposed_MCA_Routes_Market_Share__c;
            PropObj.RecordTypeId = PropRecType.get(RecType);
            PropObj.Type__c = OpportunityObj1.Category__c;
            PropObj.Contact__c = OpportunityObj1.Contact__c;            
            Obj.MyPropObj = PropObj;
        }
        return JSON.serialize(Obj); 
    }
    
}