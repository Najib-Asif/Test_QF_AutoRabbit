/*********************************************************************************
Name         : QCC_LoyaltyStatusEventSendSMSInvocable
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 9 September 2019
Usages       : This class is used to send the SMS message when the customer reached a certain value of Status Credits field.
*********************************************************************************/
public class QCC_LoyaltyStatusSendSMSInvocable {
    //@Purpose: This method is used to send the Loyalty Status SMS to the customer.
    //@input parameters:
    //	1. contactRecords - The contact records being created or updated.
    //@return type: None
    @InvocableMethod
    public static void processLoyaltyStatusSMSSending(List<Contact> contactRecords) {
        System.debug('QCC_LoyaltyStatusSendSMSInvocable.processLoyaltyStatusSMSSending');
        System.debug('contactRecords: ' + contactRecords);

        List<Id> contactIds = new List<Id>();
        for(Contact contactRecord : contactRecords) {
            contactIds.add(contactRecord.Id);
        }

        QCC_SOQL_Setting__mdt customMetadataRecord = QCC_UtilityHelper.getSOQLSettingRecordByModuleName('Loyalty Status Event Send SMS');
        System.debug('customMetadataRecord: ' + customMetadataRecord);

        //Check if the current time is within the office hours.
        Boolean isOfficeHours = QCC_UtilityHelper.checkIfWithinBusinessHours('QCC Loyalty Bonus SMS', System.now());
        System.debug('isOfficeHours: ' + isOfficeHours);

        if (isOfficeHours && customMetadataRecord != null) {
            //Get all needed values from contact records
            String queryString = customMetadataRecord.Query_String__c + ' AND Id IN: contactIds';
            contactRecords = Database.query(queryString);
            System.debug('contactRecords: ' + contactRecords);

            if (!contactRecords.isEmpty()) {
                //Get all Loyalty Status SMS Setting records
                List<QCC_Loyalty_Status_SMS_Setting__mdt> smsSettingRecords = [
                    SELECT Id, Point_Type__c, Template_Name__c,
                    Case_Template_Developer_Name__c, Contact_Field_Name__c
                    FROM QCC_Loyalty_Status_SMS_Setting__mdt
                ];
                System.debug('smsSettingRecords: ' + smsSettingRecords);

                Map<String, QCC_Loyalty_Status_SMS_Setting__mdt> smsSettingMap = new Map<String, QCC_Loyalty_Status_SMS_Setting__mdt>();

                //List all source to target module names
                List<String> sourceToTargetModuleNames = new List<String>();

                //List all email template names
                Set<String> emailTemplateNames = new Set<String>();

                for(QCC_Loyalty_Status_SMS_Setting__mdt smsSettingRecord : smsSettingRecords) {
                    smsSettingMap.put(smsSettingRecord.Point_Type__c, smsSettingRecord);
                    sourceToTargetModuleNames.add(smsSettingRecord.Point_Type__c);
                    emailTemplateNames.add(smsSettingRecord.Template_Name__c);
                }

                System.debug('smsSettingMap: ' + smsSettingMap);
                System.debug('sourceToTargetModuleNames: ' + sourceToTargetModuleNames);
                System.debug('emailTemplateNames: ' + emailTemplateNames);

                //Get all Source To Target records that will be used for PB50K and PB75K
                Map<String,List<sObject>> sourceToTargetMapPerModule = QCC_UtilityHelper.getSourceToTargetRecordsByModuleNames(sourceToTargetModuleNames);
                System.debug('sourceToTargetMapPerModule: ' + sourceToTargetMapPerModule);

                //Get all the email template that will be used
                Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
                for(EmailTemplate emailTemp : [SELECT Id,Developername,HtmlValue,Subject FROM EmailTemplate WHERE Developername IN: emailTemplateNames]){
                    emailTemplateMap.put(emailTemp.Developername,emailTemp);
                }

                System.debug('emailTemplateMap: ' + emailTemplateMap);

                //Generate the SMS Wrapper that will be used to send the SMS per contact record.
                List<SendSMSWrapper> sendSMSWrapperList = new List<SendSMSWrapper>();

                //Generate the wrapper per contact.
                for(Contact contactRecord : contactRecords) {
                    if (smsSettingMap.containsKey(contactRecord.QCC_TECH_Loyalty_Point_Type__c)) {
                        QCC_Loyalty_Status_SMS_Setting__mdt smsSettingRecord = smsSettingMap.get(contactRecord.QCC_TECH_Loyalty_Point_Type__c);
                        SendSMSWrapper sendSMSWrapper = new SendSMSWrapper();
                        sendSMSWrapper.contactId = contactRecord.Id;
                        sendSMSWrapper.contactRecord = contactRecord;
                        sendSMSWrapper.caseRecord = generateCaseRecord(sourceToTargetMapPerModule, contactRecord);

                        Id emailTemplateId = null;
                        if (emailTemplateMap.containsKey(smsSettingRecord.Template_Name__c)) {
                            emailTemplateId = emailTemplateMap.get(smsSettingRecord.Template_Name__c).Id;
                        }
                        Messaging.SingleEmailMessage currentMessage = QCC_UtilityHelper.generateSMSBodyFromEmailTemplate(contactRecord.Id, emailTemplateId, null);
                        sendSMSWrapper.messageBody = currentMessage.getPlainTextBody();
                        sendSMSWrapper.taskRecord = QCC_UtilityHelper.generateTaskRecordFromEmailMessage(contactRecord, currentMessage, null);

                        System.debug('sendSMSWrapper: ' + sendSMSWrapper);
                        sendSMSWrapperList.add(sendSMSWrapper);
                    }
                }
                System.debug('sendSMSWrapperList: ' + sendSMSWrapperList);

                if (!sendSMSWrapperList.isEmpty()) {
                    String jsonData = JSON.serialize(sendSMSWrapperList);
                    QCC_LoyaltyStatusSendSMSQueueable queueableJob = new QCC_LoyaltyStatusSendSMSQueueable();
                    queueableJob.sendSMSWrapperString = jsonData;

                    System.enqueueJob(queueableJob);
                }
            }
        }
    }

    //@Purpose: This method is used to generate a case record
    //@input parameters:
    //	1. sourceToTargetRecords - The metadata record to create the case record.
    //	2. contactRecord - The related contact for the case record.
    //@return type: Case record to be inserted after the SMS has been sent successfully.
    public static Case generateCaseRecord(Map<String,List<sObject>> sourceToTargetRecords, Contact contactRecord) {
        System.debug('QCC_LoyaltyStatusSendSMSInvocable.generateCaseRecord');

        List<sObject> sourceRecords = new List<sObject>();
        sourceRecords.add(contactRecord);

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QCC_Elite_Process').getRecordTypeId();

        Case newCaseRecord = new Case();
        if (sourceToTargetRecords.containsKey(contactRecord.QCC_TECH_Loyalty_Point_Type__c)) {
            List<sObject> newRecords = QCC_UtilityHelper.transformSourceToTargetObjects (
                contactRecord.QCC_TECH_Loyalty_Point_Type__c,
                sourceRecords,
                sourceToTargetRecords.get(contactRecord.QCC_TECH_Loyalty_Point_Type__c),
                'Case',
                recordTypeId,
                null
            );
            System.debug('newRecords: ' + newRecords);


            if (!newRecords.isEmpty()) {
                for (sObject newRecord : newRecords) {
                    newCaseRecord = (Case)newRecord;
                    break;
                }
            }
        }

        return newCaseRecord;
    }

    //Wrapper class to send the actual callout and insert the task and record upon success and also updates the contact record.
    public class SendSMSWrapper {
        public Id contactId;
        public Task taskRecord;
        public Contact contactRecord;
        public Case caseRecord;
        public String messageBody;
    }

    //Wrapper class holding all the data needed to send the SMS.
    public class LoyaltyMessageWrapper {
        public String countryCode;
        public String mobileNumber;
        public String message;
        public String senderName;
    }

    //Wrapper class that will be populated by the flow to pass multiple parameters in the invocable method.
    public class LoyaltySMSWrapper {
        @InvocableVariable public Contact contactRecord;
        @InvocableVariable public Decimal statusCreditQantas;
        @InvocableVariable public Decimal statusCreditJetstar;
    }
}