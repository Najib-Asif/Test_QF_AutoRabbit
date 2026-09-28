/*Test Class for QL_BatchToSendQUIPEmailComms*/
@isTest
public with sharing class QL_BatchToSendQUIPEmailCommsTest 
{
    
    public testmethod static void main()
    {
        try
        {
            ID QantasSalesAcct=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        ID QantasSalesCont=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId(); 
        User getUser=[select id,name,userrole.name from user where userrole.name like :'%R&G%' limit 1];
        List<Id> getAcctIds=new List<Id>();
        List<QL_QuipScheduledJob__c> listScheduledJobs=new List<QL_QuipScheduledJob__c>();
        String batchName='QL_BatchToSendQUIPEmailComms'+system.now();
        
        test.startTest();
        
       // List<Id> acctIds=new List<Id>();
        Trigger_Status__c valCust=new Trigger_Status__c(name='ContentDocLinkTriggerCheck',Active__c=true);
        insert valCust;

        AutomationSettingsForQuiFlow__c settings = new AutomationSettingsForQuiFlow__c(SetupOwnerId=UserInfo.getUserId(), SkipFlow__c= true);
        insert settings;
        
        Account acct=new Account(recordtypeid=QantasSalesAcct,Latest_Period_Date__c='22 May',name='Test Account for QUIP1',legal_name__c='Test Account for QUIP1',active__c=true,Contracted__c=true,ownerid=getUser.id);
        insert acct;
        
        
        contact cont=new contact(recordtypeid=QantasSalesCont,accountid=acct.id,firstname='Donna',lastname='Hill',email='donna.hill@qantas.com.au');
        insert cont;  
        
        
        AccountContactRelation acr=[select id,Related_Email__c,accountid,AQ_First_Name__c,contactid from accountcontactrelation where accountid=:acct.id limit 1];
        acr.Related_Email__c='donna.hill@qantas.com.au';
        acr.AQ_First_Name__c='Donna';
        acr.Performance_Update__c='Subscribed';
        update acr;
        
        getAcctIds.add(acct.id);
        ContentVersion contV=new ContentVersion(title='Monthly Performance - '+acct.Latest_Period_Date__c,PathOnClient='Monthly Performance - '+acct.Latest_Period_Date__c+'.pdf',VersionData=Blob.valueOf('Test Content'),IsMajorVersion=true);
        insert contV;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contV.Id].ContentDocumentId;
        
        ContentDocumentLink contLink=new ContentDocumentLink(LinkedEntityId=acct.id,ContentDocumentId=conDocId,shareType='V');
        insert contLink;
        
        QL_QuipScheduledJob__c statusRec=new QL_QuipScheduledJob__c(QL_Account_Id__c=acct.id,QL_Job_Name__c=batchName,QL_Account_Name__c=acct.legal_name__c,Account_Owner__c=acct.owner.name);
        listScheduledJobs.add(statusRec);
        
        
        database.executeBatch(new QL_BatchToSendQUIPEmailComms(getAcctIds,listScheduledJobs),200);
        
        test.stopTest();
        
        }    
        
        catch(exception e)
        {
            system.debug('Exception has occurred'+e.getmessage());
        }
        
    }
}