/*
Created Date: October 2023
Description: Test Class for quipTriggerHelper
Developer: Navpreet Kaur
CRM-7300

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
*/
@isTest
public with sharing class quipTriggerHelperTest 
{
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest
    static void testAccountEligibilityForQuipChange()
    {
        List<QL_QuipScheduledJob__c> createQuips=new List<QL_QuipScheduledJob__c>();
        List<QL_QuipScheduledJob__c> updateQuips=new List<QL_QuipScheduledJob__c>();
        ID accountTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        List<Id> quipIds=new List<Id>();
        test.starttest();
        Account acct=new Account(recordtypeid=accountTypeId,name='Account Test',Contracted__c=true,legal_name__c='Account Test',Latest_Period_Date__c='May 2023',Active__c=true);
        insert acct;
        
        QL_QuipScheduledJob__c getRec=new QL_QuipScheduledJob__c(QL_Job_Name__c='',QL_Next_Job_Name__c='',QL_Account_Id__c=acct.id);
        QL_QuipScheduledJob__c getRec1=new QL_QuipScheduledJob__c(QL_Job_Name__c='Batch To Export As PDFs',QL_Next_Job_Name__c='Batch to Send Emails Comms',QL_Account_Id__c=acct.id);
        createQuips.add(getRec);
        createQuips.add(getRec1);
        
        insert createQuips;
        
        List<QL_QuipScheduledJob__c> fetchQuip=[select id,QL_Job_Name__c,QL_Next_Job_Name__c from QL_QuipScheduledJob__c where id=:createQuips[0].id] ;
        fetchQuip[0].QL_Job_Name__c='Batch To Send Comms Aborted';
        updateQuips.add(fetchQuip[0]);
        update updateQuips;
        
        quipTriggerHelper.changeIneligibilityStatus(createQuips);
        quipTriggerHelper.changeIneligibilityStatus(updateQuips);
        
        test.stoptest();        
    }
}