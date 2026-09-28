/**********************************************************************
Name:  QP_AccountFlowControllerTest
Copyright © 2019  Qantas Airways.
======================================================
Req: 
Test account details returned to the flow screen
======================================================
Purpose:                                                            
Test class for QP_AccountFlowControllerForFlow
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 	Anil Nair       27/08/2019      Initial Development
========================================================
Methods
1. testGetAccountRecord() - performs data insert and call the insertRecords method to insert special condition records

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
***********************************************************************/
@isTest
public class QP_AccountFlowControllerTest {
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    public static testMethod void testGetAccountRecord() {
        Account a = new Account();
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        a.Name = 'Test Account';
        a.Active__c = true;
        a.BillingCountry = 'AU';
        a.Type = 'Agency Account';
        insert a;
        Account a1 = new Account();
        a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        a1.Name = 'Test Account 1';
        a1.Active__c = true;
        a1.BillingCountry = 'AU';
        a1.Type = 'Agency Account';
        a1.ParentId = a.Id;
        insert a1;
        QP_AccountFlowController obj = QP_AccountFlowController.getAccountRecord(a.Id);
        System.assertEquals(Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId(), obj.ctrtRTId);
        System.assertEquals('AU', obj.accountAddress.trim());
        System.assertEquals(false, obj.activeChannelContract);
        System.assertEquals(a.Name, obj.existingAccount.Name);
    }
}