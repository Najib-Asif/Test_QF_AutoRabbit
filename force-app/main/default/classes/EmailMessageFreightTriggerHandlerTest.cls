/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 04-26-2024
 * @last modified by  : Praveen Sampath
 * History            : Refactored the code by removing the system.debug and commented codes
*  Modified By        : Truong Nguyen (Capgemini), 26-Aug-2026
*  Desc               : Add coverage for PSV Change - SFRBACPSV-711 - EmailMessageFreightTriggerHandlerTest.cls
**/
@isTest
private class EmailMessageFreightTriggerHandlerTest {
    private static final Id RTID_ACCOUNT_FREIGHT = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Freight_Account').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    private static final Id RTID_QANTASFREIGHT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
    private static final String FRCSUAU_QUEUE_DEV = 'Freight_CSU_AU_Queue';
    private static final String FRCSSAU_QUEUE_DEV = 'Freight_CSS_AU_Queue';
    private static final String FRT_CLAIMS_QUEUE = 'Freight_Claims_Queue';
    private static final String SPL_MOVES_EMAIL = 'specialmoves@qantas.com.au';
    private static final Id RTID_CASE_FRTCLAIMS = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Claims').getRecordTypeId();
     private static final Id RTID_CASE_QFREIGHT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
     private static final Map<String, Map<String, Id>> BU_RECORDTYPEMAP =  CaseUtility.mapBUnitToCaseRecordTypes();
     private static final Map<String, Id> FREIGHT_RECORDTYPEMAP = BU_RECORDTYPEMAP.get('Freight');
     private static final Map<Id, Group> QUEUE_GROUPMAP = CaseUtility.queryQueueGroups();
     private static final Map<Id, Approval_Matrix__c> APPROVALMATRIX_MAP = CaseUtility.queryApprovalMatrices();
     private static final Map<Id, User> USERMAP = CaseUtility.queryUsers(new Set<Id>{ UserInfo.getUserId() }); 
    
    @testSetup static void createTestData() {
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        List<QantasConfigData__c> recConfig = new QantasConfigData__c[3];
        recConfig[0] = TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTSYDTracing', 'FRT SYD Tracing');
        recConfig[1] = TestUtilityDataClassQantas.createQantasConfigData('Queue_Freight_Freight_CSS_AU_Queue', 'Freight_CSS_AU_Queue');
        recConfig[2] = TestUtilityDataClassQantas.createQantasConfigData('FreightSubjecyKeywords', 'DELIVERIES DELIVERY MISSING MAPPING');
        
        insert recConfig;
        
        List<Trigger_Status__c> triggerStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        triggerStatus.addAll(TestUtilityDataClassQantas.createEmailMessageTriggerSetting());
        insert triggerStatus;
        
        Map<String, Id> queueNameIdMap = new Map<string, Id>();
        for (Group groupRec : [ SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' ])
        {
            queueNameIdMap.put(groupRec.DeveloperName, groupRec.Id);
        }
        
        Group claimsQueue = [ SELECT Id, DeveloperName FROM Group WHERE Type='Queue' AND DeveloperName='Freight_Claims_Queue' LIMIT 1 ];
        Group auCSUQueue = [ SELECT Id, DeveloperName FROM Group WHERE Type='Queue' AND DeveloperName='Freight_CSU_AU_Queue' LIMIT 1 ];
        Group frtSalesQueue = [ SELECT Id, DeveloperName FROM Group WHERE Type='Queue' AND DeveloperName='Freight_Sales_Support_AU_Queue' LIMIT 1 ];
        
        List<Account> accountRecords = new Account[4];
        accountRecords[0] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            Name = 'Green Camp Corp[Freight-SYD-AU]',
            BillingCountry = 'AU',
            Email__c = 'info@greencamp.com.au'
        );
        accountRecords[1] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            Name = 'Green Cord Corp[Freight-PER-AU]',
            BillingCountry = 'AU',
            Email__c = 'infocorp@greencord.com.au'
        );
        accountRecords[2] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            Name = 'Green Avenue Corp[Freight-BNE-AU]',
            BillingCountry = 'AU',
            Email__c = 'greeninfo@greenavenue.com.au'
        );
        accountRecords[3] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            Name = 'Green Trees Corp[Freight-MEL-AU]',
            BillingCountry = 'AU',
            Email__c = 'corptrees@greentrees.com'
        );
        insert accountRecords;
        
        List<Contact> contactRecords = new Contact[5];
        contactRecords[0] = new Contact(
            RecordTypeId = RTID_CONTACT_CONTACT,
            FirstName = 'Yellow',
            LastName = 'Trees',
            Email = 'yellowtrees@greencamp.com.au',
            AccountId = accountRecords[1].Id
        );
        contactRecords[1] = new Contact(
            RecordTypeId = RTID_CONTACT_CONTACT,
            FirstName = 'Green',
            LastName = 'Trees',
            Email = 'greentrees@greencord.com.au',
            AccountId = accountRecords[1].Id
        );
        contactRecords[2] = new Contact(
            RecordTypeId = RTID_CONTACT_CONTACT,
            FirstName = 'Red',
            LastName = 'Avenue',
            Email = 'redavenue@greenavenue.com.au',
            AccountId = accountRecords[2].Id
        );
        contactRecords[3] = new Contact(
            RecordTypeId = RTID_CONTACT_CONTACT,
            FirstName = 'One',
            LastName = 'Three',
            Email = 'onethree@greentrees.com',
            AccountId = accountRecords[3].Id
        );
        contactRecords[4] = new Contact(
            RecordTypeId = RTID_CONTACT_CONTACT,
            FirstName = 'Five',
            LastName = 'Four',
            Email = 'fivefour@greentrees.com',
            AccountId = accountRecords[3].Id
        );
        insert contactRecords;
        
        List<Airport_Code__c> airportCodes = new Airport_Code__c[6];
        airportCodes[0] = new Airport_Code__c (Name='BNE', QF_Freight_Presence__c=true);
        airportCodes[1] = new Airport_Code__c (Name='BHQ', QF_Freight_Presence__c=true);
        airportCodes[2] = new Airport_Code__c (Name='ABX', QF_Freight_Presence__c=true);
        airportCodes[3] = new Airport_Code__c (Name='ALH', QF_Freight_Presence__c=true);
        airportCodes[4] = new Airport_Code__c (Name='ARM', QF_Freight_Presence__c=true);
        airportCodes[5] = new Airport_Code__c (Name='ASP', QF_Freight_Presence__c=true);
        insert airportCodes;       
        List<Case> caseRecords = new Case[8];
        caseRecords[0] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Cust Service',
            Status = 'Open',
            Subject = 'Test Case 10',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp',
            OwnerId = queueNameIdMap.get(FRCSUAU_QUEUE_DEV)
        );
        caseRecords[1] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Bookings',
            Status = 'Open',
            Subject = 'Test Case 11',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[2] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Bookings',
            Status = 'Closed',
            Subject = 'Test Case 11',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[3] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Cust Service',
            Status = 'On hold',
            Subject = 'Test Case 12',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[4] = new Case( 
            RecordTypeId = RTID_CASE_FRTCLAIMS, 
            Origin = 'Web',
            Status = 'New',
            Subject = 'Test Case 12',
            Description = 'This is for testing. My credit card number is 123 45678 9234 5679.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenTrees@fedex.com',
            SuppliedCompany = 'Green Trees Corp'
        );
        caseRecords[5] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Claims',
            Status = 'On hold',
            Subject = 'Test Case 13',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp',
      OwnerId = claimsQueue.Id
        );
        caseRecords[6] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Spl Moves',
            Status = 'On hold',
            Subject = 'Test Case 14',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp',
      OwnerId = auCSUQueue.Id
        );
        caseRecords[7] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Sales Support',
            Status = 'On hold',
            Subject = 'Test Case 14',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp',
      OwnerId = frtSalesQueue.Id
        ); 
        insert caseRecords;

        // SFRBACPSV-711: Add coverage for PSV Change
        Map<String, Profile> profileMap = TestUtilityDataClassQantas.getProfileMap();
        User noAccessUser = new User(
            Username = 'sfrbacpsv711.noaccess@qftest.com',
            Email = 'sfrbacpsv711.noaccess@qantas.com.au',
            LastName = 'NoAccess',
            FirstName = 'SFRBACPSV711',
            Alias = 'psv711',
            ProfileId = profileMap.get('Standard Platform User').Id,
            TimeZoneSidKey = 'Australia/Sydney',
            LocaleSidKey = 'en_AU',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert noAccessUser;

        // SFRBACPSV-711: Add coverage for PSV Change
        User minimumAccessUser = new User(
            Username = 'sfrbacpsv711.minaccess@qftest.com',
            Email = 'sfrbacpsv711.minaccess@qantas.com.au',
            LastName = 'MinAccess',
            FirstName = 'SFRBACPSV711',
            Alias = 'psv711b',
            ProfileId = profileMap.get('QL_Sales').Id,
            TimeZoneSidKey = 'Australia/Sydney',
            LocaleSidKey = 'en_AU',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert minimumAccessUser;
    }

    // SFRBACPSV-711: Add coverage for PSV Change
    private static User getNoAccessUser() {
        return [SELECT Id FROM User WHERE Username = 'sfrbacpsv711.noaccess@qftest.com' LIMIT 1];
    }

    // SFRBACPSV-711: Add coverage for PSV Change
    private static User getMinimumAccessUser() {
        return [SELECT Id FROM User WHERE Username = 'sfrbacpsv711.minaccess@qftest.com' LIMIT 1];
    }

    @isTest static void testOnBeforeInsert() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'ABX' LIMIT 1 ];
        
        List<Case> caseRecords = [ SELECT Id, Origin, Status, Subject, AccountId, Description FROM Case ];
        Map<Id, Case> caseRecordMap = new Map<Id, Case>{ caseRecords[0].Id => caseRecords[0] };
        List<EmailMessage> emailRecords = new EmailMessage[1];
        emailRecords[0] = new EmailMessage(
            FromAddress='FromEmailRecord@qantas.com.au',
            To_Address__c='ToEmailRecord@qantas.com.au',
            HtmlBody='This is an email for test class',
            Textbody='Sample Message',
            MessageDate=system.now(),
            ParentId=caseRecords[0].Id,
            Subject='Qantas Freight Customer Support – Ref No ' , 
            RelatedToId =caseRecords[0].Id
        );
        
       
        EmailMessageFreightTriggerHandler.onBeforeInsert(emailRecords, caseRecordMap);
        for (Case caseRecord : caseRecords) {
            System.debug(caseRecord.Subject + ' - ' + caseRecord.AccountId + ' - ' + caseRecord.Description);
        }
    }
    
    @isTest static void testOnAfterInsert() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'ABX' LIMIT 1 ];
        
        List<Case> caseRecords = [ SELECT Id, CaseNumber, Origin, Status, Priority, Subject, AccountId, Description, RecordTypeId, OwnerName__c FROM Case ];
        Map<Id, Case> caseRecordMap = new Map<Id, Case>();
        Set<Id> accountIds = new Set<Id>();
        for (Case record : caseRecords) {
            caseRecordMap.put(record.Id, record);
            accountIds.add(record.AccountId);
        }
        List<EmailMessage> emailRecords = new EmailMessage[8];
        for (Integer i = 0; i < 8; i++) {
            emailRecords[i] = new EmailMessage(
                FromAddress='FromEmailRecord@qantas.com.au',
                To_Address__c='ToEmailRecord@qantas.com.au',
                HtmlBody='This is an email for test class',
                Textbody='Sample Message',
                MessageDate=system.now(),
                ParentId=caseRecords[i].Id,
                Subject='Qantas Freight Customer Support – Ref No ' + caseRecords[i].CaseNumber , 
                RelatedToId =caseRecords[i].Id,
        Incoming = true
            );
        }
        emailRecords[0].Status = '0';
        emailRecords[1].Status = '1';
        emailRecords[2].Status = '3';
        emailRecords[2].IsBounced = true;
        emailRecords[2].Incoming = true;
        emailRecords[3].ToAddress = 'freightinvoices@qantas.com.au; freightcustomerservice@qantas.com.au';
        emailRecords[3].Status = '1';
        Map<String, Id> caseQueueMap = new Map<String, Id>();
        for (Group record : QUEUE_GROUPMAP.values()) {
            caseQueueMap.put(record.DeveloperName, record.Id);
        }
        
        EmailMessageFreightTriggerHandler.afterInsert(emailRecords, caseRecordMap, accountIds, new Set<Id> { UserInfo.getUserId() }, caseQueueMap, new Set<String>{ 'qantas.com.au' });
    }
    
    @isTest static void testAfterUpdate() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'ABX' LIMIT 1 ];
        
        List<Case> caseRecords = [ SELECT Id, CaseNumber, Origin, Status, Priority, Subject, AccountId, Description, RecordTypeId, OwnerName__c FROM Case ];
        Map<Id, Case> caseRecordMap = new Map<Id, Case>();
        Set<Id> accountIds = new Set<Id>();
        for (Case record : caseRecords) {
            caseRecordMap.put(record.Id, record);
        }
        List<EmailMessage> emailRecords = new EmailMessage[8];
        for (Integer i = 0; i < 8; i++) {
            emailRecords[i] = new EmailMessage(
                FromAddress='FromEmailRecord@qantas.com.au',
                To_Address__c='ToEmailRecord@qantas.com.au',
                HtmlBody='This is an email for test class',
                Textbody='Sample Message',
                MessageDate=system.now(),
                ParentId=caseRecords[i].Id,
                Subject='Qantas Freight Customer Support – Ref No ' + caseRecords[i].CaseNumber , 
                RelatedToId =caseRecords[i].Id
            );
        }
        emailRecords[0].Status = '0';
        emailRecords[1].Status = '1';
        emailRecords[2].Status = '3';
        emailRecords[2].IsBounced = true;
        emailRecords[2].Incoming = true;
        emailRecords[3].ToAddress = 'freightinvoices@qantas.com.au; freightcustomerservice@qantas.com.au';
        emailRecords[3].Status = '1';
        emailRecords[3].IsBounced = true;
        insert emailRecords;
        EmailMessageFreightTriggerHandler.afterUpdate(emailRecords, caseRecordMap, new Set<Id> { UserInfo.getUserId() });
    }

    @isTest static void testOnAfterUpdatev2() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'ABX' LIMIT 1 ];
        
        List<Case> caseRecords = [ SELECT Id, CaseNumber, Origin, Status, Priority, Subject, AccountId, Description, RecordTypeId, OwnerName__c FROM Case ];
        Map<Id, Case> caseRecordMap = new Map<Id, Case>();
        Set<Id> accountIds = new Set<Id>();
        for (Case record : caseRecords) {
            caseRecordMap.put(record.Id, record);
        }
        List<EmailMessage> emailRecords = new EmailMessage[8];
        for (Integer i = 0; i < 8; i++) {
            emailRecords[i] = new EmailMessage(
                FromAddress='FromEmailRecord@qantas.com.au',
                To_Address__c='ToEmailRecord@qantas.com.au',
                HtmlBody='This is an email for test class',
                Textbody='Sample Message',
                MessageDate=system.now(),
                ParentId=caseRecords[i].Id,
                Subject='Qantas Freight Customer Support – Ref No ' + caseRecords[i].CaseNumber , 
                RelatedToId =caseRecords[i].Id
            );
        }
        emailRecords[0].Status = '0';
        emailRecords[1].Status = '1';
        emailRecords[2].Status = '3';
        emailRecords[2].Incoming = true;
        emailRecords[3].ToAddress = 'freightinvoices@qantas.com.au; freightcustomerservice@qantas.com.au';
        emailRecords[3].Status = '1';
        emailRecords[3].IsBounced = true;
        insert emailRecords;
        
        EmailMessageFreightTriggerHandler.afterUpdate(emailRecords, caseRecordMap, new Set<Id>{ UserInfo.getUserId() });
    }
    
    @isTest static void testClosedCase(){
        Test.startTest();
        Trigger_Status__c cTStatus = Trigger_Status__c.getValues('CaseTriggerV2');
        cTStatus.Active__c = false;
        update cTStatus;
        //Insert Case Origin
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_Webchat', 'Webchat')); 
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTBookings', 'FRT Bookings')); 
        insert lstConfigData;
        
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'ABX' LIMIT 1 ];
        
        List<Case> caseRecords = [ SELECT Id, CaseNumber, Origin, Status, Priority, Subject, AccountId, Description, RecordTypeId, OwnerName__c, OwnerId FROM Case LIMIT 1];
        
        //Insert Close Case
        String caseJSON = '{"attributes":{"type":"CasSe","url":"/services/data/v60.0/sobjects/Case"},';
        caseJSON += '"Status":"Closed","CreatedDate":"2012-10-04T17:54:26.000+0000", "ClosedDate":"2012-11-04T17:54:26.000+0000",';
        caseJSON += '"RecordTypeId":"'+ RTID_CASE_QFREIGHT +'","Origin":"'+ CustomSettingsUtilities.getConfigDataMap('CaseOrigin_FRTBookings') +'", "Subject":"Test Case 14", "Description":"This is for testing.",';
        caseJSON += '"Freight_Port__c":"'+ airportCodeRecord.Id +'","SuppliedEmail":"greenavenue@qantas.com.au", "SuppliedCompany":"Green Avenue Corp", "OwnerId":"'+CaseRecords[0].OwnerId+'"';
        //caseJSON += '",AccountId":"'+ accountRecords[0].Id +'"';
        caseJSON += '}'; 
        
        Case closedCase = (Case) JSON.deserialize(caseJSON, Case.class); 
        insert closedCase;
        
        Map<Id, Case> caseRecordMap = new Map<Id, Case>();
        Set<Id> accountIds = new Set<Id>();
        caseRecordMap.put(closedCase.Id, closedCase);
        accountIds.add(closedCase.AccountId);
        
        List<EmailMessage> emailRecords = new EmailMessage[1];
        for (Integer i = 0; i < 1; i++) {
            emailRecords[i] = new EmailMessage(
                FromAddress='FromEmailRecord@qantas.com.au',
                To_Address__c='ToEmailRecord@qantas.com.au',
                HtmlBody='This is an email for test class',
                Textbody='Sample Message',
                MessageDate=system.now(),
                ParentId=closedCase.Id,
                Subject='Qantas Freight Customer Support – Ref No ' + closedCase.CaseNumber , 
                RelatedToId =closedCase.Id,
                Incoming = true
            );
        }
     
       insert emailRecords;
        
        Test.stopTest();
        Map<String, Id> caseQueueMap = new Map<String, Id>();
        
        for (Group record : QUEUE_GROUPMAP.values()) {
            caseQueueMap.put(record.DeveloperName, record.Id);
        }
        
        EmailMessageFreightTriggerHandler.afterInsert(emailRecords, caseRecordMap, accountIds, new Set<Id> { UserInfo.getUserId() }, caseQueueMap, new Set<String>{ 'qantas.com.au' });
} 
    @isTest static void testFreightUpdateCase1() {
        Id queueId = [ SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName = :FRCSSAU_QUEUE_DEV LIMIT 1 ].Id;
        Case caseRecord = new Case(
            Origin = 'FRT SYD Tracing',
            Subject = 'Test 1 MISSING',
            Description = 'Testing 123',
            SuppliedEmail = 'testingone@testone.com.au',
            OwnerId = queueId
        );
        insert caseRecord;
        EmailMessage emRecord = new EmailMessage(
            FromAddress = caseRecord.SuppliedEmail,
            Subject = caseRecord.Subject,
            TextBody = caseRecord.Description,
            ToAddress = 'freightcustomerservice@qantas.com.au',
            ParentId = caseRecord.Id
        );
        insert emRecord;
        Case caseRec = [ SELECT OwnerName__c, Origin FROM Case WHERE Id = :caseRecord.Id LIMIT 1 ];    
        EmailMessageFreightTriggerHandler.freightUpdateCase(emrecord, caseRec);
    }
    
    @isTest static void testFailures() {
        EmailMessageFreightTriggerHandler.onBeforeInsert(null, null);
        EmailMessageFreightTriggerHandler.freightUpdateCase(null, null);
        EmailMessageFreightTriggerHandler.afterInsert(null, null, null, null, null, null);
        EmailMessageFreightTriggerHandler.assignUrgentPriorityForCasesWithHotWords(null, null, null);
        EmailMessageFreightTriggerHandler.freightLevelUpCasePriority(null);
    }
    

    private static EmailMessage getTestEmail(String subject) {
        EmailMessage em = new EmailMessage(
            FromName    = 'Test User',
            FromAddress = 'test.user@test.com',
            Subject     = subject,
            TextBody    = 'This is a test email body'
        );
        return em;
    }

    private static Case getFreightClaimsCase() {
         Id queueId = [ SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName = :FRT_CLAIMS_QUEUE LIMIT 1 ].Id;
        Case c = new Case(
            Origin = 'FRT Claims',
            Subject = 'CCA Request MAWB 618-12345678 MEL',
            Description = 'Testing 123',
            SuppliedEmail = 'testingone@testone.com.au',
            Freight_AWB_Number__c = '618-12345678',
            Type = 'Claims',
            OwnerId = queueId
        );
        insert c;
        EmailMessage emRecord = new EmailMessage(
            FromAddress = c.SuppliedEmail,
            Subject = c.Subject,
            TextBody = c.Description,
            ToAddress = 'freightcustomerservice@qantas.com.au',
            ParentId = c.Id
        );
        insert emRecord;
        Case caseRec = [ SELECT OwnerName__c, Origin FROM Case WHERE Id = :c.Id LIMIT 1 ];  
        EmailMessage eMsg = [ SELECT Subject, FromAddress FROM EmailMessage WHERE Id = :emRecord.Id LIMIT 1 ]; 
  @TestVisible
 final String CASE_ORIGIN_FRT_CLAIMS = 'Freight Claims';      
        c.Origin       = CASE_ORIGIN_FRT_CLAIMS;
        return c;
    }

    /* ============================
       Test 1: Valid AWB Extraction
       ============================ */
    @IsTest
    static void testFreightClaims_WithValidAWB() {

       
		
EmailMessage emailMsg = getTestEmail(
            'CCA Request MAWB 618-12345678 MEL'
        );

        Case c = getFreightClaimsCase();
        


        // WHEN
        Test.startTest();
        c = EmailMessageFreightTriggerHandler.freightUpdateCase(emailMsg, c);
        system.debug('AWB:'+c.Freight_AWB_Number__c);
        Test.stopTest();

        // THEN
        System.assertEquals(
            '618-12345678',
            c.Freight_AWB_Number__c,
            'AWB should be extracted and set'
        );

@TestVisible
 final String CASE_ORIGIN_FRT_CLAIMS = 'FRT Claims';

        System.assertEquals(
            'Claims',
            c.Type,
            'Case Type should be Claims'
        );

    }

    // SFRBACPSV-711: Add coverage for PSV Change
    @isTest
    static void userNoAccessTest() {

        User noAccessUser = getNoAccessUser();

        Case c = [SELECT Id, CaseNumber FROM Case LIMIT 1];
        EmailMessage em = new EmailMessage(
            FromAddress = 'test@test.com',
            To_Address__c = 'receiver@test.com',
            Subject = 'Test No Access',
            TextBody = 'Test body',
            ParentId = c.Id,
            RelatedToId = c.Id,
            MessageDate = System.now(),
            Incoming = true
        );

        List<EmailMessage> emailList = new List<EmailMessage>{ em };
        Map<Id, Case> caseMap = new Map<Id, Case>{ c.Id => c };

        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>{ UserInfo.getUserId() };

        Map<String, Id> caseQueueMap = new Map<String, Id>();
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
            caseQueueMap.put(g.DeveloperName, g.Id);
        }

        Case resultCase;
        Test.startTest();
        System.runAs(noAccessUser) {
            EmailMessageFreightTriggerHandler.onBeforeInsert(emailList, caseMap);
            EmailMessageFreightTriggerHandler.afterInsert(
                emailList,
                caseMap,
                accountIds,
                userIds,
                caseQueueMap,
                new Set<String>{ 'qantas.com.au' }
            );

            EmailMessageFreightTriggerHandler.afterUpdate(
                emailList,
                caseMap,
                userIds
            );

            resultCase = EmailMessageFreightTriggerHandler.freightUpdateCase(em, c);
        }
        Test.stopTest();

        System.assertNotEquals(null, resultCase, 'freightUpdateCase should return gracefully for a restricted-access user');
    }

    // SFRBACPSV-711: Add coverage for PSV Change
    @isTest
    static void fetchAccountsQueryExceptionTest() {
        User minimumAccessUser = getMinimumAccessUser();

        Boolean exceptionCaught = false; 
        Test.startTest();
        System.runAs(minimumAccessUser) {
            try {
                EmailMessageFreightTriggerHandler.fetchAccounts(new Set<String>{ 'qantas.com.au' });
            } catch (Exception e) {
                exceptionCaught = true;
            }
        }
        Test.stopTest();
        System.assert(!exceptionCaught, 'Expected no Exception');
    }

}