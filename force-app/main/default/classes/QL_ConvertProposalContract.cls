public with sharing class QL_ConvertProposalContract
{
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    //@AuraEnabled public String recID {get;set;}
    
    @AuraEnabled
    public static QL_ConvertProposalContract createProposalContract(Id OpporId)
    {
        QL_ConvertProposalContract Obj = new QL_ConvertProposalContract();
        
        try
        {
            system.debug('*******'+OpporId);
            Opportunity thisOpportunity = [Select Id, AccountId, Name, Forecast_Charter_Spend__c, Contact_Information__c, Description from Opportunity where Id = :OpporId];
            
            If(thisOpportunity != null)
            {
                Proposal__c NewProposal = new Proposal__c();
                NewProposal.Opportunity__c = thisOpportunity.Id;
                NewProposal.Account__c = thisOpportunity.AccountId;
                NewProposal.Name = thisOpportunity.Name;
                Newproposal.Status__c = 'System Created';
                Newproposal.Proposal_Start_Date__c = system.today();
                Newproposal.Proposal_End_Date__c = system.today();
                Newproposal.Forecast_MCA_Revenue__c = 1000;
            
                if(thisOpportunity.Forecast_Charter_Spend__c != null)
                    Newproposal.Forecast_Charter_Spend__c = thisOpportunity.Forecast_Charter_Spend__c;
                
                Newproposal.Contact_Information__c = thisOpportunity.Contact_Information__c;
                Newproposal.Description__c = thisOpportunity.Description;
                
                Id NewproposalRecordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get('Adhoc Charter').getRecordTypeId();
                Newproposal.RecordTypeId = NewproposalRecordTypeId;
            
                insert Newproposal;
                
                Contract__c NewContract = new Contract__c();
                NewContract.Account__c = Newproposal.Account__c;
                NewContract.Opportunity__c = Newproposal.Opportunity__c;
                NewContract.Name = Newproposal.Name;
                NewContract.Proposal__c = Newproposal.Id;
                NewContract.Contract_Start_Date__c = Newproposal.Proposal_Start_Date__c;
                NewContract.Contract_End_Date__c = Newproposal.Proposal_End_Date__c;
                NewContract.Forecast_Charter_Spend__c = Newproposal.Forecast_Charter_Spend__c;
                NewContract.Description__c = Newproposal.Description__c;
                NewContract.Contact_Information__c = Newproposal.Contact_Information__c;
                
                Id NewContractRId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Adhoc Charter').getRecordTypeId();                
                NewContract.RecordTypeId = NewContractRId;
                
                insert NewContract;
                
                Obj.isSuccess = true;
                Obj.msg = 'The current Opportunit is converted to Proposal & Contract: '+ NewProposal.Name;
            }
            else
            {
                Obj.isSuccess = false;
                Obj.msg = 'There is no such Opportunity';
            }
            return Obj;            
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());    
        }
    }

}