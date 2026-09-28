/*********************************************************************************
Name         : QCC_SendQantasReportToSPSchedulable
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 August 2019
Usages       : This class is used to schedule the batch job below:
         - QCC_SendQantasReportToSharepointBatch
*********************************************************************************/
global class QCC_SendQantasReportToSPSchedulable implements Schedulable {
    public String moduleName;
    
    public QCC_SendQantasReportToSPSchedulable(String paramModuleName){
        moduleName = paramModuleName;
    }
    
     global void execute(SchedulableContext sc) {
        //Get the metadata record for the specific Module Name
        QCC_SOQL_Setting__mdt customMetadataRecord;
        try {
            customMetadataRecord = [
                SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c, Filter_Condition__c 
                FROM QCC_SOQL_Setting__mdt 
                WHERE Module_Name__c =: moduleName LIMIT 1
            ];
        } catch(Exception ex) {
            customMetadataRecord = null;
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Send Qantas Report To Sharepoint Schedulable', 'QCC_SendQantasReportToSPSchedulable', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
        //Checking if metadata is null
        if (customMetadataRecord != null) {
            //Execute the dynamic batch job to trigger the creation of case records
            Id batchJobId = Database.executeBatch(
                new QCC_SendQantasReportToSharepointBatch(
                    customMetadataRecord.Target_Object__c,
                    customMetadataRecord.Query_String__c,
                    customMetadataRecord.Module_Name__c,
                    null
                ), 
                Integer.valueOf(customMetadataRecord.Batch_Size__c)
            );
        }
    }

}