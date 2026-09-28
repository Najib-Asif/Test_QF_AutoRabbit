/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method. Formatted code
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class QL_ApexClassToPassAccountOwnersListTest 
{
    @TestSetup static void setupData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
    }
    
    @istest
    public static void createAccountsTest()
    {
        ID accountTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        User getUser=[select id,name,title,firstname,lastname,userrole.name from user where userrole.name like '%R&G%' limit 1];
        List<Account> createAccounts=new List<Account>();
        List<QL_QuipScheduledJob__c> listScheduledJobs=new List<QL_QuipScheduledJob__c>();
        List<Id> getAcctIds=new List<Id>();
        set<Id> getSetIds=new set<Id>();
        String batchNamePdf='QL_batchClassToInvokeQuipFlowPDF'+system.now();
        String batchNameRef='QL_batchClassToInvokeREFRESHQUIPFlow'+system.now();
        datetime daytoday=system.now().addminutes(5);
        
        String day=String.valueof(daytoday.day());
        String month=String.valueof(daytoday.month()) ;
        String hour=String.valueof(daytoday.hour()) ;
        String year=String.valueof(daytoday.year()) ;
        String minute=String.valueof(daytoday.minute());
        
        String strSchedule= '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        List<Trigger_Status__c> lisTriggerStatus=new List<Trigger_Status__c>();
        
        Trigger_Status__c statusAccountEligibility=new Trigger_Status__c(name='AccountEligibilityLogTrigger',Active__c=true);          
        lisTriggerStatus.add(statusAccountEligibility);
        Trigger_Status__c AccountUpdateAccountDetail=new Trigger_Status__c(name='AccountUpdateAccountDetail',Active__c=true);
        lisTriggerStatus.add(AccountUpdateAccountDetail);
        Trigger_Status__c AccountTeam=new Trigger_Status__c(name='AccountTeam',Active__c=true);
        lisTriggerStatus.add(AccountTeam);
        Trigger_Status__c ACRPrimaryContact=new Trigger_Status__c(name='ACRPrimaryContact',Active__c=true);
        lisTriggerStatus.add(ACRPrimaryContact);
        Trigger_Status__c ContentDocLinkTriggerCheck=new Trigger_Status__c(name='ContentDocLinkTriggerCheck',Active__c=true);
        lisTriggerStatus.add(ContentDocLinkTriggerCheck);
        
        for(integer i=0;i<=210;i++)
        {
            Account acct=new Account(Contract_Commencement_Date__c=system.today().adddays(-90),recordtypeid=accountTypeId,name='Account '+i,Contracted__c=true,legal_name__c='Account '+i,Latest_Period_Date__c='May 2023',Active__c=true,ownerid=getUser.id,Quip__c='https://qantasairwaysptyltd.quip.com/0bZHAWaLGFH1');
            createAccounts.add(acct);
            
        }
        
        test.startTest();
        insert createAccounts;
        if(lisTriggerStatus.size()>0)
        {
            insert lisTriggerStatus;
        }
        for(Account getAcct: createAccounts)
        {
            getAcctIds.add(getAcct.id);
            QL_QuipScheduledJob__c statusRec=new QL_QuipScheduledJob__c(QL_Account_Id__c=getAcct.id,QL_Job_Name__c=batchNamePdf,QL_Account_Name__c=getAcct.legal_name__c,Account_Owner__c=getAcct.owner.name);
            listScheduledJobs.add(statusRec);
        } 
        getSetIds.addall(getAcctIds);
        insert listScheduledJobs;
        
        QL_ApexClassToPassAccountOwnersList.invokeQuipFlow();
        QL_ApexClassToPassAccountOwnersList.createCronExpression(day, month, hour, minute, year);
        QL_ApexClassToPassAccountOwnersList.invokeQuipPDFFlow(getAcctIds, listScheduledJobs, batchNamePdf);
        QL_ApexClassToPassAccountOwnersList.decideForApexCall(getSetIds, listScheduledJobs , batchNameRef);
        
        test.stopTest();
    }
}