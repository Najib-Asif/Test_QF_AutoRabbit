/*==============================================================================================================================
Author:         Gnanavelu
Purpose:        Test class for CaseTrigger and CaseTriggerHelper
Date:           19-Jul-2021
==============================================================================================================================
History:
19-Jul-2021     Gnanavelu          Initial Design
==============================================================================================================================*/
@isTest
public class QCC_TriggerAssignmentRulesTest {
    @testSetup
    static void createData() {
        Test.StartTest();
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
        
		// Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628        
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Customer_Advocacy_Agent_Permissions,Composer_User');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        
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
        
        // QAC Agency Credits Test data
        
        List<Trigger_Status__c> lsttrgStatus1 = TestUtilityDataClassQantas.createAssetTriggerSetting();
        insert lsttrgStatus1;
        
        Trigger_Status__c CaseTriggeragencyCreditFulfilment = new Trigger_Status__c();
        CaseTriggeragencyCreditFulfilment.Name = 'CaseTriggeragencyCreditFulfilment';
        CaseTriggeragencyCreditFulfilment.Active__c = true;
        insert CaseTriggeragencyCreditFulfilment;
        
        Test.StopTest();
        
    }
    
    static testMethod void TriggerAssignmentRulesCase() {
        String type = 'VIP Email Enquiries';
        String recordType = 'QCC_Assistance';
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        
        System.runAs(u1) {
            List<Contact> contacts = [SELECT Id, Name FROM Contact];
            Test.startTest();
            
           /* List<Case> cases1 = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, '','','','');
            System.debug('Case Owner = '+cases1[0].OwnerId ); 
            List<Id> recordIds = new List<Id>();
            System.debug('Case Owner = '+cases1);
            recordIds.add(cases1[0].Id);
            
            QCC_TriggerAssignmentRules.QCCTriggerAssignmentRules(recordIds);*/

            Test.stopTest();
        }
    }
}