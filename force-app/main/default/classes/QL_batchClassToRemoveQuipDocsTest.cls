/*
Description-> test class for QL_batchClassToRemoveQuipDocs
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
CRM-6830

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
*/

@isTest
public with sharing class QL_batchClassToRemoveQuipDocsTest 
{
    @TestSetup static void setupData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
    }
    
    @istest
    public static void createAccounts()
    {
        ID accountId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        User getUser=[select id from user where userrole.name like '%R&G%' limit 1];
        List<Trigger_Status__c> triggerStatus=new List<Trigger_Status__c>();
        
        List<Account> createAccounts=new List<Account>();
        set<Id> acctId=new set<id>();
        
        Trigger_Status__c getStatusContentdocLink=new Trigger_Status__c(name='ContentDocLinkTriggerCheck',Active__c=false);
        triggerStatus.add(getStatusContentdocLink);
        Trigger_Status__c getStatusContentdel=new Trigger_Status__c(name='ContDocTriggerEligiblityCheckContDel',Active__c=false);
        triggerStatus.add(getStatusContentdel);
        Trigger_Status__c getAccountTriggerStatus=new Trigger_Status__c(name='AccountUpdateAccountDetail',Active__c=false);
        triggerStatus.add(getAccountTriggerStatus);
        
        if(triggerStatus!=null && triggerStatus.size()>0)
        {
            insert triggerStatus;
        }
        
        Account acct=new Account(recordtypeid=accountId,name='Account ABC',Active__c=true,ownerid=getUser.id,Quip__c='http://someurl.quip.com/jhjwhd78',contracted__c=true);
        createAccounts.add(acct);
        
        test.startTest();
        insert createAccounts;
        
        ContentVersion version = new ContentVersion(
            Title='Monthly Performance - Account ABC',
            PathOnClient='Monthly Performance - Account ABC.pdf',
            VersionData=EncodingUtil.base64Decode('AA=='),
            Origin='H');
        insert version;
        
        version = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];
        
        ContentDocumentLink cdl=new ContentDocumentLink();
        cdl.LinkedEntityId=createAccounts[0].id;
        cdl.contentdocumentid=version.ContentDocumentId ;
        Insert cdl;
        
        acctId.add(createAccounts[0].id);
        database.executeBatch(new QL_batchClassToRemoveQuipDocs(acctId),200);
        test.stopTest();
    }
}