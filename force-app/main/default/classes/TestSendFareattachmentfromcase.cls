/*----------------------------------------------------------------------------------------------------------------------
Author:         gnanavelu
Jira:           CRM-3506
Description:    Send Fare attachment (excel) from Salesforce Case to external address
Class:          QL_SendFareattachmentfromcase
************************************************************************************************************************
History
************************************************************************************************************************
12-Feb-2019      gnanavelu               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class TestSendFareattachmentfromcase 
{

    @testSetup
    static void createData() {

        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic','Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic','Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode International','International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational','   Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible','Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed','Closed'));
            
        insert lstConfigData;

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();


        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
             Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Consultant').Id,
             EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
             TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
             );
        insert u1;
        
        List<Contact> contacts = new List<Contact>();
        
        List<APXTConga4__Conga_Email_Template__c> congaEmailTemplates = TestUtilityDataClassQantas.createCongaEmailTemplates();
        insert congaEmailTemplates;

        List<APXTConga4__Conga_Template__c> congaTemplates = TestUtilityDataClassQantas.createCongaTemplates();
        insert congaTemplates;

        System.runAs(u1) {
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Email='test@mailinator.com', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services',Frequent_Flyer_Number__c = '12345' + i);
                contacts.add(con);
            }
            insert contacts;
        }
    }
    @isTest
    Static void SendEmailTest()
    {
        List<Account> AccList = TestUtilityDataClassQantas.getAccounts();
        
        List<Trigger_Status__c> Triggerstatus = TestUtilityDataClassQantas.enableTriggers();
        system.debug('triggerst'+Triggerstatus);
        Trigger_Status__c trgCaseFieldUpdates = new Trigger_Status__c(Name = 'trgCaseFieldUpdates',Active__c = false);
        insert trgCaseFieldUpdates;
        
        system.debug('triggerstcase'+trgCaseFieldUpdates);
        
        Case Testcase = new Case(AccountId = AccList[0].Id, Type = 'New Deal Load', Status= 'Assigned to Pricing for Fare Filing',
                                 Due_Date__c = date.Today(), PCC_DI__c = 'PCC', GDS_DI__c = 'Amadeus', Domestic_Spend__c = 12,
                                 International_Spend__c = 12, Total_Spend__c = 24, RecordTypeId='01290000001IINIAA4');
        
        insert Testcase;
        
        // Create Content Version
        ContentVersion contentVersion = new ContentVersion(Title = 'Rule_DocInvoice', PathOnClient = 'Penguins.jpg',
                                                           VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        
        insert contentVersion;
        
        List<ContentDocument> Documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = Testcase.id;
        cdl.ContentDocumentId = Documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;        
        
        Test.startTest();
        Testcase.Status = 'Assigned - Deal Support - Deal Sheet';
        update Testcase; 
        List<Case> Caselist = new List<Case>();
        Caselist.add(Testcase);
        QL_SendFareattachmentfromcase.SendEmail(Caselist);
        Test.stopTest();
    }
}