/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 25-11-2024
 * @last modified by  : Praveen Sampath
 * Test class: CaseQCCTriggerHandlerTest
**/
public class CaseQCCTriggerHandler {
    private static final Id RTIDVOICE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('CCC_Voice_RecordTypeDevName')).getRecordTypeId();
    private static final String RT_SPECIFICNEEDS = CustomSettingsUtilities.getConfigDataMap('RT_QCC_Specific_Needs');
    private static final String RT_ELITEPORCESS = CustomSettingsUtilities.getConfigDataMap('RT_QCC_Elite_Process');
    private static final String STATUS_WAITINGFORCUSTOMER = CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Customer');
    private static final String STATUS_WAITINGFORINTERNAL = CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Internal');
    private static final String WAITINGFORCUSTOMER_SNQUEUE = CustomSettingsUtilities.getConfigDataMap('Queue_SN_WaitingForCustomer');
    private static final String WAITINGFORINTERNAL_SQQUEUE = CustomSettingsUtilities.getConfigDataMap('Queue_SN_WaitingForInternal');
    private static final String WAITINGFORCUSTOMER_VIPQUEUE = CustomSettingsUtilities.getConfigDataMap('Queue_VIP_WaitingForCustomer');
    private static final String WAITINGFORINTERNAL_VIPQUEUE = CustomSettingsUtilities.getConfigDataMap('Queue_VIP_WaitingForInternal');
    private static final String WAITINGFORCUSTOMER_QUEUE = CustomSettingsUtilities.getConfigDataMap('Queue_WaitingForCustomer');
    private static final String WAITINGFORINTERNAL_QUEUE = CustomSettingsUtilities.getConfigDataMap('Queue_WaitingForInternal');
    private static final String CASE_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String CASE_REOPENED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
    private static final String CASE_CRITICAL_PRIORITY = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
    private static final String CASE_HIGH_PRIORITY = CustomSettingsUtilities.getConfigDataMap('CasePriorityHigh');
    private static final String CASE_MEDIUM_PRIORITY = CustomSettingsUtilities.getConfigDataMap('Case Priority Medium');
    private static final String CASE_LOW_PRIORITY = CustomSettingsUtilities.getConfigDataMap('Priority_Low');
    private static final String CASE_QANTAS_ORIGIN = CustomSettingsUtilities.getConfigDataMap('QCC Qantas');
    private static final String CASE_REDAPP_ORIGIN = CustomSettingsUtilities.getConfigDataMap('QCC_Red App');
    private static final string CASE_BluePrism_Origin = CustomSettingsUtilities.getConfigDataMap('QCC_BluePrism');
    private static final String EXCEPTION_QUEUE_NAME = CustomSettingsUtilities.getConfigDataMap('Exception_Queue_API_NAME');
    private static final String VIPREPLY_QUEUE_NAME = CustomSettingsUtilities.getConfigDataMap('VIP_Reply_Received_Queue_API_NAME');
    private static final String INSURANCE_LETTER_TYPE_CASE = CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type');
    private static final String QCC_SENSITIVE_CASE = CustomSettingsUtilities.getConfigDataMap('QCC SENSITIVE CASE');
    private static final String RT_INSURANCELETTER = CustomSettingsUtilities.getConfigDataMap('RT_CCCInsuranceLetterCase');
    private static final String CASE_INSURANCE_QUEUE = CustomSettingsUtilities.getConfigDataMap('QCC Insurance Queue');
    //CRM-13830 and CRM-13876 fetching queue names for solutions and resolutions queues
    private static final String CASE_Resolutions_QUEUE = CustomSettingsUtilities.getConfigDataMap('QCC Resolutions Queue');
    private static final String CASE_Solutions_QUEUE = CustomSettingsUtilities.getConfigDataMap('QCC Solutions Queue');
    public static final	String DEFAULT_QUEUE_SUFFIX = 'Low';

    //public static Boolean assignmentRuleInvoked = false;
    public static Id QCC_EliteProcessRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Elite Process RecType'));
    public static Id QCC_ComplaintsRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType'));
    public static Id QCC_ComplimentsRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Compliment RecType'));
    public static Id QCC_EventRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType'));
    public static Id QCC_FARRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Further Action RecType'));
    public static Id QCC_AssistanceRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Assistance RecType'));
    public static Id QCC_InsuranceRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType'));
    public static Id QCC_QueryRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Query RecType'));
    public static Id recTypeCCCBaggage = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
    public static Id QCC_BouncedBackRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Bounced Back RecType'));
    public static Id QCC_SpecificNeedsRTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Specific Needs RecType'));
    public static Id QCC_OTSRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case OTRS RecType'));
    public static Id QCC_OffloadRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Offload RecType'));
    public static Id QCC_DisruptionRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Disruption RecType'));
    // ASO --Start
    public static final String CASE_COMPLAINT_TYPE = CustomSettingsUtilities.getConfigDataMap('Case Type Complaint');
    public static final String CASE_BAGGAGE_TYPE = CustomSettingsUtilities.getConfigDataMap('Case Baggage Type');
    public static final String CASE_DAMAGEDBAGGAGE_GROUP = CustomSettingsUtilities.getConfigDataMap('QCC_DamagedBaggageGroup');
    public static final String CASE_MOBILITYAIDS_CATEGORY = CustomSettingsUtilities.getConfigDataMap('QCC_Mobility_Aids_Category');
    public static Id QCC_MedicalTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType'));
    public static Id QCC_RefundRecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Refund RecType'));
    // ASO --End
           
    public static String BlankTemplate = CustomSettingsUtilities.getConfigDataMap('CaseBlankTemplate');
    public static String QueryType = CustomSettingsUtilities.getConfigDataMap('CaseQueryTemplate');

    public static Map<String, String> getCongaEmailTemplateId = CustomSettingsUtilities.getCongaEmailTemplateId();
    public static Map<String, String> mapComplaintTemplates = new Map<String, String>();
    public static Map<String, APXTConga4__Conga_Email_Template__c> mapCongaTemplates1 = new Map<String, APXTConga4__Conga_Email_Template__c>();
    public static Map<String, APXTConga4__Conga_Template__c> mapCongaTemplates2 = new Map<String, APXTConga4__Conga_Template__c>();

    public static Map<String, QCC_EmergencyExpense__mdt> mapQCCEmergency = new Map<String, QCC_EmergencyExpense__mdt>();

    public static Map<String, QCC_Case_SLA__mdt> mapQCCCaseSLA = new Map<String, QCC_Case_SLA__mdt>();
    public static Map<String, BusinessHours> mapBusHrs = new Map<String, BusinessHours>();
    
    //Jira:CRM-8706
    //public static Set<Id> setQCCRectype = CaseTriggerHelper.qccCaseRecordTypeIds();
    public static Set<Id> setQCCRectype = CaseUtility.qccCaseRecordTypeIds();
    public static Boolean isDesHasHotword = false;
    public static List<QCC_Hotword_Queue_Routing__c> qccHotwordQueueRouting = [ SELECT Id, Name, Hot_words__c, Priority__c, Queue_Name__c, CCC_R1_CCAT_Type__c FROM QCC_Hotword_Queue_Routing__c WHERE RecordType.DeveloperName='Customer_Connect' ];
        
    public static Map<String, Id> mapQueue;// = new Map<String, Id>();
    public static Map<Id, String> mapQueueName;// = new Map<Id, String>();
    public static Map<String, String> mapHotWordQueue;// = new Map<Id, String>();
    public static Map<String, QCC_HotWord__mdt> devNameToHotWordMap;
    public static Map<String, String> mapCaseLastQueue = new Map<String, String>();
    public static List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
    public static Map<Id, Boolean> assignmentRuleInvokedMap = new Map<Id, Boolean>();
    
    // Added by Suresh as part of CRM-10622
    public static final String CASE_GROUP_CONTACT_CENTER = 'Contact Centre'; 
    public static final String CASE_CATEGORY_MUSICAL_INSTUMENT = 'Musical Instrument'; 
    public static final String CASE_CATEGORY_EMIRATES = 'Emirates'; 
    public static final String CASE_CATEGORY_PARTNER_AIRLINES = 'Partner Airlines'; 
    public static final String CASE_CHANNEL_TYPE_WNS = 'WNS BackOffice';
    public static final String CASE_CHANNEL_TYPE_AKL = 'AKL BackOffice';
    public static String QCC_CASE_TYPE = CustomSettingsUtilities.getConfigDataMap('Case Query Type');

    // Added by Bharath Inti as part of CRM-10999
    public static final String CASE_CHANNEL_TYPE_SHM = 'SHR Musical';
    public static final String CASE_CHANNEL_TYPE_SHJ = 'SHR Jpn';
    public static final String CASE_CHANNEL_TYPE_SHK = 'SHR Kor';
    public static final String CASE_CHANNEL_TYPE_SHO = 'SHR OW';
    public static final String CASE_CHANNEL_TYPE_SHE = 'SHR EK';
    
    // Added by Bharath Inti part of CRM-10624
    public static final String CASE_CATEGORY_FINANCE = 'Finance';
    public static final String CASE_CHANNEL_TYPE_SHRQET = 'SHR QET';
    public static final String CASE_CHANNEl_TYPE_SHRCUSTQ = 'SHR CustQ';
    public static final String CASE_CHANNEL_TYPE_SHRINSIGHT = 'SHR Insight';
    public static final String CASE_CHANNEL_TYPE_SHRCSCC = 'SHR CSCC';
    public static final String CASE_GROUP_SERVICE_DELIVERY = 'Service Delivery';

    public CaseQCCTriggerHandler() {
        //this.newCaseMap = (Map<Id, Case>) Trigger.newMap;
        //this.oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
        //this.newCaseList = (List<Case>) Trigger.new;
        //this.oldCaseList = (List<Case>) Trigger.old;
    }

    public static void onBeforeInsert(List<Case> newCases, Map<String, Id> recordTypeMap, List<Id> contactIds, List<String> referenceNumberList) {
        
      
            fetchCongaEmailTemplateGeneric();
            calculateEmergencyExpenseGeneric();
            updateCaseSLAGeneric();
            
            Map<String,List<sObject>> metaObjectsByModuleName = fetchMetaObjectsByModuleName(Label.QCC_casesRecordTypesForEmailToCaseAndAPI + ' - ' +
                                                                         Label.QCC_CaseTypesContactWatchlistCheck + ' - Watchlist');
               
            Map<String, qcc_first_host__c> qccFirstHostRecMap = fetchQCCFirstHostRecords(referenceNumberList);
    
            Map<String, QCC_Contact_Watchlist__c> watchlistMap = fetchContactWatchListRescord(contactIds);
            Map<String, Id> mapQCCEntitlement = fetchQCCEntitlementRecords();
            Map<Id, Contact> contactRecordsMap = new Map<Id, Contact>([ SELECT Frequent_Flyer_Tier__c, SSU__c, QCC_Effective_Tier__c FROM Contact WHERE Id IN :contactIds ]);
            List<QCC_HotWord__mdt> hotWordList = [ SELECT DeveloperName, Hot_Word__c, Order__c, CCC_R1_CCAT_Type__c FROM QCC_HotWord__mdt ORDER BY Order__c ];
            // ASO -- Start
            Map<String, QCCRoutingTable__mdt> mapQCCRouting = new Map<String, QCCRoutingTable__mdt>();
            Map<String, QCCRoutingPriority__mdt> mapQCCPriority = new Map<String, QCCRoutingPriority__mdt>();
        	Map<String, QCCVIPPriorityUpdateWrapper> vipPriorityMap = new Map<String, QCCVIPPriorityUpdateWrapper>();
            Map<String, BusinessHours> mapBusHrs = new Map<String, BusinessHours>();
            Map<String, String> mapExcludePriority = new Map<String, String>();
            Boolean isReopen = false;
            String temp;

            //CRM-7348 101 SOQL limit Fix
            for(QCCRoutingTable__mdt qccRouting: QCCRoutingTable__mdt.getAll().values()) {
                //temp = qccRouting.CaseType__c + qccRouting.Group__c + (qccRouting.Category__c=='none' ? '' : qccRouting.Category__c) + (qccRouting.Sub_Category__c=='none' ? '' : qccRouting.Sub_Category__c);
                temp = qccRouting.CaseType__c + qccRouting.Group__c + (qccRouting.Category__c.equals('none') ? '' : qccRouting.Category__c) + (qccRouting.Sub_Category__c.equals('none') ? '' : qccRouting.Sub_Category__c);
                mapQCCRouting.put(temp, qccRouting);
            }
            for(QCCRoutingPriority__mdt qccPriority: QCCRoutingPriority__mdt.getAll().values()) {
                temp = qccPriority.Cabin__c + '#' + qccPriority.Tier__c;
                mapQCCPriority.put(temp, qccPriority);
            }
        
            for (QCC_VIPCases_Priority__mdt mdt : QCC_VIPCases_Priority__mdt.getAll().values()) {
            String uniqueKey = mdt.Case_RecordType__c + '_' + mdt.Case_Type__c;
            vipPriorityMap.put(uniqueKey, new QCCVIPPriorityUpdateWrapper(
            mdt.Case_RecordType__c,
            mdt.Case_Type__c,
            mdt.Priority__c
            ));
}
        
            for(QantasConfigData__c qcd : [ SELECT Id, Name, Config_Value__c FROM QantasConfigData__c WHERE Name LIKE 'Exclude Priority%' ]) 
            {
                if(qcd.Name.contains('Exclude Priority'))
                {
                    mapExcludePriority.put(qcd.Name, qcd.Config_Value__c);
                }
                    
            }
            // ASO -- End
    
            for(Case objCase: newCases) {
    
                if (objCase.Description != null) {
                    String referenceNumber = CaseTriggerHandler.extractReferenceNumber(objCase.Description);
                    if (qccFirstHostRecMap.containskey(referenceNumber)) {
                        objCase = updateHostNumber(objCase, qccFirstHostRecMap.get(referenceNumber)); // Shall we trigger only on before update Praveen?
                    }
                }

                //QCC_Elite_Process Case
                if (objCase.RecordTypeId.equals(recordTypeMap.get(RT_ELITEPORCESS)) &&
                                watchlistMap.get(objCase.ContactId) != null && 
                                watchlistMap.get(objCase.ContactId).QCC_Contact__c == objCase.contactId && 
                                Label.QCC_CaseTypesContactWatchlistCheck.split(';').contains(objCase.type)) {

                                    objCase = updateFields(objCase, watchlistMap.get(objCase.ContactId), metaObjectsByModuleName);
                    
                }


                if(String.isNotBlank(objCase.Group__c) &&  objCase.Group__c == 'SPECIFIC-NEEDS'){
                    specificNeedsChange(objCase, QCC_SpecificNeedsRTypeId);
                }

                objCase = assginCaseFields(objCase, recordTypeMap);
                                 
                objCase = assignEntitlementToCase(objCase, mapQCCEntitlement, recordTypeMap);
                
                if ((setQCCRectype.contains(objCase.RecordtypeId) || objCase.RecordTypeId == QCC_OTSRecordTypeId) &&
                        (objCase.Origin == CASE_REDAPP_ORIGIN || objCase.Origin == CASE_QANTAS_ORIGIN)) {
                    objCase = populateBasicAutoCaseValues(objCase);
                }
                //fetchCongaEmailTemplateId
                if(objCase.Type != null || objCase.Group__c != null || objCase.Refund_Type__c != null) {
                    string congaEmailTemplateId = getCongaEmailTemplateId.get(objCase.RecordTypeId+':'+objCase.Type+':'+objCase.Email_Template__c);
                    fetchCongaEmailTemplateId(objCase, mapComplaintTemplates, mapCongaTemplates1, mapCongaTemplates2, congaEmailTemplateId);
                }
                //update Priority for cases
                objCase= updateVIPCasePriority(recordTypeMap,objCase,vipPriorityMap);
                
                // assignCaseOwner
                objCase = assignCaseOwner(recordTypeMap, null, objCase, (objCase.ContactId==NULL ? NULL : contactRecordsMap.get(objCase.ContactId)), hotWordList, mapQCCRouting, mapQCCPriority, mapExcludePriority);
                
                objCase = assignQCCFields(objCase); // Added by Suresh as part of CRM-10622
                
                //updateCaseSLA
    
                updateCaseSLA(objCase, null, false, mapQueueName);
            
                //calculateEmergencyExpense
                Boolean isValid = false;
                if(objCase.RecordTypeId == recTypeCCCBaggage) {
                    if(objCase.Customer_Not_In_Home_Port__c) {
                        isValid = true;
                    }
                    calculateEmergencyExpense(objCase, null, isValid);
                }
    
                //update tech fields
                if(setQCCRectype.contains(objCase.RecordtypeId)) {
                    objCase = updateTECHFields(objCase);
                }

                objCase = updateDepartureDateField(objCase, NULL);
            }
        
    }
    
    //update logic
    public static void onBeforeUpdate(Map<Id, Case> newCaseMap, Map<Id, Case> mapOldMap, Map<String, Id> recordTypeMap, Map<Id, Case> caseQueueMap, 
                                        List<String> referenceNumberList, List<Id> parentCaseIds, Set<Id> contactIds, Map<Id, User> userMap) {
       
            Set<Id> cCATUserIds = CaseUtility.getCCATUserIds(userMap);
            Set<Id> resolutionConsultantIds = CaseUtility.getResolutionConsultantIds(userMap);                                 
            Case oldCase;
            Contact contactRecord;                                    
            Boolean isParentIdFieldChanged;
            fetchCongaEmailTemplateGeneric();
            calculateEmergencyExpenseGeneric();
            updateCaseSLAGeneric();
            fetchQueueNames(caseQueueMap);
            Map<Id, String> mapParentCaseValidationError = fetchValidateParentCaseRecords(newCaseMap.keySet(), parentCaseIds);                                   
            Map<String, qcc_first_host__c> qccFirstHostRecMap = fetchQCCFirstHostRecords(referenceNumberList);
            
            // assignCaseOwner -- Start
            Map<String, QCCRoutingTable__mdt> mapQCCRouting = new Map<String, QCCRoutingTable__mdt>();
            Map<String, QCCRoutingPriority__mdt> mapQCCPriority = new Map<String, QCCRoutingPriority__mdt>();
            Map<String, QCCVIPPriorityUpdateWrapper> vipPriorityMap = new Map<String, QCCVIPPriorityUpdateWrapper>();
            Map<String, BusinessHours> mapBusHrs = new Map<String, BusinessHours>();
            Map<String, String> mapExcludePriority = new Map<String, String>();
            Map<Id, Contact> contactRecordsMap = new Map<Id, Contact>([ SELECT Frequent_Flyer_Tier__c, SSU__c, QCC_Effective_Tier__c FROM Contact WHERE Id IN :contactIds ]);
            List<QCC_HotWord__mdt> hotWordList = [ SELECT DeveloperName, Hot_Word__c, Order__c, CCC_R1_CCAT_Type__c FROM QCC_HotWord__mdt ORDER BY Order__c ];
            Boolean isReopen = false;
            String temp;
            //CRM-7348 101 SOQL limit Fix
            for(QCCRoutingTable__mdt qccRouting: QCCRoutingTable__mdt.getAll().values()) {
                //temp = qccRouting.CaseType__c + qccRouting.Group__c + (qccRouting.Category__c=='none' ? '' : qccRouting.Category__c) + (qccRouting.Sub_Category__c=='none' ? '' : qccRouting.Sub_Category__c);
                temp = qccRouting.CaseType__c + qccRouting.Group__c + (qccRouting.Category__c.equals('none') ? '' : qccRouting.Category__c) + (qccRouting.Sub_Category__c.equals('none') ? '' : qccRouting.Sub_Category__c);
                mapQCCRouting.put(temp, qccRouting);
            }
            for(QCCRoutingPriority__mdt qccPriority: QCCRoutingPriority__mdt.getAll().values()) {
                temp = qccPriority.Cabin__c + '#' + qccPriority.Tier__c;
                mapQCCPriority.put(temp, qccPriority);
            }
                                            
            for (QCC_VIPCases_Priority__mdt mdt : QCC_VIPCases_Priority__mdt.getAll().values()) {
            String uniqueKey = mdt.Case_RecordType__c + '_' + mdt.Case_Type__c;
            vipPriorityMap.put(uniqueKey, new QCCVIPPriorityUpdateWrapper(
            mdt.Case_RecordType__c,
            mdt.Case_Type__c,
            mdt.Priority__c
            ));
            }
                                            
            for(QantasConfigData__c qcd : [ SELECT Id, Name, Config_Value__c FROM QantasConfigData__c WHERE Name LIKE 'Exclude Priority%' ]) 
            {
                if(qcd.Name.contains('Exclude Priority'))
                {
                    mapExcludePriority.put(qcd.Name, qcd.Config_Value__c);
                }
                 
            }
            // assignCaseOwner -- End
    
            for(Case objCase: newCaseMap.values()) {
                contactRecord = objCase.ContactId==null ? null : contactRecordsMap.get(objCase.ContactId);
                oldCase = mapOldMap.get(objCase.Id);
                if (objCase.Sensitive__c && objCase.Description != null && objCase.Description.equals(QCC_SENSITIVE_CASE)) {
                    objCase.IsDescriptionChanged__c = false;
                } else if (objCase.Description != null && oldCase.Description != null) {
                    objCase.IsDescriptionChanged__c = !objCase.Description.stripHtmlTags().equals(oldCase.Description.stripHtmlTags());
                }
                
                if(objCase.ParentId != null && mapParentCaseValidationError.containsKey(objCase.Id)) {
                    objCase.adderror(mapParentCaseValidationError.get(objCase.Id));
                } else if(objCase.ParentId != Null && mapParentCaseValidationError.containsKey(objCase.ParentId) && 
                        objCase.Status != CASE_CLOSED_STATUS &&
                        !(mapParentCaseValidationError.get(objCase.ParentId).equalsIgnoreCase(System.Label.QCC_Open_Child_Case_Exist_Error_Msg)
                        && !objCase.ParentId.equals(mapOldMap.get(objCase.Id).ParentId))) {
                    objCase.adderror(mapParentCaseValidationError.get(objCase.ParentId));
                }
                
                if (objCase.Description != null) {
                    String referenceNumber = CaseTriggerHandler.extractReferenceNumber(objCase.Description);
                    if (qccFirstHostRecMap.containskey(referenceNumber)) {
                        objCase = updateHostNumber(objCase, qccFirstHostRecMap.get(referenceNumber));
                    }
                }
                //fetchCongaEmailTemplateId
                if(oldCase != null && (objCase.Type != oldCase.Type || objCase.Sub_Category__c != oldCase.Sub_Category__c || objCase.Category__c !=oldCase.Category__c || objCase.Group__c != oldCase.Group__c || 
                    objCase.Classification__c != oldCase.Classification__c || objCase.Email_Template__c != oldCase.Email_Template__c)) {
                    string congaEmailTemplateId = getCongaEmailTemplateId.get(objCase.RecordTypeId+':'+objCase.Type+':'+objCase.Email_Template__c);
                    fetchCongaEmailTemplateId(objCase, mapComplaintTemplates, mapCongaTemplates1, mapCongaTemplates2, congaEmailTemplateId);    
                }
                // assignCaseOwner --> return cases
                objCase = assignCaseOwner(recordTypeMap, oldCase, objCase, contactRecord, hotWordList, mapQCCRouting, mapQCCPriority, mapExcludePriority);
                boolean isCasePreviouslyClosedorResolved = false;
                if(oldCase != Null && oldCase.Status != objCase.Status && objCase.Status != CASE_CLOSED_STATUS/* &&
                objCase.Status != CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusResolved')*Jira 4960* */ &&
                (oldCase.Status == CASE_CLOSED_STATUS /*|| oldCase.Status == CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusResolved')*//*Jira 4960*/)) {
                    isCasePreviouslyClosedorResolved = true;
                }

                if(setQCCRectype.contains(objCase.RecordtypeId) && (oldCase == Null || isCasePreviouslyClosedorResolved ||
                                                                    (objCase.RecordtypeId != oldCase.RecordtypeId) ||
                                                                    (oldCase.Status != objCase.Status && objCase.Status == CASE_REOPENED_STATUS) ||
                                                                    (oldCase.Priority != objCase.Priority && objCase.Priority == CASE_CRITICAL_PRIORITY) ||
                                                                    (oldcase.Description != objCase.Description && String.isBlank(oldcase.Description)) ||
                                                                    (oldcase.Group__c != objCase.Group__c && String.isBlank(oldcase.Group__c)) ||
                                                                    (oldcase.Type != objCase.Type) || ((oldcase.ContactId == null && objCase.ContactId != null)&&(oldcase.ContactId != objCase.ContactId))))
                {
    
                    updateCaseSLA(objCase, oldcase, isCasePreviouslyClosedorResolved, mapQueueName);
                }
                 if(setQCCRectype.contains(objCase.RecordtypeId) && (oldCase == Null || 
                                                                    (objCase.RecordtypeId != oldCase.RecordtypeId) ||
                                                                    (oldCase.Status != objCase.Status && objCase.Status == CASE_REOPENED_STATUS) ||
                                                                    (oldcase.Type != objCase.Type) || ((oldcase.ContactId == null && objCase.ContactId != null)&&(oldcase.ContactId != objCase.ContactId))))
                {

                
                                objCase= updateVIPCasePriority(recordTypeMap,objCase,vipPriorityMap);
                }
                //calculateEmergencyExpense
                if(objCase.RecordTypeId == recTypeCCCBaggage) {
                    Boolean isValid = false;
                    if(oldCase != Null) {
                        set<String> fieldSet = new Set<String>();
                        //dynamically get the fields from the field set and then use the same for comparison in the trigger.
                        for(Schema.FieldSetMember fields :Schema.SObjectType.Case.fieldSets.getMap().get('QCC_EmergencyExpense').getFields()) {
                            fieldSet.add(fields.getFieldPath());
                        }
                        
                        for(string field: fieldSet) {
                            if(objCase.get(field) != oldCase.get(field)) {
                                isValid = true;
                                break;
                            }
                        }
                    }
                    calculateEmergencyExpense(objCase, oldCase, isValid);
                }
                if(setQCCRectype.contains(objCase.RecordtypeId))  {
                    objCase = caseStatusUpdated(objCase, oldCase);
                }
                //update Tech fields
                if(setQCCRectype.contains(objCase.RecordtypeId) && (oldcase != null &&
                                    (objCase.Email_Arrival_Date_Time__c != oldcase.Email_Arrival_Date_Time__c) ||
                                    (objCase.Actual_Arrival_Date_Time__c != oldcase.Actual_Arrival_Date_Time__c) ||
                                    (objCase.Email_Departure_Date_Time__c != oldcase.Email_Departure_Date_Time__c) ||
                                    (objCase.Arrival_Date_Time__c != oldcase.Arrival_Date_Time__c) ||
                                    (objCase.Departure_Date_Time__c != oldcase.Departure_Date_Time__c)))  
                {
                    objCase = updateTECHFields(objCase);
                }
                objCase = updateDepartureDateField(objCase, oldCase);
                //GRAHITE-GRAPHITE-1980 : New way of checking if user is CCAT.
                //Check first if status was changed or not, applies only when update
                //If Not CCAT Agent, it will proceed to checking per status then reassigns the case to a queue.
                if (objCase.Status != oldCase.Status && !cCATUserIds.contains(objCase.OwnerId) && !resolutionConsultantIds.contains(objCase.OwnerId)) {
                    objCase = reassignCaseWithWaitingStatus(oldCase, objCase, recordTypeMap, contactRecord);
                }
                //if (String.valueOf(objCase.OwnerId).startsWith('005')) {//Added by Raghav for POC
                //    objCase.CCAT_User__c = cCATUserIds.contains(objCase.OwnerId) ? true : false;
                //}
                                        
            }
        
    }

    public static void afterInsert(Map<Id, Case> newCaseMap, List<Id> contactIds, List<Case> qantasAndRedAppCaseList, Map<Id, Case> qccSensitiveCaseMap, Map<String,Set<Id>> pnrEventIdMap, Map<Id, Event__c> eventMap) {

        try {
            if (qccSensitiveCaseMap != null && !qccSensitiveCaseMap.isEmpty()) {
                ID notificationJobID = System.enqueueJob(new QCC_CaseNotificationHelperQueuable(qccSensitiveCaseMap.keySet(), qantasAndRedAppCaseList, UserInfo.getSessionId()));
            } else if (qantasAndRedAppCaseList != null && qantasAndRedAppCaseList.size() > 0 ) {
                ID jobID = System.enqueueJob(new QCC_CaseCreatorV2(qantasAndRedAppCaseList, UserInfo.getSessionId()));   
            }
            createCaseFlightEvent(newCaseMap, pnrEventIdMap, eventMap); // CRM-8725
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                'afterInsert', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }

    public static void afterUpdate(Map<Id, Case> newCaseMap, Map<Id, Case> mapOldMap, List<Id> contactIds, Map<Id, Case> qccSensitiveCaseMap, Map<String,Set<Id>> pnrEventIdMap, Map<Id, Event__c> eventMap) {
        
        try {
            
            
            if (qccSensitiveCaseMap != null && !qccSensitiveCaseMap.isEmpty()) {
                ID notificationJobID = System.enqueueJob(new QCC_CaseNotificationHelperQueuable(qccSensitiveCaseMap.keySet(), null, UserInfo.getSessionId()));
            }
            createCaseFlightEvent(newCaseMap, pnrEventIdMap, eventMap); // CRM-8725
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                'afterUpdate', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
    
    //Added by Suresh as art of CRM-10622; Updated by Bharath as part of CRM-10999,CRM-10624
    public static Case assignQCCFields(Case objCase){
        
        if(CustomSettingsUtilities.getConfigDataMap('QCC Musical Baggage Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_MUSICAL_INSTUMENT,CASE_CHANNEL_TYPE_SHM,CASE_GROUP_CONTACT_CENTER);
        } 
        if(CustomSettingsUtilities.getConfigDataMap('QCC Emirates Helpdesk Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_EMIRATES,CASE_CHANNEL_TYPE_SHE,CASE_GROUP_CONTACT_CENTER);
        } 
        if(CustomSettingsUtilities.getConfigDataMap('QCC OneWorld Helpdesk Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_PARTNER_AIRLINES,CASE_CHANNEL_TYPE_SHO,CASE_GROUP_CONTACT_CENTER);
        } 
        if(CustomSettingsUtilities.getConfigDataMap('QCC Japan Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_PARTNER_AIRLINES,CASE_CHANNEL_TYPE_SHJ,CASE_GROUP_CONTACT_CENTER);
        }
        if(CustomSettingsUtilities.getConfigDataMap('QCC Korean Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_PARTNER_AIRLINES,CASE_CHANNEL_TYPE_SHK,CASE_GROUP_CONTACT_CENTER);
        }
        if(CustomSettingsUtilities.getConfigDataMap('CCC QET Supervisors Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_FINANCE,CASE_CHANNEL_TYPE_SHRQET,CASE_GROUP_CONTACT_CENTER);
        }
        if(CustomSettingsUtilities.getConfigDataMap('CCC Customer Queries Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_FINANCE,CASE_CHANNEl_TYPE_SHRCUSTQ,CASE_GROUP_CONTACT_CENTER);
        }
        if(CustomSettingsUtilities.getConfigDataMap('CCC Insights Queue').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,CASE_CATEGORY_FINANCE,CASE_CHANNEL_TYPE_SHRINSIGHT,CASE_GROUP_CONTACT_CENTER);
        }
        if(CustomSettingsUtilities.getConfigDataMap('Service Delivery').equalsIgnoreCase(objCase.OwnerName__c)){
            applyQCCDefaults(objCase,'',CASE_CHANNEL_TYPE_SHRCSCC,CASE_GROUP_SERVICE_DELIVERY);
        }
        return objCase;
    }

    private static void applyQCCDefaults(Case objCase,String category,String channelType,String caseGroup){
            objCase.Group__c = caseGroup;
            objCase.Category__c = category;
            objCase.Type = QCC_CASE_TYPE;
            objCase.Channel_Type__c = channelType; 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        assginCaseFields
    Description:        Method to assign Case type, Due data, Contact email and Id
    Parameter:          Case objCase
    --------------------------------------------------------------------------------------*/
    public static Case assginCaseFields (Case objCase, Map<String, Id> recordTypeMap) {
        try {
            if (objCase.Origin.equals(CustomSettingsUtilities.getConfigDataMap('QCCOriginVIPServiceTeam')) && objCase.OwnerName__c.equals(CustomSettingsUtilities.getConfigDataMap('QCCVIPEmailCaseOwnerDevName'))
            && String.isBlank(objCase.Qantas_Host__c)) {
        
                objCase.Type = CustomSettingsUtilities.getConfigDataMap('QCCVIPEmailCaseOwner');
                objCase.Contact_Email__c = '';
                objCase.ContactId = NULL;
                objCase.Due_Date__c = system.today().addDays(2);
            } else if (objCase.Origin.equals(CustomSettingsUtilities.getConfigDataMap('QCCSSUEmailEnquiriesCaseOrigin')) && (objCase.OwnerName__c.equals(CustomSettingsUtilities.getConfigDataMap('QCCSSUEmailEnquiriesCaseOriginDevName')))
                    && String.isBlank(objCase.Qantas_Host__c)) {
                objCase.Assign_using_active_assignment_rules__c = true;
                objCase.Contact_Email__c = '';
                objCase.ContactId = NULL;
                objCase.Type = CustomSettingsUtilities.getConfigDataMap('QCCSSUEmailEnquiriesCaseOrigin');
                objCase.Due_Date__c = system.today().addDays(2);
                
            } 
            else if (objCase.Origin.equals(CustomSettingsUtilities.getConfigDataMap('QCC Origin Specific Needs')) && objCase.RecordTypeId.equals(recordTypeMap.get(RT_SPECIFICNEEDS))){
                        if(objCase.Type== null){
                        objCase.Type = CustomSettingsUtilities.getConfigDataMap('Case QCC Specific Needs RecType');
                        objCase.Group__c = CustomSettingsUtilities.getConfigDataMap('Case QCC Specific Needs RecType');
                        objCase.Category__c = CustomSettingsUtilities.getConfigDataMap('Case QCC Specific Needs RecType');
                        objCase.Contact_Email__c = '';
                        objCase.ContactId = NULL;
                        objCase.Due_Date__c = system.today().addDays(5);
                }
            } 
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                'assginCaseFields', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return objCase;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        updateCaseSLA
    Description:        Method to Invoke updateCaseSLA from Case Trigger
    Parameter:           Case objCase, Case oldCase, boolean isCasePreviouslyClosedorResolved, Map<Id, String> mapQueueName
    --------------------------------------------------------------------------------------*/
    public static void updateCaseSLA(Case objCase, Case oldCase, boolean isCasePreviouslyClosedorResolved, Map<Id, String> mapQueueName){
        try{
            
            String priority;
            Integer numberOfDays;
            QCC_Case_SLA__mdt caseSLA;
            QCC_Case_SLA__mdt oldCaseSLA;
            if(mapQCCCaseSLA.containsKey(objCase.Type+''+objCase.Frequent_Flyer_Tier__c)) {
                caseSLA = mapQCCCaseSLA.get(objCase.Type+''+objCase.Frequent_Flyer_Tier__c);
            }else if(mapQCCCaseSLA.containsKey(objCase.Group__c+''+objCase.Frequent_Flyer_Tier__c)) {
                caseSLA = mapQCCCaseSLA.get(objCase.Group__c+''+objCase.Frequent_Flyer_Tier__c);
                if(!caseSLA.CheckWithGroup__c) {
                    caseSLA = null;
                }
                
            }
            
            if(oldCase != Null && (objCase.RecordtypeId != oldCase.RecordtypeId)) {
                if(mapQCCCaseSLA.containsKey(oldCase.Type+''+oldCase.Frequent_Flyer_Tier__c)) {
                    oldCaseSLA = mapQCCCaseSLA.get(oldCase.Type+''+oldCase.Frequent_Flyer_Tier__c);
                }else if(mapQCCCaseSLA.containsKey(oldCase.Group__c+''+oldCase.Frequent_Flyer_Tier__c)) {
                    oldCaseSLA = mapQCCCaseSLA.get(oldCase.Group__c+''+oldCase.Frequent_Flyer_Tier__c);
                    if(!oldCaseSLA.CheckWithGroup__c) {
                        oldCaseSLA = null;
                    }
                }
            }
            
            Integer oldNumberOfDays;
            String oldPriority;
            if(oldCaseSLA != Null) {
                oldNumberOfDays =  (Integer)oldCaseSLA.SLA__c;
                oldPriority = oldCaseSLA.Case_Priority__c;
                if(oldCase.Priority == CASE_CRITICAL_PRIORITY) {
                    oldNumberOfDays = (Integer)oldCaseSLA.Hot_Word_SLA__c;
                    oldPriority = oldCaseSLA.Hot_word_Priority__c;
                }
            }

            if(caseSLA != Null) {
                priority = caseSLA.Case_Priority__c;
                numberOfDays = (Integer)caseSLA.SLA__c;
                
                if(objCase.Priority == CASE_CRITICAL_PRIORITY) {
                    priority = caseSLA.Hot_word_Priority__c;
                    numberOfDays = (Integer)caseSLA.Hot_Word_SLA__c;
                }else{
                    if(objCase.description != null) {
                        caseDescriptionCheck(objCase.description);
                    }
                    if(isDesHasHotword) {
                        priority = caseSLA.Hot_word_Priority__c;
                        numberOfDays = (Integer)caseSLA.Hot_Word_SLA__c;
                        if(oldCaseSLA != Null) {
                            oldNumberOfDays = (Integer)oldCaseSLA.Hot_Word_SLA__c;
                            oldPriority = oldCaseSLA.Hot_word_Priority__c;
                        }
                    }
                }
                //SLA High Should be considered
                if(oldNumberOfDays != Null && numberOfDays>=oldNumberOfDays) {
                    priority = oldPriority;
                    numberOfDays = oldNumberOfDays;
                }
                
                String cityofOwner = String.valueOf(objCase.OwnerId).StartsWith('005') ? objCase.Owner_City__c : CustomSettingsUtilities.getConfigDataMap(mapQueueName.get(objCase.OwnerId).substring(0, mapQueueName.get(objCase.OwnerId).lastIndexOf('_')));
                String settingname = cityofOwner+' BusinessHours';
                String businessHrsName = CustomSettingsUtilities.getConfigDataMap(settingname);
                BusinessHours busHrs = mapBusHrs.get(businessHrsName);
                
                if(busHrs != null && numberOfDays != null){
                    
                    Integer diff = busHrs.MondayEndTime.hour()-busHrs.MondayStartTime.hour();
                    Integer hrs = diff<=0 ? 24+diff : diff;
                    DateTime startDate;
                    DateTime createdTime;
                    
                    //if Case is Reopened
                    if(objCase.Status == CASE_REOPENED_STATUS || isCasePreviouslyClosedorResolved) {
                        createdTime = system.now();
                        objCase.Reopened_Date__c = createdTime;
                    }else{
                        createdTime = objCase.Received_Date__c;
                    }
                    
                    //Check if Time within business houres of the location
                    if(BusinessHours.isWithin(busHrs.Id, createdTime)) {
                        startDate = createdTime;
                    }else{
                        startDate = BusinessHours.nextStartDate(busHrs.Id, createdTime).Date();
                    }
                
                    objCase.Due_Date__c = BusinessHours.add(busHrs.Id, startDate, 1000*60*60*hrs*numberOfDays).date();
                }
                
            	} 
                            
                //Default value : If no metadata found for case type, then default value of 2 days is populated for duedate
        		
            if(objCase.Due_Date__c == null){
                objCase.Due_Date__c = system.today().addDays(2);
             }
				
                
                if(objCase.Original_Due_Date__c == null && objCase.Due_Date__c != null) {
                    objCase.Original_Due_Date__c = objCase.Due_Date__c;
                }
               
            }  
               
        
        catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'updateCaseSLA', String.valueOf(''), String.valueOf(''),false, '', ex);
        }
        
    }
    
    /*--------------------------------------------------------------------------------------
    Method Name:        calculateEmergencyExpense
    Description:        Method to assign a case to case owner
    Parameter:          Case objCase, Case oldCase, Boolean isValid
    --------------------------------------------------------------------------------------*/
    public static void calculateEmergencyExpense(Case objCase, Case oldCase, Boolean isValid){
        try { 
                
            //Updating Emergency_Expense_Outcome
            if(oldCase == Null || oldCase.Customer_Not_In_Home_Port__c != objCase.Customer_Not_In_Home_Port__c
                || oldCase.Flight_Type_Code__c != objCase.Flight_Type_Code__c) {
                if(objCase.Customer_Not_In_Home_Port__c) {
                    if(objCase.Flight_Type_Code__c == CustomSettingsUtilities.getConfigDataMap('QCC_FligjtCode Domestic')) {
                        objCase.Emergency_Expense_Outcome__c = CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeDomestic');
                    }else if(objCase.Flight_Type_Code__c == CustomSettingsUtilities.getConfigDataMap('QCC_FligjtCode International')) {
                        objCase.Emergency_Expense_Outcome__c = CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeInternational');
                    }else{
                        objCase.Emergency_Expense_Outcome__c =  CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeNotEligible');
                    }
                }else{
                    objCase.Emergency_Expense_Outcome__c = CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeNotEligible');
                }
            }
            
            //Update backend field
            if(objCase.Arrival_UTC_Date_Time__c != Null) {
                Integer hours = objCase.Arrival_Delay_Time_Hours__c != Null ? Integer.valueOf(objCase.Arrival_Delay_Time_Hours__c) : 0;
                Integer minutues = objCase.Arrival_Delay_Time_Mins__c != Null ? Integer.valueOf(objCase.Arrival_Delay_Time_Mins__c) : 0;
                DateTime arrivalTime = objCase.Arrival_UTC_Date_Time__c.addHours(hours);
                arrivalTime = objCase.Arrival_UTC_Date_Time__c.addHours(minutues);
                objCase.Arrival_DateTime_Backend__c = arrivalTime;
            }
            
            //Update Bag Delayed 21 Days
            if(objCase.Located_Date__c != Null && (oldCase == Null || oldCase.Located_Date__c != objCase.Located_Date__c)) {
                objCase.Bag_Delayed_21_Days__c = false;
                Date arrivalDT = Date.valueOf(objCase.Arrival_DateTime_Backend__c);
                Integer diff = arrivalDT.daysBetween(objCase.Located_Date__c);
                if(diff>21) {
                    objCase.Bag_Delayed_21_Days__c = true;
                }
            }
            
            if(isValid) {
                QCC_EmergencyExpense__mdt objEmergencyExpenseCabin;
                QCC_EmergencyExpense__mdt objEmergencyExpenseTier;
                QCC_EmergencyExpense__mdt objEmergencyExpenseOther;
                QCC_EmergencyExpense__mdt objEmergencyExpense;
                
                Boolean stage1 = objCase.Stage_1_Reimbursed__c == Null ? false : objCase.Stage_1_Reimbursed__c;
                Boolean stage2 = objCase.Stage_2_Reimbursed__c == Null ? false : objCase.Stage_2_Reimbursed__c;
                Boolean stage3 = objCase.Stage_3_Reimbursed__c == Null ? false : objCase.Stage_3_Reimbursed__c;
                Boolean baggage = objCase.Bag_Will_Arrive_Greater_Than_24HRS_of_Ar__c == Null ? false : objCase.Bag_Will_Arrive_Greater_Than_24HRS_of_Ar__c;
                
                String key = objCase.Emergency_Expense_Outcome__c+''+objCase.Cabin_Class__c+''+baggage+''+stage1+''+stage2+''+stage3;
                String key1 = objCase.Emergency_Expense_Outcome__c+''+objCase.FF_Tier__c+''+baggage+''+stage1+''+stage2+''+stage3;
                String key2 = objCase.Emergency_Expense_Outcome__c+'Other'+baggage+''+stage1+''+stage2+''+stage3;
                                
                if(mapQCCEmergency.containsKey(key)) {
                    objEmergencyExpenseCabin = mapQCCEmergency.get(key);
                }else if(mapQCCEmergency.containsKey(key1)) {
                    objEmergencyExpenseTier = mapQCCEmergency.get(key1);
                }else if(mapQCCEmergency.containsKey(key2)) {
                    objEmergencyExpenseOther = mapQCCEmergency.get(key2);
                }
                
                if(objEmergencyExpenseCabin != Null && objEmergencyExpenseTier != Null) {
                    if(objEmergencyExpenseCabin.Emergency_Expense_24_DomInt__c > objEmergencyExpenseTier.Emergency_Expense_24_DomInt__c ) {
                        objEmergencyExpense = objEmergencyExpenseCabin;
                    }
                    else{
                        objEmergencyExpense = objEmergencyExpenseTier;
                    }
                }
                else if(objEmergencyExpenseCabin != Null) {
                    objEmergencyExpense = objEmergencyExpenseCabin;
                }
                else if(objEmergencyExpenseTier != Null) {
                    objEmergencyExpense = objEmergencyExpenseTier;
                }
                else if(objEmergencyExpenseOther != Null) {
                    objEmergencyExpense = objEmergencyExpenseOther;
                }
                if(objCase.Arrival_DateTime_Backend__c != Null && objEmergencyExpense != Null && objCase.Customer_Not_In_Home_Port__c) {
                    
                    if( objCase.Arrival_DateTime_Backend__c>system.now().addHours(-24)) {
                        objCase.Recommended_Emergency_Expense__c = objEmergencyExpense.Emergency_Expense_24_DomInt__c;
                        objCase.EmergencyExpenseStage__c = 'Stage 1';
                    }
                    else if(objCase.Arrival_DateTime_Backend__c<system.now().addHours(-24) && objCase.Arrival_DateTime_Backend__c>system.now().addHours(-48)) {
                        objCase.Recommended_Emergency_Expense__c = objEmergencyExpense.Emergency_Expense_48_DomInt__c;
                        if(objCase.Emergency_Expense_Outcome__c == CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeInternational')) {
                            objCase.EmergencyExpenseStage__c = 'Stage 2';
                        }else if(objCase.Emergency_Expense_Outcome__c == CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeDomestic')) {
                            objCase.EmergencyExpenseStage__c = 'Stage 1';
                        }
                    }
                    else if(objCase.Arrival_DateTime_Backend__c<system.now().addHours(-48)) {
                        objCase.Recommended_Emergency_Expense__c = objEmergencyExpense.Emergency_Expense_grt48_International__c;
                        if(objCase.Emergency_Expense_Outcome__c == CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeInternational')) {
                            objCase.EmergencyExpenseStage__c = 'Stage 3';
                        }else if(objCase.Emergency_Expense_Outcome__c == CustomSettingsUtilities.getConfigDataMap('QCC_EmergencyOutcomeDomestic')) {
                            objCase.EmergencyExpenseStage__c = 'Stage 2';
                        }
                    }
                }else{
                    objCase.Recommended_Emergency_Expense__c =0;
                    objCase.EmergencyExpenseStage__c = 'NA';
                    
                }
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'calculateEmergencyExpense', String.valueOf(''), String.valueOf(''),false, '', ex);
        }
    }
    /*----------------------------------------------------------------------------------------------
    Method Name:        fetchCongaEmailTemplateId
    Description:        To Fetch Conga Email Template Id based on the Criteria
    Parameter:          case newCs, Map<String, String> mapComplaintTemplates, Map<String, APXTConga4__Conga_Email_Template__c> mapCongaTemplates1, Map<String, APXTConga4__Conga_Template__c> mapCongaTemplates2, String congaEmailTemplateId 
    ----------------------------------------------------------------------------------------------*/
    public static void fetchCongaEmailTemplateId(case newCs, Map<String, String> mapComplaintTemplates, Map<String, APXTConga4__Conga_Email_Template__c> mapCongaTemplates1, Map<String, APXTConga4__Conga_Template__c> mapCongaTemplates2, String congaEmailTemplateId) {
        try {
            string mapKey = newCs.Type+':'+newCs.Group__c+':'+newCs.Category__c+':'+newCs.Sub_category__c+':'+newCs.Classification__c+':'+newCs.Email_Template__c;

            if((newCs.RecordTypeId == QCC_QueryRecordTypeId)  && newCs.Type == CustomSettingsUtilities.getConfigDataMap('Case Query Type')) {
                newCs.Conga_Email_Template_ID__c = QueryType;
            } 
            else if(newCs.RecordTypeId == QCC_InsuranceRecordTypeId  && (newCs.Type == INSURANCE_LETTER_TYPE_CASE || newCs.Type == CustomSettingsUtilities.getConfigDataMap('Case Baggage Type'))) {
                string key1 = newCs.Type+':'+newCs.Group__c+':'+newCs.Refund_Type__c;
                if(mapCongaTemplates1.containsKey(key1)) {
                    newCs.Conga_Email_Template_ID__c = mapCongaTemplates1.get(key1).Id;
                    string key2 = mapCongaTemplates1.get(key1).Email_Template_Name__c+':'+mapCongaTemplates1.get(key1).APXTConga4__Template_Group__c;
                    if(mapCongaTemplates2.containsKey(key2)) {
                        newCs.Conga_Template_ID__c = mapCongaTemplates2.get(key2).Id;
                    }
                }
            } else if(congaEmailTemplateId != null) {
                newCs.Conga_Email_Template_ID__c = congaEmailTemplateId;
            } else if(mapComplaintTemplates != null && mapComplaintTemplates.get(mapKey) != null) {
                newCs.Conga_Email_Template_ID__c = mapComplaintTemplates.get(mapKey);
            } else {
                newCs.Conga_Email_Template_ID__c = BlankTemplate;
            } 
            
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'fetchCongaEmailTemplateId', String.valueOf(''), String.valueOf(''),false,newCs.Id !=null?newCs.Id:'', ex);
        }
    }
    /*--------------------------------------------------------------------------------------
    Method Name:        calculateEmergencyExpenseGeneric
    Description:        Method to get the QCC Map values
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void calculateEmergencyExpenseGeneric() {
        try {
            Map<String, QCC_EmergencyExpense__mdt> mapQCCEmergMTD= new Map<String, QCC_EmergencyExpense__mdt>();
            mapQCCEmergMTD=QCC_EmergencyExpense__mdt.getall();
            
            for(QCC_EmergencyExpense__mdt objEmergency: mapQCCEmergMTD.values()) {
                Boolean stage1 = objEmergency.Stage_1_Reimbursed__c == Null ? false : objEmergency.Stage_1_Reimbursed__c;
                Boolean stage2 = objEmergency.Stage_2_Reimbursed__c == Null ? false : objEmergency.Stage_2_Reimbursed__c;
                Boolean stage3 = objEmergency.Stage_3_Reimbursed__c == Null ? false : objEmergency.Stage_3_Reimbursed__c;
                Boolean baggage = objEmergency.Bag_Will_Arrive_Greater_Than_24HRS_of_Ar__c == Null ? false : objEmergency.Bag_Will_Arrive_Greater_Than_24HRS_of_Ar__c;
                string key = objEmergency.Emergency_Expense_Outcome__c+''+objEmergency.Cabin_Tier__c+''+baggage+''+stage1+''+stage2+''+stage3;
                mapQCCEmergency.put(key, objEmergency);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'calculateEmergencyExpenseGeneric', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        fetchCongaEmailTemplateGeneric
    Description:        Method to get the QCC Map values
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void fetchCongaEmailTemplateGeneric() {

        try {
                List<APXTConga4__Conga_Email_Template__c> congaEmailTemplaes = [Select Id, APXTConga4__Name__c, Type__c, Group__c, Category__c, Sub_category__c,Email_Template_Name__c,
                                                                                Classification__c, AutoCloseCase__c, APXTConga4__Template_Group__c, Email_Template__c FROM
                                                                                APXTConga4__Conga_Email_Template__c];
        
                List<APXTConga4__Conga_Template__c> CongaTemplateList = [Select id, APXTConga4__Name__c, Email_Template_Name__c, APXTConga4__Template_Group__c, APXTConga4__Template_Type__c from APXTConga4__Conga_Template__c];
        
                for(APXTConga4__Conga_Email_Template__c congaEmailIds : congaEmailTemplaes) {
                    mapComplaintTemplates.put(congaEmailIds.Type__c+':'+congaEmailIds.Group__c+':'+congaEmailIds.Category__c+':'+congaEmailIds.Sub_category__c+':'+congaEmailIds.Classification__c+':'+congaEmailIds.Email_Template__c,congaEmailIds.Id);
                    mapCongaTemplates1.put(congaEmailIds.Type__c+':'+congaEmailIds.Group__c+':'+congaEmailIds.Category__c,congaEmailIds);
                }
        
                for(APXTConga4__Conga_Template__c template : CongaTemplateList) {
                    mapCongaTemplates2.put(template.Email_Template_Name__c+':'+template.APXTConga4__Template_Group__c, template);
                } 
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'fetchCongaEmailTemplateGeneric', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        updateCaseSLAGeneric
    Description:        Method to get the QCC Map values
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void updateCaseSLAGeneric() {
        try {
            caseQueueInfo();
            caseHotWords();
            for(QCC_Case_SLA__mdt slaData: [Select Id, DeveloperName, Masterlabel, CheckWithGroup__c, Case_Priority__c, Case_Type__c,
                                            Hot_Word_SLA__c, Hot_word_Priority__c, SLA__c,Tier__c from QCC_Case_SLA__mdt]) {
                String key = slaData.Case_Type__c+''+slaData.Tier__c;
                mapQCCCaseSLA.put(key, slaData);
            }
            
            for(BusinessHours businessHRS: [Select Id, Name, IsActive, MondayStartTime, MondayEndTime from BusinessHours where IsActive =: true]) {
                mapBusHrs.put(businessHRS.Name, businessHRS);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'updateCaseSLAGeneric', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        caseQueueInfo
    Description:        Method to Create a map of Queue to avoid SOQL
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void caseQueueInfo(){
        try {
            if(mapQueue == Null || mapQueueName == Null) {
                mapQueue = new Map<String, Id>();
                mapQueueName = new Map<Id, String>();
                for(QueueSobject queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where
                                            SobjectType ='Case']) {
                                                mapQueue.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
                                                mapQueueName.put(queueObj.QueueId, queueObj.Queue.DeveloperName);
                                            }
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'caseQueueInfo', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        caseHotWords
    Description:        Method to Create a map of Queue to avoid SOQL
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void caseHotWords(){
        try {
            if(mapHotWordQueue == Null ) {
                mapHotWordQueue = new Map<String, String>();
                devNameToHotWordMap = new Map<String, QCC_HotWord__mdt>();// (User Story: QSFR-23)
                for(QCC_HotWord__mdt qccHotWord: [Select DeveloperName, Hot_Word__c, Order__c,CCC_R1_CCAT_Type__c from QCC_HotWord__mdt order by Order__c]) {
                    mapHotWordQueue.put(qccHotWord.DeveloperName, qccHotWord.Hot_Word__c);
                    devNameToHotWordMap.put(qccHotWord.DeveloperName, qccHotWord);// (User Story: QSFR-23)
                    String allHotWord = mapHotWordQueue != Null && mapHotWordQueue.containsKey('All') ? mapHotWordQueue.get('All')+','+qccHotWord.Hot_Word__c : qccHotWord.Hot_Word__c;
                    mapHotWordQueue.put('All', allHotWord);
                }
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'caseHotWords', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        caseDescriptionCheck
    Description:        Method to get the hot word queue name
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void caseDescriptionCheck(String caseDescription){
        try {
            Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
            Matcher matcher = nonAlphanumeric.matcher(caseDescription);
            String description = ' '+matcher.replaceAll(' ')+' ';
            isDesHasHotword = false;
            for(String hotWordQueue: mapHotWordQueue.keyset()) {
                if(hotWordQueue != 'All') {
                    List<String> lstHotword = mapHotWordQueue.get(hotWordQueue).split(',');
                    for(String hotWord: lstHotword) {
                        String spaceHot = ' '+hotWord.trim()+' ';
                        if(description.containsIgnoreCase((spaceHot).replace('"',''))) {
                            isDesHasHotword = true;
                            break;
                        }
                    }
                    if(isDesHasHotword) {
                        break;
                    }
                }
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'caseDescriptionCheck', String.valueOf(''), String.valueOf(''),false, '', ex);
        } 
    }
    
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        assignEntitlementToCase   
    Description:        it will assign the Entitlement record to the Case 
    Parameter:          Case objCase
    ----------------------------------------------------------------------------------------------*/
    public static Case assignEntitlementToCase(Case objCase, Map<String, Id> mapQCCEntitlement, Map<String, Id> recordTypeMap) {
        String customerTier;
        String entitlementCaseTypeKey;
        try {
                String key = 'QCCCase-'+objCase.Contact.Frequent_Flyer_Tier__c;

                customerTier = CustomSettingsUtilities.getConfigDataMap('GOLD');
                if(CustomSettingsUtilities.getConfigDataMap(key) != null && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(key))) {
                        customerTier = CustomSettingsUtilities.getConfigDataMap(key);
                }
                
                if (objCase.CCC_R1_CCAT_Type__c == NULL) {
                    entitlementCaseTypeKey = getKeysByValue(recordTypeMap, objCase.RecordTypeId) + '_' + customerTier;
                } else {
                    entitlementCaseTypeKey = 'CCAT'+'_'+customerTier;
                }

                String entitlementName = CustomSettingsUtilities.getConfigDataMap(entitlementCaseTypeKey);
                if(mapQCCEntitlement.containsKey(entitlementName)) {
                    objCase.EntitlementId = mapQCCEntitlement.get(entitlementName);
                }
                
            } catch(Exception ex) {
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                'assignEntitlementToCase', String.valueOf(''), String.valueOf(''),false, objCase.Id !=null?objCase.Id:'', ex);
            }
            return objCase;
         
    }
    
    public static String getKeysByValue(Map<String, Id> recTypMap, Id value) {
        try {
            for(String key : recTypMap.keySet()) {
                if(recTypMap.get(key) == value) {          
                  return key;
                }
              }
            } catch (Exception ex) {
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                'getKeysByValue', String.valueOf(''), String.valueOf(''),false, '', ex);
            }
            return null;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        fetchQCCEntitlementRecords
    Description:        Method to get all QCC Entitlement records
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static Map<String, Id> fetchQCCEntitlementRecords() {
        Map<String, Id> mapQCCEntitlement = new Map<String, Id>();
        try {
            for(Entitlement objEntitlement: [SELECT Id, Name from Entitlement where Name like :'QCC%'] ){
                mapQCCEntitlement.put(objEntitlement.Name, objEntitlement.Id);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'fetchQCCEntitlementRecords', String.valueOf(''), String.valueOf(''),false, '', ex);                      
        }
        
        return mapQCCEntitlement;
    }

    
    /*--------------------------------------------------------------------------------------
    Method Name:        fetchQCCFirstHostRecords
    Description:        Method to get all QCC First Host records
    Parameter:          Map<String, qcc_first_host__c>
    --------------------------------------------------------------------------------------*/
    public static Map<String, qcc_first_host__c> fetchQCCFirstHostRecords(List<String> referenceNumberList) {
        Map<String, qcc_first_host__c> qccFirstHostRecMap = new Map<String, qcc_first_host__c>();
        try {
            for(qcc_first_host__c firstHostRecord: [SELECT id,name, QCC_First_Host_Contact__c FROM qcc_first_host__c WHERE name IN :referenceNumberList]){
                qccFirstHostRecMap.put(firstHostRecord.name, firstHostRecord);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'fetchQCCFirstHostRecords', String.valueOf(''), String.valueOf(''),false, '', ex);                      
        }
        return qccFirstHostRecMap;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        fetchContactWatchListRescord
    Description:        Method to get contact watch List records for the Contacts
    Parameter:          List<Id> contactIds
    --------------------------------------------------------------------------------------*/
    public static Map<String, QCC_Contact_Watchlist__c> fetchContactWatchListRescord(List<Id> contactIds) {
        Map<String, QCC_Contact_Watchlist__c> watchlistMap = new Map<String, QCC_Contact_Watchlist__c>();
        try {
           
            for(QCC_Contact_Watchlist__c watchlistRecord : [SELECT Id, QCC_Contact__c FROM QCC_Contact_Watchlist__c 
                                                            WHERE QCC_Contact__c IN :contactIds AND  QCC_Watchlist_Start_Date__c  <= TODAY 
                                                            AND QCC_Watchlist_End_Date__c >= TODAY]) {
                    watchlistMap.put(watchlistRecord.QCC_Contact__c, watchlistRecord );
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'fetchContactWatchListRescord', String.valueOf(''), String.valueOf(''),false, '', ex);                      
        }
        return watchlistMap;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        updateTECHFields
    Description:        this method update the Tech field values.
    Parameter:          Case objCase
    --------------------------------------------------------------------------------------*/
    public static Case updateTECHFields(Case objCase){
        try {
                //CRM-8293: 23 July PROD: Date fields on Case have incorrect format of values
                String fullDate;
                if(objCase.Departure_Date_Time__c != null) {
                    objCase.TECH_Departure_Date_Time__c = GenericUtils.getFullDate (objCase.Departure_Date_Time__c, true);
                    objCase.TECH_Departure_Date__c = GenericUtils.getFullDate (objCase.Departure_Date_Time__c, true);
                }
                if(objCase.Email_Departure_Date_Time__c != null) {
                    objCase.TECH_Email_Departure_Date_Time__c = GenericUtils.getFullDate (objCase.Email_Departure_Date_Time__c, true);
                }
                if (objCase.Arrival_Date_Time__c != null) {
                    objCase.TECH_Arrival_Date__c = GenericUtils.getFullDate (objCase.Arrival_Date_Time__c, true);

                }
                if(objCase.Actual_Arrival_Date_Time__c != null) {
                    objCase.TECH_Actual_Arrival_Date_Time__c = GenericUtils.getFullDate (objCase.Actual_Arrival_Date_Time__c, true);
                }
                if(objCase.Email_Arrival_Date_Time__c != null) {
                    objCase.TECH_Email_Arrival_Date_Time__c = GenericUtils.getFullDate (objCase.Email_Arrival_Date_Time__c, true);
                }
            } catch(Exception ex) {
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                'updateTECHFields', String.valueOf(''), String.valueOf(''),false, objCase.Id !=null?objCase.Id:'', ex);                     
            }
            return objCase;
    }

     /*--------------------------------------------------------------------------------------
    Method Name:        fetchQueueNames
    Description:        Set Last Queue Owner Names
    Parameter:
    --------------------------------------------------------------------------------------*/
    public static void fetchQueueNames(Map<Id, Case> caseQueueMap) {
        try {
            if(caseQueueMap.size() > 0) {
                for(Group queue : [Select Id, Name from Group where Type = 'Queue' and Id in :caseQueueMap.keySet() ]) {
                    mapCaseLastQueue.put(queue.Id, queue.Name);
                }
            }
        }
        catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'fetchQueueNames', String.valueOf(''), String.valueOf(''),false, '', ex);                     
        }
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        caseStatusUpdated
    Description:        Set last queue owner; post to chatter, update case contact
    Parameter:          Case objCase, Case oldcase
    --------------------------------------------------------------------------------------*/
    public static Case caseStatusUpdated(Case objCase, Case oldcase){
        try{
            String invalidQueuesForLastQueueOwner= Label.CCC_R1_InvalidQueuesForLastQueueOwner;      // (User Story: QSFR-23)
            
            if(oldcase != null && oldcase.OwnerId != objCase.OwnerId) {
                if(string.valueOf(oldcase.OwnerId).startsWith('00G')) {
                    if( !invalidQueuesForLastQueueOwner.Contains(mapQueueName.get(oldcase.OwnerId)) ) {  //(User Story: QSFR-23) Start
                        objCase.Last_Queue_Owner__c = oldcase.OwnerId;
                        objCase.Last_Queue_Owner_Name__c = mapCaseLastQueue.containskey(oldcase.OwnerId) ? mapCaseLastQueue.get(oldcase.OwnerId) : objCase.Last_Queue_Owner_Name__c;
                    }
                }
                
            }
            
            //GRAPHITE-2372 : When Case Status Change, update Date field when the change happen, also if the status is Reloved
            if(oldcase != null && oldcase.Status != objCase.Status) {
                objCase.QCC_Status_Changed_Date__c = system.now();
                if(objCase.Status == CASE_CLOSED_STATUS) {
                    objCase.Resolve_Closeddate__c = system.now();
                    objCase.Qualtrics_Survey_Notification_Date__c = system.now();//jira-CRM-4962
                } /**Jira 4960*/
            }
            return objCase;
        }catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                     'caseStatusUpdated', String.valueOf(''), String.valueOf(''), false, objCase.Id !=null ? objCase.Id : '', ex);
            return null;                        
        }
        
    }

    
    /*--------------------------------------------------------------------------------------       
    Method Name:        updateHostNumber
    Description:        This method will get reference number from case description then search in Qantas Host object 
                        via name equals reference number and update the Qantas Host field in Case object with Qantas host ID
    Parameter:          Case caseRecord, qcc_first_host__c firstHostRecord
    --------------------------------------------------------------------------------------*/
    public static Case updateHostNumber(Case caseRecord, qcc_first_host__c firstHostRecord){
        
        try{
            caseRecord.Qantas_Host__c = firstHostRecord.id;
            caseRecord.Due_Date__c = System.today() + 2;
            caseRecord.Type = CustomSettingsUtilities.getConfigDataMap('QCC_PLATINUM_ONE_EMAIL_ENQ');
            if(firstHostRecord.QCC_First_Host_Contact__c != null){
                caseRecord.ContactId = firstHostRecord.QCC_First_Host_Contact__c;
            }
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
            'updateHostNumber', String.valueOf(''), String.valueOf(''), false, caseRecord.Id !=null ? caseRecord.Id : '', ex);
        }
        return caseRecord;
        
    }
    
    /**-------------------------------------------------------------------
    Method Name:        fetchValidateParentCaseRecords   
    Description:        To validate the parent case field-- Jira CRM-4844
    Parameter:          List<Id> caseIds, List<Id> parentCaseIds
     ---------------------------------------------------------------------*/
    public static Map<Id, String> fetchValidateParentCaseRecords(Set<Id> caseIds, List<Id> parentCaseIds) {
        Map<Id, String> mapParentCaseValidationError = new Map<Id, String>();
        try {
            //Agent making Parent as a child case
            for(Case objCase: [SELECT Id, ParentId FROM Case Where ParentId =:caseIds]){
                mapParentCaseValidationError.put(objCase.ParentId, System.Label.QCC_Making_Parent_Case_As_Child_Error_Msg);
            }
    
            for(Case objCase: [SELECT Id, ParentId, Status FROM Case Where Id =:parentCaseIds]){
                if(objCase.ParentId != Null){
                    //Agent adding a child to a child case.
                    mapParentCaseValidationError.put(objCase.Id, System.Label.QCC_Child_case_as_Parent_Error_Msg);
                } else if (objCase.Status != CASE_CLOSED_STATUS) {
                    //Agent adding a parent case number to a child but parent case is open
                    mapParentCaseValidationError.put(objCase.Id, System.Label.QCC_Parent_case_status_Error_Msg);
                }
            }
    
            //Any Child case status is not closed. only one open child case is allowd for a parent case.
            for(Case objCase: [SELECT Id, ParentId, Status FROM Case Where ParentId =:parentCaseIds AND Id NOT IN :caseIds]){
                if(!mapParentCaseValidationError.containsKey(objCase.ParentId) && objCase.Status != CASE_CLOSED_STATUS){
                    mapParentCaseValidationError.put(objCase.ParentId, System.Label.QCC_Open_Child_Case_Exist_Error_Msg);
                }
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
            'fetchValidateParentCaseRecords', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return mapParentCaseValidationError;
    }
   
        
    /*---------------------------------------------------------------------------------------------------
    Method Name:        populateBasicAutoCaseValues
    Description:        Sets Contact Email, Assign Active Assignment Rules for Red App & Qantas.com Cases
    Parameter:          Case
    ---------------------------------------------------------------------------------------------------*/
    public static Case populateBasicAutoCaseValues(Case cs) {
        try {
            
            cs.Description =  String.isNotBlank(cs.Description)?cs.Description.unescapeHtml4():cs.Description;
            cs.QCC_Combined_Case_Description__c = cs.QCC_Combined_Case_Description__c != null ? cs.QCC_Combined_Case_Description__c.unescapeHtml4() : cs.QCC_Combined_Case_Description__c;
            
            if(cs.RecordTypeId != QCC_OTSRecordTypeId && cs.OwnerId != mapQueue.get(EXCEPTION_QUEUE_NAME)) {
                if(cs.Type != INSURANCE_LETTER_TYPE_CASE && cs.Status != CASE_CLOSED_STATUS) {
                    cs.QCC_enableAssignmentRules__c = false;
                    cs.Assign_using_active_assignment_rules__c = true;
                }
                if(cs.Type == INSURANCE_LETTER_TYPE_CASE) {
                    cs.FCR__c = true;
                }
            }
            
            // The flight number from Webform always comes as combination of airline code and flight number. Eg:"QF0400". So we need to remove the starting 2 characters
            if(cs.Origin == CASE_QANTAS_ORIGIN && cs.Flight_Number__c != null) {
                cs.Flight_Number__c = cs.Flight_Number__c.substring(2);
            }
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler',
                                    'populateBasicAutoCaseValues', String.valueOf(''), String.valueOf(''),false, cs != null ? cs.Id : '', ex);
        }
        return cs;
    }
       
 
/*--------------------------------------------------------------------------------------
    Method Name:        updateVIPCasePriority
    Description:        Method to update the case priority for QCC types of cases
    Parameter:          String
    --------------------------------------------------------------------------------------*/
	public static Case updateVIPCasePriority(Map<String, Id> recordTypeMap, Case caseNewRecord, Map<String,QCCVIPPriorityUpdateWrapper> vipPriorityMap) {	
	
    /** Start: VIP Cases Priority update Logic **/

        Set<String> vipTiers = new Set<String>{
        CustomSettingsUtilities.getConfigDataMap('FFPO'),
        CustomSettingsUtilities.getConfigDataMap('CHAIRMANS_LOUNGE_PLATINUM_ONE'),
        CustomSettingsUtilities.getConfigDataMap('CHAIRMANS_LOUNGE')};

    Boolean isVIPTier = vipTiers.contains(caseNewRecord.Frequent_Flyer_Tier__c);

    String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(caseNewRecord.RecordTypeId).getName();
	
	if (isVIPTier) {
                
        String uniqueKey = recordTypeName + '_' + caseNewRecord.Type;

        if (vipPriorityMap.containsKey(uniqueKey)) {
            caseNewRecord.Priority = vipPriorityMap.get(uniqueKey).priority;
        }  
    }
		
	/** End: VIP Cases Priority update Logic **/

    return caseNewRecord;
}
    
/*-------------------------------------------------------------------------------------
Method Name:        assignCaseOwner
Description:        Method to assign a case to case owner
Parameter:          
--------------------------------------------------------------------------------------*/
    public static Case assignCaseOwner(Map<String, Id> recordTypeMap, Case caseOldRecord, Case caseNewRecord, Contact contactRecord, List<QCC_HotWord__mdt> hotWordList, Map<String, QCCRoutingTable__mdt> mapQCCRouting, Map<String, QCCRoutingPriority__mdt> mapQCCPriority, Map<String, String> mapExcludePriority) 
    {
        String originListForCTQELogic = 'Email;Phone;Web;Internal - Terminal;Internal - Other;In Person;Post;Voice;Webchat;Social Media;QF Internal;Red App;Qantas.com;Event;SMS;VIP Service Team Email Enquiries';
        String channelTypes = 'Qantas South Africa;Qantas Austria;Qantas Benelux;Qantas Scandinavia;Qantas Germany;Qantas Italy;Qantas Switzerland';

            QCC_HotWord__mdt hotWordMdt;

            QCCRoutingTable__mdt routingInfo;
            String queueName;
            List<String> asuLogicOne = CustomSettingsUtilities.getConfigDataMap('AssignCaseOwner_LogicOne').split(';');
            List<String> FFTierForAssignment = Label.QCC_Frequent_Flyer_Tier_with_Assignment_Rule.split(';');
            List<String> caseTypeForAssignment = Label.QCC_Case_Type_with_Assignment_Rule.split(';');
            List<String> frequentFlierForQantasVIP = new List<String> {
                    CustomSettingsUtilities.getConfigDataMap('FFPO'),
                    CustomSettingsUtilities.getConfigDataMap('CLQF'),
                    CustomSettingsUtilities.getConfigDataMap('CLPO'),
                    CustomSettingsUtilities.getConfigDataMap('CHAIRMANS_LOUNGE_PLATINUM_ONE'),
                    CustomSettingsUtilities.getConfigDataMap('CHAIRMANS_LOUNGE')
            };
            List<Id> recordTypeIdsForQantas = new List<Id> {
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Further Action RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC On The Spot Recovery RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Query RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType'))
            };
            List<Id> recordTypeIdsForQantasVIP = new List<Id> { 
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Further Action RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Query RecType')),
                        GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType'))
                };
                    List<String> categoryNotAllowedForQantasVIP = new List<String> {
                        CustomSettingsUtilities.getConfigDataMap('Medical - Assistance Provided'), 
                            CustomSettingsUtilities.getConfigDataMap('Medical - Patient'), 
                            CustomSettingsUtilities.getConfigDataMap('Injury/Illness/Safety')
                    };
                        List<String> ownerNamesNotAllowedForQVIP = new List<String> {
                            CustomSettingsUtilities.getConfigDataMap('Advocacy Queue'),
                                CustomSettingsUtilities.getConfigDataMap('Critical_Queue'),
                                CustomSettingsUtilities.getConfigDataMap('Emirates_Queue'),
                                CustomSettingsUtilities.getConfigDataMap('EU_Compensation_Queue'),
                                CustomSettingsUtilities.getConfigDataMap('ExCo_Queue')
                        };
                            Set<Id> recordTypeIdsForHobertQueue = new Set<Id> {
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Compliment RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Further Action RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC On The Spot Recovery RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Query RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType'))
            };
            Set<Id> recordTypeIdsForExCOQueue = new Set<Id> {
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Compliment RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Elite Process RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Assistance RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Disruption RecType')),
                GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Specific Needs RecType'))
            };
            //Set<String> ownerNamesForHobertQueue = new Set<String> { 'Hobart','Critical','Advocacy','Emirates','EU Compensation','ExCo','Baggage','Insurance','Medical' };
           //CRM-8115
            Set<String> ownerNamesForHobertQueue = new Set<String> { 'CCC_Hobart_Queue_High','CCC_Hobart_Queue_Low', 'CCC_Hobart_Queue_Medium', 'CCC_Hobart_Queue_SLA', 'CCC_R1_Hobart_Q',
                                                                     'CCC_R1_Critical_Q', 'Critical_Queue_High', 'Critical_Queue_Low', 'Critical_Queue_Medium', 'Critical_Queue_SLA',  
                                                                     'Advocacy_Queue_High','Advocacy_Queue_Low', 'Advocacy_Queue_Medium', 'Advocacy_Queue_SLA', 'CCC_R1_Advocacy_Q',
                                                                     'CCC_R1_Emirates_Q','Emirates_Queue_High','Emirates_Queue_Low', 'Emirates_Queue_Medium', 'Emirates_Queue_SLA',
                                                                     'EU_Compensation_Queue_High',
                                                                     'ExCo_Queue_High',
                                                                     'Baggage_Damaged_Queue_High', 'Baggage_Damaged_Queue_Low', 'Baggage_Damaged_Queue_Medium', 'Baggage_Damaged_Queue_SLA', 'Baggage_Delayed_Queue_High', 'Baggage_Delayed_Queue_Low', 
                                                                     'Baggage_Delayed_Queue_Medium', 'Baggage_Delayed_Queue_SLA', 'CCC_Baggage_Tracing_Queue', 'CCC_R1_Damaged_Baggage_Q', 'CCC_R1_Delayed_Baggage_Q',
                                                                     'CCC_Insurance_Refund_Queue', 'CCC_R1_Insurance_Q', 'Insurance_Queue_High', 'Insurance_Queue_Low', 'Insurance_Queue_Medium', 'Insurance_Queue_SLA',
                                                                     'Medical' };


            //GRAPHITE-1798
            List<String> QCC_PreTravelCaseRTwithAssignmentRule = Label.QCC_Pre_Travel_Case_RT_with_Assignment_Rule.split(';');
            List<String> QCC_PostTravelCaseRTwithAssignmentRule = Label.QCC_Post_Travel_Case_RT_with_Assignment_Rule.split(';');
            List<String> QCC_CaseRTWithoutContactForAssignmentRule = Label.QCC_CaseRTWithoutContactForAssignmentRule.split(';');
            List<String> QCC_FFEffectiveTierForCaseAssignment = Label.QCC_FFEffectiveTierForCaseAssignment.split(';');
            String caseRecordTypeName =  Schema.sObjectType.Case.getRecordTypeInfosById().get(caseNewRecord.RecordTypeId).getName();
            String description = String.isBlank(caseNewRecord.QCC_Combined_Case_Description__c) ? caseNewRecord.Description : caseNewRecord.QCC_Combined_Case_Description__c;
            if (String.isNotBlank(description) && caseNewRecord.RecordTypeId != QCC_RefundRecordTypeId) {
                hotWordMdt = caseDescriptionCheck(description, hotWordList);
                queueName = hotWordMdt != null ? hotWordMdt.DeveloperName : queueName;
            }

                //GRAPHITE-1429/1722: For Specific Needs, hot word will not be considered. It will always be assigned to the Specific Needs queue.
                //As part of this solution, the "QCC Case - Email-to-Case Creation" PB will also set the Override Hotword = TRUE.
                if(hotWordMdt != NULL && caseOldRecord == null && asuLogicOne.contains(caseNewRecord.Origin)) {
                    caseNewRecord.QCC_enableAssignmentRules__c = false;
                    caseNewRecord.Assign_using_active_assignment_rules__c = true;
                    
                }
                //GRAPHITE-927: Tag (QCC_ASSIGNMENT_FLAG) is appended in the description as temporary indicator to run Assignment rules for VIP scenarios. Tag will be removed by QCC Case - Enable Assignment Rule
                //note: Unable to use Assign_using_active_assignment_rules__c because it is being unchecked in this code before the record is committed
                //and so when the case assignment rule is invoked system would not know that the user/system has checked the flag
                //GRAPHITE-1798 - Assignment rules will only be run for: (1) Post Travel without hotword, (2) All pretravel regardless if there is a hotword or not.
                if (caseNewRecord.Assign_using_active_assignment_rules__c) {
                    //For pre-travel cases created with out Contact (i.e. email-to-case), it will be processed by the assignment rule to be assigned to pretravel queues
                    //caseTypeForAssignment contains case types (e.g Qantas Host Call) for PreTravel cases that does not always have a Contact
                    if (contactRecord == null && (caseOldRecord == null || !assignmentRuleInvokedMap.containsKey(caseNewRecord.Id)) && (QCC_CaseRTWithoutContactForAssignmentRule.contains(caseRecordTypeName) || (QCC_PreTravelCaseRTwithAssignmentRule.contains(caseRecordTypeName) && caseTypeForAssignment.contains(caseNewRecord.Type)))) {
                        caseNewRecord.Comments__c = caseNewRecord.Comments__c == null  ? Label.QCC_Case_Assignment_Flag : caseNewRecord.Comments__c + ' ' + Label.QCC_Case_Assignment_Flag;
                        assignmentRuleInvokedMap.put(caseNewRecord.Id, true);
                    } else {
                        if (contactRecord != null && (caseOldRecord == null || !assignmentRuleInvokedMap.containsKey(caseNewRecord.Id)) && (FFTierForAssignment.contains(contactRecord.Frequent_Flyer_Tier__c) || contactRecord.SSU__c || QCC_FFEffectiveTierForCaseAssignment.contains(contactRecord.QCC_Effective_Tier__c))) {
                            if ((hotWordMdt == null && QCC_PostTravelCaseRTwithAssignmentRule.contains(caseRecordTypeName)) || QCC_PreTravelCaseRTwithAssignmentRule.contains(caseRecordTypeName)) {
                                caseNewRecord.Comments__c = caseNewRecord.Comments__c == null  ? Label.QCC_Case_Assignment_Flag : caseNewRecord.Comments__c + ' ' + Label.QCC_Case_Assignment_Flag;
                                assignmentRuleInvokedMap.put(caseNewRecord.Id, true);
                            }
                        }
                    }
                }
                // GRAPHITE-927 - END
                //Added hotWordMdt != NULL for QDCUSCON-5240
                if (caseNewRecord.Assign_using_active_assignment_rules__c && !caseNewRecord.Override_Hotword__c && caseNewRecord.Airline__c != 'REX' && (contactRecord != NULL || hotWordMdt != NULL)                             
                           && (caseOldRecord == null || caseNewRecord.RecordtypeId != caseOldRecord.RecordtypeId || !caseNewRecord.QCC_enableAssignmentRules__c ||
                               caseNewRecord.Assign_using_active_assignment_rules__c != caseOldRecord.Assign_using_active_assignment_rules__c ||
                               (caseOldRecord.Status != caseNewRecord.Status && caseNewRecord.Status == CASE_REOPENED_STATUS) ))
                {
                    //Updates Priority logic for Non-VIP Tier cases. For VIP Tier cases 'updateVIPCasePriority' method is used.

                    String queueSuffix = 'Low';

                    Boolean isVIPTier = caseNewRecord.Frequent_Flyer_Tier__c != null && (frequentFlierForQantasVIP.contains(caseNewRecord.Frequent_Flyer_Tier__c) ) ;

                    if (mapQCCPriority.containsKey(caseNewRecord.Cabin_Class__c + '#' + caseNewRecord.Frequent_Flyer_Tier__c)) {
                        queueSuffix = mapQCCPriority.get(caseNewRecord.Cabin_Class__c + '#' + caseNewRecord.Frequent_Flyer_Tier__c).Priority__c;
                    }
					
                    //CRM-13876 Adding conditional category based routing for solutions and resolutions types
                    String q_Name=mapQCCRouting?.get(caseNewRecord?.Type + caseNewRecord?.Group__c + (String.isBlank(caseNewRecord?.Category__c) ? '' : caseNewRecord?.Category__c))?.QUEUE_Name__c;
                    if(q_Name=='CCC_Resolutions'|| q_Name=='CCC_Solutions')
                    {
                        system.debug('>>Inside case category routing');
                        //Only consider the Type/Group/Catgeory To match for solutions/resolutions
                        routingInfo = mapQCCRouting.get(caseNewRecord.Type + caseNewRecord.Group__c + (String.isBlank(caseNewRecord.Category__c) ? '' : caseNewRecord.Category__c));
                    }
                    else
                    {
                        routingInfo = mapQCCRouting.get(caseNewRecord.Type + caseNewRecord.Group__c + (String.isBlank(caseNewRecord.Category__c) ? '' : caseNewRecord.Category__c) + (String.isBlank(caseNewRecord.Sub_Category__c) ? '' : caseNewRecord.Sub_Category__c));
                    }
                    system.debug('>>> routing info record'+routingInfo);
                    if (routingInfo == null) {
                        routingInfo = mapQCCRouting.get(caseNewRecord.Type + caseNewRecord.Group__c);
                    }
                    if(routingInfo != null) {
                        if (hotWordMdt != null) {
                            if (caseOldRecord == null && caseNewRecord.Status == CASE_CLOSED_STATUS && caseNewRecord.Is_Response_Requested__c == CustomSettingsUtilities.getConfigDataMap('QCC_ResponseRequired')) {
                                caseNewRecord.Status = CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusReceived');
                            }
                            caseNewRecord.CCC_R1_CCAT_Type__c = hotWordMdt.CCC_R1_CCAT_Type__c;
                            caseNewRecord.Hot_words_check__c = true;
                        } else {
                            /*CRM-13876 Commenting this code out as This routing model is obsolete
                            if(caseNewRecord.Type == CASE_COMPLAINT_TYPE && caseNewRecord.Group__c == CustomSettingsUtilities.getConfigDataMap('Case Group Lounges')) {
                                queueName = CustomSettingsUtilities.getConfigDataMap('QCC Lounges Queue');
                            } 
                            //CRM-13812 and CRM-13876 as all the open OTSR cases should be going to solutions queue    
                            else */
                            if (caseNewRecord.recordtypeid==QCC_OTSRecordTypeId && caseNewRecord.status!=CASE_CLOSED_STATUS) {
                                queueName=CASE_Solutions_QUEUE;
                            } 
                            else if (caseNewRecord.Type == CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type')) {
                                //CRM-13830 and CRM-13876 as all Insurance letter cases should be going to resolutions queue
                                //queueName = CASE_INSURANCE_QUEUE;
                                queueName=CASE_Resolutions_QUEUE;
                                // Jira CRM-7009:Damaged Mobility Aid to be routed to CCAT
                            } else if((!(caseNewRecord.RecordTypeId == recTypeCCCBaggage && caseNewRecord.Type == CASE_BAGGAGE_TYPE && caseNewRecord.Group__c == CASE_DAMAGEDBAGGAGE_GROUP && caseNewRecord.Category__c == CASE_MOBILITYAIDS_CATEGORY)) && 
                                      (frequentFlierForQantasVIP.contains(caseNewRecord.Frequent_Flyer_Tier__c) || (contactRecord != NULL && (CustomSettingsUtilities.getConfigDataMap('FFLP') == contactRecord.QCC_Effective_Tier__c || contactRecord.SSU__c))) &&
                                      recordTypeIdsForQantasVIP.contains(caseNewRecord.RecordTypeId) && !categoryNotAllowedForQantasVIP.contains(caseNewRecord.Category__c) && !ownerNamesNotAllowedForQVIP.contains(caseNewRecord.OwnerName__c) && !caseNewRecord.Board_Of_Member__c
                                     ) 
                            {
                                queueName = CustomSettingsUtilities.getConfigDataMap('Qantas VIP Post Travel Queue');
                            } else {
                                queueName = routingInfo.QUEUE_Name__c; 
                            }
                        }
                        Set<String> vipTiers = new Set<String>{
        CustomSettingsUtilities.getConfigDataMap('FFPO'),
        CustomSettingsUtilities.getConfigDataMap('CHAIRMANS_LOUNGE_PLATINUM_ONE'),
        CustomSettingsUtilities.getConfigDataMap('CHAIRMANS_LOUNGE')};
            
                        //Consolidation of Queues (User Story: QSFR-23) START
                        if (mapExcludePriority.containsKey('Exclude Priority '+queueName)) {
                            caseNewRecord.Priority = mapExcludePriority.get('Exclude Priority '+queueName);
                        } 
                        
                        else  {
                             if(!isVIPTier /*CRM-14077 Execute routing priority assignment only on Case insert; skip updates to preserve Customer Reply priority. */ && caseOldRecord == null){
                            caseNewRecord.Priority = queueSuffix;
                        }
                        }
						
                        
                        //Consolidation of Queues (User Story: QSFR-23) END
                        if(mapQueue.containsKey(queueName)) {
                            caseNewRecord.OwnerId = mapQueue.get(queueName);
                        }
                    }
                    caseNewRecord.Assign_using_active_assignment_rules__c = false;
                    caseNewRecord.QCC_enableAssignmentRules__c = true;
                    //added HOTWORD email creation 
                } else if (!caseNewRecord.Assign_using_active_assignment_rules__c && !caseNewRecord.Override_Hotword__c && hotWordMdt != NULL && (caseOldRecord == NULL || caseOldRecord.Description != caseNewRecord.Description) && String.isNotBlank(caseNewRecord.Origin) && caseNewRecord.Origin!='Email')
                {
                   caseNewRecord.addError(CustomSettingsUtilities.getConfigDataMap('QCC_HotwordMSG'));
                } else if (Trigger.isUpdate && caseNewRecord.Assign_using_active_assignment_rules__c && caseNewRecord.Override_Hotword__c && caseNewRecord.OwnerId == caseOldRecord.OwnerId) {
                    //Added by Raghav to check if case owner is changed, then do not throw error.
                    caseNewRecord.addError(CustomSettingsUtilities.getConfigDataMap('QCC_RoutingConflictMSG'));
                    // Added by Purushotham for QDCUSCON-5240
                } else if(caseNewRecord.Assign_using_active_assignment_rules__c && contactRecord == null) {
                    caseNewRecord.Assign_using_active_assignment_rules__c = false;
                }
                // End - QDCUSCON-5240    
            String ownerId = caseNewRecord.OwnerId;
            //Added as part of the Jira CRM-4804
            if (ownerId != null && ownerId.startsWith('00G') && caseNewRecord.RecordTypeId != QCC_RefundRecordTypeId) {
                caseNewRecord.QCC_Routing_Invoked__c = true;
                String slaQueueName = mapQueueName.get(caseNewRecord.OwnerId);
                if (slaQueueName != null) {
                    slaQueueName = slaQueueName.substring(0, slaQueueName.lastIndexOf('_')) + '_SLA';
                    caseNewRecord.SLA_Queue__c = mapQueue.get(slaQueueName);
                }
                

                
            }
            //assignmentRuleInvoked = true;
            // CRM-6184: *Platinum FF Cases should be routed to CCC Hobart Queue
            if (String.isNotBlank(caseNewRecord.OwnerName__c) && recordTypeIdsForHobertQueue.contains(caseNewRecord.RecordTypeId) 
                && String.isNotBlank(caseNewRecord.Frequent_Flyer_Tier__c) && caseNewRecord.Frequent_Flyer_Tier__c == 'Platinum' && !ownerNamesForHobertQueue.contains(caseNewRecord.OwnerName__c) 
                && (caseNewRecord.OwnerName__c.startsWith('CCC') || caseNewRecord.OwnerName__c.contains('Queue'))
                && (caseOldRecord == null || caseOldRecord.OwnerName__c != caseNewRecord.OwnerName__c 
                    || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId || caseOldRecord.Frequent_Flyer_Tier__c != caseNewRecord.Frequent_Flyer_Tier__c)) 
            { 
                //CRM-13758 rerouting cases with specific conditions to Disruptions Queue(Platinum FF and other parent checks remain same) 
                if((caseNewRecord.RecordTypeId.equals(QCC_ComplaintsRecordTypeId) || caseNewRecord.RecordTypeId.equals(QCC_FARRecordTypeId)|| caseNewRecord.RecordTypeId.equals(QCC_QueryRecordTypeId))
                && (caseNewRecord.Category__c=='Accommodation/Reimbursement of Expenses' || caseNewRecord.Category__c=='Downgrade')
                && (String.isBlank(caseNewRecord.Sub_Category__c) || caseNewRecord.Sub_Category__c=='Agent booking' || caseNewRecord.Sub_Category__c=='QF booking single Sector' || caseNewRecord.Sub_Category__c=='QF Booking Throughfare'))
                {
                    caseNewRecord.Priority = 'High';
                    caseNewRecord.OwnerId = mapQueue.get('CCC_Omni_Flight_Disruption');
                }
                //CRM-13876 Commenting this code out as This routing model is obsolete for Contact centers
                /*else {   
                caseNewRecord.Priority = 'High';
                caseNewRecord.OwnerId = mapQueue.get('CCC_R1_Hobart_Q');
                }*/
            } else if (caseNewRecord.RecordTypeId == QCC_InsuranceRecordTypeId && String.isNotBlank(caseNewRecord.OwnerName__c)
                        && (caseNewRecord.OwnerName__c.containsIgnoreCase('Critical') || caseNewRecord.OwnerName__c.containsIgnoreCase('Advocacy') 
                            || caseNewRecord.OwnerName__c.containsIgnoreCase('Emirates') || caseNewRecord.OwnerName__c.containsIgnoreCase('ExCo')
                            || caseNewRecord.OwnerName__c.containsIgnoreCase('EU Compensation'))
                        && (caseOldRecord == null || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId 
                            || caseOldRecord.OwnerId != caseNewRecord.OwnerId)) 
            {
                if (String.isNotBlank(caseNewRecord.Frequent_Flyer_Tier__c) 
                    && (caseOldRecord == null || caseOldRecord.Last_Queue_Owner_Name__c != caseNewRecord.Last_Queue_Owner_Name__c
                        || caseOldRecord.Frequent_Flyer_Tier__c != caseNewRecord.Frequent_Flyer_Tier__c))
                {
                    // For Case Insurance letters redirect the case owner to Insurance queue if hot words are present for Bronze and Non Tiered 
                    if (caseNewRecord.Frequent_Flyer_Tier__c.containsIgnoreCase('Non-tiered') 
                        || caseNewRecord.Frequent_Flyer_Tier__c.containsIgnoreCase('Bronze')) 
                    {
                        caseNewRecord.Priority = 'Low';
                        //CRM-13830 and CRM-13876 as all Insurance letter cases should be going to resolutions queue
                        //caseNewRecord.OwnerId = mapQueue.get(CASE_INSURANCE_QUEUE);
                    }
                    // For Case Insurance letters redirect the case owner to Insurance queue if hot words are present for Gold and Silver 
                    if (caseNewRecord.Frequent_Flyer_Tier__c.containsIgnoreCase('Gold') 
                        || caseNewRecord.Frequent_Flyer_Tier__c.containsIgnoreCase('Silver')) 
                    {
                            caseNewRecord.Priority = 'Medium';
                            //CRM-13830 and CRM-13876 as all Insurance letter cases should be going to resolutions queue
                            //caseNewRecord.OwnerId = mapQueue.get(CASE_INSURANCE_QUEUE);
                    }
                    // For Case Insurance letters redirect the case owner to Insurance queue if hot words are present for Platinum  
                    if (caseNewRecord.Frequent_Flyer_Tier__c.containsIgnoreCase('Platinum') 
                        && String.isNotBlank(caseNewRecord.Last_Queue_Owner_Name__c)) 
                    {
                            caseNewRecord.Priority = 'High';
                            //CRM-13830 and CRM-13876 as all Insurance letter cases should be going to resolutions queue
                            //caseNewRecord.OwnerId = mapQueue.get(CASE_INSURANCE_QUEUE);
                    }
                }
            }
        else if (caseNewRecord.RecordTypeId == QCC_InsuranceRecordTypeId && String.isNotBlank(caseNewRecord.Frequent_Flyer_Tier__c) 
                        && caseNewRecord.Frequent_Flyer_Tier__c.containsIgnoreCase('Platinum') 
                        && String.isNotBlank(caseNewRecord.Last_Queue_Owner_Name__c) 
                        && !caseNewrecord.Last_Queue_Owner_Name__c.containsIgnoreCase('Insurance')
                        && (caseOldRecord == null || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId 
                            || caseOldRecord.Last_Queue_Owner_Name__c != caseNewRecord.Last_Queue_Owner_Name__c 
                            || caseOldRecord.Frequent_Flyer_Tier__c != caseNewRecord.Frequent_Flyer_Tier__c)) 
            {
                // For Case Insurance letters redirect the case owner to Insurance queue if hot words are present for Platinum 
                caseNewRecord.Priority = 'High';
                //CRM-13830 and CRM-13876 as all Insurance letter cases should be going to resolutions queue
                //caseNewRecord.OwnerId = mapQueue.get(CASE_INSURANCE_QUEUE);
            } 
        else if (caseNewRecord.ContactId != null && caseNewRecord.Contact.Board_Of_Member__c 
                        && !recordTypeIdsForExCOQueue.contains(caseNewRecord.RecordTypeId) && caseNewRecord.Group__c != 'Post Flight Survey'
                        && (caseOldRecord == null || caseOldRecord.Group__c != caseNewRecord.Group__c 
                            || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId))
            {
                //QCC_Board_of_Member_Beneficiaries_cases_to_Exco_Queue_High
                caseNewRecord.OwnerId = mapQueue.get('ExCo_Queue_High');

            }
        
            if (caseNewRecord.RecordTypeId == QCC_AssistanceRecordTypeId && caseNewRecord.ParentId != null 
                    && String.isBlank(caseNewRecord.Last_Queue_Owner__c) && String.isBlank(caseNewRecord.Last_Queue_Owner_Name__c)
                    && (caseOldRecord == null || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId 
                        || caseOldRecord.ParentId != caseNewRecord.ParentId 
                        || caseOldRecord.Last_Queue_Owner__c != caseNewRecord.Last_Queue_Owner__c 
                        || caseOldRecord.Last_Queue_Owner_Name__c != caseNewRecord.Last_Queue_Owner_Name__c)) 
            {
                // QCC Update Child Assistance Case Owner
                //caseNewRecord.OwnerId = mapQueue.get(VIPREPLY_QUEUE_NAME);
               caseNewRecord.OwnerId = mapQueue.get('QCC_VIP_Email_Enquiries');  
            } 
        else if (caseNewRecord.RecordTypeId == recTypeCCCBaggage && caseNewRecord.Status != CASE_CLOSED_STATUS
                       && String.isNotBlank(caseNewRecord.Baggage_Assessment_Outcome__c) 
                       && (caseOldRecord == null || caseOldRecord.Status != caseNewRecord.Status))
            {
                //caseNewRecord.Baggage_Assessment_Outcome__c = null; //CDP2-965 AC04 No longer required
            } else if (caseNewRecord.OwnerId == mapQueue.get(EXCEPTION_QUEUE_NAME) && String.isNotBlank(caseNewRecord.SuppliedEmail)
                        && caseNewRecord.RecordTypeId != QCC_BouncedBackRecordTypeId 
                        && (caseOldRecord == null || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId 
                            || caseOldRecord.OwnerId != caseNewRecord.OwnerId 
                            || caseOldRecord.SuppliedEmail != caseNewRecord.SuppliedEmail)) 
            {
                caseNewRecord.RecordTypeId = QCC_QueryRecordTypeId;
                caseNewRecord.OwnerId = mapQueue.get(EXCEPTION_QUEUE_NAME);
                caseNewRecord.Origin = 'SHR QCC';
            }
            if (caseNewRecord.RecordTypeId == QCC_SpecificNeedsRTypeId && caseNewRecord.ParentId != null 
                      && (String.isBlank(caseNewRecord.Last_Queue_Owner__c) || String.isBlank(caseNewRecord.Last_Queue_Owner_Name__c))
                      && (caseOldRecord == null || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId 
                        || caseOldRecord.ParentId != caseNewRecord.ParentId
                        || caseOldRecord.Last_Queue_Owner__c != caseNewRecord.Last_Queue_Owner__c 
                        || caseOldRecord.Last_Queue_Owner_Name__c != caseNewRecord.Last_Queue_Owner_Name__c)) 
            {
                //QCC Update Child Specific Needs Case Owner
               // caseNewRecord.OwnerId = mapQueue.get('QCC_Specific_Needs_Bounce_Back_Queue');
               caseNewRecord.OwnerId = mapQueue.get('QCC_Specific_Needs_Email_Enquiries');//new change
            }
            
            // Cases from qantas with CCAT hot word should go to Critical queue-High
            if (caseNewRecord.Origin == CASE_QANTAS_ORIGIN && String.isNotBlank(caseNewRecord.Description)
                && caseNewRecord.Description.contains('CCAT')
                && (caseOldRecord == null || caseOldRecord.Origin != caseNewRecord.Origin 
                    || caseOldRecord.Description != caseNewRecord.Description)) {
                caseNewRecord.OwnerId = mapQueue.get('CCC_R1_Critical_Q');
                caseNewRecord.Priority = CASE_HIGH_PRIORITY;
            }
        
         if (caseNewRecord.Origin == CASE_QANTAS_ORIGIN && String.isNotBlank(caseNewRecord.Description)
                && caseNewRecord.Description.contains('CCAT')
                && (caseOldRecord == null || caseOldRecord.Origin != caseNewRecord.Origin 
                    || caseOldRecord.Description != caseNewRecord.Description)) {
                caseNewRecord.Priority = CASE_HIGH_PRIORITY;
            }

            
            // QCC_Cases to Exception queue if contact is blank
            //Added by Suresh as per CRM-10622
        List<String> lstQCCQueues = new List<String>();
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('QCC Musical Baggage Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('QCC Emirates Helpdesk Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('QCC OneWorld Helpdesk Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('QCC Japan Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('QCC Korean Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('CCC QET Supervisors Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('CCC Insights Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('CCC Customer Queries Queue'));
        lstQCCQueues.add(CustomSettingsUtilities.getConfigDataMap('Service Delivery'));
        
            if (caseOldRecord == null && caseNewRecord.ContactId == null 
                && (caseNewRecord.RecordTypeId == recTypeCCCBaggage || caseNewRecord.RecordTypeId == QCC_ComplaintsRecordTypeId
               || caseNewRecord.RecordTypeId == QCC_ComplimentsRecordTypeId || caseNewRecord.RecordTypeId == QCC_BouncedBackRecordTypeId
               || caseNewRecord.RecordTypeId == QCC_EventRecordTypeId || caseNewRecord.RecordTypeId == QCC_FARRecordTypeId 
                || caseNewRecord.RecordTypeId == QCC_InsuranceRecordTypeId ||  caseNewRecord.RecordTypeId == QCC_MedicalTypeId 
                || caseNewRecord.RecordTypeId == QCC_OffloadRecordTypeId || caseNewRecord.RecordTypeId == QCC_OTSRecordTypeId 
               || caseNewRecord.RecordTypeId == QCC_QueryRecordTypeId || caseNewRecord.RecordTypeId == QCC_RefundRecordTypeId)
                && originListForCTQELogic.containsIgnoreCase(caseNewRecord.Origin) && (caseNewRecord.OwnerName__c == NULL || 
                 (caseNewRecord.OwnerName__c != NULL && !CustomSettingsUtilities.getConfigDataMap('Linguistic_Queues').containsIgnoreCase(caseNewRecord.OwnerName__c)))
               && (!lstQCCQueues.contains(caseNewRecord.OwnerName__c)))
            {
                caseNewRecord.OwnerId = mapQueue.get(EXCEPTION_QUEUE_NAME);
            }
            if (caseNewRecord.SubmitForFinalisation__c == true
                && (caseNewRecord.RecordTypeId == recTypeCCCBaggage || caseNewRecord.RecordTypeId == QCC_ComplaintsRecordTypeId
                    || caseNewRecord.RecordTypeId == QCC_ComplimentsRecordTypeId || caseNewRecord.RecordTypeId == QCC_InsuranceRecordTypeId 
					|| caseNewRecord.RecordTypeId == QCC_QueryRecordTypeId // || caseNewRecord.RecordTypeId == QCC_MedicalTypeId CDP2-1009
                    || caseNewRecord.RecordTypeId == QCC_FARRecordTypeId || caseNewRecord.RecordTypeId == QCC_EventRecordTypeId
                    || caseNewRecord.RecordTypeId == QCC_OTSRecordTypeId || caseNewRecord.RecordTypeId == QCC_RefundRecordTypeId
                    || caseNewRecord.RecordTypeId == QCC_EliteProcessRecordTypeId || caseNewRecord.RecordTypeId == QCC_AssistanceRecordTypeId
                    || caseNewRecord.RecordTypeId == QCC_BouncedBackRecordTypeId || caseNewRecord.RecordTypeId == QCC_DisruptionRecordTypeId
                    || caseNewRecord.RecordTypeId == QCC_SpecificNeedsRTypeId)
                && (caseOldRecord == null || caseOldRecord.SubmitForFinalisation__c != caseNewRecord.SubmitForFinalisation__c || caseOldRecord.RecordTypeId != caseNewRecord.RecordTypeId))
            {
                caseNewRecord.OwnerId = mapQueue.get('Fulfillment_Queue');
                caseNewRecord.SubmitForFinalisation__c = false;
            }
            if (caseOldRecord == null && caseNewRecord.RecordTypeId == QCC_FARRecordTypeId 
                        && caseNewRecord.Origin == CASE_REDAPP_ORIGIN
                        && caseNewRecord.Category__c == 'Seating' && caseNewRecord.Sub_Category__c == 'Comfort/Functionality'
                        && caseNewRecord.Type == 'Further Action Required' && caseNewRecord.Group__c == 'In-Flight') 
            {
                caseNewRecord.OwnerId = mapQueue.get('CCC_Ex_Gratia_Recoveries');
            }
            
            
            //CRM-8439 -- Only Temporary to be removed
            if (caseNewRecord.Airline__c != 'REX' && caseNewRecord.Departure_Airport__c == 'REX-NOT-PROVIDED') {
                caseNewRecord.OwnerId = mapQueue.get('Other_Queue_SLA');
                caseNewRecord.Airline__c = 'REX';
                caseNewRecord.Is_Response_Requested__c = 'No';
                caseNewRecord.Assign_using_active_assignment_rules__c = false;
            }

           
            if(caseNewRecord.status != null && caseNewRecord.status.equals('Pending Recovery') && (caseOldRecord == null || caseNewRecord.status != caseOldRecord.status ))
            {
                if(mapQueue.containsKey('Pending_Recovery')) {
                    caseNewRecord.OwnerId = mapQueue.get('Pending_Recovery');
                }
            }
            return caseNewRecord;
    }
        
    
    /*--------------------------------------------------------------------------------------
    Method Name:        fetchMetaObjectsByModuleName
    Description:        Method to fetch Source to target records by module name
    Parameter:          String
    --------------------------------------------------------------------------------------*/
    public static Map<String,List<sObject>> fetchMetaObjectsByModuleName(String moduleName) {
        
        try {
            List<string> moduleNameList = new List<String>();
            moduleNameList.add(moduleName);
            return QCC_UtilityHelper.getSourceToTargetRecordsByModuleNames(moduleNameList); 

        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                'fetchMetaObjectsByModuleName', String.valueOf(''), String.valueOf(''), false, '', ex);
                return null;
        }
    }

    public static Case updateFields(Case cs, QCC_Contact_Watchlist__c watchlistRecord, Map<String,List<sObject>> metaObjectsByModuleName) {
        try{
            
            String moduleName =  String.isBlank(cs.recordType.developerName) ? RT_ELITEPORCESS : cs.recordType.developerName + ' - ' +cs.Type;
            //if contact is on watchlist append watchlist to module name
            if(watchlistRecord != null && watchlistRecord.QCC_Contact__c == cs.contactId){
                //Contact of case is on watchlist
                moduleName = moduleName + ' - Watchlist';
            }
            
            if(!metaObjectsByModuleName.isEmpty() && metaObjectsByModuleName.containsKey(moduleName)){
                // Collection of Field from Metada for updating Case record
                List<sObject> metaObjects = metaObjectsByModuleName.get(moduleName);
                
                List<Case> caseList =  QCC_UtilityHelper.transformSourceToTargetObjects(moduleName, new List<Case>{cs},metaObjects , 'Case', cs.RecordTypeId, null) ;
            }

        }catch(exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                'updateFields', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return cs;

    }

/*--------------------------------------------------------------------------------------
Method Name:        caseDescriptionCheck
Description:        Method to get the hot word queue name
Parameter:
--------------------------------------------------------------------------------------*/
    public static QCC_HotWord__mdt caseDescriptionCheck(String caseDescription, List<QCC_HotWord__mdt> hotWordList) {
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
        Matcher matcher = nonAlphanumeric.matcher(caseDescription);
        caseDescription = ' ' + matcher.replaceAll(' ') + ' ';
        for (QCC_HotWord__mdt qccHotWord : hotWordList) {
            if (String.isNotBlank(qccHotWord.Hot_Word__c)) {
                for (String hotWord : qccHotWord.Hot_Word__c.split(',')) {
                    if(caseDescription.containsIgnoreCase((' '+hotWord.trim()+' ').replace('"',''))) {
                        return qccHotWord;
                    }
                }
            }
        }
        return NULL;
    }
/*--------------------------------------------------------------------------------------
Method Name:        reassignCaseWithWaitingStatus
Description:        Assign Case to Queue if status is Waiting for Customer/Internal. Need to run the full logic only when the status has been changed.
Parameter:
--------------------------------------------------------------------------------------*/
    public static Case reassignCaseWithWaitingStatus(Case caseOldRecord, Case caseRecord, Map<String, Id> recordTypeMap, Contact contactRecord) {
        try {
            Set<String> vipFFTierSet = new Set<String>(Label.QCC_CaseVIP.split(';'));
            caseQueueInfo(); // Reuse getting case queue list
            String currentFFTier = String.isNotBlank(caseRecord.FF_Tier__c) ? caseRecord.FF_Tier__c : (contactRecord == null ? '' : contactRecord.Frequent_Flyer_Tier__c );
                if (caseRecord.RecordTypeId == recordTypeMap.get(RT_SPECIFICNEEDS)) {
                //For case record type = QCC Specific Needs
                if(caseRecord.Status == STATUS_WAITINGFORCUSTOMER) {
                    caseRecord = updateCaseLastQueueOwnerFieldValue(caseRecord, caseOldRecord);//Jira: CRM-5357
                    caseRecord.Previous_Case_Owner__c = UserInfo.getUserId();
                    caseRecord.OwnerId = mapQueue.get(WAITINGFORCUSTOMER_SNQUEUE);
                } else if (caseRecord.Status == STATUS_WAITINGFORINTERNAL) {
                    caseRecord.OwnerId = mapQueue.get(WAITINGFORINTERNAL_SQQUEUE);
                }
            } else if ((contactRecord != null && contactRecord.SSU__c) || vipFFTierSet.contains(currentFFTier) ) {
                // Assign the case to VIP Team Regardless of Record Type
                if(caseRecord.status == STATUS_WAITINGFORCUSTOMER) {
                    caseRecord = updateCaseLastQueueOwnerFieldValue(caseRecord, caseOldRecord);//Jira: CRM-5357
                    caseRecord.Previous_Case_Owner__c = UserInfo.getUserId();
                    caseRecord.OwnerId = mapQueue.get(WAITINGFORCUSTOMER_VIPQUEUE);
                } else if (caseRecord.Status == STATUS_WAITINGFORINTERNAL) {
                    caseRecord.OwnerId = mapQueue.get(WAITINGFORINTERNAL_VIPQUEUE);
                }
            } else {
                //For case that is NOT VIP contact nor SSU and record type != QCC Specific Needs
                caseRecord = updateCaseLastQueueOwnerFieldValue(caseRecord, caseOldRecord);//Jira: CRM-5357
                if(caseRecord.Status == STATUS_WAITINGFORCUSTOMER) {
                    caseRecord.Previous_Case_Owner__c = UserInfo.getUserId();
                    caseRecord.OwnerId = mapQueue.get(WAITINGFORCUSTOMER_QUEUE);
                } else if(caseRecord.Status == STATUS_WAITINGFORINTERNAL) {
                    caseRecord.OwnerId = mapQueue.get(WAITINGFORINTERNAL_QUEUE);
                }
            }
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                    'reassignCaseWithWaitingStatus', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return caseRecord;
    }

/*----------------------------------------------------------------------------------------------
    Method Name:        updateCaseLastQueueOwnerFieldValue
    Description:        update the last queue owner when case status changed to Waiting for Customer/Waiting for Internal-Jira:CRM-5357
    Parameter:          Case, Case
----------------------------------------------------------------------------------------------*/
    public static Case updateCaseLastQueueOwnerFieldValue(Case caseRecord, Case oldCaseRecord) {
        try {
            String invalidQueuesForLastQueueOwner= Label.CCC_R1_InvalidQueuesForLastQueueOwner;
            if(String.valueOf(oldCaseRecord.OwnerId).startsWith('00G')) {
                caseQueueInfo();
                if (!invalidQueuesForLastQueueOwner.containsIgnoreCase(mapQueueName.get(oldCaseRecord.OwnerId))) {
                    caseRecord.Last_Queue_Owner__c = oldCaseRecord.OwnerId;
                    if (mapCaseLastQueue.containskey(caseRecord.Last_Queue_Owner__c)) {
                        caseRecord.Last_Queue_Owner_Name__c = mapCaseLastQueue.get(caseRecord.Last_Queue_Owner__c);
                    }
                }
            }
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                    'updateCaseLastQueueOwnerFieldValue', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return caseRecord;
    }
/*----------------------------------------------------------------------------------------------
    Method Name:        updateDepartureDateField
    Description:        
    Parameter:          Case, Case
----------------------------------------------------------------------------------------------*/
    public static Case updateDepartureDateField(Case caseRecord, Case oldCaseRecord) {
        try {
            String depDateTime = caseRecord.Departure_Date_Time__c;
            if (String.isBlank(depDateTime)) {
                return caseRecord;
            }
            depDateTime = depDateTime.split(' ')[0];
            if (String.isNotBlank(depDateTime) && (oldCaseRecord == null || caseRecord.Departure_Date_Time__c != oldCaseRecord.Departure_Date_Time__c)) {
                caseRecord.Updated_Departure_Date_Time__c = Date.parse(depDateTime);
            }
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                    'updateDepartureDateField', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return caseRecord;
    }

    public static Case specificNeedsChange(Case caseRecord, String rectypeId){
        try {
            caseRecord.RecordTypeId = rectypeId;
            caseRecord.Type = caseRecord.Category__c;
            caseRecord.Category__c = '';
            caseRecord.Group__c = '';
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                    'specificNeedsChange', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return caseRecord;
    }

    /*----------------------------------------------------------------------------------------------
        Method Name:        createCaseFlightEvent
        Description:        CRM-8725
        Parameter:          Map <PNR, List<Id>>
    ----------------------------------------------------------------------------------------------*/
    public static void createCaseFlightEvent(Map<Id, Case> caseMap, Map<String, Set<Id>> pnrEventIdMap, Map<Id, Event__c> eventMap) { //CRM-8661
        try {
            String caseFlightEventName;
            Event__c eventRecord;
            List<Case_Flight_Event__c> caseFlightEvents = new List<Case_Flight_Event__c>();
            for (Case caseRecord : caseMap.values()) {
            //CRM-8846 commenting to expand the Case Flight Event Functionality to other QCC Record Types
                if (/*caseRecord.RecordTypeId == RTIDVOICE &&*/ pnrEventIdMap.containsKey(caseRecord.Booking_PNR__c)) {
                    for (Id eventId : pnrEventIdMap.get(caseRecord.Booking_PNR__c)) {
                        eventRecord = eventMap.get(eventId);
                        if (eventRecord.Status__c != 'Closed') {
                            caseFlightEventName = caseMap.get(caseRecord.Id).CaseNumber + ' ' +  eventRecord.Name;
                            caseFlightEvents.add(new Case_Flight_Event__c(
                                    Name = caseFlightEventName,
                                    Case__c = caseRecord.Id,
                                    Flight_Event__c = eventRecord.Id
                            ));
                        }
                    }
                }
            }
            if (!caseFlightEvents.isEmpty()) {
                insert caseFlightEvents;
            }
        } catch(exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'CaseQCCTriggerHandler', 
                    'createCaseFlightEvent', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
    }
}