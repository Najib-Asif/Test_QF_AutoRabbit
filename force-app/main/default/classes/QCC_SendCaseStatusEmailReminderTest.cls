/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_SendCaseStatusEmailReminderTest {
    
    @testSetup
    static void createData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        
        Test.startTest();
		//Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        List<Contact> contactRecords = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        insert contactRecord;
        
		List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
        
        //Create test data for Case object
        List<Case> caseRecords = new List<Case>();
        
        String specificNeedsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Specific Needs').getRecordTypeId();
        Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRecord.RecordTypeId = specificNeedsRecordTypeId;
        caseRecord.Status = 'Waiting for Internal';
        caseRecord.QCC_Internal_Followup_Emails__c = 'sample1@email.com;sample2@email.com';
        caseRecord.Contact_Email__c = 'sample1@email.com';
        caseRecords.add(caseRecord);
        
        Case caseRecord2 = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRecord2.RecordTypeId = specificNeedsRecordTypeId;
        caseRecord2.Status = 'Waiting for Customer';
        caseRecord2.QCC_Internal_Followup_Emails__c = 'sample1@email.com;sample2@email.com';
        caseRecord2.Contact_Email__c = 'sample1@email.com';
        caseRecords.add(caseRecord2);
        
        insert caseRecords;
        Test.stopTest();
    }
    
    static testMethod void test1(){
        Test.startTest();
        String fieldNames = '';
        Schema.DescribeSobjectResult[] objectDescribe = Schema.describeSObjects(new List<String>{'Case'});
        for(Schema.DescribeSobjectResult res : objectDescribe) {
            for (String fieldName : res.fields.getMap().keySet()) {
                if (fieldNames == '') {
                    fieldNames = fieldName;
                } else {
                    fieldNames = fieldNames + ',' + fieldName;
                }
            }
        }
        
        List<Case> caseRecords = Database.query('SELECT ' + fieldNames + ', RecordType.DeveloperName, Contact.SSU__c, Contact.Frequent_Flyer_Tier__c FROM Case LIMIT 5');
        List<QCC_SendCaseStatusEmailReminderInvocable.classVariable> wrapperList = new List<QCC_SendCaseStatusEmailReminderInvocable.classVariable>();
        for(Case caseRecord : caseRecords) {
            QCC_SendCaseStatusEmailReminderInvocable.classVariable myWrapper = new QCC_SendCaseStatusEmailReminderInvocable.classVariable();
            myWrapper.caseRecord = caseRecord;
            myWrapper.emailTemplateName = 'Email_Reminder_Day_3';
            wrapperList.add(myWrapper);
        }
        
        QCC_SendCaseStatusEmailReminderInvocable.sendCaseEmailReminder(wrapperList);
        Test.stopTest();
    }
}