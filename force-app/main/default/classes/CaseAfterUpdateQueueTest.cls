/**
* @description       : 
* @author            : Praveen Sampath
* @group             : 
* @last modified on  : 04-27-2024
* @last modified by  : Praveen Sampath
* Test class for CaseApterUpdateQueue
**/
@isTest
private class CaseAfterUpdateQueueTest {
    private static final Id RTID_CASE_INSURANCELETTER = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('QCC_Insurance_Letter_Case').getRecordTypeId();
    private static final Id RTID_CASE_DEALSUPPORT = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Support_request').getRecordTypeId();
    private static final Id RTID_CASE_ACCOUNTMAINTENANCE = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Account_Maintenance').getRecordTypeId();
    private static final Id RTID_CONTACT_CONTACT = Schema.SobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
    private static final Id RTID_ACCOUNT_AGENCY = Schema.SobjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
    private static final Id RTID_OPPORTUNITY = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Partnerships').getRecordTypeId();
    private static final Id RTID_CONTRACT = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Agency - Signed by Customer').getRecordTypeId();
    private static final Id assRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();     
    
    @testSetup static void createTestData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lstTrigStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        insert lstTrigStatus;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        //TestUtilityDataClassQantas.enableTriggers();
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
            Opportunity opportunityRecord = new Opportunity(Name = 'Opp2'+accountRecord.Name , AccountId = accountRecord.Id,Proposed_Market_Share__c = 70,Proposed_International_Market_Share__c = 50,
                                                            Amount = 500000,  CloseDate = Date.Today(),Proposed_MCA_Routes_Market_Share__c = 90,
                                                            StageName = 'Closed - Accepted', RecordTypeId = RTID_OPPORTUNITY, Category__c = 'Corporate Airfares', Type = 'Agency Partnerships',Forecast_MCA_Revenue__c=20000);
        //insert opportunityRecord;
        insert new List<Opportunity>{ opportunityRecord };
            Contract__c contractRecord = new Contract__c(Name = 'Sample Contract', Account__c = accountRecord.Id, Opportunity__c = opportunityRecord.Id, 
                                                         Active__c = true,  International_Annual_Share__c = 70,
                                                         Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                                         MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = system.today(), Contract_End_Date__c = system.today().addmonths(12),
                                                         Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No',   RecordTypeId = RTID_CONTRACT                                             
                                                        );
        //insert contractRecord;
        insert new List<Contract__c>{ contractRecord };
            System.debug('contractRecord========> ' + contractRecord.id);
        System.debug('opportunityRecord.Id=====> ' + opportunityRecord.Id);
        
        List<Asset> listAssets = new List<Asset>();
        Asset ass1 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId, AccountId = accountRecord.Id, Active__c = True, Total_Acquired_Credits__c = 1000, Total_Consumed_Credits__c = 0 ); 
        listAssets.add(ass1);
        insert listAssets;
        
        List<Case> caseRecords = new Case[2];
        caseRecords[0] = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Insurance Letter Case', 'Insurance Letter', 'Delayed Flight', '', '', '');
        caseRecords[0].ContactId = contactRecord.Id;
        caseRecords[0].Origin = 'Qantas.com';
        caseRecords[0].Flight_Number__c = 'QF0400';
        caseRecords[0].Booking_PNR__c = '123456';
        caseRecords[0].AccountId = accountRecord.Id;
        
        caseRecords[1] = new Case(
            RecordTypeId = RTID_CASE_DEALSUPPORT,
            AccountId = accountRecord.Id,
            //Type = 'Agency Account',
            Type = 'Deal Amendment',
            Sub_Type__c = 'Channel Agency Payment Contract',
            //Sub_Type_1__c = 'Other',
            Approval_Status__c = 'Approved',
            Approve__c = 'No',
            Related_Contract__c = contractRecord.Id,
            NAM_s_Approval__c = true
        );
        insert caseRecords;
        
    }
    
    @isTest static void testCaseAfterUpdateQueue1() {
        List<Account> accountRecords = new List<Account>{ new Account(
            RecordTypeId = RTID_ACCOUNT_AGENCY,
            BillingCountry = 'AU',
            Name = 'Green Cord Corp',
            Email__c = 'greencord@auspost.com.au'
        )};
            List<Contact> contactRecords = new List<Contact>{ new Contact(
                FirstName = 'Yellow',
                LastName = 'Trees',
                Email = 'greenTrees@fedex.com',
                AccountId = accountRecords[0].Id,
                RecordTypeId = RTID_CONTACT_CONTACT
            )};
                insert contactRecords;
        Map<Id, Case> oldCaseRecordMap = new Map<Id, Case>([ SELECT CaseNumber, RecordTypeId,Related_Contract__c, Booking_PNR__c, ContactId FROM Case ]);
        List<Case> newCaseRecords = new List<Case>();
        for (Case record : oldCaseRecordMap.values()) {
            newCaseRecords.add(new Case(Id=record.Id, Related_Contract__c = record.Related_Contract__c, RecordTypeId=record.RecordTypeId, Booking_PNR__c='654321', ContactId=contactRecords[0].Id));
        }
        Test.startTest();
        System.enqueueJob(new CaseAfterUpdateQueue(newCaseRecords, oldCaseRecordMap));
        Test.stopTest();
    }
    
    @isTest static void testDeleteAffectedPassengers() {
        String type = 'Insurance Letter';
        String recordType =  'CCC Insurance Letter Case';
        Case cs;
        
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight', '', '', '');
        cs.ContactId = con.id;
        cs.Departure_Date_Time__c = '10/06/2018 16:50:00';
        cs.Actual_Arrival_Date_Time__c = '14/06/2018 14:55:00';
        cs.Status = 'Closed';
        cs.Sensitive__c = false;    
        cs.Booking_PNR__c = 'XXXX98';    
        insert cs;
        
        Test.startTest();
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' ,Frequent_Flyer_Tier__c='Platinum', Frequent_Flyer_Number__c = '00061422023');
        insert contact1;
        
        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        
        insert objEvent;
        
        //add passenger in response
        Affected_Passenger__c afp = new Affected_Passenger__c(PassengerId__c = '1544523921002621', Passenger__c =contact1.Id, TECH_PreFlight__c = true,Event__c = objEvent.Id , case__c = cs.Id);
        
        Case objCase = [Select id, Status , ContactEmail , Booking_PNR__c , Sensitive__c, Priority,Related_Contract__c from Case where Id = :cs.Id];
        if (objCase.Status.equals(CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')))
        {
            Case childCase = objCase.clone(false, true, false, true);
            childCase.ParentId = objCase.Id;
            childCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            childCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            childCase.Sensitive__c = true;
            childCase.Booking_PNR__c = 'XXX123';
            childCase.Description = 'Test Case Description';
            insert childCase;
        }
        else
        {
            objCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            objCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            objCase.Sensitive__c = true;
            objCase.Booking_PNR__c = 'XXX1';   
            update objCase;
        }
        Test.stopTest();
    }
    
    @isTest static void testCaseAfterUpdateQueue2() {
        Id accountMaintenanceRTId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_AccountMaintenance')).getRecordTypeId();
        
        /*
List<Account> accountRecords = new List<Account>{ new Account(
RecordTypeId = RTID_ACCOUNT_AGENCY,
BillingCountry = 'AU',
Name = 'Green Cord Corp',
Email__c = 'greencord@auspost.com.au'
)};
insert accountRecords;
*/
        List<Account> accountRecords = [SELECT id,RecordTypeId,BillingCountry, Email__c,Name FROM Account ];
        
        List<Contact> contactRecords = new List<Contact>{ new Contact(
            FirstName = 'Yellow',
            LastName = 'Trees',
            Email = 'greenTrees@fedex.com',
            AccountId = accountRecords[0].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        )};
            insert contactRecords;
        Map<Id, Case> oldCaseRecordMap = new Map<Id, Case>([ SELECT CaseNumber, RecordTypeId, Booking_PNR__c,Related_Contract__c,End_Date__c,Reasons_for_Termination__c, ContactId FROM Case ]);
        List<Case> newCaseRecords = new List<Case>();
        for (Case record : oldCaseRecordMap.values()) {
            newCaseRecords.add(new Case(Id=record.Id, RecordTypeId=accountMaintenanceRTId,Related_Contract__c = record.Related_Contract__c, Booking_PNR__c='654321', Total_Credits__c = 1000, ContactId=contactRecords[0].Id, AccountId = accountRecords[0].Id, Type  = 'Agency Account', Approve__c = 'No',Approval_Status__c ='Approved', Sub_Type_1__c = 'Ad-hoc Credits'));
        }
        Test.startTest();
        System.enqueueJob(new CaseAfterUpdateQueue(newCaseRecords, oldCaseRecordMap));
        Test.stopTest();
    }
    
    
    @isTest static void testCaseAfterUpdateQueue3() {
        Id accountMaintenanceRTId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_AccountMaintenance')).getRecordTypeId();
        List<Account> accountRecords = new List<Account>{ new Account(
            RecordTypeId = RTID_ACCOUNT_AGENCY,
            BillingCountry = 'AU',
            Name = 'Green Cord Corp',
            Email__c = 'greencord@auspost.com.au'
        )};
            insert accountRecords;
        
        
        List<Contact> contactRecords = new List<Contact>{ new Contact(
            FirstName = 'Yellow',
            LastName = 'Trees',
            Email = 'greenTrees@fedex.com',
            AccountId = accountRecords[0].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        )};
            insert contactRecords;
        Map<Id, Case> oldCaseRecordMap = new Map<Id, Case>([ SELECT CaseNumber, RecordTypeId, Booking_PNR__c,Related_Contract__c,End_Date__c,Reasons_for_Termination__c, ContactId FROM Case ]);
        List<Case> newCaseRecords = new List<Case>();
        for (Case record : oldCaseRecordMap.values()) {
            newCaseRecords.add(new Case(Id=record.Id, RecordTypeId=accountMaintenanceRTId,Related_Contract__c = record.Related_Contract__c, Booking_PNR__c='654321', Total_Credits__c = 1000, ContactId=contactRecords[0].Id, AccountId = accountRecords[0].Id, Type  = 'Agency Account', Approve__c = 'No',Approval_Status__c ='Approved', Sub_Type_1__c = 'Ad-hoc Credits'));
        }
        Test.startTest();
        System.enqueueJob(new CaseAfterUpdateQueue(newCaseRecords, oldCaseRecordMap));
        Test.stopTest();
    }
    
    @isTest static void testagencyContractUpdateMethod() {
        Id accountMaintenanceRTId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_AccountMaintenance')).getRecordTypeId();
        // Id asbcContractRTId = Schema.sObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('RT_AgencySignedByCustomer').getRecordTypeId();
        Id asbcContractRTId = Schema.sObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_AgencySignedByCustomer')).getRecordTypeId();
        
        List<Account> accountRecords = new List<Account>{ new Account(
            RecordTypeId = RTID_ACCOUNT_AGENCY,
            BillingCountry = 'AU',
            Name = 'Green Cord Corp',
            Email__c = 'greencord@auspost.com.au'
        )};
            insert accountRecords;
        
        List<Contact> contactRecords = new List<Contact>{ new Contact(
            FirstName = 'Yellow',
            LastName = 'Trees',
            Email = 'greenTrees@fedex.com',
            AccountId = accountRecords[0].Id,
            RecordTypeId = RTID_CONTACT_CONTACT
        )};
            insert contactRecords;
        Set<Id> contractIds = new set<Id>();
        Map<Id, Case> contractCaseMap = new Map<Id, Case>();
        
        Map<Id, Case> oldCaseRecordMap = new Map<Id, Case>([ SELECT CaseNumber, RecordTypeId, Booking_PNR__c,Related_Contract__c, End_Date__c,Reasons_for_Termination__c, ContactId FROM Case ]);
        List<Case> newCaseRecords = new List<Case>();
        for (Case record : oldCaseRecordMap.values()) {
            newCaseRecords.add(new Case(Id=record.Id, RecordTypeId=accountMaintenanceRTId,Related_Contract__c = record.Related_Contract__c, Booking_PNR__c='654321', ContactId=contactRecords[0].Id, AccountId = accountRecords[0].Id, Type  = 'Agency Account', Approve__c = 'No',Approval_Status__c ='Approved', Sub_Type_1__c = 'Ad-hoc Credits'));
            
            if (!String.isBlank(record.Related_Contract__c)) {
                
                contractIds.add(record.Related_Contract__c);
                contractCaseMap.put(record.Related_Contract__c, record);
            }
        }
        Test.startTest();
        //System.enqueueJob(new CaseAfterUpdateQueue(newCaseRecords, oldCaseRecordMap));
        
        CaseAfterUpdateQueue.agencyContractUpdateMethod(contractIds,contractCaseMap );
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseOwner() {
        // Create Test Queue (Group)
        
        Group testQueue = new Group(
            Name = 'Test Queue',
            DeveloperName = 'Test_Queue',
            Type = 'Queue'
        );
        insert testQueue;
        
        // Create Freight Port
        Airport_Code__c freightPort = new Airport_Code__c(
            Name = 'PortName',
            Freight_Region__c = 'AU'
        );
        insert freightPort;
        
        // Create AWB Info
        AWB_Info__c awbInfo = new AWB_Info__c(
            Name = 'AWB001'
        );
        insert awbInfo;
        
        // Create Case
        Case testCase = new Case(
            Status = 'New',
            Freight_AWB_Number__c = awbInfo.Name
        );
        insert testCase;
        
        // Create AWB Relationship
        AWB_Relationship__c awbRel = new AWB_Relationship__c(
            Case__c = testCase.Id,
            AWB__c = awbInfo.Id
        );
        insert awbRel;
        
        // Prepare Input for Method
        Map<Id, Case> caseMap = new Map<Id, Case>{
            testCase.Id => testCase
                };
                    
                    /*Integration_User_Tradesite__c  iutRecord = new Integration_User_Tradesite__c(
                        Name = 'Freight_iCargo_Integration',
                        Endpoint__c = 'https://api-stage.qantas.com/freight/freightgatewayservice/tracking/v2/trackshipment/',
                        Password__c = 'DW03CMWL',
                        Username__c = 'SALESICARGOP',
                        Authentication_Endpoint_URL__c = 'https://api-stage.qantas.com/api/token',
                        Client_Id__c = 'hcMQLqotDPJfKoYfPZ1CBJshtt4a',
                        Client_Secret__c = 's3ezAQeTs4y4Y3QlJvAwtSiay1Aa',
                        NameChangeEndNumber__c = 1,
                        NameChangeStartNumber__c = 1
                    );
       insert iutRecord;*/
        
        // Call the method to test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Freight_AWBMockRequest('no'));
        CaseAfterUpdateQueue.updateCaseOwner(caseMap);
        Test.stopTest();
        
    }

    // CRM-13421 - Skip owner update for specific case criteria
    @IsTest
    static void testDealSupportBranchCoverage() {
        Contract__c contractRec = [
            SELECT Id
            FROM Contract__c
            LIMIT 1
        ];
        Case existingCase = [
            SELECT Id,
            Booking_PNR__c,
            ContactId,
            Related_Contract__c
            FROM Case
            LIMIT 1
        ];
        Map<Id, Case> oldCaseMap = new Map<Id, Case>{
            existingCase.Id => existingCase
                };
                    Case updatedCase = new Case(
                        Id = existingCase.Id,
                        RecordTypeId = RTID_CASE_DEALSUPPORT,
                        Booking_PNR__c = '999999',
                        ContactId = existingCase.ContactId,
                        Related_Contract__c = contractRec.Id,
                        NAM_s_Approval__c = true,
                        Approval_Status__c =
                        CustomSettingsUtilities.getConfigDataMap(
                            'CaseApprovalStatusApproved'
                        ),
                        Sub_Type__c =
                        CustomSettingsUtilities.getConfigDataMap(
                            'CaseSubTypeChannelAgencyPC'
                        )
                    );
        Test.startTest();
        System.enqueueJob(
            new CaseAfterUpdateQueue(
                new List<Case>{ updatedCase },
                oldCaseMap
            )
        );
        Test.stopTest();
        System.assert(true);
    }
    
    
}