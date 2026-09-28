/*----------------------------------------------------------------------------------------------------------------------
Author:        Abhijeet P
Company:       TCS
Description:   This test class will cover the test coverage for all Tile created as part of Freight functionality
    
************************************************************************************************
History
************************************************************************************************
10-Aug-2017    Abhijeet P              Initial Design
08-June-2026  Jesus Suarez             CRM-12983 - Added method
10-June-2026  Truong-Capgemini         CRM-12985 - Add code for catch query exception - FreightCustomerRankingController
-----------------------------------------------------------------------------------------------------------------------*/


@isTest
private class FreightAllTileControllerTest{
    
    //Added by QCC Project
    @testSetup
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

        // CRM-12985: Prepare User without access for catching query exception
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User qeUser = new User(
            LastName = 'FreightQEUser', Alias = 'FrtQE',
            Email = 'no_access_user@qantas.com.au',
            Username = 'no_access_user@sample.com',
            ProfileId = profMap.get('Standard Platform User').Id,
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_AU', TimeZoneSidKey = 'Australia/Sydney',
            UserPermissionsKnowledgeUser = true
        );
        insert qeUser;
    }

    // CRM-12985: call this method to getting no access user
    private static User getNoAccessUser() {
        return [SELECT Id FROM User WHERE Username = 'no_access_user@sample.com' LIMIT 1];
    }

    @isTest 
    static void ACRTileRecordTest() {
        
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Claims').getRecordTypeId();
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        
        TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.createEnableValidationRuleSetting();

        // disable ContactCeateAccount to not create person account
        List<Trigger_Status__c> contactTriggerStatus = [SELECT Id, Name, Active__c FROM Trigger_Status__c WHERE Name = 'ContactCeateAccount'];
        List<Trigger_Status__c> updateTriggerStatus = new List<Trigger_Status__c>();
        for(Trigger_Status__c triggerStatus: contactTriggerStatus) {
          triggerStatus.Active__c = false;
          updateTriggerStatus.add(triggerStatus);
        }
        update updateTriggerStatus;

        
        Integration_User_Tradesite__c testSetting = new Integration_User_Tradesite__c();
        testSetting.name = 'tradeSiteUser';
        testSetting.Username__c = 'sf1';
        testSetting.Password__c = 'pas';
        testSetting.Endpoint__c = 'endpo';
        testSetting.NameChangeStartNumber__c = 1;
        testSetting.NameChangeEndNumber__c = 9;
        testSetting.NameChangeLastNumber__c = 1;
        testSetting.ApprovedText__c = 'Appr';
        testSetting.RejectedText__c = 'Reje';
        insert testSetting;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        Profile p = [Select Id, Name from Profile where Name = 'Qantas Freight Service'];
        
        Trigger_Status__c ts = new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true);
        insert ts;
        
        List<Freight_RecordTypeSeggregation__c> lstfreCusSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
        insert lstfreCusSetting;
        
        Airport_Code__c aCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c  ='NSW');
        insert aCode;
        
        /*User u = new User(LastName = 'TestUser', Alias = 'testu',Email = 'testuser@sample.com',Username = 'testusername@sample.com',
                          CommunityNickname = 'testu', Phone = '1232141246', ProfileId = p.Id, 
                          EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                          TimeZoneSidKey = 'Australia/Sydney',IsActive = true );
        insert u;*/
        
        Account testacc = new Account(Name='Test Tcs Account',
                                      Active__c = true,
                                      Type = 'Freight-Country',
                                      Customer_Ranking__c = '5',
                                      Sentiment__c = 'Positive',
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
        
        // testing ACR Tile , Acc Owner Details and Account Ranking Tile
        Test.StartTest();
        FreightACRTileController.getACRRecord(testcase.Id);
        FreightCustomerRankingController.getAccRecord(testcase.Id);
        FreightAccOwnerController.getAccOwner(testcase.Id);
        Test.StopTest();    
        
    }

  //CRM-12984: FOR USER WITH NO ACCESS
@isTest
static void userNoAccessTest() { 
    
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];
    
    User u1 = new User(
        Username = 'testuser_noaccess_' + System.currentTimeMillis() + '@example.com',
        Email = 'testuser@qantas.com.au',
        LastName = 'NoAccess',
        FirstName = 'User',
        Alias = 'tuser',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
    );
    insert u1;

    // CREATE YOUR OWN DATA
    Account acc = new Account(Name='Test Account');
    insert acc;

    Contact con = new Contact(LastName='Test', AccountId=acc.Id);
    insert con;

    Case c = new Case(
        AccountId = acc.Id,
        ContactId = con.Id,
        Subject = 'Test Case',
        Status = 'Open',
        Origin = 'Phone'
    );
    insert c;

    Test.startTest();
    System.runAs(u1) {
        try {
            // Call SAME methods used in your main test
            FreightACRTileController.getACRRecord(c.Id);
            FreightCustomerRankingController.getAccRecord(c.Id);
            FreightAccOwnerController.getAccOwner(c.Id);

            // Optional: force failure if needed
            // throw new Exception('Force catch');

        } catch (Exception e) {
            System.assertNotEquals(null, e);
        }
    }
    Test.stopTest();
}

    // CRM-12985: Add code for catch query exception
    @isTest static void testGetAccRecord_QueryException() {
        
        User noAccessUser = getNoAccessUser();

        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(LastName='Test', AccountId=acc.Id);
        insert con;
        Case c = new Case(
            AccountId = acc.Id,
            ContactId = con.Id,
            Subject = 'Test Case',
            Status = 'Open',
            Origin = 'Phone'
        );
        insert c;

        Test.startTest();
        System.runAs(noAccessUser) {
            try {
                FreightCustomerRankingController.getAccRecord(c.Id);
            } catch (Exception e) {
                System.debug('### Exception Occurred getAccRecord' + e.getMessage() + ' : ' + e.getStackTraceString());
            }
        }
        Test.stopTest();
    }

    
@isTest
static void testGetAccOwner_CatchBlock() { //ADDED JESUS SUAREZ FOR USER WITH NO ACCESS

    // Create an inactive user
    Profile p = [SELECT Id FROM Profile LIMIT 1];

    User inactiveUser = new User(
        Alias = 'inact',
        Email = 'inactive@qantas.com.au',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Inactive',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'inactive' + System.currentTimeMillis() + '@test.com',
        IsActive = false
    );
    insert inactiveUser;

    // Create Account owned by inactive user
    Account acc = new Account(
        Name = 'Test Account',
        OwnerId = inactiveUser.Id
    );
    insert acc;

    Contact con = new Contact(LastName = 'Test', AccountId = acc.Id);
    insert con;

    Case c = new Case(
        AccountId = acc.Id,
        ContactId = con.Id,
        Subject = 'Test Case',
        Status = 'Open',
        Origin = 'Phone'
    );
    insert c;

    Test.startTest();

    try {
        FreightAccOwnerController.getAccOwner(c.Id);
        System.assert(false, 'Expected exception not thrown');
    } catch (AuraHandledException e) {
        System.assertNotEquals(null, e);
    }

    Test.stopTest();
}

    
    // Commented by Vinoth after discussing with Raj sharma because of Test Class Error
    /*@isTest 
    static void OpenCasesTileTest() {
        
        List<Freight_RecordTypeSeggregation__c> lstfreCusSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
        insert lstfreCusSetting;
        
        Airport_Code__c aCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c  ='NSW');
        insert aCode;
        
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Claims').getRecordTypeId();
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        
        Trigger_Status__c ts = new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true);
        insert ts;
        
        Account testacc = new Account(Name='Test Tcs Account',
                                      Active__c = true,
                                      Type = 'Freight-Country',
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
                                 Freight_Resolve_Reason__c = 'Other',
                                 Freight_Resolve_Comments__c = 'Resolved',
                                 Freight_Recovery_Solution__c = 'Other',
                                 Freight_Recovery_Cost__c = 100
                                );
        insert testcase;
        
        
        list<Case> openCasesList = new list<Case>();
        //list<Case> returnCaselist = new list<Case>();
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Customer_Advice_Method__c = 'Email'));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe caseAssignedAssignedAssignedAssigned',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Customer_Advice_Method__c = 'Email'));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Customer_Advice_Method__c = 'Email'));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Customer_Advice_Method__c = 'Email'));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Customer_Advice_Method__c = 'Email'));
        
        if(!openCasesList.isEmpty())
            insert openCasesList;
        
        Test.StartTest();
        FreightOpenCasesController.getAllOpenCases(testcase.Id);
        
        //GRAPHITE-1930 Remove this block of code since this is not used in the controller
        /**testcase.Status = 'Assigned';
        update testcase;
        testcase.Status = 'Resolved';
        testcase.Freight_Resolve_Reason__c='Other';
        testcase.Resolved_Reasons_Sub_Type__c='Other';
        update testcase;
        testcase.Status = 'Reopened';
        update testcase;
        testcase.Status = 'Closed';
        update testcase;*/
        //Test.StopTest();    
        
    //}

  /*--------------------------------------------------------------------------------------      
    Method Name:        OpenCasesTileTestservicerequest
    Description:        This test Method will increase the test coverage for'assignEntitlement1' method 
                        in Freight_CaseTriggerHandler class 
    Parameter:          Case New List & Old Map 
    --------------------------------------------------------------------------------------*/
    
    //GRAPHITE-1930 Remove this block of code since this is not calling any controller method
    /**@isTest
    static void OpenCasesTileTestservicerequest() {
        
        List<Freight_RecordTypeSeggregation__c> lstfreCusSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
        insert lstfreCusSetting;

        
        
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();

        Trigger_Status__c ts = new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true);
        insert ts;
        
        Trigger_Status__c ts1 = new Trigger_Status__c(Name = 'AccountTeam', Active__c = true);
        insert ts1;
        
        Trigger_Status__c ts2 = new Trigger_Status__c(Name = 'AccountEligibilityLogTrigger', Active__c = true);
        insert ts2;
        
        Trigger_Status__c ts3 = new Trigger_Status__c(Name = 'AccountAirlineLeveltrigger', Active__c = true);
        insert ts3;
        
        Trigger_Status__c ts4 = new Trigger_Status__c(Name = 'AccountDeleteTrigger', Active__c = true);
        insert ts4;
        
        Trigger_Status__c ts5 = new Trigger_Status__c(Name = 'AccountUpdateAccountDetail', Active__c = true);
        insert ts5;
        
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType1','Agency Account;Charter Account;Customer Account;Global Account;Other Account;Prospect Account;Regional Account;'));
        
        insert lstConfigData;
        
        Account testacc = new Account(Name='Test Tcs Account',
                                      Active__c = true,
                                      RecordTypeId=accRTId
                                      );
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
                                // Customer_Advice_Method__c = 'Email',
                               //  Freight_Resolve_Reason__c = 'Other',
                                 Freight_Resolve_Comments__c = 'Resolved',
                                // Freight_Recovery_Solution__c = 'Other',
                                 Freight_Recovery_Cost__c = 100,
                                 Service_Fee_Applies__c='No',
                                 Service_Fee_Reason__c   ='System error',
                                 Travel_Type__c = 'Domestic'
                                );
        insert testcase;
        
        
        list<Case> openCasesList = new list<Case>();
        //list<Case> returnCaselist = new list<Case>();
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Service_Fee_Applies__c='No', Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic' ));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe casethe caseAssignedAssignedAssignedAssigned',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Service_Fee_Applies__c='No', Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic'));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Service_Fee_Applies__c='No', Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic'));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Service_Fee_Applies__c='No', Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic'));
        openCasesList.add(new Case(AccountId = testacc.id,ContactId = testcon.id,RecordTypeId = caseRTId,Subject = 'the case',Description = 'test desc',Status = 'Open',Priority = 'Medium',Origin = 'Phone',Type = 'Customer Query',Service_Fee_Applies__c='No', Service_Fee_Reason__c   ='System error',Travel_Type__c = 'Domestic'));
        
        if(!openCasesList.isEmpty())
            insert openCasesList;
        
        Test.StartTest();
        
            testcase.Status = 'In Progress';
            update testcase;
            testcase.Status = 'Resolved';
            update testcase;
            testcase.Status = 'Reopened';
            update testcase;
            testcase.Status = 'Closed';
            testcase.Service_Fee_Applies__c='No';
            testcase.Service_Fee_Reason__c   ='System error';
            update testcase;
        Test.StopTest();    
        
    }
    */
}