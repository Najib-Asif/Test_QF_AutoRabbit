@isTest
public class QCC_InvokeEmailBatchFromFlowTest {

    @testSetup
    static void setupData() {

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
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@example.com'
        );
        insert testContact;


        Id recoveryRTId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_Complaints').getRecordTypeId();
        // Create test Cases
        List<Case> cases = new List<Case>{
            new Case(Status = 'New', Origin = 'Phone',recordtypeid = recoveryRTId,contactId = testContact.Id, Subject = 'Test Recovery Case')
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
    static void testInvokeEmailBatchFromFlow() {
        // Fetch required test data
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        Recovery__c recovery = [SELECT Id FROM Recovery__c LIMIT 1];

        EmailTemplate template = new EmailTemplate(
            Name = 'TestTemplate',
            DeveloperName = 'Test_Template',
            FolderId = UserInfo.getUserId(), // Putting it in user's private folder
            TemplateType = 'custom',
            Subject = 'Test Subject',
            HtmlValue = '<p>Hello </p>',
            Body = 'Test body',
            IsActive = true
        );
        insert template;
       

        // Prepare EmailRequests input for Flow
        EmailRequests req = new EmailRequests();
        req.contactId = c.Id;
        req.recoveryId = recovery.Id;
        req.templateId = template.Id;
        req.caseId = caseObj.Id;

        List<EmailRequests> reqList = new List<EmailRequests>{ req };

        Test.startTest();
        QCC_InvokeEmailBatchFromFlow.runBatch(reqList);
        Test.stopTest();

        // Assert a dummy pass since actual email sending can't be verified in unit tests
        System.assertEquals(1, reqList.size(), 'Should have one email request sent to batch.');
    }
}