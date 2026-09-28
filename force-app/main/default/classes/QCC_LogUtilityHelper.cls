/*********************************************************************************
Name         : QCC_LogUtilityHelper
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 2 September 2019
Usages       : This class is used to handle all Log__c related logic.
*********************************************************************************/
public class QCC_LogUtilityHelper {
    //@Purpose: This method is used to generate the Log__c record.
    //@input parameters:
    //	1. moduleName - The name of the module where the error happen.
    //	2. className - The name of the class where this method has been called.
    //	3. methodName - The name of the method where this method has been called.
    //	4. inboundMessage - The Inbound Message / Request when sending a callout.
    //	5. outboundMessage - The Outbound Message / Response after sending a callout.
    //	6. isIntegrationMessage - The flag whether the log record is for integration or not.
    //	7. recordId - The ID of the record being processed when the error happen.
    //	8. ex - The actual exception when the error happen.
    //	9. errorMessage - The error message when ex is null.
    //@return type: Generated log record that can be inserted.
    public static Log__c generateLogRecord(String moduleName, String className, String methodName, 
                                           String inboundMessage, String outboundMessage, Boolean isIntegrationMessage, 
                                           String recordId, Exception ex, String errorMessage) 
    {
        String recordTypeName;
        Log__c logRecord = new Log__c();
        
        //Set the record type name based on the isIntegrationMessage flag
        if (isIntegrationMessage) {
            recordTypeName = 'Integration Logs';
        } else {
            recordTypeName = 'Exception Logs';
        }
        
        //Generate the log record
        logRecord.RecordTypeId = GenericUtils.getObjectRecordTypeId('Log__c', recordTypeName);
        logRecord.Business_Function_Name__c = moduleName;
        logRecord.Class_Name__c = className;
        logRecord.Method_Name__c = methodName;
        logRecord.Is_Integration_Error__c = isIntegrationMessage;
        logRecord.Inbound_Payload__c = inboundMessage;
        logRecord.Outbound_Payload__c = outboundMessage;
        logRecord.FailedRecordID__c = recordId;
        logRecord.LoggedIn_User__c = UserInfo.getUserName();
        
        //Parse the exception to get the error message
        if (ex != null) {
            logRecord = parseException(logRecord, ex);
        } else {
            logRecord.Error_Message__c = errorMessage;
        }
        
        return logRecord;
    }
    
    //@Purpose: This method parse the exception and update the log record generated.
    //@input parameters:
    //	1. logRecord - The log record that will be updated.
    //	2. ex - The actual exception when the error happen.
    //@return type: Updated log record with Error message.
    public static Log__c parseException(Log__c logRecord, Exception ex) {
        logRecord.Exception_Type__c = ex.getTypeName();
        logRecord.Error_Message__c = ex.getMessage();
        logRecord.Error_Message__c += ' ' + ex.getStackTraceString();
        
        return logRecord;
    }
    
    //@Purpose: This method creates the log record
    //@input parameters:
    //	1. logRecord - The log record to be inserted
    //@return type: None
    public static void createLogRecord(Log__c logRecord) {
        insert logRecord;
    }
    
    //@Purpose: This method creates a list of log record
    //@input parameters:
    //	1. logRecords - The log record list to be inserted
    //@return type: None
    public static void createLogRecords(List<Log__c> logRecords) {
        if (!logRecords.isEmpty()) {
            insert logRecords;
        }
    }

    public static DatabaseResultsWrapper getDatabaseResults (Database.SaveResult[] saveResultList, String moduleName, String className, String methodName) {
        Map<String, List<String>> failedResultsMap = new Map<String, List<String>>();
        Set<Id> successfulIds = new Set<Id>();
        Integer recordCount = 0;
        for(Database.SaveResult saveResult : saveResultList) {
            recordCount = recordCount + 1;
            if(saveResult.isSuccess()) {
                successfulIds.add(saveResult.id);
            }else{
                List<String> resultMessageList = new List<String>();
                for(Database.Error err : saveResult.getErrors()) {
                    resultMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                }
                String resultId = (saveResult.getId() != '') ? saveResult.getId() : String.valueOf(recordCount);
                failedResultsMap.put(resultId, resultMessageList);
            }
        }

        DatabaseResultsWrapper DatabaseResults = new DatabaseResultsWrapper();
        DatabaseResults.successfulRecordIds = successfulIds;
        DatabaseResults.failedRecordsMessages = failedResultsMap;

        //Create the log record for those save result that fails
        List<Log__c> logRecords = new List<Log__c>();
        for(String recordId: DatabaseResults.failedRecordsMessages.keyset()){
            for(String resultMessage : DatabaseResults.failedRecordsMessages.get(recordId)) {
                logRecords.add(QCC_LogUtilityHelper.generateLogRecord(moduleName, className, methodName, '', '', false, recordId, null, resultMessage));
            }
        }
        if (!logRecords.isEmpty()) {
            QCC_LogUtilityHelper.createLogRecords(logRecords);
        }


        return DatabaseResults;

    }

    public class DatabaseResultsWrapper {
        public Set<Id> successfulRecordIds;
        public Map<String, List<String>> failedRecordsMessages;
    }
}