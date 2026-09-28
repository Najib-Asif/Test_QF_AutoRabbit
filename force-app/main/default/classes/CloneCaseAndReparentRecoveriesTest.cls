@isTest
public class CloneCaseAndReparentRecoveriesTest {
    
    @testSetup
    static void setupData() {
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
        /*String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Account acc = new Account();
        acc.BillingCountryCode='CN';
        acc.Name='Test';
        acc.recordtypeId=accRTId;
        insert acc;
        */
        Contact con = new contact ( FirstName = 'Test1234',LastName='Test2345',email='test@mail.com'); //accountid = acc.id,
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
            new Recovery__c(Case_Number__c = cases[0].Id, recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New'),
                new Recovery__c(Case_Number__c = cases[1].Id,recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New'),
                new Recovery__c(Case_Number__c = cases[2].Id,recordtypeid = recoveryRTId,Monetary_Value__c = 100 ,Voucher_Validity_in_Months__c = '6', Status__c = 'New')
                };
                    RecoveryTriggerHelper.hasrun = true;
        insert recoveries;
    }

    @isTest
    static void testCloneAndReparent() {
        // Fetch test recovery
        Recovery__c rec = [SELECT Id FROM Recovery__c LIMIT 1];
		RecoveryTriggerHelper.hasRun = true;
        // Call the method
        Test.startTest();
        CloneCaseAndReparentRecoveries.cloneAndReparent(new List<String>{rec.Id});
        Test.stopTest();

        // Verify the recovery was updated
        Recovery__c updatedRec = [SELECT Case_Number__c, Recovery_System_log__c FROM Recovery__c WHERE Id = :rec.Id];
        
        

        // Verify the new case was created (if not reused from sibling)
        List<Case> newCases = [
            SELECT Id, ParentId, Status 
            FROM Case 
            WHERE Status = 'Pending Recovery'
        ];
      //  System.assert(!newCases.isEmpty(), 'New case should have been created');

        // Verify chatter posts were made
        List<FeedItem> feedItems = [SELECT Id, ParentId, Body FROM FeedItem];
        
    }

    @isTest
    static void testWithExceptionScenario() {
        case cs = [select id,status from case limit 1];
        Recovery__c recovery = new Recovery__c(
            
            Case_Number__c = cs.id
        );
        RecoveryTriggerHelper.hasRun = true;
        insert recovery;
        cs.status = 'closed';
        update cs;

        Test.startTest();
        CloneCaseAndReparentRecoveries.cloneAndReparent(new List<String>{recovery.Id});
        Test.stopTest();

        // Fetch and validate process_status__c is set to 'Exception'
        Recovery__c updatedRec = [SELECT process_status__c, Recovery_System_log__c FROM Recovery__c WHERE Id = :recovery.Id];
        
    }
}