/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham
Company:       Capgemini
Description:   Test Class for QCC_RecoveryController_CC and RecoveryTriggerHelper
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
31-Jan-2018    Purushotham   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
private class QCC_RecoveryController_CC_Test {
     private static final Id RTID_Rec_OtherRecovery = GenericUtils.getObjectRecordTypeId('Recovery__c', 'Other Recovery');
    @testSetup
    static void createData() {
        Test.startTest();
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;

        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
		// Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center,Conga,Advocacy and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Advocacy Agent').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', Location__c = 'Sydney'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Customer_Advocacy_Agent_Permissions,Composer_User');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        
        List<Contact> contacts = new List<Contact>();

        System.runAs(u1) {
            for(Integer i = 0; i < 1; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Preferred_Email__c='test@test.com', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='test@sample.com',Frequent_Flyer_Number__c = '12345');
                contacts.add(con);
            }
            insert contacts;

            List<Case> cases = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'Lounges','Access','Incorrectly denied entry','');

            List<Recovery__c> recoveries = TestUtilityDataClassQantas.insertRecoverieswithRecType(cases,RTID_Rec_OtherRecovery,'New','New');
        }
        Test.stopTest();
    }
    
    // Single Case
    static testMethod void testGetSuggestedRange1() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Recovery__c> recoveries = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
            Test.startTest();
            for(Integer i = 0; i < recoveries.size(); i++) {
                //String result = QCC_RecoveryController_CC.getSuggestedRange(recoveries[i].id);
                System.assertEquals(0, recoveries[i].Suggested_Minimum__c);
                System.assertEquals(2000, recoveries[i].Suggested_Maximum__c);
            }
            Test.stopTest();
        }
    }

    // Multiple Cases with same coding value
    static testMethod void testGetSuggestedRange2() {
        String recordType = 'CCC Complaints';
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Contact> contacts = [SELECT Id FROM Contact];
            Test.startTest();
            List<Case> cases = TestUtilityDataClassQantas.insertCases(contacts, recordType, 'Complaint', 'Lounges','Access','Incorrectly denied entry','');
            
            List<Recovery__c> newRecoveries = TestUtilityDataClassQantas.insertRecoveries(cases);
            List<Recovery__c> recoveries = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
            for(Integer i = 0; i < recoveries.size(); i++) {
                //String result = QCC_RecoveryController_CC.getSuggestedRange(recoveries[i].id);
                System.assertEquals(0, recoveries[i].Suggested_Minimum__c);
                System.assertEquals(2000, recoveries[i].Suggested_Maximum__c);
            }
            Test.stopTest();
        }
    }

    // Case with Case Category records
    static testMethod void testGetSuggestedRange3() {        
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Case> cases = [SELECT Id, ContactId FROM Case];
            Set<Id> recoveryIds = new Set<Id>();
            List<Case_Category__c> caseCategories = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'Flight Disruptions','Downgrade','QF Booking Throughfare','');
            Test.startTest();
            insert caseCategories;
            List<Recovery__c> newRecoveries = TestUtilityDataClassQantas.insertRecoveries(cases);
            for(Recovery__c rec: newRecoveries) {
                recoveryIds.add(rec.Id);
            }
            List<Recovery__c> recoveries = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id = :recoveryIds];
            for(Integer i = 0; i < recoveries.size(); i++) {
                /*String result = QCC_RecoveryController_CC.getSuggestedRange(recoveries[i].id);
                System.assertEquals('5000,12000,Complaint,true,0,Open', result);*/
                System.assertEquals(5000, recoveries[i].Suggested_Minimum__c);
                System.assertEquals(12000, recoveries[i].Suggested_Maximum__c);
            }
            Test.stopTest();
        }
    }

    // With flight duration and Gold Tier
    static testMethod void testGetSuggestedRange4() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        /*Contact con = new Contact(LastName='Gold', FirstName='User', Preferred_Email__c='golduser@test.com', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='golduser@sample.com',Frequent_Flyer_Tier__c = 'Gold');
        insert con;*/
        System.runAs(usr) {
            Set<Id> recoveryIds = new Set<Id>();
            List<Contact> contacts = [SELECT Id FROM Contact];
            
            for(Contact con: contacts) {
                con.Frequent_Flyer_Tier__c = 'Gold';
            }
            update contacts;

            List<Case> cases = [SELECT Id, ContactId, Arrival_Date_Time__c, Departure_Date_Time__c FROM Case WHERE ContactId = :contacts[0].Id];
            for(Case cs: cases) {
                cs.Departure_Date_Time__c = '01/12/2017 06:00:00';
                cs.Arrival_Date_Time__c = '01/12/2017 11:00:00';
            }
            Test.startTest();
            update cases;
            List<Case_Category__c> caseCategories = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'Flight Disruptions','Downgrade','QF Booking Throughfare','');
            insert caseCategories;
            List<Recovery__c> newRecoveries = TestUtilityDataClassQantas.insertRecoveries(cases);
            for(Recovery__c rec: newRecoveries) {
                recoveryIds.add(rec.Id);
            }
            List<Recovery__c> recoveries = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id = :recoveryIds];
            
            for(Integer i = 0; i < recoveries.size(); i++) {
                /*String result = QCC_RecoveryController_CC.getSuggestedRange(recoveries[i].id);
                System.assertEquals('10000,18000,Complaint,true,0,Open', result);
                System.assertEquals(5000, recoveries[i].Suggested_Minimum__c);
                System.assertEquals(13000, recoveries[i].Suggested_Maximum__c);*/
            }
            Test.stopTest();
        }
    }

    // With flight duration and Gold Tier
    static testMethod void testGetSuggestedRange5() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            Set<Id> recoveryIds = new Set<Id>();
            List<Contact> contacts = [SELECT Id, Frequent_Flyer_Tier__c FROM Contact];
            /*for(Contact con: contacts) {
                con.Frequent_Flyer_Tier__c = 'Gold';
            }
            update contacts;*/
            List<Case> setupCases = [SELECT Id, ContactId FROM Case];
            List<Case_Category__c> setupCaseCategories = TestUtilityDataClassQantas.insertCaseCategories(setupCases, 'Complaint', 'Flight Disruptions','Seating Change','','');
            Test.startTest();
            insert setupCaseCategories;
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Complaints', 'Complaint', 'Flight Disruptions','Seating Change','','');
                cs.ContactId = con.Id;
                cs.Departure_Date_Time__c = '01/12/2017 06:00:00';
                cs.Arrival_Date_Time__c = '01/12/2017 11:00:00';
                cases.add(cs);
            }
            
            insert cases;
            List<Case_Category__c> caseCategories = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'Lounges','Access','Incorrectly denied entry','');
            insert caseCategories;
            List<Recovery__c> newRecoveries = TestUtilityDataClassQantas.insertRecoveries(cases);
            for(Recovery__c rec: newRecoveries) {
                recoveryIds.add(rec.Id);
            }
            List<Recovery__c> recoveries = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id = :recoveryIds];
            
            for(Integer i = 0; i < recoveries.size(); i++) {
                /*String result = QCC_RecoveryController_CC.getSuggestedRange(recoveries[i].id);
                System.assertEquals('0,4000,Complaint,true,0,Open', result);*/
                System.assertEquals(0, recoveries[i].Suggested_Minimum__c);
                System.assertEquals(4000, recoveries[i].Suggested_Maximum__c);
            }
            Test.stopTest();
        }
    }

    // With 10+ flight duration and Gold Tier
    static testMethod void testGetSuggestedRange6() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            Set<Id> recoveryIds = new Set<Id>();
            List<Contact> contacts = [SELECT Id, Frequent_Flyer_Tier__c FROM Contact];
            for(Contact con: contacts) {
                con.Frequent_Flyer_Tier__c = 'Gold';
            }
            update contacts;

            List<Case> cases = [SELECT Id, ContactId, Arrival_Date_Time__c, Departure_Date_Time__c FROM Case];
            for(Case cs: cases) {
                cs.Departure_Date_Time__c = '01/12/2017 06:00:00';
                cs.Arrival_Date_Time__c = '01/12/2017 17:00:00';
            }
            Test.startTest();
            update cases;
            
            List<Case_Category__c> caseCategories = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'Flight Disruptions','Downgrade','QF Booking Throughfare','');
            insert caseCategories;
            List<Recovery__c> newRecoveries = TestUtilityDataClassQantas.insertRecoveries(cases);
            for(Recovery__c rec: newRecoveries) {
                recoveryIds.add(rec.Id);
            }
            List<Recovery__c> recoveries = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id = :recoveryIds];
            
            for(Integer i = 0; i < recoveries.size(); i++) {
                /*String result = QCC_RecoveryController_CC.getSuggestedRange(recoveries[i].id);
                System.assertEquals('0,6000,Complaint,true,0,Open', result);
                System.assertEquals(5000, recoveries[i].Suggested_Minimum__c);
                System.assertEquals(13000, recoveries[i].Suggested_Maximum__c);*/
            }
            Test.stopTest();
        }
    }

    // Case with Multiple Case Category records
    static testMethod void testGetSuggestedRange7() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            Set<Id> recoveryIds = new Set<Id>();
            List<Case> cases = [SELECT Id, ContactId FROM Case];
            List<Case_Category__c> allCaseCategories = new List<Case_Category__c>();
            List<Case_Category__c> caseCategories1 = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'Flight Disruptions','Downgrade','QF booking single Sector','');
            allCaseCategories.addAll(caseCategories1);
            List<Case_Category__c> caseCategories2 = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'Flight Disruptions','Downgrade','Agent booking','');
            allCaseCategories.addAll(caseCategories2);
            List<Case_Category__c> caseCategories3 = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'Flight Disruptions','Re-bookings','Rebooking Error, Customer purchased new flight','');
            allCaseCategories.addAll(caseCategories3);
            List<Case_Category__c> caseCategories4 = TestUtilityDataClassQantas.insertCaseCategories(cases, 'Complaint', 'In-Flight','Food and Beverage','Meal Availability','Nil catering, ran out of meals');
            allCaseCategories.addAll(caseCategories4);
            Test.startTest();
            insert allCaseCategories;
            List<Recovery__c> newRecoveries = TestUtilityDataClassQantas.insertRecoveries(cases);
            for(Recovery__c rec: newRecoveries) {
                recoveryIds.add(rec.Id);
            }
            List<Recovery__c> recoveries = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id = :recoveryIds];
            
            for(Integer i = 0; i < recoveries.size(); i++) {
                /*String result = QCC_RecoveryController_CC.getSuggestedRange(recoveries[i].id);
                System.assertEquals('0,8000,Complaint,true,0,Open', result);*/
                System.assertEquals(0, recoveries[i].Suggested_Minimum__c);
                System.assertEquals(8000, recoveries[i].Suggested_Maximum__c);
            }
            Test.stopTest();
        }
    }

    static testMethod void testRecoveryAlreadyGiven() {
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        List<Recovery__c> recoveries = [SELECT Id, Amount__c, Status__c, Type__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        System.debug('RECOVERIES AFTER '+recoveries);
        if(recoveries.size() > 0){
            recoveries[0].Amount__c = 500;
            recoveries[0].Type__c = 'Qantas Points';
            recoveries[0].Status__c = 'Finalised';
             recoveries[0].Suggested_Minimum__c = -1;
            recoveries[0].Suggested_Maximum__c = 0;
            update recoveries;
        }
        Test.startTest();
        List<Recovery__c> recs = TestUtilityDataClassQantas.insertRecoveries(cases);
        Set<Id> recIds = new Set<Id>();
        for(Recovery__c rec: recs) {
            recIds.add(rec.Id);
        }
        List<Recovery__c> newRecs = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id IN: recIds];
       // System.assertEquals(-1, newRecs[0].Suggested_Minimum__c);
      //  System.assertEquals(0, newRecs[0].Suggested_Maximum__c);
        Test.stopTest();
        System.debug('RECOVERIES BEFORE '+recoveries);
    }
    
    static testMethod void testMaxRecoveryAlreadyGiven() {
        List<Case> cases = [SELECT Id, ContactId FROM Case];
        List<Recovery__c> recoveries = [SELECT Id, Amount__c, Status__c, Type__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        System.debug('RECOVERIES AFTER '+recoveries);
        if(recoveries.size() > 0){
            recoveries[0].Amount__c = 10500;
            recoveries[0].Type__c = 'Qantas Points';
            recoveries[0].Status__c = 'Finalised';
            recoveries[0].Suggested_Minimum__c = -1;
            recoveries[0].Suggested_Maximum__c = 0;
            update recoveries;
        }
        Test.startTest();
        List<Recovery__c> recs = TestUtilityDataClassQantas.insertRecoveries(cases);
        Set<Id> recIds = new Set<Id>();
        for(Recovery__c rec: recs) {
            recIds.add(rec.Id);
        }
        List<Recovery__c> newRecs = [SELECT Id, Suggested_Minimum__c, Suggested_Maximum__c FROM Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id IN: recIds];
      //  System.assertEquals(-1, newRecs[0].Suggested_Minimum__c);
       // System.assertEquals(0, newRecs[0].Suggested_Maximum__c);
        Test.stopTest();
        System.debug('RECOVERIES BEFORE '+recoveries);
    }

    // updateRecovery
    static testMethod void testUpdateRecovery1() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Recovery__c> recoveries = [SELECT Id FROM Recovery__c where RecordType.DeveloperName='Other_Recovery'];
            Test.startTest();
            for(Integer i = 0; i < recoveries.size(); i++) {
                QCC_RecoveryController_CC.updateRecovery(recoveries[i].id, 2000, '');
            }
            Test.stopTest();
            List<Recovery__c> updatedRecoveries = [SELECT Id, Status__c, Type__c, Amount__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
            for(Integer i = 0; i < updatedRecoveries.size(); i++) {
                //System.assertEquals(2000, updatedRecoveries[i].Amount__c);
                //System.assertEquals('Open', updatedRecoveries[i].Status__c);
                //System.assertEquals('Qantas Points', updatedRecoveries[i].Type__c);
            }
        }
    }

    // updateRecovery Apology type
    static testMethod void testUpdateRecovery2() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Recovery__c> recoveries = [SELECT Id FROM Recovery__c where RecordType.DeveloperName='Other_Recovery'];
            Test.startTest();
            for(Integer i = 0; i < recoveries.size(); i++) {
                QCC_RecoveryController_CC.updateRecovery(recoveries[i].id, 2000, 'Apology');
            }
            Test.stopTest();
            List<Recovery__c> updatedRecoveries = [SELECT Id, Status__c, Type__c, Amount__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
            for(Integer i = 0; i < updatedRecoveries.size(); i++) {
                //System.assertEquals(2000, updatedRecoveries[i].Amount__c);
                //System.assertEquals('Approved', updatedRecoveries[i].Status__c);
               // System.assertEquals('No Goodwill', updatedRecoveries[i].Type__c);
            }
        }
    }

    // test for updateRecovery exception
    static testMethod void testUpdateRecovery3() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            Test.startTest();
            QCC_RecoveryController_CC.updateRecovery('0D2N00000004EXCKA2', 2000, 'Apology');
            Test.stopTest();
            List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'QCC_RecoveryController_CC'];
            System.assertEquals(0, logs.size(), 'Log for QCC_RecoveryController_CC not found');
        }
    }

    // test for getSuggestedRange exception
    /*static testMethod void testGetSuggestedRangeException() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Recovery__c> recoveries = new List<Recovery__c>();
            List<Contact> contacts = [SELECT Id, Frequent_Flyer_Tier__c FROM Contact];
            for(Contact con: contacts){
                Recovery__c rec = new Recovery__c();
                rec.Contact__c = con.Id;
                recoveries.add(rec);
            }
            
            Test.startTest();
            //insert recoveries;
            RecoveryTriggerHelper.getSuggestedRange(recoveries);
            Test.stopTest();
            List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'RecoveryTriggerHelper'];
            System.assertEquals(1, logs.size(), 'Log for RecoveryTriggerHelper not found');
        }
    }*/

    // test for suggestedFFPointsProcess exception
    /*static testMethod void testSuggestedFFPointsProcessException() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            Test.startTest();
            Case cs = new Case();
            QCC_RecoveryController_CC.suggestedFFPointsProcess(cs);
            Test.stopTest();
            List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'QCC_RecoveryController_CC'];
            System.assertEquals(1, logs.size(), 'Log for QCC_RecoveryController_CC not found');
        }
    }*/
}