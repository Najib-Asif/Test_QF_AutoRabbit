/*********************************************************************************
Name         : QCC_LoyaltyStatusSendSMSSchedulable
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 September 2019
Usages       : This class is used to send the SMS on certain schedule.
*********************************************************************************/
global class QCC_LoyaltyStatusSendSMSSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        //Get the metadata record for the specific Module Name
        QCC_SOQL_Setting__mdt customMetadataRecord = QCC_UtilityHelper.getSOQLSettingRecordByModuleName('Loyalty Status Event Send SMS');
        
        //Checking if metadata is null
        if (customMetadataRecord != null) {
            //Execute the dynamic batch job to trigger the creation of case records
            Id batchJobId = Database.executeBatch(
                new QCC_LoyaltyStatusSendSMSBatch(customMetadataRecord.Query_String__c),
                Integer.valueOf(customMetadataRecord.Batch_Size__c)
            );
        }
    }
}