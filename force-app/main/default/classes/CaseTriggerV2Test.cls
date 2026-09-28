@isTest
private class CaseTriggerV2Test {
    @testSetup
    static void createData() {
        Test.StartTest();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());

        Trigger_Status__c ts1 = new Trigger_Status__c();
            ts1.Name = 'FeedItemTrgPreventChatterDeletion';
            ts1.Active__c = true;
            lsttrgStatus.add(ts1);
        Trigger_Status__c ts2 = new Trigger_Status__c();
            ts2.Name = 'FeedItemTrgUpdateEscalationTickBox';
            ts2.Active__c = true;
            lsttrgStatus.add(ts2);

        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
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
             Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
             EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
             TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
             );
        insert u1;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }

        List<Contact> contacts = new List<Contact>();
        List<APXTConga4__Conga_Email_Template__c> congaEmailTemplates = TestUtilityDataClassQantas.createCongaEmailTemplates();
        insert congaEmailTemplates;
        List<APXTConga4__Conga_Template__c> congaTemplates = TestUtilityDataClassQantas.createCongaTemplates();
        insert congaTemplates;
        System.runAs(u1) {
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Email='test@mailinator.com', Business_Types__c='Agency', Job_Role__c='Agency Manager',
                                          Function__c='Advisory Services', Frequent_Flyer_Number__c = '12345' + i);
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
        Id agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Id assRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        list<Account> myAccounts = new list<Account>();
        Account acc1 = new Account(Name = 'ValidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                   RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565369',Email__c='managefile.qac@qantas.com.au',
                                   IATA_Number__c = '0239209', Tradesite__c = True);
        myAccounts.add(acc1);
        Account acc2 = new Account(Name = 'ValidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                   RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565368',Email__c='managefile.qac@qantas.com.au',
                                   IATA_Number__c = '0239201', Tradesite__c = True);
        myAccounts.add(acc2);
        insert myAccounts;
        List<Asset> listAssets = new List<Asset>();
        Asset ass1 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId, AccountId = acc1.Id, Active__c = True, Total_Acquired_credits__c = 0, Total_Consumed_credits__c = 0); 
        listAssets.add(ass1);
        insert listAssets;
        Test.StopTest();
    }

    static testMethod void testUpdateCaseComplimentTemplateValue() {
        String type = 'Compliment';
        String recordType = 'CCC Compliment';
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(u1) {
            List<Contact> contacts = [SELECT Id, Name FROM Contact];
            Test.startTest();
            List<Case> cases1 = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'Qantas.com','','','');
            System.debug('CaseList1 Id = '+cases1[0].id);            
            List<Case> cases1ToUpdate = TestUtilityDataClassQantas.assertCase(cases1, 1);
            List<Case> cases2 = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'Qantas.com','','','');
            System.debug('CaseList2 Id = '+cases2[0].id);            
            List<Case> cases2ToUpdate = TestUtilityDataClassQantas.assertCase(cases2, 2);
            Test.stopTest();
        }
    }
    
    static testMethod void testPopulateBasicAutoCaseValues() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Contact> contacts = [SELECT Id, Name FROM Contact];
            List<Case> cases = new List<Case>();
            Test.startTest();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight','','','');
                cs.ContactId = con.Id;
                cs.Origin = CustomSettingsUtilities.getConfigDataMap('QCC Qantas');
                cs.Flight_Number__c = 'QF0400';
                cases.add(cs);
            }
            insert cases;
            Test.stopTest();
            List<Case> updatedCases = [SELECT Id, status, FCR__c, Flight_Number__c, Assign_using_active_assignment_rules__c FROM Case];
			/*
            for(Integer i = 0; i < updatedCases.size(); i++) {
                System.assertEquals(false, updatedCases[i].Assign_using_active_assignment_rules__c);
            }
			*/
        }
    }

    static testMethod void testUpdateCaseEscalatedTo() {
        String type = 'Compliment';
        String recordType = 'CCC Compliment';
        Test.startTest();
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Contact> contacts = [SELECT Id, Name FROM Contact];

            List<Case> cases = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'In-Flight','','','');

            for(Integer i = 0; i < cases.size(); i++) {
                System.assertEquals(null, cases[i].Escalated_To__c);
                System.assertEquals(false, cases[i].isEscalated);
                cases[i].isEscalated = true;
            }

            update cases;

            List<Case> updatedCases = [SELECT Id, status, isEscalated, Escalated_To__c FROM Case];
            Test.stopTest();
            for(Integer i = 0; i < updatedCases.size(); i++) {
                //System.assertEquals(UserInfo.getName(), updatedCases[i].Escalated_To__c);
                System.assertEquals(true, updatedCases[i].isEscalated);
            }
        }

    }
    static testMethod void testFetchCongaEmailTemplateIdComlplaintType() {

        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        APXTConga4__Conga_Email_Template__c complaintTemplate = new APXTConga4__Conga_Email_Template__c();
        complaintTemplate.Type__c = 'Complaint';
        complaintTemplate.Group__c = 'In-Flight';
        complaintTemplate.Category__c = 'In-Flight Entertainment';
        complaintTemplate.Sub_category__c = 'Content';
        complaintTemplate.Classification__c = 'Content variety';
        complaintTemplate.Email_Template__c = 'Complaint Template';
        insert complaintTemplate;
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Complaint Template';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();                                                            
    }
    static testMethod void testBlankComlplainttype() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Blank Template';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        QCC_FeedMentionforcasestatus.mentionTextPost(objCase.Id);
        Test.stopTest();                                                            
    }
    static testMethod void testEFTAuthorisationComlplainttype() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'EFT Authorisation';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();                                                            
    }
    static testMethod void testEFTAuthorisationNoRecComlplainttype() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'EFT Authorisation - No Receipt';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();                                                            
    }
    static testMethod void testFurtherActionRrequiredTypeBlank() {
        String type = 'Further Action Required';
        String recordType = 'CCC Further Action Required';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'Food and Beverage', 'Catering Quality/Selection', 'Presentation/quality of selection');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Blank Template';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
    static testMethod void testFurtherActionRrequiredTypeEFT() {
        String type = 'Further Action Required';
        String recordType = 'CCC Further Action Required';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'Food and Beverage', 'Catering Quality/Selection', 'Presentation/quality of selection');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'EFT Authorisation';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }

     static testMethod void testupdateContactBlankEmail() {
        String type = 'Further Action Required';
        String recordType = 'CCC Further Action Required';
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.Email = '';
        update con;
        Test.startTest();
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'Food and Beverage', 'Catering Quality/Selection', 'Presentation/quality of selection');
        cs.ContactId = con.id;
        cs.Contact_Email__c ='test@test.com';
        insert cs;
        Contact objCon = [SELECT Id, Name, Email FROM Contact where Id =: con.Id];
        Test.stopTest();
    }

    static testMethod void testFurtherActionRrequiredTypeEFTNoReceipt() {
        String type = 'Further Action Required';
        String recordType = 'CCC Further Action Required';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'Food and Beverage', 'Catering Quality/Selection', 'Presentation/quality of selection');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'EFT Authorisation - No Receipt';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
    static testMethod void testFurtherActionRrequiredType() {
        String type = 'Further Action Required';
        String recordType = 'CCC Further Action Required';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Flight Disruptions', 'Downgrade', 'QF Booking Throughfare', '');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Complaint Template';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c, Group__c, Category__c from Case where Id = :cs.Id];
        APXTConga4__Conga_Email_Template__c conga = [Select Id from APXTConga4__Conga_Email_Template__c where Group__c =: objCase.Group__c AND Category__c = :objCase.Category__c];
        Test.stopTest();
    }
    static testMethod void testInsuranceLettertype() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight', '', '', '');
        cs.ContactId = con.id;
        insert cs;
        APXTConga4__Conga_Email_Template__c conga = [Select Id from APXTConga4__Conga_Email_Template__c where type__c = :type AND group__c = 'Delayed Flight'];
        APXTConga4__Conga_Template__c templates = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE Email_Template_Name__c = 'QCC Delayed Flight'];
        Case objCase = [Select id, Conga_Email_Template_ID__c, Conga_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
    static testMethod void testBaggageType() {
        String type = 'Baggage';
        String recordType = 'CCC Baggage';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Qantas Not Liable';
        insert cs;
        APXTConga4__Conga_Email_Template__c conga = [Select Id from APXTConga4__Conga_Email_Template__c
                                                                    where Email_Template__c = 'Qantas Not Liable'
                                                                    AND type__c=: cs.Type];
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
    static testMethod void testMedicalType() {
        String type = 'Medical-Patient';
        String recordType = 'CCC Medical';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Blank Template';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
    static testMethod void testMedicalAssistanceTypeBlank() {
        String type = 'Medical-Assistance Provided';
        String recordType = 'CCC Medical';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Blank Template';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
    static testMethod void testMedicalAssistanceType() {
        String type = 'Medical-Assistance Provided';
        String recordType = 'CCC Medical';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Medical Assistance provided';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
    static testMethod void testQueryType() {

        String type = 'Query';
        String recordType = 'CCC Query';
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Test.startTest();
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        cs.ContactId = con.id;
        cs.Email_Template__c = 'Query';
        insert cs;
        Case objCase = [Select id, Conga_Email_Template_ID__c from Case where Id = :cs.Id];
        Test.stopTest();
    }
  static testMethod void caseStatusUpdated() {
    String queueName = 'Fulfillment_Queue';
    String type = 'Complaint';
    String recordType = 'CCC Complaints';
    Contact con = [SELECT Id, Name FROM Contact Limit 1];
    con.Firstname = 'Tester';
    con.Lastname = 'TesterLN';
    update con;
    Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Fulfillment_Queue'];
    Test.startTest();
    Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
    anycase.OwnerId = caseGroup.Id;
    anyCase.Status = 'Received';
    anyCase.Priority = 'High';
    anyCase.contactId = con.Id;
    insert anycase;
    //test last queue owner
            anyCase.OwnerId = UserInfo.getUserId();
            update anyCase;
            Case res = [select Id , OwnerId , Last_Queue_Owner__c , Last_Queue_Owner_Name__c from Case where Id =: anycase.Id];

            Test.stopTest();
        }

        static testMethod void submitForFinalisationTest(){
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            Contact con = [SELECT Id, Name FROM Contact Limit 1];
            Test.startTest();
            Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            anyCase.submitForFinalisation__c = true;
            insert anyCase;
            Case res = [select Id , SubmitForFinalisation__c from Case where Id =: anyCase.Id];
            System.assert(res.SubmitForFinalisation__c == false);
            Test.stopTest();
        }

        static testMethod void assignCaseOwnerCriticalQ(){
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
            //get search contact
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            Case anyCase;
            Test.startTest();
            System.runAs(u1){
                Contact con = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Email='email@email.com',Frequent_Flyer_Tier__c='Platinum', Frequent_Flyer_Number__c = '12345');
                insert con;
                System.assert(con != null);
                System.assert(con.Id != null);
                anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
                anyCase.Description = 'abuse';
                //assign case to contact
                anyCase.contactId = con.Id;
                anycase.Assign_using_active_assignment_rules__c = true;
                insert anyCase;
                System.assert(anyCase.Id != null);
                System.debug('my case ' + anyCase);
            }
            Test.stopTest();
            System.assert(anycase != null);
            Case objCase = [select OwnerId from Case where Id =: anyCase.Id];
            System.debug('new owner ' + objCase.OwnerId);
            System.assert(string.valueOf(objCase.OwnerId).startsWith('00G'));
            
        }

        static testMethod void assignCaseOwnerAdvocacyQ(){
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
            Case anyCase;
            Contact con = [SELECT Id,Frequent_Flyer_Tier__c, Name FROM Contact Limit 1];
            con.Frequent_Flyer_Tier__c = 'Gold';
            Test.startTest();
            update con;
            anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            anyCase.Cabin_Class__c = 'Business';
            anyCase.ContactId = con.id;
            System.runAs(u1){
                anyCase.Description = 'illegal';
                anycase.Assign_using_active_assignment_rules__c = true;
                insert anyCase;
            }
            Test.stopTest();
            Case objCase = [select OwnerId from Case where Id =: anyCase.Id];
            System.debug('new owner ' + objCase.OwnerId);
            System.assert(string.valueOf(objCase.OwnerId).startsWith('00G'));
            
        }
        static testMethod void assignCaseOwnerExCoQ(){
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
            //get search contact
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            Case anyCase;
            Test.startTest();
            System.runAs(u1){
                Contact con = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Email='email@email.com', Frequent_Flyer_Tier__c='Platinum',Frequent_Flyer_Number__c = '12345');
                insert con;
                System.assert(con != null);
                System.assert(con.Id != null);
                anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
                anyCase.Description = 'Garry Hounsell';
                anyCase.Priority = 'High';
                anyCase.Cabin_Class__c = 'Business';
                //assign case to contact
                anyCase.contactId = con.Id;
                anycase.Assign_using_active_assignment_rules__c = true;
                anyCase.OwnerId = u1.Id;
                insert anyCase;
                
            }
            Test.stopTest();
            Case objCase = [select OwnerId from Case where Id =: anyCase.Id];
           // System.assert(string.valueOf(objCase.OwnerId).startsWith('00G'));
        }
        static testMethod void assignCaseOwnerEUQ(){
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
            //get search contact
            Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
            Case anyCase;
            Test.startTest();
            System.runAs(u1){
                Contact con = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Email='email@email.com', Frequent_Flyer_Tier__c='Platinum',Frequent_Flyer_Number__c = '12345');
                insert con;
                System.assert(con.Id != null);
                anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
                anyCase.Description = 'EU Regulation';
                anyCase.Priority = 'High';
                anyCase.Cabin_Class__c = 'Business';
                //assign case to contact
                anyCase.contactId = con.Id;
                anyCase.OwnerId = u1.Id;
                anycase.Assign_using_active_assignment_rules__c = true;
                insert anyCase;
                System.assert(anyCase.Id != null);
            }

            Test.stopTest();
            Case objCase = [select OwnerId from Case where Id =: anyCase.Id];
            System.assert(string.valueOf(objCase.OwnerId).startsWith('00G'));
            
            System.debug('new owner ' + objCase.OwnerId);
        }

        static testMethod void assignCaseOwnerEmirates(){
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            Case anyCase;
            Contact con = [SELECT Id, Name FROM Contact Limit 1];
            Test.startTest();
            anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            anyCase.Description = 'Emirates';
            anycase.Assign_using_active_assignment_rules__c = true;
            anyCase.contactId = con.Id;
            insert anyCase;
            Case res = [select Id , OwnerId  from Case where Id =: anyCase.Id];
            //TODO fix
          //  System.assert(string.valueOf(res.OwnerId).startsWith('00G'));
            Test.stopTest();

        }

        static testMethod void assignCaseOwnerNoHotWords(){
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            Contact con = [SELECT Id, Name FROM Contact Limit 1];
            Case anyCase;
            Test.startTest();
            anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            anyCase.Description = 'Where my honey nuts at??';
            anyCase.contactId = con.Id;
            anycase.Assign_using_active_assignment_rules__c = true;
            insert anyCase;
            Case res = [select Id , OwnerId  from Case where Id =: anyCase.Id];
           // System.assert(string.valueOf(res.OwnerId).startsWith('00G'));
        Test.stopTest();
    }

    static testMethod void assignCaseOwnerHotWordFirtClassPlatinum(){
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = con.Id;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        insert anyCase;
        Case res = [select Id , OwnerId  from Case where Id =: anyCase.Id];
      //  System.assert(string.valueOf(res.OwnerId).startsWith('00G'));
        Test.stopTest();
    }

    static testMethod void updateCaseOnClose(){
        Test.startTest();
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User u2 = new User(LastName = 'User2', Alias = 'Mgr', Email = 'sampleuser2@sample.com', 
                           Username = 'sampleuser2username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id, //CRM-11908 Update metadata rerferences
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney',Location__c='Sydney'
                          );
        insert u2;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }

        User u1 = [SELECT Id , ManagerId FROM User WHERE Username = 'sampleuser1username@sample.com'];
        u1.ManagerId = u2.Id;
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        System.runAs(u1){

            Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
            con.Frequent_Flyer_Tier__c = 'Platinum';
            update con;
            Group queue = [Select Id , Name , DeveloperName from Group where Type = 'Queue' and Name = 'CCC Emirates Queue-High' ];

            Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            //anyCase.Status = 'Closed';
            //Need to restrict recovery creations for closed cases. Jira: CRM-5617
            anyCase.Status = 'In Progress';
            anycase.contactId = con.Id;
            anycase.TECH_CCEFTRecoveryId__c='test';
            insert anyCase;
            
            Recovery__c rec = new Recovery__c();
            rec.Case_Number__c=anyCase.Id;
            rec.CreatedById=userinfo.getUserId();
            insert rec;
            
            //anyCase.status='Closed';
            //update anyCase;
            //TODO fix
            //insert anyCase;
            //Case res = [select Id , OwnerId  from Case where Id =: anyCase.Id];
            //System.assert(anyCase.isClosed == true);
            //System.assert(anyCase.ClosedByLocation__c == 'Sydney');
            //System.assert(anyCase.ClosedByManager__c == u2.Id);
            //System.assert(anyCase.Closed_By_Profile__c == UserInfo.getUserId());
        }

        Test.stopTest();
    }




  static testMethod void updateCaseCalculatedFieldsTest1() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Handle broken;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
  static testMethod void updateCaseCalculatedFieldsTest2() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Locks;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
  static testMethod void updateCaseCalculatedFieldsTest3() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Trolley;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
  static testMethod void updateCaseCalculatedFieldsTest4() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Zip - broken pull;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
  static testMethod void updateCaseCalculatedFieldsTest5() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Zip - replace sliders and tab;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
  static testMethod void updateCaseCalculatedFieldsTest6() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Zip - completely replace;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
  static testMethod void updateCaseCalculatedFieldsTest7() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Dent / pushed in;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
  static testMethod void updateCaseCalculatedFieldsTest8() {
    Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Frame crushed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }
    
     static testMethod void updateCaseCalculatedFieldsTest9() {
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }

     static testMethod void updateCaseCalculatedFieldsTest10() {
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Wheel snapped or broken off x 1;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }

     static testMethod void updateCaseCalculatedFieldsTest11() {
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Wheel snapped or broken off x 2;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }

     static testMethod void updateCaseCalculatedFieldsTest12() {
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Wheel snapped or broken off x 3;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }

     static testMethod void updateCaseCalculatedFieldsTest13() {
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Wheel snapped or broken off x 4;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        
        insert anyCase;
        Case result = [select Id , Repair_Cost_Numeric__c from Case where Id = :anyCase.Id];
        Test.stopTest();
    }

    static TestMethod void calculateEmergencyExpenseTest1(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Cabin_Class__c            = 'Business';
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'Domestic';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-40);
        anycase.Located_Date__c = system.today().adddays(40);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;
        
        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }

    static TestMethod void calculateEmergencyExpenseTest2(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Gold';
        update con;
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'Domestic';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-40);
        anycase.Located_Date__c = system.today().adddays(40);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;
        
        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }

    static TestMethod void calculateEmergencyExpenseTest3(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'Domestic';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-90);
        anycase.Located_Date__c = system.today().adddays(40);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;
        
        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }

    static TestMethod void calculateEmergencyExpenseTest4(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Gold';
        update con;
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Cabin_Class__c            = 'Business';
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'International';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-20);
        anycase.Located_Date__c = system.today().adddays(10);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;

        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }
    
    
    static testMethod void testUdateCaseSLA() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        insert cs;
        cs.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType'));
        cs.Type = 'Medical-Patient';
        cs.Group__c = 'Departure Airport';
        cs.Category__c = '';
        cs.Sub_Category__c = '';
        cs.Classification__c = '';
        cs.Assign_using_active_assignment_rules__c = true;
        update cs;
        Test.stopTest();
    }
    
    static testMethod void testUpdateCaseEscalatedToException() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        List<Case> caseList = new List<Case>();
        Map<Id, Case> blankCaseMap = new Map<Id, Case>();
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            cs.ContactId = con.id;
        caseList.add(cs);
        insert caseList;
        //Jira:CRM-8706
        //CaseTriggerHelper.updateCaseEscalatedTo(caseList, blankCaseMap);
        Test.stopTest();
        //List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'CaseTriggerHelper'];
        //System.assert(logs.size() != 0, 'Log for CaseTriggerHelper not found');
    }


    static testMethod void SetAuditFields() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Status = 'Closed';
        insert cs;
        //Case objCase = [Select id, Status from Case where Id = :cs.Id];
        Test.stopTest();
    }

    static testMethod void updateTECHFields() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Case cs;
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Departure_Date_Time__c = '10/06/2018 16:50:00';
        cs.Actual_Arrival_Date_Time__c = '14/06/2018 14:55:00';
        cs.Status = 'Closed';
        cs.Sensitive__c = true;    
        cs.Booking_PNR__c = 'XXXX23';    
        insert cs;
        
        Test.stopTest();
        Case objCase = [Select id, Status , ContactEmail , Sensitive__c, Priority from Case where Id = :cs.Id];
        if (objCase.Status.equals(CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')))
        {
            Case childCase = objCase.clone(false, true, false, true);
            childCase.ParentId = objCase.Id;
            childCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            childCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            childCase.Sensitive__c = false;
            insert childCase;
            childCase.Sensitive__c = true;
            update childCase;
        }
        else
        {
            objCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            objCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            objCase.Sensitive__c = false;
            update objCase;
            objCase.Sensitive__c = true;
            update objCase;
        }
    }

    //GRAPHITE-1930 Move the Test.startTest to reset governor limits to the last update DML.
    static testMethod void deleteAffectedPassengers() {
        String type = 'Insurance Letter';
        String recordType =  'CCC Insurance Letter Case';
        Case cs;

        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight', '', '', '');
        cs.ContactId = con.id;
        cs.Departure_Date_Time__c = '10/06/2018 16:50:00';
        cs.Actual_Arrival_Date_Time__c = '14/06/2018 14:55:00';
        cs.Status = 'Closed';
        cs.Sensitive__c = false;    
        cs.Booking_PNR__c = 'XXXX34';    
        insert cs;

        Test.startTest();
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' ,Frequent_Flyer_Tier__c='Platinum', Frequent_Flyer_Number__c = '00061422023');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';

        insert objEvent;

        //add passenger in response
        Affected_Passenger__c afp = new Affected_Passenger__c(PassengerId__c = '1544523921002621', Passenger__c =contact1.Id, TECH_PreFlight__c = true,Event__c = objEvent.Id , case__c = cs.Id);

        Case objCase = [Select id, Status , ContactEmail , Booking_PNR__c , Sensitive__c, Priority from Case where Id = :cs.Id];
        if (objCase.Status.equals(CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')))
        {
            Case childCase = objCase.clone(false, true, false, true);
            childCase.ParentId = objCase.Id;
            childCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            childCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            childCase.Sensitive__c = true;
            childCase.Booking_PNR__c = 'XXX123';
            childCase.Description = 'Test Case Description';
            insert childCase;
        }
        else
        {
            objCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            objCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            objCase.Sensitive__c = true;
            objCase.Booking_PNR__c = 'XXX1';   
            update objCase;
        }
        Test.stopTest();
    }
    
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:         
    Description:        QAC Agency Credits logic
    Parameter:          
    ----------------------------------------------------------------------------------------------*/      
    
    //GRAPHITE-1930 Comment this out to check why "Adhoc Credits" is disabled in BAUSIT and Production. If this is valid, then we need to access if this test class is still relevant.
 /*      static testMethod void testAgencyCreditFulfilmentMethod() {
        
        Id caseTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Maintenance').getRecordTypeId();
        Id assRecTypeId1 = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Id ledRecTypeId = Schema.SObjectType.Ledger__c.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        Account acc1 =[SELECT id, IATA_Number__c From Account WHERE IATA_Number__c = '0239209' ];
        Account acc2 =[SELECT id, IATA_Number__c From Account WHERE IATA_Number__c = '0239201' ];
        
        Asset ass1 =[SELECT id, Total_Acquired_credits__c, Total_Consumed_credits__c From Asset WHERE Total_Acquired_credits__c = 0];
        
        
        Test.startTest();
        List<Case> amCaseList = new List<Case>();
        Case casObj1 = new Case(recordtypeid = caseTypeId, Accountid = acc1.ID, Status = 'New', Type = 'Agency Account', Sub_Type_1__c = 'Ad-hoc Credits', Approve__c = 'No', Total_Credits__c = 530, Reason = 'New problem');
        amCaseList.add(casObj1);
        insert  amCaseList;
        casObj1.Approval_Status__c = 'Approved';
        update  casObj1;
        
        
        Case casObj2 = new Case(recordtypeid = caseTypeId, Accountid = acc1.ID, Status = 'New', Type = 'Agency Account', Sub_Type_1__c = 'Ad-hoc Credits', Approve__c = 'No', Total_Credits__c = 530, Reason = 'New problem');
        try{
            insert  casObj2;  
            Ledger__c ledrecord = new Ledger__c (Account__c = acc1.ID,
                                                 Asset__c = ass1.Id, Case__c = casObj2.Id,                                                        
                                                 RecordTypeId = ledRecTypeId, Transaction_type__c = 'Credit', 
                                                 Transaction_frequency__c = 'Adhoc', Transaction_date__c = System.Today(),
                                                 Reason__c = 'Adhoc Credits',
                                                 Total_Credit_Value__c = ass1.Total_Acquired_credits__c, Total_Outstanding_Credits__c = ass1.Total_Acquired_credits__c - ass1.Total_Consumed_credits__c
                                                );
            insert ledrecord;
            casObj2.Approval_Status__c = 'Approved';
            update  casObj2;
        }
        catch(Exception ex){}
        
        Asset ass2 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId1, AccountId = acc1.Id, Active__c = True, Total_Acquired_credits__c = 2, Total_Consumed_credits__c =1 ); 
        insert ass2;
        
        Case casObj3 = new Case(recordtypeid = caseTypeId, Accountid = acc1.ID, Status = 'New', Type = 'Agency Account', Sub_Type_1__c = 'Ad-hoc Credits', Approve__c = 'No', Total_Credits__c = 530, Reason = 'New problem');
        try{
            insert  casObj3;  
            casObj3.Approval_Status__c = 'Approved';
            update  casObj3;
        }
        catch(Exception ex){}
        
        Asset ass3 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId1, AccountId = acc2.Id, Active__c = False, Total_Acquired_credits__c = 2, Total_Consumed_credits__c =1 ); 
        insert ass3;
        
        Case casObj4 = new Case(recordtypeid = caseTypeId, Accountid = acc2.ID, Status = 'New', Type = 'Agency Account', Sub_Type_1__c = 'Ad-hoc Credits', Approve__c = 'No', Total_Credits__c = 530, Reason = 'New problem');
        try{
            insert  casObj4;  
            casObj4.Approval_Status__c = 'Approved';
            update  casObj4;
        }
        catch(Exception ex){}
        Test.stopTest();
        
    }*/

        /*----------------------------------------------------------------------------------------------      
    Method Name:        updateCaseHotwordQueueRouting    
    Parameter:          
    ----------------------------------------------------------------------------------------------*/      
    
    static testMethod void testupdateCaseHotwordQueueRouting() {
        Trigger_Status__c caseUpdateRoutingDetail = new Trigger_Status__c();
        caseUpdateRoutingDetail.Name = 'CaseHotwordQueueRoutingTrigger';
        caseUpdateRoutingDetail.Active__c = true;
        insert caseUpdateRoutingDetail;
            
         String type = 'Complaint';
            String recordType = 'CCC Complaints';
            Contact con = [SELECT Id, Name FROM Contact Limit 1];
            Case anyCase;
            Test.startTest();
            anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            anyCase.Description = 'Where my honey nuts at??';
            anyCase.contactId = con.Id;
            anycase.Assign_using_active_assignment_rules__c = true;
            insert anyCase;
                List<Case> amCaseList = new List<Case>();
               amCaseList.add(anyCase);
            //Case = [select Id , OwnerId  from Case where Id =: anyCase.Id];
        //Jira:CRM-8706
        //casetriggerhelper.updateCaseHotwordQueueRouting(amCaseList);
        List<String> hotWordList = new List<String>();
        hotWordList.add('element');
        String caseDescription='test';
        //casetriggerhelper.hasAdvocacyHotword(hotWordList, caseDescription);
        //casetriggerhelper.createLoyaltyCaseStream(amCaseList);
        system.debug('amCaseList');
        Test.stopTest();
    }
    
     /*----------------------------------------------------------------------------------------------      
    Method Name:        ReassignCaseWithWaitingStatus
    Description:        ReassignCaseWithWaitingStatus
    Parameter:          List<Case> listCase, Map<Id, Case> 
    ----------------------------------------------------------------------------------------------*/     
    
    static testMethod void testReassignCaseWithWaitingStatus() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'Specific Needs';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Specific Needs','', '', '');
        cs.ContactId = con.id;
        //Test coverage 
        cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Customer';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        agencyContractUpdateMethod
    Description:        QC channel Contract Termination logic
    Parameter:          
    ----------------------------------------------------------------------------------------------*/      
    
    static testMethod void testagencyContractUpdateMethod() {
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Id caRTId = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Agency - Signed by Customer').getRecordTypeId();
        Id quotRTId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Agency Partnerships').getRecordTypeId();
        Id optyRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Partnerships').getRecordTypeId();
        Id caseTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Deal Support Request').getRecordTypeId();
         List < Case > newList = new List < Case >();
        Map < Id, Case > oldMap = new Map < Id, Case >();
        
        //Create Account
        Account testacc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                      RecordTypeId = accRTId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', ABN_Tax_Reference__c ='12345678901');
        insert testacc;
        
        Opportunity validOpp = new Opportunity(Name = 'Opp2'+testacc.Name , AccountId = testacc.Id,Proposed_Market_Share__c = 70,Proposed_International_Market_Share__c = 50,
                                               Amount = 500000,  CloseDate = Date.Today(),Proposed_MCA_Routes_Market_Share__c = 90,
                                               StageName = 'Closed - Accepted', RecordTypeId = optyRTId, Category__c = 'Corporate Airfares', Type = 'Agency Partnerships',Forecast_MCA_Revenue__c=20000);
        insert validOpp;
        
        Quote quorec = new Quote(Name = 'testquot', OpportunityId =validOpp.Id,  Status = 'Draft', Rate_Valid_after_acceptance_until__c = system.today(), RecordTypeId = quotRTId );
        //AccountId = testacc.Id
        insert quorec;
        
        Test.StartTest();
        //Create Contract
        Contract__c contr = new Contract__c(Name = 'Sample Contract', Account__c = testacc.Id, Opportunity__c = validOpp.Id, 
                                            Active__c = true,  International_Annual_Share__c = 70,
                                            Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                            MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = system.today(), Contract_End_Date__c = system.today().addmonths(12),
                                            Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No',   RecordTypeId = caRTId                                             
                                           );
        insert contr;
        
        Case cs = new Case(RecordTypeId = caseTypeId, Sub_Type__c = 'Channel Agency Payment Contract', AccountId = testacc.Id, Related_Contract__c = contr.Id, Type = 'Deal Termination', Due_Date__c = system.today().addmonths(1),
                           Distribution_Email__c='test123@email.com', ReasonsForTermination__c='Market Share', Reasons_for_Termination__c = 'Test termination',  End_Date__c = system.today().addmonths(3), Status = 'Not yet assigned - with Account Manager');
        
        
        
        //Test.StartTest();
        insert cs;
        newList.add(cs);
        cs.Approval_Status__c = 'Approved';
        cs.NAM_s_Approval__c = True;
        
        update cs;
        oldMap.put(cs.Id, cs);
        
        //CaseTriggerHelper.agencyContractUpdateMethod(newList,oldMap);
        Test.StopTest();
            
       
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        testAssetCreationMethod
    Description:        To create asset record if there is NO Active Asset record exists for the same POS(Country)
    Parameter:          
    ----------------------------------------------------------------------------------------------*/      
    // Commenting out the section as is no longer needed by business.
  /*
    static testMethod void testAssetCreationMethod()
    {
        String caseTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ticketing Authority').getRecordTypeId();

        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
       Account testacc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                      RecordTypeId = accRTId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', ABN_Tax_Reference__c ='12345678901');
        insert testacc;
        contact mycontact = new contact(Lastname ='test',Function__c ='sales',AccountId= testacc.id,Business_Types__c ='Agency',Email ='test@gmail.com',Frequent_Flyer_Number__c = '12345');
        insert mycontact;
        
        Case CaseObj = new Case(AccountId = testacc.Id,status = 'New', country__c = 'chile' , RecordTypeId = caseTypeID, ContactId =mycontact.Id);
        insert caseObj;
        
        
        
         Test.startTest();
        //Case c = [select id,Accountid,country__c from case where status = 'new'];
         caseObj.Status = 'Closed';
         update caseObj;
         Test.StopTest();
 
    } */
    
    
    @isTest static void testDeletion() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'Specific Needs';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Specific Needs','', '', '');
        cs.ContactId = con.id;
        //Test coverage 
        cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> caseRecords = [ SELECT Id, CaseNumber FROM Case ];
        delete caseRecords;
    }
    
    @isTest static void testTriggerHandler() {
        String handlerName = 'Test';
        TriggerHandler tHandler = new TriggerHandler();
        tHandler.setMaxLoopCount(2);
        tHandler.clearMaxLoopCount();
        TriggerHandler.bypass(handlerName);
        TriggerHandler.clearBypass(handlerName);
        TriggerHandler.isBypassed(handlerName);
        TriggerHandler.clearAllBypasses();
        tHandler.beforeInsert();
        tHandler.afterInsert();
        tHandler.beforeUpdate();
        tHandler.afterUpdate();
        tHandler.beforeDelete();
        tHandler.afterDelete();
        tHandler.afterUndelete();
    }
}