@isTest
private class CaseUtilityTest {
    
    private static final Id RTID_ACCOUNT_AGENCY = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    //private static final Id RTID_CASE_QFREIGHT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
    private static final Id RTID_SERVICE_REQUEST = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('QIC_Service_request').getRecordTypeId();
    //private static final Id RTID_KNOWLEDGE_REQUEST = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Knowledge_Request').getRecordTypeId();
    private static final String RTID_SRFLIGHT = Schema.SObjectType.Flight__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final String RTID_SRWORDER = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    private static final String RTID_AFFPASS = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    
    @testSetup static void createTestData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
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
        
        
        List<Case> caseRecords = new Case[1];
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
        insert caseRecords;
    }
    
    @isTest static void testNonParameterizedMethods() {
        CaseUtility.caseRecordType();
        CaseUtility.mapQCCRecordTypes();
        CaseUtility.mapBUnitToCaseRecordTypes();
        CaseUtility.queryQueueGroups();
        CaseUtility.getQualtrics();
        //CaseUtility.getDyanamicUrlForFreightLogo();
        CaseUtility.queryAccounts();
        CaseUtility.queryApprovalMatrices();
        CaseUtility.qccCaseRecordTypeIds();
    }
    
    @isTest static void testParameterizedMethods() {
        Set<String> emailIds = new Set<String>{ 'greenavenue@qantas.com.au' };
        Map<Id, Account> accountRecordMap = new Map<Id, Account>([ SELECT Id, Name FROM Account ]);
        Map<Id, Case> caseRecordMap = new Map<Id, Case>([ SELECT Id, CaseNumber FROM Case ]);
        CaseUtility.caseRecordTypeId('Qantas Freight');
        CaseUtility.getRecordTypeIdByDevName('QCC_Insurance_Letter_Case');
        //CaseUtility.getQueueIdByDevName();
        CaseUtility.maskCreditCardAndUATPCardNumbers('This is a sample text. My credit card number is 9087 3456 2345 1234.');
        CaseUtility.maskCreditCardAndUATPCardNumbers('This is a sample text. My uatp card number is 908 734562345124');
        CaseUtility.queryAffectedPassengers(caseRecordMap.keySet(), RTID_AFFPASS);
        CaseUtility.queryFlights(caseRecordMap.keySet(), RTID_SRFLIGHT);
        CaseUtility.queryWorkOrders(caseRecordMap.keySet(), RTID_SRWORDER);  
        Map<Id, User> userRecordMap = CaseUtility.queryUsers(new Set<Id>{ UserInfo.getUserId() });
        CaseUtility.queryAccounts(accountRecordMap.keySet());
        CaseUtility.fetchUserIdByName(userRecordMap, UserInfo.getUserName());
        CaseUtility.getCCATUserIds(userRecordMap);
        CaseUtility.getResolutionConsultantIds(userRecordMap);
        Map<Id, Group> queueGroup = CaseUtility.queryQueueGroups();
        Id groupId = CaseUtility.getQueueIdByDevName(queueGroup, 'Account_Review_Queue');
        CaseUtility.queryGroups(new Set<Id>{ groupId });
        CaseUtility.queryContacts(RTID_CONTACT_CONTACT, emailIds);
        CaseUtility.queryAccounts(RTID_ACCOUNT_AGENCY, accountRecordMap.keySet());
        CaseUtility.getAssignmentRuleId('');
        CaseUtility.getDomainFromEmailField('greenavenue@qantas.com.au');
    }
    
    @isTest static void testExceptions() {
        try {
            Map<Id, Account> accountRecordMap = new Map<Id, Account>();
            Map<Id, Case> caseRecordMap = new Map<Id, Case>();
            CaseUtility.caseRecordTypeId('');
            CaseUtility.getRecordTypeIdByDevName('');
            //CaseUtility.getQueueIdByDevName();
            CaseUtility.queryAffectedPassengers(caseRecordMap.keySet(), RTID_AFFPASS);
            CaseUtility.queryFlights(caseRecordMap.keySet(), RTID_SRFLIGHT);
            CaseUtility.queryWorkOrders(caseRecordMap.keySet(), RTID_SRWORDER);  
            Map<Id, User> userRecordMap = CaseUtility.queryUsers(new Set<Id>());
            CaseUtility.queryAccounts(accountRecordMap.keySet());
            CaseUtility.fetchUserIdByName(userRecordMap, '');
            CaseUtility.getCCATUserIds(userRecordMap);
            Map<Id, Group> queueGroup = CaseUtility.queryQueueGroups();
            Id groupId = CaseUtility.getQueueIdByDevName(queueGroup, '');
            CaseUtility.queryGroups(new Set<Id>());
            CaseUtility.queryContacts(RTID_CONTACT_CONTACT, new Set<String>());
            CaseUtility.queryAccounts(RTID_ACCOUNT_AGENCY, accountRecordMap.keySet());
        } catch (Exception ex) {
            
        }
    }
}