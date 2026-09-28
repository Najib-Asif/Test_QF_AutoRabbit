/**
 * @description       : Case Trigger Handler Class, handles all the case trigger logics
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 05-07-2024
 * @last modified by  : Praveen Sampath
**/
public class CaseTriggerHandler extends TriggerHandler {
    
    //Trigger Context Variables
    private Map<Id, Case> newCaseMap;
    private Map<Id, Case> oldCaseMap;
    private List<Case> newCaseList;
    private List<Case> oldCaseList;
    
    List<String> baggageReferenceNumberList = new List<String>();
    List<String> qccReferenceNumberList = new List<String>();
    private List<Case> newQCCCaseList = new List<Case>();
    private List<Case> newOtheraseList = new List<Case>();
    private Map<Id, Case> newQCCCaseMap = new Map<Id, Case>();
    private List<Case> qantasAndRedAppCaseList = new List<Case>();
    private List<Id> newQCCCaseContactIds = new List<Id>();
    private List<Case> newBaggageCaseList = new List<Case>();
    private List<Id> newBaggageCaseContactIds = new List<Id>();
    private Map<Id, Case> oldFreightCaseMap = new Map<Id, Case>();
    private Map<Id, Case> caseQueueMap = new Map<Id, Case>();
    private List<Id> qccParentCaseIds = new List<Id>();
    private Map<String, Id> qccRecordTypeMap;
    private Set<Id> qccRecordTypeIds;
    private Map<String, Id> freightRecordTypeMap;
    private Set<Id> freightRecordTypeIds;
    private Map<String, Id> otherRecordTypeMap;
    private Set<Id> otherRecordTypeIds;
    private Map<Id, Case> qccSensitiveCaseMap;
    private List<Id> accountRelationShipList = new List<Id>(); //Added as a part of CRM-8122

    // FINAL VARIABLES
    private static final String CNDSRF_FI = 'Chatter_Notification_Deal_Support_Request_FlowInterview-';
    private static final Id CASE_ASSGNRULEID = CaseUtility.getAssignmentRuleId(Label.QCC_AssignmentRuleName);
    private static final String CASE_ASSIGNMENTFLAG = Label.QCC_Case_Assignment_Flag;
    private static final String ORIGIN_QANTASCOM = CustomSettingsUtilities.getConfigDataMap('QCC Qantas');
    private static final String ORIGIN_REDAPP = CustomSettingsUtilities.getConfigDataMap('QCC_Red App');
    private static final String COMMA_CHECK = CustomSettingsUtilities.getConfigDataMap('Comma check');
    private static final String EMPTY_STRING = '';
    // To fetch RecordTypes developer name and ids based on business unit
    public static final Map<String, Map<String, Id>> BU_RECORDTYPEMAP =  CaseUtility.mapBUnitToCaseRecordTypes();
    // To fetch queues specific to Case object in the form of map
    public static final Map<Id, Group> QUEUE_GROUPMAP = CaseUtility.queryQueueGroups();
    // To fetch Approval Matrix id and record as key-value pair
    private static final Map<Id, Approval_Matrix__c> APPROVALMATRIX_MAP = CaseUtility.queryApprovalMatrices();
    private static final String RTID_SRFLIGHT = Schema.SObjectType.Flight__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final String RTID_SRWORDER = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final String RTID_AFFPASS = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final List<QualtricsSurvey__mdt> QUALTRICSSURVEY_LIST = CaseUtility.getQualtrics();
    //private static final Map<String, Group> QUEUE_DATA = CaseUtility.getQueueInfo();

    public CaseTriggerHandler() {
        this.newCaseMap = (Map<Id, Case>) Trigger.newMap;
        this.oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
        this.newCaseList = (List<Case>) Trigger.new;
        this.oldCaseList = (List<Case>) Trigger.old;
        this.qccRecordTypeMap = BU_RECORDTYPEMAP.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitQCC'));
        this.qccRecordTypeIds = new Set<Id>(qccRecordTypeMap.values());
        this.freightRecordTypeMap = BU_RECORDTYPEMAP.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitFreight'));
        this.freightRecordTypeIds = new Set<Id>(freightRecordTypeMap.values());
        this.otherRecordTypeMap = BU_RECORDTYPEMAP.get(CustomSettingsUtilities.getConfigDataMap('BusinessUnitOthers'));
        this.otherRecordTypeIds = new Set<Id>(otherRecordTypeMap.values());
        /*
        //Max Loop Count for the Case Trigger
        Integer loopCount = (CustomSettingsUtilities.getConfigDataMap('CaseTriggerLoopCount') != null && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap('CaseTriggerLoopCount')))? Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('CaseTriggerLoopCount')) : 2;
        this.setMaxLoopCount(loopCount);
        */
    }
    public override void beforeInsert() {
        
            // Do something before insert   
            List<Case> newFreightCaseList = new List<Case>();
            Set<String> freightEmailIds = new Set<String>();
            Set<Id> freightPortIds = new Set<Id>();
            Set<Id> freightAccountIds = new Set<Id>();
            Set<Id> commonAccountIds = new Set<Id>();
            User usrInfo = fetchCurrentUserInfo();
            Set<Id> userIds = new Set<Id>{ UserInfo.getUserId() };
            Map<Id, User> userMap;
            Date currentDate = System.now().date();
            for(Case objCase : newCaseList){
                String gsaKey = 'GSA_' + usrInfo.GSA_User__c + '_Type';
                objCase.User_Type__c = CustomSettingsUtilities.getConfigDataMap(gsaKey) != null ? CustomSettingsUtilities.getConfigDataMap(gsaKey) : EMPTY_STRING;
                objCase = updateCaseCalculatedFields(objCase);
                system.debug('qccRecordTypeIds =====> ' + qccRecordTypeIds);
                //All QCC Cases
                if(objCase.RecordTypeId != null && qccRecordTypeIds != null && qccRecordTypeIds.contains(objCase.RecordTypeId)) {
                    newQCCCaseList.add(objCase);
                    if(objCase.Description!=Null){
                        qccReferenceNumberList.add(extractReferenceNumber(objCase.Description));
                    }
                    if (objCase.ContactId != Null) {
                        newQCCCaseContactIds.add(objCase.ContactId);
                    }
                } else if (objCase.RecordTypeId != null && freightRecordTypeIds != null && freightRecordTypeIds.contains(objCase.RecordTypeId)) {
                    // All Freight Cases
                    if (String.isNotBlank(objCase.SuppliedEmail)) {
                        freightEmailIds.add(objCase.SuppliedEmail);
                    }
                    if (String.isNotBlank(objCase.Freight_Port__c)) {
                        freightPortIds.add(objCase.Freight_Port__c);
                    }
                    if (objCase.AccountId != null) {
                        freightAccountIds.add(objCase.AccountId);
                    }
                    newFreightCaseList.add(objCase);
                } else if(objCase.RecordTypeId != null && otherRecordTypeIds != null && otherRecordTypeIds.contains(objCase.RecordTypeId)) {
                    //All Other Cases
                    newOtheraseList.add(objCase);
                    accountRelationShipList.add(objCase.TMC__c);//Added for CRM-8122
                }
                if (String.isNotBlank(objCase.Description)) {
                    objCase = maskCreditCard(objCase, false);
                }
                objCase = updateCaseForQualtricsSurveyNotification(objCase);
                if (objCase.OwnerId != null && !String.valueOf(objCase.OwnerId).startswith('00G')) {
                    userIds.add(objCase.OwnerId);
                }
            }
            userMap = CaseUtility.queryUsers(userIds);
            system.debug(LoggingLevel.debug , 'newQCCCaseList ---'+newQCCCaseList);
            // Invoke QCC logics
            if(newQCCCaseList != null && !newQCCCaseList.isEmpty()) {
                CaseQCCTriggerHandler.onBeforeInsert(newQCCCaseList, qccRecordTypeMap, newQCCCaseContactIds, qccReferenceNumberList);
            }

            if (!newFreightCaseList.isEmpty()) {
                CaseFreightTriggerHandler.onBeforeInsert(newFreightCaseList, freightRecordTypeMap, QUEUE_GROUPMAP, freightEmailIds, freightPortIds, freightAccountIds, APPROVALMATRIX_MAP, userMap);
            }

            if (!newOtheraseList.isEmpty()) {
                CaseOthersTriggerHandler.onBeforeInsert(newOtheraseList, QUEUE_GROUPMAP, accountRelationShipList);
            }
        System.debug('### CaseTriggerHandler.beforeInsert():'+newCaseList);
            for(Case objCase : newCaseList) {
                if (objCase.Status == CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')) {
                    objCase.Resolve_Closeddate__c = currentDate;
                    objCase.Qualtrics_Survey_Notification_Date__c = currentDate;//jira-CRM-4962
                } /**Jira 4960*/
            }
        
    }

    public override void afterInsert() {
        try {
            /* CRM-8725 -- start */
            Set<String> pnrSet = new Set<String>();
            Set<Id> flightEventIds = new Set<Id>();
            Map<String, Set<Id>> pnrEventIdMap;
            Map<Id, Event__c> eventMap;
            /* CRM-8725 -- end */
            Set<String> flowLabelsSet = new Set<String>();
            Map<String, FlowInterview> flowInterviewMap = new Map<String, FlowInterview>();
            List<Case> otherCasesList = new List<Case>();
            List<Case> updateCaseUsingAssgnRule = new List<Case>();
            for(Case objCase : newCaseList){
                if(objCase.RecordTypeId != NULL && qccRecordTypeIds != NULL && qccRecordTypeIds.contains(objCase.RecordTypeId)) {
                    newQCCCaseMap.put(objCase.Id, objCase);
                    
                    if (objCase.ContactId != Null) {
                        newQCCCaseContactIds.add(objCase.ContactId);
                    }
                    if(String.isNotBlank(objCase.Booking_PNR__c)){ //PNRCheck CRM-8661
                        pnrSet.add(objCase.Booking_PNR__c);
                    }
                    System.debug('objCase.Origin=======> ' + objCase.Origin);
                    System.debug('ORIGIN_QANTASCOM=======>' + ORIGIN_QANTASCOM);
                    System.debug('CaseTriggerHandler.AfterInsert() - objCase.Channel_Type__C: ' + objCase.Channel_Type__C);
                    if (objCase.Origin == ORIGIN_QANTASCOM || objCase.Origin == ORIGIN_REDAPP) {
                        qantasAndRedAppCaseList.add(objCase);
                    }
                    if(objCase.Sensitive__c == true && oldCaseMap.get(objCase.Id).Sensitive__c == false) {
                        if(qccSensitiveCaseMap == NULL) {
                            qccSensitiveCaseMap = new Map<Id, Case>();
                        }
                        qccSensitiveCaseMap.put(objCase.Id, objCase);
                    }
                }      
                if(objCase.RecordTypeId != NULL && otherRecordTypeIds != NULL && otherRecordTypeIds.contains(objCase.RecordTypeId)) {
                    otherCasesList.add(objCase);
                    flowLabelsSet.add(CNDSRF_FI+String.valueOf(objCase.Id));
                }
                if (String.isNotBlank(objCase.Comments__c) && objCase.Comments__c.contains(CASE_ASSIGNMENTFLAG)) {
                    updateCaseUsingAssgnRule.add(objCase);
                }
            }
            System.debug('qantasAndRedAppCaseList========> ' + qantasAndRedAppCaseList);
            /* CRM-8725 -- start */
            pnrEventIdMap = queryAffectedPassengers(pnrSet);
            for (Set<Id> eventIds : pnrEventIdMap.values()) {
                flightEventIds.addAll(eventIds);
            }
            eventMap = queryFlightEvents(new Set<Id>(flightEventIds));
            /* CRM-8725 -- end */
            if(!newQCCCaseMap.isEmpty()) {
                CaseQCCTriggerHandler.afterInsert(newQCCCaseMap, newQCCCaseContactIds, qantasAndRedAppCaseList, qccSensitiveCaseMap, pnrEventIdMap, eventMap);
            }
            flowInterviewMap = queryFlowInterviews(flowLabelsSet);
            if (!otherCasesList.isEmpty()) {
                CaseOthersTriggerHandler.afterInsert(otherCasesList, QUEUE_GROUPMAP, flowInterviewMap);
            }
            if (!updateCaseUsingAssgnRule.isEmpty()) {
                assignVIPCaseUsingAssignmentRule(updateCaseUsingAssgnRule);
            }
            //GRAPHITE-1372 Send update to Loyalty once a case record has been created or the status has been updated.
            if(System.isQueueable() == false && System.isFuture() == false && System.isBatch() == false && System.isScheduled() == false){
                System.enqueueJob(new LoyaltyCaseStreamQueue(newCaseList, null));
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler', 
                'afterInsert', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    public static boolean CaseQCCTriggerHandleronBeforeUpdate = false; // Added variable to avoid recursion
       public override void beforeUpdate() {
                
            System.debug('inside beforeUpdate');
           // Do something before insert  
           Map<Id, User> userMap;
           Set<Id> userIds = new Set<Id>{ UserInfo.getUserId() };
           Map<Id, Case> oldQCCCaseMap = new Map<Id, Case>();
           Map<Id, Case> newQCCCaseMap = new Map<Id, Case>();
           Map<Id, Case> oldFreightCaseMap = new Map<Id, Case>();
           Map<Id, Case> newFreightCaseMap = new Map<Id, Case>();
           Map<Id, Case> oldOthersCaseMap = new Map<Id, Case>();
           List<Case> newOthersCases = new List<Case>();
            //CDP2-265 
           List<Case> newCasesList = new list<case>();
           Map<Id, Case> oldRecoveryCaseMap = new map<id,case>();
           //CDP2-265
           Set<Id> freightPortIds = new Set<Id>();
            Set<Id> freightAccountIds = new Set<Id>();
            Set<Id> newQCCCaseContactIds = new Set<Id>();
            System.debug('qccRecordTypeIds=======> ' + qccRecordTypeIds);
            Case oldCaseRecord;
            Date currentDate = System.now().date();
            for(Case objCase : newCaseList){
                oldCaseRecord = oldCaseMap.get(objCase.Id);
                objCase = updateCaseCalculatedFields(objCase);
                if (oldCaseRecord.OwnerId != null && !String.valueOf(oldCaseRecord.OwnerId).startswith('00G')) {
                    userIds.add(oldCaseRecord.OwnerId);
                }
                if (oldCaseMap.get(objCase.Id).OwnerId != NULL) {
                    caseQueueMap.put(oldCaseMap.get(objCase.Id).OwnerId, objCase);
                }
                
                if (objCase.RecordTypeId != NULL && qccRecordTypeIds != NULL && qccRecordTypeIds.contains(objCase.RecordTypeId)){
                    newQCCCaseList.add(objCase);
                    newQCCCaseMap.put(objCase.Id, objCase);
                    oldQCCCaseMap.put(objCase.Id, oldCaseMap.get(objCase.Id));
                    if(objCase.Description!=Null){
                        qccReferenceNumberList.add(extractReferenceNumber(objCase.Description));
                    }
                    //qccCaseIds.add(objCase.Id);
                    if (objCase.ParentId != null)
                    {
                        qccParentCaseIds.add(objCase.ParentId);
                    }
                    if (objCase.ContactId != null) {
                        newQCCCaseContactIds.add(objCase.ContactId);
                    }
                }

                if (objCase.RecordTypeId != NULL && freightRecordTypeIds != NULL && freightRecordTypeIds.contains(objCase.RecordTypeId)) {
                    newFreightCaseMap.put(objCase.Id, objCase);
                    oldFreightCaseMap.put(objCase.Id, oldCaseMap.get(objCase.Id));
                    if (!String.isBlank(objCase.Freight_Port__c)) {
                        freightPortIds.add(objCase.Freight_Port__c);
                    }
                    if (objCase.AccountId != null) {
                        freightAccountIds.add(objCase.AccountId);
                    }
                }
                if (objCase.RecordTypeId != NULL && otherRecordTypeIds != NULL && otherRecordTypeIds.contains(objCase.RecordTypeId)) {
                    newOthersCases.add(objCase);
                    oldOthersCaseMap.put(objCase.Id, oldCaseMap.get(objCase.Id));
                }
                if (String.isNotBlank(objCase.Description)) {
                    objCase = maskCreditCard(objCase, false);
                }
                objCase = updateCaseForQualtricsSurveyNotification(objCase);
               //CDP2-265 CDP2-197
                if(oldCaseRecord.Status != objCase.Status && (objCase.status == 'Pending Recovery' || objCase.status == 'Closed'  )){
                    newCasesList.add(objCase);
                    oldRecoveryCaseMap.put(objCase.id,oldCaseRecord);
                }
                //CDP2-265
            }
            userMap = CaseUtility.queryUsers(userIds);
            if(!newQCCCaseMap.isEmpty()  && !CaseQCCTriggerHandleronBeforeUpdate) { // added extra static variable to stop recursion on 02/09/2024
                CaseQCCTriggerHandleronBeforeUpdate = true;
                CaseQCCTriggerHandler.onBeforeUpdate(newQCCCaseMap, oldQCCCaseMap, qccRecordTypeMap, caseQueueMap, qccReferenceNumberList, qccParentCaseIds, newQCCCaseContactIds, userMap);
            }

            if (!newFreightCaseMap.isEmpty()) {                 
                CaseFreightTriggerHandler.onBeforeUpdate(oldFreightCaseMap, newFreightCaseMap, freightRecordTypeMap, freightPortIds, freightAccountIds, APPROVALMATRIX_MAP, userMap);
            }
            if (!newOthersCases.isEmpty()) {                
                CaseOthersTriggerHandler.beforeUpdate(newOthersCases, oldOthersCaseMap, userMap, QUEUE_GROUPMAP);
            }
            for(Case objCase : newCaseList) {
                if (oldCaseRecord.Status != objCase.Status) {
                    objCase.QCC_Status_Changed_Date__c = System.now();
                    if (objCase.Status == CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')) {
                        objCase.Resolve_Closeddate__c = currentDate;
                        objCase.Qualtrics_Survey_Notification_Date__c = currentDate;//jira-CRM-4962
                    } /**Jira 4960*/
                }
                
                //Added as per JIRA CRM-10622
                if(objCase.Channel_Type__c==null && qccRecordTypeIds.contains(objCase.RecordTypeId)){
                    System.debug('### CaseTriggerHandler.beforeUpdate() ->  assignQCCFields()');
                    CaseQCCTriggerHandler.assignQCCFields(objCase);
                }
                
            System.debug('### CaseTriggerHandler.beforeUpdate() -> objCase.Channel_Type__c'+objCase.id+' '+objCase.Channel_Type__c);
            }
            //CDP2-265
            if(!newCasesList.isempty()){
                CaseStatusUpdateHandler.handleCaseStatusUpdate(newCasesList,oldRecoveryCaseMap);
            }
            //CDP2-265
    }

    public override void afterUpdate() {
            /* CRM-8725 -- start */
            Set<String> pnrSet = new Set<String>();
            Set<Id> flightEventIds = new Set<Id>();
            Map<String, Set<Id>> pnrEventIdMap;
            Map<Id, Event__c> eventMap;
            /* CRM-8725 -- end */
            Map<String, FlowInterview> flowInterviewMap;
            Set<String> flowLabelsSet = new Set<String>();
            Map<Id, Affected_Passenger__c> affectedPassengerMap = CaseUtility.queryAffectedPassengers(newCaseMap.keySet(), RTID_AFFPASS);
            Map<Id, Flight__c> flightMap = CaseUtility.queryFlights(newCaseMap.keySet(), RTID_SRFLIGHT);
            Map<Id, WorkOrder> workOrderMap = CaseUtility.queryWorkOrders(newCaseMap.keySet(), RTID_SRWORDER);
            List<Case> updateCaseUsingAssgnRule = new List<Case>();
            // Do something after update
            List<Case> newOthersCases = new List<Case>();
            Map<Id, Case> oldOthersCaseMap = new Map<Id, Case>();
            Id dealSupportRequest = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_DealSupportRequest')).getRecordTypeId();
            Map<Id, Case> newDealSupportRequestCaseMap = new Map<Id, Case>();
            Map<Id, Case> oldDealSupportRequestCaseMap = new Map<Id, Case>();
            List<FlowInterview> flowInterviews = new List<FlowInterview>();
            //CRM-3506 Send Fare attachment (excel) from Salesforce Case to external address
            for (Case objCase : newCaseList) {
                if(objCase.RecordTypeId != NULL && qccRecordTypeIds != NULL && qccRecordTypeIds.contains(objCase.RecordTypeId)) {
                    newQCCCaseMap.put(objCase.Id, objCase);
                    if (objCase.ContactId != Null) {
                        newQCCCaseContactIds.add(objCase.ContactId);
                    }
                    if(objCase.Sensitive__c == true && oldCaseMap.get(objCase.Id).Sensitive__c == false) {
                        if(qccSensitiveCaseMap == NULL) {
                            qccSensitiveCaseMap = new Map<Id, Case>();
                        }
                        qccSensitiveCaseMap.put(objCase.Id, objCase);
                    }
                    if(String.isNotBlank(objCase.Booking_PNR__c) 
                       && oldCaseMap.get(objCase.Id) != null && oldCaseMap.get(objCase.Id).Booking_PNR__c != objCase.Booking_PNR__c)
                    { //PNRCheck CRM-8661
                        pnrSet.add(objCase.Booking_PNR__c);
                    }
                }
                if (objCase.RecordTypeId != NULL && otherRecordTypeIds != NULL && otherRecordTypeIds.contains(objCase.RecordTypeId)) {
                    newOthersCases.add(objCase);
                    oldOthersCaseMap.put(objCase.Id, oldCaseMap.get(objCase.Id));
                    flowLabelsSet.add(CNDSRF_FI+String.valueOf(objCase.Id));
                }
                if (String.isNotBlank(objCase.Comments__c) && objCase.Comments__c.contains(CASE_ASSIGNMENTFLAG)) {
                    updateCaseUsingAssgnRule.add(objCase);
                }
            }
            flowInterviewMap = queryFlowInterviews(flowLabelsSet);
            /* CRM-8725 -- start */
            pnrEventIdMap = queryAffectedPassengers(pnrSet);
            for (Set<Id> eventIds : pnrEventIdMap.values()) {
                flightEventIds.addAll(eventIds);
            }
            eventMap = queryFlightEvents(new Set<Id>(flightEventIds));
            /* CRM-8725 -- end */
            if(!newQCCCaseMap.isEmpty()) {
                CaseQCCTriggerHandler.afterUpdate(newQCCCaseMap, this.oldCaseMap, newQCCCaseContactIds, qccSensitiveCaseMap, pnrEventIdMap, eventMap); //Added qccPNRCasIdsMap as a part of CRM-8661
            }

            if (!newOthersCases.isEmpty()) {
                CaseOthersTriggerHandler.onAfterUpdate(newOthersCases, oldOthersCaseMap, QUEUE_GROUPMAP, flightMap, workOrderMap, affectedPassengerMap, flowInterviewMap);
            }
            if (!updateCaseUsingAssgnRule.isEmpty()) {
                assignVIPCaseUsingAssignmentRule(updateCaseUsingAssgnRule);
            }
            
            if(test.isrunningtest() == false && System.isQueueable() == false && System.isFuture() == false && System.isBatch() == false && System.isScheduled() == false){
                System.enqueueJob(new CaseAfterUpdateQueue(newCaseList, oldCaseMap));
            }
    }
    
    public override void beforeDelete() {
        // Do something before delete
    }

/*----------------------------------------------------------------------------------------------      
    Method Name:        updateCaseForQualtricsSurveyNotification
    Description:        Make Qualtrics_Survey_Required__c to true if the picklist value on case 
                        is present in custom metadata 
    Parameter:          Case New Record
----------------------------------------------------------------------------------------------*/
    public static Case updateCaseForQualtricsSurveyNotification(Case caseRecord) {
        try {
            String str = String.valueOf(Schema.SObjectType.Case.getRecordTypeInfosById().get(caseRecord.RecordTypeId).getDeveloperName());
            for (QualtricsSurvey__mdt qualtrics : QUALTRICSSURVEY_LIST) {
                if (qualtrics.Case_Record_Type__c == str && qualtrics.Type__c == caseRecord.Type && qualtrics.Category__c == caseRecord.Category__c && qualtrics.Group__c == caseRecord.Group__c && qualtrics.Sub_Category__c == caseRecord.Sub_Category__c)
                {
                    caseRecord.Qualtrics_Survey_Required__c = false;
                    return caseRecord;
                }
            }
            caseRecord.Qualtrics_Survey_Required__c = true;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler', 'updateCaseForQualtricsSurveyNotification', '', '', false, '', ex);
        }
        return caseRecord;
    }
    
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        segregateEmailMsgBodyAndFooter   
    Description:        it will seperate the email body and footer msg from email message. Jira: CRM-4843
    Parameter:          String emailMsg
    ----------------------------------------------------------------------------------------------*/
    @InvocableMethod(label='Segregate Email Message Body And Footer' description='')
    public static List<String> segregateEmailMsgBodyAndFooter(List<String> emailMsgs)
    {
        List<String> response = new List<String>();
        try {

            String emailMsg = emailMsgs[0];
            System.debug('emailMsg========> ' + emailMsg);
            
            //CRM-7348 101 SOQL limit Fix
            List<QCC_Email_Thread_Domain__mdt> emailThreadDomains = QCC_Email_Thread_Domain__mdt.getAll().Values();
            
            for (QCC_Email_Thread_Domain__mdt emailThreadDomain: emailThreadDomains)
            {
                if (emailMsg.stripHtmlTags().indexOf(emailThreadDomain.Mail_Thread_Starting_String__c) != -1)
                {
                    emailMsg = emailMsg.substring(0, emailMsg.stripHtmlTags().indexOf(emailThreadDomain.Mail_Thread_Starting_String__c));
                    break;
                }
            }
            if (String.isBlank(emailMsg))
            {
                emailMsg = System.Label.QCC_Case_Des_For_Empty_Email_Msg_Body;
            }
            response.add(emailMsg);
            System.debug('segregateEmailMsgBodyAndFooter response===========> ' + response);
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler', 
            'segregateEmailMsgBodyAndFooter', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return response;
    }
        
    public static Case maskCreditCard(Case caseNewRecord, Boolean isHTML){
       
        try {
            List<String> recordTypesList = Label.QCC_MaskCardNumberForRecordTypes.split(';');
            List<String> typeList = new List<String>{
                    CustomSettingsUtilities.getConfigDataMap('Case Baggage Type'),
                    CustomSettingsUtilities.getConfigDataMap('Case Type Insurance'),
                    CustomSettingsUtilities.getConfigDataMap('Case Type Complaint'),
                    CustomSettingsUtilities.getConfigDataMap('Case Compliment Type'),
                    CustomSettingsUtilities.getConfigDataMap('Case Type Complaint'),
                    CustomSettingsUtilities.getConfigDataMap('Case Further Action Required Type'),
                    CustomSettingsUtilities.getConfigDataMap('Case Medical Patient Type'),
                    CustomSettingsUtilities.getConfigDataMap('Case Medical Assistance Type'),
                    CustomSettingsUtilities.getConfigDataMap('On the Spot Recovery'),
                    CustomSettingsUtilities.getConfigDataMap('Case Query Type')
                };
            String description = caseNewRecord.Description;
            description = isHTML ? description.replaceAll('\\<.*?\\>', ' ') : description;
            description = isHTML ? description.replace('&nbsp;',' ') : description;
            
            description = description.replace('\n',' ');
            description = description.replace(';',' ');
            description = description.replace('\r','');
            description = description.trim(); 

            //GRAPHITE-909 Mask card details if  recordtype is Assistance
            if (description != NULL && 
                ((caseNewRecord.Origin != CustomSettingsUtilities.getConfigDataMap('Case Origin Auto Email') &&  typeList.contains(caseNewRecord.Type)) || 
                 (caseNewRecord.RecordTypeId != NULL && recordTypesList.contains(Schema.sObjectType.Case.getRecordTypeInfosById().get(caseNewRecord.RecordTypeId).getName()))
                )) {
                Map<String, String> maskedStringMap = new Map<String, String>();
                    if (String.isNotBlank(caseNewRecord.Description)) {
                        maskedStringMap = QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(description);
                    }
                for (String maskedString : maskedStringMap.keySet()) {
                    description = description.replace(maskedString, maskedStringMap.get(maskedString));
                    caseNewRecord.HasCreditCard__c = true;
                } 
                if (caseNewRecord.HasCreditCard__c) {
                    caseNewRecord.Description = description;
                }
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler', 
                'maskCreditCard', String.valueOf(''), String.valueOf(''), false, caseNewRecord.id != null ? caseNewRecord.id: '', ex);
        }
        return caseNewRecord;
    }

    
    /*----------------------------------------------------------------------------------------------
    Method Name:        updateCaseCalculatedFields
    Description:        Updates Escalated To field if the case's Escalated checkbox is ticked
    Parameter:          Case
    ----------------------------------------------------------------------------------------------*/
    public static Case updateCaseCalculatedFields(Case objCase) {
        try {
            System.debug('Damage_Sustained__c ' + objCase.Damage_Sustained__c);
            if(String.isNotBlank(objCase.Damage_Sustained__c)) {
                objCase.Repair_Cost_Numeric__c = 0;
                List<String> valuesSelected = objCase.Damage_Sustained__c.split(';');
                for(String val : valuesSelected) {
                    String key = 'QCost-'+val;
                    if(!key.contains(COMMA_CHECK) && key.length() < 36){
                        if(CustomSettingsUtilities.getConfigDataMap(key) != null && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(key))){
                            objCase.Repair_Cost_Numeric__c += Integer.valueOf(CustomSettingsUtilities.getConfigDataMap(key));
                        }
                    }
                   
                }
                objCase.Repair_Cost_Numeric__c += 28;
            }else{
                objCase.Repair_Cost_Numeric__c = 0;
            }
            if(objCase.Replacement_Bag_Cost__c < objCase.Repair_Cost_numeric__c && objCase.Replacement_Bag_Cost__c < objCase.Settlement_Value__c && objCase.Repair_Cost_numeric__c >= 80) {
                objCase.Offer_Replacement_Bag__c = true;
            } else {
                objCase.Offer_Replacement_Bag__c = false;
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler',
            'updateCaseCalculatedFields', String.valueOf(''), String.valueOf(''), false, objCase.Id !=null ? objCase.Id : '', ex);
        }
        return objCase;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        extractReferenceNumber
    Description:        Method to extract Reference Number from Case Description
    Parameter:          String caseDescription
    --------------------------------------------------------------------------------------*/
    public static String extractReferenceNumber(String caseDescription){
        String referenceNumber;
        if (String.isBlank(caseDescription)) return null;
        try {
            //capture FH and any consecutive number after `Ref#` e.g(FH123456)
            String regex = 'Ref#(FH\\d+)';
            Pattern pat = Pattern.compile(regex);
            Matcher matcher = pat.matcher(caseDescription);
            Boolean matches = matcher.find();
            
            //check if pattern match in case description
            if(matches){
                referenceNumber = matcher.group(1);
            }else{
                referenceNumber = null;
            }
           
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler', 
            'extractReferenceNumber', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return referenceNumber;
        
    }
    
    /*--------------------------------------------------------------------------------------
    Method Name:        fetchCurrentUserInfo
    Description:        Method to extract current user information
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static User fetchCurrentUserInfo() {
        User usr;
        try {
             
            return [SELECT id, FirstName, LastName, Email, GSA_User__c  from user where id =: UserInfo.getUserId() LIMIT 1];
            
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler', 
            'fetchCurrentUserInfo', String.valueOf(''), String.valueOf(''), false, '', ex);
            return null;
        }
    }

/*--------------------------------------------------------------------------------------
    Method Name:        assignVIPCaseUsingAssignmentRule
    Description:        GRAPHITE-927: Method to assign a case via the active Assignment Rule. 
                                        This is only applicable for VIP scenario.
                                            This will be on "after" events:
                                            - New cases inserted
                                            - Cases manually updated by user and where the "Assign Using Active Assignment Rule" flag is checked (applicable for post travel)
    Parameter:          List of New Case Records
--------------------------------------------------------------------------------------*/
    public static void assignVIPCaseUsingAssignmentRule(List<Case> caseRecords) {
        try {
            Database.DMLOptions dmlOption = new Database.DMLOptions();
            List<Case> casesToUpdate = new List<Case>();
            String commentsWithoutFlag;
            Case tempCaseRecord;
            if (CASE_ASSGNRULEID != null) {
                dmlOption.AssignmentRuleHeader.AssignmentRuleId = CASE_ASSGNRULEID;
                for (Case caseRecord : caseRecords) {
                    tempCaseRecord = new Case(Id=caseRecord.Id, Comments__c=caseRecord.Comments__c);
                    commentsWithoutFlag = tempCaseRecord.Comments__c.remove(CASE_ASSIGNMENTFLAG);
                    tempCaseRecord.Comments__c = commentsWithoutFlag;
                    tempCaseRecord.setOptions(dmlOption);
                    casesToUpdate.add(tempCaseRecord);
                }
            }
            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'ALL', 'CaseTriggerHandler', 'assignVIPCaseUsingAssignmentRule', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    
    public static Map<String, FlowInterview> queryFlowInterviews(Set<String> flowLabels) {
        Map<String, FlowInterview> flowInterviewMap = new Map<String, FlowInterview>();
        if (flowLabels == null || flowLabels.isEmpty()) {
            return flowInterviewMap;
        }
        for (FlowInterview fIRecord : [ SELECT Id, Name, InterviewLabel FROM FlowInterview WHERE InterviewLabel IN :flowLabels ])
        {
            flowInterviewMap.put(fIRecord.InterviewLabel, fIRecord);
        }
        return flowInterviewMap;
    }
    /* CRM-8725 */
    public static Map<String, Set<Id>> queryAffectedPassengers(Set<String> pnrSet) {
        Map<String, Set<Id>> pnrEventIdMap = new Map<String, Set<Id>>();
        Set<Id> flightEventIds;
        if (pnrSet == null || pnrSet.isEmpty()) {
            return pnrEventIdMap;
        }
        for (Affected_Passenger__c afRecord : [ SELECT Id, PNR__c, Event__c FROM Affected_Passenger__c WHERE PNR__c IN :pnrSet ])
        {
            if (String.isNotBlank(afRecord.PNR__c) && afRecord.Event__c != null) {
                if (pnrEventIdMap.containsKey(afRecord.PNR__c)) {
                    pnrEventIdMap.get(afRecord.PNR__c).add(afRecord.Event__c);
                } else {
                    pnrEventIdMap.put(afRecord.PNR__c, new Set<Id>{afRecord.Event__c});
                }
            }
        }
        return pnrEventIdMap;
    }
    /* CRM-8725 */
    public static Map<Id, Event__c> queryFlightEvents(Set<Id> flightEventIds) {
        if (flightEventIds == null || flightEventIds.isEmpty()) {
            return new Map<Id, Event__c>();
        }
        return new Map<Id, Event__c>([ SELECT Id, Name, Status__c FROM Event__c WHERE Id IN :flightEventIds ]);
    }
}