@isTest
private class CongaMailSchedulerTest {
    @testSetup
    static void createData() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEmailMessageTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_ContactEmail', 'test1234@sample.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_NoReplyContactLastName', 'Sample12345'));
        insert lstConfigData;
        
        TestUtilityDataClassQantas.createCongaQueries();
    }
    
    @isTest static void test_method_one() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 2; i++) {
            Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='test@sample.com');
                con.CAP_ID__c = '71000000001'+ (i+7);   
            contacts.add(con);
        }
        insert contacts;
        
        List<Case> cases = new List<Case>();
        for(Contact con: contacts) {
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs.ContactId = con.Id;
            cs.Origin = 'Qantas.com';
            cases.add(cs);
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        insert cases;
        System.enqueueJob(new CongaMailSchedulerV2(UserInfo.getSessionId(), cases));
        Test.stopTest();
        List<EmailMessage> emails = [SELECT Id, ParentId, HasAttachment FROM EmailMessage];
        
        
    }

    @isTest static void test_method_two() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 2; i++) {
            Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services',Email='test@sample.com');
                con.CAP_ID__c = '71000000001'+ (i+7);   
            contacts.add(con);
        }
        insert contacts;
        
        List<Case> cases = new List<Case>();
        for(Contact con: contacts) {
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs.ContactId = con.Id;
            cs.Conga_Template_ID__c = 'a0VN00000044nye';
            cases.add(cs);
        }
         Contact cons = new Contact(LastName='Sample12345', FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='test1234@sample.com');
        insert cons;
        system.assert(cons.Id != Null, 'Contact is not inserted');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CalloutExceptionMock());
        insert cases;
        System.enqueueJob(new CongaMailSchedulerV2(UserInfo.getSessionId(), cases));
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'CongaMailSchedulerV2'];
        //System.assertEquals(1, logs.size(), 'Log for CongaMailScheduler not found');
    }
    
    @isTest static void test_method_three() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 1; i++) {
            Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='test@sample.com');
                con.CAP_ID__c = '71000000001'+ (i+7);   
            contacts.add(con);
        }
        insert contacts;
        
        List<Case> cases = new List<Case>();
        for(Contact con: contacts) {
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs.ContactId = con.Id;
            cs.Origin = 'Email';
            cs.Conga_Template_ID__c = 'a0VN00000044nye';
            cs.Contact_Email__c = 'test@sample.com';
            cases.add(cs);
        }
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        insert cases;
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('test');
        att.Name = 'Test Attachment';
        att.ParentId = cases[0].Id;
        insert att;
        System.enqueueJob(new CongaMailSchedulerV2(UserInfo.getSessionId(), cases));
        Test.stopTest();
        List<EmailMessage> emails = [SELECT Id, ParentId, HasAttachment FROM EmailMessage];
        System.debug(emails);
        //System.assert(emails.size() > 0, 'Email not sent');
        //System.assertEquals(cases[0].id, emails[0].ParentId);
        //System.assertEquals(true, emails[0].HasAttachment);
    }
    
    // This test method is for linkCaseToContact method of accConRshipUpdateonContacts class
    @isTest static void testLinkCaseToContact() {
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center,Conga, Advocacy and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Advocacy Agent').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Customer_Advocacy_Agent_Permissions,Composer_User');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        
        System.runAs(u1) {
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'User';            
            con.Alternate_Email__c = 'test@sample.com';
            con.QAC_Contact__c = 'No';
            con.Frequent_Flyer_Number__c = '12345';
            insert con;
            Case cs = new Case();
            cs.Type = 'Complaint';
            cs.Description = 'test';
            cs.Origin = 'Email';
            cs.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', 'CCC Complaints');
            insert cs;            
            Test.startTest();
            con.CaseId__c = cs.Id;
            update con;
            Test.stopTest();
           
        }
    }
}