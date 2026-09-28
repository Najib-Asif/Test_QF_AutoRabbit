//Test class : chatTranscriptTriggerHelperTest
public with sharing class QL_ChatTranscriptNDC {

    public class FlowInput_QLChatTranscriptNDC {
        @InvocableVariable public String operationVar;
        @InvocableVariable public LiveChatTranscript chatTranscriptVar;
    }

    @InvocableMethod(label='Perform NDC Chat Logic')
    public static void processChatTranscript(List<FlowInput_QLChatTranscriptNDC> flowInputList) {
        FlowInput_QLChatTranscriptNDC flowInputRecord = flowInputList[0];
        LiveChatTranscript chatTranscriptRecord = flowInputRecord.chatTranscriptVar;
        Contact contactRecord;
        Account accountRecord;
        Case caseRecord;
        if (String.isNotBlank(flowInputRecord.operationVar) && flowInputRecord.operationVar.equals('INSERT')) {
            accountRecord = findAccount(chatTranscriptRecord.QIC_Number__c);
            caseRecord = createCaseRecord(chatTranscriptRecord, accountRecord, contactRecord);
            if (caseRecord != null) {
                chatTranscriptRecord.CaseId = caseRecord.Id;
            }
            if (accountRecord != null) {
                chatTranscriptRecord.AccountId = accountRecord.Id;
                chatTranscriptRecord.Account_Tier__c = accountRecord.Customer_Category__c;
            }
            try {
                update chatTranscriptRecord;
            } catch (Exception ex) {
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Chat Transcript', 'QL_ChatTranscriptNDC',
                'processChatTranscript', String.valueOf(''), String.valueOf(''), false, '', ex);
            }
        } else if (String.isNotBlank(flowInputRecord.operationVar) && flowInputRecord.operationVar.equals('UPDATE')) {
            accountRecord = queryAccount(chatTranscriptRecord.AccountId);
            contactRecord = updateContactFields(chatTranscriptRecord, accountRecord);
            updateCaseFields(chatTranscriptRecord, contactRecord);
        }
    }

    public static Account findAccount(String qicNumber) {
        final Id rtIdAccountAgencyConnect = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        Account accountRecord;
        if (String.isBlank(qicNumber)) {
            return accountRecord;
        }
        system.debug('qicNumber--'+qicNumber);
        accountRecord = [ SELECT Id, OwnerId, Qantas_Industry_Centre_ID__c, Customer_Category__c FROM Account
                            WHERE RecordTypeId = :rtIdAccountAgencyConnect 
                            AND Qantas_Industry_Centre_ID__c = :qicNumber ];
        return accountRecord;
    }

    public static Account queryAccount(Id accountId) {
        Account accountRecord;
        if (String.isBlank(accountId)) {
            return accountRecord;
        }
        accountRecord = [ SELECT Id, OwnerId, Qantas_Industry_Centre_ID__c, Customer_Category__c FROM Account
                            WHERE Id = :accountId ];
        return accountRecord;
    }

    public static void updateCaseFields(LiveChatTranscript lctRecord, Contact contactRecord) {
        Case caseRecord;
        if (String.isBlank(lctRecord.CaseId)) {
            return;
        }
        caseRecord = [ SELECT Id, CaseNumber, OwnerId, Consultants_Name__c, ContactId FROM Case
                            WHERE Id = :lctRecord.CaseId ];
        if (caseRecord == null) {
            return;
        }
        if (String.isNotBlank(lctRecord.OwnerId) && String.isNotBlank(lctRecord.Status)
            && lctRecord.Status.equalsIgnoreCase('InProgress') && !lctRecord.OwnerId.equals(caseRecord.OwnerId))
        {
            caseRecord.OwnerId = lctRecord.OwnerId;
        }
        if (contactRecord != null && String.isNotBlank(contactRecord.Name)
            && !contactRecord.Name.equals(caseRecord.Consultants_Name__c))
        {
            caseRecord.Consultants_Name__c = contactRecord.Name;
        }
        if (contactRecord != null 
            && (String.isBlank(caseRecord.ContactId) || caseRecord.ContactId != contactRecord.Id)) 
        {
            caseRecord.ContactId = contactRecord.Id;
        }
        try {
            update caseRecord;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Chat Transcript', 'QL_ChatTranscriptNDC',
            'updateCaseFields', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    
    public static Contact updateContactFields(LiveChatTranscript lctRecord, Account accountRecord) {
        Contact contactRecord;
        if (String.isBlank(lctRecord.ContactId)) {
            return contactRecord;
        }
        contactRecord = [ SELECT Id, Name, Contact_number__c, Function__c, Job_Role__c, Business_Types__c, OwnerId, QIC_Number__c, AccountId, Technology_Partner__c, PNR__c 
                            FROM Contact 
                            WHERE Id = :lctRecord.ContactId ];
        if (contactRecord == null) {
            return contactRecord;
        }
        if (accountRecord != null) {
            contactRecord.AccountId = accountRecord.Id;
            contactRecord.Business_Types__c = 'Agency'; 
			contactRecord.Job_Role__c = 'Other'; 
			contactRecord.Function__c = 'Other';
            contactRecord.OwnerId = accountRecord.OwnerId;
        }
        /*
        if (String.isNotBlank(lctRecord.Technology_Partner__c)
            && !lctRecord.Technology_Partner__c.equals(contactRecord.Technology_Partner__c))
        {
            contactRecord.Technology_Partner__c = lctRecord.Technology_Partner__c;
        }
        if (String.isNotBlank(lctRecord.PNR__c)
            && !lctRecord.PNR__c.equals(contactRecord.PNR__c))
        {
            contactRecord.PNR__c = lctRecord.PNR__c;
        }
        if (String.isNotBlank(lctRecord.Contact_number__c)
            && !lctRecord.Contact_number__c.equals(contactRecord.Contact_number__c))
        {
            contactRecord.Contact_number__c = lctRecord.Contact_number__c;
        }
        if (String.isNotBlank(lctRecord.QIC_Number__c)
            && !lctRecord.QIC_Number__c.equals(contactRecord.QIC_Number__c))
        {
            contactRecord.QIC_Number__c = lctRecord.QIC_Number__c;
        }
        */
        contactRecord.Technology_Partner__c = lctRecord.Technology_Partner__c;
        contactRecord.PNR__c = lctRecord.PNR__c;
        contactRecord.Contact_number__c = lctRecord.Contact_number__c;
        contactRecord.QIC_Number__c = lctRecord.QIC_Number__c;
        try {
            update contactRecord;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Chat Transcript', 'QL_ChatTranscriptNDC',
            'updateContactFields', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return contactRecord;
    }

    public static Case createCaseRecord(LiveChatTranscript lctRecord, Account accountRecord, Contact contactRecord) {
        final Id rtIdCaseQACCONTACT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QAC_Contact_Us_Support').getRecordTypeId();
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = rtIdCaseQACCONTACT; //RecordType
        caseRecord.Booking_PNR__c = lctRecord.PNR__c;
        caseRecord.Consultants_Name__c = lctRecord.Travel_Consultant_Name__c;
        caseRecord.Consultant_Phone__c = lctRecord.Contact_number__c;
        caseRecord.GDS_DI__c = lctRecord.Technology_Partner__c;
        caseRecord.IATA__c = lctRecord.QIC_Number__c;
        caseRecord.Origin = 'Web';
        caseRecord.Type = 'NDC';
        caseRecord.Category__c = 'Web Chat';
        caseRecord.Sub_Category__c = 'General';
        caseRecord.Group__c = 'NDC Portal';
        caseRecord.Description = '';
        if (accountRecord != null) {
            caseRecord.AccountId = accountRecord.Id;
        }
        if (contactRecord != null) {
            caseRecord.Consultants_Name__c = contactRecord.Name;
        }
        try {
            insert caseRecord;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Chat Transcript', 'QL_ChatTranscriptNDC',
            'createCaseRecord', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return caseRecord;
    }
}