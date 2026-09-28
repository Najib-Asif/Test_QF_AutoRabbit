/***********************************************************************************************************************************

Description: Test Method-Lightning component handler for the Proosal 's customer reject

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-2797   Test method LEx-Proposal Customer Approval                T01
                                    
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
public with sharing class QL_ProposalCustRejected {
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    
    @AuraEnabled
    public static QL_ProposalCustRejected getProposal(Id propId)
    {
        
        QL_ProposalCustRejected obj = new QL_ProposalCustRejected ();
        
        try{
        List<Proposal__c> propList = [SELECT Id,Status__c,Active__c FROM Proposal__c where Id =: propId];
        List<Proposal__c> propToUpdate = new List<Proposal__c>();
            system.debug('propListt***'+propList);
             List<User> u = [select id,CountryCode from user where id=:userinfo.getuserid()];
             
             for(Proposal__c p:propList)
              {
                 if(p.Active__c == TRUE)
                  {
                  p.status__c = 'Rejected - External'; 
                  propToUpdate.add(p);
                  }
                  
                 else
                 {
                 obj.isSuccess =false;
                 obj.msg='Proposal should be Active!';
                 }
              }
             
             
             
             if(propToUpdate.size()>0)
              update propToUpdate;
              
            obj.isSuccess = true;
             return obj;  
             }
             
      catch(Exception ex)
       {
         throw new AuraHandledException(ex.getMessage());    
        }       
     }  
     }