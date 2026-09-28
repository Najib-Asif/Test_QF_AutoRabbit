/*
Description-> This Apex helper has functions to schedule the batches for QUIP Automation.
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/
public with sharing class QL_ApexClassToPassAccountOwnersList   
{
    
     static List<Id> getAcctListForQuipRecreation=new List<Id>();
     static Integer upperLimitForQuipRecreation=0;
     static Id ownerIDForQuipRecreation;
     Static double batchsizeVariable=30.0;
     
    public static void invokeQuipFlow()
    {
       String accountOwnerRole='%R&G%';
       List<ID> getAcctManagersIDs=new List<ID>(); 
       List<Account> getQualifiedAccounts=new List<Account>();
       List<Id> getQualifiedAccountIds=new List<Id>();
       ID accountTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); 
       Decimal calculateBatches;
       Integer batchSize;
       
       Integer minutesCounter=2;
       Map<Integer,List<Id>> mapAccounts=new Map<Integer,List<Id>>();
       List<Id> createAcctList=new List<Id>();
       List<Id> tempHolder;
       Integer count=1;
       String day ;
       String month ;
       String hour ;
       String year ;
       String minute; 
       
       getQualifiedAccounts=[select id,ownerid from account where recordtypeid=:accountTypeId and Account_Owner_Role__c like :accountOwnerRole and Active__c =true and Contracted__c =true and Contract_Commencement_Date__c<=LAST_N_MONTHS:2];
       Map<Id,Integer> mapOwnerAcctCounts=new Map<Id,Integer>(); 
       
        
       if(getQualifiedAccounts!=null && getQualifiedAccounts.size()>0)
       {
          
           calculateBatches=getQualifiedAccounts.size()/batchsizeVariable;
           batchSize=(Integer)calculateBatches.round(system.RoundingMode.CEILING);
           
            for(integer j=0;j<getQualifiedAccounts.size();j++)
            {
                   system.debug('>>> the value of getQualifiedAccounts[j]'+getQualifiedAccounts[j]);
                   
                   createAcctList.add(getQualifiedAccounts[j].id);
                   system.debug('>>> the value of createAcctList'+createAcctList);
                   if((createAcctList.size()==(integer)batchsizeVariable) || (j==(getQualifiedAccounts.size()-1) && createAcctList.size()<=(integer)batchsizeVariable))
                   {
                       tempHolder=new List<Id>(); 
                       tempHolder.addall(createAcctList);
                        mapAccounts.put(count,tempHolder);
                        count++;
                        createAcctList.clear();
                   } 
                
            }
           for(integer i=0;i<batchSize;i++)
           {
               Integer RandomInt=Math.abs(Crypto.getRandomInteger());
               String passableBatchName=String.valueof(RandomInt)+system.now()+' '+i;
               String batchName='QL_batchClassToInvokeQuipFlow';
               batchName=batchName+passableBatchName;
               datetime gettime=system.now().addminutes(minutesCounter);
               day=string.valueOf(gettime.day());
               month=string.valueOf(gettime.month());
               hour=string.valueOf(gettime.hour());
               year=string.valueOf(gettime.year());
               minute=String.valueof(gettime.minute());
               
               String strSchedule= createCronExpression(day,month,hour,minute,year);
               if(!test.isRunningTest())
               {
                   System.schedule(batchName, strSchedule, new QL_batchClassToInvokeQuipFlow(mapAccounts.get(i+1),passableBatchName));  
               }
               
               if(i==(batchSize-1))
               {
                   datetime gettimenow=gettime.addminutes(120);
                   String daynow=string.valueOf(gettimenow.day());
                   string monthnow=string.valueOf(gettimenow.month());
                   string hournow=string.valueOf(gettimenow.hour());
                   string yearnow=string.valueOf(gettimenow.year());
                   string minutenow=String.valueof(gettimenow.minute());
                   
                   String Schedule= createCronExpression(daynow,monthnow,hournow,minutenow,yearnow);
                   
                   System.schedule('QL_RestoreTheTriggerStatus'+RandomInt, Schedule, new QL_RestoreTheTriggerStatus());
               }
               minutesCounter+=20;
           }
           
          
       }
       
    }
     
    public static void invokeQuipPDFFlow(List<Id> getAccountIds,List<QL_QuipScheduledJob__c> getBatchStatus,String getBatchName)
    {
        string batchNamePdf='QL_batchClassToInvokeQuipFlowPDF'+getBatchName;
        String day ;
        String month ;
        String hour ;
        String year ;
        String minute; 
        
        datetime timeanow=system.now().addminutes(65);
        day=string.valueOf(timeanow.day());
        month=string.valueOf(timeanow.month());
        hour=string.valueOf(timeanow.hour());
        year= string.valueOf(timeanow.year());
        minute= string.valueOf(timeanow.minute());
        String strSchedule;
        
       
        system.debug('>>> the value of getBatchStatus'+getBatchStatus);
       
        strSchedule=createCronExpression(day,month,hour,minute,year);
        if(!test.isRunningTest())
        {
            System.schedule(batchNamePdf, strSchedule, new QL_batchClassToInvokeQuipFlowPDF(getAccountIds,getBatchStatus,getBatchName));   
        }
        
        
        //Next batch scheduled infor updated on QL scheduled jobs object
        QL_QuipBatchesStatusUpdator.updateBatchScheduleTime(getAccountIds,timeanow,batchNamePdf);

        
    }
  
    
    public static void decideForApexCall(set<ID> getAccountIds,List<QL_QuipScheduledJob__c> getBatchStatus,String getRandomBatchName)
    {
        List<Id> passAcctIds=new List<Id>();
        String day ;
        String month ;
        String hour ;
        String year ;
        String minute; 
     
        system.debug('>>> getBatchStatus results in decideForApexCall'+getBatchStatus);
       if(getAccountIds!=null && getAccountIds.size()>0)
       {
           passAcctIds.addAll(getAccountIds);
          
          
           String batchNameRef='QL_batchClassToInvokeREFRESHQUIPFlow'+getRandomBatchName; 
           
           datetime gettime=system.now().addminutes(2);
           
           day=string.valueOf(gettime.day());
           month=string.valueOf(gettime.month());
           hour=string.valueOf(gettime.hour());
           year=string.valueOf(gettime.year());
           minute=String.valueof(gettime.minute());
           
           String strSchedule= createCronExpression(day,month,hour,minute,year);
           if(!test.isRunningTest())
           {
               System.schedule(batchNameRef, strSchedule, new QL_batchClassToInvokeREFRESHQUIPFlow(passAcctIds,getBatchStatus,getRandomBatchName)); 
           }
           
           
           //Next scheduled batch updator
           QL_QuipBatchesStatusUpdator.updateBatchScheduleTime(passAcctIds,gettime,batchNameRef);  
           
       } 
    }
   
    public static string createCronExpression(String day, String month, String hour, String minute , String year)
    {
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        return strSchedule;
    }   
}