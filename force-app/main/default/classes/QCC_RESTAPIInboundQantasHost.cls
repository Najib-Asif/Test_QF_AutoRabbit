/*********************************************************************************
Name         : QCC_InboundQantasHostRESTAPI
Created By   : Leslie Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE-1054
Created Date : 20 October 2019
Usages       : This class holds all inbound API requests for the Qantas Host object
*********************************************************************************/
@RestResource(urlMapping='/AccessQantasHost/*')
global with sharing class QCC_RESTAPIInboundQantasHost{
    //Variables
    private static String inboundPayload {get;set;}
    private static String outboundPayload {get;set;}
    
    //This service expects single record for update
	@Httppatch
    global static void start(){
        System.debug('QCC_InboundQantasHostRESTAPI.start');
        RestRequest req = RestContext.request;
        System.debug('req: ' + req);
        
        inboundPayload = req.requestBody.toString();
        
        //Create log record for Inbound Payload
        Log__c logRecordInbound = QCC_LogUtilityHelper.generateLogRecord('QCC - Inbound Qantas Host REST API', 'QCC_InboundQantasHostRESTAPI', 'updateQantasHost', inboundPayload, '', false, '', null, '');
        QCC_LogUtilityHelper.createLogRecord(logRecordInbound);
        
        RestContext.response.responseBody = execute();
        
        //Create log record for Outbound Payload
        Log__c logRecordOutbound = QCC_LogUtilityHelper.generateLogRecord('QCC - Inbound Qantas Host REST API', 'QCC_InboundQantasHostRESTAPI', 'updateQantasHost', '', outboundPayload, false, '', null, '');
        QCC_LogUtilityHelper.createLogRecord(logRecordOutbound);
    }    
    
    public static Blob execute() {
        System.debug('QCC_InboundQantasHostRESTAPI.execute');
        ResponseWrapper response;        
        try {
            //Deserializing the request string received from the request
            Map<String,Object> objectMap = (Map<String,Object>)JSON.deserializeUntyped(inboundPayload);
            Map<String,Object> newObjs = new Map<String,Object>();
            newObjs.put('1',objectMap);
            System.debug('>>>newObjs: ' + newObjs);

            //This approach works only if the request body matches the Salesfoce field API names
            List<sObject> dynamicRecords = QCC_UtilityHelper.createDynamicObjectRecords ('QCC_First_Host__c', '', newObjs, null, null, null);
            System.debug('dynamicRecords: ' + dynamicRecords);

            String conditionClause = ' WHERE Module_Name__c = \'AccessQantasHost\'';
            List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords ('QCC_Source_to_Target_Object_Mapping__mdt', conditionClause);

            List<sObject> recordsToUpdate = QCC_UtilityHelper.transformSourceToTargetObjects (
                'AccessQantasHost',
                dynamicRecords,
                metaObjects,
                'QCC_First_Host__c',
                null,
                null
            );
            System.debug('recordsToUpdate: ' + recordsToUpdate);

            //List all the record Ids to retrieve all the Departure Dates
            List<String> recordIds = new List<String>();
            for(sObject recordToUpdate : recordsToUpdate) {
                recordIds.add(String.valueOf(recordToUpdate.get('Id')));
            }

            //Retrieve all the needed information from the Qantas Host record.
            List<sObject> records = [SELECT Id, QCC_Departure_Local_Date__c FROM QCC_First_Host__c WHERE Id IN: recordIds];
            Boolean hasDepartureDateAlreadyPassed = false;

            //Get the time expiration that will be concatenated to the departure date of the Qantas Host record
            String expirationTimeLabel = Test.isRunningTest() ? '23:00' : Label.QCC_Qantas_Host_Form_Expiration_Time;
            Integer hh = Integer.valueOf(expirationTimeLabel.substringBefore(':'));
            Integer mm = Integer.valueOf(expirationTimeLabel.substringAfterLast(':'));
            Time expirationTime = Time.newInstance(hh, mm, 0, 0);

            System.debug('expirationTime: ' + expirationTime);
            
            DateTime dateTimeNow = System.now();

            //Generate new GMT Date Time for the current datetime.
            Time timeNow = Time.newInstance(dateTimeNow.hour(), dateTimeNow.minute(), dateTimeNow.second(), 0);
            dateTimeNow = DateTime.newInstanceGmt(Date.valueOf(dateTimeNow), timeNow);
            System.debug('dateTimeNow: ' + dateTimeNow);

            //Check if there are Qantas Host records included in the request that passed the expiration date and time.
            for(sObject record : records) {
                Date departureDate = Date.valueOf(record.get('QCC_Departure_Local_Date__c'));
                System.debug('departureDate: ' + departureDate);
                DateTime expirationDateTime = Datetime.newInstanceGmt(departureDate.addDays(-1), expirationTime);
                System.debug('expirationDateTime: ' + expirationDateTime);
                if (dateTimeNow > expirationDateTime) {
                    hasDepartureDateAlreadyPassed = true;
                    break;
                }
            }

            System.debug('hasDepartureDateAlreadyPassed: ' + hasDepartureDateAlreadyPassed);

            if (hasDepartureDateAlreadyPassed) {
                response = generateResponse ('400', 'Expiration time reached');
            } else {
                if (!recordsToUpdate.isEmpty()) {
                    List<QCC_First_Host__c> qantasHostRecords = recordsToUpdate;
                    for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
                        qantasHostRecord.QCC_Online_Form_Submission_Date__c = System.now();
                    }

                    System.debug('qantasHostRecords: ' + qantasHostRecords);

                    update qantasHostRecords;
                }
                
                response = generateResponse('200', 'Qantas Host record successfully updated.');
            }
        } catch (Exception ex) {
            response = generateResponse('404', ex.getMessage());
            
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Inbound Qantas Host REST API', 'QCC_InboundQantasHostRESTAPI', 'parseString', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
        outboundPayload = JSON.serializePretty(response);
        Blob jsonBlob = Blob.valueOf(outboundPayload);
        return jsonBlob;
    }
    
    public class ResponseWrapper{
        public String StatusCode {get;set;}
        public String Result {get;set;}
        public String Message {get;set;}
    }
    
    public static ResponseWrapper generateResponse(String statusCode, String responseMessage) {
        System.debug('QCC_InboundQantasHostRESTAPI.generateResponse');
        ResponseWrapper response = new ResponseWrapper();
        response.StatusCode = statusCode;
        response.Result = statusCode == '200' ? 'Success' : 'Failed';
        response.Message = responseMessage;
        
        System.debug('response: ' + response);
        
        return response;
    }
}