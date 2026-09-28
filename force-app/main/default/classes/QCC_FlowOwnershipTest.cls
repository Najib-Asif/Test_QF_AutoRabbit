/*==============================================================================================================================
Author:         Rinaldo Clucher
Company:        Salesforce
Purpose:        This Class will be used to test change in owneership method.
. 
Date:           29/03/2021
==============================================================================================================================
History:
29-Mar-2021      RC               First Release.
Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
==============================================================================================================================*/
@isTest
public class QCC_FlowOwnershipTest {
    @TestSetup
    public static void insertTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest
    Static void test_change_case_owner(){
        
        Id profileAdminId = [Select Id from profile where name='System Administrator'].id;
        Id roleCCCId = [SELECT Id,Name FROM UserRole where Name = 'QF-QDC'].Id;
        
        Id queueId = [Select Id from group where DeveloperName='CCC_R1_Post_Travel_Q'].id;
        
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
            testCase.ownerId = queueId;
            insert testCase;
        }
        Test.startTest();
        System.runAs(testUser){
            
            List <Id> testIdList = new List <Id>();
            List <Case> testCaseList = new List <Case>();
            
            testIdList.add(testCase.Id);
            
            testCaseList = QCC_FlowOwnership.changeCaseOnwerToCurrentUser(testIdList);
            System.Assert(testCaseList[0].ownerId == testUser.Id);
        }
        Test.stopTest();
    }
}