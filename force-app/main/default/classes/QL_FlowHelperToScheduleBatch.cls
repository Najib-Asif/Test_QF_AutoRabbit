/*
Desc: This class schedules the batch class(QL_BatchToSendQUIPEmailComms) to send email communications.
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/
global with sharing class QL_FlowHelperToScheduleBatch 
{

      public class FlowInputs{
        @InvocableVariable
        public List<ID> getAccountIds;
        
        @InvocableVariable
        public List<QL_QuipScheduledJob__c> getBatchStatus;
        
        
        @InvocableVariable
        public Id getPdfBatchjobid;
        
        @InvocableVariable
        public String randomBatchName;
        
        }
       
       
   
    @invocablemethod(label='QL Check Content Document Age')
    public static void decideForApexCall(List<FlowInputs> request)
    {
        try
        {
            
        
        List<QL_QuipScheduledJob__c> listInsertJobs=new List<QL_QuipScheduledJob__c>();
        String numDays=System.Label.QL_DaysGap;
        Integer intDays=Integer.valueof(numDays);
        ID acctOwnerId;
            
        Datetime minutenow=system.now();
        Datetime daynow=system.now().AddDays(intDays);
            
        String day = string.valueOf(daynow.day());
        String month = string.valueOf(daynow.month());
        String hour = string.valueOf(daynow.hour());
        String minute = string.valueOf(daynow.addminutes(5).minute());
        String year = string.valueOf(daynow.year());
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        
         system.debug('>>> Inside the decideForApexCall Emails Comms Scheduler');
        
        List<Account> getAccountsInfo=[select id,Legal_Name__c,owner.name,name,ownerid,(select id from AccountContactRelations where Performance_Update__c='Subscribed') from account where id in :request[0].getAccountIds];    
       
       
        system.debug('>>> the value of request[0].getAccountIds'+request[0].getAccountIds);
        system.debug('>>> the value of request[0].getBatchStatus'+request[0].getBatchStatus);        
        
        String batchName='QL_BatchToSendQUIPEmailComms'+request[0].randomBatchName;
        
       
        System.schedule(batchName, strSchedule, new QL_BatchToSendQUIPEmailComms(request[0].getAccountIds,request[0].getBatchStatus));  
        //Status update for Completed batch details on Scheduled jobs object(Batch PDFs)
        QL_QuipBatchesStatusUpdator.updateStatusRecord(request[0].getAccountIds,request[0].getPdfBatchjobid);
        
        //Status updated for Next Scheduled batch details on Scheduled jobs object(Batch Send Comms)
        QL_QuipBatchesStatusUpdator.updateBatchScheduleTime(request[0].getAccountIds,daynow,batchName);         
            
            
         
        }
        catch(Exception e)
        {
            System.debug('Exception occurred in QL_FlowHelperToScheduleBatch'+e.getMessage());
        }
    }
  
   
}