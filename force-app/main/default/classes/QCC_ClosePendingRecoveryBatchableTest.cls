@isTest
public class QCC_ClosePendingRecoveryBatchableTest {
    @testSetup
    static void setup() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        list<Trigger_Status__c> ts = new list<Trigger_Status__c>();
        ts.add(new Trigger_Status__c(name='RecoveryTriggerSubmitForFinalisation',Active__c =false));
        ts.add(new Trigger_Status__c(name='CaseTriggerV2',Active__c =false));
        ts.add(new Trigger_Status__c(name='isNotFrequentFlyerMember',Active__c =false));
        ts.add(new Trigger_Status__c(name='isFrequentFlyerMember',Active__c =false));
        ts.add(new Trigger_Status__c(name='updateRecoveryType',Active__c =false));
        ts.add(new Trigger_Status__c(name='setFulfilledBy',Active__c =false));
        ts.add(new Trigger_Status__c(name='handleRecoveryTrigger',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryInvokeLoyaltyPostService',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryTriggerUpdateCaseRecoveryValue',Active__c =false));
        ts.add(new Trigger_Status__c(name='getSuggestedRange',Active__c =false));
        ts.add(new Trigger_Status__c(name='routeCaseOnRecoveryPaymentUpdate',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryTriggerUpdateCaseRecoveryEvent',Active__c =false));
        ts.add(new Trigger_Status__c(name='RecoveryTriggerPostToChatter',Active__c =false));
        insert ts;
        Id recoveryRTId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_Complaints').getRecordTypeId();
        // Create test Cases
        List<Case> cases = new List<Case>{
            new Case(Status = 'Pending Recovery', Origin = 'Phone',recordtypeid = recoveryRTId),
            new Case(Status = 'Closed', Origin = 'Email',recordtypeid = recoveryRTId)
        };
        insert cases;
        Id otherRecvyRecTypeId = schema.SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('EFT_Recovery').getRecordTypeId();
        // Create test Recoveries related to the first Case
        List<Recovery__c> recoveries = new List<Recovery__c>{
            new Recovery__c(Case_Number__c = cases[0].Id, Status__c = 'Finalised', RecordTypeID = otherRecvyRecTypeId)
        };
        RecoveryTriggerHelper.hasrun = true;
        insert recoveries;
    }



    @isTest
    static void testFinalisedRecoveriesCaseUpdate() {
        
        Test.startTest();
        
        Database.executeBatch(new QCC_ClosePendingRecoveryCaseBatchable());
        Test.stopTest();

        // Verify Case is updated to Closed
      //  Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :targetCase.Id];
        //System.assertEquals('Closed', updatedCase.Status, 'Case should be closed after Recovery is finalised and batch runs.');
    }

}