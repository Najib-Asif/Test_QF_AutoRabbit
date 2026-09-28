/*********************************************************************************
Name         : QCC_TransformActionToObjectBatch
Created By   : Leslie Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 July 2019
Usages       : This class is used to generate target records for the modules below
			   - Quarterly Health Check Call
			   - No Flight Health Check
			   - Watch list is Expiring
*********************************************************************************/
global class QCC_TransformActionToObjectBatch implements Database.Batchable<sObject>, Database.Stateful{
    global String objectName;
    global String query;
    global String moduleName;
    global String recordTypeId;
    global Map<String, List<String>> resultMap;

    //GRAPHITE-1372 This will hold all the created case via this batch
    List<Id> caseIds = new List<Id>();

    global QCC_TransformActionToObjectBatch(String targetObjectName, String queryString, String metaModuleName, String targetRecordTypeId){
        objectName = targetObjectName;
        query = queryString;
        moduleName = metaModuleName;
        recordTypeId = targetRecordTypeId;
	   	resultMap = new Map<String, List<String>>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        //Dynamically create object
        //Get the custom metadata type for this object
        String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
        String conditionClause = ' WHERE Module_Name__c = \'' + moduleName + '\'';
        List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords (metaName, conditionClause);
        system.debug('>>>metaObjects: ' + metaObjects);

        //Call the method that transforms the source records to their corresponding object
        try{
            List<sObject> records = (List<sObject>)scope;
            System.debug('records: ' + records);
            //GRAPHITE-119: New parameter added to the transformSourceToTargetObjects
            List<sObject> newRecords = QCC_UtilityHelper.transformSourceToTargetObjects (moduleName, records, metaObjects, objectName, recordTypeId, null);
            System.debug('newRecords: ' + newRecords);
            List<Database.SaveResult> saveResultList = Database.insert(newRecords, false);
            System.debug('saveResultList: ' + saveResultList);
            //Generate the save result so that we can create a Log record later.
            Integer recordCounter = 0;
            for(Database.SaveResult saveResult : saveResultList) {
                String recordId = records[recordCounter].Id;
                String caseId = newRecords[recordCounter].Id;
                List<String> resultMessageList = new List<String>();
                if (!saveResult.isSuccess()) {
                    for(Database.Error err : saveResult.getErrors()) {
                        resultMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    resultMap.put(recordId, resultMessageList);
                } else {
                    //GRAPHITE-1372 List all created case ids
                    caseIds.add(caseId);
                }
                recordCounter++;
            }
            System.debug('resultMap: ' + resultMap);
            System.debug('caseIds: ' + caseIds);

            //Create the log record for those save result that fails
            List<Log__c> logRecords = new List<Log__c>();
            for(String recordId: resultMap.keyset()){
                for(String resultMessage : resultMap.get(recordId)) {
                    logRecords.add(QCC_LogUtilityHelper.generateLogRecord('QCC - Transform Action To Object', 'QCC_TransformActionToObjectBatch', 'execute', '', '', false, recordId, null, resultMessage));
                }
            }
            if (!logRecords.isEmpty()) {
                QCC_LogUtilityHelper.createLogRecords(logRecords);
            }
        } catch (Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Transform Action To Object', 'QCC_TransformActionToObjectBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('QCC_TransformActionToObjectBatch.finish');
        //GRAPHITE-1372 Send Case Stream manually for Quarterly, No Flight and Watchlist expiring since we cannot call new batch inside execute.
        List<Id> caseIdsToSendCaseStream = new List<Id>();
        List<Id> autoClosedCaseIds = new List<Id>();

        Map<String, List<String>> caseStreamSwitchPerTypeMap = QCC_UtilityHelper.getAllCaseStreamSwitch(true);
        List<Case> caseRecords = [SELECT Id, Status, Type FROM Case WHERE Id IN: caseIds];
        for(Case caseRecord : caseRecords) {
            Boolean canSendCaseStreamCallout = QCC_UtilityHelper.checkIfCanSendCaseStreamCallout(caseStreamSwitchPerTypeMap, caseRecord);
            if (canSendCaseStreamCallout) {
                caseIdsToSendCaseStream.add(caseRecord.Id);
            }
        }

        System.debug('caseIdsToSendCaseStream: ' + caseIdsToSendCaseStream);
        if (!caseIdsToSendCaseStream.isEmpty()) {
            QCC_SOQL_Setting__mdt caseStream001 = QCC_UtilityHelper.getSOQLSettingByDeveloperName('Case_Stream_001');
            if (caseStream001 != null) {
                Database.executeBatch(new QCC_CaseStreamBatch(caseStream001.Query_String__c, caseIdsToSendCaseStream, autoClosedCaseIds), 1);
            }
        }
    }
}