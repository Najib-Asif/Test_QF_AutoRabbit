/*********************************************************************************
Name         : QCC_SpecificNeedsEmailTest
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 13 March 2020
Usages       : This class is used for the code coverage of the apex class below:
- QCC_SpecificNeedsMailInvocable, QCC_SpecificNeedsSendMailQueueable

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_SpecificNeedsEmailTest {
    @testSetUp
    public static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Trigger_Status__c> caseCustomSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert caseCustomSettingList;
        
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        List<Contact> contactList = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '1234567890';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.SSU__c = true;
        insert contactRecord;
        
        //Create test data for Case object
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Specific Needs').getRecordTypeId();
        
        system.debug('caseRecordTypeId'+caseRecordTypeId);
        system.debug('accountRecord.Id'+accountRecord.Id);
        system.debug('contactRecord.Id'+contactRecord.Id);
        Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRecord.RecordTypeId = caseRecordTypeId;
        caseRecord.Subject = 'TESTSUBJECT';
        caseRecord.Type = 'Mobility Aid';
        // caseRecord.Origin = 'Qantas.com';
        caseRecord.Contact_Email__c = 'ToEmailRecord@qantas.com.au';
        caseRecord.Description = 'test';
        insert caseRecord;
        
        EmailMessage email=new EmailMessage(FromAddress='FromEmailRecord@qantas.com.au',To_Address__c='ToEmailRecord@qantas.com.au',HtmlBody='This is an email for test class',MessageDate=system.now(),ParentId=caseRecord.id,subject='Qantas Freight Customer Support – Ref No ' + caseRecord.casenumber, RelatedToId =caseRecord.id, status='0');
        insert email;      
    }
    
    static testmethod void sendEmailTest(){
        test.startTest();
        Case caseRec = [SELECT Id, Contact_email__c FROM Case LIMIT 1];
        system.debug('case'+caseRec);
        EmailMessage emailRec= [SELECT id, parentId,To_Address__c From EmailMessage LIMIT 1];
        system.debug('EmailMessage'+emailRec);
        test.stopTest(); 
        
        System.assert(caseRec.Id == emailRec.parentID);
        System.assert(caseRec.contact_email__c == emailRec.To_Address__c);
    } 
}