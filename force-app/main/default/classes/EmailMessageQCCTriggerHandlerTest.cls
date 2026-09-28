/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 04-28-2024
 * @last modified by  : Praveen Sampath
**/
@isTest
public class EmailMessageQCCTriggerHandlerTest {

    @testSetup
    static void setup() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        Test.startTest();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList1;
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEmailMessageTriggerSetting());

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
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        //(User Story: QSFR-23) START
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_DamagedBaggageHighQueue','CCC_R1_Damaged_Baggage_Q'));
        insert lstConfigData;
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();

        List<User> testUsers = new List<User>();
        // RBAC - Updated Profile name to QCC Contact Center Agent CRM-11628
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com',
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                           TimeZoneSidKey = 'Australia/Sydney'
                           );
        testUsers.add(u1);
        User u2 = new User(LastName = 'User2', Alias = 'User', Email = 'sampleuser2@sample.com',
                           Username = 'sampleuser2username@sample.com', ProfileId = profMap.get('Data Administrator').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                           TimeZoneSidKey = 'Australia/Sydney'
                           );
        testUsers.add(u2);
        // RBAC - Updated Profile name to QCC Contact Center Agent CRM-11628
        User u3 = new User(LastName = 'User3', Alias = 'User', Email = 'sampleuser3@sample.com',
                           Username = 'sampleuser3username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                           TimeZoneSidKey = 'Australia/Sydney'
                           );
        testUsers.add(u3);
        // RBAC - Updated Profile name to QCC Operational Manager
        User u4 = new User(LastName = 'User4', Alias = 'User', Email = 'sampleuser4@sample.com',
                           Username = 'sampleuser4username@sample.com', ProfileId = profMap.get('QCC Operational Manager').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                           TimeZoneSidKey = 'Australia/Sydney'
                           );
        testUsers.add(u4);
        insert testUsers;
         // RBAC - added permissions to test user CRM-11628
		System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIdsCon = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<Id> permissionSetIdsLead = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions,QCC_Team_Lead_Coaching_and_Training_User_Permissions');
            List<PermissionSetAssignment> psaListcon = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIdsCon);
            List<PermissionSetAssignment> psaListcolead = TestUtilityDataClassQantas.createPermissionSetAssignments(u3.Id,permissionSetIdsLead);
        }
        System.runAs(u2){
            Account acc        = TestUtilityDataClassQantas.createAccountOfQantasCorporateEmailAccount();
            acc.ABN_Tax_Reference__c = '11111111111';
            insert acc;
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup acc: '+acc);
            Contact con        = TestUtilityDataClassQantas.createContact(acc.Id);
            con.Business_Types__c = 'Agency';
            con.Job_Role__c       = 'Other';
            con.Function__c       = 'Other';
            con.Frequent_Flyer_Tier__c = 'Bronze';
            con.Frequent_Flyer_Number__c = '12345';
            insert con;
            con.AccountId         = acc.id;
            update con;
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup con: '+con);
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup con Acc Name: '+con.Account.Name);
            Case newcase1      = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Complaints','Complaint','Departure Airport','Announcements','General','');
            newcase1.ContactId = con.id;
            newcase1.Origin    = 'Phone';
            insert newcase1;
        }
        Test.stopTest();
    }

    
    static testMethod void testnegetive() {
        Case objCase =  [Select Id, Acknowledgement_Sent__c, First_email_to_customer__c from Case where RecordType.DeveloperName = 'CCC_Complaints' Limit 1];
        objCase.Acknowledgement_Sent__c = true;
        update objCase;
        EmailMessageQCCTriggerHandler test = new EmailMessageQCCTriggerHandler();
        EmailMessage em   = new EmailMessage();
        em.Incoming       = false;
        em.FromAddress    = 'qantas_customer_care@qantas.com.au';
        em.ToAddress      = 'test@test.com';
        em.Subject        = 'Qantas Customer Care';
        em.HtmlBody       = '<br/><h1>Hello!!</h1>';
        em.Status         = '3';
        em.ParentId       = objCase.Id;
        EmailMessage emTwo= em.clone(false, false, false, false);
        emTwo.ToAddress   = 'test@email.com';
        //insert emTwo;
        List<EmailMessage> emgs = new List<EmailMessage>();
        emgs.add(emTwo);
        EmailMessageQCCTriggerHandler.beforeInsert(emgs, null);
        Map<Id, EmailMessage> newQCCEmailMessageMap = new Map<Id, EmailMessage>();
        newQCCEmailMessageMap.put(emTwo.id, emTwo);
        EmailMessageQCCTriggerHandler.afterInsert(newQCCEmailMessageMap, null, null,null,null,null);
        EmailMessageQCCTriggerHandler.beforeUpdate(newQCCEmailMessageMap, null);
        EmailMessageQCCTriggerHandler.afterUpdate(newQCCEmailMessageMap, null, null,null,null,null);
        EmailMessageQCCTriggerHandler.processCaseEmailMessage(null, null, null,null);
        EmailMessageQCCTriggerHandler.fetchAllOutboundEmailsOfACase(null, null, null);
    }
    
    static testMethod void testcaptureFirstOutboundEmail() {
        
        Case objCase =  [Select Id, Acknowledgement_Sent__c, First_email_to_customer__c from Case where RecordType.DeveloperName = 'CCC_Complaints' Limit 1];
        objCase.Acknowledgement_Sent__c = true;
        update objCase;
        Test.startTest();
        EmailMessageQCCTriggerHandler test = new EmailMessageQCCTriggerHandler();
        EmailMessage em   = new EmailMessage();
        em.Incoming       = false;
        em.FromAddress    = 'qantas_customer_care@qantas.com.au';
        em.ToAddress      = 'test@test.com';
        em.Subject        = 'Qantas Customer Care';
        em.HtmlBody       = '<br/><h1>Hello!!</h1>';
        em.Status         = '3';
        em.ParentId       = objCase.Id;
        EmailMessage emTwo= em.clone(false, false, false, false);
        emTwo.ToAddress   = 'test@email.com';
        insert emTwo;
        
        insert em;
        //update emTwo;
        
    }

    static testMethod void testprocessCaseEmailMessage(){
        Set<Id> emailMessageIDSet = new Set<Id>();
        User u1 = [Select Id, Username from User where Username = 'sampleuser1username@sample.com'];
        User u2 = [Select Id, Username from User where Username = 'sampleuser2username@sample.com'];
        
        u1.CCAT_User__c = true;
        update u1;
        
        System.debug('userid = '+u1.Id);
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId, RecordTypeId, Type, Group__c, Cabin_Class__c, OwnerId From Case where ContactId=: cont.id Limit 1];
        ncase.Type   = 'Baggage';
        ncase.Group__c = 'Damaged Baggage';
        ncase.Cabin_Class__c = 'Economy';
        ncase.FF_Tier__c='Gold';
        ncase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        System.debug('case owner = '+ncase.OwnerId);
        ncase.OwnerId = u1.Id;
        //List<Task> tt = [Select Subject,Status,Case_Status__c,ActivityDate,WhatId,WhoId,Email__c,Task_From__c From Task Where WhatId=: em.ParentId];
        ncase.Auto_Close_on_Email_Sent__c = true;
       // ncase.Status='Resolved';
        ncase.Status='Closed';
        ncase.Resolution_Method__c='Email';
        ncase.OwnerId=u2.id;
        ncase.QCC_Internal_Followup_Emails__c = 'qantas_customer_care@qantas.com.au';
        update ncase;
               
        cont.SSU__c = true;
        update cont;
               
        
        EmailMessage em   = new EmailMessage();
        system.runAs(u2) {
            //Sending email
            em.Incoming       = false;
            //em.FromAddress    = CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email');
            em.FromAddress    = 'qantas_customer_care@qantas.com.au';
            em.ToAddress      = cont.Email;
            em.Subject        = 'Qantas Customer Care';
            em.HtmlBody       = '<br/><h1>Hello!!</h1>';
            em.Status         = '3';
            em.ParentId       = ncase.id;
            em.QCC_Tech_Is_Internal_Email__c=true;
            insert em;
        }
        
        Case closedCase     = [select Id , Status FROM Case where Id =: ncase.id];
        //GRAPHITE- 1380 - comment out 136 then replace status w/ Resolved
       // System.assert(closedCase.Status == 'Resolved');
        System.assert(closedCase.Status == 'Closed');
       
        Test.startTest();
        for(EmailMessage email:[select id from EmailMessage]){
            emailMessageIDSet.add(email.id);    
        }
       // EmailMessageTriggerHelper.processCaseEmailMessage(emailMessageIDSet);
        Test.stopTest();
    } 

    
    static testMethod void testprocessCaseEmailMessageforOutgoingEmails(){
        Set<Id> emailMessageIDSet = new Set<Id>();
        User u1 = [Select Id, Username from User where Username = 'sampleuser1username@sample.com'];
        User u2 = [Select Id, Username from User where Username = 'sampleuser2username@sample.com'];
        System.debug('userid = '+u1.Id);
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId, RecordTypeId,Acknowledgement_Sent__c, Type, Group__c, Cabin_Class__c, OwnerId From Case where ContactId=: cont.id Limit 1];
        ncase.Type   = 'Baggage';
        ncase.Group__c = 'Damaged Baggage';
        ncase.Cabin_Class__c = 'Economy';
        ncase.FF_Tier__c='Gold';
        ncase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        System.debug('case owner = '+ncase.OwnerId);
        ncase.OwnerId = u1.Id;
        ncase.Auto_Close_on_Email_Sent__c = true;
        ncase.Status='New';
        ncase.Resolution_Method__c='Email';
        ncase.OwnerId=u2.id;
        ncase.Acknowledgement_Sent__c = false;
        update ncase;
        
        EmailMessage em   = new EmailMessage();
        system.runAs(u2) {
            //Sending email
            em.Incoming       = false;
            em.FromAddress    =  'qantas_customer_care@qantas.com.au';
            em.ToAddress      = cont.Email; 
            em.Subject        = 'Qantas Customer Care';
            em.HtmlBody       = '<br/><h1>Hello!!</h1>';
            em.Status         = '3';
            em.ParentId       = ncase.id;
            em.QCC_Tech_Is_Internal_Email__c=true;
            em.TECH_FromChatter__c = false;
            insert em;
        }
        
        Case cs     = [select Id ,Auto_Close_on_Email_Sent__c,Recovery_Inprogress__c, Status FROM Case where Id =: ncase.id];
        cs.Acknowledgement_Sent__c = true;
        Test.startTest();
        update cs;
        EmailMessage email = [select id,TECH_FromChatter__c from EmailMessage LIMIT 1]; 
        email.TECH_FromChatter__c = false;
        update email;
       
        Test.stopTest();
    } 

    static testMethod void testprocessCaseEmailMessageforOutgoingEmails1(){
        Set<Id> emailMessageIDSet = new Set<Id>();
        User u1 = [Select Id, Username from User where Username = 'sampleuser1username@sample.com'];
        User u2 = [Select Id, Username from User where Username = 'sampleuser2username@sample.com'];
        System.debug('userid = '+u1.Id);
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId, RecordTypeId,Acknowledgement_Sent__c, Type, Group__c, Cabin_Class__c, OwnerId From Case where ContactId=: cont.id Limit 1];
        ncase.Type   = 'Baggage';
        ncase.Group__c = 'Damaged Baggage';
        ncase.Cabin_Class__c = 'Economy';
        ncase.FF_Tier__c='Gold';
        ncase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        System.debug('case owner = '+ncase.OwnerId);
        ncase.OwnerId = u1.Id;
        ncase.Auto_Close_on_Email_Sent__c = true;
        ncase.Status='New';
        ncase.Resolution_Method__c='Email';
        ncase.OwnerId=u2.id;
        ncase.Acknowledgement_Sent__c = false;
        update ncase;
        
        EmailMessage em   = new EmailMessage();
        system.runAs(u2) {
            //Sending email
            em.Incoming       = false;
            em.FromAddress    =  'qantas_customer_care@qantas.com.au';
            em.ToAddress      = cont.Email; 
            em.Subject        = 'Qantas Customer Care';
            em.HtmlBody       = '<br/><h1>Hello!!</h1>';
            em.Status         = '3';
            em.ParentId       = ncase.id;
            em.QCC_Tech_Is_Internal_Email__c=true;
            em.TECH_FromChatter__c = false;
            insert em;
        }
        
        Case cs     = [select Id ,Auto_Close_on_Email_Sent__c,Recovery_Inprogress__c, Status FROM Case where Id =: ncase.id];
        cs.Acknowledgement_Sent__c = true;
        cs.Recovery_Inprogress__c = true;
        Test.startTest();
        update cs;
        EmailMessage email = [select id,TECH_FromChatter__c from EmailMessage LIMIT 1]; 
        email.TECH_FromChatter__c = false;
        update email;
       
        Test.stopTest();
    } 



    /*
    static testMethod void testprocessCaseEmailMessageforIncomingEmails(){
        Set<Id> emailMessageIDSet = new Set<Id>();
        EmailMessageQCCTriggerHandler test = new EmailMessageQCCTriggerHandler();
        User u1 = [Select Id, Username from User where Username = 'sampleuser1username@sample.com'];
        User u2 = [Select Id, Username from User where Username = 'sampleuser2username@sample.com'];
        System.debug('userid = '+u1.Id);
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId, RecordTypeId, Type, Group__c, Cabin_Class__c, OwnerId From Case where ContactId=: cont.id Limit 1];
        ncase.Type   = 'Baggage';
        ncase.Group__c = 'Damaged Baggage';
        ncase.Cabin_Class__c = 'Economy';
        ncase.FF_Tier__c='Gold';
        ncase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        System.debug('case owner = '+ncase.OwnerId);
        ncase.OwnerId = u1.Id;
        ncase.Auto_Close_on_Email_Sent__c = true;
        ncase.Status='New';
        ncase.Resolution_Method__c='Email';
        ncase.OwnerId=u2.id;
        update ncase;
        
        EmailMessage em   = new EmailMessage();
        system.runAs(u2) {
            //Sending email
            em.Incoming       = true;
            em.FromAddress    =  cont.Email;
            em.ToAddress      = 'qantas_customer_care@qantas.com.au';
            em.Subject        = 'Qantas Customer Care';
            em.HtmlBody       = '<br/><h1>Hello!!</h1>';
            em.Status         = '3';
            em.ParentId       = ncase.id;
            em.QCC_Tech_Is_Internal_Email__c=true;
            insert em;
        }
        
        Case closedCase     = [select Id , Status FROM Case where Id =: ncase.id];
        EmailMessage email = [select id from EmailMessage LIMIT 1]; 
        update email;
    } 
*/
    static testMethod void testprocessCaseEmailMessageforIncomingEmailsForWaitingforCustomerCases(){
        Set<Id> emailMessageIDSet = new Set<Id>();
        User u1 = [Select Id, Username from User where Username = 'sampleuser1username@sample.com'];
        User u2 = [Select Id, Username from User where Username = 'sampleuser2username@sample.com'];
        System.debug('userid = '+u1.Id);
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId, RecordTypeId, Type, Group__c, Cabin_Class__c, OwnerId From Case where ContactId=: cont.id Limit 1];
        ncase.Type   = 'Baggage';
        ncase.Group__c = 'Damaged Baggage';
        ncase.Cabin_Class__c = 'Economy';
        ncase.FF_Tier__c='Gold';
        ncase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        System.debug('case owner = '+ncase.OwnerId);
        ncase.OwnerId = u1.Id;
        ncase.Auto_Close_on_Email_Sent__c = true;
        ncase.Status='Waiting for Customer';
        ncase.Resolution_Method__c='Email';
        ncase.OwnerId=u2.id;
        update ncase;
        
        EmailMessage em   = new EmailMessage();
        system.runAs(u2) {
            //Sending email
            em.Incoming       = true;
            em.FromAddress    =  cont.Email;
            em.ToAddress      = 'qantas_customer_care@qantas.com.au';
            em.Subject        = 'Qantas Customer Care 1234';
            em.HtmlBody       = '<br/><h1>Hello!!</h1>';
            em.Status         = '3';
            em.ParentId       = ncase.id;
            em.QCC_Tech_Is_Internal_Email__c=true;
            insert em;
        }
        
        Case closedCase     = [select Id , Status FROM Case where Id =: ncase.id];
       
        Test.startTest();
        for(EmailMessage email:[select id from EmailMessage]){
            emailMessageIDSet.add(email.id);    
        }
       
        Test.stopTest();
    }

    static testMethod void testEmailMessageTrigger1() {
        EmailMessage em   = new EmailMessage();
        em.Incoming       = false;
        em.FromAddress    = 'qantas_customer_care@qantas.com.au';
        em.To_Address__c  = 'onlinesalesqueries@qantas.com.au';
        em.Subject        = 'Qantas Customer Care';
        em.HtmlBody       = '<br/><h1>Hello!!</h1>';
        em.Status         = '3';
        Test.startTest();
        insert em;
        Test.stopTest();
        EmailMessage msg = [SELECT Id, To_Address__c FROM EmailMessage WHERE Id = :em.Id];

        em.TECH_FromChatter__c = false;

        update em;
        System.assertEquals(em.To_Address__c, msg.To_Address__c );
    }

    static testMethod void testEmailMessageTrigger2() {
        EmailMessage em   = new EmailMessage();
        em.Incoming       = false;
        em.FromAddress    = 'test@qantas.com.au';
        em.To_Addresss__c  = 'test@test.com';
        em.Subject        = 'Qantas Customer Care';
        em.HtmlBody       = '<br/><h1>Hello!!</h1>';
        em.Status         = '3';
        Test.startTest();
        insert em;
        Test.stopTest();
        EmailMessage msg = [SELECT Id, To_Addresss__c FROM EmailMessage WHERE Id = :em.Id];
        System.assertEquals(em.To_Addresss__c, msg.To_Addresss__c);
    }


}