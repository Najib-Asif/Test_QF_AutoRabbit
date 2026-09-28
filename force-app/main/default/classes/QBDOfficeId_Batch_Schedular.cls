/*----------------------------------------------------------------------------------------------------------------------
Author: Praveen Sampath 
Company: Capgemini  
Purpose: Invokes QBDOfficeId_PR_Daily_Update_Batch batch class daily
Date:    
************************************************************************************************
History
************************************************************************************************
19-Dec-2016    Praveen Sampath              Initial Design           
-----------------------------------------------------------------------------------------------------------------------*/
global class QBDOfficeId_Batch_Schedular implements Schedulable {

   global void execute(SchedulableContext SC) {
        DateTime dtNow =  DateTime.now();
        DateTime dtBefor24hrs = dtNow.addHours(-24);
        List<QBD_Online_Office_ID__c> lstQBDOnline  = [select Id, LastModifiedDate from QBD_Online_Office_ID__c where 
                                                       LastModifiedDate >: dtBefor24hrs ];
       if(lstQBDOnline.size()>0){
            QBDOfficeId_PR_Daily_Update_Batch aa = new QBDOfficeId_PR_Daily_Update_Batch(false);
            Database.executeBatch(aa);
        }
   }
}