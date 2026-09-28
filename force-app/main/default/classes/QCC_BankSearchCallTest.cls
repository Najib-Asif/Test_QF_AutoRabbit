/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_BankSearchCallTest {
    @testSetup
    static void setup() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        list<Trigger_Status__c> ts = new list<Trigger_Status__c>();
        ts.add(new Trigger_Status__c(name='RecoveryTriggerSubmitForFinalisation',Active__c =false));
        ts.add(new Trigger_Status__c(name='CaseTriggerV2',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryTriggerUpdateCaseRecoveryValue',Active__c =false));
        ts.add(new Trigger_Status__c(name='isNotFrequentFlyerMember',Active__c =false));
        ts.add(new Trigger_Status__c(name='isFrequentFlyerMember',Active__c =false));
        ts.add(new Trigger_Status__c(name='getSuggestedRange',Active__c =false));
        ts.add(new Trigger_Status__c(name='updateRecoveryType',Active__c =false));
        ts.add(new Trigger_Status__c(name='setFulfilledBy',Active__c =false));
        ts.add(new Trigger_Status__c(name='handleRecoveryTrigger',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryInvokeLoyaltyPostService',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryTriggerUpdateCaseRecoveryEvent',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryTriggerPostToChatter',Active__c =false));
        ts.add(new Trigger_Status__c(name='routeCaseOnRecoveryPaymentUpdate',Active__c =false));
        insert ts;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new contact (accountid = acc.id, FirstName = 'Test1234',LastName='Test2345',email='test@mail.com');
        insert con;
        Id recoveryCaseRTId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_On_The_Spot_Recovery').getRecordTypeId();
        // Create test Cases
        List<Case> cases = new List<Case>{
            new Case(Status = 'New', Origin = 'Phone',recordtypeid = recoveryCaseRTId,type='',First_Name__c ='Test First 1',Last_Name__c ='Test Last 1'),
                new Case(Status = 'Closed', Origin = 'Email',recordtypeid = recoveryCaseRTId,type='',First_Name__c ='Test First 2',Last_Name__c ='Test Last 2'),
                new Case(Status = 'New', Origin = 'Email',recordtypeid = recoveryCaseRTId,type='',First_Name__c ='Test First 3',Last_Name__c ='Test Last 3')
                };
                    insert cases;
        
        // Create test Recoveries related to the first Case
        Id recoveryRTId = SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('Travel_Voucher_Recovery').getRecordTypeId();
        List<Recovery__c> recoveries = new List<Recovery__c>
        {
            new Recovery__c(Case_Number__c = cases[0].Id, recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New',Cost_Centre_Account_Number__c ='EU Regulation :  EU Regulation (800301 : 712001)',Refund_Account__c='712001	(EU Regulation)',Refund_Cost_Centre__c = '800301	(EU Regulation)'),
                new Recovery__c(Case_Number__c = cases[1].Id,recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New',Cost_Centre_Account_Number__c ='EU Regulation :  EU Regulation (800301 : 712001)',Refund_Account__c='712001	(EU Regulation)',Refund_Cost_Centre__c = '800301	(EU Regulation)'),
                new Recovery__c(Case_Number__c = cases[2].Id,recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New',Cost_Centre_Account_Number__c ='EU Regulation :  EU Regulation (800301 : 712001)',Refund_Account__c='712001	(EU Regulation)',Refund_Cost_Centre__c = '800301	(EU Regulation)')
                };
                    RecoveryTriggerHelper.hasrun = true;
        insert recoveries;
    }
    
    @isTest
    static void testExecute1() {
        list<id> recordIds = new list<id>();
        for(Recovery__c rec : [select id from Recovery__c]){
            recordIds.add(rec.id);
        }
        
        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(0));
        
        QCC_BankSearchCall bankc = new QCC_BankSearchCall(recordIds);
        System.enqueueJob(bankc );
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecute2() {
        
        list<id> recordIds = new list<id>();
        for(Recovery__c rec : [select id from Recovery__c]){
            recordIds.add(rec.id);
        }
        
        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(1));
        
        QCC_BankSearchCall bankc = new QCC_BankSearchCall(recordIds);
        System.enqueueJob(bankc );
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecute3() {
        
        list<id> recordIds = new list<id>();
        for(Recovery__c rec : [select id from Recovery__c]){
            recordIds.add(rec.id);
        }
        
        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(2));
        
        QCC_BankSearchCall bankc = new QCC_BankSearchCall(recordIds);
        System.enqueueJob(bankc );
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecute4() {
        
        list<id> recordIds = new list<id>();
        for(Recovery__c rec : [select id from Recovery__c]){
            recordIds.add(rec.id);
        }
        delete  [select id from Recovery__c];
        
        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(2));
        
        QCC_BankSearchCall tvc = new QCC_BankSearchCall(recordIds);
        System.enqueueJob(tvc);

        Test.stopTest();
    }
    
    @isTest
    static void testExecute5() {
        list<id> recordIds = new list<id>();
        for(Recovery__c rec : [select id from Recovery__c]){
            recordIds.add(rec.id);
        }
        // delete  [select id from Recovery__c];
        
        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(3));
        
        QCC_BankSearchCall tvc = new QCC_BankSearchCall(recordIds);
        System.enqueueJob(tvc);

        Test.stopTest();
    }
    
    @isTest
    static void testExecute6() {
        
        list<id> recordIds = new list<id>();
        Recovery__c rec = new Recovery__c();
        
        recordIds.add(rec.id);
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(3));
        
        QCC_BankSearchCall tvc = new QCC_BankSearchCall(recordIds);
        System.enqueueJob(tvc);
        Test.stopTest();
    }
    
    @isTest
    static void testExecute7() {
        list<id> recordIds = new list<id>();
        for(Recovery__c rec : [select id from Recovery__c]){
            recordIds.add(rec.id);
        }
        
        Test.startTest();
        
        QCC_BankSearchCall tvc = new QCC_BankSearchCall(recordIds);
        System.enqueueJob(tvc);
        Test.stopTest();
    }
    
    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public MockHttpResponseGenerator(integer c){
            this.count =c;
        }
        public integer count;
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(this.count ==0){
                res.setBody('{"P_BANK_BRANCH_RECORDS" : {"P_BANK_BRANCH_RECORDS_ITEM" : [ {"CLAIM_NO" : "R01030955","BANK_COUNTRY" : "Australia","BANK_NAME" : "Commonwealth Bank Of Australia","BANK_BRANCH_NAME" : "Drummoyne (062157)","BRANCH_NUMBER" : "062157","EFT_SWIFT_CODE" : null,"BRANCH_ID" : "26229495","STATUS" : "SUCCESS","ERROR_CODE" : null,"MESSAGE" : null} ]},"P_OUT_RESULT" : "COMPLETED"}');
                res.setStatusCode(200);
            }
            
            if(this.count == 1){
                res.setBody('{"batch_reference": "12345", "batch_timestamp": "2024-01-01", "code": null, "message": "Success", "submit_status_details": [ {"referenceNumber": "20","campaign_reference": "233455","status": "SUCCESS","message": "OK"}]}');
                res.setStatusCode(404);
            }
            if(this.count == 2){
                res.setBody('{"P_BANK_BRANCH_RECORDS" : {"P_BANK_BRANCH_RECORDS_ITEM" : [ {"CLAIM_NO" : "R01030955","BANK_COUNTRY" : "Australia","BANK_NAME" : "Commonwealth Bank Of Australia","BANK_BRANCH_NAME" : "Drummoyne (062157)","BRANCH_NUMBER" : "062157","EFT_SWIFT_CODE" : "ZXCKJHSAKDHKJHK","BRANCH_ID" : "26229495","STATUS" : "SUCCESS","ERROR_CODE" : "EC02","MESSAGE" :"Test message"} ]},"P_OUT_RESULT" : "COMPLETED"}');
                res.setStatusCode(200);
            }
            if(this.count == 3){
                res.setBody('{"P_BANK_BRANCH_RECORDS" : {"P_BANK_BRANCH_RECORDS_ITEM" : [ {"CLAIM_NO" : "R01030955","BANK_COUNTRY" : "Australia","BANK_NAME" : "Commonwealth Bank Of Australia","BANK_BRANCH_NAME" : "Drummoyne (062157)","BRANCH_NUMBER" : "062157","EFT_SWIFT_CODE" : null,"BRANCH_ID" : "26229495","STATUS" : "SUCCESS","ERROR_CODE" : "EC05","MESSAGE" :"Test message"} ]},"P_OUT_RESULT" : "COMPLETED"}');
                res.setStatusCode(200);
            }
            return res;
        }
    }
}