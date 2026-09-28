/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an org are executed whenever Apex code is deployed
* to a production org to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production org. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the org size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class ViewAllFilesControllerTest {
    
    @testSetup
    static void createTestData(){
        //Enable Account, Contact,Case Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEmailMessageTriggerSetting());
        insert lsttrgStatus;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        //Create Account
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');
        
        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        objContact.CAP_ID__c='710000000017';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');
        
        //Create Case
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        String recordType = 'CCC Complaints';
        String type = 'Complaint';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Flight Disruptions','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');
        
        
        ContentVersion objContVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            FirstPublishLocationId = lstCase[0].Id
        );
        insert objContVersion; 
        
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('EmailAttachment.pdf');
        attach.setInline(false);
        attach.Body = Blob.valueOf('Email Attachment Content');
        //Apex Single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] { CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email') });//Set To Email Address
        mail.setSubject('Qantas Customer Care');//Set Subject
        mail.setHtmlBody('<br/><h1>Hello!!</h1>');//Set HTML Body
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });//Set File Attachment
        mail.setWhatId(lstCase[0].Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });//Send Email
        
    }
    
    @isTest
    static void testGetRelatedDocs(){
        case rec = [select id from case limit 1];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :rec.Id limit 1];
        ViewAllFilesController.getRelatedDocs(rec.Id);
        ViewAllFilesController.getDocURL(cdl.ContentDocumentId);
    }
    
    @isTest
    static void testGetDocURL(){
        case rec = [select id from case limit 1];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :rec.Id limit 1];
        ViewAllFilesController.getDocURL(cdl.ContentDocumentId);
    }
    
    @isTest
    static void testDeleteDoc(){
        case rec = [select id from case limit 1];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :rec.Id limit 1];
        ViewAllFilesController.deleteDoc(cdl.ContentDocumentId);
    }
    
    @isTest
    static void testRemoveRecord(){
        case rec = [select id from case limit 1];
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :rec.Id limit 1];
        ViewAllFilesController.removeRecord(cdl.ContentDocumentId);
    }
}