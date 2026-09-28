/**
* @description       : 
* @author            : Praveen Sampath
* @group             : 
* @last modified on  : 05-08-2024
* @last modified by  :
* Test class         : CaseFreightTriggerHandlerTest
************************************************************************************************
History
************************************************************************************************
2-Feb-2026   Tanya-Capgemini      CRM-10425 Code Security Remediation, PSV changes for System and User Mode for SOQL    
---------------------------------------------------------------------------------------------------------------------
**/
public with sharing class CaseFreightTriggerHandler {
    
    // ALL FINAL VARIABLES
    private static final Id RTID_QANTASFREIGHTHQR = Schema.SObjectType.QCC_Hotword_Queue_Routing__c.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_QCCQANTASFreight')).getRecordTypeId();
    private static final String MAILSUFFIX = CustomSettingsUtilities.getConfigDataMap('FreightTypeInQHQR');
    private static final Set<String> PORTCODES_FREIGHTSET = fetchPortCodes();
    //private static final Set<String> PREMIUMACCOUNTS_FREIGHTSET = fetchPremiumAccounts();
    private static final Set<String> HOTWORDS_FREIGHTSET = queryHotWordsWithFreightType(RTID_QANTASFREIGHTHQR, MAILSUFFIX);
    private static final Id RTID_CONTACT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_Contact')).getRecordTypeId();
    private static final Id RTID_FREIGHTACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_FreightAccount')).getRecordTypeId();
    private static final String PRODUCT_CARGO = CustomSettingsUtilities.getConfigDataMap('Product_CargoClientAirlines');
    private static final String MILESTONETYPE_OWNERSHIP = CustomSettingsUtilities.getConfigDataMap('MilestoneType_OwnershipAssignment_Name');
    private static final String MILESTONETYPE_CASERESOLUTION = CustomSettingsUtilities.getConfigDataMap('MilestoneType_CaseResolution_Name');
    private static final String MILESTONETYPE_CASECLOSURE = CustomSettingsUtilities.getConfigDataMap('MilestoneType_CaseClosure_Name');
    private static final String CASE_ASSIGNED_STATUS = CustomSettingsUtilities.getConfigDataMap('Case_Assigned_Status');
    private static final String CASE_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String CASE_RESOLVED_STATUS = CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusResolved');
    private static final String CASE_REOPENED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
    private static final String CASE_NEW_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusNew');
    private static final String QUEUE_FREIGHTCSUAU = CustomSettingsUtilities.getConfigDataMap('Freight_CSU_AU_Queue');
    private static final String EMPTY_STRING = '';
    private static final String CASEORIGIN_WEB_CASE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_Web');
    private static final String CASEORIGIN_FRTCUSTSERVICE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTCustService');
    private static final String WCT_FGE_CASE = CustomSettingsUtilities.getConfigDataMap('WebCaseType_FGE');
    private static final String WCT_FTATQ_CASE = CustomSettingsUtilities.getConfigDataMap('WebCaseType_FTATQ');
    private static final String WCT_GUF_CASE = CustomSettingsUtilities.getConfigDataMap('WebCaseType_GUF');
    private static final String PRIORITY_PREMIUM_CASE = CustomSettingsUtilities.getConfigDataMap('Priority_Premium');
    private static final String ORIGIN_FRTBOOKINGS_CASE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTBookings');
    private static final String RT_FREIGHTQUERY = CustomSettingsUtilities.getConfigDataMap('RT_FreightQuery');
    private static final String RT_QANTASFREIGHT = CustomSettingsUtilities.getConfigDataMap('RT_QANTASFREIGHT');
    private static final String RT_FREIGHTSHIPMENT = CustomSettingsUtilities.getConfigDataMap('RT_FreightShipment');
    private static final String RT_FREIGHTFEEDBACK = CustomSettingsUtilities.getConfigDataMap('RT_FreightFeedback');
    private static final String PRIORITY_URGENT_CASE = CustomSettingsUtilities.getConfigDataMap('Priority_Urgent');
    private static final String STATUS_AUTOCLOSED_CASE = CustomSettingsUtilities.getConfigDataMap('Status_AutoClosed');
    private static final String TYPE_INVALID_CASE = CustomSettingsUtilities.getConfigDataMap('Type_InvalidCase');
    private static final String SUBJECTLINE = CustomSettingsUtilities.getConfigDataMap('SubjectLineInCase');
    private static final String SLAPROCESS_FE = CustomSettingsUtilities.getConfigDataMap('SLAProcess_FE');
    private static final String DESCRIPTION_MAILTO = CustomSettingsUtilities.getConfigDataMap('DescriptionMailTo');
    private static final String DESCRIPTION_FROM = CustomSettingsUtilities.getConfigDataMap('DescriptionFrom');
    private static final String STATUS_OPEN_CASE = CustomSettingsUtilities.getConfigDataMap('Status_Open');
    private static final String PRIORITY_LOW_CASE = CustomSettingsUtilities.getConfigDataMap('Priority_Low');
    private static final String RT_FREIGHTINVOICE = CustomSettingsUtilities.getConfigDataMap('RT_Invoicing');
    private static final String TYPE_CLAIMSCASE = CustomSettingsUtilities.getConfigDataMap('Type_Claims');
    private static final String TYPE_BDCASE = CustomSettingsUtilities.getConfigDataMap('Type_BillingDiscrepancy');
    private static final String TYPE_INTERNALADMACM = CustomSettingsUtilities.getConfigDataMap('Type_InternalADMACM');
    private static final String ORIGIN_FRTPHONE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTPhone');
    private static final String CASE_ORIGIN_FRTJNB = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTJNB');
    private static final String RT_FreightClaims = CustomSettingsUtilities.getConfigDataMap('RT_Claims');
    private static final String RT_FreightEmail2Case = CustomSettingsUtilities.getConfigDataMap('RT_Email_to_Case');
    private static final String CASE_STYPE_CHECKINSTATUS = CustomSettingsUtilities.getConfigDataMap('SubType2_Check_in_Status');
    private static final String CASE_STYPE_MAPPING = CustomSettingsUtilities.getConfigDataMap('SubType2_Mapping');
    private static final String CASE_STYPE_DELIVERY = CustomSettingsUtilities.getConfigDataMap('SubType2_Delivery');
    private static final String CASE_STATUS_REPLYRECEIVED = CustomSettingsUtilities.getConfigDataMap('CaseStatusReplyReceived');//CRM-9928
    
    public static void onBeforeInsert(List<Case> newCaseList, Map<String, Id> freightRecordTypeMap,  Map<Id, Group> queueMap, Set<String> emailIds, Set<Id> freightPortIds, Set<Id> accountIds, Map<Id, Approval_Matrix__c> approvalMatrixMap, Map<Id, User> userMap) {
        try {
            List<Freight_Premium_Account__mdt>PREMIUMACCOUNTS_FREIGHTSET= fetchPremiumAccounts();
            List<Contact> contactList = CaseUtility.queryContacts(RTID_CONTACT, emailIds);
            // To append account ids from Contact list to the existing account id set
            for (Contact contactRecord : contactList) {
                if (contactRecord.AccountId != null) {
                    accountIds.add(contactRecord.AccountId);
                    //email for the contact is added to the emailIds set to avoid querying the same contact again
                }
            }
            
            Map<Id, Account> accountMap = CaseUtility.queryAccounts(RTID_FREIGHTACCOUNT, accountIds);
            Map<Id, Airport_Code__c> airPortCodesMap = new Map<Id, Airport_Code__c>([ SELECT Id, Name FROM Airport_Code__c WHERE Id IN :freightPortIds WITH USER_MODE]);//CRM-10425 PSV changes to run in User mode
            Id freightCSUAUQueueId = CaseUtility.getQueueIdByDevName(queueMap, QUEUE_FREIGHTCSUAU);
            Id systemAdminUpdatesUserId = CaseUtility.fetchUserIdByName(userMap, 'System Admin Updates');
            String temp;
            User currentUser=userMap.get(UserInfo.getUserId());
            system.debug('Before update Active Prod');
            for (Case caseRecord : newCaseList) {
                Account currentAccount = accountMap.get(caseRecord.AccountId);
                caseRecord =updateActiveProducts(caseRecord, null);
                caseRecord = processForAWB(caseRecord, null); //CRM-8979
                if((currentUser.Name != 'System Admin Updates' && currentUser.Name != 'Automated Process' && caseRecord.Origin != 'Webchat') && caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_QANTASFREIGHT)  && currentAccount != null && currentAccount.Freight_Region__c != caseRecord.Freight_Region__c){
                    caseRecord.AccountId.addError('Please Select Related Case Region Freight Account');
                }
                if(caseRecord.Status == CASE_CLOSED_STATUS) {
                    caseRecord.Original_Closed_Date__c = caseRecord.ClosedDate == null ? Date.today() : Date.newInstance(caseRecord.ClosedDate.Year(), caseRecord.ClosedDate.Month(), caseRecord.ClosedDate.Day());
                }
                // Reassign recordtype for freight cases from web, based on values in Freight_WebToCaseType__c field.
                if (caseRecord.Origin == CASEORIGIN_WEB_CASE ) {
                    if (String.isNotBlank(caseRecord.Freight_WebToCaseType__c)) {
                        if (caseRecord.Freight_WebToCaseType__c.containsIgnoreCase(WCT_FGE_CASE)) {
                            caseRecord.RecordTypeId = freightRecordTypeMap.get(RT_FREIGHTQUERY);
                            caseRecord.Priority = PRIORITY_LOW_CASE;
                            caseRecord.Status = STATUS_OPEN_CASE;
                        } else if (caseRecord.Freight_WebToCaseType__c.containsIgnoreCase(WCT_FTATQ_CASE)) {
                            caseRecord.RecordTypeId = freightRecordTypeMap.get(RT_FREIGHTSHIPMENT);
                            caseRecord.Priority = PRIORITY_LOW_CASE;
                            caseRecord.Status = STATUS_OPEN_CASE;
                        } else if (caseRecord.Freight_WebToCaseType__c.containsIgnoreCase(WCT_GUF_CASE)) {
                            caseRecord.RecordTypeId = freightRecordTypeMap.get(RT_FREIGHTFEEDBACK);
                            caseRecord.Priority = PRIORITY_LOW_CASE;
                            caseRecord.Status = STATUS_OPEN_CASE;
                        }
                    }
                } else if (caseRecord.Origin == ORIGIN_FRTBOOKINGS_CASE || caseRecord.Origin == CASEORIGIN_FRTCUSTSERVICE) {
                    caseRecord = assignUrgentPriorityForCasesWithHotWords(caseRecord);
                    if (String.isNotBlank(caseRecord.Description)) {
                        temp = CaseUtility.maskCreditCardAndUATPCardNumbers(caseRecord.Description);
                        if (!caseRecord.Description.equals(temp)) {
                            caseRecord.Description = temp;
                            caseRecord.HasCreditCard__c = true;
                        }
                    }
                    caseRecord = autoCloseAuotmaticReplayCases(caseRecord);
                }
                if (!(caseRecord.Origin == ORIGIN_FRTPHONE || systemAdminUpdatesUserId == UserInfo.getUserId())) {
                    caseRecord = autoAssignCaseToCSUQueue(caseRecord, freightCSUAUQueueId, airPortCodesMap.get(caseRecord.Freight_Port__c));
                }
                //CRM-8489
                if (caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_QANTASFREIGHT) && caseRecord.Sub_Type_2__c == 'AWB Stock Request') {
                    caseRecord.OwnerId = CaseUtility.getQueueIdByDevName(queueMap, 'Freight_Sales_Support_AU_Queue');
                }
                //CRM-8500
                if (caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_QANTASFREIGHT) 
                    //&& caseRecord.Sub_Type_2__c == 'New'
                    && caseRecord.Sub_Type_2__c != null && caseRecord.Sub_Type_2__c.equals('New')
                    //&& caseRecord.Sub_Type_1__c == 'Accounts') {
                    && caseRecord.Sub_Type_1__c != null && caseRecord.Sub_Type_1__c.equals('Accounts')) {
                        caseRecord.OwnerId = CaseUtility.getQueueIdByDevName(queueMap, 'Freight_Inside_Sales_AU_Queue');
                    }
                caseRecord = autoAssignPriorityAsPremium(caseRecord,PREMIUMACCOUNTS_FREIGHTSET);
                if (String.isNotBlank(caseRecord.Subject)) {
                    for (String caseSubject : Label.FreightCaseSubjects.split(';')) {
                        if (caseRecord.Subject.containsIgnoreCase(caseSubject) && caseRecord.Status != CASE_CLOSED_STATUS) {
                            caseRecord.Status = CASE_CLOSED_STATUS;
                        }
                    }
                }
                if (caseRecord.Origin == ORIGIN_FRTPHONE ) {//CRM-8382
                    caseRecord = autoAssignPriorityAsPremiumManualAccounts(caseRecord, accountMap.get(caseRecord.AccountId),PREMIUMACCOUNTS_FREIGHTSET);
                }
                if (caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTINVOICE) && (caseRecord.Type == TYPE_CLAIMSCASE || caseRecord.Type == TYPE_BDCASE)) {
                    caseRecord = assignUsersBasedOnApprovalMatrix(caseRecord, approvalMatrixMap, caseRecord.Type,  accountMap.get(caseRecord.AccountId), systemAdminUpdatesUserId);
                } else if (caseRecord.Problem_Type__c == TYPE_INTERNALADMACM) {
                    caseRecord = assignUsersBasedOnApprovalMatrix(caseRecord, approvalMatrixMap, caseRecord.Problem_Type__c, accountMap.get(caseRecord.AccountId), systemAdminUpdatesUserId);
                }
                //CRM-9065 auto-update Destination for auto-AWB-Refresh
                
                if((caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTQUERY) || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTSHIPMENT)
                    || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTFEEDBACK) || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_QANTASFREIGHT)
                    || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTINVOICE) || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FreightClaims) 
                    || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FreightEmail2Case))  &&
                   String.isNotEmpty(caseRecord.Freight_AWB_Number__c) && String.isNotEmpty(caseRecord.Sub_Type_1__c) 
                   && String.isNotEmpty(caseRecord.Sub_Type_2__c))
                {
                    caseRecord=updateAirportCodeBasedOnAWB(caseRecord,null);
                }

                //CRM-9836:INC2843705 Manual case created to remain with Case Creator as Case Owner
                if (caseRecord.Origin == ORIGIN_FRTPHONE && !CustomSettingsUtilities.getConfigDataMap('Freight_Machine_Users').containsIgnoreCase(currentUser.Name)) {
                    caseRecord.OwnerId = currentUser.Id;
                }
            }
            assignEntitlement(newCaseList, accountIds, freightPortIds);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'onBeforeInsert', '', '', false, '', ex);
        }
    }
    
    // Only Freight Record Type Cases are passed as parameter
    public static void onBeforeUpdate(Map<Id,Case> oldCasesMap, Map<Id, Case> newCasesMap, Map<String, Id> freightRecordTypeMap, Set<Id> freightPortIds, Set<Id> accountIds, Map<Id, Approval_Matrix__c> approvalMatrixMap, Map<Id, User> userMap) {
        try {
            Case oldCaseRecord;
            List<Freight_Premium_Account__mdt> PREMIUMACCOUNTS_FREIGHTSET= fetchPremiumAccounts();
            Map<Id, Account> accountMap = CaseUtility.queryAccounts(RTID_FREIGHTACCOUNT, accountIds);
            Id systemAdminUpdatesUserId = CaseUtility.fetchUserIdByName(userMap, 'System Admin Updates');
            String temp;
            User currentUser=userMap.get(UserInfo.getUserId());
            for (Case caseRecord : newCasesMap.values()) {
                Account currentAccount = accountMap.get(caseRecord.AccountId);
                oldCaseRecord = oldCasesMap.get(caseRecord.Id);
                caseRecord = processForAWB(caseRecord, oldCaseRecord); //CRM-8979
                caseRecord = updateActiveProducts(caseRecord, oldCaseRecord);
                
                if(caseRecord.Status == CASE_CLOSED_STATUS) {
                    caseRecord.Original_Closed_Date__c = caseRecord.ClosedDate == null ? Date.today() : Date.newInstance(caseRecord.ClosedDate.Year(), caseRecord.ClosedDate.Month(), caseRecord.ClosedDate.Day());
                }
                if (caseRecord.Origin == ORIGIN_FRTBOOKINGS_CASE || caseRecord.Origin == CASEORIGIN_FRTCUSTSERVICE || caseRecord.Origin == ORIGIN_FRTPHONE) {//CRM-8382
                    caseRecord = autoAssignPriorityAsPremiumManualAccounts(caseRecord, accountMap.get(caseRecord.AccountId),PREMIUMACCOUNTS_FREIGHTSET);
                    if (String.isNotBlank(caseRecord.Description)) {
                        temp = CaseUtility.maskCreditCardAndUATPCardNumbers(caseRecord.Description);
                        if (!caseRecord.Description.equals(temp)) {
                            caseRecord.Description = temp;
                            caseRecord.HasCreditCard__c = true;
                        }
                    }
                }
                if ((caseRecord.Status == STATUS_OPEN_CASE || caseRecord.Status == CASE_REOPENED_STATUS || caseRecord.Status == CASE_NEW_STATUS) &&
                    caseRecord.OwnerId !=  oldCasesMap.get(caseRecord.Id).OwnerId && string.valueOf(oldCasesMap.get(caseRecord.Id).OwnerId).startswith('00G')) {
                        caseRecord.Status = CASE_ASSIGNED_STATUS;
                    }
                //CRM-9928  
 Integer emailmsglist =[select id from EmailMessage where ParentId =:caseRecord.Id and Incoming =true WITH SYSTEM_MODE].size();
                Id systemAdminUpdatesUsernameId = CaseUtility.fetchUserIdByName(userMap, 'System Admin Updates');
                
     Date YearAgo = Date.today().addYears(-1);
    if (String.isNotBlank(caseRecord.Subject)) {
                    for (String caseSubject : Label.FreightCaseSubjects.split(';')) {
                        if (caseRecord.Subject.containsIgnoreCase(caseSubject) && caseRecord.Status != CASE_CLOSED_STATUS && emailmsglist == 1  && caseRecord.CreatedDate.date() >= YearAgo &&  systemAdminUpdatesUsernameId == UserInfo.getUserId() ) {
                            caseRecord.Status = CASE_CLOSED_STATUS;
                            break;
                       }else if(caseRecord.Subject.containsIgnoreCase(caseSubject) && caseRecord.Status != CASE_CLOSED_STATUS  && caseRecord.CreatedDate.date() >= YearAgo) {
                        caseRecord.Status = CASE_STATUS_REPLYRECEIVED;
                           break;
                        }else if(caseRecord.Subject.containsIgnoreCase(caseSubject) && caseRecord.Status != CASE_CLOSED_STATUS  && caseRecord.CreatedDate.date() < YearAgo) {
                         caseRecord.Status = CASE_CLOSED_STATUS;
                           break;
                        }
                    }
                }

                //CRM-8489
                if (caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_QANTASFREIGHT) 
                    && caseRecord.Sub_Type_2__c != oldCasesMap.get(caseRecord.Id).Sub_Type_2__c 
                    && caseRecord.Sub_Type_2__c == 'AWB Stock Request') {
                        caseRecord.OwnerId = CaseUtility.getQueueIdByDevName(CaseTriggerHandler.QUEUE_GROUPMAP, 'Freight_Sales_Support_AU_Queue');
                    }
                //CRM-8500
                if (caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_QANTASFREIGHT) 
                    && (caseRecord.Sub_Type_2__c != oldCasesMap.get(caseRecord.Id).Sub_Type_2__c || caseRecord.Sub_Type_1__c != oldCasesMap.get(caseRecord.Id).Sub_Type_1__c)
                    //&& caseRecord.Sub_Type_2__c == 'New'
                    && caseRecord.Sub_Type_2__c != null && caseRecord.Sub_Type_2__c.equals('New')
                    //&& caseRecord.Sub_Type_1__c == 'Accounts') {
                    && caseRecord.Sub_Type_1__c != null && caseRecord.Sub_Type_1__c.equals('Accounts')) {
                        caseRecord.OwnerId = CaseUtility.getQueueIdByDevName(CaseTriggerHandler.QUEUE_GROUPMAP, 'Freight_Inside_Sales_AU_Queue');
                    }
                if (caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTINVOICE) && (caseRecord.Type == TYPE_CLAIMSCASE || caseRecord.Type == TYPE_BDCASE)) {
                    caseRecord = assignUsersBasedOnApprovalMatrix(caseRecord, approvalMatrixMap, caseRecord.Type,  accountMap.get(caseRecord.AccountId), systemAdminUpdatesUserId);
                } else if (caseRecord.Problem_Type__c == TYPE_INTERNALADMACM) {
                    caseRecord = assignUsersBasedOnApprovalMatrix(caseRecord, approvalMatrixMap, caseRecord.Problem_Type__c, accountMap.get(caseRecord.AccountId), systemAdminUpdatesUserId);
                }
                //CRM-9065 auto-update Destination for auto-AWB-Refresh
                if((caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTQUERY) || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTSHIPMENT)
                    || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTFEEDBACK) || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_QANTASFREIGHT)
                    || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FREIGHTINVOICE) || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FreightClaims) 
                    || caseRecord.RecordTypeId == freightRecordTypeMap.get(RT_FreightEmail2Case)) 
                   &&
                   String.isNotEmpty(caseRecord.Freight_AWB_Number__c) && (oldCaseRecord.Sub_Type_2__c!=caseRecord.Sub_Type_2__c || oldCaseRecord.Port_Override_Flag__c!=caseRecord.Port_Override_Flag__c) &&
                   String.isNotEmpty(caseRecord.Sub_Type_2__c))
                {
                    system.debug('>>> inside before update block');
                    caseRecord=updateAirportCodeBasedOnAWB(caseRecord,oldCaseRecord);
                }
                
                
            }
            assignEntitlement(newCasesMap.values(), accountIds, freightPortIds);
            //restrictAccountUpdateAfterClose(oldCasesMap,newCasesMap);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'onBeforeUpdate', '', '', false, '', ex);
        }
    }
    
    public static void onAfterUpdate(Map<Id,Case> oldCasesMap, Map<Id, Case> newCasesMap) {
        try {
            Set<Id> caseStatusChangedIds = new Set<Id>();
            
            for (Case caseRecord : newCasesMap.values()) {
                if (caseRecord.Status != oldCasesMap.get(caseRecord.Id).Status) {
                    caseStatusChangedIds.add(caseRecord.Id);
                }
            }
            milestoneCompletion(caseStatusChangedIds);
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'CaseFreightTriggerHelper', 'onAfterUpdate', '', '', false, String.valueOf(newCasesMap == NULL ? NULL : newCasesMap.keySet()), ex);
        }
    }
    /*-----------------------------------------------------------------------------------------------------------      
Method Name:        autoAssignCaseToCSUQueue
TestMethod Name:    testautoAssignCaseToCSUQueue
Description:        This method automates the case assignment for the mentioned ports
in Freight_Ports__mdt to Freight CSU AU Queue
Parameter:          New Case Record, Freight CSU AU Queue Id, Airport Code object
Jira Story:         FCRM-860
Date Implemented:   17 Jan 2022
Sprint Freight      151
-------------------------------------------------------------------------------------------------------------*/
    public static Case autoAssignCaseToCSUQueue(Case caseRecord, Id queueId, Airport_Code__c airportRecord) {
        try {
            if (airportRecord != null) {
                for (String portCode : PORTCODES_FREIGHTSET) {
                    if(portCode.contains(airportRecord.Name)) {
                        caseRecord.OwnerId = queueId;
                        return caseRecord;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'autoAssignCaseToCSUQueue', '', '', false, '', ex);
        }
        return caseRecord;
    }
    /*----------------------------------------------------------------------------------------------------------      
Method Name:        autoAssignPriorityAsPremium
TestMethod Name:    testautoAssignCaseToCSUQueue
Description:        This method automates the case Priority to be Premium based on the Account details
in the Case description or SuppliedEmail field
Parameter:          Case New Record
Jira Story:         FCRM-880
Date Implemented:   15 Feb 2022
Sprint Freight      153
-----------------------------------------------------------------------------------------------------------*/
    public static Case autoAssignPriorityAsPremium(Case caseRecord,List<Freight_Premium_Account__mdt> PREMIUMACCOUNTS_FREIGHTSET) {
        try {
            String description = caseRecord.Description;
            for (Freight_Premium_Account__mdt premiumAcc : PREMIUMACCOUNTS_FREIGHTSET) {
                if (String.isNotBlank(caseRecord.SuppliedEmail) && (caseRecord.Origin == ORIGIN_FRTBOOKINGS_CASE || caseRecord.Origin == CASEORIGIN_FRTCUSTSERVICE || caseRecord.Origin == CASEORIGIN_WEB_CASE)) {
                    
                    if ((String.isNotBlank(caseRecord.SuppliedEmail) && caseRecord.SuppliedEmail.substringAfter('@').containsIgnoreCase(premiumAcc.Premium_Accounts__c) ) && caseRecord.Freight_Region__c.contains(premiumAcc.Region__c) && premiumAcc.Tier__c=='Tier 1')  {
                        caseRecord.Priority = PRIORITY_PREMIUM_CASE;
                        system.debug('caseRecord.Priority**'+caseRecord.Priority );
                        break;
                    }
                    else if((String.isNotBlank(caseRecord.SuppliedEmail) && caseRecord.SuppliedEmail.substringAfter('@').containsIgnoreCase(premiumAcc.Premium_Accounts__c) ) && caseRecord.Freight_Region__c.contains(premiumAcc.Region__c) && premiumAcc.Tier__c=='Tier 2')  {
                        caseRecord.Priority = PRIORITY_URGENT_CASE;
                        system.debug('caseRecord.Priority***'+caseRecord.Priority );
                        break;
                    }
                    else if (String.isNotBlank(description) && description.containsIgnoreCase(DESCRIPTION_FROM) && (description.indexOf('@')+1) == description.indexOfIgnoreCase(premiumAcc.Premium_Accounts__c)) {
                        System.debug('inside premiumelseif***'+    caseRecord.Priority);
                        caseRecord.Priority = PRIORITY_PREMIUM_CASE;
                        break;
                    }else if (caseRecord.Origin == ORIGIN_FRTBOOKINGS_CASE){
                        caseRecord.Priority = caseRecord.Priority;                        
                    }else{
                        caseRecord.Priority = PRIORITY_LOW_CASE;
                        break;
                    }
                }
                
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'autoAssignPriorityAsPremium', '', '', false, '', ex);
        }
        return caseRecord;
    }
    
    /*----------------------------------------------------------------------------------------------------------      
Method Name:        assignUrgentPriorityForCasesWithHotWords
TestMethod Name:    testassignUrgentPriorityForCasesWithHotWords
Description:        This method automates the case Priority to be Urgent based on Hot words 
Parameter:          Case New Record
Jira Story:         FCRM-894, FCRM-943
Date Implemented:   28 March 2022
Sprint Freight      156
------------------------------------------------------------------------------------------------------------*/
    public static Case assignUrgentPriorityForCasesWithHotWords(Case caseRecord) {
        try {
            String description = caseRecord.Description;
            if (caseRecord.Priority != PRIORITY_PREMIUM_CASE) {
                for (String hotWord : HOTWORDS_FREIGHTSET) {
                    if (String.isNotBlank(caseRecord.SuppliedEmail) && caseRecord.SuppliedEmail.containsIgnoreCase(hotWord)) {
                        caseRecord.Priority = PRIORITY_URGENT_CASE;
                        break;
                    }else if (String.isNotBlank(description) && description.containsIgnoreCase(DESCRIPTION_FROM) && description.indexOf('@') == description.indexOfIgnoreCase(hotWord)) {
                        caseRecord.Priority = PRIORITY_URGENT_CASE;
                        break;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'assignUrgentPriorityForCasesWithHotWords', '', '', false, '', ex);
        }
        return caseRecord;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        autoCloseAuotmaticReplayCases
Description:        Set status and type fields to particular values on case 
if subject contains 'Automatic reply:'
Parameter:          Case New Record
--------------------------------------------------------------------------------------*/
    public static Case autoCloseAuotmaticReplayCases(Case caseNewRecord) {
        try {
            if (caseNewRecord.Subject != NULL && caseNewRecord.Subject.containsIgnoreCase(SUBJECTLINE)) {
                caseNewRecord.Status = STATUS_AUTOCLOSED_CASE;
                caseNewRecord.Type = TYPE_INVALID_CASE;
                caseNewRecord.Approve__c = EMPTY_STRING;
                caseNewRecord.Condition_Met__c = EMPTY_STRING;
                caseNewRecord.Problem_Type__c = EMPTY_STRING;
                caseNewRecord.Sub_Type__c = EMPTY_STRING;
                caseNewRecord.Sub_Type_1__c = EMPTY_STRING;
                caseNewRecord.Group__c = EMPTY_STRING;
                caseNewRecord.Reasons_for_Credit_and_Action_Taken__c = EMPTY_STRING;
                caseNewRecord.Risk__c = EMPTY_STRING;
                caseNewRecord.Reason_for_Waiver__c = EMPTY_STRING;
                caseNewRecord.Waiver_Sub_Type__c = EMPTY_STRING;
                caseNewRecord.Sub_Type_2__c = EMPTY_STRING;
                caseNewRecord.Category__c = EMPTY_STRING;
                caseNewRecord.Secondary_Reasons_for_Credit__c = EMPTY_STRING;
                caseNewRecord.Request_Reason_Sub_Type__c = EMPTY_STRING;
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'autoCloseAuotmaticReplayCases', '', '', false, '', ex);
        }
        return caseNewRecord;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        autoAssignPriorityAsPremiumManualAccounts
TestMethod Name:    testautoAssignCaseToCSUQueue
Description:        This method automates the case Priority to be Premium based on the Account Changed Manually
Parameter:          Case New Record, Set Of Premium Account Ids
Jira Story:         FCRM-887
Date Implemented:   1 March 2022
Sprint Freight      154
--------------------------------------------------------------------------------------*/
    public static Case autoAssignPriorityAsPremiumManualAccounts(Case caseRecord, Account accountRecord, List<Freight_Premium_Account__mdt> PREMIUMACCOUNTS_FREIGHTSET) {
        try {
            if (accountRecord != null && accountRecord.RecordTypeId == RTID_FREIGHTACCOUNT && String.isNotBlank(accountRecord.Email__c)) {
                for(Freight_Premium_Account__mdt premiumDomain : PREMIUMACCOUNTS_FREIGHTSET) {
                    if ((String.isNotBlank(accountRecord.Email__c) && accountRecord.Email__c.substringAfter('@').containsIgnoreCase(premiumDomain.Premium_Accounts__c) && caseRecord.Freight_Region__c.contains(premiumDomain.Region__c) && premiumDomain.Tier__c=='Tier 1')) { 
                        caseRecord.Priority = PRIORITY_PREMIUM_CASE;
                        break;
                        
                    }else if((String.isNotBlank(accountRecord.Email__c) && accountRecord.Email__c.substringAfter('@').containsIgnoreCase(premiumDomain.Premium_Accounts__c) && caseRecord.Freight_Region__c.contains(premiumDomain.Region__c) && premiumDomain.Tier__c=='Tier 2')) { 
                        caseRecord.Priority = PRIORITY_URGENT_CASE;
                        break;
                    }
                    
                }
                return caseRecord;
            }} catch (Exception ex) {
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'autoAssignPriorityAsPremiumManualAccounts', '', '', false, '', ex);
            }
        return caseRecord;
    }
    /*---------------------------------------------------------------------------------------------------------------------      
Method Name:        assignUsersBasedOnApprovalMatrix
TestMethod Name:    testautoAssignCaseToCSUQueue
Description:        This method align's the approval matrix record's approver fields with 
the case record's user lookup field
Parameter:          Case New Record, Map of ApprovalMatrix, String either Waiver Type/ Problem,Account, System Admin Update
----------------------------------------------------------------------------------------------------------------------*/
    public static Case assignUsersBasedOnApprovalMatrix(Case caseRecord, Map<Id, Approval_Matrix__c> approvalMatrixMap, String type, Account accountRecord, Id systemAdminUpdatesUserId) {
        try {
            for (Approval_Matrix__c amRecord : approvalMatrixMap.values()) {
                if (amRecord.Type__c == type && accountRecord != null && amRecord.Region__c == accountRecord.BillingCountry)
                {
                    caseRecord.Reports_To__c = amRecord.Manager__c;
                    caseRecord.AM_s_Manager__c = amRecord.Team_Lead__c;
                    caseRecord.Requested_By__c = amRecord.Level_3_Approver__c;
                    return caseRecord;
                }
            }
            caseRecord.Manager_s_Manager__c = systemAdminUpdatesUserId;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'assignUsersBasedOnApprovalMatrix', '', '', false, '', ex);
        }
        return caseRecord;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        assignEntitlement
Description:        Method for creation or assignment Entitlement for Account
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/
    public static void assignEntitlement(List<Case> caseNewList, Set<Id> accountIds, Set<Id> freightPortIds){
        try {
            // To Identify whether Freight Account is associated with any Entitlement or not
            // If Entitlement exist for Account, relevant entitlement will be associated with Account
            // Else respective Entitlement record created for Account
            Map<Id, Entitlement> entitlementMap = new Map<Id, Entitlement>();
            Entitlement entitlementRecord;
            for (Entitlement eachEntitlement : [ SELECT AccountId, Name FROM Entitlement WHERE AccountId IN :accountIds WITH SYSTEM_MODE]) //CRM-10425 PSV changes to run in User mode
            {
                entitlementMap.put(eachEntitlement.AccountId, eachEntitlement);
            }
            // Querying Entitlemnet Process
            SlaProcess process = [ SELECT Name FROM SlaProcess WHERE Name = :SLAPROCESS_FE WITH SYSTEM_MODE]; //CRM-10425 PSV changes to run in USER_MODE
            List<Entitlement> entitlementsToInsert = new List<Entitlement>();
            for (Account eachAccount : [ SELECT Id, Name FROM Account WHERE Id IN :accountIds WITH USER_MODE]) //CRM-10425 PSV changes to run in user mode
            {
                if (entitlementMap.containsKey(eachAccount.Id)) {
                    continue;
                }
                // New Entitlement records creation data
                entitlementRecord = new Entitlement(
                    // Entitlement is based on Account Name + Entitlement
                    Name       = eachAccount.Name + ' - Entitlement',      
                    SlaProcessId   = process.Id,
                    StartDate     = Date.today().addDays(-1),   
                    Enddate     = Date.newInstance(2099, 12, 31),   
                    AccountId     = eachAccount.Id
                );
                entitlementsToInsert.add(entitlementRecord);
                
            }
            
            // Insertion of required Entitlements
            if (!entitlementsToInsert.isEmpty()) {
                insert as system entitlementsToInsert;
            }
            
            for(Entitlement objEntitlement: entitlementsToInsert){
                entitlementMap.put(objEntitlement.AccountId, objEntitlement);
            }
            
            // To hold PortId vs State code map
            Map<Id, String> portIdVsStateCodeMap = new map<Id, string>();
            
            // Retrieving States for relevant Stations or Port Code
            for(Airport_Code__c eachCode : [ SELECT Id, Name, Freight_Station_Name__c, Freight_Airport_State_Code__c FROM Airport_Code__c WHERE Id IN :freightPortIds WITH USER_MODE]) //CRM-10425 PSV changes to run in User mode
            {
                portIdVsStateCodeMap.put(eachCode.Id, eachCode.Freight_Airport_State_Code__c); 
            }
            
            // Assignement of ENtitlement to Case to associate required Milestone with Case
            for (Case eachCase : caseNewList) {
                // Assigning Entitlment to the Case
                if (eachCase.AccountId == null || entitlementMap.get(eachCase.AccountId) == null){
                    continue;
                }
                eachCase.EntitlementId = entitlementMap.get(eachCase.AccountId).Id;
                // Assigning State Code to Case based on Port selected
                if(!String.isBlank(eachCase.Freight_Port__c)) {
                    if(portIdVsStateCodeMap.get(eachCase.Freight_Port__c) != null)
                        eachCase.Freight_Port_State_Code__c = portIdVsStateCodeMap.get(eachCase.Freight_Port__c);
                } else {
                    eachCase.Freight_Port_State_Code__c = '';
                }
            }
        } catch(QueryException ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'CaseFreightTriggerHelper', 'assignEntitlement', '', '', false, '', ex);
            throw new QueryException('Exception occured in querying account');
        }catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'CaseFreightTriggerHelper', 'assignEntitlement', '', '', false, '', ex);
        }
    } 
    
    /*--------------------------------------------------------------------------------------      
Method Name:    milestoneCompletion
Description:    Complete milestone records based on change in case status
Parameter:       
----------------------------------------------------------------------------------------*/  
    public static void milestoneCompletion(Set<Id> caseIds) {
        try {
            Set<String> milestoneTypes = new Set<String>{ MILESTONETYPE_OWNERSHIP, MILESTONETYPE_CASERESOLUTION, MILESTONETYPE_CASECLOSURE };
                DateTime dateOfCompletion = System.now();
            List<CaseMilestone> caseMilestonesToUpdate = new List<CaseMilestone>();
            for (CaseMilestone cmRecord : [ SELECT Case.Status, MilestoneType.Name, CompletionDate FROM CaseMilestone WHERE MilestoneType.Name IN :milestoneTypes AND CaseId IN :caseIds WITH SYSTEM_MODE]) //CRM-10425 PSV changes to run in User mode
            {
                if (cmRecord.MilestoneType.Name == MILESTONETYPE_OWNERSHIP) {
                    if (cmRecord.Case.Status == CASE_ASSIGNED_STATUS) {
                        cmRecord.CompletionDate = dateOfCompletion;
                        caseMilestonesToUpdate.add(cmRecord);
                    }
                } else if (cmRecord.MilestoneType.Name == MILESTONETYPE_CASERESOLUTION) {
                    if (cmRecord.Case.Status == CASE_RESOLVED_STATUS) {
                        cmRecord.CompletionDate = dateOfCompletion;
                        caseMilestonesToUpdate.add(cmRecord);
                    } else if (cmRecord.Case.Status == CASE_REOPENED_STATUS) {
                        cmRecord.CompletionDate = NULL;
                        caseMilestonesToUpdate.add(cmRecord);
                    }
                } else if (cmRecord.MilestoneType.Name == MILESTONETYPE_CASECLOSURE) {
                    if (cmRecord.Case.Status == CASE_CLOSED_STATUS) {
                        cmRecord.CompletionDate = dateOfCompletion;
                        caseMilestonesToUpdate.add(cmRecord);
                    }
                }
            }
            if (!caseMilestonesToUpdate.isEmpty()) {
                update as system caseMilestonesToUpdate; //CRM-10425 PSV changes to run in user mode
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'CaseFreightTriggerHelper', 'milestoneCompletion', '', '', false, String.valueOf(caseIds), ex);
        }
    }
    /*-----------------------------------------------------------------------------------------------------------      
Method Name:        fetchPortCodes
Description:        This method stores all the non blank Port_Code__c field values from 
Freight_Ports__mdt custom metadata in a set of strings.
Returned Value:     Set of Strings
-------------------------------------------------------------------------------------------------------------*/
    public static Set<String> fetchPortCodes() {
        Set<String> portCodes = new Set<String>();
        try {
            Map<String, Freight_Ports__mdt> portMdts = Freight_Ports__mdt.getAll();
            if (portMdts != null) {
                for (Freight_Ports__mdt portMdt : portMdts.values()) {
                    if (String.isNotBlank(portMdt.Port_Code__c)) {
                        portCodes.add(portMdt.Port_Code__c);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'fetchPortCodes', '', '', false, '', ex);
        }
        return portCodes;
    }
    /*-----------------------------------------------------------------------------------------------------------      
Method Name:        fetchPremiumAccounts
Description:        This method stores all the non blank Premium_Accounts__c field values from 
Freight_Premium_Account__mdt custom metadata in a set of strings.
Returned Value:     Set of Strings
-------------------------------------------------------------------------------------------------------------*/
    public static List<Freight_Premium_Account__mdt> fetchPremiumAccounts() {
        //Set<String> premiumAccounts = new Set<String>();
        List<Freight_Premium_Account__mdt> premiumAccounts = new List<Freight_Premium_Account__mdt>();
        for (Freight_Premium_Account__mdt freightMetadata :  Freight_Premium_Account__mdt.getAll().values()) {
           // premiumAccounts.add(freightMetadata.Premium_Accounts__c);
            premiumAccounts.add(freightMetadata);
        }
        return premiumAccounts;
    }
    /*-----------------------------------------------------------------------------------------------------------      
Method Name:        queryHotWordsWithFreightType
Description:        This method stores all the non blank Hot_words__c field values from 
QCC_Hotword_Queue_Routing__c custom metadata in a set of strings.
Returned Value:     Set of Strings
-------------------------------------------------------------------------------------------------------------*/
    public static Set<String> queryHotWordsWithFreightType(Id rtId, String freightType) {
        Set<String> hotWordsOfFreightType = new Set<String>();
        try {
            for (QCC_Hotword_Queue_Routing__c hqrRecord : [ SELECT Id, Hot_words__c, freight_Type__c FROM QCC_Hotword_Queue_Routing__c 
                                                           WHERE RecordTypeId = :rtId WITH USER_MODE ])  //CRM-10425 PSV changes to run in User mode                                                 
            {
                if (String.isNotBlank(hqrRecord.Hot_words__c) && String.isNotBlank(hqrRecord.freight_Type__c) && hqrRecord.freight_Type__c.containsIgnoreCase(MAILSUFFIX)) {
                    for (String hotWord : hqrRecord.Hot_words__c.split(',')) {
                        if (String.isNotBlank(hotWord)) {
                            hotWordsOfFreightType.add(hotWord);
                        }
                    }
                } 
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 'queryHotWordsWithFreightType', '', '', false, '', ex);
        }
        return hotWordsOfFreightType;
    } 
    public static Map<Id, Account> fetchAccounts(Map<Id, Account> accountMap, Set<Id> accountIds) {
        Map<Id, Account> newAccountMap = new Map<Id, Account>();
        if (accountMap != null) {
            for (Account accountRecord : accountMap.values()) {
                if (accountRecord.RecordTypeId == RTID_FREIGHTACCOUNT && accountIds.contains(accountRecord.Id)) {
                    newAccountMap.put(accountRecord.Id, accountRecord);
                }
            }
        }
        return newAccountMap;
    }
    
    
    public static Case processForAWB(Case caseRecord, Case oldCaseRecord) { //New method added as a part of CRM-8979
        try {
            Integer awbPrefixVal;
            if (oldCaseRecord == null || caseRecord.Freight_AWB_Number__c != oldCaseRecord.Freight_AWB_Number__c) {
                if (String.isBlank(caseRecord.Freight_AWB_Number__c)) {
                    caseRecord.Airline__c = EMPTY_STRING;
                } else {
                    awbPrefixVal = Integer.valueOf(caseRecord.Freight_AWB_Number__c.substringBefore('-'));
                    // FCRM-866, FRTWEB-8762 If AWB number doesn't start with '081', the airline should be blank
                    if (awbPrefixVal != 81) {
                        caseRecord.Product__c = PRODUCT_CARGO;
                    }
                    caseRecord.Airline__c = CustomSettingsUtilities.getConfigDataMap('Freight_AWB_'+awbPrefixVal);
                }
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FREIGHT', 'CaseFreightTriggerHandler', 
                                    'processForAWB', '', '', false, '', ex
                                   );
        }
        return caseRecord;
    }
    
    public static Case updateActiveProducts(Case caseRecord, Case oldCaseRecord) { 
        try{
            
            List<String> pickListValuesActive = new List<String>();
            List<String> pickListValuesInactive = new List<String>();
            Schema.DescribeFieldResult fieldResult = Case.Product__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple) {
                if(pickListVal.isActive()) {
                    pickListValuesActive.add(pickListVal.getLabel());
                }else {
                    pickListValuesInactive.add(pickListVal.getLabel());
                }
            }
            
            String productVal;
            if (caseRecord.Product__c != null && !pickListValuesActive.contains(caseRecord.Product__c)){
                productVal = String.valueOf(caseRecord.Product__c);
                caseRecord.Product__c = CustomSettingsUtilities.getConfigDataMap('QF_iCargo_'+productVal);
            }
        }catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Types', 'FREIGHT', 'CaseFreightTriggerHandler', 
                                    'updateActiveProducts', '', '', false, '', ex);
        }
        return caseRecord;
    }      
    //CRM-9065 auto-update Destination for auto-AWB-Refresh
    public static Case updateAirportCodeBasedOnAWB(Case caseRecord, Case oldCaseRecord)  
    {
        try {
            if(caseRecord!=null)
            {
                List<AWB_Relationship__c> AWBRecord = [select id,AWB__c from AWB_Relationship__c where Case__c =:caseRecord.Id WITH USER_MODE];//CRM-10425 PSV changes to run in User mode
                if(!AWBRecord.isEmpty()){
                    AWB_Info__c newAWB = [select id,Product__c,Name,Port_Override_Flag__c,Pieces_Arrived__c,Ready_for_Collection__c,Pieces_for_Collection__c,Freight_Origin__c,
                                          Freight_Weight__c,Freight_AWB_Handling_Code__c,Freight_AWB_Pieces__c,Freight_Destination__c,Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c from AWB_Info__c where Name =: caseRecord.Freight_AWB_Number__c WITH SYSTEM_MODE];//newAWB //CRM-10425 PSV changes to run in User mode
                    
                    List<Airport_Code__c> getMatchingAirportCodes=[select id,name from Airport_Code__c where (name =:newAWB.Freight_Destination__c or name=: newAWB.Freight_Origin__c) AND QF_Freight_Presence__c=: true WITH SECURITY_ENFORCED];
                    if(getMatchingAirportCodes!=null && getMatchingAirportCodes.size()>0)
                    {
                        for(Airport_Code__c getPort:getMatchingAirportCodes)
                        {
                            set<String> Port_Override_Flag_Combinations = new set<String>{CASE_STYPE_MAPPING,CASE_STYPE_CHECKINSTATUS,CASE_STYPE_DELIVERY};//CRM-9847
                            String key = caseRecord.Type+'-'+caseRecord.Sub_Type_1__c+'-'+caseRecord.Sub_Type_2__c;
                     if((caseRecord.Port_Override_Flag__c == true || Port_Override_Flag_Combinations.contains(key)) && oldCaseRecord.Port_Override_Flag__c !=true  && newAWB.Freight_Destination__c.containsIgnoreCase(getPort.name))
                              {
                                caseRecord.Freight_Port__c=getPort.id;//Port = AWB Destination
                                newAWB.Freight_Port__c = caseRecord.Freight_Port__c;
                                caseRecord.Port_Override_Flag__c=true;
                                caseRecord.Freight_AWB_Status__c = 'Update Port to AWB Destination';
                            } 
                          
                           else if((!caseRecord.Port_Override_Flag__c == true && !Port_Override_Flag_Combinations.contains(key)) || (!caseRecord.Port_Override_Flag__c == true && Port_Override_Flag_Combinations.contains(key)) && newAWB.Freight_Origin__c.containsIgnoreCase(getPort.name) )
                 {
                                caseRecord.Freight_Port__c=getPort.id;//Port = AWB Origin
                                newAWB.Freight_Port__c = caseRecord.Freight_Port__c;//new fix for awb 9611
                                caseRecord.Port_Override_Flag__c=false;
                                caseRecord.Freight_AWB_Status__c = 'Update Port to AWB Origin';
                            }   
                        }
                        }
                    }        
                }
            }catch(QueryException ex){
                 CreateLogs.insertLogRec( 'Log Exception Logs Rec Types', 'FREIGHT', 'CaseFreightTriggerHandler', 
                                        'updateAirportCodeBasedOnAWB', '', '', false, '', ex);
                throw new QueryException('Exception occurred in querying AWBinfo');                        
            }
         catch (Exception ex) {
            system.debug('Exception has occurred in updateAirportCodeBasedOnAWB'+ ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Types', 'FREIGHT', 'CaseFreightTriggerHandler', 
                                    'updateAirportCodeBasedOnAWB', '', '', false, '', ex);
        }
        return caseRecord;
    } 
    /*
public static void restrictAccountUpdateAfterClose(Map<Id,Case> oldCaseMap, Map<Id,Case> newCaseMap){
for(Case cas: newCaseMap.values()){
if((oldCaseMap.get(cas.Id).AccountId != cas.AccountId) && cas.Status== 'Closed'){
cas.AccountId.addError('Account cannot be changed once case is closed.');
}
}
}
*/
}