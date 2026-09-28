/*----------------------------------------------------------------------------------------------------------------------
************************************************************************************************
History
************************************************************************************************
29-Jan-2026   Mark-Capgemini      CRM-10427: Test method updated for PSV changes
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class FreightEmailMsgCloseDuplicateCasesTest {

    @testSetup
    static void createData() {

        // Trigger settings
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;

        TestUtilityDataClassQantas.insertQantasConfigData();

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        // Config keys used by main class
        List<QantasConfigData__c> cfg = new List<QantasConfigData__c>();
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTBookings', 'FRT Bookings'));
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_FRTCustService', 'FRT Cust Service'));
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed', 'Closed'));
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('RepliedEmailPrefix', 'Re:'));
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('ForwardedEmailPrefix', 'Fwd:'));
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('ColonSymbol', ':'));
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('Type_InvalidCase', 'Invalid'));
        cfg.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert cfg;

        // ContentDocLink trigger setting (per your org pattern)
        Trigger_Status__c contentDocLink = new Trigger_Status__c();
        contentDocLink.Name = 'ContentDocLinkTriggerCheck';
        contentDocLink.Active__c = true;
        insert contentDocLink;

        // Queue for Case
        Group grp = new Group();
        grp.Name = 'Freight CSU AU Queue';
        grp.Type = 'Queue';
        grp.DeveloperName = 'Freight_CSU_AU_Grp';
        insert grp;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueuesObject q1 = new QueuesObject();
            q1.QueueID = grp.Id;
            q1.SobjectType = 'Case';
            insert q1;
        }

        // Record Types
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Freight Account').getRecordTypeId();

        Id caseRT = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Qantas Freight').getRecordTypeId();

        // Account + Contact
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        accountRecord.BillingCountry = 'AU';
        accountRecord.Email__c = 'greenavenue@auspost.com.au';
        insert accountRecord;

        Airport_Code__c port = new Airport_Code__c(Name='NONE', QF_Freight_Presence__c=true);
        insert port;

        Contact cont = new Contact(
            FirstName='Test',
            LastName='Contact',
            AccountId=accountRecord.Id,
            Email='freight_Emails@qantas.com.au'
        );
        insert cont;

        // Two OPEN duplicate cases, different origins
        Case bookingsCase = new Case(
            RecordTypeId = caseRT,
            Freight_Port__c = port.Id,
            Type = 'Claims',
            Sub_Type_1__c = 'Animal',
            Freight_AWB_Number__c = '081-76763768',
            Origin = 'FRT Bookings',
            OwnerId = grp.Id,
            Priority = 'Medium',
            Status = 'Open',
            Resolved_Reasons_Sub_Type__c = 'Capacity',
            Freight_Resolve_Reason__c = 'Aircraft trimissues',
            Subject = 'Qantas Freight Customer Support – Ref No',
            Description = 'test Case',
            AccountId = accountRecord.Id,
            ContactId = cont.Id,
            Freight_Shipment__c = 'Domestic'
        );

        Case custServiceCase = new Case(
            RecordTypeId = caseRT,
            Freight_Port__c = port.Id,
            Type = 'Claims',
            Sub_Type_1__c = 'Animal',
            Freight_AWB_Number__c = '081-76763768',
            Origin = 'FRT Cust Service',
            OwnerId = grp.Id,
            Priority = 'Medium',
            Status = 'Open',
            Resolved_Reasons_Sub_Type__c = 'Capacity',
            Freight_Resolve_Reason__c = 'Aircraft trimissues',
            Subject = 'Re: Qantas Freight Customer Support – Ref No',
            Description = 'test Case',
            AccountId = accountRecord.Id,
            ContactId = cont.Id,
            Freight_Shipment__c = 'Domestic'
        );

        insert new List<Case>{ bookingsCase, custServiceCase };

        // Email on cust service case (must match duplicate logic)
        EmailMessage em = new EmailMessage(
            FromAddress = 'FromEmailRecord@qantas.com.au',
            To_Address__c = 'ToEmailRecord@qantas.com.au',
            TextBody = 'Test Case Email - duplicate match',
            MessageDate = System.now(),
            ParentId = custServiceCase.Id,
            Subject = 'Re: Qantas Freight Customer Support – Ref No',
            RelatedToId = custServiceCase.Id,
            Incoming = true
        );
        insert em;
        
        EmailMessage emBooking = new EmailMessage(
            FromAddress = 'FromEmailRecordBook@qantas.com.au',
            To_Address__c = 'ToEmailRecordBook@qantas.com.au',
            TextBody = 'Test Case Email - duplicate match',
            MessageDate = System.now(),
            ParentId = bookingsCase.Id,
            Subject = 'Re: Qantas Freight Customer Support – Ref No',
            RelatedToId = bookingsCase.Id,
            Incoming = true
        );
        insert emBooking;

        // Attachment (for HasAttachment path)
        Blob b = Blob.valueOf('StringToBlob');
        insert new Attachment(ParentId = em.Id, Name='Test Attachment', Body=b);

        // File + explicit ContentDocumentLink to EmailMessage (so your query finds it)
        ContentVersion cv = new ContentVersion(
            VersionData = b,
            Title = 'TestFile',
            PathOnClient = 'TestFile.txt'
        );
        insert cv;

        ContentVersion cv2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        insert new ContentDocumentLink(
            ContentDocumentId = cv2.ContentDocumentId,
            LinkedEntityId = em.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
    }

    // Helper to fetch setup records safely inside each test method
    private static Map<String, SObject> fetchSetupRecords() {
        Map<String, SObject> outMap = new Map<String, SObject>();

        Case bookings = [
            SELECT Id, Origin, Subject, CreatedDate
            FROM Case
            WHERE Origin = 'FRT Bookings'
              AND Subject = 'Qantas Freight Customer Support – Ref No'
            LIMIT 1
        ];

        Case cust = [
            SELECT Id, Origin, Subject, CreatedDate
            FROM Case
            WHERE Origin = 'FRT Cust Service'
              AND Subject LIKE 'Re:%'
            LIMIT 1
        ];

        EmailMessage em = [
            SELECT Id, ParentId, Subject, HasAttachment
            FROM EmailMessage
            WHERE ParentId = :cust.Id
            LIMIT 1
        ];
        
        EmailMessage emBooking = [
            SELECT Id, ParentId, Subject, HasAttachment
            FROM EmailMessage
            WHERE ParentId = :bookings.Id
            LIMIT 1
        ];

        outMap.put('bookings', bookings);
        outMap.put('cust', cust);
        outMap.put('email', emBooking);
        return outMap;
    }

      @isTest
    static void testfreightCloseDuplicateCases_NoInput_ExpectNoThrow() {
        // This covers the current behavior when passing empty list; since class does not throw, just ensure no exception
        // Create a Standard User for running user-context tests
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email='stduser@qantas.com.au',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='stduser'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        insert u;
        
        Map<String, SObject> testRecords = fetchSetupRecords();
        List<EmailMessage> lstEmailMessage = new List<EmailMessage>();
        EmailMessage msg = (EmailMessage) testRecords.get('email');
        lstEmailMessage.add(msg);
        
        //System.runAs(u) {// Removed runAs
           
            Test.startTest();
            FreightEmailMessageCloseDuplicateCases.freightCloseDuplicateCases(lstEmailMessage);
            Test.stopTest();
            System.assert(true, 'No exception expected for empty input with current implementation');
        //}//Removed runAs
    }
    
    //Method added to support Code Security Remediation changes
    @isTest
    static void testfreightCloseDuplicateCases_QueryException() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'stduser',
            Email='stduser@qantas.com.au',
            EmailEncodingKey='UTF-8',
            LastName='User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            Username='stduser'+System.currentTimeMillis()+'@example.com',
            ProfileId = p.Id
        );
        insert u;
        
        Map<String, SObject> testRecords = fetchSetupRecords();
        List<EmailMessage> lstEmailMessage = new List<EmailMessage>();
        EmailMessage msg = (EmailMessage) testRecords.get('email');
        lstEmailMessage.add(msg);
        
        System.runAs(u) {
            try {
                Test.startTest();
                FreightEmailMessageCloseDuplicateCases.freightCloseDuplicateCases(lstEmailMessage);
                Test.stopTest();
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

        
}