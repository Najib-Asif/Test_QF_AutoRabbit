/**
 * @description       : 
 * @author            : Gandla Mallikarjuna
 * @group             : 
 * @last modified on  : 02-13-2024
 * @last modified by  : Gandla Mallikarjuna
**/
public class CaseOthersTriggerHandler {
    
    private static final String CNDSRF_FI = 'Chatter_Notification_Deal_Support_Request_FlowInterview-';
    private static final String MILESTONETYPE_OWNERSHIP = CustomSettingsUtilities.getConfigDataMap('MilestoneType_OwnershipAssignment_Name');
    private static final String MILESTONETYPE_CASERESOLUTION = CustomSettingsUtilities.getConfigDataMap('MilestoneType_CaseResolution_Name');
    private static final String MILESTONETYPE_CASECLOSURE = CustomSettingsUtilities.getConfigDataMap('MilestoneType_CaseClosure_Name');
    private static final String CASE_ASSIGNED_STATUS = CustomSettingsUtilities.getConfigDataMap('Case_Assigned_Status');
    private static final String CASE_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String CASE_RESOLVED_STATUS = CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusResolved');
    private static final String CASE_REOPENED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
    private static final String EMPTY_STRING = '';
    private static final String QUEUE_DEAL_SUPPORT_REQUEST = CustomSettingsUtilities.getConfigDataMap('Queue_DealSupportRequest');
    private static final String CASE_ONHOLD_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusOnHold');
    private static final String QAC_WEBSITE = CustomSettingsUtilities.getConfigDataMap('QAC Website Origin');
    private static final Id RTID_Account_Handover = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Account_Handover').getRecordTypeId();
    private static final String ARTICLE_JOURNEY = CustomSettingsUtilities.getConfigDataMap('ArticleJourney');
    private static final String RT_KNOWLEDGEREQUEST = CustomSettingsUtilities.getConfigDataMap('RT_Knowledge_Request');
    private static final Id RTID_KNOWLEDGEREQUEST = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RT_KNOWLEDGEREQUEST).getRecordTypeId();
    private static final String STATUS_REOPENED_CASE = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
    private static Id ServiceRequestRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
    private static Id QACContactUsRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QAC_Contact_Us_Support').getRecordTypeId();
    private static Id DRARequestRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DRA Request').getRecordTypeId(); //Added as a part of CRM-8122
    private static Id RTID_DEALSUPPORTREQUEST = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Support_request').getRecordTypeId();
    private static final Id RTID_AgencyAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
    private static final Id RTID_SALESSUPPORT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SHR_QIS_Sales_Support').getRecordTypeId();
    private static list<Case_Fulfilment__c> fulfilmentRecordsToInsert = new list<Case_Fulfilment__c>();
    
    public static void onBeforeInsert(List<Case> newCases, Map<Id, Group> groupMap, List<Id> accountRelationShipList) {
        try {
            List<Case> serviceRequestCases = new List<Case>();
            Set<Id> serviceRequestAccountIds = new Set<Id>();
            Map<Id, Account_Relation__c> accountRelationShipMap = new Map<Id, Account_Relation__c>();
            if (accountRelationShipList != null && accountRelationShipList.size() > 0) {
                accountRelationShipMap = fetchAccountRelationshipRecords(accountRelationShipList);
            }
            for(Case objCase: newCases) {
                if (objCase.RecordTypeId == ServiceRequestRecTypeId && objCase.AccountId != null) {
                    serviceRequestCases.add(objCase);
                    serviceRequestAccountIds.add(objCase.AccountId);
                }
                if (objCase.RecordTypeId == DRARequestRecTypeId && (accountRelationShipMap.get(objCase.TMC__c) != null) && (accountRelationShipMap.get(objCase.TMC__c).Corporate_Touch_Point__c == null || accountRelationShipMap.get(objCase.TMC__c).TMC_Touchpoint__c == null)) {   //Added as a part of CRM-8122
                    objCase.addError('Account Relationship is missing Corporate/TMC touchpoints, Please ensure you add in your touchpoints before submitting.');              
                }
            }
            if (!serviceRequestCases.isEmpty()) {
                assignEntitlement(serviceRequestCases, serviceRequestAccountIds);
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Other', 'CaseOthersTriggerHandler', 
                'onBeforeInsert', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }

    public static void beforeUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap, Map<Id, User> userMap, Map<Id, Group> groupMap) {
        try {
            List<Case> serviceRequestCases = new List<Case>();
            Set<Id> serviceRequestAccountIds = new Set<Id>();
            Set<String> nonValidUsers = new Set<String>{ 'System Admin Updates', 'Integration User', 'Deployment User' };
            Case oldCaseRecord;
            for(Case objCase: newCases) {
                oldCaseRecord = oldCaseMap.get(objCase.Id);
                if (objCase.RecordTypeId == ServiceRequestRecTypeId) {
                    if (objCase.Status == STATUS_REOPENED_CASE && objCase.Status != oldCaseMap.get(objCase.Id).Status) {
                        objCase.Reopened_Date__c = System.now();
                    }
                    if (objCase.AccountId != null) {
                    	serviceRequestCases.add(objCase);
                        serviceRequestAccountIds.add(objCase.AccountId);
                    }
                } else if (objCase.RecordTypeId == RTID_KNOWLEDGEREQUEST && objCase.Article_Journey__c == ARTICLE_JOURNEY) {
                    objCase.EntitlementId = Label.EntitlementId;
                    objCase.SlaStartDate = System.now();
                } else if (objCase.RecordTypeId == RTID_SALESSUPPORT) {
                    if ((objCase.Origin == 'SHR Sales Support' || objCase.Origin == 'SHR QIS Sales Support') && objCase.Status == 'Reopened'
                            && (oldCaseRecord.Status == 'On Hold' || oldCaseRecord.Status == 'Closed')) 
                    {
                        if (userMap.containsKey(oldCaseRecord.OwnerId)) {
                            objCase.QL_Previous_Case_Owner__c = userMap.get(oldCaseRecord.OwnerId).Name;
                        } else if (groupMap.containsKey(oldCaseRecord.OwnerId)) {
                            objCase.QL_Previous_Case_Owner__c = groupMap.get(oldCaseRecord.OwnerId).Name;
                        } 
                        if (nonValidUsers.contains(objCase.QL_Previous_Case_Owner__c)) {
                            objCase.QL_Previous_Case_Owner__c = EMPTY_STRING;
                        }
                    }
                }
            }
            if (!serviceRequestCases.isEmpty()) {
                assignEntitlement(serviceRequestCases, serviceRequestAccountIds);
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Other', 'CaseOthersTriggerHandler', 
                'beforeUpdate', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }

    public static void afterInsert(List<Case> newCases, Map<Id, Group> groupMap, Map<String, FlowInterview> flowInterviewMap) {
        try {
            List<Case> dealSupportRequestCases = new List<Case>();
            map<Id,Case> serviceReccaseMap = new map<Id,Case>();
            Set<String> waiverTypes = new Set<String>();
            Set<String> waiverSubTypes = new Set<String>();
            for(Case objCase: newCases) {
                if(objCase.Origin == QAC_WEBSITE && objCase.RecordTypeId == ServiceRequestRecTypeId && String.isNotBlank(objCase.Problem_Type__c)) {
                    doCaseFulfilmentCreation(objCase);
                }
                if (objCase.RecordTypeId == RTID_DEALSUPPORTREQUEST) {
                    dealSupportRequestCases.add(objCase);
                }
            }
            if(!fulfilmentRecordsToInsert.isEmpty()) {
                insert fulfilmentRecordsToInsert;
            }
            if (!dealSupportRequestCases.isEmpty()) {
                scheduleChatterNotification(dealSupportRequestCases, null, groupMap, flowInterviewMap);
            }
            
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Other', 'CaseOthersTriggerHandler', 
                'afterInsert', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }

    public static void onAfterUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap, Map<Id, Group> groupMap, Map<Id, Flight__c> flightMap, Map<Id, WorkOrder> workOrderMap, Map<Id,Affected_Passenger__c> affectedPassengerMap, Map<String, FlowInterview> flowInterviewMap) {
       		List<Case> dealSupportRequestCases = new List<Case>();
            Set<Id> serviceRequestCaseIds = new Set<Id>();
            List<Case> serviceRequestNewCases = new List<Case>();
            Map<Id, String> accountNameMap = new Map<Id, String>();
            Map<Id, Case> casesForSendFareMap = new Map<Id, Case>();
            for (Case caseRecord : newCases) {
                if (caseRecord.RecordTypeId == ServiceRequestRecTypeId) {
                    serviceRequestCaseIds.add(caseRecord.Id);
                    serviceRequestNewCases.add(caseRecord);
                }
                if (caseRecord.RecordTypeId == QACContactUsRecTypeId && caseRecord.Type == 'EOI') {
                    serviceRequestCaseIds.add(caseRecord.Id);
                }
                if (caseRecord.RecordTypeId == RTID_DEALSUPPORTREQUEST) {
                    dealSupportRequestCases.add(caseRecord);
                    if ((caseRecord.Status == CustomSettingsUtilities.getConfigDataMap('Status_AssignedDealSupportDealSheet') || caseRecord.Status == CustomSettingsUtilities.getConfigDataMap('Status_CompletePendingPRISMDealLoad')) && 
                    oldCaseMap.get(caseRecord.Id).Status == CustomSettingsUtilities.getConfigDataMap('Status_AssignedToPricingForFareFiling') && 
                    (caseRecord.Created_by_Role__c.contains(CustomSettingsUtilities.getConfigDataMap('CBR_UKEMEIA')) || caseRecord.Created_by_Role__c.contains(CustomSettingsUtilities.getConfigDataMap('CBR_AsiaSG')) || caseRecord.Created_by_Role__c.contains(CustomSettingsUtilities.getConfigDataMap('CBR_NorthAmericaNZ'))) && 
                    caseRecord.Latest_Status__c == NULL ) { 
                        casesForSendFareMap.put(caseRecord.Id, caseRecord);
                        accountNameMap.put(caseRecord.Id, caseRecord.Account.Name);
                    }
                }
            }
            if (!casesForSendFareMap.isEmpty()) {
                sendFareAttachmentFromCase(casesForSendFareMap, accountNameMap);
            }
            milestoneCompletion(serviceRequestCaseIds);
            createPaymentRecords(serviceRequestNewCases, oldCaseMap, flightMap, workOrderMap, affectedPassengerMap);
        if (!dealSupportRequestCases.isEmpty()) {
            scheduleChatterNotification(dealSupportRequestCases, oldCaseMap, groupMap, flowInterviewMap);
        }
    }
    /*----------------------------------------------------------------------------------------------      
    Method Name:        scheduleChatterNotification
    Description:        This method will schedule Chatter Post 
    Parameter:          Case Old and New Record
    ----------------------------------------------------------------------------------------------*/
    
    public static void scheduleChatterNotification(List<Case> caseRecordList, Map<Id,Case> oldCaseRecordMap, Map<Id, Group> groupMap, Map<String, FlowInterview> flowInterviewMap) {
        try {
            Case oldCaseRecord;
            FlowInterview fiRecord;
            List<FlowInterview> fiRecordsToBeDeleted = new List<FlowInterview>();
            for (Case caseRecord : caseRecordList) {
                if (oldCaseRecordMap != null) {
                    oldCaseRecord = oldCaseRecordMap.get(caseRecord.Id);
                }
                if (caseRecord.Status.containsIgnoreCase(CASE_ONHOLD_STATUS) && groupMap.get(caseRecord.OwnerId) != null && groupMap.get(caseRecord.OwnerId).DeveloperName == QUEUE_DEAL_SUPPORT_REQUEST 
                    && (oldCaseRecord == null || caseRecord.Status != oldCaseRecord.Status || caseRecord.OwnerId != oldCaseRecord.OwnerId)) {
                    Flow.Interview.Chatter_Notification_Deal_Support_Request cndsrFlow = new Flow.Interview.Chatter_Notification_Deal_Support_Request(
                        new Map<String, Object>{ 'CaseRecordId' => caseRecord.Id, 'DealSupportRequestQueueId' => caseRecord.OwnerId }
                    );
                    cndsrFlow.start();
                    fiRecord = flowInterviewMap == null ? null : flowInterviewMap.get(CNDSRF_FI+String.valueOf(caseRecord.Id));
                    if (fiRecord != null) {
                        fiRecordsToBeDeleted.add(fiRecord);
                    }
                }
            }
            if (!fiRecordsToBeDeleted.isEmpty()) {
                delete fiRecordsToBeDeleted;
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Other', 'CaseOthersTriggerHandler', 
                'scheduleChatterNotification', String.valueOf(''), String.valueOf(''), false, String.valueOf(caseRecordList), ex);
        }
       
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        doCaseFulfilmentCreation
    Description:        This method will create fulfilment Case records.
    Parameter:          Case New Record
    ----------------------------------------------------------------------------------------------*/
    public static void doCaseFulfilmentCreation(Case objCase) {
        
        Map<String,QAC_Fulfillment_Status__mdt> allFFMDTmap = new Map<String,QAC_Fulfillment_Status__mdt>();
        Map<String,list<String>> allFFName_SeqStringMap = new Map<String,list<String>>();
        String waivCombo = '', myCaseWaivCombo = '';
        try {

            for(QAC_Fulfillment_Status__mdt eachFFMDT : QAC_Fulfillment_Status__mdt.getAll().values()) {
    
                if(objCase.Problem_Type__c == eachFFMDT.Waiver_Type__c 
                            && objCase.Waiver_Sub_Type__c ==  eachFFMDT.Waiver_Sub_Type__c) {
    
                    waivCombo = eachFFMDT.Waiver_Type__c+'_'+eachFFMDT.Waiver_Sub_Type__c;
                    allFFMDTmap.put(waivCombo,eachFFMDT);
                    
                    list<String> seqString = new list<String>{eachFFMDT.Sequence_1__c,eachFFMDT.Sequence_2__c,
                                                                eachFFMDT.Sequence_3__c,eachFFMDT.Sequence_4__c,
                                                                eachFFMDT.Sequence_5__c,eachFFMDT.Sequence_6__c,
                                                                eachFFMDT.Sequence_7__c,eachFFMDT.Sequence_8__c};
                    Integer i=0;
                    while(i < seqString.size()){
                        if(seqString[i] == null)
                            seqString.remove(i);
                        else
                            i++;
                    }
                    system.debug('all seq**'+seqString);
                    allFFName_SeqStringMap.put(waivCombo,seqString);
                }                
            }
            
            if(!allFFMDTmap.isEmpty() && !allFFName_SeqStringMap.isEmpty()) {
    
                system.debug('FFMDT map'+allFFMDTmap);
                system.debug('FFMDT Sequence map'+allFFName_SeqStringMap);
                
                myCaseWaivCombo = objCase.Problem_Type__c+'_'+objCase.Waiver_Sub_Type__c;
                if(objCase.Problem_Type__c == allFFMDTmap.get(myCaseWaivCombo).Waiver_Type__c &&
                    objCase.Waiver_Sub_Type__c == allFFMDTmap.get(myCaseWaivCombo).Waiver_Sub_Type__c) {
    
                    for(String eachFFMDT_SeqString : allFFName_SeqStringMap.get(myCaseWaivCombo)){
                        Case_Fulfilment__c newFF = new Case_Fulfilment__c();
                        newFF.Fulfilment_Name__c = objCase.Problem_Type__c;
                        newFF.Category__c = eachFFMDT_SeqString;
                        newFF.Case__c = objCase.Id;
                        newFF.Status__c = allFFMDTmap.get(myCaseWaivCombo).Fulfillment_Status__c;
                        newFF.Message__c = allFFMDTmap.get(myCaseWaivCombo).Fulfillment_Message__c;
                        newFF.Timestamp__c = System.now();
                        fulfilmentRecordsToInsert.add(newFF);
                    }
                }
    
            }
        } catch(exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Other', 'CaseOthersTriggerHandler', 
                'doCaseFulfilmentCreation', String.valueOf(''), String.valueOf(''), false, objCase.Id !=null ? objCase.Id : '', ex);
        }
       
    }

/*--------------------------------------------------------------------------------------      
Method Name:        assignEntitlement
Description:        Method for creation or assignment Entitlement for Account
Parameter:          Case New List & Old Map 
--------------------------------------------------------------------------------------*/
    public static void assignEntitlement(List<Case> caseNewList, Set<Id> accountIds){
        try {
            // To Identify whether Freight Account is associated with any Entitlement or not
            // If Entitlement exist for Account, relevant entitlement will be associated with Account
            // Else respective Entitlement record created for Account
            Map<Id, Entitlement> entitlementMap = new Map<Id, Entitlement>();
            Entitlement entitlementRecord;
            for (Entitlement eachEntitlement : [ SELECT AccountId, Name FROM Entitlement WHERE AccountId IN :accountIds]) 
            {
                entitlementMap.put(eachEntitlement.AccountId, eachEntitlement);
            }
            // Querying Entitlemnet Process
            SlaProcess process = [ SELECT Name FROM SlaProcess WHERE Name = :CustomSettingsUtilities.getConfigDataMap('SLAProcess_QACE') ]; 
            List<Entitlement> entitlementsToInsert = new List<Entitlement>();
            for (Account eachAccount : [ SELECT Id, Name, BillingCountry, BillingCountryCode, RecordTypeId FROM Account WHERE Id IN :accountIds ]) 
            {
                if (eachAccount.BillingCountryCode == 'AU' && eachAccount.RecordTypeId == RTID_AgencyAccount) {
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
            }
            // Insertion of required Entitlements
            if (!entitlementsToInsert.isEmpty()) {
                insert entitlementsToInsert;
            }
            for (Entitlement record : entitlementsToInsert) {
                entitlementMap.put(record.AccountId, record);
            }
            // Assignement of ENtitlement to Case to associate required Milestone with Case
            for (Case eachCase : caseNewList) {
                // Assigning Entitlment to the Case
                if (eachCase.AccountId == null || entitlementMap.get(eachCase.AccountId)==null) {
                    continue;
                }
                eachCase.EntitlementId = entitlementMap.get(eachCase.AccountId).Id;
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Others', 'CaseOthersTriggerHandler', 'assignEntitlement', '', '', false, '', ex);
        }
    } 
    /*--------------------------------------------------------------------------------------      
    Method Name:    fetchAccountRelationshipRecords
    Description:    To retrieve Account Relation record data (CRM-8122)
    Parameter:       
    ----------------------------------------------------------------------------------------*/  
    public static MAP<Id, Account_Relation__c> fetchAccountRelationshipRecords(List<Id> accountRelationShipList) { 

        return new Map<ID, Account_Relation__c>([SELECT Id, Corporate_Touch_Point__c, TMC_Touchpoint__c  from Account_Relation__c where Id =: accountRelationShipList]);

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
            for (CaseMilestone cmRecord : [ SELECT Case.Status, MilestoneType.Name, CompletionDate FROM CaseMilestone WHERE MilestoneType.Name IN :milestoneTypes AND CaseId IN :caseIds ])
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
                update caseMilestonesToUpdate;
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Others', 'CaseOthersTriggerHandler', 'milestoneCompletion', '', '', false, String.valueOf(caseIds), ex);
        }
    }

    /**********************************************************************************************************************************
     * Description     : To Create QAC Payment records when the Paid Service is enabled
     * JIRA            : CRM-4162
     * *******************************************************************************************************************************/
    public static void createPaymentRecords(List<Case> newCases, Map<Id, Case> oldCaseMap, Map<Id, Flight__c> flightMap, Map<Id, WorkOrder> workOrderMap, Map<Id,Affected_Passenger__c> affectedPassengerMap) {
        
            Set<Id> affectedPassengerCaseSet = new Set<Id>();
            Set<Id> flightCaseSet = new Set<Id>();
            Set<Id> workOrderCaseSet = new Set<Id>();
            Case oldCaseRecord;
            Boolean myPaxSeq;
            if (affectedPassengerMap != null) {
                for (Affected_Passenger__c afRecord : affectedPassengerMap.values()) {
                    affectedPassengerCaseSet.add(afRecord.Case__c);
                }
            }
            if (flightMap != null) {
                for (Flight__c flightRecord : flightMap.values()) {
                    flightCaseSet.add(flightRecord.Case__c);
                }
            }
            if (workOrderMap != null) {
                for (WorkOrder workOrderRecord : workOrderMap.values()) {
                    if (workOrderRecord.WorkOrderLineItems != null) {
                        workOrderCaseSet.add(workOrderRecord.CaseId);
                    }
                }
            }
            for(Case caseRecord : newCases){
                myPaxSeq = affectedPassengerCaseSet.contains(caseRecord.Id);
                oldCaseRecord = oldCaseMap.get(caseRecord.Id);
                if (caseRecord.Service_Fee_Applies__c == 'Yes - Apply' && caseRecord.QAC_Request_Country__c == 'AU') {
                    if (caseRecord.Problem_Type__c != null && myPaxSeq 
                            && (caseRecord.Service_Fee_Applies__c != oldCaseRecord.Service_Fee_Applies__c || caseRecord.QAC_Request_Country__c != oldCaseRecord.QAC_Request_Country__c)
                            && !workOrderCaseSet.contains(caseRecord.Id))
                    {
                        QAC_PaymentsProcess.doPaymentsCreation(caseRecord.Problem_Type__c+'_'+caseRecord.Waiver_Sub_Type__c, caseRecord.CreatedDate, caseRecord, myPaxSeq);
                    }
                    if (caseRecord.IsClosed && (caseRecord.IsClosed != oldCaseRecord.IsClosed) 
                            && (!myPaxSeq || !flightCaseSet.contains(caseRecord.Id))) 
                    {
                        caseRecord.addError(Label.QAC_Service_Request_without_Flights_and_Passengers);
                    }
                }
            }
        
    }
/*----------------------------------------------------------------------------------------------------------------------
    Method Name:  sendFareAttachmentFromCase
    Jira:         CRM-3506
    Description:  Send Fare attachment (excel) from Salesforce Case to external address
    Test Class:   TestSendFareattachmentfromcase
************************************************************************************************************************/
    public static void sendFareAttachmentFromCase(Map<Id, Case> caseMap, Map<Id, String> accountNameMap) {
        try {
            String documentName = '%' + Label.Fare_Filing_Audit_Email_Document_Name + '%';
            Set<Id> contentDocumentIds = new Set<Id>();
            Map<Id, Id> documentIdCaseIdMap = new Map<Id, Id>();
            ContentDocument contDocument;
            List<ContentVersion> contVersionList;
            Case caseRecord;
            List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            List<Case> caseList = new List<Case>();
            for (ContentDocumentLink cdl : [ SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :caseMap.keySet() ]) 
            {
                contentDocumentIds.add(cdl.ContentDocumentId);
                documentIdCaseIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
            if (!contentDocumentIds.isEmpty()) {
                contDocument = [ SELECT Id, CreatedDate, Title, LastModifiedDate FROM ContentDocument WHERE Id IN :contentDocumentIds AND Title LIKE :documentName ORDER BY LastModifiedDate DESC LIMIT 1 ];
                if (contDocument != NULL) {
                    contVersionList = [SELECT Id, Title, FileType, VersionData, IsLatest, ContentDocumentId FROM ContentVersion WHERE IsLatest = TRUE AND Title LIKE :documentName AND ContentDocumentId =: contDocument.Id];
                    if (contVersionList != NULL && !contVersionList.isEmpty()) {
                        contentDistributionList = [ SELECT DistributionPublicUrl, ContentDocumentId, RelatedRecordId FROM ContentDistribution WHERE ContentVersionId IN :contVersionList ];
                        if (contentDistributionList.isEmpty()) {
                            for (ContentVersion contVersion : contVersionList) {
                                contentDistributionList.add(new ContentDistribution(
                                    ContentVersionId = contVersion.Id,
                                    Name = contVersion.Title,
                                    RelatedRecordId = documentIdCaseIdMap.get(contVersion.ContentDocumentId),
                                    PreferencesAllowViewInBrowser = true,
                                    PreferencesLinkLatestVersion = true,
                                    PreferencesPasswordRequired = false,
                                    PreferencesAllowOriginalDownload = true
                                ));
                            }
                            if (Schema.sObjectType.ContentDistribution.isCreateable() && !contentDistributionList.isEmpty()) {
                                insert contentDistributionList;
                            }
                        }
                        for (ContentDistribution contentDistribution : contentDistributionList) {
                            if (contentDistribution.RelatedRecordId == documentIdCaseIdMap.get(contentDistribution.ContentDocumentId)) {
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setToAddresses(new String[]{ Label.Email_of_First_pass_auditor_ZO });
                                mail.setCcAddresses(new String[]{ Label.Email_of_Second_Pass_auditor_WNS });
                                mail.setSubject('Ticketing Instructions for '+ accountNameMap.get(caseMap.get(contentDistribution.RelatedRecordId).AccountId)); 
                                mail.setHtmlBody(
                                    'Hi,<br/><br/>.' + 
                                        '<b>**This is an automated email generated from Qantas Salesforce. Please do not reply to this email**</b> <br/><br/>' +
                                        'To access the Ticketing Instructions for ' + accountNameMap.get(caseMap.get(contentDistribution.RelatedRecordId).AccountId) + 
                                        '. Please <a href=' + contentDistribution.DistributionPublicUrl + '>click here.</a> <br/><br/>' +
                                    'Thanks<br/>' + 'Qantas Salesforce Support'
                                );
                                mailList.add(mail);
                            }
                        }
                        if (!mailList.isEmpty()) {
                            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(mailList, false);
                            for (Messaging.SendEmailResult result : emailResults) {
                                if (result.isSuccess()) {
                                    //caseList.add(new Case( Id=caseMap.get(contentDistribution.RelatedRecordId).Id,  Latest_Status__c=System.now()));
                                }
                            }
                            if (Schema.sObjectType.Case.fields.Latest_Status__c.isUpdateable() && !caseList.isEmpty()) {
                                update caseList;
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'OTHERS', 'CaseOthersTriggerHandler', 'sendFareAttachmentFromCase', '', '', false, '', ex);
        }
    }
}