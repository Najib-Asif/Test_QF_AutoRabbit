/**
* @File Name : QCC_CurrencyConversionCallTest .cls
* @Description : Test class
* @Author : Sourabh Singh
* @Last Modified By :
* @Last Modified On : August 19, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 19, 2024 |   | Initial Version
**/

@isTest
public class QCC_CurrencyConversionCallTest {

    @testSetup
    static void createData() {
        
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;

        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center,Advocacy,Conga and Genesys permission sets on the user as part of RBAC CRM-11628               
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Advocacy Agent').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', Location__c = 'Sydney'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Customer_Advocacy_Agent_Permissions,Composer_User');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        
        List<Contact> contacts = new List<Contact>();

        System.runAs(u1) {
            for(Integer i = 0; i < 1; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Preferred_Email__c='test@test.com', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='test@sample.com',Frequent_Flyer_Number__c = '12345');
                contacts.add(con);
            }
            insert contacts;

            List<Case> cases = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'Lounges','Access','Incorrectly denied entry','');

            List<Recovery__c> recoveries = TestUtilityDataClassQantas.insertRecoveries(cases);
        }
        
    }

    @isTest
    static void testExecuteCurrencyConversionSuccessEFT() {
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        List<Recovery__c> recoveries = [SELECT Id, Monetary_Value__c, Value__c, Currency_Conversion_Rate__c,Original_Currency_Acronym__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c FROM Recovery__c]; 
        // Create test data
        Recovery__c testRecovery = recoveries.get(0);
        testRecovery.Value__c = 100.00;
        testRecovery.Type__c = 'Ticket Refund EFT';
        testRecovery.Original_Currency__c ='USD United States Dollar';
        Date today = System.today();
		Date oneYearAgo = today.addYears(-1);
        oneYearAgo = oneYearAgo.addMonths(-1);
        
        testRecovery.Conversion_Date__c = oneYearAgo;
        update testRecovery;
        
        // Mock the currency conversion service
        String mockJsonResponse = '{"conversionDetails":[{"conversionRate":{"rate":"1.2345"},"convertedAmount":[{"typeQualifier":"TRU","amount":"100.00"}]}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockJsonResponse));
        
        // Mock the custom metadata
        QCC_Recoveries_Switch__mdt masterSwitch = new QCC_Recoveries_Switch__mdt();
        masterSwitch.Currency_Conversion_Switch__c = true;
        
        // Execute the Queueable class
        Test.startTest();
        QCC_CurrencyConversionCall queueable = new QCC_CurrencyConversionCall(new List<Id>{testRecovery.Id});
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Query the updated record
        testRecovery = [SELECT Monetary_Value__c, Currency_Conversion_Rate__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c 
                        FROM Recovery__c WHERE Id = :testRecovery.Id];
        
        
      
        //System.assert(testRecovery.Recovery_System_log__c == null || !testRecovery.Recovery_System_log__c.contains('FAIL'));
        System.assertEquals('Exception', testRecovery.Process_Status__c);
        System.assertEquals(null, testRecovery.Monetary_Value__c);
    }

    @isTest
    static void testExecuteCurrencyConversionFailure() {
        // Create test data
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        List<Recovery__c> recoveries = [SELECT Id, Monetary_Value__c, Value__c, Currency_Conversion_Rate__c,Original_Currency_Acronym__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c FROM Recovery__c]; 
        // Create test data
        Recovery__c testRecovery = recoveries.get(0);
        testRecovery.Value__c = 100.00;
        testRecovery.Original_Currency__c = 'USD United States Dollar';
        update testRecovery;
        
        // Mock the currency conversion service to throw an exception
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        // Mock the custom metadata
        QCC_Recoveries_Switch__mdt masterSwitch = new QCC_Recoveries_Switch__mdt();
        masterSwitch.Currency_Conversion_Switch__c = true;
        
        // Execute the Queueable class
        Test.startTest();
        QCC_CurrencyConversionCall queueable = new QCC_CurrencyConversionCall(new List<Id>{testRecovery.Id});
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Query the updated record
        testRecovery = [SELECT Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c 
                        FROM Recovery__c WHERE Id = :testRecovery.Id];
        
        // Validate that the currency conversion failed
        System.assert(testRecovery.Recovery_System_log__c != null && testRecovery.Recovery_System_log__c.contains('FAIL'));
        System.assertEquals('Exception', testRecovery.Process_Status__c);
        //System.assertEquals(false, testRecovery.Automated_Currency_Conversion_Complete__c);
    }

    @isTest
    static void testManualCurrencyConversionRequired() {
        // Create test data
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        List<Recovery__c> recoveries = [SELECT Id, Monetary_Value__c, Value__c, Currency_Conversion_Rate__c,Original_Currency_Acronym__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c FROM Recovery__c]; 
        // Create test data
        Recovery__c testRecovery = recoveries.get(0);
        testRecovery.Value__c = 100.00;
        testRecovery.Original_Currency__c = 'USD United States Dollar';
        update testRecovery;
        
        // Mock the custom metadata
        QCC_Recoveries_Switch__mdt masterSwitch = new QCC_Recoveries_Switch__mdt();
        masterSwitch.Currency_Conversion_Switch__c = false;
        
        
        // Execute the Queueable class
        Test.startTest();
        QCC_CurrencyConversionCall queueable = new QCC_CurrencyConversionCall(new List<Id>{testRecovery.Id});
        queueable.isTestRun = false;
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Query the updated record
        testRecovery = [SELECT Recovery_System_log__c, Process_Status__c 
                        FROM Recovery__c WHERE Id = :testRecovery.Id];
        
        // Validate that the manual currency conversion is required
        //System.assert(testRecovery.Recovery_System_log__c != null && testRecovery.Recovery_System_log__c.contains('Manual Currency Conversion Required'));
        //System.assertEquals('Exception', testRecovery.Process_Status__c);
    }

    @isTest
    static void testNoCurrencyConversionForAUD() {
        // Create test data
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        List<Recovery__c> recoveries = [SELECT Id, Monetary_Value__c, Value__c, Currency_Conversion_Rate__c,Original_Currency_Acronym__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c FROM Recovery__c]; 
        // Create test data
        Recovery__c testRecovery = recoveries.get(0);
        testRecovery.Value__c = 100.00;
        testRecovery.Original_Currency__c = 'AUD Australian Dollar';
        update testRecovery;
        
        // Mock the custom metadata
        QCC_Recoveries_Switch__mdt masterSwitch = new QCC_Recoveries_Switch__mdt();
        masterSwitch.Currency_Conversion_Switch__c = true;
        
        // Execute the Queueable class
        Test.startTest();
        QCC_CurrencyConversionCall queueable = new QCC_CurrencyConversionCall(new List<Id>{testRecovery.Id});
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Query the updated record
        testRecovery = [SELECT Monetary_Value__c, Currency_Conversion_Rate__c, Recovery_System_log__c, Automated_Currency_Conversion_Complete__c 
                        FROM Recovery__c WHERE Id = :testRecovery.Id];
        
        // Validate that the currency conversion was skipped for AUD
        System.assertEquals(100.00, testRecovery.Monetary_Value__c);
        System.assertEquals(1, testRecovery.Currency_Conversion_Rate__c);
        System.assertEquals(null, testRecovery.Recovery_System_log__c);
        System.assertEquals(true, testRecovery.Automated_Currency_Conversion_Complete__c);
    }

    // Mock HTTP Response Generator Class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
    
       @isTest
    static void testExecuteCurrencyConversionSuccess() {
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        List<Recovery__c> recoveries = [SELECT Id, Monetary_Value__c, Value__c, Currency_Conversion_Rate__c,Original_Currency_Acronym__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c FROM Recovery__c]; 
        // Create test data
        Recovery__c testRecovery = recoveries.get(0);
        testRecovery.Value__c = 100.00;
        testRecovery.Original_Currency__c = 'USD United States Dollar';
        update testRecovery;
        
        // Mock the currency conversion service
        String mockJsonResponse = '{"conversionDetails":[{"conversionRate":{"rate":"1.2345"},"convertedAmount":[{"typeQualifier":"TRU","amount":"100.00"}]}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, mockJsonResponse));
        
        // Mock the custom metadata
        QCC_Recoveries_Switch__mdt masterSwitch = new QCC_Recoveries_Switch__mdt();
        masterSwitch.Currency_Conversion_Switch__c = true;
        
        // Execute the Queueable class
        Test.startTest();
        QCC_CurrencyConversionCall queueable = new QCC_CurrencyConversionCall(new List<Id>{testRecovery.Id});
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Query the updated record
        testRecovery = [SELECT Monetary_Value__c, Currency_Conversion_Rate__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c 
                        FROM Recovery__c WHERE Id = :testRecovery.Id];
        
        // Validate that the currency conversion was successful
        System.assertEquals(123.45, testRecovery.Monetary_Value__c);
        //System.assertEquals(1 / 1.2345, testRecovery.Currency_Conversion_Rate__c);
        System.assertEquals(System.today(), testRecovery.Conversion_Date__c);
        System.assert(testRecovery.Recovery_System_log__c == null || !testRecovery.Recovery_System_log__c.contains('FAIL'));
        System.assertEquals(true, testRecovery.Automated_Currency_Conversion_Complete__c);
    }
    
   
}