@isTest
private class LoyaltyCaseStreamQueueTest {
    private static final Id RTID_CASE_INSURANCELETTER = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('QCC_Insurance_Letter_Case').getRecordTypeId();
    private static final Id RTID_CASE_DEALSUPPORT = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Support_request').getRecordTypeId();
    private static final Id RTID_CASE_ACCOUNTMAINTENANCE = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Account_Maintenance').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    private static final Id RTID_ACCOUNT_AGENCY = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
    
    @testSetup static void createTestData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        Account accountRecord = new Account(
            RecordTypeId = RTID_ACCOUNT_AGENCY,
            BillingCountry = 'AU',
            Email__c = 'greenavenue@qantas.com.au',
            Name = 'Green Avenue Corp'
        );
        insert new List<Account>{ accountRecord };
        Contact contactRecord = new Contact(
            FirstName = 'Green',
            LastName = 'Garden',
            Email = 'greenavenue@qantas.com.au',
            AccountId = accountRecord.Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        insert new List<Contact>{ contactRecord };
            
        List<Case> caseRecords = new Case[1];
        caseRecords[0] = TestUtilityDataClassQantas.createCaseWithCodingValues('QCC Elite Process', 'Welcome to SSU', '', '', '', '');
        caseRecords[0].Description = 'Sample text';
        caseRecords[0].ContactId = contactRecord.Id;
        caseRecords[0].Assign_using_active_assignment_rules__c = true;
        insert caseRecords;
    }
    
    @isTest static void testLoyaltyCaseStreamQueue() {
        List<Contact> contactRecords = [ SELECT Id FROM Contact ];
        List<Case> caseRecords = [ SELECT Id, Status, Type FROM Case ];
        Test.startTest();
        System.enqueueJob(new LoyaltyCaseStreamQueue(caseRecords, null));
        Test.stopTest();
        caseRecords = [ SELECT Id, Status, Type FROM Case ];
        System.assertEquals(caseRecords[0].Status, 'New');
    }

    
    @isTest static void testLoyaltyCaseStreamQueue1() {
        List<Contact> contactRecords = [ SELECT Id FROM Contact ];
        List<Case> caseRecords = [ SELECT Id, Status, Type FROM Case ];
        caseRecords[0].Status = 'Closed';
        update caseRecords;
        Test.startTest();
        System.enqueueJob(new LoyaltyCaseStreamQueue(caseRecords, null));
        Test.stopTest();
        caseRecords = [ SELECT Id, Status, Type FROM Case ];
        System.assertEquals(caseRecords[0].Status, 'Closed');
    }
}