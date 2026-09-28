/***********************************************************************************************************************************

Description: Test Method-Lightning component handler for the Proosal 's Status Override
History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-2797    LEx-Proposal Customer status override              T01
                                    
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
@isTest
private class   QL_StatusOverrideTest { 
    
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
         //Create User (AU)
         
       String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
          Profile pf = [Select Id from Profile where Name = 'System Administrator'];
            User u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User';
            u.Email = uniqueName + '@test' + sandboxName + '.com';
            u.CompanyName = 'test.com';
            u.Title = 'Test User';
            u.Username = uniqueName + '@test' + sandboxName + '.com';
            u.Alias = 'testuser';
            u.CommunityNickname = 'Test User';
            u.TimeZoneSidKey = 'Australia/Sydney';
            u.LocaleSidKey = 'en_AU';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = pf.Id;
            u.LanguageLocaleKey = 'en_US';
            u.CountryCode='AU';
            insert u;

        system.runAs(u) {
         Test.startTest();               
        try{
           //  Database.Update(conList);
                QL_StatusOverride.getProposal(propList[0].Id);
            
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
          //Create User (US)
          
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = uniqueName + '@test' + sandboxName + '.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        u.CountryCode='US';
        insert u;

        system.runAs(u) {
         Test.startTest();  
          for (Proposal__c p:propList)  
           {
             p.Active__c = true;
             propListUpd.add(p);
           }            
        try{
             Database.Update(propListUpd);
                QL_StatusOverride.getProposal(propList[1].Id);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
          }
    }
    }