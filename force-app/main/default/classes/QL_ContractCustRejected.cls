/***********************************************************************************************************************************

Description: Lightning component handler for the customer contract rejection 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-2797   LEx-Contract reject                 T01
                                    
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
public with sharing class QL_ContractCustRejected {
    
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    
    @AuraEnabled
    public static QL_ContractCustRejected getProposal(Id propId)
    {
        
        QL_ContractCustRejected obj = new QL_ContractCustRejected();
        
        try{
        List<Contract__c> conList = [SELECT Id,Status__c FROM Contract__c where Id =: propId];
        List<Contract__c> conToUpdate = new List<Contract__c>();
            system.debug('conListt***'+conList);
            // Check for the valid Contract
             if(!conList.isEmpty()){
             for(Contract__c c:conList)
              {
              //Validate if the Contract Status as "Approval Required – Legal"
                 if(c.Status__c == 'Approval Required – Legal')
                  {
                  obj.isSuccess =false;
                  obj.msg='Legal Approval Required!';                  
                  }
             //Handle for all other Status     
                 else
                 {
                 c.status__c = 'Rejected - Customer'; 
                 conToUpdate.add(c);
                 }
              }
             
             }
             else
             {
              obj.isSuccess =false;
              obj.msg='Some Error Occured';
             }
             // Update the Contract List
             if(conToUpdate.size()>0)
              update conToUpdate;              
              obj.isSuccess = true;
              return obj;  
             }
             
      catch(Exception ex)
       {
         throw new AuraHandledException(ex.getMessage());    
        }       
     }  
     }