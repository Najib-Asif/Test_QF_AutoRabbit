/***********************************************************************************************************************************

Description: Test class for QCC_casedeparturedatecalculation. 

History:
======================================================================================================================
Name                               Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan      Departure Date/Time field                                          T01
                                    
Created Date    :            16/07/2018 (DD/MM/YYYY)

**********************************************************************************************************************************/

@isTest
private class QCC_casedeparturedatecalculationTest {
    @testSetup
    static void createData() {

        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
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
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
               
        List<Contact> contacts = new List<Contact>();
        
        List<APXTConga4__Conga_Email_Template__c> congaEmailTemplates = TestUtilityDataClassQantas.createCongaEmailTemplates();
        insert congaEmailTemplates;

        List<APXTConga4__Conga_Template__c> congaTemplates = TestUtilityDataClassQantas.createCongaTemplates();
        insert congaTemplates;

        System.runAs(u1) {
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Email='test@mailinator.com', Business_Types__c='Agency',
                                          Frequent_Flyer_Number__c = '12345' + i, Job_Role__c='Agency Manager', Function__c='Advisory Services');
                contacts.add(con);
            }
            insert contacts;
        }
    }

static testMethod void CaseUpdateDepartureDateTime() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        List<Case> caseList = new List<Case>();
        Map<Id, Case> blankCaseMap = new Map<Id, Case>();
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Departure_Date_Time__c = '01/12/2000 07:00:00';
        cs.Actual_Arrival_Date_Time__c = '01/12/2001 04:00:00';
        cs.Updated_Departure_Date_Time__c= Date.Today();
        cs.TECH_Departure_Date_Time__c = '01/12/2001 04:00:00'; 
        caseList.add(cs);
        Test.startTest();
        insert caseList;
        Test.stopTest();
        List<Case> cases = [SELECT Tech_Departure_Date_Time__c , Tech_Actual_Arrival_Date_Time__c ,TECH_Departure_Date__c , TECH_Arrival_Date__c FROM Case Where Id =: caseList[0].Id];
        System.assert(cases != null);
        System.assert(cases.size() > 0);
    	System.debug('cases[0].Tech_Departure_Date_Time__c=====> ' + cases[0].Tech_Departure_Date_Time__c);
        //check for date
        System.assert(cases[0].Tech_Departure_Date_Time__c == '1 Dec 2000');
        
    }
}