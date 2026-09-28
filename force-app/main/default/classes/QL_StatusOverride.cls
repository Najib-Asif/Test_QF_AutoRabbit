/***********************************************************************************************************************************

Description:Lightning component handler for the Proosal 's Status Override
History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-2797    LEx-Proposal Customer status override              T01
                                    
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
public with sharing class QL_StatusOverride {
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    
    @AuraEnabled
    // Method to check for the valid Proposal and update its status
    public static QL_StatusOverride getProposal(Id propId)
    {
        
        QL_StatusOverride obj = new QL_StatusOverride();
        
        try{
        List<Proposal__c> propList = [SELECT Id,Status__c,Active__c FROM Proposal__c where Id =: propId];
        List<Proposal__c> propToUpdate = new List<Proposal__c>();
            system.debug('propListt***'+propList);
             List<User> u = [select id,CountryCode from user where id=:userinfo.getuserid()];
             // Validate Proposal exists for Non AU users
             if(!propList.isEmpty() && (u[0].CountryCode!='AU' || u[0].CountryCode!='US')){
             for(Proposal__c p:propList)
              {
                 if(p.Active__c == TRUE)
                  {
                  p.status__c = 'Acceptance Required - Customer'; 
                  propToUpdate.add(p);
                  }
                  
                 else
                 {
                 obj.isSuccess =false;
                 obj.msg='Proposal should be Active!';
                 }
              }
             
             }
             else
             {
              obj.isSuccess =false;
              obj.msg='This status override button can only be used by the International (non-AU) Account Managers / Sales Users';
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