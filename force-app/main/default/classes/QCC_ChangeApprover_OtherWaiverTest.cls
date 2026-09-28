/*********************************************************************************
Name         : QCC_ChangeApprover_OtherWaiverTest
Created By   : Lora Mae S. Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 August 2019
Usages       : This class is used for the code coverage of the apex class QCC_Change_Approver_Other_Waiver

Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_ChangeApprover_OtherWaiverTest {
    
    static User qantasCcOperationalManagerUser;
    static User qantasCcTeamLeadUser;    
    static User qantasCcConsultantUser;
    static QCC_Other_Waiver__c otherWaiver;
    
    static testMethod void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //create test data  for User object - Qantas CC Operational Manager
        Profile qantasCcOperationalManagerProfile = [Select Id, Name from Profile where Name = 'Qantas CC Operational Manager'];
        qantasCcOperationalManagerUser = QCC_TestDataFactory.createUserTestData(qantasCcOperationalManagerProfile.Id);
        insert qantasCcOperationalManagerUser;        
        
        //create test data  for User object - Qantas CC Team Lead
        Profile qantasCcTeamLeadProfile = [Select Id, Name from Profile where Name = 'Qantas CC Team Lead'];
        qantasCcTeamLeadUser = QCC_TestDataFactory.createOperationalManagerUserTestData(qantasCcTeamLeadProfile.Id, qantasCcOperationalManagerUser.Id);
        insert qantasCcTeamLeadUser;        
        
        //create test data  for User object - Qantas CC Consultant
        Profile qantasCcConsultantProfile = [Select Id, Name from Profile where Name = 'Qantas CC Consultant'];
        qantasCcConsultantUser = QCC_TestDataFactory.createManagerUserTestData(qantasCcConsultantProfile.Id, qantasCcTeamLeadUser.Id);
        insert qantasCcConsultantUser;

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
        insert contactRecord;
        
        //Create test data for Other_Waiver__c object
        otherWaiver = QCC_TestDataFactory.createOtherWaiverTestData(qantasCcConsultantUser.Id, contactRecord.Id);
        otherWaiver.QCC_Status__c = 'Open';
        otherWaiver.QCC_Amount__c = 5000;
        insert otherWaiver;
    }
    
    static testMethod void testchangeApprover() {        
        setupTestData();

        //start the test for the changeApprover method
        //run as Qantas Cc Consultant profile
        Test.startTest();
        system.runAs(qantasCcConsultantUser){            
            //submit approval request
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setObjectId(otherWaiver.Id);        
            Approval.ProcessResult result = Approval.process(req);
            
            QCC_Other_Waiver__c otherWaiverRecord = [SELECT id FROM QCC_Other_Waiver__c];
            List<Id> recordIDsList = new List<Id>();
            recordIDsList.add(otherWaiverRecord.Id);
            QCC_ChangeApprover_OtherWaiver.changeApprover(recordIDsList);
        }
        Test.stopTest();        
    }
}