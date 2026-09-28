/*********************************************************************************
Name         : QCC_CaseStreamBatch
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 11 December 2019
Usages       : This class is used for the Case Stream logic.
*********************************************************************************/
global class QCC_CaseStreamBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public String queryString;
    public List<Id> caseIds;
    public List<Id> autoCloseCaseIds;
    
    global QCC_CaseStreamBatch(String paramQueryString, List<Id> paramCaseIds, List<Id> paramAutoCloseCaseIds) {
        queryString = paramQueryString;
        caseIds = paramCaseIds;
        autoCloseCaseIds = paramAutoCloseCaseIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('QCC_CaseStreamBatch.start');
        
        System.debug('queryString: ' + queryString);
        System.debug('caseIds: ' + caseIds);
        System.debug('autoCloseCaseIds: ' + autoCloseCaseIds);
        
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('QCC_CaseStreamBatch.execute');
        try{
            List<Case> caseRecords = (List<Case>)scope;
            System.debug('caseRecords: ' + caseRecords);
            
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CaseStream');
            System.debug('qantasAPI: ' + qantasAPI);
            
            String token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_CaseStreamToken');
            System.debug('token: ' + token);
            
            List<Log__c> logRecords = new List<Log__c>();
            for(Case caseRecord : caseRecords) {
                //This will determine if a case record should be sent as New before sending it as Closed.
                Boolean initialCaseStreamCreationSucceeded = false;
                
                //Send a callout to create the Case record first before sending a callout for the Closed.
                if (autoCloseCaseIds.contains(caseRecord.Id)) {
                    caseRecord.Status = 'New';
                    String requestBody = generateContent(caseRecord);
                    System.debug('Auto Close - requestBody: ' + requestBody);

                    //List all the log records to be created after sending the callout
                    QCC_InvokeCAPAPI.CaseStreamWrapper caseStreamWrapper = QCC_InvokeCAPAPI.invokeCaseStreamUpdateAPI(qantasAPI, token, requestBody);
                    initialCaseStreamCreationSucceeded = caseStreamWrapper.isSuccess;
                    logRecords.add(caseStreamWrapper.requestLogRecord);
                    logRecords.add(caseStreamWrapper.responseLogRecord);

                    //Reset the status to Closed
                    caseRecord.Status = 'Closed';
                } else {
                    initialCaseStreamCreationSucceeded = true;
                }
                System.debug('initialCaseStreamCreationSucceeded: ' + initialCaseStreamCreationSucceeded);
                
                //This will send the callout for the actual case record.
                if (initialCaseStreamCreationSucceeded) {
                    String requestBody = generateContent(caseRecord);
                    System.debug('Non Auto Close - requestBody: ' + requestBody);

                    //List all the log records to be created after sending the callout
                    QCC_InvokeCAPAPI.CaseStreamWrapper caseStreamWrapper = QCC_InvokeCAPAPI.invokeCaseStreamUpdateAPI(qantasAPI, token, requestBody);
                    logRecords.add(caseStreamWrapper.requestLogRecord);
                    logRecords.add(caseStreamWrapper.responseLogRecord);
                }
            }

            //Update the token field of the Qantas API record
        	QCC_GenericUtils.updateToken(token, 'QCC_CaseStreamToken');

            //Insert all the log records after sending all the callout to prevent the issue with "You have uncommited changes".
            if (!logRecords.isEmpty()) {
                QCC_LogUtilityHelper.createLogRecords(logRecords);
            }
        } catch (Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Case Stream Batch', 'QCC_CaseStreamBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    } 
    
    global void finish(Database.BatchableContext BC){
        System.debug('QCC_CaseStreamBatch.finish');
    }
    
    public static String generateContent(Case caseRecord) {
        System.debug('QCC_CaseStreamBatch.generateContent');
        
        //Get all QCC_JSON_Mapping__mdt record related to QCC Case Stream
        List<QCC_JSON_Mapping__mdt> jsonMappings = [
            SELECT Id, JSON_Field_Name__c, Object_Field_Name__c, 
            Has_Special_Logic__c, Special_Logic_Name__c, 
            Static_Resource_Name__c
            FROM QCC_JSON_Mapping__mdt
            WHERE Module_Name__c = 'QCC Case Stream'
        ];
        System.debug('jsonMappings: ' + jsonMappings);
        
        //Create a list of SOQL Setting to be used.
        Set<String> soqlSettingNames = new Set<String>();
        
        //Create a map to maintain all QCC_JSON_Mapping__mdt record based on the StaticResource Name
        Map<String, List<QCC_JSON_Mapping__mdt>> jsonFieldMap = new Map<String, List<QCC_JSON_Mapping__mdt>>();
        for(QCC_JSON_Mapping__mdt jsonMapping : jsonMappings) {
            List<QCC_JSON_Mapping__mdt> jsonMappingList;
            if (jsonFieldMap.containsKey(jsonMapping.Static_Resource_Name__c)) {
                jsonMappingList = jsonFieldMap.get(jsonMapping.Static_Resource_Name__c);
            } else {
                jsonMappingList = new List<QCC_JSON_Mapping__mdt>();
            }
            jsonMappingList.add(jsonMapping);
            jsonFieldMap.put(jsonMapping.Static_Resource_Name__c, jsonMappingList);
        }
        
        //Preparing all the data needed for generating the JSON.
        Map<String, List<sObject>> soqlSettingDataMap = new Map<String, List<sObject>>();
        
        //Case_Stream_001 - Case Record
        List<sObject> caseRecords = new List<sObject>();
        caseRecords.add(caseRecord);
        soqlSettingDataMap.put('Case_Stream_001', caseRecords);
        
        //This is used in getting the Case_Stream_002 and Case_Stream_003
        Id caseId = caseRecord.Id;
        
        //Case_Stream_002 - Query string to get all the Email Message related to the case.
        QCC_SOQL_Setting__mdt caseStream002 = QCC_UtilityHelper.getSOQLSettingByDeveloperName('Case_Stream_002');
        if (caseStream002 != null) {
            soqlSettingDataMap.put(caseStream002.DeveloperName, Database.query(caseStream002.Query_String__c));
        }
        
        //Case_Stream_003 - Query string to get all the Call Task related to the case.
        QCC_SOQL_Setting__mdt caseStream003 = QCC_UtilityHelper.getSOQLSettingByDeveloperName('Case_Stream_003');
        if (caseStream003 != null) {
            soqlSettingDataMap.put(caseStream003.DeveloperName, Database.query(caseStream003.Query_String__c));
        }
        
        System.debug('soqlSettingDataMap: ' + soqlSettingDataMap);
        
        //Get all JSON Template from StaticResource based on the QCC_JSON_Mapping__mdt records
        List<StaticResource> staticResourceRecords = [
            SELECT Id, Name, Body FROM StaticResource WHERE Name IN: jsonFieldMap.keySet()
        ];
        System.debug('staticResourceRecords: ' + staticResourceRecords);
        
        //Prepare all the JSON Template stored as static resource to generate the actual JSON content.
        Map<String, String> staticResourceMap = new Map<String, String>();
        for(StaticResource staticResourceRecord : staticResourceRecords) {
            staticResourceMap.put(staticResourceRecord.Name, staticResourceRecord.Body.toString());
        }
        System.debug('staticResourceMap: ' + staticResourceMap);
        
        System.debug('caseRecord: ' + caseRecord);
        
        //This will generate the main content of the JSON for Case Stream.
        //QCC_CaseStreamJSONTemplate - Template we are maintaining to generate the main content of the JSON.
        //QCC_CaseStreamEmailActivityJSONTemplate- Template we are maintaining for the list of activities related to the case where type is EMAIL.
        //QCC_CaseStreamCallActivityJSONTemplate- Template we are maintaining for the list of activities related to the case where type is CALL.
        String requestBody = '';
        if (caseRecord != null) {
            if (staticResourceMap.containsKey('QCC_CaseStreamJSONTemplate')) {
                String content = staticResourceMap.get('QCC_CaseStreamJSONTemplate');
                System.debug('content: ' + content);
                
                if (jsonFieldMap.containsKey('QCC_CaseStreamJSONTemplate')) {
                    for(QCC_JSON_Mapping__mdt jsonMapping : jsonFieldMap.get('QCC_CaseStreamJSONTemplate')) {
                        System.debug('jsonMapping: ' + jsonMapping);
                        if (jsonMapping.Has_Special_Logic__c) {
                            if (jsonMapping.Special_Logic_Name__c == 'getActivities') {
                                //Get all the Task and Email Message records
                                content = content.replace(jsonMapping.JSON_Field_Name__c, generateCaseActivities(jsonFieldMap, staticResourceMap, soqlSettingDataMap));
                            } else if (jsonMapping.Special_Logic_Name__c == 'generateEventId') {
                                //Generate the Event Id
                                content = content.replace(jsonMapping.JSON_Field_Name__c, generateEventId(caseRecord));
                            } else if (jsonMapping.Special_Logic_Name__c == 'removeLineBreak') {
                                //Remove the line break
                                content = content.replace(jsonMapping.JSON_Field_Name__c, removeLineBreak(caseRecord, jsonMapping.Object_Field_Name__c));
                            }
                        } else {
                            content = generateJSONContentPerField(content, jsonMapping, caseRecord);
                        }
                    }
                }
                
                System.debug('content: ' + content);
                
                requestBody = content;
            }
        }
        
        return requestBody;
    }
    
    //@Purpose: This method get the value from the record then replace the temporary content per field.
    //@input parameters:
    //	-tempContent - The temporary content of the JSON.
    //	-jsonMapping - QCC_JSON_Mapping__mdt we are maintaining to replace the specific keyword in the template.
    //	-record - The record we are using to replace the keyword in the template.
    //@return type: String which holds the temporary content.
    public static String generateJSONContentPerField(String tempContent, QCC_JSON_Mapping__mdt jsonMapping, sObject record) {
        System.debug('QCC_CaseStreamBatch.generateJSONContentPerField');
        System.debug('jsonMapping: ' + jsonMapping);
        
        if (jsonMapping.Object_Field_Name__c != null) {
            String fieldValue = QCC_UtilityHelper.getValueFromSObject(jsonMapping.Object_Field_Name__c, record);
            System.debug('fieldValue: ' + fieldValue);
            if (fieldValue != null) {
                tempContent = tempContent.replace(jsonMapping.JSON_Field_Name__c, fieldValue);
            } else {
                tempContent = tempContent.replace(jsonMapping.JSON_Field_Name__c, '');
            }
        } else {
            tempContent = tempContent.replace(jsonMapping.JSON_Field_Name__c, '');
        }
        
        return tempContent;
    }
    
    //@Purpose: This method get the Case Record in the Map
    //@input parameters:
    //	-soqlSettingDataMap - The map holding all the records per template.
    //@return type: Case record from map
    public static Case getCaseRecordFromMap(Map<String, List<sObject>> soqlSettingDataMap) {
        System.debug('QCC_CaseStreamBatch.getCaseRecordFromMap');
        Case caseRecord;
        List<Case> records = soqlSettingDataMap.get('Case_Stream_001');
        for(Case record : records) {
            caseRecord = record;
            break;
        }
        return caseRecord;
    }

    //@Purpose: This method generate EventId in the JSON
    //@input parameters:
    //	-soqlSettingDataMap - The map holding all the records per template.
    //@return type: String which holds the temporary content.
    public static String generateEventId(Case caseRecord) {
        System.debug('QCC_CaseStreamBatch.generateEventId');
        String tempEventId = '';
        DateTime lastModifiedDate = DateTime.valueOf(QCC_UtilityHelper.getValueFromSObject('LastModifiedDate', caseRecord));
        tempEventId = QCC_UtilityHelper.getValueFromSObject('Id', caseRecord) + String.valueOf(lastModifiedDate.getTime());

        return tempEventId;
    }
    
    //@Purpose: This method generate all the activities part of the JSON.
    //@input parameters:
    //	-jsonFieldMap - The map holding all the fields per template.
    //	-staticResourceMap - The map holding all the templates.
    //	-soqlSettingDataMap - The map holding all the records per template.
    //@return type: String which holds the temporary content.
    public static String generateCaseActivities(Map<String, List<QCC_JSON_Mapping__mdt>> jsonFieldMap, Map<String, String> staticResourceMap, Map<String, List<sObject>> soqlSettingDataMap) {
        System.debug('QCC_CaseStreamBatch.generateCaseActivities');
        String tempContent = '';
        
        //Generate Email Activity
        if (staticResourceMap.containsKey('QCC_CaseStreamEmailActivityJSONTemplate')) {
            String templateBody = staticResourceMap.get('QCC_CaseStreamEmailActivityJSONTemplate');
            
            List<EmailMessage> emailMessageRecords = soqlSettingDataMap.get('Case_Stream_002');
            
            for(EmailMessage emailMessageRecord : emailMessageRecords) {
                String activity = templateBody;
                for(QCC_JSON_Mapping__mdt jsonMapping : jsonFieldMap.get('QCC_CaseStreamEmailActivityJSONTemplate')) {
                    if (jsonMapping.Has_Special_Logic__c) {
                        if (jsonMapping.Special_Logic_Name__c == 'removeLineBreak') {
                            activity = activity.replace(jsonMapping.JSON_Field_Name__c, removeLineBreak(emailMessageRecord, jsonMapping.Object_Field_Name__c));
                        }
                    } else {
                        activity = generateJSONContentPerField(activity, jsonMapping, emailMessageRecord);
                    }
                }
                System.debug('activity: ' + activity);
                tempContent = tempContent == '' ? tempContent + activity : tempContent + ', ' + activity;
            }
        }
        
        //Generate Call Activity
        if (staticResourceMap.containsKey('QCC_CaseStreamCallActivityJSONTemplate')) {
            String templateBody = staticResourceMap.get('QCC_CaseStreamCallActivityJSONTemplate');
            
            List<Task> taskRecords = soqlSettingDataMap.get('Case_Stream_003');
            
            for(Task taskRecord : taskRecords) {
                String activity = templateBody;
                for(QCC_JSON_Mapping__mdt jsonMapping : jsonFieldMap.get('QCC_CaseStreamCallActivityJSONTemplate')) {
                    if (jsonMapping.Has_Special_Logic__c) {
                        if (jsonMapping.Special_Logic_Name__c == 'getRelatedToCaseNumber') {
                            activity = activity.replace(jsonMapping.JSON_Field_Name__c, getRelatedToCaseNumber(soqlSettingDataMap));
                        }
                    } else {
                        activity = generateJSONContentPerField(activity, jsonMapping, taskRecord);
                    }
                }
                System.debug('activity: ' + activity);
                tempContent = tempContent == '' ? tempContent + activity : tempContent + ', ' + activity;
            }
        }
        
        tempContent = '[' + tempContent + ']';
        System.debug('tempContent: ' + tempContent);
        
        return tempContent;
    }
    
    //@Purpose: This method generate RelatedTo field in the JSON
    //@input parameters:
    //	-soqlSettingDataMap - The map holding all the records per template.
    //@return type: String which holds the temporary content.
    public static String getRelatedToCaseNumber(Map<String, List<sObject>> soqlSettingDataMap) {
        System.debug('QCC_CaseStreamBatch.getRelatedToCaseNumber');
        String caseNumber = '';
        Case caseRecord = getCaseRecordFromMap(soqlSettingDataMap);
        if (caseRecord != null) {
            caseNumber = QCC_UtilityHelper.getValueFromSObject('CaseNumber', caseRecord);
        }

        return caseNumber;
    }

    //@Purpose: This method remove the line break and replace it with "\n"
    //@input parameters:
    //	-record - The record which holds the value of the field.
    //	-sourceFieldName - The API Name of the field.
    //@return type: String which holds the temporary content.
    public static String removeLineBreak(sObject record, String sourceFieldName) {
        System.debug('QCC_CaseStreamBatch.removeLineBreak');
        String fieldValue = '';
        if (record.get(sourceFieldName) != null) {
            fieldValue = String.valueOf(record.get(sourceFieldName));
        }
        System.debug('fieldValue before removing line break: ' + fieldValue);

        if (!String.isBlank(fieldValue)) {
            fieldValue = fieldValue.replace('\n', '\\n');
            fieldValue = fieldValue.replace('\r\n', '\\r\n');
            fieldValue = fieldValue.replace('\r', '\\r');
        }
        System.debug('fieldValue after removing line break: ' + fieldValue);

        return fieldValue;
    }
}