/*********************************************************************************
Name         : QCC_TransformActionToObjectSchedulable
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 July 2019
Usages       : This class is used to schedule the batch job for the modules below:
			   - Quarterly Health Check Call
			   - No Flight Health Check
			   - Watch list is Expiring
*********************************************************************************/
global class QCC_TransformActionToObjectSchedulable implements Schedulable {
    public String moduleName;
    
    public QCC_TransformActionToObjectSchedulable(String paramModuleName){
        moduleName = paramModuleName;
    } 
    
    global void execute(SchedulableContext sc) {
        //Get all the switch
        Map<String, QCC_Platform_Event_Switch__c> switchSettings = QCC_UtilityHelper.getPlatformEventSwitch();

        if (switchSettings.containsKey(moduleName)) {
            if(switchSettings.get(moduleName).Active__c){
                //Get the metadata record for the specific Module Name
                QCC_SOQL_Setting__mdt customMetadataRecord;
                try {
                    customMetadataRecord = [
                        SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c
                        FROM QCC_SOQL_Setting__mdt
                        WHERE Module_Name__c =: moduleName LIMIT 1
                    ];
                } catch(Exception e) {
                    customMetadataRecord = null;
                }

                //Checking if metadata is null
                if (customMetadataRecord != null) {
                    //Generate the filter for the SOQL based on the metadata records.
                    String queryString = QCC_SpecialLogicUtilityHelper.generateAdditionalFilterForDynamicSOQL(customMetadataRecord.Module_Name__c, customMetadataRecord.Query_String__c);
                    String targetRecordTypeId = Schema.getGlobalDescribe().get(customMetadataRecord.Target_Object__c).getDescribe().getRecordTypeInfosByName().get(customMetadataRecord.Target_Record_Type__c).getRecordTypeId();

                    System.debug('query: ' + queryString);

                    //Execute the dynamic batch job to trigger the creation of case records
                    Id batchJobId = Database.executeBatch(
                        new QCC_TransformActionToObjectBatch(
                            customMetadataRecord.Target_Object__c,
                            queryString,
                            customMetadataRecord.Module_Name__c,
                            targetRecordTypeId
                        ),
                        Integer.valueOf(customMetadataRecord.Batch_Size__c)
                    );
                }
            }
        }
    }
}