/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath 
Company:       Capgemini
Description:   Schedule class to run when the Custom Setting value on Scheme Fee is changed
Inputs:        
Test Class:     
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
global class SchemeFee_Batch_Scheduler implements Schedulable {
         
    global void execute(SchedulableContext sc) {
        DateTime dtNow =  DateTime.now();
        DateTime dtBefor24hrs = dtNow.addHours(-24);
        boolean isGSTChanged = false;
        List<SchemeFees__c> lstSchemeFee  = [select Id, Scheme_Type__c, Currency__c, LastModifiedDate from 
                                              SchemeFees__c where LastModifiedDate >: dtBefor24hrs ];
       

        List<String> lstName = CustomSettingsUtilities.getConfigDataMap('GSTSettings').split(';');
        system.debug('lstName#######'+lstName);
        List<QantasConfigData__c> lstConfig  = [select Id, LastModifiedDate from QantasConfigData__c where 
                                                LastModifiedDate >: dtBefor24hrs and Name IN: lstName];

        if(lstConfig != Null && lstConfig.size()>0){
            isGSTChanged = true;
        }
       
        if(lstSchemeFee.size()>0 || isGSTChanged){
            SchemeFee_Daily_Update_Check_Batch runBatch = new SchemeFee_Daily_Update_Check_Batch(isGSTChanged, lstSchemeFee);
            Database.executeBatch(runBatch);
        }
    }
}