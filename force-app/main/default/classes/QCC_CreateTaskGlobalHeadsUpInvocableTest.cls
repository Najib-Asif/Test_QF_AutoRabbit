/*********************************************************************************
Name         : QCC_CreateTaskGlobalHeadsUpInvocableTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 10 October 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_CreateTaskForGlobalHeadsUpInvocable
*********************************************************************************/
@isTest
public class QCC_CreateTaskGlobalHeadsUpInvocableTest {
	@testSetup
    static void setupTestData(){
                TestUtilityDataClassQantas.insertQantasConfigData();
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
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        insert contactRecord;
        
        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;
        
        Event__c flightEventRecord = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord.Name = 'Sample Global Heads Up Event';
        flightEventRecord.RecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
        flightEventRecord.Affected_Ports__c = 'MNL';
        flightEventRecord.Comments__c = 'Sample';
        flightEventRecord.Global_Event_Type__c = 'Airport Event';
        flightEventRecord.Global_Event_Sub_Type__c = 'Cyclone';
        flightEventRecord.Start_Date__c = System.today();
        flightEventRecord.End_Date__c = System.today();
        flightEventRecord.QCC_Local_Start_Time__c = datetime.now().time().addHours(-2);
        flightEventRecord.QCC_Local_End_Time__c = datetime.now().time().addHours(2);
        insert flightEventRecord;
    }
    
    static testmethod void test1(){
        Id recordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
        List<Event__c> flightEventRecords = [SELECT Id FROM Event__c WHERE RecordTypeId =: recordTypeId];
        QCC_CreateTaskForGlobalHeadsUpInvocable.execute(flightEventRecords);
    }
    
    static testmethod void test2(){
        Id recordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
        List<Event__c> flightEventRecords = [SELECT Id FROM Event__c WHERE RecordTypeId =: recordTypeId];
        flightEventRecords[0].Comments__c = null;
        
        update flightEventRecords;
        QCC_CreateTaskForGlobalHeadsUpInvocable.execute(flightEventRecords);
    }
}