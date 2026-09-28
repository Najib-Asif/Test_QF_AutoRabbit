/**
 * This class contains unit tests for validating the behavior of Account_Ownership_Update_Daily_Batch class.
 */
@isTest
private class Test_AccountOwnershipUpdateDailyBatch {
    
    //Added By Praveen For test class failure fix
    @testsetup
    static void createData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
    }

    static testMethod void testBatchProcess() {
       TestUtilityDataClassQantas.enableTriggers();
       
       // Insert Users
        List<User> users = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        users.add(new User(Alias = 'standt1', Email='standardusertest1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusertest1@testorg.com' + Math.random()));
        users.add(new User(Alias = 'standt2', Email='standardusertest2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standardusertest2@testorg.com' + Math.random()));
        users.add(new User(Alias = 'Int_User', FirstName = 'Integration', 
            EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Email='IntegrationUser@testorg.com', 
            TimeZoneSidKey='America/Los_Angeles', UserName='IntegrationUser@testorg.com' + Math.random()));            
        insert users;
        
        
        // Insert Account
        Account acc = new Account(Name = 'Test Sample', 
                                  RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(),
                                  OwnerId =  users[2].id,
                                  Estimated_Total_Air_Travel_Spend__c = 300000
                                  );
                                  
        insert acc;
        
        // Insert Account Team members                          
        List<AccountTeamMember> listAccTeam = new List<AccountTeamMember>();                            
        AccountTeamMember member = new AccountTeamMember();
        member.AccountId = acc.Id;
        member.UserId = users[2].id;
        member.TeamMemberRole = 'Account Manager';
        listAccTeam.add(member);                                  
        AccountTeamMember member1 = new AccountTeamMember();
        member1.AccountId = acc.Id;
        member1.UserId = Userinfo.getUserId();
        member1.TeamMemberRole = 'Business Development Rep';
        listAccTeam.add(member1);
        insert listAccTeam; 
        
        //insert Account Owner Settings            
        insert new Account_Owner__c(Name = 'T', Account_Manager__c = users[0].id, Business_Development_Rep__c = users[1].id, 
                                    Update_Required_AM__c = true, Update_Required_BDR__c = true,
                                    Old_Account_Manager__c = users[2].id, Old_BDR__c = Userinfo.getUserId());
                                    
        Test.startTest();
            Account_Ownership_Update_Daily_Batch batchObj = new Account_Ownership_Update_Daily_Batch();
            Database.executeBatch(batchObj);
        Test.stopTest();
                
        system.assertEquals([SELECT UserId FROM AccountTeamMember WHERE TeamMemberRole = 'Account Manager' AND AccountId =:acc.id].UserId, users[0].id);
        system.assertEquals([SELECT UserId FROM AccountTeamMember WHERE TeamMemberRole = 'Business Development Rep' AND AccountId =:acc.id].UserId, users[1].id);
    }
}