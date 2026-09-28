/*----------------------------------------------------------------------------------------------------------------------
Author:        Bharathkumar
Company:       Tata Consultancy services
Description:   QCC EmailMessageCreditCardNoticeHelperTest
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
21-July-2018      Bharathkumar               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/

@isTest
public class QCC_EmailMessageCreditCardHelperTest {
 @testSetup 
    static void setup() {
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
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
        //TestUtilityDataClassQantas.insertQantasConfigData();
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();

        List<User> testUsers = new List<User>();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628                       
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
        User u3 = new User(LastName = 'User3', Alias = 'User', Email = 'sampleuser3@sample.com', 
                               Username = 'sampleuser3username@sample.com', ProfileId = profMap.get('Qantas CC Team Lead').Id,
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        testUsers.add(u3);
        User u4 = new User(LastName = 'User4', Alias = 'User', Email = 'sampleuser4@sample.com', 
                               Username = 'sampleuser4username@sample.com', ProfileId = profMap.get('QCC Operational Manager').Id,
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        testUsers.add(u4);
        insert testUsers;
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628               
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }

        // CRM-11911 - Added permission sets to test user
        System.runAs(new User(Id = UserInfo.getUserId())) {
           List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Team_Lead_Coaching_and_Training_User_Permissions, QCC_Analytics_User_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u4.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }

        System.runAs(u1){
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
    }  
    
    static void PreventdeleteEmailMessage1(){
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        User u2 = [Select Username from User where Username = 'sampleuser2username@sample.com'];
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId,Record_Type__c , Type From Case where ContactId=: cont.id Limit 1];
            
        Test.startTest();
        ncase.Type   = 'Baggage';
        EmailMessage em   = new EmailMessage();
        System.runAs(u2){
            //Sending email         
            em.Incoming       = false;
            em.FromAddress    = CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email');
            em.ToAddress      = cont.Email;
            em.Subject        = 'Qantas Customer Care';
            em.HtmlBody       = '<br/><h1>Hello!!</h1>';
            em.Status         = '3';
            em.ParentId       = ncase.id;
            insert em;
        }
        
        System.runAs(u1){
            try {
                EmailMessage msg = [SELECT Id FROM EmailMessage WHERE Id =: em.Id];
                delete msg;
            } catch(Exception e) {
                System.debug(e.getMessage());
                System.assert(e.getMessage().contains('You do not have access to delete the EmailMessage'));
            }
        }
        Test.stopTest();
    }
    
    @isTest 
    static void PreventdeleteEmailMessage2(){
        User u3 = [Select Id, Username from User where Username = 'sampleuser3username@sample.com'];
        User u2 = [Select Id, Username from User where Username = 'sampleuser2username@sample.com'];
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id, OwnerId From Case where ContactId=: cont.id Limit 1];
            
        Test.startTest();
        ncase.OwnerId   = u3.Id;
        update ncase;
        EmailMessage em   = new EmailMessage();
        System.runAs(u2){
            //Sending email         
            em.Incoming       = true;
            em.FromAddress    = CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email');
            em.ToAddress      = cont.Email;
            em.Subject        = 'Qantas Customer Care';
            em.HtmlBody       = '<br/><h1>4363030108191479</h1>';
            em.TextBody        ='test';
            em.Status         = '3';
            em.ParentId       = ncase.id;
            insert em;
        }
       
        List<EmailMessage> em1= new List<EmailMessage>();
        em1.add(em);
        boolean isPhoneNumber=true;
        QCC_EmailMessageCreditCradNoticeHelper.maskCreditCard(em1);
        
        System.runAs(u3){
            try {
                List<EmailMessage> msg = [SELECT Id FROM EmailMessage WHERE Id =: em.Id];
                 insert msg;
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    
}