/*********************************************************************************
Name         : QCC_QantasHostCommunication
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 21 October 2019
Usages       : This will determine whether the Qantas Host message will be sent as Email or SMS
******************************************************1***************************
Date			Company		Name                Purpose
20 Nov 2019 	Accenture 	Rafael Escuadra		GRAPHITE-1370 Update logic for Qantas Host Always Call
23 Jan 2020 	Accenture 	Lora Mae Dapulang   GRAPHITE-1820 Update the SOQL for QCC_Qantas_Host_Communication_Template__mdt to query only the records where Active__c = TRUE
*********************************************************************************/

public class QCC_QantasHostCommunication {
    //@Purpose: This method will generate the template and check the preferred channel of the customer
    //@input parameters:
    //	-qantasHostList - The list of records to be processed
    //@return type: None
    public static void getQantasHostTemplateByContactPreference(List<Id> qantasHostIds) {
        System.debug('>>>QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference');
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendSMSMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendEmailMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        List<Qcc_First_Host__c> qantasRecordsToCreateCase = new List<Qcc_First_Host__c>();
        
        List<QCC_First_Host__c> qantasHostRecords = [
            SELECT Id, QCC_Cabin__c, QCC_First_Host_Contact__c, 
            QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c, 
            QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c, 
            QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c, 
            QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c, 
            QCC_Departure_Airport__c, QCC_Carrier_Code__c, QCC_Flight_No__c, 
            QCC_First_Host_Contact__r.QCC_Preferred_Contact_Channel__c, 
            QCC_First_Host_Contact__r.QCC_TECH_TravelSMSPhoneCountryCode__c, 
            QCC_First_Host_Contact__r.QCC_TECH_TravelSMSPhoneNumber__c, 
            QCC_First_Host_Contact__r.QCC_Travel_Email__c,
            QCC_Departure_Airport_Code__r.Name,
            CreatedDate, QCC_TECH_Comms_Sending_Date__c,
            QCC_TECH_CONX_Parent_Id__c
            FROM QCC_First_Host__c 
            WHERE Id IN: qantasHostIds
        ];
        
        System.debug('qantasHostRecords: ' + qantasHostRecords);
        
        //Get all contact records
        List<Id> contactIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            contactIds.add(qantasHostRecord.QCC_First_Host_Contact__c);
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contactRecord : [SELECT Id, SSU__c, Email, QCC_TECH_MobilePhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c, QCC_Travel_Email__c, QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_TravelSMSPhoneCountryCode__c FROM Contact WHERE Id IN: contactIds]) {
            contactMap.put(contactRecord.Id, contactRecord);
        }
        
        //Get all Qantas Host Templates
        //Note: Setting the limit to avoid hitting the 10k limit on query results
        List<QCC_Qantas_Host_Communication_Template__mdt> qantasHostTemplates = [
            SELECT Id, Order_Sequence__c, Cabin__c, Is_Top_Platinum_One__c, Frequent_Flyer_Tier__c, Tier_Effective_Tier__c, 
            Departure_Port__c, Excluded_Flights__c, SMS_Template_API_Name__c, Email_Template_API_Name__c, Active__c
            FROM QCC_Qantas_Host_Communication_Template__mdt
            WHERE Active__c = TRUE
            ORDER BY Order_Sequence__c
            LIMIT 10000
        ];
        
        System.debug('qantasHostTemplates: ' + qantasHostTemplates);
        
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            System.debug('>>>qantasHostRecord: ' + qantasHostRecord);
            //GRAPHITE-2185 Check for QCC_TECH_CONX_Parent_Id__c and QCC_TECH_Comms_Sending_Date__c
            //If QCC_TECH_CONX_Parent_Id__c is null, this mean that the current Qantas Host record is not a connecting flight
            //If QCC_TECH_Comms_Sending_Date__c is null, this mean that the comms was not yet sent.
            if (qantasHostRecord.QCC_TECH_CONX_Parent_Id__c == null && qantasHostRecord.QCC_TECH_Comms_Sending_Date__c == null) {
                if (
                    qantasHostRecord.QCC_First_Host_Contact__c != null &&
                    (qantasHostRecord.QCC_First_Host_Contact__r.QCC_Preferred_Contact_Channel__c != 'None' && !string.isEmpty(qantasHostRecord.QCC_First_Host_Contact__r.QCC_Preferred_Contact_Channel__c)) &&
                    (!qantasHostRecord.QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c || (qantasHostRecord.QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c &&  (qantasHostRecord.QCC_Departure_Airport_Code__r.Name != 'MEL' && qantasHostRecord.QCC_Departure_Airport_Code__r.Name != 'SYD')))
                ) {
                    //Get the Qantas Host Communication template to be used
                    QCC_Qantas_Host_Communication_Template__mdt qantasHostTemplate = QCC_UtilityHelper.getQantasHostCommunicationTemplate(qantasHostRecord, qantasHostTemplates);
                    System.debug('qantasHostTemplate: ' + qantasHostTemplate);

                    if (qantasHostTemplate != null) {
                        QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = new QCC_UtilityHelper.QantasHostTemplateWrapper();
                        myWrapper.qantasHostRecord = qantasHostRecord;
                        if (contactMap.containsKey(qantasHostRecord.QCC_First_Host_Contact__c)) {
                            myWrapper.contactRecord = contactMap.get(qantasHostRecord.QCC_First_Host_Contact__c);
                        }

                        //Check for the Preferred Channel per Contact record
                        if (qantasHostRecord.QCC_First_Host_Contact__r.QCC_Preferred_Contact_Channel__c == 'Email' && qantasHostTemplate.Email_Template_API_Name__c != null) {
                            myWrapper.emailTemplateAPIName = qantasHostTemplate.Email_Template_API_Name__c;
                            qantasHostToSendEmailMap.put(qantasHostRecord.Id, myWrapper);
                        } else if (qantasHostRecord.QCC_First_Host_Contact__r.QCC_Preferred_Contact_Channel__c == 'SMS') {
                            //If preferred channel is SMS but SMS Template is null, send Email instead
                            if (qantasHostTemplate.SMS_Template_API_Name__c != null) {
                                myWrapper.emailTemplateAPIName = qantasHostTemplate.SMS_Template_API_Name__c;
                                qantasHostToSendSMSMap.put(qantasHostRecord.Id, myWrapper);
                            } else if (qantasHostTemplate.Email_Template_API_Name__c != null) {
                                myWrapper.emailTemplateAPIName = qantasHostTemplate.Email_Template_API_Name__c;
                                qantasHostToSendEmailMap.put(qantasHostRecord.Id, myWrapper);
                            }
                        }
                    }
                } else {
                    //GRAPHITE-958 Get all Qantas Host record id for case creation
                    //check if it has Contact and if contact opted to be always called
                    if(qantasHostRecord.QCC_First_Host_Contact__c != null){
                        if(qantasHostRecord.QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c == TRUE && (qantasHostRecord.QCC_Departure_Airport_Code__r.Name == 'MEL' || qantasHostRecord.QCC_Departure_Airport_Code__r.Name == 'SYD') ){
                            qantasRecordsToCreateCase.add(qantasHostRecord);
                        }
                    }
                }
            }
        }
        
        System.debug('>>>qantasHostToSendEmailMap: ' + qantasHostToSendEmailMap);
        System.debug('>>>qantasHostToSendSMSMap: ' + qantasHostToSendSMSMap);
        
        //Send the Email if map is not empty.
        if (!qantasHostToSendEmailMap.isEmpty()) {
            List<QCC_First_Host__c> qantasHostRecordsToUpdate = new List<QCC_First_Host__c>();
            Messaging.SendEmailResult[] sendEmailResults = QCC_UtilityHelper.sendQantasHostEmail(qantasHostToSendEmailMap);

            Set<Id> targetIdsFailed = new Set<Id>();
            Integer recordCounter = 0;
            for(Messaging.SendEmailResult sendEmailResult : sendEmailResults){
                if(sendEmailResult.isSuccess()){
                    List<String> qantasHostEmailIds = new List<String>();
                    for(String qantasHostId : qantasHostToSendEmailMap.keySet()) {
                        qantasHostEmailIds.add(qantasHostId);
                    }
                    Id recordId = qantasHostEmailIds[recordCounter];
                    System.debug('Success recordId: ' + recordId);
                    if (qantasHostToSendEmailMap.containsKey(recordId)) {
                        QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = qantasHostToSendEmailMap.get(recordId);
                        QCC_First_Host__c qantasHostRecordToUpdate = myWrapper.qantasHostRecord;
                        qantasHostRecordToUpdate.QCC_TECH_Comms_Sending_Date__c = System.now();
                        qantasHostRecordsToUpdate.add(qantasHostRecordToUpdate);
                    }
                }
                recordCounter++;
            }

            if (!qantasHostRecordsToUpdate.isEmpty()) {
                update qantasHostRecordsToUpdate;
            }
        }
        
        //Boolean isOfficeHours = QCC_UtilityHelper.checkIfOfficeHours(Integer.valueOf(Label.QCC_Qantas_Host_Office_Start), Integer.valueOf(Label.QCC_Qantas_Host_Office_Start));
        Boolean isOfficeHours = QCC_UtilityHelper.checkIfWithinBusinessHours('QCC Qantas Host SMS', System.now());
        //Send the Email if map is not empty.
        if (!qantasHostToSendSMSMap.isEmpty()) {
            if (isOfficeHours) {
                QCC_UtilityHelper.sendQantasHostSMS(qantasHostToSendSMSMap, 'Qantas Host Communication Matrix');
            } else {
                List<QCC_First_Host__c> qantasHostRecordsToUpdate = new List<QCC_First_Host__c>();
                for(Id contactId : qantasHostToSendSMSMap.keySet()) {
                    QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = qantasHostToSendSMSMap.get(contactId);
                    QCC_First_Host__c qantasHostRecordToUpdate = myWrapper.qantasHostRecord;
                    qantasHostRecordToUpdate.QCC_TECH_SMS_Need_To_Send__c = true;
                    qantasHostRecordsToUpdate.add(qantasHostRecordToUpdate);
                }
                
                if (!qantasHostRecordsToUpdate.isEmpty()) {
                    update qantasHostRecordsToUpdate;
                }
            }
        }
        
        //GRAPHITE-958 Create case Qantas Always Call 
        if(!qantasRecordsToCreateCase.isEmpty()){
            qantasRecordstoCreateCase(qantasRecordsToCreateCase);
        }
    }
    
    //GRAPHITE-958 
    //Create case for Qantas Host with contact who opted to receive a call (QCC_Qantas_Host_Always_Call__c = TRUE) instead of email or text 
    public static void qantasRecordstoCreateCase(List<Qcc_First_Host__c> qantasHostRecords){
        System.debug('>>>QCC_QantasHostCommunication.qantasRecordstoCreateCase');
        try{
            
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QCC Elite Process').getRecordTypeId();
            String conditionClause = ' WHERE Module_Name__c =  \'Case Always Call\'';
            List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords ('QCC_Source_to_Target_Object_Mapping__mdt', conditionClause);
            system.debug('>>>metaObjects: ' + metaObjects);
            
            //Create new case records using QCC Source to Target Object Mappings: Case_QH_Always_Call metadata
            List<sObject> newCaseRecords = QCC_UtilityHelper.transformSourceToTargetObjects('Case Always Call', qantasHostRecords,metaObjects , 'Case', recordTypeId, null);
            
            System.debug('>>>newCaseRecords: '+newCaseRecords);
            if(!newCaseRecords.isEmpty()){
                //insert newCaseRecords;
                Database.SaveResult[] saveResultList = Database.insert(newCaseRecords, false);
                //Create the log record for those save result that fails
                QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC Loyalty Status Event - Create Always Call Case', 'QCC_QantasHostCommunication', '');
                
            }
        }catch(Exception ex){
            System.debug('>>>exception: '+ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC Qantas Host - Create Case', 'QCC_QantasHostCommunication', 'createCaseForContactWithAlwaysCall', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }
}