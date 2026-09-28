/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class QL_batchClassToInvokeREFRESHQUIPFlowTest 
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
        String batchName='QL_batchClassToInvokeQuipFlow'+system.now();
        datetime daytoday=system.now().addminutes(5);
        
        String day=String.valueof(daytoday.day());
        String month=String.valueof(daytoday.month()) ;
        String hour=String.valueof(daytoday.hour()) ;
        String year=String.valueof(daytoday.year()) ;
        String minute=String.valueof(daytoday.minute());
        
        String strSchedule= '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        
        for(integer i=0;i<=10;i++)
        {
            Account acct=new Account(Contract_Commencement_Date__c=system.today().adddays(-90),recordtypeid=accountTypeId,name='Account '+i,Contracted__c=true,legal_name__c='Account '+i,Latest_Period_Date__c='May 2023',Active__c=true,ownerid=getUser.id);
            createAccounts.add(acct);
        }
        
        test.startTest();
        insert createAccounts;
        for(Account getAcct: createAccounts)
        {
            getAcctIds.add(getAcct.id);
            QL_QuipScheduledJob__c statusRec=new QL_QuipScheduledJob__c(QL_Account_Id__c=getAcct.id,QL_Job_Name__c=batchName,QL_Account_Name__c=getAcct.legal_name__c,Account_Owner__c=getAcct.owner.name);
            listScheduledJobs.add(statusRec);
        } 
        insert listScheduledJobs;
        new QL_batchClassToInvokeREFRESHQUIPFlow();
        new QL_batchClassToInvokeREFRESHQUIPFlow(getAcctIds);
        
        System.schedule('batchName', '0 0 0 3 9 ? 2042', new QL_batchClassToInvokeREFRESHQUIPFlow(getAcctIds,listScheduledJobs,batchName)); 
        
        database.executeBatch(new QL_batchClassToInvokeREFRESHQUIPFlow(getAcctIds,listScheduledJobs,batchName));
        test.stopTest();
    }
}