//Test class : chatTranscriptTriggerHelperTest
public class chatTranscriptTriggerHelper {
    
    private static final Schema.SObjectType SOBJECTTYPE_USER = User.getSObjectType();
    private static final String RT_CASE_QANTASFREIGHT = CustomSettingsUtilities.getConfigDataMap('RT_Case_QantasFreight');
    private static final String RT_ACCOUNT_FREIGHT = CustomSettingsUtilities.getConfigDataMap('RT_FreightAccount');
    private static final String FULLNAME_AUTOMATEDUSER = CustomSettingsUtilities.getConfigDataMap('FullName_AutomatedUser');
    private static final Id RTID_CASE_QANTASFREIGHT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_CASE_QANTASFREIGHT).getRecordTypeId();
    private static final Id RTID_QAC_CHAT_TRANSCRIPT = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('QAC_NDC_Chat').getRecordTypeId(); 
    private static final Id RTID_ACCOUNT_FREIGHT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RT_ACCOUNT_FREIGHT).getRecordTypeId();
    private static final String FULLNAME_RETAILCUSTOMERWC = 'Retail Customer Webchat';
    private static final String FULLNAME_RETAILCUSTOMERCC = 'Retail Customer [FREIGHT-CASHCUST-AU]';
    private static final Set<String> EMAIL_DOMAINS = new Set<String>(Label.WebchatPublicEmailDomains.split(';'));

    
    public static void onAfterUpdate(List<LiveChatTranscript> listTranscriptsList) {
        try {
            User auUser = [ SELECT Id FROM User WHERE Name = :FULLNAME_AUTOMATEDUSER LIMIT 1 ];
            Account retailCustomerWebchatAcc, retailCustomerCashCust;
            Map<Id, Account> auAccountsMap = new Map<Id, Account>();
            for (Account record : [ SELECT Id, Name, Email__c FROM Account WHERE RecordTypeId=:RTID_ACCOUNT_FREIGHT AND Country_f__c='AU' ORDER BY CreatedDate DESC ])
            {
                if (record.Name == FULLNAME_RETAILCUSTOMERWC) {
                    retailCustomerWebchatAcc = record;
                } else if(record.Name == FULLNAME_RETAILCUSTOMERCC) {
                    retailCustomerCashCust = record;
                } else {
                    auAccountsMap.put(record.Id, record);
                }
            }                  
            Set<Id> caseIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<Id, Case> caseRecordsMap;
            Map<Id, Contact> contactRecordsMap;
            Map<Id, Case> casesToUpdate = new Map<Id, Case>();
            Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
            Case caseRecord; 
            Contact contactRecord;
            for (LiveChatTranscript lctRecord : listTranscriptsList) {
                if (lctRecord.RecordTypeId != RTID_QAC_CHAT_TRANSCRIPT) { 
                    if (lctRecord.CaseId != null) {
                        caseIds.add(lctRecord.CaseId);
                    }
                    if (lctRecord.ContactId != null) {
                        contactIds.add(lctRecord.ContactId);
                    }
                }
            }
            caseRecordsMap = queryCaseRecords(caseIds);
            contactRecordsMap = queryContactRecords(contactIds);
            /*
            Set<Id> contactIdsRCWCMT2 = new Set<Id>();
            for (AggregateResult arRecord : [ SELECT ContactId, COUNT(Id) FROM Case WHERE Contact.Account.Name=:FULLNAME_RETAILCUSTOMERWC GROUP BY ContactId ]) 
            {
                if (Integer.valueOf(arRecord.get('expr0')) > 2 ) {
                    contactIdsRCWCMT2.add(Id.valueOf(String.valueOf(arRecord.get('ContactId'))));
                }
            }
            */
            for (LiveChatTranscript lctRecord : listTranscriptsList) {
                if (lctRecord.RecordTypeId != RTID_QAC_CHAT_TRANSCRIPT) {
                    caseRecord = caseRecordsMap.get(lctRecord.CaseId);
                    contactRecord = contactRecordsMap.get(lctRecord.ContactId);
                    // To update the case owner from Automated Process to the current Agent
                    if (caseRecord != null && lctRecord.OwnerId.getSObjectType() == SOBJECTTYPE_USER 
                        && caseRecord.OwnerId == auUser.Id && caseRecord.Origin == 'Webchat')
                    {
                        caseRecord.OwnerId = lctRecord.OwnerId;
                        casesToUpdate.put(caseRecord.Id, caseRecord);
                    }
                    // To update case and contact records based on the chat transcripts
                    if (caseRecord != null && caseRecord.Origin != 'Webchat') {
                        if (lctRecord.ContactId == null) {
                            caseRecord.AccountId = retailCustomerWebchatAcc.Id;
                            caseRecord.Description = 'Please see Feed for the chat transcript.';
                        } else {
                            if (contactRecord.AccountId == null) {
                                contactRecord.AccountId = retailCustomerWebchatAcc.Id;
                                contactRecord.Business_Types__c = 'Freight';
                                contactRecord.Function__c = 'Other';
                                contactRecord.Job_Function__c = 'Other';
                                contactRecord.Job_Role__c = 'Other';
                                contactRecord.Source__c = 'FRT-CHAT';
                                contactsToUpdate.put(contactRecord.Id, contactRecord);
                                caseRecord.AccountId = contactRecord.AccountId;
                                caseRecord.Description = 'Please see Feed for the chat transcript.';
                            } else {
                                if (contactRecord.Account.RecordTypeId == RTID_ACCOUNT_FREIGHT) {
                                    caseRecord.Description = 'Please see details of Chat transcript via the feed sub tab.';
                                    if (contactRecord.AccountId == retailCustomerWebchatAcc.Id) {
                                        contactRecord.AccountId = chatContactReassignmentAfterTwoCases(retailCustomerWebchatAcc.Id,retailCustomerCashCust.Id,auAccountsMap,contactRecord);
                                        contactsToUpdate.put(contactRecord.Id, contactRecord);
                                    }
                                } else {
                                    caseRecord.AccountId = retailCustomerWebchatAcc.Id;
                                    caseRecord.Description = 'Please see Feed for the chat transcript.';
                                }
                            }
                        }
                        caseRecord.Customer_Advice_Method__c = 'SMS_Text';
                        caseRecord.Origin = 'Webchat';
                        caseRecord.Subject = lctRecord.Freight_Chat_Topic__c;
                        casesToUpdate.put(caseRecord.Id, caseRecord);
                    }
                }
            }
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate.values();
            }
            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate.values();
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'LiveChatTranscript', 'chatTranscriptTriggerHelper', 
                'onAfterUpdate', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    
    /*
    public static void onAfterUpdate(List<LiveChatTranscript> listTranscriptsList) {
        try{
        User auUser = [ SELECT Id FROM User WHERE Name = :FULLNAME_AUTOMATEDUSER LIMIT 1 ];
        Set<Id> caseIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> emailDomains = new Set<Id>();
        Map<Id, Case> caseRecordsMap;
        Map<Id, Contact> contactRecordsMap;
        Map<String, Account> accountRecordsMap = new Map<String, Account>();
        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        Case caseRecord; 
        Contact contactRecord;
        String emailDomain;
        String email;
        Account retailCustomerAccount;
        for (LiveChatTranscript lctRecord : listTranscriptsList) {
            if (lctRecord.CaseId != null) {
                caseIds.add(lctRecord.CaseId);
            }
            if (lctRecord.ContactId != null) {
                contactIds.add(lctRecord.ContactId);
            }
        }
        caseRecordsMap = queryCaseRecords(caseIds);
        contactRecordsMap = queryContactRecords(contactIds);
        for (Account accountRecord : [ SELECT Id, Name, Email__c FROM Account
                                        WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT
                                        ORDER BY CreatedDate DESC ])
        {
            if (retailCustomerAccount == null && accountRecord.Name == 'Retail Customer Webchat') {
                retailCustomerAccount = accountRecord;
                continue;
            } else if (String.isNotBlank(accountRecord.Email__c)) {
                email = accountRecord.Email__c;
                emailDomain = email.split('@')[1];
                if (accountRecordsMap.containsKey(emailDomain)) {
                    continue;
                }
                accountRecordsMap.put(emailDomain, accountRecord);
            }
        }
        for (LiveChatTranscript lctRecord : listTranscriptsList) {
            caseRecord = caseRecordsMap.get(lctRecord.CaseId);
            contactRecord = contactRecordsMap.get(lctRecord.ContactId);
            // To update the case owner from Automated Process to the current Agent
            if (caseRecord != null && lctRecord.OwnerId.getSObjectType() == SOBJECTTYPE_USER 
                && caseRecord.OwnerId == auUser.Id && caseRecord.Origin == 'Webchat')
            {
                caseRecord.OwnerId = lctRecord.OwnerId;
                casesToUpdate.put(caseRecord.Id, caseRecord);
            }
            // To update case and contact records based on the chat transcripts
            if (caseRecord != null && caseRecord.Origin != 'Webchat') {
                if (contactRecord != null) {
                    email = contactRecord.Email;
                    emailDomain = String.isBlank(email) ? null : email.split('@')[1];
                    //caseRecord.SuppliedEmail = emailDomain;
                    if (contactRecord.AccountId != null && contactRecord.Account.RecordTypeId == RTID_ACCOUNT_FREIGHT) {
                        if (contactRecord.Account.Name == 'Retail Customer Webchat') {
                            if (accountRecordsMap.containsKey(emailDomain)) {
                                contactRecord.AccountId = accountRecordsMap.get(emailDomain).Id;
                                contactRecord.Business_Types__c = 'Freight';
                                contactRecord.Function__c = 'Other';
                                contactRecord.Job_Function__c = 'Other';
                                contactRecord.Job_Role__c = 'Other';
                                contactRecord.Source__c = 'FRT-CHAT';
                                caseRecord.AccountId = accountRecordsMap.get(emailDomain).Id;
                                caseRecord.Customer_Advice_Method__c = 'SMS_Text';
                                caseRecord.Description = 'Please see details of Chat transcript via the feed sub tab.1';
                                caseRecord.Origin = 'Webchat';
                                caseRecord.Subject = lctRecord.Freight_Chat_Topic__c;
                                contactsToUpdate.put(contactRecord.Id, contactRecord);
                            } else {
                                caseRecord.Customer_Advice_Method__c = 'SMS_Text';
                                caseRecord.Description = 'Please see Feed for the chat transcript.2';
                                caseRecord.Origin = 'Webchat';
                                caseRecord.Subject = lctRecord.Freight_Chat_Topic__c;
                            }
                        } else {
                            caseRecord.Customer_Advice_Method__c = 'SMS_Text';
                            caseRecord.Description = 'Please see details of Chat transcript via the feed sub tab.3';
                            caseRecord.Origin = 'Webchat';
                            caseRecord.Subject = lctRecord.Freight_Chat_Topic__c;
                        }
                    } else {
                        if (contactRecord.AccountId == null && accountRecordsMap.containsKey(emailDomain)) {
                            contactRecord.AccountId = accountRecordsMap.get(emailDomain).Id;
                            contactRecord.Business_Types__c = 'Freight';
                            contactRecord.Function__c = 'Other';
                            contactRecord.Job_Function__c = 'Other';
                            contactRecord.Job_Role__c = 'Other';
                            contactRecord.Source__c = 'FRT-CHAT';
                            caseRecord.AccountId = accountRecordsMap.get(emailDomain).Id;
                            caseRecord.Customer_Advice_Method__c = 'SMS_Text';
                            caseRecord.Description = 'Please see details of Chat transcript via the feed sub tab.4';
                            caseRecord.Origin = 'Webchat';
                            caseRecord.Subject = lctRecord.Freight_Chat_Topic__c;
                            contactsToUpdate.put(contactRecord.Id, contactRecord);
                        } else {
                            caseRecord.AccountId = retailCustomerAccount.Id;
                            caseRecord.Customer_Advice_Method__c = 'SMS_Text';
                            caseRecord.Description = 'Please see Feed for the chat transcript.5';
                            caseRecord.Origin = 'Webchat';
                            caseRecord.Subject = lctRecord.Freight_Chat_Topic__c;
                        }
                    }
                } else {
                    caseRecord.AccountId = retailCustomerAccount.Id;
                    caseRecord.Customer_Advice_Method__c = 'SMS_Text';
                    caseRecord.Description = 'Please see Feed for the chat transcript.6';
                    caseRecord.Origin = 'Webchat';
                    caseRecord.Subject = lctRecord.Freight_Chat_Topic__c;
                }
                casesToUpdate.put(caseRecord.Id, caseRecord);
            }
            
        }
            if (contactsToUpdate.size() > 0) {
                update contactsToUpdate.values();
                
            }
            if (casesToUpdate.size() > 0) {
                update casesToUpdate.values();
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'LiveChatTranscript', 'chatTranscriptTriggerHelper', 
                'onAfterUpdate', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    */

    /*
        Created Date: 13 September 2024
        Description: To query the case records of QANTAS_FREIGHT recordtype
        Developer: Balaganapathy
    */
    public static Id chatContactReassignmentAfterTwoCases(Id retailCustomerWebchatAccId, Id retailCustomerCashCustId, Map<Id, Account> auAccountsMap, Contact contactRecord) {
        if (String.isNotBlank(contactRecord.Email)) {
            if (EMAIL_DOMAINS.contains(contactRecord.Email.split('@').get(1))) {
                return retailCustomerCashCustId;
            }
            for (Account record : auAccountsMap.values()) {
                if (String.isNotBlank(record.Email__c) && record.Email__c.contains('@' + contactRecord.Email.split('@').get(1))) 
                {
                    return record.Id;
                }     
            }
        }
        return retailCustomerWebchatAccId;
    }

    /*
        Created Date: 13 September 2024
        Description: To query the case records of QANTAS_FREIGHT recordtype
        Developer: Balaganapathy
    */
    public static Map<Id, Case> queryCaseRecords(Set<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            return new Map<Id, Case>();
        }
        return new Map<Id, Case>([ SELECT Id, OwnerId, AccountId, Account.Name, Account.Email__c, Account.RecordTypeId, Origin FROM Case 
                                    WHERE RecordTypeId = :RTID_CASE_QANTASFREIGHT AND Id IN :caseIds ]);
    }

    /*
        Created Date: 13 September 2024
        Description: To query the contact records
        Developer: Balaganapathy
    */
    public static Map<Id, Contact> queryContactRecords(Set<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) {
            return new Map<Id, Contact>();
        }
        return new Map<Id, Contact>([ SELECT Id, Name, Email, AccountId, Account.Name, Account.Email__c, Account.RecordTypeId FROM Contact 
                                        WHERE Id IN :contactIds ]);
    }
    
    /*
        Created Date: 11 November 2021
        Description: To update the case owner from Automated Process to the current Agent
        Incident Number: INC1661457
        Developer: Navpreet Kaur
    */
    public static ID QantasFreight=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
    public static void changeOwnerToCurrentAgent(List<LiveChatTranscript> listTranscripts)
    {
        
        List<ID> caseIds=new List<ID>();
        User UID=[select id,name from user where name='Automated Process' limit 1];
        List<Case> updateCases=new List<Case>();
       
        
        if(listTranscripts!=null && listTranscripts.size()>0)
        {
            for(LiveChatTranscript eachTrans:listTranscripts)
            {
                if(eachTrans.CaseId!=null)
                {
                    caseIds.add(eachTrans.CaseId);
                    
                }
            }        
        }
        for(Case eachCase:[select id,casenumber,ownerId,Origin from case where ID IN :caseIds and recordtypeid=:QantasFreight])
        {
            for(LiveChatTranscript eachTransRec:listTranscripts)
            {
                String ownerIds=string.valueof(eachTransRec.OwnerId);
                
                if(ownerIds.startswith('005') && eachCase.Id.equals(eachTransRec.caseid) && eachCase.OwnerId.equals(UID.Id) && eachCase.origin.contains('Webchat'))
                {
                    eachCase.OwnerId=eachTransRec.OwnerId;
                    updateCases.add(eachCase);
                }
            }
        }
        if(updateCases!=null && updateCases.size()>0)
        {
            update updateCases;
        }
    } 
}