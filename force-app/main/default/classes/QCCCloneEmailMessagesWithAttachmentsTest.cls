/*----------------------------------------------------------------------------------------------------------------------
Author:        Pradnya Unde
Company:       TCS
Description:   Test class for QCCCloneEmailMessagesWithAttachments--Jira CRM-5051
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCCCloneEmailMessagesWithAttachmentsTest {
    @testSetup
    static void setup() {
        Test.startTest();
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList1;
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEmailMessageTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        
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
        //(User Story: QSFR-23) END
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
        insert testUsers;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
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
            


            Case newchildcase1      = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Complaints','Complaint','Departure Airport','Announcements','General','');
            newchildcase1.ContactId = con.id;
            newchildcase1.Origin    = 'Email';
            newchildcase1.ParentId    = newcase1.Id;
            //insert newchildcase1;
        }
        Test.stopTest();
    }

    static testMethod void testCreateEmailMessagesWithAttachments() { 
        User u1 = [Select Id, Username from User where Username = 'sampleuser1username@sample.com'];
        System.debug('userid = '+u1.Id);
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId, RecordTypeId, Type, Group__c, Cabin_Class__c, OwnerId From Case where ContactId=: cont.id Limit 1];
        ncase.Type   = 'Baggage';
        ncase.Group__c = 'Delayed Baggage';
        ncase.Cabin_Class__c = 'Economy';
        ncase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        System.debug('case owner = '+ncase.OwnerId);
        ncase.OwnerId = u1.Id;
        ncase.Auto_Close_on_Email_Sent__c = true;
        update ncase;

        ContentVersion objContVersion = new ContentVersion(Title = 'EmailAttachment',  PathOnClient = 'EmailAttachment.pdf', 
                                                           VersionData = Blob.valueOf('Email Attachment Content'), IsMajorVersion = true);
        insert objContVersion; 
        
        List<ContentDocument> objCOnDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
        EmailMessage emIn   = new EmailMessage(); 
        emIn.Incoming       = true;
        emIn.FromAddress    = cont.Email;
        emIn.ToAddress      = CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email');
        emIn.Subject        = 'Qantas Customer Care';
        emIn.HtmlBody       = '<br/><h1>Hello!!</h1>';
        emIn.Status         = '3';
        emIn.ParentId       = ncase.id;  
        emIn.QCC_Has_Attachment__c = true;
        insert emIn;    
        //create ContentDocumentLink  record 
        ContentDocumentLink objCDL = New ContentDocumentLink();
        objCDL.LinkedEntityId =  emIn.Id;
        objCDL.ContentDocumentId = objCOnDoc[0].Id;
        objCDL.shareType = 'V';
        insert objCDL;
        
        List<EmailMessage> emlist = new List<EmailMessage>();
        emlist.add(emIn);
        Test.startTest();
            List<QCCCloneEmailMessagesWithAttachments.inputWrapper> inputs = new List<QCCCloneEmailMessagesWithAttachments.inputWrapper>();
            QCCCloneEmailMessagesWithAttachments.inputWrapper iw = new QCCCloneEmailMessagesWithAttachments.inputWrapper();
            iw.parentCaseId = ncase.Id;
        	iw.childCaseId = ncase.Id;
            iw.parentCaseEmailMsgs = emlist;            
            iw.isFromEmailReplyReceived = true;
            inputs.add(iw);
            QCCCloneEmailMessagesWithAttachments.createEmailMessagesWithAttachments(inputs);
        
       		inputs = new List<QCCCloneEmailMessagesWithAttachments.inputWrapper>();
            iw = new QCCCloneEmailMessagesWithAttachments.inputWrapper();
            iw.parentCaseId = ncase.Id;
        	iw.childCaseId = ncase.Id;
            iw.parentCaseEmailMsgs = emlist;            
            iw.isFromEmailReplyReceived = false;
            inputs.add(iw);
            QCCCloneEmailMessagesWithAttachments.createEmailMessagesWithAttachments(inputs);
        Test.stopTest();
        List<emailmessage> emailMsgs = [SELECT ID, IsAsyncLogic__c, ValidatedFromAddress FROM EmailMessage];
        System.assertEquals(emailMsgs[0].IsAsyncLogic__c, true);
        System.assertEquals(emailMsgs[0].ValidatedFromAddress, 'test1contact@duptest.com');

    }
    
    
    static testMethod void testCreateEmailMessagesWithAttachments2() { 
        User u1 = [Select Id, Username from User where Username = 'sampleuser1username@sample.com'];
        System.debug('userid = '+u1.Id);
        Account acct = [SELECT Id,Name FROM Account WHERE Name='QantasCorporateEmailAccount' LIMIT 1];
        Contact cont = [Select Id,Name,Email,AccountId From Contact Where Account.Name ='QantasCorporateEmailAccount' Limit 1];
        Case ncase   = [Select Id,CaseNumber,ContactId, RecordTypeId, Type, Group__c, Cabin_Class__c, OwnerId From Case where ContactId=: cont.id Limit 1];
        ncase.Type   = 'Baggage';
        ncase.Group__c = 'Delayed Baggage';
        ncase.Cabin_Class__c = 'Economy';
        ncase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        System.debug('case owner = '+ncase.OwnerId);
        ncase.OwnerId = u1.Id;
        ncase.Auto_Close_on_Email_Sent__c = true;
        update ncase;

        ContentVersion objContVersion = new ContentVersion(Title = 'EmailAttachment',  PathOnClient = 'EmailAttachment.pdf', 
                                                           VersionData = Blob.valueOf('Email Attachment Content'), IsMajorVersion = true);
        insert objContVersion; 
        
        List<ContentDocument> objCOnDoc = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
        EmailMessage emIn   = new EmailMessage(); 
        emIn.Incoming       = true;
        emIn.FromAddress    = cont.Email;
        emIn.ToAddress      = CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email');
        emIn.Subject        = 'Qantas Customer Care 1';
        emIn.HtmlBody       = '<br/><h1>Hello!!</h1>';
        emIn.Status         = '3';
        emIn.ParentId       = ncase.id;  
        emIn.QCC_Has_Attachment__c = true;
        insert emIn;    
        //create ContentDocumentLink  record 
        ContentDocumentLink objCDL = New ContentDocumentLink();
        objCDL.LinkedEntityId =  emIn.Id;
        objCDL.ContentDocumentId = objCOnDoc[0].Id;
        objCDL.shareType = 'V';
        insert objCDL;
        
        EmailMessage emIn2   = new EmailMessage(); 
        emIn2.Incoming       = true;
        emIn2.FromAddress    = cont.Email;
        emIn2.ToAddress      = CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email');
        emIn2.Subject        = 'Qantas Customer Care 2';
        emIn2.HtmlBody       = '<br/><h1>Hello!!</h1>';
        emIn2.Status         = '3';  
        emIn2.QCC_Has_Attachment__c = true;
        //insert emIn2;  
        List<EmailMessage> lst2 = new List<EmailMessage>();
        lst2.add(emIn2);

        Test.startTest();
        
        	QCCCloneEmailMessagesWithAttachments.createChildContentDocumentLinks(emIn.Id, JSON.serialize(lst2), true);
        Test.stopTest();
        
    }

}