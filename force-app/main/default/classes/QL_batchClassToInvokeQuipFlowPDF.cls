/*
Description-> This batch class invokes the flow QL_AutomateQuipPDFs  that creates the PDF versions of the QUIP documents.
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/
global with sharing class QL_batchClassToInvokeQuipFlowPDF implements Database.Batchable<sObject>,Schedulable,database.stateful {
     
    ID localAcctOwnId;
    Integer localAcctupperLimit=0;
    List<QL_QuipScheduledJob__c> BatchStatus=new List<QL_QuipScheduledJob__c>();
    List<ID> localAcctIds;
    String randomBatchName;
    global QL_batchClassToInvokeQuipFlowPDF()
    {
        
    }
    global QL_batchClassToInvokeQuipFlowPDF(List<Id> getAcctIds)
    {
        this.localAcctIds=getAcctIds;   
        
    }
    global QL_batchClassToInvokeQuipFlowPDF(List<Id> getAcctIds,List<QL_QuipScheduledJob__c> getBatchStatus,String getRandomBatchName)
    {
        system.debug('>>> the value of getBatchStatus'+getBatchStatus);
        this.localAcctIds=getAcctIds; 
        this.BatchStatus.addall(getBatchStatus);
        this.randomBatchName=getRandomBatchName;
        system.debug('>>> the value of BatchStatus'+BatchStatus);
    }
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       String query;
       ID accountId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
       if(Test.isRunningTest())
       {
           query='Select id,quip__c,Legal_Name__c,name,ownerid,owner.name,owner.title,owner.firstname,owner.lastname,Active__c,Latest_Period_Date__c,Contracted__c,Account_Owner_Role__c from account where recordtypeid=:accountId and ID IN:localAcctIds and quip__c!=null order by createddate desc limit 200';
       }
       else
       {
           query='Select id,quip__c,Legal_Name__c,name,ownerid,owner.name,owner.title,owner.firstname,owner.lastname,Active__c,Latest_Period_Date__c,Contracted__c,Account_Owner_Role__c from account where recordtypeid=:accountId and ID IN:localAcctIds and quip__c!=null order by createddate desc';
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
                 
                         params.put('getListAccounts', scope);
                         params.put('ListBatchStatus', BatchStatus);
                         params.put('PdfbatchJobId', bc.getJobid());
                         params.put('randomBatchName',randomBatchName);
                         Flow.Interview.QL_AutomateQuipPDFs QuipFlowPDF = new Flow.Interview.QL_AutomateQuipPDFs(params);
                         QuipFlowPDF.start();
                 
            }
        
         }
         catch(exception e)
         {
             system.debug('Exception Occurred'+e.getmessage());
         }
     }
     global void finish(Database.BatchableContext bc) 
     {
     }
    global void execute(SchedulableContext sc)
    {
       database.executeBatch(new QL_batchClassToInvokeQuipFlowPDF(localAcctIds,BatchStatus,randomBatchName),200);
    }  
 }