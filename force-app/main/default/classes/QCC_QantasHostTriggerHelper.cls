/*----------------------------------------------------------------------------------------------------------------------
Author:			Rafael Escuadra
Company:		Accenture
Description:   	Class used to prevent Qantas Host records duplication
Inputs:			List of QHost records
Test Class:     QCC_QantasHostTriggerHelperTest
************************************************************************************************
History
************************************************************************************************
22-Oct-2019 		Rafael Escuadra 				Add checkQantasHostDuplicate method - prevents duplication of records with duplicate QCC_PNR__c, QCC_Flight_No__c,
													QCC_Departure_Airport__c, QCC_Departure_Local_Date__c, QCC_Flight_Departure_Time__c
12-Nov-2019 		Lora Mae Dapulang				GRAPHITE-1369 - updated the fields used to identify duplicate records
                                                    -	PNR
                                                    -	Flight No
                                                    -	Departure Port
                                                    -	Departure Date
                                                    -	Frequent Flyer No. (if ff num is null; check for First Name and Last Name)
26-Dec-2019			Raymart Tolentino				Refactored the logic to apply the Trigger Framework used by the Accenture team.
                                                    GRAPHITE-1381 Added new logic to send the Online Form Submission notication.
13-Mar-2020      Raymart Tolentino        GRAPHITE-2355 Transfer the logic from PB to trigger
--------------------------------------------------------------------------------------------------------*/
public with sharing class QCC_QantasHostTriggerHelper implements TriggerHelper.Processor {
    public static Map<Id, QCC_First_Host__c> oldRecMap = new Map<Id, QCC_First_Host__c>();

    public void processTrigger(List<QCC_First_Host__c> newRecs, List<QCC_First_Host__c> oldRecs, TriggerHelper.Action triggerAction){
        if (triggerAction == TriggerHelper.Action.AFTERINSERT) {
        }

        if (triggerAction == TriggerHelper.Action.AFTERUPDATE) {
            buildOldRecMap(oldRecs);
            sendSpaBookingStatusNotification(newRecs);
            sendOnlineFormSubmissionNotification(newRecs);
        }

        if (triggerAction == TriggerHelper.Action.BEFOREINSERT) {
            checkQantasHostDuplicate(newRecs);
            convertFirstAndLastNameToTitleCase(newRecs);
        }

        if (triggerAction == TriggerHelper.Action.BEFOREUPDATE) {
            buildOldRecMap(oldRecs);
            checkQantasHostDuplicate(newRecs);
            convertFirstAndLastNameToTitleCase(newRecs);
        }
    }

    /**
*  Description of the purpose of the class method.
*  @name buildOldRecMap
*  @param oldRecs - List of records before any changes gets saved
*  @return <parameter> - <Description about the return parameter>
*  @throws exception-<exception description>
*/
    private static void buildOldRecMap(List<QCC_First_Host__c> oldRecs) {
        for (QCC_First_Host__c oldRec : oldRecs) {
            oldRecMap.put(oldRec.Id, oldRec);
        }
    }

    public static void checkQantasHostDuplicate(List<QCC_First_Host__c> qantasHostList){
        System.debug('>>>checkQantasHostDuplicate');
        System.debug('>>>qantasHostList sizex: '+ qantasHostList.size() );
        System.debug('>>>qantasHostList: '+ qantasHostList);
        try{
            Map<String,Qcc_First_Host__c> qantasHostMap = new Map<String,QCC_First_Host__c>();
            //List<String> pnrList = new List<String>();
            Set<String> pnrSet = new Set<String>();
            Set<String> flightNoSet = new Set<String>();
            Set<String> departurePortSet = new Set<String>();
            Set<Date> departureLocalDateSet = new Set<Date>();
            Set<String> frequentFlyerSet = new Set<String>();
            Set<String> firstNameSet = new Set<String>();
            Set<String> lastNameSet = new Set<String>();

            for(QCC_First_Host__c qantasHost : qantasHostList){
                String qantasHostkey;
                if(!String.isEmpty(qantasHost.QCC_Frequent_Flyer_Number__c)){
                    qantasHostkey  = qantasHost.QCC_PNR__c + qantasHost.QCC_Flight_No__c + qantasHost.QCC_Departure_Airport__c + qantasHost.QCC_Departure_Local_Date__c + qantasHost.QCC_Frequent_Flyer_Number__c;
                }
                else {
                    qantasHostkey  = qantasHost.QCC_PNR__c + qantasHost.QCC_Flight_No__c + qantasHost.QCC_Departure_Airport__c + qantasHost.QCC_Departure_Local_Date__c + qantasHost.QCC_First_Host_First_Name__c.toUpperCase() + qantasHost.QCC_Contact_Lastname__c.toUpperCase();
                }
                System.debug('>>>qantasHostkey: ' + qantasHostkey);

                //show error if inserted list has duplicate records
                if(qantasHostMap.containsKey(qantasHostkey) ){
                    qantasHost.addError('There is already a Qantas Host record with these details');
                }
                qantasHostMap.put(qantasHostkey,qantasHost);
                pnrSet.add(qantasHost.QCC_PNR__c);
                flightNoSet.add(qantasHost.QCC_Flight_No__c);
                departurePortSet.add(qantasHost.QCC_Departure_Airport__c);
                departureLocalDateSet.add(qantasHost.QCC_Departure_Local_Date__c);
                frequentFlyerSet.add(qantasHost.QCC_Frequent_Flyer_Number__c);
                firstNameSet.add(qantasHost.QCC_First_Host_First_Name__c);
                lastNameSet.add(qantasHost.QCC_Contact_Lastname__c);
            }
            System.debug('>>>qantasHostMap: ' + qantasHostMap);

            List<QCC_First_Host__c> qantasHostRecordsList = [
                SELECT Id, QCC_PNR__c, QCC_Flight_No__c, QCC_Departure_Airport__c,
                QCC_Departure_Local_Date__c,QCC_Frequent_Flyer_Number__c,
                QCC_Contact_Lastname__c,  QCC_First_Host_First_Name__c
                FROM QCC_First_Host__c
                WHERE QCC_PNR__c IN: pnrSet
                AND QCC_Flight_No__c IN: flightNoSet
                AND QCC_Departure_Airport__c IN: departurePortSet
                AND QCC_Departure_Local_Date__c IN: departureLocalDateSet
                AND
                (
                    QCC_Frequent_Flyer_Number__c IN: frequentFlyerSet OR
                    (QCC_Contact_Lastname__c IN: lastNameSet AND QCC_First_Host_First_Name__c IN: firstNameSet)
                )
            ];
            System.debug('>>>qantasHostRecordsList: ' + qantasHostRecordsList);

            for(Qcc_First_Host__c qantasHostRecord : qantasHostRecordsList){
                String qantasHostRecordkey;
                if(!String.isEmpty(qantasHostRecord.QCC_Frequent_Flyer_Number__c)){
                    qantasHostRecordkey  = qantasHostRecord.QCC_PNR__c + qantasHostRecord.QCC_Flight_No__c + qantasHostRecord.QCC_Departure_Airport__c + qantasHostRecord.QCC_Departure_Local_Date__c + qantasHostRecord.QCC_Frequent_Flyer_Number__c;
                    System.debug('>>>WITH FF NUM');
                    System.debug('>>>qantasHostRecordkey:' + qantasHostRecordkey);
                }
                else{
                    qantasHostRecordkey  = qantasHostRecord.QCC_PNR__c + qantasHostRecord.QCC_Flight_No__c + qantasHostRecord.QCC_Departure_Airport__c + qantasHostRecord.QCC_Departure_Local_Date__c + qantasHostRecord.QCC_First_Host_First_Name__c.toUpperCase() + qantasHostRecord.QCC_Contact_Lastname__c.toUpperCase();
                    System.debug('>>>NO FF NUM');
                    System.debug('>>>qantasHostRecordkey:' + qantasHostRecordkey);
                }
                System.debug('>>>qantasHostRecordkey:'+qantasHostRecordkey);

                if(qantasHostMap.containsKey(qantasHostRecordkey)){
                    System.debug('>>>qantasHostRecordkey.id: ' + qantasHostMap.get(qantasHostRecordkey).id);
                    System.debug('>>>qantasHostRecord.id: ' + qantasHostRecord.id);


                    if(qantasHostMap.get(qantasHostRecordkey).id != qantasHostRecord.id ){
                        qantasHostMap.get(qantasHostRecordkey).addError('There is already a Qantas Host record with these details');
                    }
                }

                System.debug('>>>qantasHostRecordkey: ' + qantasHostRecordkey);
            }
        }
        catch(Exception ex){
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - prevent Qantas Host Duplicate', 'checkQantasHostDuplicate', 'checkQantasHostDuplicate', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }

    //@Purpose: This method is used send the Online Form Submission notification
    //@input parameters:
    //	1. qantasHostRecords - The records that is currently in batch. (Trigger.New)
    //@return type: None
    public static void sendOnlineFormSubmissionNotification(List<QCC_First_Host__c> qantasHostRecords) {
        System.debug('QCC_QantasHostTriggerHelper.sendOnlineFormSubmissionNotification');
        System.debug('oldRecMap: ' + oldRecMap);
        List<Id> qantasHostIds = new List<Id>();

        List<Id> contactIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            contactIds.add(qantasHostRecord.QCC_First_Host_Contact__c);
        }

        //Get all the Qantas Host information including the Contact information such as Preferred Channel, etc.
        qantasHostRecords = [
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
            CreatedDate, QCC_Online_Form_Submission_Date__c
            FROM QCC_First_Host__c
            WHERE Id IN: qantasHostRecords
        ];

        //Get all the contact records related to the Qantas Host records in the current batch which will be stored as a Map.
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contactRecord : [SELECT Id, SSU__c, QCC_Preferred_Contact_Channel__c, QCC_Qantas_Host_Always_Call__c, Email, QCC_TECH_MobilePhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c, QCC_Travel_Email__c, QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_TravelSMSPhoneCountryCode__c FROM Contact WHERE Id IN: contactIds]) {
            contactMap.put(contactRecord.Id, contactRecord);
        }

        //Get all Qantas Host Templates
        //Note: Setting the limit to avoid hitting the 10k limit on query results
        List<QCC_Qantas_Host_Communication_Template__mdt> qantasHostTemplates = [
            SELECT Id, Order_Sequence__c, Cabin__c, Is_Top_Platinum_One__c, Frequent_Flyer_Tier__c, Tier_Effective_Tier__c,
            Departure_Port__c, Excluded_Flights__c, SMS_Template_API_Name__c, Email_Template_API_Name__c,
            Online_Form_Submission_Email_Template__c, Online_Form_Submission_SMS_Template__c
            FROM QCC_Qantas_Host_Communication_Template__mdt
            ORDER BY Order_Sequence__c
            LIMIT 10000
        ];

        System.debug('qantasHostTemplates: ' + qantasHostTemplates);

        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendSMSMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendEmailMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();

        //Get all Qantas Host records that is required to send the Online Form submission notification Email / SMS.
        for (QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            if (oldRecMap.containsKey(qantasHostRecord.Id)) {
                QCC_First_Host__c oldRecord = oldRecMap.get(qantasHostRecord.Id);
                System.debug('oldRecord: ' + oldRecord);
                System.debug('qantasHostRecord: ' + qantasHostRecord);
                Contact contactRecord = null;

                //Get the contact record related to the current Qantas Host record of the loop.
                if (contactMap.containsKey(qantasHostRecord.QCC_First_Host_Contact__c)) {
                    contactRecord = contactMap.get(qantasHostRecord.QCC_First_Host_Contact__c);
                }

                //Check if the QCC_Online_Form_Submission_Date__c has been changed and not null.
                if (qantasHostRecord.QCC_Online_Form_Submission_Date__c != null && qantasHostRecord.QCC_Online_Form_Submission_Date__c != oldRecord.QCC_Online_Form_Submission_Date__c) {
                    if (
                        contactRecord != null &&
                        (contactRecord.QCC_Preferred_Contact_Channel__c != 'None' && !string.isEmpty(contactRecord.QCC_Preferred_Contact_Channel__c)) &&
                        !contactRecord.QCC_Qantas_Host_Always_Call__c
                    ) {
                        //Get the Qantas Host Communication template to be used
                        QCC_Qantas_Host_Communication_Template__mdt qantasHostTemplate = QCC_UtilityHelper.getQantasHostCommunicationTemplate(qantasHostRecord, qantasHostTemplates);
                        System.debug('qantasHostTemplate: ' + qantasHostTemplate);

                        if (qantasHostTemplate != null) {
                            QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = new QCC_UtilityHelper.QantasHostTemplateWrapper();
                            myWrapper.qantasHostRecord = qantasHostRecord;
                            myWrapper.contactRecord = contactRecord;

                            //Check for the Preferred Channel per Contact record
                            if (contactRecord.QCC_Preferred_Contact_Channel__c == 'Email' && qantasHostTemplate.Online_Form_Submission_Email_Template__c != null) {
                                myWrapper.emailTemplateAPIName = qantasHostTemplate.Online_Form_Submission_Email_Template__c;
                                qantasHostToSendEmailMap.put(qantasHostRecord.Id, myWrapper);
                            } else if (contactRecord.QCC_Preferred_Contact_Channel__c == 'SMS') {
                                //If preferred channel is SMS but SMS Template is null, send Email instead
                                if (qantasHostTemplate.Online_Form_Submission_SMS_Template__c != null) {
                                    myWrapper.emailTemplateAPIName = qantasHostTemplate.Online_Form_Submission_SMS_Template__c;
                                    qantasHostToSendSMSMap.put(qantasHostRecord.Id, myWrapper);
                                } else if (qantasHostTemplate.Online_Form_Submission_Email_Template__c != null) {
                                    myWrapper.emailTemplateAPIName = qantasHostTemplate.Online_Form_Submission_Email_Template__c;
                                    qantasHostToSendEmailMap.put(qantasHostRecord.Id, myWrapper);
                                }
                            }
                        }
                    }
                }
            }
        }

        System.debug('>>>qantasHostToSendEmailMap: ' + qantasHostToSendEmailMap);
        System.debug('>>>qantasHostToSendSMSMap: ' + qantasHostToSendSMSMap);

        //Send the Email if map is not empty.
        if (!qantasHostToSendEmailMap.isEmpty()) {
            QCC_UtilityHelper.sendQantasHostEmail(qantasHostToSendEmailMap);
        }
        
        //Send the Email if map is not empty.
        if (!qantasHostToSendSMSMap.isEmpty()) {
            QCC_UtilityHelper.sendQantasHostSMS(qantasHostToSendSMSMap, 'Online Form Submission');
        }
    }
        
    //@Purpose: This method is used send the Spa bookings status notification
    //@input parameters:
    //	1. qantasHostRecords - The records that is currently in batch. (Trigger.New)
    //@return type: None
    public static void sendSpaBookingStatusNotification(List<QCC_First_Host__c> qantasHostRecords) {
        System.debug('QCC_QantasHostTriggerHelper.sendSpaBookingStatusNotification');
        System.debug('oldRecMap: ' + oldRecMap);
        List<Id> qantasHostIds = new List<Id>();
        
        List<Id> contactIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            contactIds.add(qantasHostRecord.QCC_First_Host_Contact__c);
        }
        
        //Get all the Qantas Host information including the Contact information such as Preferred Channel, etc.
        qantasHostRecords = [
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
            CreatedDate, QCC_Online_Form_Submission_Date__c,
            QCC_Spa_Booking_Status__c,
            QCC_Spa_Booking_Time__c,
            QCC_Spa_Request_Outcome__c,
            QCC_Qantas_First_Spa_Lounge__c,
            QCC_First_Host_First_Name__c,
            QCC_Preferred_Contact_Channel__c
            FROM QCC_First_Host__c 
            WHERE Id IN: qantasHostRecords
        ];
        
        //Get all the contact records related to the Qantas Host records in the current batch which will be stored as a Map.
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact contactRecord : [SELECT Id, SSU__c, QCC_Preferred_Contact_Channel__c, QCC_Qantas_Host_Always_Call__c, Email, QCC_TECH_MobilePhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c, QCC_Travel_Email__c, QCC_Travel_SMS__c, QCC_Travel_Country_Code__c, QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_TravelSMSPhoneCountryCode__c FROM Contact WHERE Id IN: contactIds]) {
            contactMap.put(contactRecord.Id, contactRecord);
        }
        
        //Get all Qantas Host Templates
        //Note: Setting the limit to avoid hitting the 10k limit on query results
        List<QCC_Spa_Booking_Comms__mdt> qantasHostTemplates = [
            SELECT Id, DeveloperName, MasterLabel, Preffered_Contact_Method__c, Spa_Booking_Status__c, Template_Name__c
            FROM QCC_Spa_Booking_Comms__mdt
            LIMIT 10000
        ];
        
        System.debug('qantasHostTemplates: ' + qantasHostTemplates);
        
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendSMSMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendEmailMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        List<QCC_First_Host__c> qantasHostRecordsList = new List<QCC_First_Host__c>();
        
        //Get all Qantas Host records that is required to send the Spa booking notification Email / SMS.
        for (QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            if (oldRecMap.containsKey(qantasHostRecord.Id)) {
                QCC_First_Host__c oldRecord = oldRecMap.get(qantasHostRecord.Id);
                System.debug('oldRecord: ' + oldRecord);
                System.debug('qantasHostRecord: ' + qantasHostRecord);
                Contact contactRecord = null;
                
                //Get the contact record related to the current Qantas Host record of the loop.
                if (contactMap.containsKey(qantasHostRecord.QCC_First_Host_Contact__c)) {
                    contactRecord = contactMap.get(qantasHostRecord.QCC_First_Host_Contact__c);
                }
                
                //Check if the QCC_Spa_Request_Outcome__c has been changed, not null and is 'Sending' value.
                if (qantasHostRecord.QCC_Spa_Request_Outcome__c == 'Sending' && qantasHostRecord.QCC_Spa_Request_Outcome__c != oldRecord.QCC_Spa_Request_Outcome__c) {
                    if (contactRecord != null) {
                        //Get the Qantas Spa Booking Communication template to be used
                        String qantaSpaBookingTemplateName = QCC_UtilityHelper.getSpaBookingCommsTemplate(qantasHostRecord, qantasHostTemplates);
                        System.debug('qantaSpaBookingTemplateName: ' + qantaSpaBookingTemplateName);
                        
                        if (qantaSpaBookingTemplateName != null) {
                            QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = new QCC_UtilityHelper.QantasHostTemplateWrapper();
                            myWrapper.qantasHostRecord = qantasHostRecord;
                            myWrapper.contactRecord = contactRecord;
                            myWrapper.emailTemplateAPIName = qantaSpaBookingTemplateName;
                            
                            //Check for the Preferred Channel per Contact record
                            if (contactRecord.QCC_Preferred_Contact_Channel__c == 'SMS' && (contactRecord.QCC_Travel_SMS__c != null || contactRecord.Phone != null)) { // CRM 5762
                                qantasHostToSendSMSMap.put(qantasHostRecord.Id, myWrapper);
                            } else if(contactRecord.QCC_Preferred_Contact_Channel__c != 'SMS' && (contactRecord.QCC_Travel_Email__c != null || contactRecord.Email != null)) {
                                qantasHostToSendEmailMap.put(qantasHostRecord.Id, myWrapper);
                            } else{ //if there is a contact but no phone number or email
                                qantasHostRecord.QCC_Spa_Request_Outcome__c = 'Failed to Send';
                                qantasHostRecordsList.add(qantasHostRecord);
                                }
                        } else {
                            // If there is a contact but no retrieved template, update outcome to Failed to Send
                            qantasHostRecord.QCC_Spa_Request_Outcome__c = 'Failed to Send';
                            qantasHostRecordsList.add(qantasHostRecord);    
                        }
                    } else {
                        // If there is no retrieved contact or QCC_Qantas_Host_Always_Call__c field is true, update
                        // outcome to Failed to Send
                        qantasHostRecord.QCC_Spa_Request_Outcome__c = 'Failed to Send';
                       qantasHostRecordsList.add(qantasHostRecord);
                    }
                }
            }
        }
        
        System.debug('>>>qantasHostToSendEmailMap: ' + qantasHostToSendEmailMap);
        System.debug('>>>qantasHostToSendSMSMap: ' + qantasHostToSendSMSMap);
        
        //Send the Email if map is not empty.
        if (!qantasHostToSendEmailMap.isEmpty()) {
            Messaging.SendEmailResult[] result = QCC_UtilityHelper.sendQantasHostEmail(qantasHostToSendEmailMap);

            Set<Id> targetIdsFailed = new Set<Id>();
            for(Messaging.SendEmailResult rr:result){
                if(!rr.isSuccess()){
                    System.debug('Email result: ' + rr);
                    Messaging.SendEmailError[] errArr = rr.getErrors();
                    targetIdsFailed.add(errArr[0].getTargetObjectId());
                } 
            }
            
            for(QCC_UtilityHelper.QantasHostTemplateWrapper wrapper: qantasHostToSendEmailMap.values()){
                if(targetIdsFailed.contains(wrapper.qantasHostRecord.Id)){
                    wrapper.qantasHostRecord.QCC_Spa_Request_Outcome__c = 'Failed to Send';
                } else{
                    wrapper.qantasHostRecord.QCC_Spa_Request_Outcome__c = 'Sent';
                }
                qantasHostRecordsList.add(wrapper.qantasHostRecord);
            }
        }
        
        //Send the Email if map is not empty.
        if (!qantasHostToSendSMSMap.isEmpty()) {
            System.debug('spa booking send SMS');
            QCC_UtilityHelper.sendQantasHostSMS(qantasHostToSendSMSMap, 'Spa Booking Status');
        }
                
        if (!qantasHostRecordsList.isEmpty()) {
            update qantasHostRecordsList;
        }
    }

    //GRAPHITE-2355 Transfer the logic from QCC_QantasHostCorrectNameCapitalization process builder to trigger
    public static void convertFirstAndLastNameToTitleCase(List<QCC_First_Host__c> qantasHostRecords) {
        System.debug('QCC_QantasHostTriggerHelper.convertFirstAndLastNameToTitleCase');
        //This contains the regex we will use to split the name fields to convert in title case format.
        String delimiter = Label.QCC_QantasHostUpdateNameREGEX;
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            String firstName = '';
            if (qantasHostRecord.QCC_First_Host_First_Name__c != NULL && qantasHostRecord.QCC_First_Host_First_Name__c != '') {
            for(String splittedName : qantasHostRecord.QCC_First_Host_First_Name__c.split(delimiter)) {
                String titleCaseWord = splittedName.toLowerCase().capitalize();
                Integer tempLength = firstName.length();
                firstName = firstName == '' ? titleCaseWord : firstName + qantasHostRecord.QCC_First_Host_First_Name__c.substring(tempLength, tempLength + 1) + titleCaseWord;
            }
        }

            String lastName = '';
            if (qantasHostRecord.QCC_Contact_Lastname__c != NULL && qantasHostRecord.QCC_Contact_Lastname__c != '') {
            for(String splittedName : qantasHostRecord.QCC_Contact_Lastname__c.split(delimiter)) {
                String titleCaseWord = splittedName.toLowerCase().capitalize();
                Integer tempLength = lastName.length();
                lastName = lastName == '' ? titleCaseWord : lastName + qantasHostRecord.QCC_Contact_Lastname__c.substring(tempLength, tempLength + 1) + titleCaseWord;
            }
        }
			
            if(firstName != null) {
                List<String> fName = firstName.split(' ');
            	qantasHostRecord.QCC_First_Host_First_Name__c = fName.remove(0);
            }
            qantasHostRecord.QCC_Contact_Lastname__c = lastName;
        }
    }
}