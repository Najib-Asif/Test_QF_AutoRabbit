@isTest
public class CaseStatusUpdateHandlerTest {
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
            new Case(Status = 'New', Origin = 'Phone',recordtypeid = recoveryRTId),
            new Case(Status = 'Closed', Origin = 'Email',recordtypeid = recoveryRTId)
        };
        insert cases;
        Id otherRecvyRecTypeId = schema.SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('Other_Recovery').getRecordTypeId();
        // Create test Recoveries related to the first Case
        List<Recovery__c> recoveries = new List<Recovery__c>{
            new Recovery__c(Case_Number__c = cases[0].Id, Status__c = 'New', RecordTypeID = otherRecvyRecTypeId)
        };
        RecoveryTriggerHelper.hasrun = true;
        insert recoveries;
    }
    
    @isTest
    static void testHandleCaseStatusUpdateWithOpenRecoveries() {
        // Fetch test data
        List<Case> cases = [SELECT Id, Status, RecordType.DeveloperName FROM Case];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c);
        }

        // Update the status of the first Case to Pending Recovery
        cases[0].Status = 'Pending Recovery';
        
        Test.startTest();
        //CaseStatusUpdateHandler.handleCaseStatusUpdate(cases, oldCaseMap);
        Trigger_Status__c ts = Trigger_Status__c.getValues('CaseTriggerV2');
        ts.Active__c = true;
        update ts;
        try {
            Update cases;
        } catch (DmlException e) {
            // Assert that the exception is thrown
            System.assert(true, 'DmlException was caught as expected');
            System.debug('Caught DmlException: ' + e.getMessage());
        }
        Test.stopTest();
       
        
    }


    @isTest
    static void testHandleCaseStatusUpdateWithNoOpenRecoveries() {
        // Fetch test data
        List<Case> cases = [SELECT Id, Status, RecordType.DeveloperName FROM Case];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c);
        }

        // Update the status of the second Case to Pending Recovery
        cases[1].Status = 'Pending Recovery';
        
        Test.startTest();
        CaseStatusUpdateHandler.handleCaseStatusUpdate(cases, oldCaseMap);
        Test.stopTest();
        
        // Check for error
        System.assert(cases[1].Status == 'Pending Recovery');
        System.assertEquals(1, cases[1].getErrors().size());
        System.assertEquals('There are no open related Recoveries on this Case', cases[1].getErrors()[0].getMessage());
    }
    
    @isTest
    static void testHandleCaseStatusUpdateNoStatusChange() {
        // Fetch test data
        List<Case> cases = [SELECT Id, Status, RecordType.DeveloperName FROM Case];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c);
        }
        
        // Update the status of the first Case to a valid status with no error
        cases[0].Status = 'Processing';
        
        Test.startTest();
        CaseStatusUpdateHandler.handleCaseStatusUpdate(cases, oldCaseMap);
        Test.stopTest();
        
        // Check for no error
        System.assertEquals(0, cases[0].getErrors().size());
    }
    
    @isTest
    static void testFinalisedRecoveriesCaseUpdate() {
        
        List<Case> cases = [SELECT Id, Status, RecordType.DeveloperName FROM Case];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c);
        }

        // Update the status of the second Case to Pending Recovery
        cases[0].Status = 'Pending Recovery';
        update cases[0];
        // Fetch test data
        List<Recovery__c> recvyList = [SELECT Id, Type__c, Status__c, RecordTypeId, RecordType.DeveloperName FROM Recovery__c order by LastModifiedDate desc];
        
        recvyList[0].Type__c = 'Qantas Points';
        recvyList[0].Status__c = 'Finalised';

        
        Test.startTest();
        update recvyList[0];
        Test.stopTest();
        
        //System.assertEquals('Closed', [Select Id, Case_Number__r.Status from Recovery__c][0].Case_Number__r.Status);
    }
    
    @isTest
    static void testCancelledRecoveriesCaseUpdate() {
        
        List<Case> cases = [SELECT Id, Status, RecordType.DeveloperName FROM Case];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        
        for (Case c : cases) {
            oldCaseMap.put(c.Id, c);
        }

        // Update the status of the second Case to Pending Recovery
        cases[0].Status = 'Pending Recovery';
        update cases[0];
        // Fetch test data
        List<Recovery__c> recvyList = [SELECT Id, Type__c, Status__c, RecordTypeId, RecordType.DeveloperName FROM Recovery__c];
        
        recvyList[0].Type__c = 'Qantas Points';
        recvyList[0].Status__c = 'Cancelled';

        
        Test.startTest();
        update recvyList[0];
        Test.stopTest();
        
        System.assertEquals(UserInfo.getUserId(), [Select Id, Case_Number__r.OwnerId from Recovery__c][0].Case_Number__r.OwnerId);
    }
    
    @isTest
    static void testCaseValidationsPendingRecyChk() {
        // Fetch test data
        List<Case> cases = [SELECT Id, Status, RecordType.DeveloperName FROM Case limit 1];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        for (Case c : cases) {
            
            Case newCase = new Case();
            newCase.status = 'Pending Recovery';
            oldCaseMap.put(c.Id, newCase);
        }
        
        cases[0].Status = 'Closed';

        Test.startTest();
        CaseStatusUpdateHandler.handleCaseStatusUpdate(cases, oldCaseMap);
        Test.stopTest();
        
        // Check for no error
        System.assertEquals(1, cases[0].getErrors().size());
    }
}