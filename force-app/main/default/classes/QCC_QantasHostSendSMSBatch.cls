/*********************************************************************************
Name         : QCC_QantasHostSendSMSBatch
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 October 2019
Usages       : This will process all Qantas Host records with QCC_TECH_SMS_Need_To_Send__c = true to send the Qantas Host message.
*********************************************************************************/
global class QCC_QantasHostSendSMSBatch implements Database.Batchable<sObject>{
    global String queryString;
    
    global QCC_QantasHostSendSMSBatch(String paramQueryString) {
        System.debug('QCC_QantasHostSendSMSBatch');
        queryString = paramQueryString;
        System.debug('queryString: ' + queryString);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('QCC_QantasHostSendSMSBatch.start');
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('QCC_QantasHostSendSMSBatch.execute');
        try{
            List<QCC_First_Host__c> qantasHostRecords = (List<QCC_First_Host__c>)scope;
            System.debug('qantasHostRecords: ' + qantasHostRecords);
            
            //Get all record Ids
            List<Id> qantasHostIds = new List<Id>();
            for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
                qantasHostIds.add(qantasHostRecord.Id);
            }
            
            //Reuse the same logic
            QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference(qantasHostIds);
        } catch (Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Qantas Host Status Send SMS Batch', 'QCC_QantasHostSendSMSBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    } 
    
    global void finish(Database.BatchableContext BC){
        System.debug('QCC_QantasHostSendSMSBatch.finish');
    }
}