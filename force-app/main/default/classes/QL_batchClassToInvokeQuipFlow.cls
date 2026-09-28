/*
Description-> This batch passes the Accounts to Flow QL_AutomateQuipDocuments that creates the QUIP documents.
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/

global with sharing class QL_batchClassToInvokeQuipFlow implements Database.Batchable<sObject>,Schedulable,database.stateful {
     
    ID localAcctOwnId;
    Integer localAcctupperLimit;
    List<Id> listAccountIds=new List<Id>();
    //String batchName;
    List<Account> getListAccts=new List<Account>();
    List<Id> getAccountsoutput;
    List<Id> getAccountIdsWithQuip;
    String randomBatchName;
    global QL_batchClassToInvokeQuipFlow()
    {
        
    }
    global QL_batchClassToInvokeQuipFlow(List<Id> getlistAccountIds,String getrandomBatchName)
    {
        this.listAccountIds=getlistAccountIds;
        this.randomBatchName=getrandomBatchName;
    }
  
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       String query;
       String subs='Subscribed';
       ID accountId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); 
       if(Test.isRunningTest())
       {
           query='Select id,Account_Owner_Role__c,owner.name,name,Active__c,Quip__c,Contracted__c,Legal_Name__c,Latest_Period_Date__c,Estimated_Total_QF_Dom_Annual_Revenue__c,Estimated_Total_QF_Int_Annual_Revenue__c,QF_Domestic_Revenue__c,QF_International_Revenue__c,QF_Revenue__c,Contract_Start_Date__c,Contract_End_Date__c,Qantas_Annual_Expenditure__c,Domestic_Annual_Share__c,International_Annual_Share__c,Estimated_Total_Annual_Revenue__c,Estimated_QF_Dom_Market_Share__c,Estimated_Int_Market_Share__c,Contract_Commencement_Date__c,(select id from AccountContactRelations where Performance_Update__c=:subs) from Account where recordtypeid=:accountId and id IN:listAccountIds and Active__c=true and Contracted__c=true and Contract_Commencement_Date__c<=LAST_N_MONTHS:2 limit 200';
       }
       else
       {
          query='Select id,Account_Owner_Role__c,owner.name,name,Active__c,Quip__c,Contracted__c,Legal_Name__c,Latest_Period_Date__c,Estimated_Total_QF_Dom_Annual_Revenue__c,Estimated_Total_QF_Int_Annual_Revenue__c,QF_Domestic_Revenue__c,QF_International_Revenue__c,QF_Revenue__c,Contract_Start_Date__c,Contract_End_Date__c,Qantas_Annual_Expenditure__c,Domestic_Annual_Share__c,International_Annual_Share__c,Estimated_Total_Annual_Revenue__c,Estimated_QF_Dom_Market_Share__c,Estimated_Int_Market_Share__c,Contract_Commencement_Date__c,(select id from AccountContactRelations where Performance_Update__c=:subs) from Account where recordtypeid=:accountId and id IN:listAccountIds and Active__c=true and Contracted__c=true and Contract_Commencement_Date__c<=LAST_N_MONTHS:2';
       }
       
       return Database.getQueryLocator(query); 
    }
     global void execute(Database.BatchableContext bc, List<Account> scope) 
     {
         try
         {
            Map<String, Object> params = new Map<String, Object>(); 
            system.debug('Scope size'+scope.size());
            if(scope!=null && scope.size()>0)
            {
                     getListAccts.addall(scope);
                     params.put('getListAccounts', scope);
                     params.put('quipBatchJobId', bc.getjobid());
                     params.put('RandombatchName',randomBatchName);
                     Flow.Interview.QL_AutomateQuipDocuments QuipFlow = new Flow.Interview.QL_AutomateQuipDocuments(params);
                     QuipFlow.start();
                     getAccountsoutput=(List<Id>)QuipFlow.getVariableValue('acctIdsListToClearDocs'); 
                     getAccountIdsWithQuip=(List<Id>)QuipFlow.getVariableValue('accountIdsWithQuip');
                 
                 
            }
        
         }
         catch(exception e)
         {
             system.debug('Exception Occurred'+e.getmessage());
         }
     }
     global void finish(Database.BatchableContext bc) 
     {
        List<QL_QuipScheduledJob__c> getStatus=QL_QuipBatchesStatusUpdator.createStatusRecord(getListAccts,bc.getJobId());
        system.debug('The value of getbatchStatus'+getStatus);
        system.debug('>>> get Accounts output finish method'+getAccountsoutput);
        system.debug('The value of getStatus size'+getStatus.size());
        
        if(getStatus!=null && getStatus.size()>0 && getAccountIdsWithQuip!=null && getAccountIdsWithQuip.size()>0)
        {
            QL_ApexClassToPassAccountOwnersList.invokeQuipPDFFlow(getAccountIdsWithQuip,getStatus,randomBatchName);      
        }
        
        
     }
     global void execute(SchedulableContext sc)
     {
        database.executeBatch(new QL_batchClassToInvokeQuipFlow(listAccountIds,randomBatchName),200);
     }
      
    
 }