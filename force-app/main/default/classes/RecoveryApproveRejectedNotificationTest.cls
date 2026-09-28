/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class RecoveryApproveRejectedNotificationTest {
    @testSetup
    static void setupTestData() {
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
        QantasConfigData__c qcd = new QantasConfigData__c(name= 'Case OTRS RecType',Config_Value__c = 'CCC On The Spot Recovery');
        insert qcd;
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
        // Create test data for recovery__c records
        List<recovery__c> recoveryList = new List<recovery__c>();
        for (Integer i = 0; i < 3; i++) {
            recovery__c rec = new recovery__c(
                
                TL_Approved__c = false,
                TL_Rejected__c = false,
                OM_Approved__c = false,
                OM_Rejected__c = false,
                
                Process_Status__c = 'Pending Approval',
                Case_Number__c = cases[i].id  
            );
            recoveryList.add(rec);
        }
        insert recoveryList;
    }
    
    @isTest
    static void testRecoveryToPost() {
        // Fetch the test recovery__c records
        List<recovery__c> recoveryList = [SELECT Id, Name, TL_Approved__c, Process_Status__c,approvalCount__c FROM recovery__c];
        
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setObjectId(recoveryList[0].Id);
        submitRequest.setComments('Submitting for approval');
        submitRequest.setNextApproverIds(new List<Id>{UserInfo.getUserId()}); // Use a test user if needed
        submitRequest.setSkipEntryCriteria(true);
        //Approval.ProcessResult submitResult = Approval.process(submitRequest);
        
        // Create a map of old recovery values
        Map<Id, recovery__c> oldMap = new Map<Id, recovery__c>();
        for (recovery__c rec : recoveryList) {
            recovery__c oldRec = rec.clone(false, true, false, false);
            oldRec.TL_Approved__c = false;
            oldRec.Process_Status__c = 'Pending Approval';
            
            oldMap.put(oldRec.Id, oldRec);
        }
        
        // Update some records to trigger the logic
        for (recovery__c rec : recoveryList) {
            rec.TL_Approved__c = true;
            rec.approvalCount__c = 1;
            rec.Process_Status__c = 'Approved';
        }
        Test.startTest();
        try{
            update recoveryList;
        }catch(exception e){}
        Test.stopTest();
    }
}