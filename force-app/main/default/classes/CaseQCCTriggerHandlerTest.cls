@isTest
private class CaseQCCTriggerHandlerTest {

    @testSetup
    static void createData() {
    
        
        //insert lsttrgStatus;
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
                lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Offload Passenger RecType','QCC Offload Passenger'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic','Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic','Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode International','International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational','   Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible','Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed','Closed'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Origin Specific Needs','Specific Needs Email Enquiries'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Exclude Priority ExCo_Queue','High'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Compliment Type','Compliment'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Insurance Letter RecType','CCC Insurance Letter Case'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Complaint RecType','CCC Complaints'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CCC_R1_Critical','Sydney'));
        insert lstConfigData;

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();

		// Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
             Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
             EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
             TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
             );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> PermissionsetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');        
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
            System.assertEquals(3, psaList.size());
        	System.assertEquals(u1.Id, psaList[0].AssigneeId);
        }
		


        List<Contact> contacts = new List<Contact>();
        
        List<APXTConga4__Conga_Email_Template__c> congaEmailTemplates = TestUtilityDataClassQantas.createCongaEmailTemplates();
        insert congaEmailTemplates;

        List<APXTConga4__Conga_Template__c> congaTemplates = TestUtilityDataClassQantas.createCongaTemplates();
        insert congaTemplates;

        System.runAs(u1) {
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='TestContact'+i, FirstName='User'+i, Email='testcon' + i +'@mailinator.com', Business_Types__c='Agency', Job_Role__c='Agency Manager',
                                          Function__c='Advisory Services', Frequent_Flyer_Number__c = '12345678' + i);
                contacts.add(con);
            }
            //insert contacts;
        }
        
        // QAC Agency Credits Test data
        
        List<Trigger_Status__c> lsttrgStatus1 = TestUtilityDataClassQantas.createAssetTriggerSetting();
        insert lsttrgStatus1;
        
        Trigger_Status__c CaseTriggeragencyCreditFulfilment = new Trigger_Status__c();
        CaseTriggeragencyCreditFulfilment.Name = 'CaseTriggeragencyCreditFulfilment';
        CaseTriggeragencyCreditFulfilment.Active__c = true;
        insert CaseTriggeragencyCreditFulfilment;
        
        Id agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Id assRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Credit').getRecordTypeId();
        
        list<Account> myAccounts = new list<Account>();
        Account acc1 = new Account(Name = 'ValidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                   RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565369',Email__c='managefile.qac@qantas.com.au',
                                   IATA_Number__c = '0239209', Tradesite__c = True);
        myAccounts.add(acc1);
        Account acc2 = new Account(Name = 'ValidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                   RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565368',Email__c='managefile.qac@qantas.com.au',
                                   IATA_Number__c = '0239201', Tradesite__c = True);
        myAccounts.add(acc2);
        insert myAccounts;
        
        List<Asset> listAssets = new List<Asset>();
        Asset ass1 = new  Asset(Name = 'TestAssetRecord', RecordTypeId = assRecTypeId, AccountId = acc1.Id, Active__c = True, Total_Acquired_credits__c = 0, Total_Consumed_credits__c = 0); 
        listAssets.add(ass1);
        insert listAssets;


        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;

        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord01 = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord01.RecordTypeId = contactRecordTypeId;
        contactRecord01.Frequent_Flyer_Number__c = '1947727507';

        insert contactRecord01;

        Contact contactRecord02 = QCC_TestDataFactory.createContactTestData(2, accountRecord.Id);
        contactRecord02.RecordTypeId = contactRecordTypeId;
        contactRecord01.Frequent_Flyer_Number__c = '1900000001';

        insert contactRecord02;

        //Create test data for Contact Watchlist object
        QCC_Contact_Watchlist__c conWatchListRecord01 = QCC_TestDataFactory.createWatchlistTestData(1, contactRecord01.Id);
        conWatchListRecord01.QCC_Watchlist_End_Date__c = Date.today();
        conWatchListRecord01.QCC_Watchlist_Start_Date__c = Date.today();
        insert conWatchListRecord01;

        QCC_Contact_Watchlist__c conWatchListRecord02 = QCC_TestDataFactory.createWatchlistTestData(2, contactRecord02.Id);
        conWatchListRecord02.QCC_Watchlist_End_Date__c = Date.today();
        conWatchListRecord02.QCC_Watchlist_Start_Date__c = Date.today();
        insert conWatchListRecord02;
        //createEvent();

 
       //Create Case Record
       QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = 'PNR Health Check';
        String recordType = 'QCC Elite Process';
          
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        anyCase.contactId = watchlist.QCC_Contact__c;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'BluePrism ';
        anycase.Group__c = 'SPECIFIC-NEEDS';
        insert anyCase;
		
        /*Case_Flight_Event__c objFE = new Case_Flight_Event__c();
        Event__c eventTest = createEvent();
        objFE.Flight_Event__c = eventTest.Id;
        objFE.Case__c = anyCase.Id;
        objFE.Name = 'Test name';
        insert objFE;
        /*
        Set<String> pnrSet = new Set<String>();
        pnrSet.add(anyCase.Booking_PNR__c);
        Map<String, Set<Id>> pnrEventIdMap;
        pnrEventIdMap.put(anyCase.Booking_PNR__c, new Set<Id>{eventTest.Id});
        //pnrEventIdMap = CaseTriggerHandler.queryAffectedPassengers(pnrSet);
        //(Map<Id, Case> caseMap, Map<String, Set<Id>> pnrEventIdMap, Map<Id, Event__c> eventMap)
        CaseQCCTriggerHandler.createCaseFlightEvent(new Map<Id, Case>().put(anyCase.Id,anyCase),
                                                    Map<String, Set<Id>>().put('YUY435', new Set<Id>().add(eventTest.Id)),
                                                   new Map<Id,Event__c>().put(eventTest.Id,eventTest));
        
        
*/
        
        //Create test data for Airport object
        Airport_Code__c airportRecord = new Airport_Code__c(
            Name = 'MEL');
        
        insert airportRecord;
        
        //Create test data for Qantas Host (QCC_First_Host__c) object
        List<QCC_First_Host__c> firstHostList = new List<QCC_First_Host__c>();
        Time timeNow = system.now().time();
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   
    
        QCC_First_Host__c firstHostRecord1 = QCC_TestDataFactory.createFirstHostTestData(contactRecord01.Id, airportRecord.Id);
        firstHostRecord1.QCC_PNR__c = 'MEUBMG';
        firstHostRecord1.QCC_Flight_No__c = '0037';
        firstHostRecord1.QCC_Departure_Local_Date__c = Date.valueOf('2019-09-26T00:43:35.000000050Z');
        firstHostRecord1.QCC_Flight_Departure_Time__c = timeNow;
        firstHostRecord1.QCC_Frequent_Flyer_Number__c = '1947727507';
        firstHostList.add(firstHostRecord1);
        
        QCC_First_Host__c firstHostRecord2 = QCC_TestDataFactory.createFirstHostTestData(contactRecord02.Id, airportRecord.Id);
        firstHostRecord2.QCC_PNR__c = 'MEUBMG';
        firstHostRecord2.QCC_Flight_No__c = '0037';
        firstHostRecord2.QCC_Departure_Local_Date__c = Date.valueOf('2019-09-26T00:43:35.000000050Z');
        firstHostRecord2.QCC_Flight_Departure_Time__c = timeNow;
        firstHostList.add(firstHostRecord2);
        
        //insert firstHostList; 
    }
    
    /*public static Event__c createEvent(){

    	Id recordTypeEventActive = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));

    	Event__c newEvent = new Event__c();

    	newEvent.RecordTypeId = recordTypeEventActive;

    	newEvent.Status__c = CustomSettingsUtilities.getConfigDataMap('Event Open Status');

    	newEvent.DelayFailureCode__c = 'Diversion Due to Weather';

    	newEvent.GoldBusiness__c = 1;

    	newEvent.GoldEconomy__c = 2;

    	newEvent.GoldFirstClass__c = 3;

    	newEvent.GoldPremiumEconomy__c = 4;

    	newEvent.NonTieredBusiness__c = 5;

    	newEvent.NonTieredEconomy__c = 6;

    	newEvent.NonTieredFirstClass__c = 7;

    	newEvent.NonTieredPremiumEconomy__c = 8;

    	newEvent.PlatinumBusiness__c = 9;

    	newEvent.PlatinumEconomy__c = 10;

    	newEvent.PlatinumFirstClass__c = 11;

    	newEvent.PlatinumPremiumEconomy__c = 12;

    	newEvent.Platinum1SSUBusiness__c = 13;

    	newEvent.Platinum1SSUEconomy__c = 14;

    	newEvent.Platinum1SSUFirstClass__c = 15;

    	newEvent.Platinum1SSUPremiumEconomy__c = 16;

    	newEvent.SilverBusiness__c = 17;

    	newEvent.SilverEconomy__c = 18;

    	newEvent.SilverFirstClass__c = 19;

    	newEvent.SilverPremiumEconomy__c = 20;

    	newEvent.BronzeBusiness__c = 21;

    	newEvent.BronzeEconomy__c = 22;

    	newEvent.BronzeFirstClass__c = 23;

    	newEvent.BronzePremiumEconomy__c = 24;

    	insert newEvent;

    	return newEvent;

    }*/

    
    static testMethod void testupdateFields2() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = 'PNR Health Check';
        String recordType = 'QCC Elite Process';
          
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');

        anyCase.contactId = watchlist.QCC_Contact__c;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'BluePrism ';
        anycase.Group__c = 'SPECIFIC-NEEDS';
        insert anyCase;
        System.assert(anycase != null);
        System.assertEquals('abuse', anyCase.Description);
     }
    
    static testMethod void testcaseDescriptionCheck(){
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = 'PNR Health Check';
        String recordType = 'QCC Elite Process';
          
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');

        anyCase.contactId = watchlist.QCC_Contact__c;
        anyCase.Description = 'abuse,test,descvription';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'BluePrism ';
        insert anyCase;
        CaseQCCTriggerHandler.caseDescriptionCheck(anyCase.Description);
        CaseQCCTriggerHandler.specificNeedsChange(anyCase,anyCase.recordtypeId);
        CaseQCCTriggerHandler.caseDescriptionCheck(anyCase.Description);
        CaseQCCTriggerHandler.specificNeedsChange(anyCase,anyCase.recordtypeId);
        //CaseQCCTriggerHandler.onBeforeInsert(new case().add(anyCase), new Map<String, Id>().put('QCC Elite Process',anyCase.recordtypeId), 
                                             //new List<Id>.add(anyCase.contactId),new List<String>().add('testReeference'));
        test.stopTest();
    }

    static testMethod void testassginCaseFields3() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = 'Complaint';
        String recordType = 'Specific Needs';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = watchlist.QCC_Contact__c;
        //anyCase.OwnerName__c = 'SSU Email Enquiries';
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'Qantas.com';
        anycase.Priority ='Critical';
        anyCase.Status = 'Reopened';
        insert anyCase;
        System.assert(anyCase != null);
        System.debug('anyCase.Type======> ' + anyCase);
 
        System.assertEquals('Complaint', anyCase.Type);
     }
 
     
    static testMethod void testUdateCaseSLA() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        insert cs;
        cs.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType'));
        cs.Type = 'Medical-Patient';
        cs.Group__c = 'Departure Airport';
        cs.Category__c = '';
        cs.Sub_Category__c = '';
        cs.Classification__c = '';
        cs.Assign_using_active_assignment_rules__c = true;
        update cs;
        System.assert(cs != null);
        //System.assertEquals('abuse', anyCase.Description);
        Test.stopTest();
    }
    
     static testMethod void testassginCaseFields() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = 'Complaint';
        String recordType = 'Specific Needs';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = watchlist.QCC_Contact__c;
        //anyCase.OwnerName__c = 'SSU Email Enquiries';
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'Specific Needs Email Enquiries';
        anycase.SuppliedEmail = 'test@sample.com';
        insert anyCase;
        System.assert(anyCase != null);
        System.debug('anyCase.Type======> ' + anyCase);

        System.assertEquals('Complaint', anyCase.Type);
     }

     
     static testMethod void testassginCaseFields1() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        
        
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_VIP_Email_Enquiries'];

        String type = 'Complaint';
        String recordType = 'Specific Needs';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = watchlist.QCC_Contact__c;
        //anyCase.OwnerName__c = 'QCC_VIP_Email_Enquiries';
        anyCase.OwnerId=caseGroup1.Id;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'VIP Service Team Email Enquiries';
        insert anyCase;

        System.assert(anyCase != null);
        System.assertEquals('Complaint', anyCase.Type);

     }

     
     static testMethod void testassginCaseFields2() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_SSU_Email_Enquiries'];
        String type = 'Complaint';
        String recordType = 'Specific Needs';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = watchlist.QCC_Contact__c;
        //anyCase.OwnerName__c = 'SSU Email Enquiries';
        anyCase.OwnerId=caseGroup1.Id;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'SSU Email Enquiries';
        insert anyCase;
        System.assert(anyCase != null);
        System.assertEquals('Complaint', anyCase.Type);
        
     }
    static testMethod void negetivefetchQueueNamesTest(){
        CaseQCCTriggerHandler.fetchQueueNames(null);
    }
     
    static testMethod void negetiveassginCaseFieldsTest(){
        CaseQCCTriggerHandler.assginCaseFields(null, null);
    }
    
    static testMethod void negetivefetchMetaObjectsByModuleNameTest(){
        CaseQCCTriggerHandler.fetchMetaObjectsByModuleName(null);
    }
    

    static testMethod void negetiveupdateHostNumberTest(){
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = con.Id;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        insert anyCase;
        CaseQCCTriggerHandler.updateHostNumber(anyCase, null);
    }

    
    static testMethod void testSensitiveCase() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Case cs;
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Test.startTest();
        cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Departure_Date_Time__c = '10/06/2018 16:50:00';
        cs.Actual_Arrival_Date_Time__c = '14/06/2018 14:55:00';
        cs.Status = 'In Progress';
        cs.Sensitive__c = true;    
        cs.Booking_PNR__c = 'ABXXXX';    
        insert cs;
        Test.stopTest();
        
    }
	/*
    static testMethod void updateTECHFields() {
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Case cs;
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
                    String offloadRT = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'QCC Offload Passenger');
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            //newEvent1.OwnerId = u1.Id;
 
            newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
            newEvent1.ScheduledDepTime__c = '19:15';
            newEvent1.ScheduledDepDate__c = Date.newInstance(2018, 06, 18);
            newEvent1.FlightNumber__c = 'QF0001';
            newEvent1.DeparturePort__c = 'SYD';
            newEvent1.ArrivalPort__c = 'MEL';
 
            insert newEvent1;
            Affected_Passenger__c afp = new Affected_Passenger__c();
            afp.Event__c = newEvent1.Id;
            afp.Name = 'Gold Frequentflyer'+1;
            afp.Passenger__c = con.Id;
            afp.RecordTypeId = offloadRT;
            afp.SendEmail__c  = false;
            afp.Affected__c = true;
            afp.ArrivalPort__c = 'MEL';
            afp.DeparturePort__c = 'SYD';
            afp.PNR__c = 'ABXXXX';
   
            insert afp;
        Test.startTest();
        
        cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        cs.ContactId = con.id;
        cs.Departure_Date_Time__c = '10/06/2018 16:50:00';
        cs.Actual_Arrival_Date_Time__c = '14/06/2018 14:55:00';
        cs.Status = 'Closed';
        cs.Sensitive__c = true;    
        cs.Booking_PNR__c = 'ABXXXX';    
        insert cs;
        
        Test.stopTest();
        Case objCase = [Select id, Status , ContactEmail , Sensitive__c, Priority from Case where Id = :cs.Id];
        if (objCase.Status.equals(CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')))
        {
            Case childCase = objCase.clone(false, true, false, true);
            childCase.ParentId = objCase.Id;
            childCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            childCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            childCase.Sensitive__c = false;
            insert childCase;
            childCase.Sensitive__c = true;
            update childCase;
        }
        else
        {
            objCase.Priority = CustomSettingsUtilities.getConfigDataMap('CaseStatusCritical');
            objCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
            objCase.Sensitive__c = false;
            update objCase;
            objCase.Sensitive__c = true;
            update objCase;
        }
    }
	*/

    static testMethod void assignCaseOwnerHotWordFirtClassPlatinum(){
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = con.Id;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        insert anyCase;
        Case res = [select Id , OwnerId  from Case where Id =: anyCase.Id];
      //  System.assert(string.valueOf(res.OwnerId).startsWith('00G'));
        Test.stopTest();
    }
    
    
    static testMethod void testupdateCaseHotwordQueueRouting() {
        Trigger_Status__c caseUpdateRoutingDetail = new Trigger_Status__c();
        caseUpdateRoutingDetail.Name = 'CaseHotwordQueueRoutingTrigger';
        caseUpdateRoutingDetail.Active__c = true;
        insert caseUpdateRoutingDetail;
            
         String type = 'Complaint';
            String recordType = 'CCC Complaints';
            Contact con = [SELECT Id, Name FROM Contact Limit 1];
            Case anyCase;
            Test.startTest();
            anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            anyCase.Description = 'Where my honey nuts at??';
            anyCase.contactId = con.Id;
            anycase.Assign_using_active_assignment_rules__c = true;
            insert anyCase;
                List<Case> amCaseList = new List<Case>();
               amCaseList.add(anyCase);
            
        List<String> hotWordList = new List<String>();
        hotWordList.add('element');
        String caseDescription='test';
        
        system.debug('amCaseList');
        Test.stopTest();
    }
   
    static testMethod void testPopulateBasicAutoCaseValues() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Contact> contacts = new List<Contact>();
            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='TestContact'+i, FirstName='User'+i, Email='testcon' + i +'@mailinator.com', Business_Types__c='Agency', Job_Role__c='Agency Manager',
                                          Function__c='Advisory Services', Frequent_Flyer_Number__c = '12345678' + i);
                contacts.add(con);
            }
            //insert contacts;
            //List<Contact> contacts = [SELECT Id, Name FROM Contact];
            System.debug('contacts======> ' + contacts);
            List<Case> cases = new List<Case>();
            Test.startTest();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight','','','');
                cs.ContactId = con.Id;
                cs.Origin = 'Qantas.com';
                cs.Flight_Number__c = 'QF0400';
                cs.SuppliedEmail = 'test@sample.com';
				cs.Channel_Type__c = 'Reimbursement Form';
                cases.add(cs);
            }
            insert cases;
            Test.stopTest();
            List<Case> updatedCases = [SELECT Id, status, FCR__c, Flight_Number__c, Assign_using_active_assignment_rules__c FROM Case];

            for(Integer i = 0; i < updatedCases.size(); i++) {
                System.assertEquals(false, updatedCases[i].Assign_using_active_assignment_rules__c);
            }
        }
    }
    
    
    static TestMethod void calculateEmergencyExpenseTest1(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Cabin_Class__c            = 'Business';
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'Domestic';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-40);
        anycase.Located_Date__c = system.today().adddays(40);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;
        
        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }
    
    
    static TestMethod void calculateEmergencyExpenseTest2(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Gold';
        update con;
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'Domestic';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-40);
        anycase.Located_Date__c = system.today().adddays(40);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;
        
        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }

    static TestMethod void calculateEmergencyExpenseTest3(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'Domestic';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-90);
        anycase.Located_Date__c = system.today().adddays(40);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;
        
        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }

    static TestMethod void calculateEmergencyExpenseTest4(){
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Gold';
        update con;
        Test.startTest();

        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);
        anyCase.ContactId = con.id;
        anyCase.Email_Template__c      = 'EFT Authorisation';
        anyCase.Damage_Sustained__c    = 'Completely destroyed;';
        anyCase.Repair_Cost_Numeric__c = 0;
        anyCase.Cabin_Class__c            = 'Business';
        anyCase.Description            = 'Testing this out';
        anyCase.Repair_Cost_Numeric__c = 0;
        anycase.Customer_Not_In_Home_Port__c = true;
        anycase.Flight_Type_Code__c = 'International';
        anycase.Arrival_UTC_Date_Time__c = system.now().addHours(-20);
        anycase.Located_Date__c = system.today().adddays(10);

        String day = String.valueOf(anycase.Arrival_UTC_Date_Time__c.day());
        day = day.length() == 1? '0'+day: day;
        String month = String.valueOf(anycase.Arrival_UTC_Date_Time__c.month());
        month = month.length() == 1? '0'+month: month;
        String year = String.valueOf(anycase.Arrival_UTC_Date_Time__c.year());
        String hour = String.valueOf(anycase.Arrival_UTC_Date_Time__c.hour());
        hour = hour.length() == 1? '0'+hour: hour;
        String minute = String.valueOf(anycase.Arrival_UTC_Date_Time__c.minute());
        minute = minute.length() == 1? '0'+minute: minute;
        String sec = String.valueOf(anycase.Arrival_UTC_Date_Time__c.second());
        sec = sec.length() == 1? '0'+sec: sec;

        String curday = String.valueOf(system.now().day());
        curday = curday.length() == 1? '0'+curday: curday;
        String curmonth = String.valueOf(system.now().month());
        curmonth = curmonth.length() == 1? '0'+curmonth: curmonth;
        String curyear = String.valueOf(system.now().year());
        String curhour = String.valueOf(system.now().hour());
        curhour = curhour.length() == 1? '0'+curhour: curhour;
        String curminute = String.valueOf(system.now().minute());
        curminute = curminute.length() == 1? '0'+curminute: curminute;
        String cursec = String.valueOf(system.now().second());
        cursec = cursec.length() == 1? '0'+cursec: cursec;
       
        anycase.Actual_Arrival_Date_Time__c = curday+'/'+curmonth+'/'+curyear+' '+ curhour+':'+curminute+':'+cursec;
        anycase.Arrival_Date_Time__c = day+'/'+month+'/'+year+' '+ hour+':'+minute+':'+sec;
        system.debug('anycase############'+anycase);
        insert anyCase;
        Test.stopTest();
    }

    
     /*----------------------------------------------------------------------------------------------      
    Method Name:        ReassignCaseWithWaitingStatus
    Description:        ReassignCaseWithWaitingStatus
    Parameter:          List<Case> listCase, Map<Id, Case> 
    ----------------------------------------------------------------------------------------------*/     
    
    static testMethod void testReassignCaseWithWaitingStatus() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'Specific Needs';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Specific Needs','', '', '');
        cs.ContactId = con.id;
        //Test coverage 
        cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Customer';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }

    
     /*----------------------------------------------------------------------------------------------      
    Method Name:        ReassignCaseWithWaitingStatus
    Description:        ReassignCaseWithWaitingStatus
    Parameter:          List<Case> listCase, Map<Id, Case> 
    ----------------------------------------------------------------------------------------------*/     
    
    static testMethod void testReassignCaseWithWaitingStatus1() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'Specific Needs';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.SSU__c = true;
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Specific Needs','', '', '');
        cs.ContactId = con.id;
        //Test coverage 
        cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Customer';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }

    
     /*----------------------------------------------------------------------------------------------      
    Method Name:        testReassignCaseWithWaitingStatus2
    Description:        ReassignCaseWithWaitingStatus
    Parameter:          List<Case> listCase, Map<Id, Case> 
    ----------------------------------------------------------------------------------------------*/     
    
    static testMethod void testReassignCaseWithWaitingStatus2() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'Specific Needs';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.SSU__c = true;
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Specific Needs','', '', '');
        cs.ContactId = con.id;
        //Test coverage 
        cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Internal';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }

    
     /*----------------------------------------------------------------------------------------------      
    Method Name:        testReassignCaseWithWaitingStatus3
    Description:        ReassignCaseWithWaitingStatus
    Parameter:          List<Case> listCase, Map<Id, Case> 
    ----------------------------------------------------------------------------------------------*/     
    
    static testMethod void testReassignCaseWithWaitingStatus3() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'CCC Baggage';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.SSU__c = true;
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);

        cs.ContactId = con.id;
        //Test coverage 
        //cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Internal';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }


    static testMethod void testReassignCaseWithWaitingStatus6() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'CCC Baggage';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.SSU__c = true;
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);

        cs.ContactId = con.id;
        //Test coverage 
        //cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Customer';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }
    
    static testMethod void testReassignCaseWithWaitingStatus4() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'CCC Baggage';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.SSU__c = true;
        update con;
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);

        cs.ContactId = con.id;
        //Test coverage 
        //cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Customer';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }
    
    static testMethod void testReassignCaseWithWaitingStatus5() {
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'CCC Baggage';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        con.SSU__c = true;
        update con;
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Baggage' , 'Baggage', 'Damaged Baggage', 'Checked Baggage', null,null);

        cs.ContactId = con.id;
        //Test coverage 
        //cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        system.debug('ReassignCase##bftest ');
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Internal';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();                                                            
    }

    static testMethod void testInsuranceLettertype() {
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];

        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Delayed Flight', '', '', '');
        cs.ContactId = con.id;
        cs.OwnerId=caseGroup1.Id;
        cs.Assign_using_active_assignment_rules__c = true;
        insert cs;
        
      //  System.assertEquals(conga.Id, objCase.Conga_Email_Template_ID__c);
      //  System.assertEquals(templates.Id, objCase.Conga_Template_ID__c);
        Test.stopTest();
    }

    /*
    static testMethod void testupdateHostNumber() {

        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'ReassignCaseWithWaitingStatus';
        ts.Active__c = true;
        insert ts;
        
        String type = 'Specific Needs';
        String recordType = 'Specific Needs';
        Test.startTest();
        Contact con = [SELECT Id, Name FROM Contact Limit 1];
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_Specific_Needs_Waiting_for_Customer'];
        Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Specific Needs','', '', '');
        cs.ContactId = con.id;
        //Test coverage 
        cs.Type='Specific Needs';
        //cs.Status='Waiting for Customer';
        cs.Status='New';
        cs.OwnerId=caseGroup1.Id;
        cs.Description = 'Ref# 1234';
        system.debug('ReassignCase##bftest ');

        
        //Casetriggerhelper.ReassignCaseWithWaitingStatus(listCase, mapOldMap);
        Test.stopTest();      

        
        //Create test data for Airport Code to be used in QHost record creation
        Airport_Code__c airportCodeRecord3 = QCC_TestDataFactory.createAirportCodeTestData();
        airportCodeRecord3.Name = 'MEL';
        insert airportCodeRecord3;
        
        //Create test data for Qantas Host
        List<QCC_First_Host__c> qantasHostList = new List<QCC_First_Host__c>();
        QCC_First_Host__c qantasHostRecord = QCC_TestDataFactory.createFirstHostTestData(con.Id, airportCodeRecord3.Id);
        qantasHostRecord.QCC_Flight_No__c = '0001';
        qantasHostRecord.QCC_Carrier_Code__c = 'QF';
        qantasHostList.add(qantasHostRecord);
        //insert qantasHostList;
        //QCC_First_Host__c fsthost = [SELECT Id, QCC_First_Host_Contact__c from QCC_First_Host__c LIMIT 1];
        insert cs;
        List<Case> listCase = new List<Case>();
        
        
        Map<id,case> mapOldMap = new Map<id,case>();
        mapOldMap.put(cs.Id,cs);
        listCase.add(cs);
        //casetriggerhelper cs1 = new casetriggerhelper();
        
        //Test coverage
        system.debug('ReassignCase##test '+ cs.status);
        cs.Status = 'Waiting for Customer';
        
        update cs;
        system.debug('ReassignCase##testaf '+cs.status);
        
    }
	*/

    
    static testMethod void testSegregateEmailMsgBodyAndFooter() {
        List<String> emailMsgs = new List<String>();
        
       
        
        emailMsgs.add('<h1>________________________________ From: xyx@gmail.com</h1>');
        
        List<String> testResp = new List<String>();
        Test.startTest();
           testResp = CaseTriggerHandler.segregateEmailMsgBodyAndFooter(emailMsgs);
        Test.stopTest();
        
        System.assert(testResp.size() > 0);
        
    }
    
    static testMethod void onBeforeUpdateTest1() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = 'PNR Health Check';
        String recordType = 'QCC Elite Process';
          
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        con.SSU__c = true;
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        anyCase.contactId = watchlist.QCC_Contact__c;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'BluePrism ';
        insert anyCase;
        
        
        String RT_SPECIFICNEEDS = CustomSettingsUtilities.getConfigDataMap('RT_QCC_Specific_Needs');
        Map<String, Id> recordTypeMap = new map<string,id>();
        recordTypeMap.put(RT_SPECIFICNEEDS,anycase.recordtypeid);
        
        anyCase.Status = CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Customer');
        CaseQCCTriggerHandler.reassignCaseWithWaitingStatus(anyCase,anyCase,recordTypeMap,con);
        
        anyCase.Status = CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Internal');
        CaseQCCTriggerHandler.reassignCaseWithWaitingStatus(anyCase,anyCase,recordTypeMap,con);
        
        recordTypeMap = new map<string,id>();
        anyCase.Status = CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Customer');
        CaseQCCTriggerHandler.reassignCaseWithWaitingStatus(anyCase,anyCase,recordTypeMap,con);
        
        anyCase.Status = CustomSettingsUtilities.getConfigDataMap('Case Status Waiting for Customer');
        CaseQCCTriggerHandler.reassignCaseWithWaitingStatus(anyCase,anyCase,recordTypeMap,null);
        
    }
    
     static testMethod void testOnBeforeUpdateTest() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = 'PNR Health Check';
        String recordType = 'QCC Elite Process';
          
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        con.SSU__c = true;
        update con;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628
        User u1 = new User(LastName = 'User143', Alias = 'User', Email = 'sampleuser143@sample.com', 
             Username = 'sampleuser1username143@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
             EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
             TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
             );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> PermissionsetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');        
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        
        Test.startTest();
        Group caseGroup1 = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'QCC_SSU_Email_Enquiries'];
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        anyCase.contactId = watchlist.QCC_Contact__c;
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'BluePrism ';
        anyCase.status = 'In Progress';
        anyCase.OwnerId = caseGroup1.Id;
        insert anyCase;
        
        Case anyCase1 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, '', '', '', '');
        anyCase1.contactId = watchlist.QCC_Contact__c;
        anyCase1.Description = 'abuse';
        anyCase1.Cabin_Class__c = 'First';
        anycase1.Assign_using_active_assignment_rules__c = true;
        anycase1.Origin = 'BluePrism ';
        anyCase1.ownerId = u1.id;
        anyCase1.status = 'Closed';
        insert anyCase1;
        CaseQCCTriggerHandler.caseStatusUpdated(anyCase1, anyCase);   
    }
   
    static testMethod void testassginCaseFields4() {
        QCC_Contact_Watchlist__c watchlist = [SELECT Id, QCC_Contact__c from QCC_Contact_Watchlist__c LIMIT 1];
        String type = '';
        String recordType = 'Specific Needs';
        Contact con = [SELECT Id, Name , Frequent_Flyer_Tier__c FROM Contact Limit 1];
        con.Frequent_Flyer_Tier__c = 'Platinum';
        update con;
        Test.startTest();
        Case anyCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
        anyCase.contactId = watchlist.QCC_Contact__c;
        //anyCase.OwnerName__c = 'SSU Email Enquiries';
        anyCase.Description = 'abuse';
        anyCase.Cabin_Class__c = 'First';
        anycase.Assign_using_active_assignment_rules__c = true;
        anycase.Origin = 'Specific Needs Email Enquiries';
        anycase.SuppliedEmail = 'test@sample.com';
        insert anyCase;
        Test.stopTest();
        System.assert(anyCase != null);
        System.debug('anyCase.Type======> ' + anyCase);
     }
    
    
    static testMethod void testException1(){
        CaseQCCTriggerHandler.specificNeedsChange(null,null);
        CaseQCCTriggerHandler.updateDepartureDateField(null,null);
        CaseQCCTriggerHandler.updateCaseLastQueueOwnerFieldValue(null,null);
        //CaseQCCTriggerHandler.populateBasicAutoCaseValues(null);
        CaseQCCTriggerHandler.fetchValidateParentCaseRecords(null,null);
    }
    
    static testMethod void testQCCAssignFields(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Musical Baggage Queue','CCC_Musical_Baggage_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Japan Queue','CCC_Japan_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC OneWorld Helpdesk Queue','CCC_OneWorld_Helpdesk_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Emirates Helpdesk Queue','CCC_Emirates_Helpdesk_Queue'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Korean Queue','CCC_Korean_Queue'));
        insert lstConfigData;
        
        Group qccKoreanGroups = [Select Id from Group where Type = 'Queue' AND DeveloperName ='CCC_Korean_Queue'];
        Group qccEKGroups = [Select Id from Group where Type = 'Queue' AND DeveloperName ='CCC_Emirates_Helpdesk_Queue'];
        Group qccOWGroups = [Select Id from Group where Type = 'Queue' AND DeveloperName ='CCC_OneWorld_Helpdesk_Queue'];
        Group qccJapanGroups = [Select Id from Group where Type = 'Queue' AND DeveloperName ='CCC_Japan_Queue'];
        Group qccMusicGroups = [Select Id from Group where Type = 'Queue' AND DeveloperName ='CCC_Musical_Baggage_Queue'];
        
        Test.startTest();
        List<Case> lstQCCCase = new List<Case>();
        Case anyQCCCase = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Query', 'Query', '', '', '', '');
        anyQCCCase.Origin = 'Email';
        anyQCCCase.ownerId = qccKoreanGroups.id;
        lstQCCCase.add(anyQCCCase);
        
        Case anyQCCCase1 = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Query', 'Query', '', '', '', '');
        anyQCCCase1.Origin = 'Email';
        anyQCCCase1.ownerId = qccEKGroups.id;
        lstQCCCase.add(anyQCCCase1);
        
        Case anyQCCCase2 = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Query', 'Query', '', '', '', '');
        anyQCCCase2.Origin = 'Email';
        anyQCCCase2.ownerId = qccOWGroups.id;
        lstQCCCase.add(anyQCCCase2);
        
        Case anyQCCCase3 = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Query', 'Query', '', '', '', '');
        anyQCCCase3.Origin = 'Email';
        anyQCCCase3.ownerId = qccJapanGroups.id;
        lstQCCCase.add(anyQCCCase3);
        
        Case anyQCCCase4 = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Query', 'Query', '', '', '', '');
        anyQCCCase4.Origin = 'Email';
        anyQCCCase4.ownerId = qccMusicGroups.id;
        lstQCCCase.add(anyQCCCase4);
        
        Insert lstQCCCase;
        
        CaseQCCTriggerHandler.assignQCCFields(anyQCCCase);
        CaseQCCTriggerHandler.assignQCCFields(anyQCCCase1);
        CaseQCCTriggerHandler.assignQCCFields(anyQCCCase2);
        CaseQCCTriggerHandler.assignQCCFields(anyQCCCase3);
        CaseQCCTriggerHandler.assignQCCFields(anyQCCCase4);
        Test.stopTest();
    }
}