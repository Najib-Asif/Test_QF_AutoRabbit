/*********************************************************************************
Name         : QCC_LogUtilityHelper
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 2 September 2019
Usages       : This class to create Log__c record from the Case Creation Flow
*********************************************************************************/
public class QCC_CreateLogRecordInvocable {
    //@Purpose: This method is used to create the log record for the flow.
    //@input parameters:
    //	1. logRecords - The list of log records that will come from the flow.
    //@return type: None
    @InvocableMethod
    public static void createLog(List<Log__c> logRecords) {
        List<Log__c> newLogRecordList = new List<Log__c>();
        System.debug('logRecords: ' + logRecords);
        
        //Generate the Log__c record
        for (Log__c logRecord : logRecords) {
            newLogRecordList.add(QCC_LogUtilityHelper.generateLogRecord(logRecord.Business_Function_Name__c, 'QCC_CreateLogRecordInvocable', 'createLog', '', '', false, '', null, logRecord.Error_Message__c));
        }
        System.debug('newLogRecordList: ' + newLogRecordList);
        
        //Create the Log__c record
        QCC_LogUtilityHelper.createLogRecords(newLogRecordList);
    }
}