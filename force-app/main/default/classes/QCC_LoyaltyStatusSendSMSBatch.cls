/*********************************************************************************
Name         : QCC_LoyaltyStatusSendSMSBatch
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 September 2019
Usages       : This class is used to send the SMS on certain schedule.
*********************************************************************************/
global class QCC_LoyaltyStatusSendSMSBatch implements Database.Batchable<sObject>{
    global String queryString;
    
    global QCC_LoyaltyStatusSendSMSBatch(String paramQueryString) {
        queryString = paramQueryString;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //This will get all the contact records where QCC_TECH_Loyalty_Point_Type__c != null and QCC_LoyaltyBonus_Channel__c = SMS
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            List<Contact> contactRecords = (List<Contact>)scope;
            QCC_LoyaltyStatusSendSMSInvocable.processLoyaltyStatusSMSSending(contactRecords);
        } catch (Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Loyalty Status Send SMS Batch', 'QCC_LoyaltyStatusSendSMSBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    } 
    
    global void finish(Database.BatchableContext BC){
    }
}