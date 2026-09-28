@isTest
private class EmailMessageOthersTriggerHandlerTest {
    
    private static final Id RTID_ACCOUNT_AGENCY = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
    private static final Id RTID_QDPPORTALSUPPORT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QAC_Contact_Us_Support').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    private static final Id RTID_TICKETINGAUTHORITY = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticketing_Authority').getRecordTypeId();
    private static final Id RTID_SHRQISSS = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('SHR_QIS_Sales_Support').getRecordTypeId();
    private static final Id RTID_CASE_QFREIGHT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
    private static final Map<String, Map<String, Id>> BU_RECORDTYPEMAP =  CaseUtility.mapBUnitToCaseRecordTypes();
    private static final Map<String, Id> FREIGHT_RECORDTYPEMAP = BU_RECORDTYPEMAP.get('Freight');
    private static final Map<Id, Group> QUEUE_GROUPMAP = CaseUtility.queryQueueGroups();
    private static final Map<Id, Approval_Matrix__c> APPROVALMATRIX_MAP = CaseUtility.queryApprovalMatrices();
    private static final Map<Id, User> USERMAP = CaseUtility.queryUsers(new Set<Id>{ UserInfo.getUserId() });
    private static final Id RTID_SQACSG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SHR_Qantas_Agency_Connect_SG').getRecordTypeId();
    private static final Id RTID_PERSON = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account').getRecordTypeId();
    private static final String EMAILADDRESS = CustomSettingsUtilities.getConfigDataMap('EmailAddress_EmployeeComm');
    
    @testSetup static void createTestData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Account> accountRecords = new Account[3];
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
        accountRecords[2] = new Account(
            RecordTypeId = RTID_PERSON,
            BillingCountry = 'AU',
            Email__c = 'greenavenue@qantas1.com.au',
            Name = 'Test User 01'
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
            RecordTypeId = RTID_TICKETINGAUTHORITY, 
            Risk__c = 'Low',
            Date_Effective_DAT__c = System.today(),
            Status = 'On Hold'
        );
        caseRecords[1] = new Case( 
            RecordTypeId = RTID_QDPPORTALSUPPORT, 
            Status = 'On Hold'
        );
        caseRecords[2] = new Case( 
            OwnerId = '00G90000003955e',
            Priority = 'Medium',
            Origin = 'SHR QIS Sales Support',
			RecordTypeId = RTID_SHRQISSS
        );
        caseRecords[3] = new Case( 
            RecordTypeId = RTID_QDPPORTALSUPPORT, 
            Status = 'Resolved'
        );
        caseRecords[4] = new Case( 
            RecordTypeId = RTID_QDPPORTALSUPPORT, 
            Status = 'On Hold'
        );
        caseRecords[5] = new Case( 
            RecordTypeId = RTID_SQACSG, 
            Status = 'New',
            AccountId = accountRecords[2].Id 
        );
        insert caseRecords;
    }
    
    @isTest static void testAfterInsert() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact ];
        List<Case> caseRecords = [ SELECT Id, CaseNumber, Origin, Status, Priority, Subject, AccountId, IsClosed, Description, RecordTypeId, RecordType.DeveloperName, OwnerName__c FROM Case ];
        Map<Id, Case> caseRecordMap = new Map<Id, Case>();
        Set<Id> accountIds = new Set<Id>();
        for (Case record : caseRecords) {
            caseRecordMap.put(record.Id, record);
            accountIds.add(record.AccountId);
        }
        List<EmailMessage> emailRecords = new List<EmailMessage>();
        for (Integer i = 0; i < 6; i++) {
            emailRecords.add(new EmailMessage(
                FromAddress=EMAILADDRESS,
                To_Address__c='ToEmailRecord@qantas.com.au',
                ToAddress='ToEmailRecord@qantas.com.au',
                HtmlBody='This is an email for test class',
                Textbody='Sample Message',
                MessageDate=system.now(),
                Incoming = true,
                ParentId=caseRecords[i].Id,
                Subject='Qantas Freight Customer Support – Ref No ' + caseRecords[i].CaseNumber , 
                RelatedToId =caseRecords[i].Id
            ));
        }
        Map<String, Id> caseQueueMap = new Map<String, Id>();
        for (Group record : QUEUE_GROUPMAP.values()) {
            caseQueueMap.put(record.DeveloperName, record.Id);
        }
        EmailMessageOthersTriggerHandler.afterInsert(emailRecords, caseRecordMap, caseQueueMap, new Set<Id>());
    }
    
    @isTest static void testAfterInsert1() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact ];
        List<Case> caseRecords = [ SELECT Id, CaseNumber, Origin, Status, Priority, Subject, AccountId, IsClosed, Description, RecordTypeId, RecordType.DeveloperName, OwnerName__c FROM Case ];
        Map<Id, Case> caseRecordMap = new Map<Id, Case>();
        Set<Id> accountIds = new Set<Id>();
        for (Case record : caseRecords) {
            caseRecordMap.put(record.Id, record);
            accountIds.add(record.AccountId);
        }
        List<EmailMessage> emailRecords = new List<EmailMessage>();
        for (Integer i = 0; i < 6; i++) {
            emailRecords.add(new EmailMessage(
                FromAddress='employeecomm@qantas.com.au',
                To_Address__c='sinagencyconnect@qantas.com.au',
                ToAddress = 'sinagencyconnect@qantas.com.au',
                HtmlBody='This is an email for test class',
                Textbody='Sample Message',
                MessageDate=system.now(),
                Incoming = true,
                ParentId=caseRecords[i].Id,
                Subject='Qantas Freight Customer Support – Ref No ' + caseRecords[i].CaseNumber , 
                RelatedToId =caseRecords[i].Id
            ));
        }
        
        Map<String, Id> caseQueueMap = new Map<String, Id>();
        for (Group record : QUEUE_GROUPMAP.values()) {
            caseQueueMap.put(record.DeveloperName, record.Id);
        }
        EmailMessageOthersTriggerHandler.afterInsert(emailRecords, caseRecordMap, caseQueueMap, accountIds);
		
    }
	
    @isTest static void testMethod01() {
        Case testCase = [ SELECT Id FROM Case WHERE RecordTypeId = :RTID_SHRQISSS LIMIT 1];
        
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'employeecomm@qantas.com.au';
        email.Incoming = true;
        email.ToAddress = 'qissalessupport@qantas.com.au';
        email.Subject = 'Testing 01';
        email.TextBody = 'Test Email';
        email.ParentId = testCase.Id;
        //insert email;
        Test.startTest();
        for (Database.SaveResult result : Database.insert(new List<EmailMessage> { email }, false)) {
            if (!result.isSuccess()){
                for (Database.Error err : result.getErrors()){
                    System.debug(' Error ******** ' + err);
                }
            }
        }
    }
    
    @isTest static void testMethod02() {
        Case testCase = [ SELECT Id FROM Case WHERE RecordTypeId = :RTID_SHRQISSS LIMIT 1];
        Test.startTest();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'qissalessupport@331n1ngz2efkbz53greb51p0uo2d78cm08i1rjuanytssr0q09.92-3ol17eae.aus36s.case.sandbox.salesforce.com' });
        email.setSubject('Testing 01');
        email.setHtmlBody('Test Email');
        email.setWhatId(testCase.Id);
        //insert email;
        for (Messaging.SendEmailResult result : Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email})) 
        {
            if (result.isSuccess()) {
                System.debug('result - ' + String.valueOf(result));
                System.debug(String.valueOf([SELECT Id, ParentId FROM EmailMessage]));
            }
            if (!result.isSuccess()){
                for (Database.Error err : result.getErrors()){
                    System.debug(' Error ******** ' + err);
                }
            }
        }
    }
}