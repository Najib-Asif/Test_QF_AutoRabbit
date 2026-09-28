/**
 * @description       : 
 * @author            : Gandla Mallikarjuna
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : Praveen Sampath
 * Test class         :EmailMessageQCCTriggerHandlerTest Code coverage: 82%
**/
public class EmailMessageQCCTriggerHandler {

    private static final String CASE_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final User LOGGEDINUSERINFO = [ SELECT Id, Location__c FROM User WHERE Id = :UserInfo.getUserId() ];
    public static Id recTypeCCCRefund = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Refund RecType'));
    public static Map<String,Id> mapQueue = new Map<String,Id>();
    public static Map<String, String> oldQueueIdToNewQueueDevName = new Map<String, String> ();
    public static List<String> deprecatedQueueList = new List<String> ();
    private static final String RM_AUTOCLOSED_CASE = CustomSettingsUtilities.getConfigDataMap('CaseResolutionMethod_AutoClosed');
    private static final String REASON_CLOSE_CASE = CustomSettingsUtilities.getConfigDataMap('CaseCloseReason');
    private static final String TYPE_INSURANCELETTER_CASE = CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type');
    private static final String TYPE_CCCINSURANCELETTER_CASE = CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType');

    public static final String REPLY_RECEIVED_STATUS = CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusReplyReceived');

    //CRM-9453: Child Case scenario
    public static final String INPRGOGRESS_STATUS = CustomSettingsUtilities.getConfigDataMap('Status_InProgress');
    public static final String PENDING_RECOVERY_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusPendingRecovery');

    public static final String RT_QCC_Specific_Needs = CustomSettingsUtilities.getConfigDataMap('RT_QCC_Specific_Needs');
    public static final String QCC_EMAIL_SUBJECT = CustomSettingsUtilities.getConfigDataMap('EmailSubQCC');
    public static final Set<String> CORPORATEACCOUNTEMAILS = fetchQantasCorporateAccountEmails();
    //CDP2-337
    public static final Group CASE_PENDRECVY_QUEUE = [select Id from Group where DeveloperName = 'Pending_Recovery' and Type = 'Queue' Limit 1];
    public static final List<QueueSobject> queueSObjectList=[Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where SobjectType ='Case'];


    public EmailMessageQCCTriggerHandler() {
        
    }

    public static void beforeInsert(List<EmailMessage> newQCCEmails, Map<Id, Case> mapCases) {
        try {
            //Assistance;Specific Needs 
            List<string> recordTypesList  = Label.QCC_MaskCardNumberForRecordTypes.split(';');
            Case objCase;

            //CRM-9453: Child Case scenario
            Set<Id> parentCaseIds = new Set<Id>();
            for (Case cs : mapCases.values()) {
                System.debug('cs=======> ' + cs);
                if (cs.ParentId != null && cs.Status == CASE_CLOSED_STATUS) { // Incoming email to closed child
                    parentCaseIds.add(cs.ParentId);
                } else if (cs.ParentId == null && cs.Status == CASE_CLOSED_STATUS) { // incoming email to closed Parent
                    parentCaseIds.add(cs.Id);
                }
            }
            Map<Id, Case> latestParentChildCaseMap = fetchLatestOpenChildCase(parentCaseIds);
            system.debug('latestParentChildCaseMap=====> ' + latestParentChildCaseMap);
            for (EmailMessage emailMsg: newQCCEmails) {
                objCase = mapCases.get(emailMsg.ParentId);
                if(emailMsg.subject.contains(QCC_EMAIL_SUBJECT) || (objCase != null && recordTypesList.contains(objCase.recordtype.Name))) {
                    emailMsg = EmailMessageTriggerHandler.maskCreditCard(emailMsg);
                }
                System.debug('objCase===========> ' + objCase);
                System.debug('emailMsg=======> ' + emailMsg);

                if (emailMsg.Incoming && objCase.Status == CASE_CLOSED_STATUS && objCase.ParentId != null && latestParentChildCaseMap.get(objCase.ParentId) != null) {
                    emailMsg.ParentId = latestParentChildCaseMap.get(objCase.ParentId).Id;
                } else if (emailMsg.Incoming && objCase.Status == CASE_CLOSED_STATUS && latestParentChildCaseMap.get(objCase.Id) != null) {
                    emailMsg.ParentId = latestParentChildCaseMap.get(objCase.Id).Id;
                }

            }
            
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'beforeInsert', String.valueOf(''), String.valueOf(''),false, '', ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageQCCTriggerHandler',
                                                                                     'beforeInsert', '', '', false, '', null, ex.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
        } 
    }

    public static void afterInsert(Map<Id, EmailMessage> newQCCEmailMessageMap, Map<Id, Case> mapCases, List<Id> ownerIds, 
                                            Map<Id,Case> qccOutboundcasesTobeActionedMap, Map<Id,Integer> qccCaseIdEmailCountMap, Map<Id,Id> qccOutboundCaseEmailMap) {

        try {
            List<Case> caseToUpdate = new List<Case>();
            fetchCaseQueueInfo();
            Set<Id> setOfCCATUser = QCC_UtilityHelper.getListOfCCATUser(ownerIds);
            Set<Id> setOfResolutionConsultants = QCC_UtilityHelper.getListResolutionConsultant(ownerIds);
            Set<Id> caseOutboundEmails = fetchAllOutboundEmailsOfACase(qccOutboundcasesTobeActionedMap, qccOutboundCaseEmailMap, qccCaseIdEmailCountMap);
            Case objCase;
            for (EmailMessage emsg : newQCCEmailMessageMap.values()) {
                objCase = mapCases.get(emsg.ParentId);
                objCase = processCaseEmailMessage(emsg, objCase, setOfCCATUser, setOfResolutionConsultants);
                if(emsg.Incoming) {
                    if (objCase.Sensitive__c && objCase.Status == CASE_CLOSED_STATUS && objCase.CCC_And_B_Case_Type__c == 'Child') {

                    }
                    //CRM-9453: Child Case scenario
                    if (objCase.Status == INPRGOGRESS_STATUS || objCase.Status == PENDING_RECOVERY_STATUS) {
                        objCase.Status = REPLY_RECEIVED_STATUS;
                        objCase.Channel_Type__c = CustomSettingsUtilities.getConfigDataMap(emsg.FromAddress);                        
                    }

                    objCase.Channel_Type__c = CustomSettingsUtilities.getConfigDataMap(emsg.ToAddress);

                } else {
                     if(objCase.First_email_to_customer__c == null){
                    objCase = captureFirstOutboundEmail(emsg, objCase, caseOutboundEmails);
                     }
                }
                caseToUpdate.add(objCase);
            }

            caseToUpdate = insertTasks(newQCCEmailMessageMap.values(), mapCases);
            if(caseToUpdate.size() > 0) {
                List<Database.SaveResult> results = Database.update(caseToUpdate, false);
                List<Log__c> logRecords = new List<Log__c>();
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageQCCTriggerHandler',
                                                                                     'afterInsert', '', '', false, '', null, err.getMessage());
                            logRecords.add(logRecord);
                        }
                    }
                }
                
                if (!logRecords.isEmpty()) {
                 QCC_LogUtilityHelper.createLogRecords(logRecords);
                }
            }

        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'afterInsert', String.valueOf(''), String.valueOf(''),false, '', ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageQCCTriggerHandler',
                                                                                     'afterInsert', '', '', false, '', null, ex.getMessage());
                            QCC_LogUtilityHelper.createLogRecord(logRecord);
        } 

    }

    public static void beforeUpdate(Map<Id, EmailMessage> newQCCEmailMessageMap, Map<Id, Case> mapCases) {
        try {
            //Assistance;Specific Needs 
            List<string> recordTypesList  = Label.QCC_MaskCardNumberForRecordTypes.split(';');
            Case objCase;
            for (EmailMessage emailMsg:  newQCCEmailMessageMap.values()) {
                objCase = mapCases.get(emailMsg.ParentId);
                if(emailMsg.subject.contains(QCC_EMAIL_SUBJECT) || (objCase != null && recordTypesList.contains(objCase.recordtype.Name))) {
                    emailMsg = EmailMessageTriggerHandler.maskCreditCard(emailMsg);
                }
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'beforeInsert', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }

    public static void afterUpdate(Map<Id, EmailMessage> newQCCEmailMessageMap, Map<Id, Case> mapCases, List<Id> ownerIds,
                                    Map<Id,Case> qccOutboundcasesTobeActionedMap, Map<Id,Integer> qccCaseIdEmailCountMap, Map<Id,Id> qccOutboundCaseEmailMap) {
        try {

            List<Case> caseToUpdate = new List<Case>();
            fetchCaseQueueInfo();
            Set<Id> setOfCCATUser = QCC_UtilityHelper.getListOfCCATUser(ownerIds);
            Set<Id> setOfResolutionConsultants = QCC_UtilityHelper.getListResolutionConsultant(ownerIds);
            Set<Id> caseOutboundEmails = fetchAllOutboundEmailsOfACase(qccOutboundcasesTobeActionedMap, qccOutboundCaseEmailMap, qccCaseIdEmailCountMap);
            Case objCase;
            for (EmailMessage emsg : newQCCEmailMessageMap.values()) {

                objCase = null;
                if (String.isNotBlank(emsg.ParentId) && mapCases != null && !mapCases.isEmpty()) {
                    objCase = mapCases.get(emsg.ParentId);
                }

                if (objCase != null) {
                    objCase = processCaseEmailMessage(emsg, objCase, setOfCCATUser,setOfResolutionConsultants);
                    if(!emsg.Incoming) {
                        objCase = captureFirstOutboundEmail(emsg, objCase, caseOutboundEmails);
                    }
                }
            }
            //caseToUpdate = insertTasks(newQCCEmailMessageMap.values(), mapCases);
            if(caseToUpdate.size() > 0) {
                List<Database.SaveResult> results = Database.update(caseToUpdate, false);
                List<Log__c> logRecords = new List<Log__c>();
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageQCCTriggerHandler',
                                                                                     'afterUpdate', '', '', false, '', null, err.getMessage());
                            logRecords.add(logRecord);
                        }
                    }
                }
                if (!logRecords.isEmpty()) {
                 QCC_LogUtilityHelper.createLogRecords(logRecords);
   		     }
                
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'afterUpdate', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
        
    }

    
    public static Case processCaseEmailMessage(EmailMessage eMessage, Case objCase, Set<Id> setOfCCATUser, Set<Id> setOfResolutionConsultants){
        try {
            set<id> caseIdset = new set<id>();
            System.debug('inside processCaseEmailMessage');
            if(eMessage.Incoming == true) { // Make sure there(s) an INBOUND email message to process that is related to case to prevent unnecessary process/soql
                
                // PROCESS INBOUND MESSAGES     
                if (objCase != Null && objCase.Status != CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')) {
                    
                    System.debug('not closed case.=========> ');
                    // VIP FREQUENT FLIER TIER
                    Set<String> vipFFTierSet = new Set<String>();
                    vipFFTierSet.addAll(Label.QCC_CaseVIP.split(';'));
                    Boolean isVip = false;
                    String currentFFTier = ( objCase.FF_Tier__c != NULL ? objCase.FF_Tier__c : objCase.Contact.Frequent_Flyer_Tier__c );
                    if( objCase.Contact.SSU__c == true || vipFFTierSet.contains(currentFFTier) ) {
                        isVip = true;
                    }
    
                    //GRAPHITE-1245 To check if user is CCAT Agent
                    Boolean isCCAT = false;
                    //GRAHITE-GRAPHITE-1980 : New way of checking if user is CCAT.
                    if(setOfCCATUser.contains(objCase.OwnerId)) {
                        isCCAT = true;
                    }
                    
                    //CRM-9739
                    Boolean isResolutionConsultant = false;
                    if(setOfResolutionConsultants.contains(objCase.OwnerId)) {
                        isResolutionConsultant = true;
                    }
    
                    System.debug('EmailMessageTriggerHelper - isCCAT value - ' + isCCAT);
                    system.debug('Case status : ' + objCase.Status);
                    
                    Set<String> insternalEmailSet = new Set<String>();
                    if(objCase.QCC_Internal_Followup_Emails__c != NULL && objCase.QCC_Internal_Followup_Emails__c != '') {
                        insternalEmailSet.addall(objCase.QCC_Internal_Followup_Emails__c.toLowerCase().split(';')); // All values will be lower case
                    }
                    system.debug('insternalEmailSet : ' + insternalEmailSet);
                    boolean caseIsWaiting = false;
                    String emailFromAddress = eMessage.FromAddress.toLowerCase();
                    system.debug('eMessage.FromAddress : ' + emailFromAddress);
                    system.debug('objCase.Status : ' + objCase.Status);
                    //G-1693 - if case status is 'Waiting for Internal' and inbound message's FromAddress is in To_Address picklist, change status to 'Reply Received'
                    if((insternalEmailSet.contains(emailFromAddress )) && (objCase.Status == CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Internal'))) {
                        objCase.Status = REPLY_RECEIVED_STATUS;              
						objCase.OwnerId = (isCCAT || isResolutionConsultant) ? objCase.OwnerId : objCase.Last_Queue_Owner__c;     
                        System.debug('we need to update the case owner here Waiting for Internal'); 
                        objCase.Priority = CustomSettingsUtilities.getConfigDataMap('Case Priority Internal Escalation'); //(User Story: QSFR-23)
                        caseIsWaiting = true;
                    }else if((!insternalEmailSet.contains(emailFromAddress )) && (objCase.Status == CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Internal'))) {
                        objCase.Status = REPLY_RECEIVED_STATUS;              
						objCase.OwnerId = (isCCAT || isResolutionConsultant) ? objCase.OwnerId : objCase.Last_Queue_Owner__c;     
                        System.debug('we need to update status as reply received and the case owner'); 
                     }else if((!insternalEmailSet.contains(emailFromAddress)) && (objCase.Status ==  CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Customer') ||
                            //CDP2-337 added Pending Recovery status and queue checks
                            ((objCase.Status == CustomSettingsUtilities.getConfigDataMap('CaseStatusPendingRecovery') && objCase.OwnerId ==  CASE_PENDRECVY_QUEUE.Id)))) {

                       
                        system.debug('Entered in:');
                        //CRM-6927 Owner should route via routing table, for Non CCAT waiting for customer cases, when reply recevied.
                        //G-1693 - if case status is 'Waiting for Customer' and inbound message's FromAddress is not in To_Address picklist, change status to 'Reply Received'
                        objCase.Status = REPLY_RECEIVED_STATUS;  
                        //CDP2-337 - added Pending Recovery Q owner check to retain the owner id (Pending Recvy Q) and bypass active assignment rules run 
                        objCase.OwnerId = (isCCAT || isResolutionConsultant || objCase.OwnerId ==  CASE_PENDRECVY_QUEUE.Id)? objCase.OwnerId : ObjCase.Last_Queue_Owner__c;    
                        // Updated as per CDP2-644    
                        if(objCase.Recoveries_Case__r!=Null && objCase.Recoveries_Case__r.size()>0 && objCase.Recoveries_Case__r[0] != null){     
                            ObjCase.Last_Queue_Owner__c = objCase.Recoveries_Case__r[0].CreatedById;  
                            objCase.OwnerId = objCase.Recoveries_Case__r[0].CreatedById;
                            caseIdset.add(objCase.id);
                        }
                        objCase.Assign_using_active_assignment_rules__c = (isCCAT || isResolutionConsultant|| objCase.OwnerId ==  CASE_PENDRECVY_QUEUE.Id)? false : true;
                        //CDP2-337
                        objCase.Priority = CustomSettingsUtilities.getConfigDataMap('Case Priority Customer Reply'); //(User Story: QSFR-23)  
                        caseIsWaiting = true;
                        
                    }
                   
                    
                    if(caseIsWaiting) {
                        
                        //If a case is in Waiting for Customer or Waiting for Internal, and an email reply is received to this case
                        System.debug('processEmailMessage for waiting for customer/internal status: ' + objCase.Status);
                        //CDP2-337 - added Pending Recovery Q owner check to retain the owner id 
                        if(!isCCAT && !isResolutionConsultant && (objCase.OwnerId !=  CASE_PENDRECVY_QUEUE.Id)) {
                            if(objCase.RecordType.DeveloperName == RT_QCC_Specific_Needs) {
                                //For case record type = QCC Specific Needs, assign to "Special Needs Reply Received" queue
                                objCase.OwnerId = mapQueue.get('QCC_Specific_Needs_Reply_Received');
                            }
                            /*
                            else if(isVip && objCase.RecordTypeId != recTypeCCCRefund) { //CRM-4804
                                // Assign the case to VIP Team Regardless of Record Type
                                System.debug('inside isVip============> ');
 
                            }*/

							else if(objCase.RecordTypeId == recTypeCCCRefund) //CRM-4804
                            {
                                String queueName = CustomSettingsUtilities.getConfigDataMap('CCC_TicketingQueue');
                                objCase.OwnerId =mapQueue.get(queueName);
                            }
                            else{ 
                                //For case that is NOT VIP contact nor SSU and record type != QCC Specific Needs - assign to "Reply Received" queue
                                //(User Story: QSFR-23) START
                                Id queueId;
                                
                                System.debug('inside else part========>');
                                if(String.isBlank(objCase.Last_Queue_Owner__c) ) {
                                    queueId = getNewQueueId('NULL');
                                }
                                else if (deprecatedQueueList.contains(objCase.Last_Queue_Owner__c)) {
                                    queueId = getNewQueueId(objCase.Last_Queue_Owner__c);
                                }
                                else
                                    queueId = Id.valueOf(objCase.Last_Queue_Owner__c);
                                    
                                objCase.OwnerId = queueId;
                            }
                            
                        } else{
                            System.debug('final else block');
                            objCase.OwnerId = objCase.OwnerId;
    
                        }
                    }
                }
            }
    
            // PROCESS OUTBOUND MESSAGES
            else { // Make sure there(s) an OUTBOUND email message to process that is related to case to prevent unnecessary process/soql
                //If Email Message is Related to a Parent Case then update some of Case record Fields.
                //GRAPHITE-1926 - If Case Recordtype is Specific Needs then ToAddress is the field being populated; hence information should come from this field.
                system.debug('ToAddress : ' + eMessage.ToAddress);
                system.debug('To_Address__c : ' + eMessage.To_Address__c);
                System.debug('eMessage.QCC_Tech_Is_Internal_Email__c=======> ' + eMessage.QCC_Tech_Is_Internal_Email__c);
                System.debug('objCase========> ' + objCase);
                if(eMessage.QCC_Tech_Is_Internal_Email__c && objCase != Null) { // Make sure it is comming from Qantas Correspondence before writing QCC_Internal_Followup_Emails__c Case field
                    if(objCase.RecordType.DeveloperName == RT_QCC_Specific_Needs ) {
                        objCase.QCC_Internal_Followup_Emails__c = eMessage.ToAddress;
                    }
                    else {
                        //GRAPHITE-1579 Change from ToAddress to To_Address__c field since this is the field being populated in Qantas Correspondence only
                        objCase.QCC_Internal_Followup_Emails__c = eMessage.To_Address__c;
                    }
                    // Save outbound email addresses
                    objCase.Email_Content__c = eMessage.HtmlBody; // Save outbound email addresses
                }
                
            }
           
            //Migrated to flow
            //QCC_FeedMentionforcasestatus.mentionTextPost(objCase.id);
        if(!caseIdset.isempty()){
            CaseAssignmentHandler.handleCaseAssignment(caseIdset);
        }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'processCaseEmailMessage', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
        return objCase;
        
    }
    
    /*--------------------------------------------------------------------------------------
    Method Name:        fetchQantasCorporateAccountEmails
    Description:        Method to fetch Qantas Corporate Account Emails
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static Set<String> fetchQantasCorporateAccountEmails () {
        
        Set<String> corporateAccountEmails = new Set<String>();
        try {
            for(Contact ct : [Select Id,Name,Email From Contact Where Account.Name ='QantasCorporateEmailAccount']){
                if (String.isNotBlank(ct.Email)) {
                    corporateAccountEmails.add(ct.Email);
                } 
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'fetchQantasCorporateAccountEmails', String.valueOf(''), String.valueOf(''),false, '', ex);
        }
        return corporateAccountEmails; 
    }

    
    /*--------------------------------------------------------------------------------------
    Method Name:        fetchAllOutboundEmailsOfACase
    Description:        Method to fetch all outbound emails of a Case
    Parameter:          Map<Id,Case>, Map<Id,Id>, Map<Id,Integer>, Set<String>
    --------------------------------------------------------------------------------------*/
    public static Set<Id> fetchAllOutboundEmailsOfACase (Map<Id,Case> qccOutboundcasesTobeActionedMap, Map<Id,Id> qccOutboundCaseEmailMap, 
                                                            Map<Id,Integer> qccCaseIdEmailCountMap) {
        
        Set<Id> caseOutboundEmails = new Set<Id>();
        try {
            String internalEmail = Label.Internal_Email;
            for(EmailMessage em : [Select Id, parentId, Incoming, ToAddress from EmailMessage where parentId IN: qccOutboundcasesTobeActionedMap.keySet() AND 
                                   Incoming = false AND Id NOT IN: qccOutboundCaseEmailMap.values()]) {
				if(string.isNotBlank(em.ToAddress)) {
                String custEmail = em.ToAddress.replace(internalEmail,'');
                system.debug('Email##cust '+custEmail);
                Boolean emailFound = false; 
                
                String splitBy = em.ToAddress.contains(',') ? ',' : ';';
                                
                for(String toAdd : em.ToAddress.split(splitBy)) {

                    toAdd = (toAdd!=null)?toAdd.trim():'';
                    emailFound = (toAdd !=null && !CORPORATEACCOUNTEMAILS.contains(toAdd)) ? true : false;
                }
                
                if(custEmail.contains('@') && emailFound && !qccOutboundcasesTobeActionedMap.get(em.ParentId).Acknowledgement_Sent__c)
                    caseOutboundEmails.add(em.ParentId);
                else if(custEmail.contains('@') && emailFound && qccOutboundcasesTobeActionedMap.get(em.ParentId).Acknowledgement_Sent__c)
                {
                    //CRM-6701
                    if ((em.ParentId != null) && (qccCaseIdEmailCountMap.get(em.ParentId) != Null) && (string.valueOf(em.parentId).startsWith('500') || (string.valueOf(em.parentId).startsWith('a22'))))
                    {
                        qccCaseIdEmailCountMap.put(em.ParentId,qccCaseIdEmailCountMap.get(em.ParentId) + 1);
                    }
                }
              }
                
                if(qccCaseIdEmailCountMap!=Null && !qccCaseIdEmailCountMap.isEmpty() && qccCaseIdEmailCountMap.get(em.ParentId) > 1)
                    caseOutboundEmails.add(em.ParentId);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'fetchAllOutboundEmailsOfACase', String.valueOf(''), String.valueOf(''),false, '', ex);
        }
        return caseOutboundEmails; 
    }
    
    /*--------------------------------------------------------------------------------------
    Method Name:        captureFirstOutboundEmail
    Description:        Method to capture First email to customer
    Parameter:          EmailMessage, Case, Set<Id>
    --------------------------------------------------------------------------------------*/
    Public static Case captureFirstOutboundEmail(EmailMessage emailMsg, Case objCase, Set<Id> caseOutboundEmails) {
        try {
            if(!caseOutboundEmails.contains(emailMsg.parentId))    
            {
                if(objCase != null && objCase.First_email_to_customer__c == null)
                {
                    objCase.First_email_to_customer__c = emailMsg.CreatedDate;
                }
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'captureFirstOutboundEmail', String.valueOf(''), String.valueOf(''),false, emailMsg.id != null ? emailMsg.id : '', ex);
        }
        return objCase;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        fetchCaseQueueInfo
    Description:        Method to Create a map of Queue to avoid SOQL
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void fetchCaseQueueInfo() {

        try {
            for(QueueSobject queueObj: queueSObjectList) {
                mapQueue.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
            }
            
            for (CCC_R1_OldtoNewQueueMap__mdt eachMapItem : CCC_R1_OldtoNewQueueMap__mdt.getAll().Values()) {
                oldQueueIdToNewQueueDevName.put(eachMapItem.CCC_R1_Old_Queue_Id__c, eachMapItem.CCC_R1_New_Queue_DevName__c);
            }

            List<String> reactivatedQueuesLabelNames = new List<String>();
            reactivatedQueuesLabelNames.addAll(Label.QCC_Reactivated_Queues.split(';'));
            //CCC_Auckland_Queue_SLA;CCC_Auckland_Queue_High;CCC_Auckland_Queue_Medium;CCC_Auckland_Queue_Low;Insurance_Queue_High;Flight_Disruptions_Queue_High;Qantas_com_Queue_SLA;Qantas_com_Queue_Low;Qantas_com_Queue_Medium;Qantas_com_Queue_High;Other_Queue_SLA;Other_Queue_Low;Other_Queue_High;Other_Queue_Medium;Contact_Centres_Queue_SLA;Contact_Centres_Queue_Low;Contact_Centres_Queue_Medium;Contact_Centres_Queue_High;Airports_Queue_Low;Airports_Queue_Medium;Airports_Queue_High

            for (CCC_R1_OldtoNewQueueMap__mdt eachMapItem : CCC_R1_OldtoNewQueueMap__mdt.getAll().Values()) {
                if (!reactivatedQueuesLabelNames.contains(eachMapItem.label)) {
                    deprecatedQueueList.add(eachMapItem.CCC_R1_Old_Queue_Id__c);
                }
            }

        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'fetchCaseQueueInfo', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        getNewQueueId
    Description:        Method to fetch queueId
    Parameter:          String
    --------------------------------------------------------------------------------------*/
    public static Id getNewQueueId(String oldQueueId) {

        try {
            if(oldQueueIdToNewQueueDevName.containsKey(oldQueueId)  && mapQueue.containsKey(oldQueueIdToNewQueueDevName.get(oldQueueId)) ) {
                return mapQueue.get(oldQueueIdToNewQueueDevName.get(oldQueueId));
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Email Message', 'EmailMessageQCCTriggerHandler',
                                    'getNewQueueId', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
        return null;

    }

    public static List<Case> insertTasks(List<EmailMessage> emailMessageList, Map<Id, Case> caseMap) {
        Task taskRecord;
        Case caseRecord;
        List<Case> editCases = new List<Case>();
        Map<Id,Case> editCaseMap = new Map<Id,Case>();
        List<Task> addTasks = new List<Task>();
        DateTime currDate, addedTwoDays;
        try {
            for (EmailMessage emRecord : emailMessageList) {   
                if (String.isNotBlank(emRecord.ParentId)) {
                    caseRecord = caseMap.get(emRecord.ParentId);
                    caseRecord.Email_Content__c = emRecord.HtmlBody;
                    //caseRecord.Email_Content__c = String.isNotBlank(emRecord.HtmlBody) ? emRecord.HtmlBody.left(32767) : emRecord.HtmlBody;
                    if (!emRecord.TECH_FromChatter__c && !emRecord.Incoming) {
                        if (caseRecord.Auto_Close_on_Email_Sent__c) {
                            //GRAPHITE- 1380 - comment out 136 then replace status w/ Resolved
                            caseRecord.Status = CASE_CLOSED_STATUS; // Jira 4960
                            caseRecord.Resolution_Method__c = RM_AUTOCLOSED_CASE;
                            caseRecord.Reason = REASON_CLOSE_CASE;
                            caseRecord.Closed_By__c = LOGGEDINUSERINFO.Id;
                            if (String.isNotBlank(LOGGEDINUSERINFO.Location__c)) {
                                caseRecord.ClosedByLocation__c = LOGGEDINUSERINFO.Location__c;
                            }
                            //For Defect --> JIRA-2437 added below condition....
                            if (caseRecord.Type == TYPE_INSURANCELETTER_CASE || caseRecord.Type == TYPE_CCCINSURANCELETTER_CASE) {
                                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, caseRecord.Id, ConnectApi.FeedElementType.FeedItem, 'Insurance letter sent to customer and case closed');
                            }
                        }
                        //QDCUSCON 3340 post feed to chatter when recovery in progress can't automatically close case
                        if (caseRecord.Recovery_Inprogress__c) {
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, caseRecord.Id, ConnectApi.FeedElementType.FeedItem, 'Email sent and case is not auto-closed since a recovery was still in progress');
                            caseRecord.Recovery_Inprogress__c = false;
                        }
                        //end QDCUSCON 3340
                    }
                    if (!emRecord.Incoming && String.isNotBlank(emRecord.ToAddress) && CORPORATEACCOUNTEMAILS.contains(emRecord.ToAddress.removeEnd(','))) {
                        currDate = emRecord.CreatedDate==null ? System.now() : emRecord.CreatedDate;
                        addedTwoDays = currDate.addDays(2);
                        taskRecord = new Task(
                            Subject = 'Reminder for other departments to respond',
                            Status = 'In Progress',
                            WhatId = emRecord.ParentId,
                            ActivityDate = addedTwoDays.date(),
                            Email__c = emRecord.ToAddress,
                            Task_From__c = 'QantasCorporateEmailAccount',
                            WhoId = caseRecord.ContactId,
                            Case_Status__c = caseRecord.Status
                        );
                        addTasks.add(taskRecord);
                    }
                    //editCases.add(caseRecord);
                    editCaseMap.put(emRecord.ParentId, caseRecord);
                }
            }
            if (!addTasks.isEmpty()) {
                List<Database.SaveResult> results = Database.insert(addTasks, false);
                List<Log__c> logRecords = new List<Log__c>();
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()){
                            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Log Exception Logs Rec Type', 'EmailMessageQCCTriggerHandler',
                                                                                     'insertTasks', '', '', false, '', null, err.getMessage());
                            logRecords.add(logRecord);
                        }
                    }
                }
                if (!logRecords.isEmpty()) {
                    QCC_LogUtilityHelper.createLogRecords(logRecords);
                        }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'EmailMessageTriggerHandler', 'insertTasks', '', '', false, '', ex);
        }
        //return editCases;
        return editCaseMap.values();
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        fetchLatestOpenChildCase
    Description:        Method to fetch latest open child case
    Parameter:          Set<Id>
    --------------------------------------------------------------------------------------*/
    public static Map<Id, Case> fetchLatestOpenChildCase(Set<Id> parentCaseIds) {

        Map<Id, Case> latestParentChildCaseMap = new Map<Id, Case>(); 
        try {
            
                for (Case objCase : [ SELECT Id,CaseNumber, ParentId,Status FROM Case WHERE ParentId IN :parentCaseIds AND  Status != 'Closed' ]) {

                        System.debug('objCase======> ' + objCase);
                        latestParentChildCaseMap.put(objCase.ParentId, objCase);
                }
                System.debug('latestParentChildCaseMap======> ' + latestParentChildCaseMap);

        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'EmailMessageQCCTriggerHandler', 'fetchLatestOpenChildCase', '', '', false, '', ex);
        }

        return latestParentChildCaseMap;                                                   

    }

}