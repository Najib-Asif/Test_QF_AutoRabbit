/***********************************************************************************************************************************

Description: Test Method-Lightning component handler for the Proosal 's customer approval

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-2797   Test method LEx-Proposal Customer Approval                T01
                                    
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
@isTest
private class QL_ProposalCustApprovedTest { 
    
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
         propList = QL_TestUtilityData.getProposal(oppList);
          {
             Test.startTest();               
                try{
               //  Database.Update(conList);
                 //Invoke the controller Method
                 QL_ProposalCustApproved.getProposal(propList[0].Id);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
          }
    }
    static testMethod void validateTestDataAppRegLegal() {
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<Proposal__c> propList = new List<Proposal__c>();
         List<Proposal__c> propListUpd = new List<Proposal__c>();

         List<Discount_List__c> discList = new List<Discount_List__c>();
        
         
         // Load Accounts
         accList = QL_TestUtilityData.getAccounts();
         
         // Load Opportunities
         oppList = QL_TestUtilityData.getOpportunities(accList);
         
         // Load Proposals
         propList = QL_TestUtilityData.getProposal(oppList);
     
         {
         Test.startTest();  
          for (Proposal__c p:propList)  
           {
             p.Active__c = true;
             propListUpd.add(p);
           }            
        try{
             Database.Update(propListUpd);
             //Invoke the controller Method
             QL_ProposalCustApproved.getProposal(propList[1].Id);
             System.assertEquals(True,propList[1].Active__c);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
          }
    }
    

    static testMethod void validateTestDataApp() {
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<Proposal__c> propList = new List<Proposal__c>();
         List<Proposal__c> propListUpd = new List<Proposal__c>();

         List<Discount_List__c> discList = new List<Discount_List__c>();
        
         
         // Load Accounts
         accList = QL_TestUtilityData.getAccounts();
         
         // Load Opportunities
         oppList = QL_TestUtilityData.getOpportunities(accList);
         
         // Load Proposals
         propList = QL_TestUtilityData.getProposal(oppList);
        
    {
         Test.startTest();  
          for (Proposal__c p:propList)  
           {
             p.Active__c = False;
             propListUpd.add(p);
           }            
        try{
             Database.Update(propListUpd);
             //Invoke the controller Method
             QL_ProposalCustApproved.getProposal(propList[1].Id);
             System.assertEquals(False,propList[1].Active__c);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
          }
    }
}