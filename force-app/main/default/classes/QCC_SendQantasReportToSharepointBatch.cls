/*********************************************************************************
Name         : QCC_SendQantasHostReportToSharepointBatch
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 August 2019
Usages       : This class is used to generate csv file and send upload it to Sharepoint
*********************************************************************************/
public class QCC_SendQantasReportToSharepointBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{    
    public String objectName;
    public String query;
    public String moduleName;
    public String recordTypeId;
    
    public QCC_SendQantasReportToSharepointBatch(String targetObjectName, String queryString, String metaModuleName, String targetRecordTypeId){
        objectName = targetObjectName;
        query = queryString; 
        moduleName = metaModuleName;
        recordTypeId = targetRecordTypeId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        if(Test.isRunningTest()){
            //Prevent more than one execute batch in test class
            query = query + ' LIMIT 1';
        }
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<QCC_Report_Extract_Setting__mdt> scope){
        try{
            system.debug('scope : '+scope);
            for(QCC_Report_Extract_Setting__mdt qantasHostSetting : scope){
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectField> qantasHostObjectSchema;
                qantasHostObjectSchema = Schema.SObjectType.QCC_First_Host__c.fields.getMap();
                
                //Filename format : "FFPO SYD Qantas Host Service Report DDMMMYY" i.e FFPO SYD Qantas Host Service Report 22AUG19
                String inputDate = Datetime.now().addDays(Integer.valueOf(Label.QCC_Qantas_Host_Report_Days)).format('ddMMMyy');
                String fileName = qantasHostSetting.QCC_Filename__c;
                filename = filename.replace('[inputDate]',inputDate);
                system.debug('fileName:' + fileName);
            
                HttpRequest httpRequestToSend = new HttpRequest();   
                httpRequestToSend.setEndpoint(qantasHostSetting.QCC_Sharepoint_Folder_Location__c+'(\''+EncodingUtil.urlEncode(qantasHostSetting.QCC_Sharepoint_Folder_Name__c , 'UTF-8').replaceAll('\\+','%20')+'\')/files/add(url=\''+EncodingUtil.urlEncode(fileName , 'UTF-8').replaceAll('\\+','%20')+'\')'); 
                httpRequestToSend.setMethod('POST'); 

                String extractDate = String.valueOf(Date.today().addDays(Integer.valueOf(Label.QCC_Qantas_Host_Report_Days))).removeEnd(' 00:00:00');
                String qantasHostQuery = 'SELECT ';
                qantasHostQuery += qantasHostSetting.QCC_Query_Column__c;
                qantasHostQuery += ' FROM ' + qantasHostSetting.QCC_Target_Object__c;
                
                qantasHostQuery += ' ' + qantasHostSetting.QCC_Query_Filter_Condition__c.replace('[extractDate]',extractDate);
                system.debug(qantasHostQuery);
                
                ///////////////////////////////////////////
                // List all Contact/Passenger Id's
                List<Id> passengerIdsList = new List<Id>();
                for(QCC_First_Host__c qatashost : database.query(qantasHostQuery)){
                    passengerIdsList.add(qatashost.QCC_First_Host_Contact__c);
                }
                
                Map<Id,flightDisruptionWrapper> passengerDisruptionMap = new Map<Id,flightDisruptionWrapper>();
                if(passengerIdsList.size() > 0){
                    passengerDisruptionMap = getPassengerDisruption(passengerIdsList);
                }
                
                List<QCC_First_Host__c> firstHostList = database.query(qantasHostQuery);
                //Update the heading row as per the User Story 
                String concatFields = qantasHostSetting.QCC_Report_Header__c + '\n'; 
                for(QCC_First_Host__c firstHost : firstHostList){
                    for(String qantasHostField : qantasHostSetting.QCC_Query_Column__c.Split(',')){
                        if(qantasHostField == 'QCC_First_Host_Contact__c') continue; // Do not process Contact Id field
                            
                        String sourceFieldValue = '';
                        // IF THE FIELD IS RELATIONAL
                        List<String> splittedFields = qantasHostField .split('\\.');
                        sObject lookupRecord = firstHost;
                        if (splittedFields.size() > 1) {
                            for(Integer x = 0; x < splittedFields.size() - 1; x++) {
                                String lookupObjectName = splittedFields[x];
                                lookupRecord = lookupRecord.getSObject(lookupObjectName);
                            }
                            
                            String lookupFieldName = splittedFields[splittedFields.size() - 1];
                            if(string.valueOf(lookupRecord) != NULL ){
                                //Added checking if the field type is DATETIME format the field, Boolean change to Yes/No
                                Map<String, Schema.SObjectField> sObjectFieldMap = schemaMap.get(lookupRecord.getSObjectType().getDescribe().getName()).getDescribe().fields.getMap();
                                Schema.SObjectField field = sObjectFieldMap.get(lookupFieldName);
                                Schema.DisplayType fieldType = field.getDescribe().getType();
                                sourceFieldValue = processFieldValue(sObjectFieldMap,lookupFieldName.trim(),lookupRecord);
                            }
                        }else{ // ELSE THE FIELD IS ON THE OBJECT ITSELF
                            String fieldName = qantasHostField.trim().replace('tolabel(', '');
                            fieldName = fieldName.trim().replace(')', '');
                            sourceFieldValue = processFieldValue(qantasHostObjectSchema,fieldName,firstHost);
                        }
                        
                        if(sourceFieldValue != null){
                            concatFields += sourceFieldValue;
                        }
                        concatFields +=',';  
                    }
                    // Append Additional Qantas Report Field that are not part of the query
                    if(passengerDisruptionMap.containsKey(firstHost.QCC_First_Host_Contact__c)){
                        flightDisruptionWrapper passengerDisruption = passengerDisruptionMap.get(firstHost.QCC_First_Host_Contact__c);
                                                Datetime disruptionDate = passengerDisruption.scheduledDepartureDate;
    
                        concatFields += passengerDisruption.totalDisruption + ',';
                        concatFields += disruptionDate.format('dd/MM/yyyy') + ',';
                        concatFields += passengerDisruption.flightNumber + ',';
                        concatFields += passengerDisruption.delayFailureCode + ',';
                        concatFields += passengerDisruption.departureDelayLength + ',';
                    }
                    concatFields += '\n';
                }
                
                //Handle exceptions for no rows returned and size of the file exceeding the heap size here 
                httpRequestToSend.setBodyAsBlob(Blob.ValueOf(concatFields)); 
                httpRequestToSend.setHeader('Authorization', 'Bearer '); 

                Http http = new Http();
                if(!Test.isRunningTest()){
                    HttpResponse httpResponse = http.send(httpRequestToSend);   
                }
                //Handle exceptions and log for debugging and maintenance purpose 
                //For report failure scenarios, send an email to the email address agreed with Qantas  

            }
        } catch (Exception ex) {
            //TO-DO: Error Handling
            system.debug('ERROR : ' + ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Send Qantas Report To Sharepoint Batch Job', 'QCC_SendQantasReportToSharepointBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }     
    public void finish(Database.BatchableContext BC){
        
    }
    
    // Process Disruption Logic Base on GRAPHITE-120 story
    public Map<Id,flightDisruptionWrapper> getPassengerDisruption(List <Id> passengerIds){
         Map<Id,flightDisruptionWrapper> passengerDisruptionMap = new Map<Id,flightDisruptionWrapper>();
         QCC_SOQL_Setting__mdt customMetadataRecord = QCC_UtilityHelper.getSOQLSettingRecordByModuleName(Label.QCC_Qantas_Host_Report_Disruption);
         if (customMetadataRecord != null) {
            //Generate the filter for the SOQL based on the metadata records.
            String queryFilter = QCC_SpecialLogicUtilityHelper.generateFilterForDynamicSOQL(customMetadataRecord.Module_Name__c, customMetadataRecord.Filter_Condition__c);
            // FIELDS ->> Passenger__c,Event__r.RecordTypeName__c,Event__r.ScheduledDepDate__c,Event__r.FlightNumber__c,Event__r.DelayFailureCode__c,Event__r.DepartureDelayinHRSandMIN__c,Event__r.TechDepartureDelayDuration__c,Event__r.IntDom__c
            String ids = string.join(passengerIds,'\',\'');
            String soqlQueryString = customMetadataRecord.Query_String__c + queryFilter.replace('[inputPassengerIds]',ids);
            system.debug(queryFilter.replace('[inputPassengerIds]',ids));
            
            
             
             for(Affected_Passenger__c passenger : database.query(soqlQueryString)){
                 Boolean isOverrideInfo = false; // Flag to Override Passenger Disruption Information
                 if(!passengerDisruptionMap.containsKey(passenger.Passenger__c)){
                     passengerDisruptionMap.put(passenger.Passenger__c,new flightDisruptionWrapper());
                 }
                 
                 /*********************************
                  PROCESS PASSENGER DISRUPTION WRAPPER
                    Check 2: Was there an International Flight Cancellation within the last 7 days?
                        If Yes: Check if there was more than 1 INT flight cancellation, and display details of the most recent one.
                    Check 3: Was there an International Flight Delay within the last 7 days?
                        If Yes: Check if there was more than 1 INT flight cancellation, and display details of the most delay with the largest value in the "Departure Delay Length" field.
                    Check 4: Was there a DOM Flight Cancellation within the last 7 days?
                        If Yes: Check if there was more than 1 DOM flight cancellation, and display details of the most recent one.
                    Check 5: Was there a  DOM Flight Delay within the last 7 days?
                        If Yes: Check if there was more than 1 DOM flight cancellation, and display details of the most delay with the largest value in the "Departure Delay Length" field. 
                 ***********************************/
                 
                 flightDisruptionWrapper flightDisruption = passengerDisruptionMap.get(passenger.Passenger__c);
                 flightDisruption.totalDisruption += 1; // Increment the disruption count by 1
                 if(flightDisruption.IntDom == NULL){ // Check if there was a Passenger Flight Disruptions Info if none update
                    isOverrideInfo = true;
                 }else{ // Update Passenger Disruption Info
                     if(passenger.Event__r.IntDom__c == 'Domestic' && flightDisruption.IntDom == 'International'){
                         continue; // Do not process Domestic if International disruption already setup
                     }
                     
                     if(passenger.Event__r.DelayFailureCode__c == 'Flight Cancellation'){ // If the event is flight cancelation, and the previous passenger was Flight Delay override the info, or get the latest Flight Cancelation info
                         if( (flightDisruption.delayFailureCode == 'Flight Delay') 
                            || (passenger.Event__r.IntDom__c == 'International' && flightDisruption.IntDom == 'Domestic') 
                            || (passenger.Event__r.ScheduledDepDate__c > flightDisruption.scheduledDepartureDate) )
                         {
                             isOverrideInfo = true;
                         }
                     }else if(passenger.Event__r.DelayFailureCode__c == 'Flight Delay'){ // if the event is Flight Delay compare it to previous passenger Flight Delay
                         if((passenger.Event__r.IntDom__c == 'International' && flightDisruption.IntDom == 'Domestic') 
                            || passenger.Event__r.TechDepartureDelayDuration__c > flightDisruption.departureDelay)
                         {
                             isOverrideInfo = true;
                         }
                     }
                 }
                 
                 if(isOverrideInfo){
                     flightDisruption.passengerId = passenger.Passenger__c;
                     flightDisruption.scheduledDepartureDate = passenger.Event__r.ScheduledDepDate__c;
                     flightDisruption.flightNumber = passenger.Event__r.FlightNumber__c;
                     flightDisruption.delayFailureCode = passenger.Event__r.DelayFailureCode__c;
                     flightDisruption.departureDelayLength = passenger.Event__r.DepartureDelayinHRSandMIN__c;
                     flightDisruption.departureDelay = passenger.Event__r.TechDepartureDelayDuration__c;
                     flightDisruption.IntDom = passenger.Event__r.IntDom__c;
                     
                     passengerDisruptionMap.put(passenger.Passenger__c,flightDisruption);
                 }   
             }
         }
        return passengerDisruptionMap; 
    }
    
    public class flightDisruptionWrapper{
        public Id passengerId; // Passenger/Contact Id
        public Integer totalDisruption = 0; // No. Disruptions last 7 days
        public Date scheduledDepartureDate; // Scheduled Departure Date
        public String flightNumber; // Flight Number
        public String delayFailureCode; // Delay Failure Code
        public String departureDelayLength; // Departure Delay Length
        public Double departureDelay; // Departure delay total 
        public String IntDom; // International or Domestic
    }
    /* @description: Check field data type and format field values 
     * @Parameter : sObject Scema, sObject Field, sObject
     */
    public String processFieldValue(Map<String, Schema.SObjectField> sObjectSchema,String fieldName, sObject sObjectRecord){
        String sourceFieldValue = null;
        Schema.SObjectField field = sObjectSchema.get(fieldName);
        Schema.DisplayType fieldType = field.getDescribe().getType();
        system.debug('fieldType : ' + fieldType);
        if(String.valueOf(fieldType) == 'DATETIME'){
            if(string.valueOf(sObjectRecord.get(fieldName)) != NULL){
                Datetime dateTimeValue = (datetime)sObjectRecord.get(fieldName);
                sourceFieldValue = string.valueOf(dateTimeValue.format('dd/MM/yyyy hh:mm a'));   
            }
        }else if(String.valueOf(fieldType) == 'TIME'){
            if(string.valueOf(sObjectRecord.get(fieldName)) != NULL){
                Datetime myDateTime = Datetime.newInstance(Date.today(), (Time)sObjectRecord.get(fieldName));
                sourceFieldValue = myDateTime.format('h:mm a');
            }
        }else if(String.valueOf(fieldType) == 'BOOLEAN'){
            sourceFieldValue = (Boolean.valueOf(sObjectRecord.get(fieldName)) ? 'Yes': 'No');
        }else if(String.valueOf(fieldType) == 'TEXTAREA'){
                sourceFieldValue = string.valueOf(sObjectRecord.get(fieldName));
        }else{
            sourceFieldValue = string.valueOf(sObjectRecord.get(fieldName));
        }
        
        //If there is a value, encapsulate it with "", so CSV file will not execute special character like \n \r or comma.
        if(sourceFieldValue != NULL && sourceFieldValue != ''){ 
            return '"'+sourceFieldValue+'"';
        }
        return sourceFieldValue;
    }
}