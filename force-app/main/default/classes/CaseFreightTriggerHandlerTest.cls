/*----------------------------------------------------------------------------------------------------------------------

************************************************************************************************
History
************************************************************************************************
2-Feb-2026   Tanya-Capgemini      CRM-10425: Test method updated for PSV changes   
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
private class CaseFreightTriggerHandlerTest {
    
    List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
    private static final Id RTID_ACCOUNT_FREIGHT = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Freight_Account').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    private static final Id RTID_CASE_QFREIGHT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
    private static final Id RTID_CASE_FREIGHTSHIPMENT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Shipment').getRecordTypeId();
    private static final Id RTID_CASE_FREIGHTINVOICING = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Freight_Invoicing').getRecordTypeId();
    private static final Map<String, Map<String, Id>> BU_RECORDTYPEMAP =  CaseUtility.mapBUnitToCaseRecordTypes();
    private static final Map<String, Id> FREIGHT_RECORDTYPEMAP = BU_RECORDTYPEMAP.get('Freight');
    private static final Map<Id, Group> QUEUE_GROUPMAP = CaseUtility.queryQueueGroups();
    private static final Map<Id, Approval_Matrix__c> APPROVALMATRIX_MAP = CaseUtility.queryApprovalMatrices();
    private static final Map<Id, User> USERMAP = CaseUtility.queryUsers(new Set<Id>{ UserInfo.getUserId() });
    private static final Id RTID_QANTASFREIGHTHQR = Schema.SObjectType.QCC_Hotword_Queue_Routing__c.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
    
    
    @testSetup static void createTestData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        //CRM-9131 Added by Kamini
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        List<Account> accountRecords = new Account[4];
        List<Contact> contactRecords = new Contact[7];
        List<Airport_Code__c> airportCodes = new Airport_Code__c[8];
        List<QCC_Hotword_Queue_Routing__c> hotWordsQueue = new QCC_Hotword_Queue_Routing__c[1];
        
        accountRecords[0] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            BillingCountry = 'AU',
            Name = 'Green Cord Corp[Freight-SYD-AU]',
            Email__c = 'greencord@auspost.com.au'
        );
        accountRecords[1] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            BillingCountry = 'AU',
            Name = 'Green Cord Corp[Freight-PER-AU]',
            Email__c = 'greencord@auspost.com.au'
        );
        accountRecords[2] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            BillingCountry = 'AU',
            Email__c = 'greenavenue@qantas.com.au',
            Name = 'Green Avenue Corp[Freight-Per-AU]'
        );
        accountRecords[3] = new Account(
            RecordTypeId = RTID_ACCOUNT_FREIGHT,
            BillingCountry = 'AU',
            Name = 'Green Trees Corp[Freight-Mel-AU]',
            Email__c = 'greenTrees@fedex.com'
        );
        insert accountRecords;
        
        contactRecords[0] = new Contact(
            FirstName = 'Green',
            LastName = 'Trees',
            Email = 'greenTrees@fedex.com',
            AccountId = accountRecords[1].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        contactRecords[1] = new Contact(
            FirstName = 'Yellow',
            LastName = 'Trees',
            Email = 'greenTrees@fedex.com',
            AccountId = accountRecords[1].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        contactRecords[2] = new Contact(
            FirstName = 'Green',
            LastName = 'Garden',
            Email = 'greenavenue@qantas.com.au',
            AccountId = accountRecords[2].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        contactRecords[3] = new Contact(
            FirstName = 'Green',
            LastName = 'Cord',
            Email = 'greencord@auspost.com.au',
            AccountId = accountRecords[0].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        contactRecords[4] = new Contact(
            FirstName = 'Green',
            LastName = 'Cord',
            Email = 'greencord@auspost.com.au',
            AccountId = accountRecords[2].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        contactRecords[5] = new Contact(
            FirstName = 'Green',
            LastName = 'Cord',
            Email = 'greencord@auspost.com.au',
            AccountId = accountRecords[0].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        contactRecords[6] = new Contact(
            FirstName = 'Green',
            LastName = 'Cord2',
            Email = 'greencord@auspost.com.au',
            AccountId = accountRecords[0].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        );
        insert contactRecords;
        
        airportCodes[0] = new Airport_Code__c (Name='NONE', Freight_Airport_State_Code__c='CA', QF_Freight_Presence__c=true);
        airportCodes[1] = new Airport_Code__c (Name='BHQ', QF_Freight_Presence__c=true);
        airportCodes[2] = new Airport_Code__c (Name='ABX', QF_Freight_Presence__c=true);
        airportCodes[3] = new Airport_Code__c (Name='ALH', QF_Freight_Presence__c=true);
        airportCodes[4] = new Airport_Code__c (Name='ARM', QF_Freight_Presence__c=true);
        airportCodes[5] = new Airport_Code__c (Name='ASP', QF_Freight_Presence__c=true);
        airportCodes[6] = new Airport_Code__c (Name='BNE', QF_Freight_Presence__c=true);
        airportCodes[7] = new Airport_Code__c (Name='ABX', QF_Freight_Presence__c=true);
        insert airportCodes;
        
        hotWordsQueue[0] = new QCC_Hotword_Queue_Routing__c( freight_Type__c='Mail Suffix', Hot_words__c='@qantas.com.au,@freight.com.au', Priority__c='Urgent', RecordTypeId=RTID_QANTASFREIGHTHQR );
        insert hotWordsQueue;
        List<Case> caseRecords = new Case[3];
        caseRecords[0] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Cust Service',
            Status = 'Open',
            Subject = 'Test Case 10',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[1] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Bookings',
            Status = 'Open',
            Subject = 'Test Case 11',
            Description = 'This is for testing. My credit card number is 123 45678 9234 5679.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[2] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'Web',
            Status = 'New',
            Subject = 'Test Case 12',
            Description = 'This is for testing. My credit card number is 123 45678 9234 5679.',
            Freight_Port__c = airportCodes[0].Id,
            SuppliedEmail = 'greenTrees@fedex.com',
            SuppliedCompany = 'Green Trees Corp'
        );
        
        insert caseRecords;
    }
   
    @isTest static void testOnBeforeInsert() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'NONE' LIMIT 1 ];
        
        List<Case> caseRecords = new Case[11];
        Set<String> emailIds = new Set<String>();
        caseRecords[0] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'Web',
            Status = 'New',
            Subject = 'Test Case 01',
            Description = 'This is for testing. My credit card number is 123 45678 9234 5679.',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greenTrees@fedex.com',
            SuppliedCompany = 'Green Trees Corp'
        );
        caseRecords[1] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'Web',
            Status = 'New',
            Subject = 'PIL-PIL PRE-ALERT ONBOARD SQ0237 - Test Case 02',
            Description = 'This is for testing. My credit card number is 123-4567-89234-5679.',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greencord@auspost.com.au',
            SuppliedCompany = 'Green Cord Corp',
            Freight_AWB_Number__c = '061-08254746'
        );
        caseRecords[2] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'Web',
            Status = 'New',
            Subject = 'Test Case 03',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp',
            Freight_WebToCaseType__c = 'Freight - General enquiries'
        );
        caseRecords[3] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'Web',
            Status = 'Closed',
            //Subject = 'Test Case 04',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greenTrees@fedex.com',
            SuppliedCompany = 'Green Trees Corp',
            Freight_WebToCaseType__c = 'Freight - Track and trace query'
        );
        caseRecords[4] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'Web',
            Status = 'Closed',
            Subject = 'Test Case 05',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greencord@auspost.com.au',
            SuppliedCompany = 'Green Cord Corp',
            Freight_WebToCaseType__c = 'Freight - Give us feedback'
        );
        caseRecords[5] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'Web',
            Status = 'Closed',
            Subject = 'Test Case 06',
            Description = 'This is for testing.',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[6] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Bookings',
            Status = 'Open',
            Subject = 'Automatic Reply: Test Case 07',
            Description = 'This is for testing. My credit card number is 5678-6789056-45678',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[7] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Cust Service',
            Status = 'Open',
            Subject = 'Test Case 08',
            Description = 'This is for testing. My credit card number is 8903 4567 2345 9876.',
            Freight_Port__c = airportCodeRecord.Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        caseRecords[8] = new Case( 
            RecordTypeId = RTID_CASE_FREIGHTINVOICING, 
            Type = 'Claims',
            Subject = 'Test Case 09',
            AccountId = accountRecords[0].Id,
            Description = 'This is for testing.',
            Freight_Port__c = airportCodeRecord.Id
        );
        caseRecords[9] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Subject = 'Test Case 09',
            AccountId = accountRecords[0].Id,
            Description = 'This is for testing.',
            Sub_Type_2__c = 'New',
            Sub_Type_1__c = 'Accounts',
            Type = 'Customer Query',
            Freight_Port__c = airportCodeRecord.Id
        );
        caseRecords[10] = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Subject = 'Test Case 09',
            AccountId = accountRecords[0].Id,
            Description = 'This is for testing.',
            Sub_Type_2__c = 'AWB Stock Request',
            Sub_Type_1__c = 'Accounts',
            Type = 'Customer Query',
            Freight_Port__c = airportCodeRecord.Id
        );
        
        for (Case record : caseRecords) {
            if (String.isNotBlank(record.SuppliedEmail)) {
                emailIds.add(record.SuppliedEmail);
            }
        }
        CaseFreightTriggerHandler.onBeforeInsert(caseRecords, FREIGHT_RECORDTYPEMAP, QUEUE_GROUPMAP, emailIds, new Set<Id>{ airportCodeRecord.Id }, new Set<Id> { accountRecords[0].Id }, APPROVALMATRIX_MAP, USERMAP);
        for (Case caseRecord : caseRecords) {
            System.debug(caseRecord.Subject + ' - ' + caseRecord.Type + ' - ' + airportCodeRecord);
        }
    }
    
    @isTest static void testOnBeforeUpdate() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'NONE' LIMIT 1 ];
        
        Map<Id, Case> oldCaseRecords = new Map<Id, Case>([ SELECT CaseNumber, Subject, Description, Freight_AWB_Number__c, Origin, Status, AccountId FROM Case WHERE Status != 'Closed' LIMIT 3 ]);
        Map<Id, Case> newCaseRecords = new Map<Id, Case>();
        List<Case> caseRecords = new Case[3];
        Integer i = 0;
        for (Case caseRecord : oldCaseRecords.values()) {
            caseRecords[i] = caseRecord;
            ++i;
        }
        newCaseRecords.put(caseRecords[0].Id, new Case(Id=caseRecords[0].Id, Description = caseRecords[0].Description+'Thanks', Freight_AWB_Number__c='061-08254746', Problem_Type__c='Internal - ADM/ACM'));
        newCaseRecords.put(caseRecords[1].Id, new Case(Id=caseRecords[1].Id, Subject='PIL-PIL PRE-ALERT ONBOARD SQ0237 - Test Case', Origin=caseRecords[1].Origin, Description=caseRecords[1].Description));
        newCaseRecords.put(caseRecords[2].Id, new Case(Id=caseRecords[2].Id, Status='Closed'));
        CaseFreightTriggerHandler.onBeforeUpdate(oldCaseRecords, newCaseRecords, FREIGHT_RECORDTYPEMAP, new Set<Id>{ airportCodeRecord.Id }, new Set<Id> { caseRecords[2].AccountId }, APPROVALMATRIX_MAP, USERMAP);
        
        oldCaseRecords.put(caseRecords[0].Id, new Case(Id=caseRecords[0].Id, Description = caseRecords[0].Description+'Thanks', Freight_AWB_Number__c='061-08254746', Problem_Type__c='Internal - ADM/ACM', RecordTypeId=RTID_CASE_QFREIGHT, Sub_Type_2__c='Rates', Sub_Type_1__c='Accounts', Type='Customer Query'));
        oldCaseRecords.put(caseRecords[1].Id, new Case(Id=caseRecords[1].Id, Subject='PIL-PIL PRE-ALERT ONBOARD SQ0237 - Test Case', Description=caseRecords[1].Description, RecordTypeId=RTID_CASE_QFREIGHT, Sub_Type_2__c='Rates', Sub_Type_1__c='Accounts', Type='Customer Query'));
        
        newCaseRecords.put(caseRecords[0].Id, new Case(Id=caseRecords[0].Id, Description = caseRecords[0].Description+'Thanks', Freight_AWB_Number__c='061-08254746', Problem_Type__c='Internal - ADM/ACM', RecordTypeId=RTID_CASE_QFREIGHT, Sub_Type_2__c='AWB Stock Request', Sub_Type_1__c='Accounts', Type='Customer Query'));
        newCaseRecords.put(caseRecords[1].Id, new Case(Id=caseRecords[1].Id, Subject='PIL-PIL PRE-ALERT ONBOARD SQ0237 - Test Case', Description=caseRecords[1].Description, RecordTypeId=RTID_CASE_QFREIGHT, Sub_Type_2__c='New', Sub_Type_1__c='Accounts', Type='Customer Query'));
        CaseFreightTriggerHandler.onBeforeUpdate(oldCaseRecords, newCaseRecords, FREIGHT_RECORDTYPEMAP, new Set<Id>{ airportCodeRecord.Id }, new Set<Id> { caseRecords[2].AccountId }, APPROVALMATRIX_MAP, USERMAP);
        for (Case caseRecord : caseRecords) {
            System.debug(caseRecord.Subject + ' - ' + caseRecord.AccountId + ' - ' + caseRecord.Description);
        }
    }
    
    @isTest static void testOnAfterUpdate() {
        List<Account> accountRecords = [ SELECT Id, Name FROM Account WHERE RecordTypeId = :RTID_ACCOUNT_FREIGHT ];
        List<Contact> contactRecords = [ SELECT Id, Name, Email, Account.Id, Account.Name FROM Contact WHERE RecordTypeId = :RTID_CONTACT_CONTACT ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'NONE' LIMIT 1 ];
        
        Map<Id, Case> oldCaseRecords = new Map<Id, Case>([ SELECT CaseNumber, Subject, Description, Freight_AWB_Number__c, Status FROM Case WHERE Status != 'Closed' ]);
        Map<Id, Case> newCaseRecords = new Map<Id, Case>();
        for (Case caseRecord : oldCaseRecords.values()) {
            newCaseRecords.put(caseRecord.Id, new Case(Id=caseRecord.Id, Status='Closed'));
        }        
        CaseFreightTriggerHandler.onAfterUpdate(oldCaseRecords, newCaseRecords);
    }
    
    @isTest static void testTriggerHandler() {
        Account accountRecord = [ SELECT Id FROM Account LIMIT 1 ];
        Airport_Code__c airportCodeRecord = [ SELECT Id, Name FROM Airport_Code__c WHERE Name = 'NONE' LIMIT 1 ];
        Case caseRecord = new Case( 
            RecordTypeId = RTID_CASE_FREIGHTINVOICING, 
            Type = 'Claims',
            Subject = 'Test Case 09',
            AccountId = accountRecord.Id,
            Description = 'This is for testing.',
            Freight_Port__c = airportCodeRecord.Id
        );
        insert new List<Case>{ caseRecord };
        Case newCaseRecord = new Case(
            Id = caseRecord.Id,
            RecordTypeId = RTID_CASE_FREIGHTINVOICING,
            Status = 'On Hold'
        );
        update new List<Case>{ newCaseRecord };
        delete caseRecord;
    }
    
   @isTest static void exceptionTest1(){
        CaseFreightTriggerHandler.onBeforeInsert(null,null,null,null,null,null,null,null);
            CaseFreightTriggerHandler.onBeforeUpdate(null,null,null,null,null,null,null);
            CaseFreightTriggerHandler.onAfterUpdate(null,null);
            CaseFreightTriggerHandler.autoAssignCaseToCSUQueue(null,null,null);
            CaseFreightTriggerHandler.autoAssignPriorityAsPremium(null,null);
            CaseFreightTriggerHandler.assignUrgentPriorityForCasesWithHotWords(null);
            CaseFreightTriggerHandler.autoCloseAuotmaticReplayCases(null);
            CaseFreightTriggerHandler.assignUsersBasedOnApprovalMatrix(null,null,null,null,null);
        CaseFreightTriggerHandler.assignEntitlement(null,null,null);
            CaseFreightTriggerHandler.milestoneCompletion(null);
        CaseFreightTriggerHandler.queryHotWordsWithFreightType(null,null);
        CaseFreightTriggerHandler.processForAWB(null,null);
        //CaseFreightTriggerHandler.updateActiveProducts(null,null);
        CaseFreightTriggerHandler.updateAirportCodeBasedOnAWB(null, null);
        //added to support Code Security Remediation changes
       Profile p = [Select Id from Profile where Name= 'Read Only' LIMIT 1];
        User u= new User(Alias = 'stduser',Email = 'stduser@qantas.com.au',EmailEncodingKey = 'UTF-8',
            			  LastName = 'User', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                         TimeZoneSidKey='America/Los_Angeles',Username='stduser'+System.currentTimeMillis()+'@example.com',ProfileId =p.Id);
       
        System.runAs(u){
        try{
        Case updatedDest1 = CaseFreightTriggerHandler.updateAirportCodeBasedOnAWB(new Case(), new Case());
        }catch(Exception ex){
            
        }//added to support Code Security Remediation changes
        }
        
    }
    
    @isTest
    static void testUpdateAirportCodeBasedOnAWB_DestinationAndOriginMatch() {
        // Create AWB Info for destination match
        AWB_Info__c awbDest = new AWB_Info__c(
            Name = 'AWB123',
            Freight_Destination__c = 'DEL',
            Freight_Origin__c = 'BOM'
        );
        insert awbDest;

        // Create AWB Info for origin match
        AWB_Info__c awbOrigin = new AWB_Info__c(
            Name = 'AWB456',
            Freight_Destination__c = 'BLR',
            Freight_Origin__c = 'HYD'
        );
        insert awbOrigin;

        // Create Airport Codes
        Airport_Code__c airportDest = new Airport_Code__c(
            Name = 'DEL',
            QF_Freight_Presence__c = true
        );
        Airport_Code__c airportOrigin = new Airport_Code__c(
            Name = 'HYD',
            QF_Freight_Presence__c = true
        );
        insert new List<Airport_Code__c>{airportDest, airportOrigin};

        // Create Case for destination match
        Case caseDest = new Case(
            Freight_AWB_Number__c = 'AWB123',
            Port_Override_Flag__c = true,
            Sub_Type_2__c = 'Check-in Status'
        );
        insert caseDest;

        // Create Case for origin match
        Case caseOrigin = new Case(
            Freight_AWB_Number__c = 'AWB456',
            Port_Override_Flag__c = false,
            Sub_Type_2__c = 'General Inquiry'
        );
        insert caseOrigin;

        // Create AWB Relationships
        insert new List<AWB_Relationship__c>{
            new AWB_Relationship__c(Case__c = caseDest.Id, AWB__c = awbDest.Id),
            new AWB_Relationship__c(Case__c = caseOrigin.Id, AWB__c = awbOrigin.Id)
        };
            
        Case oldCaseDest = caseDest.clone(false, false, false, false);
        Case oldCaseOrigin = caseOrigin.clone(false, false, false, false);

        Test.startTest();
        Case updatedDest = CaseFreightTriggerHandler.updateAirportCodeBasedOnAWB(caseDest, oldCaseDest);
        Case updatedOrigin = CaseFreightTriggerHandler.updateAirportCodeBasedOnAWB(caseOrigin, oldCaseOrigin);
        Test.stopTest();
        
         
        System.assertEquals(true, updatedDest.Port_Override_Flag__c, 'Destination match: Override flag should be true');
      //  System.assertNotEquals(oldCaseDest.Freight_Port__c, updatedDest.Freight_Port__c, 'Freight_Port__c should be updated');
 
        // Assertions for origin match
        System.assertNotEquals(null, updatedOrigin.Freight_Port__c, 'Origin match: Freight Port should be set');
        System.assertNotEquals(oldCaseDest.Freight_Port__c, updatedOrigin.Freight_Port__c, 'Freight_Port__c should be updated');
 
    }

    // Code added to support Code Security Remediation changes
    @isTest static void testMilestoneCompletion() {
        Account acc = [ SELECT Id FROM Account LIMIT 1 ];

        
        Test.startTest();
        SlaProcess sla = [
            SELECT Id FROM SlaProcess
            WHERE IsActive = true AND Name = 'freight entitlement sla process'
            LIMIT 1
        ];
        System.debug('sla: ' + sla);

        Entitlement ent = new Entitlement(
            Name = 'Test Entitlement',
            SlaProcessId = sla.Id,
            AccountId = acc.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1),
            Type = 'Case Resolution'
        );
        insert ent;

        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsActive = true AND Name = 'Freight Australia Business Hours' LIMIT 1];
        Datetime insideBusinessHours = Datetime.newInstance(2026, 6, 4, 10, 0, 0);

        Case c1 = new Case(
            Subject = 'Milestone Test',
            Status = 'Assigned', 
            AccountId = acc.Id,
            EntitlementId = ent.Id,
            Origin        = 'Phone',
            BusinessHoursId = bh.Id,
            RecordTypeId = RTID_CASE_FREIGHTSHIPMENT,
            Priority = 'High',
            SlaStartDate = insideBusinessHours
        );
        Case c2 = new Case(
            Subject = 'Milestone Test',
            Status = 'Reopend', 
            AccountId = acc.Id,
            EntitlementId = ent.Id,
            Origin        = 'Phone',
            BusinessHoursId = bh.Id,
            RecordTypeId = RTID_CASE_FREIGHTSHIPMENT,
            Priority = 'High',
            SlaStartDate = insideBusinessHours
        );
        Case c3 = new Case(
            Subject = 'Milestone Test',
            Status = 'Closed', 
            AccountId = acc.Id,
            EntitlementId = ent.Id,
            Origin        = 'Phone',
            BusinessHoursId = bh.Id,
            RecordTypeId = RTID_CASE_FREIGHTSHIPMENT,
            Priority = 'High',
            SlaStartDate = insideBusinessHours
        );
        insert new List<Case>{ c1, c2, c3 };

        List<CaseMilestone> cms = [
            SELECT Id, CaseId, Case.Status, MilestoneType.Name, CompletionDate FROM CaseMilestone];
        System.debug('abc' + cms);


        CaseFreightTriggerHandler.milestoneCompletion(
            new Set<Id>{ c1.Id, c2.Id, c3.Id }
        );

        Test.stopTest();
    }

    @isTest static void testFetchAccounts() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, RecordTypeId FROM Account]);

        CaseFreightTriggerHandler.fetchAccounts(accountMap, accountMap.keySet());
    }

    // Code added to support Code Security Remediation changes
    @isTest static void testAssignEntitlementQueryException() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
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
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account]);

        System.runAs(u)
        {
            try {
                CaseFreightTriggerHandler.assignEntitlement(new List<Case>(), accountMap.keySet(), new Set<Id>());
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    @isTest
static void coverInactiveProductBranch() {

    Case c = new Case(Product__c = 'INVALID_VALUE');

    Test.startTest();
    c = CaseFreightTriggerHandler.updateActiveProducts(c, null);
    Test.stopTest();

    System.assertNotEquals('INVALID_VALUE', c.Product__c);
}
    @isTest
static void coverFetchAccounts() {

    Map<Id, Account> accMap = new Map<Id, Account>(
        [SELECT Id, RecordTypeId FROM Account LIMIT 1]
    );

    Set<Id> accIds = new Set<Id>(accMap.keySet());

    Test.startTest();
    Map<Id, Account> result = CaseFreightTriggerHandler.fetchAccounts(accMap, accIds);
    Test.stopTest();

    System.assert(result.size() > 0);
}
}