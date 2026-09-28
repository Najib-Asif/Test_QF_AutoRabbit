/*
Description-> This Apex helper schedules the batches that removes the QUIP and PDF documents wherever Quip already exists.
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/
public with sharing class QL_ApexToRemoveQuipDocument 
{
     public class FlowInputs{
        @InvocableVariable
        public List<ID> getAccountIds;
        
        @InvocableVariable
        public String currentBatchNameRandom;
        
        @InvocableVariable
        public Id quipBatchJobId;
        
      
      }
      
    @invocablemethod(label='QL Pass Accounts to Remove Quip')
    public static void removeQuipDocuments(List<FlowInputs> getrequest)
    {
        try
        {
       
         set<id> getSetAcctIds=new set<id>();
            String day;
            String month;
            String hour;
            String year;
            String minute;
           
           
            
            if(getrequest[0].getAccountIds!=null && getrequest[0].getAccountIds.size()>0)
            {
                getSetAcctIds.addall(getrequest[0].getAccountIds);
                 
                 String batchName='QL_batchClassToRemoveQuipDocs'+getrequest[0].currentBatchNameRandom; 
           
                   datetime gettime=system.now().addminutes(1);
               
                   day=string.valueOf(gettime.day());
                   month=string.valueOf(gettime.month());
                   hour=string.valueOf(gettime.hour());
                   year=string.valueOf(gettime.year());
                   minute=String.valueof(gettime.addminutes(1).minute());
           
               
               system.debug('>>> value of getSetAcctIds'+getSetAcctIds);
               
               String strSchedule= QL_ApexClassToPassAccountOwnersList.createCronExpression(day,month,hour,minute,year);
               System.schedule(batchName, strSchedule, new QL_batchClassToRemoveQuipDocs(getSetAcctIds,getrequest[0].currentBatchNameRandom));
               
           
        }
        
            
       }
        catch(Exception e)
        {
            system.debug('>>Exception Occurred in QL_ApexToRemoveQuipDocument'+e.getMessage());
        }
    }
}