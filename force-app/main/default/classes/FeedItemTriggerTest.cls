/*===================================================================================
Modified By : Priyanka (TCS Team), 03-Ju-2026
Desc : CRM-13332 Added new variables. Added testupdateEscalationTickBoxInCasePositive(), testupdateEscalationTickBoxInCaseNegative method. 
Updated createData() method
=====================================================================================*/
@isTest
private class FeedItemTriggerTest {
    
    //CRM-13332
    private static final Id RTID_ACCOUNT_FREIGHT = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Freight_Account').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    private static final Id RTID_CASE_QFREIGHT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
    //CRM-13332
    @testSetup
    static void createData() {

        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.add(new Trigger_Status__c(Name= 'FeedItemTrgPreventChatterDeletion', Active__c= true));
        lsttrgStatus.add(new Trigger_Status__c(Name= 'FeedItemTrgUpdateEscalationTickBox', Active__c= true));
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

        //Create Account
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');
        
        //Create Account - CRM- 13332
		Account accountRecord = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            BillingCountry = 'AU',
            Name = 'Green Cord Corp[Freight-SYD-AU]',
            Email__c = 'greencord@auspost.com.au'
        );
        Insert accountRecord;

        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        objContact.CAP_ID__c='710000000017';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');
        
         //Create Contact - CRM- 13332
        Contact contactRecord = new Contact(
            FirstName = 'Green',
            LastName = 'Trees',
            Email = 'greenTrees@fedex.com',
            AccountId = accountRecord.Id,
            RecordTypeId = RTID_CONTACT_CONTACT);
        insert contactRecord;

        //Create Case
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        String recordType = 'CCC Complaints';
        String type = 'Complaint';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Flight Disruptions','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');
        
         //Create Case for CRM-13332
        case caseRecord = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Cust Service',
            Status = 'Open',
            Subject = 'Test Case 10',
            Description = 'This is for testing.'
        );
        insert caseRecord;
        
        FeedItem fi = new FeedItem();
        fi.ParentId = lstCase[0].id;
        fi.Body = 'Testing';
        insert fi;
        system.assert(fi.Id != Null, 'FeedItem is not inserted');
    }
    
    static testMethod void testPreventChatterDeletionPositive() {
        List<EnableValidationRule__c> lstEnableValidation = new List<EnableValidationRule__c>();
        lstEnableValidation.add(TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getprofileID()));
        insert lstEnableValidation;

        List<FeedItem> lstFeedItems = [select Id from FeedItem Limit 1 ];
        Id feedItemId = lstFeedItems[0].Id;
        
        Test.startTest();
        try {
            delete lstFeedItems;
        } catch (Exception ex) {}
        
        List<FeedItem> lstFIAftDel =  [select Id from FeedItem Where Id =: feedItemId ];
        system.assert(lstFIAftDel.size() == 1, 'FeedItem is not deleted');
        Test.stopTest();
    }
    
    static testMethod void testPreventChatterDeletionNegative() {
        EnableValidationRule__c enableVal = TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getUserID());
        enableVal.PreventChatterDeletion__c = false;
        insert enableVal;
        
        List<FeedItem> lstFeedItems = [select Id from FeedItem Limit 1 ];
        Id feedItemId = lstFeedItems[0].Id;
        
        Test.startTest();
        
        delete lstFeedItems;
        
        List<FeedItem> lstFIAftDel =  [select Id from FeedItem Where Id =: feedItemId ];
        system.assert(lstFIAftDel.size() == 0, 'FeedItem is deleted');
        Test.stopTest();
    }
    //Test method for CRM-13332 - method by mentioning Freight CSU
    static testMethod void testupdateEscalationTickBoxInCasePositive() {
        Case caseRecord = [Select Id from Case where RecordtypeId = :RTID_CASE_QFREIGHT];
        
        FeedItem fi = new FeedItem(
            ParentId = caseRecord.Id,
            Body = '@Freight CSU Mention for testing'
        );
		
        Test.startTest();
        	insert fi;
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, IsEscalated FROM Case WHERE Id = :caseRecord.Id];

    	System.assertEquals(true,updatedCase.IsEscalated,'Case should be escalated when Freight CSU is mentioned');        
    }
    //Test method for CRM-13332 - method without mentioning Freight CSU or CSU Management
    static testMethod void testupdateEscalationTickBoxInCaseNegative() {
        Case caseRecord = [Select Id from Case where RecordtypeId = :RTID_CASE_QFREIGHT];        
        FeedItem fi = new FeedItem(
            ParentId = caseRecord.Id,
            Body = 'General Post without mentioning'
        );
		
        Test.startTest();
        	insert fi;
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, IsEscalated FROM Case WHERE Id = :caseRecord.Id];

    	System.assertEquals(false,updatedCase.IsEscalated,'Case should not be escalated when chatter does not contain configured groups');        
    }
}