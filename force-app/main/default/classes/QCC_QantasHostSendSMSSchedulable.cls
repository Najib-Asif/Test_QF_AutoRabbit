/*********************************************************************************
Name         : QCC_QantasHostSendSMSSchedulable
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 24 October 2019
Usages       : This class is used to send the SMS on certain schedule when new Qantas Host record has been created via Pre Departure Event
*********************************************************************************/
global class QCC_QantasHostSendSMSSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.debug('QCC_QantasHostSendSMSSchedulable.execute');
        
        //Get the metadata record for the specific Module Name
        QCC_SOQL_Setting__mdt customMetadataRecord = QCC_UtilityHelper.getSOQLSettingRecordByModuleName('Qantas Host Send SMS');
        
        System.debug('customMetadataRecord: ' + customMetadataRecord);
        
        //Checking if metadata is null
        if (customMetadataRecord != null) {
            //Execute the dynamic batch job to trigger the creation of case records
            Id batchJobId = Database.executeBatch(
                new QCC_QantasHostSendSMSBatch(customMetadataRecord.Query_String__c), 
                Integer.valueOf(customMetadataRecord.Batch_Size__c)
            );
        }
    }
}