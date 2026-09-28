/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.  
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_TravelVoucherCallTest {
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
        insert new Qantas_API__c( Name = 'TV_Encryption_Key', Token__c =     EncodingUtil.base64Encode(Crypto.generateAesKey(256))  );
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
            new Recovery__c(Case_Number__c = cases[0].Id, recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New',Cost_Centre_Account_Number__c ='Customer Care : Ex Gratia Passenger (309276 : 718017)', Voucher_Number__c = '10986747', Refund_Account__c='718017	(Ex Gratia Passenger)',Refund_Cost_Centre__c = '309276	(Customer Care)'),
                new Recovery__c(Case_Number__c = cases[1].Id,recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New',Cost_Centre_Account_Number__c ='Customer Care : Ex Gratia Passenger (309276 : 718017)', Voucher_Number__c = '10986748', Refund_Account__c='718017	(Ex Gratia Passenger)',Refund_Cost_Centre__c = '309276	(Customer Care)'),
                new Recovery__c(Case_Number__c = cases[2].Id,recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New',Cost_Centre_Account_Number__c ='Customer Care : Ex Gratia Passenger (309276 : 718017)',Voucher_Number__c = '10986749', Refund_Account__c='718017	(Ex Gratia Passenger)',Refund_Cost_Centre__c = '309276	(Customer Care)')
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
        
        QCC_TravelVoucherCall tvc = new QCC_TravelVoucherCall(recordIds);
        System.enqueueJob(tvc);
        
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
        
        QCC_TravelVoucherCall tvc = new QCC_TravelVoucherCall(recordIds);
        System.enqueueJob(tvc);
        
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
        
        QCC_TravelVoucherCall tvc = new QCC_TravelVoucherCall(recordIds);
        System.enqueueJob(tvc);
        
        Test.stopTest();
    }
    
    @isTest
    static void testExecute4() {
        
        list<id> recordIds = new list<id>();
        for(Recovery__c rec : [select id from Recovery__c]){
            recordIds.add(rec.id);
        }
        
        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(2));
        
        QCC_TravelVoucherCall tvc = new QCC_TravelVoucherCall(recordIds);
        System.enqueueJob(tvc);
        
        Test.stopTest();
    }

    @isTest
    static void testExecute5() {
        
        List<Id> recordIds = new List<id>();
        List<Recovery__c> recoveries = New List<Recovery__c>([SELECT Id, Name,  Contact_First_Name__c,Contact_LastName__c, Case_Number__c, recordtypeid, Monetary_Value__c, Voucher_Validity_in_Months__c, 
                                                              Status__c, Cost_Centre_Account_Number__c, Refund_Account__c, Refund_Cost_Centre__c, Refund_Cost_Centre_Number__c, Refund_Account_Number__c,
                                                              Voucher_Number__c
                                                              FROM Recovery__c]);
        
        for(Recovery__c rec: recoveries){
            recordIds.add(rec.Id);
        }
        
        // Mock the HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(2));
        QCC_TravelVoucherCallHelper.createRecoveryJson(recordIds, Date.today());        
        QCC_TravelVoucherCallHelper.checkTravelVoucherNumber(recoveries, new Map<Id, Recovery__c>(recoveries));
        QCC_TravelVoucherCallHelper.updateRecoveries(recordIds,  QCC_TravelVoucherCallHelper.createRecoveryJson(recordIds, Date.today()), false, '');
        QCC_TravelVoucherCallHelper.SubmitStatusDetail objSatus = new QCC_TravelVoucherCallHelper.SubmitStatusDetail();
        objSatus.referenceNumber = 'Test'; objSatus.campaign_reference = 'Test'; objSatus.status = 'Test' ; objSatus.message = 'None'; objSatus.errorCode = 'None';        
        QCC_TravelVoucherCallHelper.BatchStatus objBatchSta = new QCC_TravelVoucherCallHelper.BatchStatus ();
        objBatchSta.batch_timestamp = 'Batch Stamp'; objBatchSta.code = '20'; objBatchSta.message = 'No Message'; objBatchSta.description = 'Batch Description';         
        QCC_TravelVoucherCallHelper.createNoteForRecord(recoveries[0].Id, 'Title', 'noteBody');  
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
                res.setBody('{"batch_reference": "12345", "batch_timestamp": "2024-01-01", "code": null, "message": "Success", "submit_status_details": [ {"referenceNumber": "20","campaign_reference": "233455","status": "SUCCESS","message": "OK"}]}');
                res.setStatusCode(200);
            }
            if(this.count == 1){
                res.setBody('{"batch_reference": "12345", "batch_timestamp": "2024-01-01", "code": null, "message": "Success", "submit_status_details": [ {"referenceNumber": "20","campaign_reference": "233455","status": "SUCCESS","message": "OK"}]}');
                res.setStatusCode(404);
            }
            if(this.count == 2){
                res.setBody('{"code": "900901","message": "Invalid Credentials","description": "Invalid Credentials. Make sure you have provided the correct security credentials" , "submit_status_details": [ {"referenceNumber": "20","campaign_reference": "233455","status": "FAIL","message": "Failed"}]}');
                res.setStatusCode(200);
            }
            return res;
        }
    }
}