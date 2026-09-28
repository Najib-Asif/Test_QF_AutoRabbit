/**
 * @description       : 
 * @author            : Gandla Mallikarjuna
 * @group             : 
 * @last modified on  : 05-15-2025
 * @last modified by  : Gandla Mallikarjuna
 * Test Class         : EmailMessageOthersTriggerHandlerTest 80% Coverage
**/
public with sharing class EmailMessageOthersTriggerHandler {
    private static final String RT_QDPPORTALSUPPORT = CustomSettingsUtilities.getConfigDataMap('RT_QDPPortalSupport');    
    private static final String RT_TICKETINGAUTHORITY = CustomSettingsUtilities.getConfigDataMap('RT_Ticketing_Authority');
    private static final Id RTID_TICKETINGAUTHORITY = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_TICKETINGAUTHORITY).getRecordTypeId();
    private static final Id RTID_QDPPORTALSUPPORT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_QDPPORTALSUPPORT).getRecordTypeId();
    private static final String CASE_STATUS_CLOSED = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String CASE_STATUS_ONHOLD = CustomSettingsUtilities.getConfigDataMap('CaseStatusOnHold');
    private static final String CASE_STATUS_CLOSEDREJECTED = CustomSettingsUtilities.getConfigDataMap('Status_ClosedRejected');
    private static final String CASE_STATUS_REOPENED = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
    private static final String CASE_Type_BounceBack = CustomSettingsUtilities.getConfigDataMap('CASE_Type_BounceBack');
    private static final String QUEUE_SALESSUPPORT = CustomSettingsUtilities.getConfigDataMap('Queue_AUSalesSupport');
    private static final String QUEUE_QDPPORTAL = CustomSettingsUtilities.getConfigDataMap('Queue_QDPPortal_Support');
    private static final String QUEUE_NDCSUPPOT = CustomSettingsUtilities.getConfigDataMap('Queue_NDC_Support'); //CRM-9663
    private static final String CASE_STATUS_RESOLVED = CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusResolved');
    private static final String CASE_STATUS_REPLYRECEIVED = CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusReplyReceived');
    private static final String RT_SMECS = CustomSettingsUtilities.getConfigDataMap('RT_SMECustomerSupport');
    private static final String RT_AGENCYDEVELOPMENT = CustomSettingsUtilities.getConfigDataMap('RT_AgencyDevelopment');
    private static final String RT_SHRQISSS = CustomSettingsUtilities.getConfigDataMap('RT_SHRQISSalesSupport');
    private static final String RT_SHRQACZA = CustomSettingsUtilities.getConfigDataMap('RT_SHRQACZA');
    private static final String RT_SHRQACUS = CustomSettingsUtilities.getConfigDataMap('RT_SHRQACUS');
    private static final String RT_SHRQACSG = CustomSettingsUtilities.getConfigDataMap('RT_SHRQACSG');
    private static final String RT_SHRQACIT = CustomSettingsUtilities.getConfigDataMap('RT_SHRQACIT');
    private static final String RT_SHRQACFR = CustomSettingsUtilities.getConfigDataMap('RT_SHRQACFR');
    private static final String RT_CCC_Complaints = CustomSettingsUtilities.getConfigDataMap('RT_CCC_Complaints');
    private static final String GMC_Email_Address = CustomSettingsUtilities.getConfigDataMap('GMC_Email_Address');
    private static final String Qantas_NDC_Support_Email = CustomSettingsUtilities.getConfigDataMap('Qantas_NDC_Support_Email');
    private static final String RT_SystemAdminRequest = CustomSettingsUtilities.getConfigDataMap('RT_SystemAdminRequest');
    private static final String EMAILADDRESS = CustomSettingsUtilities.getConfigDataMap('EmailAddress_EmployeeComm');
    private static final User DATAUPDATEUSER = [ SELECT Id, Name FROM User WHERE Name = 'Data UpdatesUser' ];
    private static final Id RTID_SQACSG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SHR_Qantas_Agency_Connect_SG').getRecordTypeId();
    private static final Id RTID_PERSON = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account').getRecordTypeId();
    
    
    public static void afterInsert(List<EmailMessage> emailMessageRecords, Map<Id, Case> caseMap, Map<String, Id> queueMap, Set<Id> accountIds) {
        
        try {
            List<Case> caseToUpdate = new List<Case>();
            Account accountRecord;
            Map<Id, Account> accountRecordMap = new Map<Id, Account>();
            if (!accountIds.isEmpty()) {
                accountRecordMap = new Map<Id, Account>([ SELECT Id, RecordTypeId, Name FROM Account WHERE Id IN :accountIds ]);
            }
            String[] caseStatusForTALogic = new String[] { CASE_STATUS_CLOSED, CASE_STATUS_ONHOLD, CASE_STATUS_CLOSEDREJECTED };
            String[] queueDevNames = new String[] { QUEUE_SALESSUPPORT, QUEUE_QDPPORTAL };
            String[] sdRecordTypeDevNames = new String[] { RT_SHRQISSS, RT_SMECS, RT_AGENCYDEVELOPMENT, RT_SHRQACZA, RT_SHRQACUS, RT_SHRQACSG, RT_SHRQACIT, RT_SHRQACFR};
            Case caseRecord;
            for (EmailMessage emRecord : emailMessageRecords) {
                caseRecord = caseMap.get(emRecord.ParentId);
                if (emRecord.FromAddress == EMAILADDRESS && sdRecordTypeDevNames.contains(caseRecord.RecordType.DeveloperName)) {
                    caseRecord.OwnerId = DATAUPDATEUSER.Id;
                    caseRecord.Status = CASE_STATUS_CLOSED;
                } 
                 
                if (emRecord.Incoming) {
                    
                   if(emRecord.ToAddress.contains(GMC_Email_Address) &&(caseRecord.RecordType.DeveloperName ==RT_SystemAdminRequest)
                      && (caseRecord.Status==CASE_STATUS_CLOSED) && (caseRecord.Type==CASE_Type_BounceBack)){
                          caseRecord.RecordTypeId = RT_CCC_Complaints;                          
						  caseRecord.First_Name__c = caseRecord.contact.FirstName;
                          caseRecord.Last_Name__c = caseRecord.contact.LastName;
                          caseRecord.Contact_Email__c= caseRecord.contact.Email;
                          caseRecord.OwnerId = queueMap.get('GMC_Triage_Queue');
                          caseRecord.Status='New'; 
                    }
                    
                    if(emRecord.ToAddress.contains(Qantas_NDC_Support_Email) && (caseRecord.RecordTypeId == RTID_QDPPORTALSUPPORT)){
                        caseRecord.Type = 'NDC';

                        //CRM-9663
                        caseRecord.Status = CASE_STATUS_REPLYRECEIVED;
                        caseRecord.OwnerId = queueMap.get(QUEUE_NDCSUPPOT);
                    }
                    
                    if (caseRecord.RecordTypeId == RTID_TICKETINGAUTHORITY && caseStatusForTALogic.contains(caseRecord.Status)) {
                        caseRecord.OwnerId = queueMap.get(QUEUE_SALESSUPPORT);
                        caseRecord.Status = CASE_STATUS_REOPENED;
                    } 
                    //CRM-9585 - Updated Type == 'QDP'
                    else if (caseRecord.RecordTypeId == RTID_QDPPORTALSUPPORT && caseRecord.Type == 'QDP') {
                        if (caseRecord.Status == CASE_STATUS_RESOLVED) {
                            caseRecord.Status = CASE_STATUS_REOPENED;
                            caseRecord.OwnerId = queueMap.get(QUEUE_QDPPORTAL);
                        } else if (caseRecord.Status == CASE_STATUS_ONHOLD) {
                            caseRecord.Status = CASE_STATUS_REPLYRECEIVED;
                            caseRecord.OwnerId = queueMap.get(QUEUE_QDPPORTAL);
                        }
                    } else if (sdRecordTypeDevNames.contains(caseRecord.RecordType.DeveloperName)) {
                        // Case Reopen on new email V2
                        if (caseRecord.IsClosed) {
                            caseRecord.Status = CASE_STATUS_REOPENED;
                        }
                        // Case On hold to reopen on new email V2 CRM 6448.
                        if (caseRecord.RecordType.DeveloperName != RT_SMECS && caseRecord.RecordType.DeveloperName != RT_AGENCYDEVELOPMENT && caseRecord.Status == CASE_STATUS_ONHOLD) {
                            caseRecord.Status = CASE_STATUS_REOPENED;
                        }
                    }
                    if (caseRecord.RecordTypeId == RTID_SQACSG && caseRecord.AccountId != null)
                    {
                        accountRecord = accountRecordMap.get(caseRecord.AccountId);
                        if (accountRecord != null && accountRecord.RecordTypeId == RTID_PERSON){
                            caseRecord.AccountId = null;
                            caseRecord.ContactId = null;
                        }
                    }
                }
                caseToUpdate.add(caseRecord);
            }
            if(!caseToUpdate.isEmpty()) {
				List<Database.SaveResult> results = Database.update(caseToUpdate, false);
				for (Database.SaveResult result : results) {
					if (!result.isSuccess()){
						for (Database.Error err : result.getErrors()){
							Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageOthersTriggerHandler',
																					 'afterInsert', '', '', false, '', null, err.getMessage());
                        	QCC_LogUtilityHelper.createLogRecord(logRecord);
						}
					}
				}
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Others', 'EmailMessageOthersTriggerHandler', 
                'afterInsert', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
}