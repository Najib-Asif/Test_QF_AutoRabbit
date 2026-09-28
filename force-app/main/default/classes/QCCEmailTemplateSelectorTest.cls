@isTest
public with sharing class QCCEmailTemplateSelectorTest {
    @TestSetup
    static void makeData(){
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Contact> conList = TestUtilityDataClassQantas.getContacts(accList);

        Case thecase = new Case();
        thecase.AccountId = accList[0].Id;
        thecase.ContactId = conList[0].Id;
        thecase.RecordTypeId = [SELECT Id,Name, SobjectType FROM RecordType WHERE SobjectType ='Case' AND Name = 'CCC Complaints'].Id;
        thecase.Origin='Email';
        thecase.Description='adsf';
        thecase.Status='New';
        thecase.Type='Complaint';
        thecase.Group__c='Contact Centre';
        thecase.Category__c='Staff Assistance';

        insert thecase;

    }
    
    @isTest
    static void testGetEmailTemplates(){
        List<List<EmailTemplate>> theEmailTemplateList;
        List<Case> theCasesList = [SELECT Id FROM Case Limit 1];
        List<Id> caseIds = new List<Id>{theCasesList[0].Id};
        Test.startTest();
            theEmailTemplateList = QCCEmailTemplateSelector.getEmailTemplates(caseIds);
        Test.stopTest();
        System.debug('===in test method theEmailTemplateList.size===='  + theEmailTemplateList.size());
        System.assert(theEmailTemplateList != null);

    }
}