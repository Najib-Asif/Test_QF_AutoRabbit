/*==============================================================================================================================
Author:         Rinaldo Clucher
Company:        Salesforce
Purpose:        This Class will be used to load files.
. 
Date:           29/03/2021
==============================================================================================================================
History:
29-Mar-2021      RC               First Release.

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
==============================================================================================================================*/
@isTest
public class QCC_LoadFileControllerTest {

    @TestSetup
    public static void insertTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest
    Static void test_File_Upload(){

        Id profileAdminId = [Select Id from profile where name='System Administrator'].id;
        Id roleCCCId = [SELECT Id,Name FROM UserRole where Name = 'QF-QDC'].Id;
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_Complaints').getRecordTypeId();
        Account customerAccount;
        Case testCase;
        List<ContentDocument> attachedDocs;

        User testUser = QCC_TestDataFactory.createUserTestData(profileAdminId);
        testUser.UserRoleId = roleCCCId;
        insert testUser;

        System.runAs(testUser){
    
            List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());

            Trigger_Status__c Contentdocumentlinkstatus = new Trigger_Status__c();
            Contentdocumentlinkstatus.Name = 'ContentDocLinkTriggerCheck';
            lsttrgStatus.add(Contentdocumentlinkstatus);

            for(Trigger_Status__c ts : lsttrgStatus){
                ts.Active__c = false;
            }
            insert lsttrgStatus; 
    
            customerAccount = QCC_TestDataFactory.createAccountTestData(1);
            insert customerAccount;
            
            Contact customerContact =  QCC_TestDataFactory.createContactTestData(1, customerAccount.Id);
            insert customerContact;

            testCase = QCC_TestDataFactory.createCaseTestData(customerAccount.Id, customerContact.Id);
            testCase.recordTypeId = caseRecordTypeId;
            insert testCase;
        }
        Test.startTest();
        System.runAs(testUser){
            QCC_TestDataFactory.createFile(testCase.Id);
            attachedDocs = QCC_LoadFileController.getAllUploadedFiles((string)testCase.Id); 
            system.debug('### Attached Docs'+ [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = : attachedDocs[0].Id]);
            System.Assert(attachedDocs.size() > 0);

            QCC_LoadFileController.CaseResponseWrapper relatedComment = QCC_LoadFileController.createCaseCommentRecord((string)testCase.Id, 'Test File Name');
            List <CaseComment> commentList =  [SELECT Id FROM CaseComment];
            System.Assert(commentList.size() > 0);
        }
        Test.stopTest();
    }
}