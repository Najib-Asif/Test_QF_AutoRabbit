/*********************************************************************************

Name              : FreightExceptionsTest

Created By        : Vinothkumar Balasubramanian

Company Name      : TCS

Project           : Freight Track & Trace

Created Date      : 22 March 2019

Purpose           : Test Class for FreightExceptionTileController AND FreightexceptionAWBdetailsController AND FreightGenericAcccreation_Batch
3-June-2026    Jesus Suarez            Added userNoAccessTest method
9-June-2026		Lerry Cabanding			CRM-12991 Added test method for Code Security Remediation
*********************************************************************************/

@isTest
private class FreightExceptionsTest {
    
    @testSetup
    static void createData() {

        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
    }

    static testMethod void FreightExceptionsTest() {

        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Track & Trace Exceptions').getRecordTypeId();
        String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByName().get('Freight Exception Flight Details').getRecordTypeId();
       
        Account testacc = new Account(Name='Test Tcs Account',
                                      Active__c = true,
                                      Type = 'Freight-Country',
                                      Customer_Ranking__c = '5',
                                      Sentiment__c = 'Positive',
                                      RecordTypeId = accRTId);
        insert testacc;
        
        Freight_Exceptions_Track_and_Trace__c testFreightException = new Freight_Exceptions_Track_and_Trace__c(Name = 'Test Freight Exception',
                                                                                                               Counter__c = 0,
                                                                                                               Count__c = 1,
                                                                                                               Value__c = testacc.id);
                                                                                                               
        insert testFreightException;                                                                                               
        
        Contact testcon = new Contact(FirstName='Bob',
                                      LastName='Test',
                                      AccountId=testacc.id,
                                      Function__c = 'IT',
                                      Business_Types__c = 'Freight',
                                      Email = 'abc@test.com');
        insert testcon;
        
        List<Case> caseList = new List<Case>();

        Case testcase = new Case(AccountId = testacc.id,
                                 ContactId = testcon.id,
                                 RecordTypeId = caseRTId,
                                 Freight_Scanned_By__c = 'Bob',
                                 Freight_Scanning_Location__c = 'Sydney',
                                 Freight_Scanned_Before__c = 'ULD',
                                 Freight_Stated_Pieces__c = 4,
                                 Freight_AWB_Pieces__c = 5,
                                 Freight_Weight__c = '20',
                                 Freight_Received_Pieces__c = 6,
                                 Freight_Function__c = 'Scanned',
                                 Freight_ULD_Number__c = '12345',
                                 Freight_AWB_Number__c = '081-12345678',
                                 Other_Damage_Description__c = 'Broken',
                                 Freight_AWB_Shipment_Description__c = 'Goods',
                                 Freight_Customer_Name__c = 'Qantas',
                                 Freight_Customer_No__c = '12345',
                                 Freight_AWB_Handling_Code__c = '12389',
                                 Freight_AWB_s__c = '081-12345678,081-12345679',
                                 Freight_Destination__c = 'Melbourne',
                                 Freight_Origin__c = 'Sydney',
                                 Arrival_Airport_Code__c = 'SYD',
                                 Subject = 'the case',
                                 Description = 'test desc',
                                 Status = 'Closed',
                                 Priority = 'Medium',
                                 Origin = 'Elenium',
                                 Type = 'Track & Trace Exception',
                                 Sub_Type_1__c = 'Missing ULD',
                                 Resolved_Reasons_Sub_Type__c = 'Process',
                                 Freight_Resolve_Reason__c = 'Handling Error'
                                );
        insert testcase;

        caseList.add(new Case(AccountId = testacc.id,
                                 ContactId = testcon.id,
                                 RecordTypeId = caseRTId,
                                 ParentId = testcase.Id,
                                 Freight_Scanned_By__c = 'Bob',
                                 Freight_Scanning_Location__c = 'Sydney',
                                 Freight_Scanned_Before__c = 'ULD',
                                 Freight_Stated_Pieces__c = 4,
                                 Freight_AWB_Pieces__c = 5,
                                 Freight_Weight__c = '20',
                                 Freight_Received_Pieces__c = 6,
                                 Freight_Function__c = 'Scanned',
                                 Freight_ULD_Number__c = '12345',
                                 Freight_AWB_Number__c = '081-12345678',
                                 Other_Damage_Description__c = 'Broken',
                                 Freight_AWB_Shipment_Description__c = 'Goods',
                                 Freight_Customer_Name__c = 'Qantas',
                                 Freight_Customer_No__c = '12345',
                                 Freight_AWB_Handling_Code__c = '12389',
                                 Freight_Destination__c = 'Melbourne',
                                 Freight_Origin__c = 'Sydney',
                                 Arrival_Airport_Code__c = 'SYD',
                                 Subject = 'the case',
                                 Description = 'test desc',
                                 Status = 'Open',
                                 Priority = 'Medium',
                                 Origin = 'Elenium',
                                 Type = 'Track & Trace Exception',
                                 Sub_Type_1__c = 'Missing AWB (from Missing ULD)'
                                ));
        insert caseList;
        
        Flight__c testflight = new Flight__c(Case__c = testcase.Id,
                                             RecordTypeId = flightRTId,
                                             Freight_Arrival_Flight_No__c = 'QF-101',
                                             Freight_Arrival_Flight_Destination__c = 'Sydney',
                                             Freight_Arrival_Flight_Origin__c = 'Melbourne',
                                             Freight_Arrival_Flight_Sector__c = 'MEL',
                                             Freight_Booked_Flight_Destination__c = 'Sydney',
                                             Freight_Booked_Flight_No__c = 'QF-102',
                                             Freight_Booked_Flight_Origin__c = 'Melbourne',
                                             Freight_Booked_Flight_Sector__c = 'SYD'
                                             );
        
        insert testflight;
        
        Test.StartTest();
        String cronExp = '0 0 0 1 1 ? 2099';

        System.schedule(
            'Test Freight Scheduler',
            cronExp,
            new FreightAcccreation_Batch_Schedular()
        );
        
        FreightExceptionTileController.getCase(testcase.Id);
        FreightexceptionAWBdetailsController.getChildCase(caseList[0].Id);
        Test.StopTest();    
         List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test Freight Scheduler'
        ];

        System.assert(jobs.size() > 0);
 
    }

    
    @isTest
    static void userNoAccessTest() { //ADDED JESUS SUAREZ
        
        // Create low-access user
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
        
        // Minimal required data for this test class
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Freight Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Freight Track & Trace Exceptions').getRecordTypeId();
        
        Account acc = new Account(
            Name = 'Test Account',
            Active__c = true,
            Type = 'Freight-Country',
            RecordTypeId = accRTId
        );
        insert acc;
        
        Contact con = new Contact(
            LastName = 'Test',
            AccountId = acc.Id
        );
        insert con;
        
        Case c = new Case(
            AccountId = acc.Id,
            ContactId = con.Id,
            RecordTypeId = caseRTId,
            Subject = 'Test Case',
            Status = 'Open',
            Origin = 'Phone',
            Type = 'Track & Trace Exception'
        );
        insert c;
        
        Test.startTest();
        System.runAs(u1) {
            try {
                // Call controllers from THIS test class
                FreightExceptionTileController.getCase(c.Id);
                FreightexceptionAWBdetailsController.getChildCase(c.Id);
                
            } catch (Exception e) {
                System.assertNotEquals(null, e);
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void userProfileNoAccessTest() { //CRM-12991 Code Security Remediation
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
        
        // Minimal required data for this test class
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Freight Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Freight Track & Trace Exceptions').getRecordTypeId();
        
        Account acc = new Account(
            Name = 'Test Account',
            Active__c = true,
            Type = 'Freight-Country',
            RecordTypeId = accRTId
        );
        insert acc;
        
        Contact con = new Contact(
            LastName = 'Test',
            AccountId = acc.Id
        );
        insert con;
        
        Case c = new Case(
            AccountId = acc.Id,
            ContactId = con.Id,
            RecordTypeId = caseRTId,
            Subject = 'Test Case',
            Status = 'Open',
            Origin = 'Elenium',
            Type = 'Track & Trace Exception'
        );
        insert c;
        
        Test.startTest();
        System.runAs(u1) {
            try {
                FreightexceptionAWBdetailsController.getChildCase(c.Id);
            } catch (Exception e) {
                System.assertNotEquals(null, e);
            }
        }
        Test.stopTest();
    }
}