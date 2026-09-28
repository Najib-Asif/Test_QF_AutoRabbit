/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 04-19-2024
 * @last modified by  : Praveen Sampath
 * Test class : EmailMessageOthersTriggerHandlerTest, EmailMessageQCCTriggerHandlerTest, EmailMessageFreightTriggerHandlerTest
**/
public class EmailMessageTriggerHandler extends TriggerHandler {
    private Map<Id, EmailMessage> newEmailMessageMap;
    private Map<Id, EmailMessage> oldEmailMessageMap;
    private List<EmailMessage> newEmailMessageList;
    private List<EmailMessage> oldEmailMessageList;
    private Map<String, Map<String, Id>> buToRecordTypeMap;

    private static final String BU_QCC = CustomSettingsUtilities.getConfigDataMap('BusinessUnitQCC');
    private static final String BU_FREIGHT = CustomSettingsUtilities.getConfigDataMap('BusinessUnitFreight');
    private static final User LOGGEDINUSERINFO = [ SELECT Id, Location__c FROM User WHERE Id = :UserInfo.getUserId() ];
    private static final String STATUS_CLOSED_CASE = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String RM_AUTOCLOSED_CASE = CustomSettingsUtilities.getConfigDataMap('CaseResolutionMethod_AutoClosed');
    private static final String REASON_CLOSE_CASE = CustomSettingsUtilities.getConfigDataMap('CaseCloseReason');
    private static final String TYPE_INSURANCELETTER_CASE = CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type');
    private static final String TYPE_CCCINSURANCELETTER_CASE = CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType');
    private static final List<Group> groupRecList = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue'];

    public EmailMessageTriggerHandler() {
        this.newEmailMessageMap = (Map<Id, EmailMessage>) Trigger.newMap;
        this.oldEmailMessageMap = (Map<Id, EmailMessage>) Trigger.oldMap;
        this.newEmailMessageList = (List<EmailMessage>) Trigger.new;
        this.oldEmailMessageList = (List<EmailMessage>) Trigger.old;
        this.buToRecordTypeMap = CaseUtility.mapBUnitToCaseRecordTypes();
        /*
        //Max Loop Count for the Case Trigger
        Integer loopCount = (CustomSettingsUtilities.getConfigDataMap('EmailTriggerLoopCount') != null && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap('EmailTriggerLoopCount')))? Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('EmailTriggerLoopCount')) : 2;
        this.setMaxLoopCount(loopCount);
        */
    }

    public override void beforeInsert() {
        try {
            Map<String, Id> qccRecordTypeMap = buToRecordTypeMap.get(BU_QCC);
            Map<String, Id> freightRecordTypeMap = buToRecordTypeMap.get(BU_FREIGHT);
            Map<String, Id> queueMap = fetchCaseQueueInfo();
            Set<Id> qccRecordTypeIds = new Set<Id>();
            Set<Id> freightRecordTypeIds = new Set<Id>();
            Map<Id, Case> caseMap;
            Map<Id, EmailMessage> qccEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> qccEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> qccCaseMap = new Map<Id, Case>();
            Map<Id, EmailMessage> freightEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> freightEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> freightCaseMap = new Map<Id, Case>();
            Map<Id, EmailMessage> otherEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> otherEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> otherCaseMap = new Map<Id, Case>();
            Case caseRecord;
            if (qccRecordTypeMap != null) {
                qccRecordTypeIds = new Set<Id>(qccRecordTypeMap.values());
            }
            if (freightRecordTypeMap != null) {
                freightRecordTypeIds = new Set<Id>(freightRecordTypeMap.values());
            }
            caseMap = fetchCases(newEmailMessageList);
            for (EmailMessage emRecord : newEmailMessageList) {
                if(String.isNotBlank(emRecord.To_Address__c)) {
                    emRecord.ToAddress =emRecord.To_Address__c;
                    //emRecord.BccAddress = emRecord.To_Address__c;
                } else if (String.isNotBlank(emRecord.To_Addresss__c)) { 
                    emRecord.ToAddress =emRecord.To_Addresss__c;
                }
                caseRecord = caseMap.get(emRecord.ParentId);
                if (caseRecord != null) {
                    if (qccRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        qccEmailMessageMap.put(emRecord.Id, emRecord);
                        qccEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        qccCaseMap.put(caseRecord.Id, caseRecord);
                    } else if (freightRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        freightEmailMessageMap.put(emRecord.Id, emRecord);
                        freightEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        freightCaseMap.put(caseRecord.Id, caseRecord);
                    } else {
                        otherEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                    }
                }
            }
            if (!qccEmailMessageMap.isEmpty()) {
                EmailMessageQCCTriggerHandler.beforeInsert(qccEmailMessageMap.values(), qccCaseMap);
            }
            if (!freightEmailMessageMap.isEmpty()) {
                EmailMessageFreightTriggerHandler.onBeforeInsert(freightEmailMessageMap.values(), freightCaseMap);
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageTriggerHandler', 
                'beforeInsert', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }

    public override void afterInsert() {
        try {
            Set<Id> otherRTAccountIds = new Set<Id>();
            //CCC_Complaints;CCC_Baggage;CCC_Further_Action_Required;QCC_Insurance_Letter_Case;CCC_Query;CCC_Medical
            String qccRecordTypesforAcknowledgementEmail = Label.QCC_RecordTypes_for_Acknowledgement_email;
            Map<String, Id> qccRecordTypeMap = buToRecordTypeMap.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitQCC'));
            Map<String, Id> freightRecordTypeMap = buToRecordTypeMap.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitFreight'));
            Map<Id, Case> qccOutboundcasesTobeActionedMap = new Map<Id, Case>();
            Map<Id, Integer> qccCaseIdEmailCountMap = new Map<Id, Integer>();
            Map<Id, Id> qccOutboundCaseEmailMap = new Map<Id, Id>();
            Map<String, Id> queueMap = fetchCaseQueueInfo();
            List<Id> qccOwnerIds = new List<Id>();
            Set<Id> qccRecordTypeIds = new Set<Id>();
            Set<Id> freightRecordTypeIds = new Set<Id>();
            Set<Id> freightAccountIds = new Set<Id>();
            Set<Id> freightCreatedByIds = new Set<Id>();
            Map<Id, Case> caseMap;
            Map<Id, EmailMessage> qccEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> qccEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> qccCaseMap = new Map<Id, Case>();
            Map<Id, EmailMessage> freightEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> freightEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> freightCaseMap = new Map<Id, Case>();
            List<EmailMessage> otherEmailMessages = new List<EmailMessage>();
            Map<Id, Case> otherCaseMap = new Map<Id, Case>();
            Map<Id, String> qccRecordIdNameMap = new Map<Id, String>();
            Set<String> setDomainName = new Set<String>();
            String emailDomain;
            Case caseRecord;
            
            if (qccRecordTypeMap != null) {
                qccRecordTypeIds = new Set<Id>(qccRecordTypeMap.values());
                for (String devName : qccRecordTypeMap.keySet()) {
                    qccRecordIdNameMap.put(qccRecordTypeMap.get(devName), devName);
                }
            }
            if (freightRecordTypeMap != null) {
                freightRecordTypeIds = new Set<Id>(freightRecordTypeMap.values());
            }
           
            caseMap = fetchCases(newEmailMessageList);
           
            for (EmailMessage emRecord : newEmailMessageList) {
                caseRecord = caseMap.get(emRecord.ParentId);
                if (caseRecord != null) {
                    if (qccRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        qccEmailMessageMap.put(emRecord.Id, emRecord);
                        qccEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        qccCaseMap.put(caseRecord.Id, caseRecord);
                        qccOwnerIds.add(caseRecord.OwnerId);
                        //QCC Outbound emails
                        if (!emRecord.Incoming) {
                            qccOutboundCaseEmailMap.put(caseRecord.Id, emRecord.Id);
                            if(qccRecordTypesforAcknowledgementEmail.contains(qccRecordIdNameMap.get(caseRecord.RecordTypeId)) && caseRecord.Acknowledgement_Sent__c) {
                                qccOutboundcasesTobeActionedMap.put(caseRecord.Id, caseRecord);
                                qccCaseIdEmailCountMap.put(caseRecord.Id, 0);
                            } else if(!qccRecordTypesforAcknowledgementEmail.contains(qccRecordIdNameMap.get(caseRecord.RecordTypeId))) {
                                qccOutboundcasesTobeActionedMap.put(caseRecord.Id, caseRecord);
                            }
                        }
                    } else if (freightRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        freightEmailMessageMap.put(emRecord.Id, emRecord);
                        freightEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        freightCaseMap.put(caseRecord.Id, caseRecord);
                        if (String.isNotBlank(caseRecord.AccountId)) {
                            freightAccountIds.add(caseRecord.AccountId);
                        }
                        if (String.isNotBlank(emRecord.CreatedById)) {
                            freightCreatedByIds.add(emRecord.CreatedById);
                        }
                        // To extract domain from email address
                        emailDomain = CaseUtility.getDomainFromEmailField(emRecord.fromaddress);
                        if (String.isNotBlank(emailDomain)) {
                            setDomainName.add(emailDomain);              
                        }
                    } else {
                        otherEmailMessages.add(emRecord);
                        otherCaseMap.put(caseRecord.Id, caseRecord);
                        if (caseRecord.AccountId != null) {
                            otherRTAccountIds.add(caseRecord.AccountId);
                        }
                    }
                }
            }
            if (!qccEmailMessageMap.isEmpty()) {
                
                EmailMessageQCCTriggerHandler.afterInsert(qccEmailMessageMap, qccCaseMap, qccOwnerIds, qccOutboundcasesTobeActionedMap, qccCaseIdEmailCountMap, qccOutboundCaseEmailMap);
                
            }
            if (!freightEmailMessageMap.isEmpty()) {
                EmailMessageFreightTriggerHandler.afterInsert(freightEmailMessageMap.values(), freightCaseMap, freightAccountIds, freightCreatedByIds, queueMap, setDomainName);
            }
            if (!otherEmailMessages.isEmpty()) {
                EmailMessageOthersTriggerHandler.afterInsert(otherEmailMessages, otherCaseMap,  queueMap, otherRTAccountIds);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageTriggerHandler',
                                    'afterInsert', String.valueOf(''), String.valueOf(''),false, '', ex);
        }
    }

    public override void beforeUpdate() {
        try {
            Map<String, Id> qccRecordTypeMap = buToRecordTypeMap.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitQCC'));
            Map<String, Id> freightRecordTypeMap = buToRecordTypeMap.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitFreight'));
            Map<String, Id> queueMap = fetchCaseQueueInfo();
            Set<Id> qccRecordTypeIds = new Set<Id>();
            Set<Id> freightRecordTypeIds = new Set<Id>();
            Map<Id, Case> caseMap;
            Map<Id, EmailMessage> qccEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> qccEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> qccCaseMap = new Map<Id, Case>();
            Map<Id, EmailMessage> freightEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> freightEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> freightCaseMap = new Map<Id, Case>();
            Map<Id, EmailMessage> otherEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> otherEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> otherCaseMap = new Map<Id, Case>();
            Case caseRecord;
            if (qccRecordTypeMap != null) {
                qccRecordTypeIds = new Set<Id>(qccRecordTypeMap.values());
            }
            if (freightRecordTypeMap != null) {
                freightRecordTypeIds = new Set<Id>(freightRecordTypeMap.values());
            }
            caseMap = fetchCases(newEmailMessageList);
            for (EmailMessage emRecord : newEmailMessageList) {
                if(String.isNotBlank(emRecord.To_Address__c)) {
                    emRecord.ToAddress =emRecord.To_Address__c;
                    //emRecord.BccAddress = emRecord.To_Address__c;
                } else if (String.isNotBlank(emRecord.To_Addresss__c)) { 
                    emRecord.ToAddress =emRecord.To_Addresss__c;
                }
                caseRecord = caseMap.get(emRecord.ParentId);
                if (caseRecord != null) {
                    if (qccRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        qccEmailMessageMap.put(emRecord.Id, emRecord);
                        qccEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        qccCaseMap.put(caseRecord.Id, caseRecord);
                    } else if (freightRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        freightEmailMessageMap.put(emRecord.Id, emRecord);
                        freightEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        freightCaseMap.put(caseRecord.Id, caseRecord);
                    } else {
                        otherEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                    }
                }
            }
            if (!qccEmailMessageMap.isEmpty()) {
                EmailMessageQCCTriggerHandler.beforeUpdate(qccEmailMessageMap, qccCaseMap);
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageTriggerHandler', 
                'beforeUpdate', String.valueOf(''), String.valueOf(''), false, '', ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageTriggerHandler',
                                                                                     'InsebeforeInsert', '', '', false, '', null, ex.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }

    }

    public override void afterUpdate() {
        try {
            //CCC_Complaints;CCC_Baggage;CCC_Further_Action_Required;QCC_Insurance_Letter_Case;CCC_Query;CCC_Medical
            String qccRecordTypesforAcknowledgementEmail = Label.QCC_RecordTypes_for_Acknowledgement_email;
            Map<String, Id> qccRecordTypeMap = buToRecordTypeMap.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitQCC'));
            Map<String, Id> freightRecordTypeMap = buToRecordTypeMap.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitFreight'));
            Map<Id, Case> qccOutboundcasesTobeActionedMap = new Map<Id, Case>();
            Map<Id, Integer> qccCaseIdEmailCountMap = new Map<Id, Integer>();
            Map<Id, Id> qccOutboundCaseEmailMap = new Map<Id, Id>();
            Map<String, Id> queueMap = fetchCaseQueueInfo();
            List<Id> qccOwnerIds = new List<Id>();
            Set<Id> qccRecordTypeIds = new Set<Id>();
            Set<Id> freightRecordTypeIds = new Set<Id>();
            Set<Id> freightCreatedByIds = new Set<Id>();
            Map<Id, Case> caseMap;
            Map<Id, EmailMessage> qccEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> qccEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> qccCaseMap = new Map<Id, Case>();
            Map<Id, EmailMessage> freightEmailMessageMap = new Map<Id, EmailMessage>();
            Map<Id, Case> freightEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, Case> freightCaseMap = new Map<Id, Case>();
            Map<Id, Case> otherEmailMessageIdCaseMap = new Map<Id, Case>();
            Map<Id, String> qccRecordIdNameMap = new Map<Id, String>();
            Case caseRecord;
            if (qccRecordTypeMap != null) {
                qccRecordTypeIds = new Set<Id>(qccRecordTypeMap.values());
                for (String devName : qccRecordTypeMap.keySet()) {
                    qccRecordIdNameMap.put(qccRecordTypeMap.get(devName), devName);
                }
            }
            if (freightRecordTypeMap != null) {
                freightRecordTypeIds = new Set<Id>(freightRecordTypeMap.values());
            }
            caseMap = fetchCases(newEmailMessageList);
            for (EmailMessage emRecord : newEmailMessageList) {
                caseRecord = caseMap.get(emRecord.ParentId);
                if (caserecord != null) {
                    if (qccRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        qccEmailMessageMap.put(emRecord.Id, emRecord);
                        qccEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        qccCaseMap.put(caseRecord.Id, caseRecord);
                        qccOwnerIds.add(caseRecord.OwnerId);
                        //QCC Outbound emails
                        if (!emRecord.Incoming) {
                            qccOutboundCaseEmailMap.put(caseRecord.Id, emRecord.Id);
                            if(qccRecordTypesforAcknowledgementEmail.contains(qccRecordIdNameMap.get(caseRecord.RecordTypeId)) && caseRecord.Acknowledgement_Sent__c) {
                                qccOutboundcasesTobeActionedMap.put(caseRecord.Id, caseRecord);
                                qccCaseIdEmailCountMap.put(caseRecord.Id, 0);
                            } else if(!qccRecordTypesforAcknowledgementEmail.contains(qccRecordIdNameMap.get(caseRecord.RecordTypeId))) {
                                qccOutboundcasesTobeActionedMap.put(caseRecord.Id, caseRecord);
                            }
                        }
                    } else if (freightRecordTypeIds.contains(caseRecord.RecordTypeId)) {
                        freightEmailMessageMap.put(emRecord.Id, emRecord);
                        freightEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                        freightCaseMap.put(caseRecord.Id, caseRecord);
                        if (String.isNotBlank(emRecord.CreatedById)) {
                            freightCreatedByIds.add(emRecord.CreatedById);
                        }
                    } else {
                        otherEmailMessageIdCaseMap.put(emRecord.Id, caseRecord);
                    }
                }
            }
            if (!qccEmailMessageMap.isEmpty()) {
                EmailMessageQCCTriggerHandler.afterUpdate(qccEmailMessageMap, qccCaseMap, qccOwnerIds, qccOutboundcasesTobeActionedMap, qccCaseIdEmailCountMap, qccOutboundCaseEmailMap);
            }
            if (!freightEmailMessageMap.isEmpty()) {
                EmailMessageFreightTriggerHandler.afterUpdate(freightEmailMessageMap.values(), freightCaseMap, freightCreatedByIds);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageTriggerHandler',
                                    'afterUpdate', String.valueOf(''), String.valueOf(''),false, '', ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageTriggerHandler',
                                                                                     'afterInsert', '', '', false, '', null, ex.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
        } 
    }


/*----------------------------------------------------------------------------------------------------
    Method Name:    fetchCases
    Descritption:   Method to fetch Case records referenced in EmaiMessage
    Parameter:      List<EmailMessage>
-----------------------------------------------------------------------------------------------------*/
    public static Map<Id,Case> fetchCases(List<EmailMessage> emailMessageRecords) {
        Map<Id, Id> emailMessageCaseIdsMap = new Map<Id, Id>();
        Map<Id, Case> emailMessageIdCaseMap = new Map<Id, Case>();
        Case caseRecord;
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        try {
            if (emailMessageRecords != null) {
                for (EmailMessage emRecord : emailMessageRecords) {
                    if (String.isNotBlank(emRecord.ParentId)) {
                        caseIds.add(emRecord.ParentId);
                    }
                }
            }
            if (!caseIds.isEmpty()) {
                caseMap = new Map<Id, Case>([ SELECT Id,Last_Queue_Owner__c,CaseNumber,CreatedDate, Acknowledgement_Sent__c, First_email_to_customer__c, Assign_using_active_assignment_rules__c,
                                                    Last_Queue_Owner_Name__c, Previous_Case_Owner__c,FF_Tier__c, accountid, contactid, CCC_And_B_Case_Type__c, Status,Resolve_Closeddate__c,
                                                    type, Sub_Type_1__c,Sub_Type_2__c,subject,description, Freight_AWB_Number__c,Freight_Port__c, priority,Sensitive__c,
                                                    Contact.Frequent_Flyer_Tier__c,Contact.SSU__c,RecordTypeId,RecordType.DeveloperName,RecordType.Name, IsClosed,ClosedDate,
                                                    Email_Content__c,Origin,Resolution_Method__c, Reason, Closed_By__c, ClosedByLocation__c, Recovery_Inprogress__c, ParentId,Freight_Region__c,SuppliedEmail,
                                                    OwnerId, QCC_Internal_Followup_Emails__c, OwnerName__c, Auto_Close_on_Email_Sent__c, contact.FirstName,contact.LastName,
                                                     contact.Email,
                                                     (SELECT Id, Name ,CreatedById,CaseNumber__c,case_number__c,CreatedBy.name, Process_Status__c,recordtype.developername FROM Recoveries_Case__r ORDER BY CreatedDate DESC LIMIT 1)
                                                      FROM Case WHERE Id IN :caseIds ]);
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', '', 'EmailMessageTriggerHandler', 'fetchCases', '', '', false, '', ex);
        }
        return caseMap;
    }
/*----------------------------------------------------------------------------------------------------     
Method Name:        fetchCaseQueueInfo
Description:        This method used to fetch Case Queue info
Parameter:          
-----------------------------------------------------------------------------------------------------*/
    public static Map<String,Id> fetchCaseQueueInfo() {
        Map<String, Id> queueMap = new Map<String, Id>();
        try {
            for (Group groupRecord : groupRecList) 
            {
                queueMap.put(groupRecord.DeveloperName, groupRecord.Id);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                'fetchCaseQueueInfo', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return queueMap;  
    }

/*----------------------------------------------------------------------------------------------------
Method Name:        maskCreditCard
Description:        Method to mask credit card and UATP numbers, in the email body.
Parameter:
-----------------------------------------------------------------------------------------------------*/
    public static EmailMessage maskCreditCard(EmailMessage emailMsg) {
        try {
            emailMsg.TextBody = emailMsg.TextBody != null ? CaseUtility.maskCreditCardAndUATPCardNumbers(emailMsg.TextBody) : emailMsg.TextBody;
            emailMsg.HtmlBody = emailMsg.HtmlBody != null ? CaseUtility.maskCreditCardAndUATPCardNumbers(emailMsg.HtmlBody) : emailMsg.HtmlBody;

        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'maskCreditCard', String.valueOf(''), String.valueOf(''),false, emailMsg.id != null ? emailMsg.id : '', ex);
        }
        return emailMsg;

    }
}