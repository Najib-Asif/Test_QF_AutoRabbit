/***********************************************************************************************************************************

Description: Test Method-Lightning component handler for the FreightRecordtypeAssignment

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-3068   Test method LEx-FreightRecordtypeAssignment                T01

Created Date    : 25/05/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
@isTest
private class QL_FreightRecordtypeAssignmentTest { 
    
    @testsetup
    static void createTestData(){
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryType','Qantas Points'));
        insert lstConfigData;
    }

    static testMethod void validateTestData() {
        
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Claims').getRecordTypeId();
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        
        TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.createEnableValidationRuleSetting();
        List<Freight_RecordTypeSeggregation__c> lstfreCusSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
        insert lstfreCusSetting;
        
        Airport_Code__c aCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c  ='NSW');
        insert aCode;
        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@qantas.com.au'; 
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
        
        Account testacc = new Account(Name='Test Tcs Account',
                                      Active__c = true,
                                      Type = 'Freight-Country',
                                      Customer_Ranking__c = '5',
                                      Sentiment__c = 'Positive',
                                      OwnerId = u.Id,
                                      RecordTypeId = accRTId);
        insert testacc;
        
        Contact testcon = new Contact(FirstName='Bob',
                                      LastName='Test',
                                      AccountId=testacc.id,
                                      Function__c = 'IT',
                                      Business_Types__c = 'Freight',
                                      Email = 'abc@test.com');
        insert testcon;
        List<Case> testCases = new List<case>();
        Case testcase1 = new Case(AccountId = testacc.id,
                                 ContactId = testcon.id,
                                 RecordTypeId = caseRTId,
                                 Subject = 'the case',
                                 Description = 'test desc',
                                 Status = 'Open',
                                 Priority = 'Medium',
                                 Origin = 'Phone',
                                 Type = 'Customer Query',
                                 Customer_Advice_Method__c = 'Email',
                                 Freight_Port__c = aCode.Id
                                );
        testCases.add(testcase1);
        
        Case testcase2 = new Case(AccountId = testacc.id,
                                 ContactId = testcon.id,
                                 RecordTypeId = caseRTId,
                                 Subject = 'the case',
                                 Description = 'test desc',
                                 Status = 'Closed',
                                 Priority = 'Medium',
                                 Origin = 'Phone',
                                 Type = 'Customer Query',
                                 Customer_Advice_Method__c = 'Email',
                                 Freight_Port__c = aCode.Id
                                );
        testCases.add(testcase2);
        
        
        insert testCases; 
        
        system.runAs(u) {
            Test.startTest();               
            try{
                //  Database.Update(conList);
                //Invoke the controller Method
                QL_FreightRecordtypeAssignment.getlistrecType();
                QL_FreightRecordtypeAssignment.reassignToRecordType(testcases[0].Id,testcases[0].Type);
                QL_FreightRecordtypeAssignment.reassignToRecordType(testcases[1].Id,testcases[1].Type);
                
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
            Test.stopTest(); 
        }
    }

    // CRM-10461: Added test method to cover query exception
    static testMethod void testQueryException() {
        
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Claims').getRecordTypeId();
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();

        TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.createEnableValidationRuleSetting();
        List<Freight_RecordTypeSeggregation__c> lstfreCusSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
        insert lstfreCusSetting;
        
        Airport_Code__c aCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c  ='NSW');
        insert aCode;
        
         String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@qantas.com.au'; 
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

        Account testacc = new Account(Name='Test Tcs Account',
                                      Active__c = true,
                                      Type = 'Freight-Country',
                                      Customer_Ranking__c = '5',
                                      Sentiment__c = 'Positive',
                                      OwnerId = u.Id,
                                      RecordTypeId = accRTId);
        insert testacc;
        
        Contact testcon = new Contact(FirstName='Bob',
                                      LastName='Test',
                                      AccountId=testacc.id,
                                      Function__c = 'IT',
                                      Business_Types__c = 'Freight',
                                      Email = 'abc@test.com');
        insert testcon;
        
        Case testcase = new Case(AccountId = testacc.id,
                                 ContactId = testcon.id,
                                 RecordTypeId = caseRTId,
                                 Subject = 'the case',
                                 Description = 'test desc',
                                 Status = 'Open',
                                 Priority = 'Medium',
                                 Origin = 'Phone',
                                 Type = 'Customer Query',
                                 Customer_Advice_Method__c = 'Email',
                                 Freight_Port__c = aCode.Id
                                );
        insert testcase; 
      
        system.runAs(u) {
            Test.startTest();               
            try{
                QL_FreightRecordtypeAssignment.getlistrecType();
                QL_FreightRecordtypeAssignment.reassignToRecordType(testcase.Id,testcase.Type);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            } 
            Test.stopTest(); 
        }
    }
    
    
    
}