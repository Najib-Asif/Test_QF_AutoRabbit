/**
* @description       : 
* @author            : Praveen Sampath
* @group             : 
* @last modified on  : 12-11-2024
* @last modified by  : Praveen Sampath
* Test Class         : EmailMessageFreightTriggerHandlerTest
* History 			 : Refactored the codes by removing system.debug and commented coded lines
* 					 : Changes to accomodate changes of JIRA CRM-12543
* 					 : Changes to accomodate changes of JIRA CRM-12762
*					 : Changes to accomodate changes of JIRA CRM-13906 for Internation Koel
*					 : Changes to accomodate changes of JIRA CRM-13734 for CSU Closed Priyanka
* @last modified on  : 08-26-2026
* @last modified by  : Truong Nguyen - SFRBACPSV-711 Code Security Remediation
**/
public with sharing class EmailMessageFreightTriggerHandler { // SFRBACPSV-711: Added with sharing

    private static final String RT_QCCQANTASFREIGHT = CustomSettingsUtilities.getConfigDataMap('RT_QCCQANTASFreight');
    private static final String RT_FREIGHTACCOUNT = CustomSettingsUtilities.getConfigDataMap('RT_FreightAccount');
    private static final String RT_QANTASFREIGHT = CustomSettingsUtilities.getConfigDataMap('RT_QANTASFREIGHT');

    private static final Id RTID_QANTASFREIGHT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_QANTASFREIGHT).getRecordTypeId();
    private static final Id RTID_QANTASFREIGHTHQR = Schema.SObjectType.QCC_Hotword_Queue_Routing__c.getRecordTypeInfosByDeveloperName().get(RT_QCCQANTASFREIGHT).getRecordTypeId();
    private static final Id RTID_QANTASFREIGHTACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RT_FREIGHTACCOUNT).getRecordTypeId();

    private static final String CASE_STATUS_CLOSED = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String CASE_STATUS_ONHOLD = CustomSettingsUtilities.getConfigDataMap('CaseStatusOnHold');
    private static final String CASE_STATUS_INPROGRESS = CustomSettingsUtilities.getConfigDataMap('Status_InProgress');
    private static final String CASE_STATUS_AUTO_CLOSED = CustomSettingsUtilities.getConfigDataMap('CaseStatusAutoclosed');
    private static final String CASE_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String CASE_STATUS_REPLYRECEIVED = CustomSettingsUtilities.getConfigDataMap('CaseStatusReplyReceived');
    private static final String CASE_STATUS_AUTO_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusAutoclosedstatus');
    private static final String CASE_STATUS_CSU_CLOSED = CustomSettingsUtilities.getConfigDataMap('CaseStatusCSUClosed');
    
    private static final String CASE_ORIGIN_FRT_BOOKINGS = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTBookings');
    private static final String CASE_ORIGIN_FRT_CUST_SERVICE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTCustService');
    private static final String CASE_ORIGIN_WEB = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_Web');
    private static final String CASE_ORIGIN_FRT_PHONE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTPhone');
    private static final String CASE_ORIGIN_FRT_EXPORT_SPL_MOVES = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTExportSplMoves');
    private static final String CASE_ORIGIN_FRT_SENIORS = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTSeniors');
    private static final String CASE_ORIGIN_FRT_SPL_MOVES = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTSplMoves');
    private static final String CASE_ORIGIN_WEBCHAT = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_Webchat');
    private static final String CASE_ORIGIN_FRT_CLAIMS = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTClaims');
    private static final String CASE_ORIGIN_FRTSALES = CustomSettingsUtilities.getConfigDataMap('Origin_FRTSalesSupport');
    private static final String CASE_ORIGIN_FRTJNB = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTJNB');//CRM 7671
    private static final String CASE_ORIGIN_FRTLON = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTLON');
    private static final String CASE_ORIGIN_FRT_EXPSPLMOVES = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTExpSplMoves');//CRM-8968
    private static final String CASE_ORIGIN_AutoEmail = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_AutoEmail');//CRM-9049
    private static final String CASE_ORIGIN_FRTSYDTRACING = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTSYDTracing');//CRM-9067
    private static final String CASE_ORIGIN_FRTUSA = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTUSA');
    private static final String CASEORIGIN_WEB_CASE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_Web');
    
    private static final String CASE_PRIOORITY_LOW = CustomSettingsUtilities.getConfigDataMap('Priority_Low');  
    private static final String CASE_PRIOORITY_MEDIUM = CustomSettingsUtilities.getConfigDataMap('Case Priority Medium');
    private static final String CASE_PRIOORITY_HIGH = CustomSettingsUtilities.getConfigDataMap('CasePriorityHigh');
    private static final String CASE_PRIOORITY_URGENT = CustomSettingsUtilities.getConfigDataMap('Priority_Urgent');
    private static final String CASE_PRIOORITY_PREMIUM = CustomSettingsUtilities.getConfigDataMap('Priority_Premium');
    private static final String CASE_PRIOORITY_SENIORS = CustomSettingsUtilities.getConfigDataMap('Priority_Seniors');


    private static final String TYPE_FREIGHTCOUNTRY_ACCOUNT = CustomSettingsUtilities.getConfigDataMap('Type_FreightCountry');
    private static final String CASE_TYPE_CLAIMS = CustomSettingsUtilities.getConfigDataMap('Type_Claims');
    private static final String CASE_TYPE_SPECIALMOVES = CustomSettingsUtilities.getConfigDataMap('Type_SpecialMoves');
    private static final String CASE_TYPE_CUSTOMERQUERY = CustomSettingsUtilities.getConfigDataMap('Type_CustomerQuery');
    private static final String CASE_TYPE_EXPORTMOVES = CustomSettingsUtilities.getConfigDataMap('Type_ExportMoves'); //CRM-8968
    private static final String CASE_TYPE_INVALID_CASE = CustomSettingsUtilities.getConfigDataMap('Type_InvalidCase');

    private static final String CASE_STYPE_GENERALENQUIRY = CustomSettingsUtilities.getConfigDataMap('SubType_GeneralEnquiry');
    private static final String CASE_STYPE_SALESSUPPORT = CustomSettingsUtilities.getConfigDataMap('SubType_SalesSupportQuery');
    private static final String CASE_STYPE_GENERAL = CustomSettingsUtilities.getConfigDataMap('SubType_General');
    
    private static final String QUEUE_FSALESSUPPORT = CustomSettingsUtilities.getConfigDataMap('Queue_FreightSalesSupport');
    private static final String QUEUE_FREIGHTCLAIMS = CustomSettingsUtilities.getConfigDataMap('Freight_Claims_Queue');
    private static final String QUEUE_FREIGHTCSUAU = CustomSettingsUtilities.getConfigDataMap('Freight_CSU_AU_Queue');
    private static final String QUEUE_FRT_UKEA_ZA = CustomSettingsUtilities.getConfigDataMap('Queue_Freight_UKEA_ZA');//CRM 7671
    private static final String QUEUE_FRTCSSAUQueue = CustomSettingsUtilities.getConfigDataMap('Queue_Freight_Freight_CSS_AU_Queue');//CRM-9067
    private static final String QUEUE_FRTCSSAEMRICAQueue = CustomSettingsUtilities.getConfigDataMap('Queue_Freight_CSS_Americas_Queue');//CRM-9122

    private static final String MAILSUFFIX = CustomSettingsUtilities.getConfigDataMap('FreightTypeInQHQR');
    private static final String DESCRIPTION_FROM = CustomSettingsUtilities.getConfigDataMap('DescriptionFrom');
    private static final String ICON_FREIGHT = CaseUtility.getDyanamicUrlForFreightLogo();
    
    private static final String CASE_SHIPMENT = CustomSettingsUtilities.getConfigDataMap('Shipment_Domestic');//CRM 8051 
    private static final String CASE_SHIPMENT_INTERNATIONAL = CustomSettingsUtilities.getConfigDataMap('Shipment_International');//CRM-8968 

    private static final String CASE_PRODUCT = CustomSettingsUtilities.getConfigDataMap('Product_NotApplicable');//CRM 8051
    private static final List<String> PUBLIC_EMAIL_DOMAIN = Label.WebchatPublicEmailDomains.split(';');

    private static final String EMPTY_STRING = '';
    private static boolean isRecursive = false;
    
    public static void onBeforeInsert(List<EmailMessage> emRecords, Map<Id, Case> caseMap) {
        try {
            Case objCase;
            for (EmailMessage emailMsg: emRecords) {
                objCase = caseMap.get(emailMsg.ParentId);
                if (CASE_ORIGIN_FRT_BOOKINGS.equals(objCase.Origin) || CASE_ORIGIN_FRT_CUST_SERVICE.equals(objCase.Origin)) {
                    emailMsg = EmailMessageTriggerHandler.maskCreditCard(emailMsg);
                    /*if (String.isNotBlank(objCase.ParentId)) {
                        emailMsg.ParentId = objCase.ParentId;
                    }*/
                }
            }
        } catch(exception ex) {
            CreateLogs.insertLogRec( 
                'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                'onBeforeInsert', String.valueOf(''), String.valueOf(''), false, String.valueOf(''), ex
            );
        }
    }
    
    public static void afterInsert(List<EmailMessage> newFreightEmailMessageList, Map<Id, Case> mapFreightCases, Set<Id> accountIds, Set<Id> createdByIds, Map<String, Id> mapCaseQueue, Set<String> setDomainName) {
        try {
            User userRecord = [ SELECT Id, Name, Email, City, CountryCode FROM User WHERE Id = :UserInfo.getUserId() ];
           // Set<String> premiumAccounts = fetchPremiumAccounts();
             List<Freight_Premium_Account__mdt>premiumAccounts= fetchPremiumAccounts();
            Set<String> hotWords= fetchHotWordsWithFreightType(MAILSUFFIX);
            Case objCase;
            Map<String, Account> accountMap = fetchAccounts(setDomainName);
            List<Case> caseToUpdate = new List<Case>();
            
            Map<Id, User> createdByMap = new Map<Id,User>([ SELECT Id, Name, Email, City, CountryCode FROM User WHERE Id IN :createdByIds WITH SYSTEM_MODE]); //SFRBACPSV-711 Code Security Remediation
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email;
            for (EmailMessage emailMsg: newFreightEmailMessageList) {
                objCase = mapFreightCases.get(emailMsg.ParentId);
                objCase = freightChildCaseCreationForClosedParent(objCase, mapCaseQueue, emailMsg);
                if (objCase.Origin.equals(CASE_ORIGIN_FRT_BOOKINGS) || objCase.Origin.equals(CASE_ORIGIN_FRT_CUST_SERVICE)) {
                    if (objCase.RecordTypeId == RTID_QANTASFREIGHT) {

                        //objCase = freightCloseDuplicateCases(emailMsg, objCase, subjectCaseMap);
                    }
                    //Updated as per CRM-14149
                    if (objCase.RecordTypeId == RTID_QANTASFREIGHT && emailMsg.Incoming == true) {
                        objCase = assignUrgentPriorityForCasesWithHotWords(emailMsg, objCase, hotWords);
                    }
                    if (objCase.Status.equals(CASE_STATUS_ONHOLD) && (emailMsg.status.contains('0') || emailMsg.status.contains('1')) &&
                        objCase.status.containsIgnoreCase(CASE_STATUS_ONHOLD) && !objCase.priority.containsIgnoreCase(CASE_PRIOORITY_URGENT) &&
                        !objCase.priority.containsIgnoreCase(CASE_PRIOORITY_PREMIUM)) 
                    {
                        objCase = freightLevelUpCasePriority(objCase);
                    }
                    objCase = freightAutoCloseCasesSentToInvoiceAndCustSer(emailMsg, objCase);   
                }
                
                if (objCase.AccountId == null) {
                    objCase = freightUpdateCaseAccountFromEmail(emailMsg, objCase, accountMap);
                }
                if (/*objCase.AccountId != null &&*/ (objCase.Origin==CASE_ORIGIN_FRT_BOOKINGS || objCase.Origin==CASE_ORIGIN_FRT_CUST_SERVICE || objCase.Origin==CASE_ORIGIN_FRT_CLAIMS 
                    || objCase.Origin==CASE_ORIGIN_FRT_SPL_MOVES ||objCase.Origin==CASE_ORIGIN_FRT_SENIORS || objCase.Origin==CASE_ORIGIN_FRTUSA || objCase.Origin==CASE_ORIGIN_FRTSYDTRACING || objCase.Origin=='FRT JNB' || objCase.Origin == CASEORIGIN_WEB_CASE))//CRM-9067(added FRT SYD TRACING ORIGIN)
                {
                    if (objCase.RecordTypeId == RTID_QANTASFREIGHT) {                        
                        objCase = freightChangePriorityForPremiumCustomers(emailMsg, objCase, premiumAccounts);
                    }
                }
                
                
                if (objCase.RecordTypeId == RTID_QANTASFREIGHT) {
                    
                    email = freightSendEmailAlertForBouncedEmails(emailMsg, objCase, createdByMap);
                    if (email != null) {
                        emailsToBeSent.add(email);
                    }
                    objCase = freightUpdateCase(emailMsg, objCase);
                }
                caseToUpdate.add(objCase);
            }
            
            if (!emailsToBeSent.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToBeSent, false);
                for (Messaging.SendEmailResult result : results) {
                    if (!result.isSuccess()){
                        for (Messaging.SendEmailError err : result.getErrors()){
                            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageFreightTriggerHandler',
                                                                                      'afterInsert', '', '', false, '', null, err.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
                        }
                    }
                }
            }
            if(caseToUpdate.size() > 0) {
                List<Database.SaveResult> results = Database.update(caseToUpdate, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageFreightTriggerHandler',
                                                                                      'afterInsert', '', '', false, '', null, err.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
                        }
                    }
                }
            }
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                                    'afterInsert', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    
    public static void afterUpdate(List<EmailMessage> newFreightEmailMessageList, Map<Id, Case> mapFreightCases, Set<Id> createdByIds) {
        try {
            List<Case> caseToUpdate = new List<Case>();
            Case objCase;
            Map<Id, User> createdByMap = new Map<Id,User>([ SELECT Id, Name, Email, City, CountryCode FROM User WHERE Id IN :createdByIds WITH SYSTEM_MODE]); //SFRBACPSV-711 Code Security Remediation
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email;
            for (EmailMessage emailMsg: newFreightEmailMessageList) {
                objCase = mapFreightCases.get(emailMsg.ParentId);
                if (objCase.Origin == CASE_ORIGIN_FRT_CUST_SERVICE || objCase.Origin == CASE_ORIGIN_FRT_BOOKINGS) {
                       objCase = freightAutoCloseCasesSentToInvoiceAndCustSer(emailMsg, objCase);   
                       caseToUpdate.add(objCase);
                }
                if (objCase.RecordTypeId == RTID_QANTASFREIGHT) {
                    email = freightSendEmailAlertForBouncedEmails(emailMsg, objCase, createdByMap);
                    if (email != null) {
                        emailsToBeSent.add(email);
                    }
                }
            }
            if (!emailsToBeSent.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToBeSent, false);
                for (Messaging.SendEmailResult result : results) {
                    if (!result.isSuccess()){
                        for (Messaging.SendEmailError err : result.getErrors()){
                            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageFreightTriggerHandler',
                                                                                      'afterUpdate', '', '', false, '', null, err.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
                        }
                    }
                }
            }
            if(caseToUpdate.size() > 0) {
                List<Database.SaveResult> results = Database.update(caseToUpdate, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageFreightTriggerHandler',
                                                                                      'afterUpdate', '', '', false, '', null, err.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
                        }
                    }
                }
            }
            
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                                    'afterUpdate', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    
    public static Case freightUpdateCase(EmailMessage emailMsg, Case objCase) {
        try {            
            if (objCase.OwnerName__c == QUEUE_FREIGHTCSUAU && objCase.Origin == CASE_ORIGIN_FRT_SPL_MOVES) {
                objCase.Contact_Email__c = emailMsg.FromAddress;
                objCase.Description = emailMsg.TextBody;
                objCase.Type = CASE_TYPE_SPECIALMOVES;
                objCase.Sub_Type_1__c = CASE_STYPE_GENERALENQUIRY;
                objCase.Subject = emailMsg.Subject;
                handleFreightAndClaimsCase(emailMsg, objCase); //CRM-12543
            } else if (objCase.OwnerName__c == QUEUE_FREIGHTCSUAU && objCase.Origin == CASE_ORIGIN_FRT_SENIORS){
                objCase.Contact_Email__c = emailMsg.FromAddress;
                objCase.Description = emailMsg.TextBody;
                objCase.Subject = emailMsg.Subject;
            }//Added for CRM-12543
            else if (
                (objCase.OwnerName__c == QUEUE_FREIGHTCSUAU &&
                 (objCase.Origin == CASE_ORIGIN_FRT_CUST_SERVICE ||
                  objCase.Origin == CASE_ORIGIN_FRT_BOOKINGS ||
                  objCase.Origin == CASE_ORIGIN_FRT_SPL_MOVES ||
                  objCase.Origin == CASE_ORIGIN_FRT_EXPORT_SPL_MOVES
                 )
                )
                ||
                (objCase.OwnerName__c == QUEUE_FREIGHTCLAIMS &&
                 objCase.Origin == CASE_ORIGIN_FRT_CLAIMS)
            ){                                               
                handleFreightAndClaimsCase(emailMsg, objCase);  
                
                // New additional check for CRM-12762
                if (objCase.OwnerName__c == QUEUE_FREIGHTCSUAU &&
                    (objCase.Origin == CASE_ORIGIN_FRT_CUST_SERVICE ||
                     objCase.Origin == CASE_ORIGIN_FRT_BOOKINGS)) {                         
                         freightSendEmailCaseClosure(emailMsg, objCase);
                     }
            }
                else if (objCase.OwnerName__c == QUEUE_FREIGHTCLAIMS && objCase.Origin == CASE_ORIGIN_FRT_CLAIMS) {
                objCase.SuppliedName = emailMsg.FromName;
                objCase.SuppliedEmail = emailMsg.FromAddress;
                objCase.Contact_Email__c = emailMsg.FromAddress;
                objCase.Description = emailMsg.TextBody;
                objCase.Type = CASE_TYPE_CLAIMS;
                objCase.Sub_Type_1__c = CASE_STYPE_GENERALENQUIRY;
                objCase.Subject = emailMsg.Subject;
            } else if (objCase.OwnerName__c == QUEUE_FSALESSUPPORT && objCase.Origin == CASE_ORIGIN_FRTSALES) {
                objCase.Description = emailMsg.TextBody;
                objCase.Subject = emailMsg.Subject;
                objCase.Type = CASE_TYPE_CUSTOMERQUERY;
                objCase.Sub_Type_1__c = CASE_STYPE_SALESSUPPORT;
                objCase.Sub_Type_2__c = CASE_STYPE_GENERAL;
                objCase.Freight_Shipment__c = CASE_SHIPMENT;//CRM 8051 Added Product and Shipment to FRT Sales Support Query
                objCase.Product__c = CASE_PRODUCT;
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                                    'freightUpdateCase', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return objCase;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        freightChildCaseCreationForClosedParent
Description:        This method checks new emailMessage on Closed Case and create a new child case, and associate it to the Closed parent
Parameter:          Case, Map<String, Id>  
Updated: CRM-10814 - 25/2/2026 -Koel Datta
--------------------------------------------------------------------------------------*/
    public static Case freightChildCaseCreationForClosedParent(Case objCase, Map<String, Id> mapCaseQueue, EmailMessage emailMsg) {
        try {
            set<String> validCaseorigins=new set<String>{CASE_ORIGIN_FRT_BOOKINGS,CASE_ORIGIN_FRT_CUST_SERVICE,CASE_ORIGIN_FRT_PHONE,
                CASE_ORIGIN_FRT_EXPORT_SPL_MOVES,CASE_ORIGIN_FRT_SPL_MOVES,CASE_ORIGIN_WEBCHAT,CASE_ORIGIN_FRT_SENIORS,CASE_ORIGIN_FRT_CLAIMS,CASE_ORIGIN_WEB,CASE_ORIGIN_FRTSALES,CASE_ORIGIN_AutoEmail};
                    Date YearAgo = Date.today().addYears(-2);
            if (emailMsg.Incoming && emailMsg.FromAddress != System.label.FRT_NoReply_Email && (((CASE_STATUS_CLOSED.equals(objCase.Status) || CASE_STATUS_CSU_CLOSED.equals(objCase.Status)) && validCaseorigins.contains(objCase.origin)) || (CASE_STATUS_AUTO_CLOSED_STATUS.equals(objCase.Status) && objCase.CreatedDate.date()>=YearAgo && objCase.RecordTypeId == RTID_QANTASFREIGHT  && CASE_ORIGIN_WEB.equals(objCase.origin)))) { // CRM -12840 Added Closed CSU Status
                objCase.Resolve_Closeddate__c = objCase.ClosedDate;  
                objCase.status = System.Label.Freight_Child_Case_Status; //Reply Received                
                //CRM-9718
                objCase.ownerid = (objCase.Type == CustomSettingsUtilities.getConfigDataMap('Type_Claims')) ? mapCaseQueue.get(CustomSettingsUtilities.getConfigDataMap('Freight_Queue_FRT Claims')) : mapCaseQueue.get(CustomSettingsUtilities.getConfigDataMap('Freight_Queue_'+ objCase.origin));
                //Added for CRM-13906
                Case cs = [Select id, Freight_Shipment__c from Case where id =: objCase.id WITH USER_MODE]; //SFRBACPSV-711 Code Security Remediation            
                if(objCase.Type == 'Claims' && cs.Freight_Shipment__c == 'Domestic' || cs.Freight_Shipment__c == 'International'){                  
                    objCase.Sub_Type_2__c = System.Label.Freight_SubType_2;//Formal Claim                   
                }
            }
            //CRM-10814 
              
            List<String> allowedFromList = System.label.FRP_Reply_Email.split('\\s*[,;]\\s*');           
            Set<String> allowedFrom = new Set<String>();
            for (String e : allowedFromList) {
                if (String.isNotBlank(e)) allowedFrom.add(e.trim().toLowerCase());
            }   
            String fromAddr = String.valueOf(emailMsg.FromAddress);
            Boolean fromMatches = String.isNotBlank(fromAddr) 
                && allowedFrom.contains(fromAddr.trim().toLowerCase());            
            //existing subject check
            Boolean subjectMatches = emailMsg.Subject != null 
                && emailMsg.Subject.contains('Cargo Correction Advice (CCA) Request for AWB number');            
            if (fromMatches && subjectMatches) {
                objCase.OwnerId = mapCaseQueue.get(CustomSettingsUtilities.getConfigDataMap('Queue_FreightSalesSupport'));
                objCase.Status  = System.Label.Freight_Child_Case_Status;
            }  
         }catch(Exception ex) {
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                                        'fetchFreigtCases', String.valueOf(''), String.valueOf(''), false, '', ex);
            }
            return objCase;
        }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        freightLevelUpCasePriority
Description:        This method checks new emailMessage on Case and upgrade the case priority and change status from on-hold to in progress
Parameter:          EmailMessage New List 
--------------------------------------------------------------------------------------*/
    public static Case freightLevelUpCasePriority(Case objCase) {
        try {
            
            objCase.status = CASE_STATUS_INPROGRESS;
            String key = 'freight' + objCase.priority + 'PriorityCaseUpgrade';
            objCase.priority = CustomSettingsUtilities.getConfigDataMap(key) != null ? CustomSettingsUtilities.getConfigDataMap(key) : CASE_PRIOORITY_URGENT;
            
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                                    'freightLevelUpCasePriority', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return objCase;
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        freightAutoCloseCasesSentToInvoiceAndCustSer
Description:        This method auto-closes the Emails sent to Invoice and Cust service address
Parameter:          Case
--------------------------------------------------------------------------------------*/    
    public static Case freightAutoCloseCasesSentToInvoiceAndCustSer(EmailMessage emRecord, Case objCase)
    {
        try {
            //freightinvoices@qantas.com.au;freightcustomerservice@qantas.com.au
            String[] emailAddresses = System.label.FreightAutoClosureEmailAddresses.split(';');
            Integer count = emailAddresses.size();
            Integer i = 0;
            while (i < count && String.isNotBlank(emRecord.ToAddress) && emRecord.ToAddress.containsIgnoreCase(emailAddresses[i])) {
                ++i;
            }
            if (i == count) {
                objCase.type = CASE_TYPE_INVALID_CASE;
                objCase.Status = CASE_STATUS_AUTO_CLOSED;
                objCase.Approve__c = EMPTY_STRING;
                objCase.Condition_Met__c = EMPTY_STRING;
                objCase.Problem_Type__c = EMPTY_STRING;
                objCase.Sub_Type__c = EMPTY_STRING;
                objCase.Sub_Type_1__c = EMPTY_STRING;
                objCase.Group__c = EMPTY_STRING;
                objCase.Reasons_for_Credit_and_Action_Taken__c = EMPTY_STRING;
                objCase.Risk__c = EMPTY_STRING;
                objCase.Reason_for_Waiver__c = EMPTY_STRING;
                objCase.Waiver_Sub_Type__c = EMPTY_STRING;
                objCase.Sub_Type_2__c = EMPTY_STRING;
                objCase.Category__c = EMPTY_STRING;
                objCase.Secondary_Reasons_for_Credit__c = EMPTY_STRING;
                objCase.Request_Reason_Sub_Type__c = EMPTY_STRING;
            }
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight email', 'EmailMessageFreightTriggerHandler', 
                                    'freightAutoCloseCasesSentToInvoiceAndCustSer', String.valueOf(''), String.valueOf(''), false, String.valueOf(objCase.Id), ex);
        }
        return objCase;
    }
    
    public static Set<String> fetchHotWordsWithFreightType(String freightType) {
        try{
        Set<String> hotWordsOfFreightType = new Set<String>();
        for (QCC_Hotword_Queue_Routing__c hqrRecord : [ SELECT Id, Hot_words__c, freight_Type__c FROM QCC_Hotword_Queue_Routing__c 
                                                       WHERE RecordTypeId = :RTID_QANTASFREIGHTHQR AND freight_Type__c= :freightType WITH USER_MODE]) //SFRBACPSV-711 Code Security Remediation                                                   
        {
            if (String.isNotBlank(hqrRecord.Hot_words__c)) {
                for (String hotWord : hqrRecord.Hot_words__c.split(',')) {
                    hotWordsOfFreightType.add(hotWord);
                }
            } 
        }
        return hotWordsOfFreightType;
        }catch (QueryException ex) { //SFRBACPSV-711 added Catch for Code Security Remediation
                Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'EmailMessageFreightTriggerHandler', 'EmailMessageFreightTriggerHandler','fetchHotWordsWithFreightType', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
                return new Set<String>();
        }
    } 
    
    public static List<Freight_Premium_Account__mdt> fetchPremiumAccounts() {
        //Set<String> premiumAccounts = new Set<String>();
        List<Freight_Premium_Account__mdt> premiumAccounts = new List<Freight_Premium_Account__mdt>();
        for (Freight_Premium_Account__mdt freightMetadata :  Freight_Premium_Account__mdt.getAll().values()) {
           // premiumAccounts.add(freightMetadata.Premium_Accounts__c);
           premiumAccounts.add(freightMetadata);
        }
        return premiumAccounts;
    }
    
    public static Map<String, Account> fetchAccounts(Set<String> setDomain) {
        try{
        Map<String, Account> accountMap = new Map<String, Account>();
        if (setDomain == null || setDomain.isEmpty()) {
            return accountMap;
        }
        //Create new domain field in Account object and update the query
        for (Account accountRecord : [ SELECT Id, Name, BillingCountryCode, Email__c, Account_Domain__c,Owner.Freight_Reporting_Team__c,Freight_Region__c FROM Account 
                                        WHERE RecordTypeId = :RTID_QANTASFREIGHTACCOUNT 
                                        AND Type = :TYPE_FREIGHTCOUNTRY_ACCOUNT 
                                        AND Account_Domain__c IN :setDomain AND Account_Domain__c NOT IN: PUBLIC_EMAIL_DOMAIN WITH USER_MODE //SFRBACPSV-711 Code Security Remediation
                                        ORDER BY CreatedDate DESC ]) //changed to DESC to view map march 21
        {
          /* accountMap.put(accountRecord.Account_Domain__c+'-'+ accountRecord.BillingCountryCode+'-'+'AU Region', accountRecord);
           accountMap.put(accountRecord.Account_Domain__c+'-'+ accountRecord.Owner.Freight_Reporting_Team__c+'-'+'Other Region', accountRecord);*/
            accountMap.put(accountRecord.Account_Domain__c+'-'+accountRecord.Freight_Region__c,accountRecord );   
        }
        return accountMap;
        }catch (QueryException ex) { //SFRBACPSV-711 added Catch for Code Security Remediation
                Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'EmailMessageFreightTriggerHandler', 'EmailMessageFreightTriggerHandler','fetchAccounts', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
                return new Map<String, Account>();
        }
    }
  
    
    /*--------------------------------------------------------------------------------------      
Method Name:        assignUrgentPriorityForCasesWithHotWords
TestMehtod:         testassignUrgentPriorityForCasesWithHotWords
Desc
ription:        This method automates the case Priority to be Urgent based on the Hot words
Parameter:          EmailMessage New List 
Jira Story:         FCRM-894
Date Implemented:   28 March 2022
Sprint Freight      156
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/
    public static Case assignUrgentPriorityForCasesWithHotWords(EmailMessage emRecord, Case caseRecord, Set<String> hotWords) {
        try {
            String description = emRecord.TextBody;
            if (caseRecord.Priority != CASE_PRIOORITY_PREMIUM) {
                for (String hotWord : hotWords) {
                    if (String.isNotBlank(emRecord.FromAddress) && emRecord.FromAddress.containsIgnoreCase(hotWord)) {
                        caseRecord.Priority = CASE_PRIOORITY_URGENT;
                        break;
                    } else if (String.isNotBlank(description) && description.containsIgnoreCase(DESCRIPTION_FROM) && (description.indexOf('@')+1) == description.indexOfIgnoreCase(hotWord)) {
                        caseRecord.Priority = CASE_PRIOORITY_URGENT;
                        break;
                    }
                }
            }
        } catch (Exception ex) {
           // System.debug(LoggingLevel.ERROR, ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'EmailMessageFreightTriggerHandler', 'assignUrgentPriorityForCasesWithHotWords', '', '', false, '', ex);
        }
        return caseRecord;
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        freightChangePriorityForPremiumCustomers
TestMehtod:         testfreightChangePriorityForPremiumCustomers
Description:        This method changes parent case's priority to Premium  
Parameter:          EmailMessage Ids 
Jira Story:         FCRM-961
Date Implemented:   14 OCT 2022
Sprint Freight      170
Developer's Name:   Navpreet Kaur
--------------------------------------------------------------------------------------*/    
    public static Case freightChangePriorityForPremiumCustomers(EmailMessage emRecord, Case objCase, List<Freight_Premium_Account__mdt> premiumAccounts) {
        try {
            String description = emRecord.TextBody;
            for (Freight_Premium_Account__mdt premiumAcc : premiumAccounts) {
                if (((String.isNotBlank(emRecord.FromAddress) && emRecord.FromAddress.substringAfter('@').containsIgnoreCase(premiumAcc.Premium_Accounts__c) && objCase.Origin !='Web' ) || (String.isNotBlank(objCase.SuppliedEmail) && objCase.SuppliedEmail.substringAfter('@').containsIgnoreCase(premiumAcc.Premium_Accounts__c)  && objCase.Origin == 'Web' ))  /*&& caseRecord.AccountId!=Null*/ && objCase.Freight_Region__c.contains(premiumAcc.Region__c) && premiumAcc.Tier__c=='Tier 1') {
                    objCase.Priority = CASE_PRIOORITY_PREMIUM;                    
                    break;
                } else if (String.isNotBlank(description) && description.containsIgnoreCase(DESCRIPTION_FROM) && (description.indexOf('@')+1) == description.indexOfIgnoreCase(premiumAcc.Premium_Accounts__c)  && objCase.Freight_Region__c.contains(premiumAcc.Region__c) && premiumAcc.Tier__c=='Tier 1') {
                    objCase.Priority = CASE_PRIOORITY_PREMIUM;
                    break;
                } else if (((String.isNotBlank(emRecord.FromAddress) && emRecord.FromAddress.substringAfter('@').containsIgnoreCase(premiumAcc.Premium_Accounts__c) && objCase.Origin !='Web' ) || (String.isNotBlank(objCase.SuppliedEmail) && objCase.SuppliedEmail.substringAfter('@').containsIgnoreCase(premiumAcc.Premium_Accounts__c)  && objCase.Origin == 'Web' )) /* && caseRecord.AccountId!=Null */&& objCase.Freight_Region__c.contains(premiumAcc.Region__c) && premiumAcc.Tier__c=='Tier 2') {
                    objCase.Priority = CASE_PRIOORITY_URGENT;
                    break;
                } else if (objCase.Origin == CASE_ORIGIN_FRT_SENIORS){
                    objCase.Priority = CASE_PRIOORITY_SENIORS;
                }else if (objCase.Origin  == CASE_ORIGIN_FRT_BOOKINGS ){
                    objCase.Priority = objCase.Priority;
                }else{
                     objCase.Priority = 'Low';
                }
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'EmailMessageFreightTriggerHandler', 'freightChangePriorityForPremiumCustomers', '', '', false, '', ex);
        }
        return objCase;
    }
/*--------------------------------------------------------------------------------------      
Method Name:        freightUpdateCaseAccountFromEmail
Description:        This method update the Account on Case with Origin Email by validating Account Region against Case Region
Parameter:          EmailMessage, CaseRecord,AccountMap
Jira:               CRM-9129
--------------------------------------------------------------------------------------*/
      public static Case freightUpdateCaseAccountFromEmail(EmailMessage emRecord, Case caseRecord, Map<String,Account> accountMap) {
        try {
            // Extract domain name from email address and region from case region field
            String domainName = CaseUtility.getDomainFromEmailField(emRecord.FromAddress);
           /* for (String emailDomain : PUBLIC_EMAIL_DOMAIN) {
                if (emailDomain.containsIgnoreCase(domainName)) {
                    caseRecord.AccountId = null;
                }
            }*/
            String key = domainName +'-'+ caseRecord.Freight_Region__c;
            //system.debug('Key***'+key);
            caseRecord.AccountId=accountMap.containsKey(key)?accountMap.get(key).id:null;
            
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'EmailMessageFreightTriggerHandler', 'freightUpdateCaseAccountFromEmail', '', '', false, '', ex);
        }
        return caseRecord;
    }

    /*--------------------------------------------------------------------------------------      
Method Name:        handleFreightAndClaimsCase
Description:        This method will check for AWB in Subject line and will add in AWB#
Jira Story:         CRM-12543
Date Implemented:   21/4/2023
Sprint Freight      254
Developer's Name:   Koel Datta
--------------------------------------------------------------------------------------*/ 
private static void handleFreightAndClaimsCase(EmailMessage emailMsg, Case objCase) {

    System.debug('Freight case identified');

    /* ============================
       Claims‑specific field setup
       ============================ */
    if (objCase.OwnerName__c == QUEUE_FREIGHTCLAIMS &&
        objCase.Origin == CASE_ORIGIN_FRT_CLAIMS) {

        objCase.SuppliedName      = emailMsg.FromName;
        objCase.SuppliedEmail     = emailMsg.FromAddress;
        objCase.Contact_Email__c  = emailMsg.FromAddress;
        objCase.Description       = emailMsg.TextBody;
        objCase.Type              = CASE_TYPE_CLAIMS;
        objCase.Sub_Type_1__c     = CASE_STYPE_GENERALENQUIRY;
        objCase.Subject           = emailMsg.Subject;
    }

    /* ============================
       AWB Extraction (CRM‑12543)
       ============================ */
    String AWB = null;

    if (String.isNotBlank(objCase.Subject)) {
        Pattern p = Pattern.compile('\\b\\d{3}-\\d{8}\\b');
        Matcher m = p.matcher(objCase.Subject);

        if (m.find()) {
            AWB = m.group(0);
        } else {
        }
    } else {
        System.debug('Subject is null or empty. Setting AWB to NULL');
    }

    if (AWB != null) {
        objCase.Freight_AWB_Number__c = AWB;
    } else {
        objCase.Freight_AWB_Number__c = null;
    }
}

    /*--------------------------------------------------------------------------------------      
    Method Name:        freightSendEmailCaseClosure
    Description:        This method will keywords from subject line of the email and will Auto Close the cases
    Jira Story:         CRM-12762
    Date Implemented:   12/6/2026
    Sprint Freight      257
    Developer's Name:   Koel Datta
    --------------------------------------------------------------------------------------*/         
    public static void freightSendEmailCaseClosure(EmailMessage emailMsg, Case objCase){
        try{
            system.debug('@@Eneterd');
            String subject = emailMsg.Subject;
            
            if (String.isNotBlank(subject) && emailMsg.ParentId != null) {
                
                // Check if this is the first email for the case
                Integer emailCount = [
                    SELECT COUNT()
                    FROM EmailMessage
                    WHERE ParentId = :emailMsg.ParentId
                ];
                
                System.debug('Email count for case: ' + emailCount);                                
                // If count = 1 → this is the first email (assuming trigger runs after insert)
                if (emailCount == 1) {                    
                    
                    List<String> keywords = new List<String>{
                        'Cargo connection request',
                            'Copy of BNE Domestic Air Product On Hand Awaiting Uplift',
                            'FLIGHT COPIES',
                            'IMPORT IRREGULAIRTY MESSAGE',
                            'Shipper: AMERICAN AIRLINES ORD',
                            '#EnjoyingBARBUSS',
                            'QF Freighter Operations Summary',
                            'Shipment Without Booking/Unbooked to Flight'
                            };
                                
                                for (String keyword : keywords) {
                                    if (subject.toLowerCase().contains(keyword.toLowerCase())) {
                                        objCase.Status = CASE_STATUS_AUTO_CLOSED_STATUS;
                                        break; // stop after first match
                                    }
                                }
                }
            }          
        }catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'EmailMessageFreightTriggerHandler', 'freightSendEmailCaseClosure', '', '', false, '', ex);
        }
    } 
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        freightSendEmailAlertForBouncedEmails
    TestMehtod:         testfreightChildCaseCreationForClosedParent
    Description:        This method sends email alerts to the sender of bounced emails
    Parameter:          EmailMessage New List  
    Jira Story:         FCRM-937
    Date Implemented:   8 Aug 2022
    Sprint Freight      165
    Developer's Name:   Navpreet Kaur
    --------------------------------------------------------------------------------------*/ 
    public static Messaging.SingleEmailMessage freightSendEmailAlertForBouncedEmails(EmailMessage emRecord, Case caseRecord, Map<Id,User> userMap) {
        try {
            Set<Id> createdByIds = new Set<Id>();
            User userRecord;
            Messaging.SingleEmailMessage eMessage = new Messaging.SingleEmailMessage();
            if (emRecord.isBounced && emRecord.Status == '3') {
                userRecord = userMap.get(emRecord.CreatedById);
                if (userRecord != NULL) {
                    eMessage.setToAddresses(new String[] { userRecord.Email });
                    eMessage.setSubject(String.format('Qantas Freight Bounced Email – Ref No {0}', new String[]{ caseRecord.CaseNumber }));
                    eMessage.setSaveAsActivity(false);
                    eMessage.setUseSignature(false);
                    eMessage.setHTMLBody(String.format('Dear {0},<br/><br/>'+'The email intended for {1} has been bounced back for the case number {2}.<br/><br/><br/> Thanks <br/> <br/><br/><footer><img src={3} alt="Freight Logo" /></footer>', 
                                                       new String[]{ userRecord.Name, emRecord.ToAddress, caseRecord.CaseNumber, ICON_FREIGHT }));
                    return eMessage;
                }
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight', 'EmailMessageFreightTriggerHandler', 'freightSendEmailAlertForBouncedEmails', '', '', false, '', ex);
        }
        return null;    
    }   
}