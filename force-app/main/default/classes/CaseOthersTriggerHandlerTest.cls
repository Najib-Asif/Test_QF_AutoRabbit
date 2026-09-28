@isTest
private class CaseOthersTriggerHandlerTest {
	private static final String CASE_ONHOLD_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusOnHold');
    private static final String QUEUE_DEAL_SUPPORT_REQUEST = CustomSettingsUtilities.getConfigDataMap('Queue_DealSupportRequest');
    private static final Id RTID_ACCOUNT_AGENCY = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    private static final Id RTID_CASE_QFREIGHT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
    private static final Id RTID_SERVICE_REQUEST = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('QIC_Service_request').getRecordTypeId();
    private static final Id RTID_KNOWLEDGE_REQUEST = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Knowledge_Request').getRecordTypeId();
    private static final Map<String, Map<String, Id>> BU_RECORDTYPEMAP =  CaseUtility.mapBUnitToCaseRecordTypes();
    private static final Map<String, Id> FREIGHT_RECORDTYPEMAP = BU_RECORDTYPEMAP.get('Freight');
    private static final Map<Id, Group> QUEUE_GROUPMAP = CaseUtility.queryQueueGroups();
    private static final Map<Id, Approval_Matrix__c> APPROVALMATRIX_MAP = CaseUtility.queryApprovalMatrices();
    private static final Map<Id, User> USERMAP = CaseUtility.queryUsers(new Set<Id>{ UserInfo.getUserId() });
    private static final String RTID_SRFLIGHT = Schema.SObjectType.Flight__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final String RTID_SRWORDER = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final String RTID_AFFPASS = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final Id RTID_SALES_SUPPORT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SHR_QIS_Sales_Support').getRecordTypeId();
    private static Id RTID_DEALSUPPORT_REQUEST = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Support_request').getRecordTypeId();
    
    @testSetup static void createTestData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lstStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lstStatus.addAll(TestUtilityDataClassQantas.createEmailMessageTriggerSetting());
        lstStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        insert lstStatus;
        List<Account> accountRecords = new Account[2];
        List<Contact> contactRecords = new Contact[2];
        
        accountRecords[0] = new Account(
            RecordTypeId = RTID_ACCOUNT_AGENCY,
            BillingCountry = 'AU',
            Name = 'Green Cord Corp',
            Email__c = 'greencord@auspost.com.au'
        );
        accountRecords[1] = new Account(
            RecordTypeId = RTID_ACCOUNT_AGENCY,
            BillingCountry = 'AU',
            Email__c = 'greenavenue@qantas.com.au',
            Name = 'Green Avenue Corp'
        );
        insert accountRecords;
        
        contactRecords[0] = new Contact(
            FirstName = 'Yellow',
            LastName = 'Trees',
            Email = 'greenTrees@fedex.com',
            AccountId = accountRecords[0].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        contactRecords[1] = new Contact(
            FirstName = 'Green',
            LastName = 'Garden',
            Email = 'greenavenue@qantas.com.au',
            AccountId = accountRecords[1].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        insert contactRecords;
        
        
        List<Case> caseRecords = new Case[6];
        caseRecords[0] = new Case( 
            RecordTypeId = RTID_SERVICE_REQUEST, 
            Status = 'Open',
            Type = 'Group Waivers',
            Problem_Type__c = 'Deposit Amount',
            Reason_for_Waiver__c = 'Compassionate Circumstances',
            AccountId = accountRecords[0].Id,
            Cost_of_Sale__c = 0,
            PNR_number__c = '123456',
            Passenger_Name__c = 'Dummy User',
            First_Flight_Date__c = System.Today(),
            flight_itinerary__c = '12345678',
            Condition_Met__c = 'Yes'
        );
        caseRecords[1] = new Case( 
            RecordTypeId = RTID_KNOWLEDGE_REQUEST, 
            Description = 'This is a sample record.',
            Article_Journey__c = 'Article Curation'
        );
        caseRecords[2] = new Case( 
            RecordTypeId = RTID_SALES_SUPPORT, 
            Description = 'This is a sample record.',
            Status = 'On Hold'
        ); 
        caseRecords[3] = new Case( 
            RecordTypeId = RTID_DEALSUPPORT_REQUEST, 
            Description = 'This is a sample record.',
            Status = 'Assigned to Pricing for Fare Filing'
        );
        caseRecords[4] = new Case( 
            RecordTypeId = RTID_SERVICE_REQUEST, 
            Status = 'In Progress',
            Type = 'Group Waivers',
            Problem_Type__c = 'Deposit Amount',
            Reason_for_Waiver__c = 'Compassionate Circumstances',
            AccountId = accountRecords[0].Id,
            Cost_of_Sale__c = 0,
            PNR_number__c = '123456',
            Passenger_Name__c = 'Dummy User',
            First_Flight_Date__c = System.Today(),
            flight_itinerary__c = '12345678',
            Condition_Met__c = 'Yes'
        );
        caseRecords[5] = new Case( 
            RecordTypeId = RTID_SERVICE_REQUEST, 
            Status = 'Open',
            Type = 'Group Waivers',
            Problem_Type__c = 'Deposit Amount',
            Reason_for_Waiver__c = 'Compassionate Circumstances',
            AccountId = accountRecords[0].Id,
            Cost_of_Sale__c = 0,
            PNR_number__c = '123456',
            Passenger_Name__c = 'Dummy User',
            First_Flight_Date__c = System.Today(),
            flight_itinerary__c = '12345678',
            Condition_Met__c = 'Yes'
        );
        insert caseRecords;
    }
   
    @isTest static void testOnBeforeInsert() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE Name = 'Green Avenue Corp' ];
        List<Case> caseRecords = new Case[1];
        List<id> accountRelationShipListN= new List<id> ();
        caseRecords[0] = new Case( 
            RecordTypeId = RTID_SERVICE_REQUEST, 
            Status = 'Open',
            Type = 'Group Waivers',
            Problem_Type__c = 'Deposit Amount',
            Reason_for_Waiver__c = 'Compassionate Circumstances',
            AccountId = accountRecords[0].Id,
            Cost_of_Sale__c = 0,
            PNR_number__c = '123456',
            Passenger_Name__c = 'Dummy User',
            First_Flight_Date__c = System.Today(),
            flight_itinerary__c = '12345678',
            Condition_Met__c = 'Yes'
        );
        CaseOthersTriggerHandler.onBeforeInsert(caseRecords, QUEUE_GROUPMAP,accountRelationShipListN);
    }
    
    @isTest static void testOnBeforeUpdate() {
        Map<Id, Case> oldCaseRecords = new Map<Id, Case>([ SELECT CaseNumber, Status, AccountId, RecordTypeId, EntitlementId, SlaStartDate, QL_Previous_Case_Owner__c, OwnerId, Reopened_Date__c, Article_Journey__c FROM Case WHERE Status != 'Closed' ]);
        Map<Id, Case> newCaseRecords = new Map<Id, Case>();
        /*for (Case caseRecord : oldCaseRecords.values()) {
            if (caseRecord.RecordTypeId == RTID_KNOWLEDGE_REQUEST) {
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Article_Journey__c=caseRecord.Article_Journey__c ));
            } else if (caseRecord.RecordTypeId == RTID_SERVICE_REQUEST) {
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Status='Reopened', AccountId=caseRecord.AccountId ));
            } else if (caseRecord.RecordTypeId == RTID_SALES_SUPPORT) { 
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Origin='SHR Sales Support', Status='Reopened'));
            }
        }*/
        for (Case caseRecord : oldCaseRecords.values()) {
            if (caseRecord.RecordTypeId == RTID_KNOWLEDGE_REQUEST) {
                //newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, Article_Journey__c=caseRecord.Article_Journey__c ));
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Article_Journey__c=caseRecord.Article_Journey__c ));
            } else if (caseRecord.RecordTypeId == RTID_SERVICE_REQUEST) {
                //newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, Status='Reopened' ));
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Status='Reopened', AccountId=caseRecord.AccountId ));
            } else if (caseRecord.RecordTypeId == RTID_SALES_SUPPORT) { 
                //newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, Origin='SHR Sales Support', Status='Reopened' ));
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Origin='SHR Sales Support', Status='Reopened'));
            }
        }
        //update newCaseRecords.values();
        CaseOthersTriggerHandler.beforeUpdate(newCaseRecords.values(), oldCaseRecords, USERMAP, QUEUE_GROUPMAP);
    }
    
    @isTest static void testAfterInsert() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE Name = 'Green Avenue Corp' ];
        List<Case> caseRecords = new Case[1];
        caseRecords[0] = new Case( 
            RecordTypeId = RTID_SERVICE_REQUEST, 
            Status = 'Open',
            Type = 'SBT',
            Problem_Type__c = 'Change Fee',
            Reason_for_Waiver__c = 'Compassionate',
            AccountId = accountRecords[0].Id,
            Cost_of_Sale__c = 0,
            PNR_number__c = '123456',
            Passenger_Name__c = 'Dummy User',
            First_Flight_Date__c = System.Today(),
            flight_itinerary__c = '12345678',
            Condition_Met__c = 'Yes',
            Origin = 'QAC Website'
        );
        insert caseRecords;
    }
    
    @isTest static void testOnAfterUpdate() {
        Map<Id, Case> oldCaseRecords = new Map<Id, Case>([ SELECT CaseNumber, Status, RecordTypeId, Origin,Created_by_Role__c, Latest_Status__c, Problem_Type__c FROM Case WHERE Status != 'Closed' ]);
        Map<Id, Case> newCaseRecords = new Map<Id, Case>();
        for (Case caseRecord : oldCaseRecords.values()) {
            /*if (caseRecord.RecordTypeId == RTID_DEALSUPPORT_REQUEST) {
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Status='Assigned - Deal Support - Deal Sheet' ));
            } else*/ if (caseRecord.RecordTypeId == RTID_SERVICE_REQUEST) {
                newCaseRecords.put(caseRecord.Id, new Case( Id=caseRecord.Id, RecordTypeId=caseRecord.RecordTypeId, Origin='QAC Website', Problem_Type__c=caseRecord.Problem_Type__c, QAC_Request_Country__c='AU', Service_Fee_Applies__c='Yes - Apply' ));
            }
            System.debug(caseRecord.Created_by_Role__c);
        }
		Map<Id, Affected_Passenger__c> affectedPassengerMap = CaseUtility.queryAffectedPassengers(newCaseRecords.keySet(), RTID_AFFPASS);
        Map<Id, Flight__c> flightMap = CaseUtility.queryFlights(newCaseRecords.keySet(), RTID_SRFLIGHT);
        Map<Id, WorkOrder> workOrderMap = CaseUtility.queryWorkOrders(newCaseRecords.keySet(), RTID_SRWORDER);        
        update newCaseRecords.values();
        //CaseOthersTriggerHandler.onAfterUpdate(newCaseRecords.values(), oldCaseRecords, QUEUE_GROUPMAP, flightMap, workOrderMap, affectedPassengerMap);
        System.debug([ SELECT Case.Status, MilestoneType.Name, CompletionDate FROM CaseMilestone ]);
    }
    
    @isTest static void testSendFareAttachments() {
        Map<Id, String> accountMap = new Map<Id, String>();
        Map<Id, Case> caseRecordsMap = new Map<Id, Case>([ SELECT Id, CaseNumber, AccountId, Account.Name FROM Case WHERE RecordTypeId = :RTID_DEALSUPPORT_REQUEST ]);        
        ContentVersion cv = new ContentVersion(
            Title = 'Rule_Doc 01',
            PathOnClient = 'SampleDoc.pdf',
            VersionData = Blob.valueOf('This is a sample text...'),
            IsMajorVersion = true
        );
        insert new List<ContentVersion> { cv };
        Id cdId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id ].ContentDocumentId;
        List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();
        for (Case caseRecord : caseRecordsMap.values()) {
            accountMap.put(caseRecord.Id, caseRecord.Account.Name);
            cdLinks.add(new ContentDocumentLink( LinkedEntityId=caseRecord.Id, ContentDocumentId=cdId, shareType='V' ));
        }
        insert cdLinks;
        CaseOthersTriggerHandler.sendFareAttachmentFromCase(caseRecordsMap, accountMap);
    }
    
    @isTest static void testScheduleNotification() {
        Case caseRecord = [ SELECT Id, Status, OwnerId FROM Case WHERE RecordtypeId = :RTID_DEALSUPPORT_REQUEST ];
        Group dealSupportQueue = [ SELECT Id FROM Group WHERE DeveloperName=:QUEUE_DEAL_SUPPORT_REQUEST AND Type='Queue' ];
        caseRecord.OwnerId = dealSupportQueue.Id;
        caseRecord.Status = 'On hold - Deal Load';
        update caseRecord;
    }
    
        static testMethod void testException1(){
            CaseOthersTriggerHandler.onBeforeInsert(null, null, null);
            CaseOthersTriggerHandler.beforeUpdate(null, null, null, null);
            CaseOthersTriggerHandler.afterInsert(null, null, null);
            CaseOthersTriggerHandler.scheduleChatterNotification(null, null, null, null);
            CaseOthersTriggerHandler.assignEntitlement(null, null);
            CaseOthersTriggerHandler.milestoneCompletion(null);
            CaseOthersTriggerHandler.sendFareAttachmentFromCase(null, null);
        }

}