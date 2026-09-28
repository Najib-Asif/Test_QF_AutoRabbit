/*
Author: Navpreet Kaur
Class Description: Apex controller that creates and updates the QUIP Scheduled Jobs status.
Date: AUG 2023
EPIC CRM-5831
 */
public with sharing class QL_QuipBatchesStatusUpdator 
{
    public static String batchName;
    public static datetime dateCompleted;
    public static List<QL_QuipScheduledJob__c> listInsertJobs;
    
    //Method that creates the scheduled job record to track batch status progress
    public static List<QL_QuipScheduledJob__c> createStatusRecord(List<Account> getListAccounts,Id getBatchId)
    {
        
        listInsertJobs=new list<QL_QuipScheduledJob__c>();
        AsyncApexJob asyClass = [Select Id, Status,CompletedDate,ApexClass.name, CreatedBy.Email from AsyncApexJob where Id = :getBatchId];
        batchName=asyClass.ApexClass.name;
        
        
        
        system.debug('>>> the value of batchName'+batchName);
        dateCompleted=asyClass.CompletedDate;
        system.debug('>>> the value of dateCompleted'+dateCompleted);
        
        If(getListAccounts!=null && getListAccounts.size()>0)   
                {
                    for(Account acct: getListAccounts)
                    {
                        QL_QuipScheduledJob__c createQuip=new QL_QuipScheduledJob__c();
                        createQuip.QL_Account_Id__c=acct.id;
                        createQuip.QL_Job_Name__c=getUserFriendlyBatchname(batchName);
                        createQuip.QL_Job_Completed_Date__c=dateCompleted;
                        createQuip.QL_Account_Name__c=acct.Legal_Name__c;   
                        createQuip.Account_Owner__c=acct.owner.name;
                        createQuip.Batch_Status__c=asyClass.Status;
                        createQuip.QL_ACR_Subscribed_Count__c=acct.AccountContactRelations.size();
                        
                        listInsertJobs.add(createQuip);    
                    }
                    database.SaveResult[] results=database.insert(listInsertJobs,false);
                    system.debug('>>> the database. save results'+results);
                }    
        return listInsertJobs;    
    }
    //Method that updates the completed scheduled jobs status
    public static List<QL_QuipScheduledJob__c> updateStatusRecord(List<Id> getAccountIds,Id getBatchId)
    {
        List<QL_QuipScheduledJob__c> getScheduledJobs=[select id,QL_Job_Completed_Date__c,QL_Job_Name__c,QL_Job_Scheduled_Date_Time__c,QL_Next_Job_Name__c,Batch_Status__c from QL_QuipScheduledJob__c where QL_Account_Id__c IN: getAccountIds];
        system.debug('>>> received batch job id'+getBatchId);
        listInsertJobs=new list<QL_QuipScheduledJob__c>();
        AsyncApexJob[] asyClass = [Select Id, Status,CompletedDate,ApexClass.name, CreatedBy.Email from AsyncApexJob where Id = :getBatchId];
        batchName=asyClass[0].apexClass.name;
        dateCompleted=   asyClass[0].CompletedDate; 
       
        system.debug('>>> the query results'+asyClass );
        system.debug('>>> batchName '+batchName);
        if(getScheduledJobs.size()>0)
        {
            for(QL_QuipScheduledJob__c getJobs:getScheduledJobs)
            {
                getJobs.Batch_Status__c=asyClass[0].Status;
                getJobs.QL_Job_Completed_Date__c=dateCompleted;
                getJobs.QL_Job_Name__c=getUserFriendlyBatchname(batchName);
                system.debug('the value of each quip scheduled job'+getJobs);
                listInsertJobs.add(getJobs);
            }
            
            if(listInsertJobs.size()>0)
            {
                database.SaveResult[] results=database.update(listInsertJobs,false);
                system.debug('>>> the database. save results for update'+results);
            }
        }
        return listInsertJobs;    
    }
    //Method that updates the next job scheduled date
    public static Boolean updateBatchScheduleTime(List<Id> getAccountIds,datetime getScheduleTime,String batchname)
    {
        List<QL_QuipScheduledJob__c> getScheduledJobs=[select id,QL_Job_Scheduled_Date_Time__c,QL_Next_Job_Name__c,Batch_Status__c from QL_QuipScheduledJob__c where QL_Account_Id__c IN: getAccountIds];
        listInsertJobs=new list<QL_QuipScheduledJob__c>();
        system.debug('>>> received batch name in upadtor'+batchname);
        if(getScheduledJobs.size()>0)
        {
            for(QL_QuipScheduledJob__c getJob:getScheduledJobs)
            {
                if(batchname==null && getScheduleTime==null)
                {
                    getJob.QL_Job_Scheduled_Date_Time__c=null;
                    getJob.QL_Next_Job_Name__c='None';
                    getJob.Batch_Status__c='Completed';
                }
                else
                {
                    getJob.QL_Job_Scheduled_Date_Time__c=getScheduleTime;
                    getJob.QL_Next_Job_Name__c=getUserFriendlyBatchname(batchName);
                }
                system.debug('>>> the job record fields'+getJob);
                listInsertJobs.add(getJob);
            }
            if(listInsertJobs.size()>0)
            {
               database.SaveResult[] results =database.update(listInsertJobs,false);
               system.debug('>>> the database save results for update schedule time'+results);
            }
        }
        return true;
    }
    //Method that forms User friendly batch name
    public static string getUserFriendlyBatchname(String batchname)
    {
        String finalBatchName;
        system.debug('>>> the value of batchname in getUserFriendlyBatchname '+batchname);
        if(batchName.contains('QL_batchClassToInvokeQuipFlowPDF'))
        {
            finalBatchName='Batch To Export As PDFs';
        }
        else if(batchName.contains('QL_batchClassToInvokeQuipFlow'))
        {
            finalBatchName='Batch to Create QUIPs';
        }
        else if(batchName.contains('QL_FlowHelperToScheduleBatch') || batchName.contains('QL_BatchToSendQUIPEmailComms'))
        {
            finalBatchName='Batch to Send Emails Comms';
        }
        else if(batchName.contains('QL_batchClassToInvokeREFRESHQUIPFlow'))
        {
            finalBatchName='Batch to Refresh QUIPs';
        }
        else if(batchName.contains('QL_batchClassToRemoveQuipDocs'))
        {
            finalBatchName='Batch to Remove QUIP Docs';
        }
        return finalBatchName;
    }
}