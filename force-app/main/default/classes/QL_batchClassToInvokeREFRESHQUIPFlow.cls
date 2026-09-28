/*
Description-> This Batch is invoked to recreate the QUIP documents wherever they have been removed.
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/

global with sharing class QL_batchClassToInvokeREFRESHQUIPFlow implements Database.Batchable<sObject>,Schedulable,database.stateful {
     
    List<ID> localListAcctIds;
    List<Account> localListAccounts;
    List<Id> getAccountsoutput;
    Id getAcctOwnerId;
    Integer getAcctUpperLimit;
    List<QL_QuipScheduledJob__c> loaclgetStatus=new List<QL_QuipScheduledJob__c>();
    String randomBatchName;
    global QL_batchClassToInvokeREFRESHQUIPFlow()
    {
        
    }
    global QL_batchClassToInvokeREFRESHQUIPFlow(List<Id> getAcctIds)
    {
        this.localListAcctIds=getAcctIds;
        
    }
    global QL_batchClassToInvokeREFRESHQUIPFlow(List<Id> getAcctIds,List<QL_QuipScheduledJob__c> getBatchStatus,String getRandomBatchName)
    {
        this.localListAcctIds=getAcctIds;
        this.randomBatchName=getRandomBatchName;
        this.loaclgetStatus.addall(getBatchStatus);
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       String query;
       ID accountId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); 
       
       if(test.isrunningtest())
       {
           query='Select id,Account_Owner_Role__c,owner.name,name,Active__c,Quip__c,Contracted__c,Legal_Name__c,Latest_Period_Date__c,Estimated_Total_QF_Dom_Annual_Revenue__c,Estimated_Total_QF_Int_Annual_Revenue__c,QF_Domestic_Revenue__c,QF_International_Revenue__c,QF_Revenue__c,Contract_Start_Date__c,Contract_End_Date__c,Qantas_Annual_Expenditure__c,Domestic_Annual_Share__c,International_Annual_Share__c,Estimated_Total_Annual_Revenue__c,Estimated_QF_Dom_Market_Share__c,Estimated_Int_Market_Share__c,Contract_Commencement_Date__c from Account where recordtypeid=:accountId and ID IN:localListAcctIds and Active__c=true and Contracted__c=true and Contract_Commencement_Date__c<=LAST_N_MONTHS:2 order by createddate DESC limit 200';
       }
       else
       {
           query='Select id,Account_Owner_Role__c,owner.name,name,Active__c,Quip__c,Contracted__c,Legal_Name__c,Latest_Period_Date__c,Estimated_Total_QF_Dom_Annual_Revenue__c,Estimated_Total_QF_Int_Annual_Revenue__c,QF_Domestic_Revenue__c,QF_International_Revenue__c,QF_Revenue__c,Contract_Start_Date__c,Contract_End_Date__c,Qantas_Annual_Expenditure__c,Domestic_Annual_Share__c,International_Annual_Share__c,Estimated_Total_Annual_Revenue__c,Estimated_QF_Dom_Market_Share__c,Estimated_Int_Market_Share__c,Contract_Commencement_Date__c from Account where recordtypeid=:accountId and ID IN:localListAcctIds and Active__c=true and Contracted__c=true and Contract_Commencement_Date__c<=LAST_N_MONTHS:2 order by createddate DESC';
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
                     localListAccounts=new List<Account>(scope);
                     params.put('getListAccounts', scope);
                     Flow.Interview.QL_AutomateQuipDocuments QuipFlow = new Flow.Interview.QL_AutomateQuipDocuments(params);
                     QuipFlow.start();
                     getAccountsoutput=(List<Id>)(QuipFlow.getVariableValue('acctIdsListToClearDocs'));
                    
                     system.debug('>>> get Accounts output'+getAccountsoutput);
                     
            }
        
         }
         catch(exception e)
         {
             system.debug('Exception Occurred'+e.getmessage());
         }
     }
     global void finish(Database.BatchableContext bc) 
     {
          
          system.debug('>>> the value of getStatus'+loaclgetStatus);
          system.debug('>>> the value account flow output in QL_batchClassToInvokeREFRESHQUIPFlow'+ getAccountsoutput);
          
          
          //Update completed batch to updator
          QL_QuipBatchesStatusUpdator.updateStatusRecord(localListAcctIds,bc.getJobid());
          
          QL_ApexClassToPassAccountOwnersList.invokeQuipPDFFlow(localListAcctIds,loaclgetStatus,randomBatchName+bc.getJobid());  
          
          
     }
     global void execute(SchedulableContext sc)
     {
        database.executeBatch(new QL_batchClassToInvokeREFRESHQUIPFlow(localListAcctIds,loaclgetStatus,randomBatchName),200);
        
     }
    
 }