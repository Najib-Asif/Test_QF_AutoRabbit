/***********************************************************************************************************************************

Description: Test Method for Lightning component handler for the customer contract rejection 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-2797   Test Method LEx-Contract reject                 T01
                                    
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/

@isTest
private class QL_ContractCustRejectedTest { 
    
  @testsetup
   static void createTestData(){
     
         // Custom setting creation
         QL_TestUtilityData.enableCPTriggers();
   }
   static testMethod void validateTestData() {
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<Proposal__c> propList = new List<Proposal__c>();
         List<Discount_List__c> discList = new List<Discount_List__c>();
         List<Contract__c> conList = new  List<Contract__c>();
       
         
         // Load Accounts
         accList = QL_TestUtilityData.getAccounts();
         
         // Load Opportunities
         oppList = QL_TestUtilityData.getOpportunities(accList);
         
         // Load Proposals
         propList = QL_TestUtilityData.getProposal(oppList);
         
         //Load Contract
         conList = QL_TestUtilityData.getContracts(propList);
         Test.startTest();               
        try{
             Database.Update(conList);
             //Invoke the controller method
             QL_ContractCustRejected.getProposal(conList[0].Id);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
    }
    static testMethod void validateTestDataAppRegLegal() {
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<Proposal__c> propList = new List<Proposal__c>();
         List<Discount_List__c> discList = new List<Discount_List__c>();
         List<Contract__c> conList = new  List<Contract__c>();
         List<Contract__c> conToupd = new  List<Contract__c>();

         
         // Load Accounts
         accList = QL_TestUtilityData.getAccounts();
         
         // Load Opportunities
         oppList = QL_TestUtilityData.getOpportunities(accList);
         
         // Load Proposals
         propList = QL_TestUtilityData.getProposal(oppList);
         
         //Load Contract
         conList = QL_TestUtilityData.getContracts(propList);
         Test.startTest();               
         //Update Contract
        For (Contract__c c:conList)
                {
                c.Status__c='Approval Required – Legal';   
                conToupd .add(c);             
                }
       try{
             Database.Update(conToupd);
             //Invoke the controller method
             QL_ContractCustRejected.getProposal(conList[1].Id);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
    }
    }