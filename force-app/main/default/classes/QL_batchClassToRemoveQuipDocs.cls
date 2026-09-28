/*
Description-> This batch will query the contentdocuments for the passed account ids and invoke flow Ql_QuipDocumentsRemovalFromFolder that deletes any Quip documents and PDF from QUIP and Salesforce. 
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/

global with sharing class QL_batchClassToRemoveQuipDocs implements Database.Batchable<sObject>,Schedulable,database.stateful {
          
    set<ID> setAccountIds=new set<ID>();
    List<ID> listAccountIds=new List<ID>();
    Id localAcctOwnerid;
    Integer localUpperLimit;
    List<QL_QuipScheduledJob__c> localBatchStatus;
    String getRandomBatchName;
    global QL_batchClassToRemoveQuipDocs()
    {
        
    }   
    global QL_batchClassToRemoveQuipDocs(set<Id> getAcctIds)
    {
        this.setAccountIds=getAcctIds;
    }  
    global QL_batchClassToRemoveQuipDocs(set<Id> getAcctIds,String randomBatchName)
    {
        this.setAccountIds=getAcctIds;
        getRandomBatchName=randomBatchName;
        this.listAccountIds.addall(getAcctIds);
        //this.localBatchStatus.addall(getBatchStatus);
    }   
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       String query;
       String accountOwnerRole='%R&G%';
       ID accountId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); 
       query='select id,ContentDocumentID,ContentDocument.title,ContentDocument.filetype, LinkedEntity.type, LinkedEntityId from contentdocumentlink where LinkedEntityId IN :setAccountIds';
           
        return Database.getQueryLocator(query); 
    }
     global void execute(Database.BatchableContext bc, List<contentdocumentlink> scope) 
     {
         try
         {
             List<Account> getAccountsForQuipRemoval=new List<Account>(); 
             List<id> getContentDocumentIds=new List<id>();
             List<Id> linkedEntityIds=new List<Id>();
             system.debug('Scope size'+scope.size());
            
             if(scope!=null && scope.size()>0)
             {
                 for(ContentDocumentLink getContLink:scope)
                    {
                        
                        if(getContLink.ContentDocumentID!=null && 
                        (getContLink.ContentDocument.filetype.contains('QUIPDOC') || (getContLink.ContentDocument.filetype.containsignorecase('PDF') && getContLink.ContentDocument.title.containsIgnorecase('Monthly Performance'))))
                        {
                            system.debug('>>> inside the content doc assignment');
                           getContentDocumentIds.add(getContLink.ContentDocumentID);
                           linkedEntityIds.add(getContLink.linkedentityid);
                        }
                    }
              }
             if(setAccountIds!=null && setAccountIds.size()>0)
                {
                    getAccountsForQuipRemoval=[select id,quip__c from Account where id in: linkedEntityIds];
                }
       
        
        if(getContentDocumentIds!=null && getContentDocumentIds.size()>0)
        {
            List<Database.DeleteResult> getDMLresults= database.delete(getContentDocumentIds,false);
            if(getDMLresults!=null && getDMLresults.size()>0)
            {
                for(Database.DeleteResult getRes:getDMLresults)
                {
                    if(!getRes.isSuccess())
                    {
                        system.debug('>>> Content Docs Deletion Error'+getRes.geterrors());
                    }
                }
            }
        }
         
        if(getAccountsForQuipRemoval!=null && getAccountsForQuipRemoval.size()>0)
            {
                 Map<String, Object> params = new Map<String, Object>();
                 params.put('getListAccounts', getAccountsForQuipRemoval);
        
                 Flow.Interview.Ql_QuipDocumentsRemovalFromFolder QuipRecordFlow = new Flow.Interview.Ql_QuipDocumentsRemovalFromFolder(params);
                 QuipRecordFlow.start();
            }
        
         }
         catch(exception e)
         {
             system.debug('Exception Occurred'+e.getmessage());
         }
     }
     global void finish(Database.BatchableContext bc) 
     {
        system.debug('>>>localAcctOwnerid in QL_batchClassToRemoveQuipDocs'+localAcctOwnerid);
        system.debug('>>>localUpperLimitin QL_batchClassToRemoveQuipDocs'+localUpperLimit);
       
         system.debug('>>> received batch status records'+localBatchStatus); 
         List<QL_QuipScheduledJob__c> getStatus=new List<QL_QuipScheduledJob__c>();
         getStatus=[select id,Account_Owner__c,Batch_Status__c,Name,QL_Account_Id__c,QL_Account_Name__c,QL_ACR_Subscribed_Count__c,QL_Job_Completed_Date__c,QL_Next_Job_Name__c,QL_Job_Name__c,QL_Job_Scheduled_Date_Time__c from QL_QuipScheduledJob__c where QL_Account_Id__c IN :setAccountIds and createddate=today limit 60];   
        system.debug('>>> getStatus results'+getStatus);
        //Completed Batch Job
         QL_QuipBatchesStatusUpdator.updateStatusRecord(listAccountIds,bc.getjobid());
        
         QL_ApexClassToPassAccountOwnersList.decideForApexCall(setAccountIds,getStatus,getRandomBatchName);
        
    }
    global void execute(SchedulableContext sc)
     {
        database.executeBatch(new QL_batchClassToRemoveQuipDocs(setAccountIds,getRandomBatchName),200);
     }
   
    
 }