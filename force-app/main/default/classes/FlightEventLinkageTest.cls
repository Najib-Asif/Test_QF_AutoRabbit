@isTest
private class FlightEventLinkageTest {

    @testSetup
    static void createData() {
        Test.StartTest();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic','Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic','Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode International','International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational','   Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible','Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed','Closed'));
        insert lstConfigData;
        
        //Create test data for Airport object
        Airport_Code__c dCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c  ='NSW');
        insert dCode;
        Airport_Code__c aCode = new Airport_Code__c(Name = 'MEL', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Melbource', Freight_Airport_State_Code__c  ='NSW');
        insert aCode;

        Map<String, Profile> profileMap = TestUtilityDataClassQantas.getProfileMap();
        User userRecord = new User(
            LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
            Username = 'sampleuser1username@sample.com', ProfileId = profileMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
            TimeZoneSidKey = 'Australia/Sydney'
        ); 
        insert userRecord;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = userRecord.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }
        
        System.runAs(userRecord) {
            Account acc = TestUtilityDataClassQantas.createAccountOfQantasCorporateEmailAccount();
            acc.ABN_Tax_Reference__c = '11111111111';
            insert acc;
            
            Contact con = TestUtilityDataClassQantas.createIndividualContact(acc.Id);
            con.Business_Types__c = 'Agency';
            con.Job_Role__c       = 'Other';
            con.Function__c       = 'Other';
            con.AccountId         = acc.id;
            insert con;
            
            List<Event__c> events = new List<Event__c>();
            Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent1.OwnerId = userRecord.Id;
            newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
            newEvent1.ScheduledDepTime__c = '19:15';
            newEvent1.ScheduledDepDate__c = Date.newInstance(2018, 06, 18);
            newEvent1.FlightNumber__c = 'QF0001';
            newEvent1.DeparturePort__c = 'SYD';
            newEvent1.ArrivalPort__c = 'MEL';
            events.add(newEvent1);
            Event__c newEvent2    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent2.OwnerId = userRecord.Id;
            newEvent2.FlightNumber__c = 'QF0002';
            newEvent2.DeparturePort__c = 'SYD';
            newEvent2.ArrivalPort__c = 'MEL';
            newEvent2.Non_Delay_Failure_Code__c = 'A/C Downgrade';
            newEvent2.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
            newEvent2.ScheduledDepTime__c = '19:15';
            newEvent2.ScheduledDepDate__c = System.today();
            newEvent2.Overnight__c = 'Confirmed Overnight';
            events.add(newEvent2);
            Event__c newEvent3    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent3.OwnerId = userRecord.Id;
            newEvent3.DeparturePort__c = 'SYD';
            newEvent3.ArrivalPort__c = 'MEL';
            newEvent3.FlightNumber__c = 'QF0003';
            newEvent3.ScheduledDepDate__c = System.today();
            newEvent3.ScheduledDepTime__c = '19:15';
            events.add(newEvent3);
            
            Event__c newEvent4    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent4.OwnerId = userRecord.Id;
            newEvent4.FlightNumber__c = 'QF0004';
            newEvent4.DeparturePort__c = 'SYD';
            newEvent4.ArrivalPort__c = 'MEL';
            newEvent4.ScheduledDepTime__c = '19:15';
            newEvent4.ScheduledDepDate__c = System.today();
            newEvent4.DelayFailureCode__c = 'Flight Cancellation';
            events.add(newEvent4);
            insert events;
            
            List<Affected_Passenger__c> afpList = new List<Affected_Passenger__c>(); 
            Integer i = 1;
            for(Event__c event: [SELECT Id, DelayFailureCode__c, Non_Delay_Failure_Code__c FROM Event__c]) {
                Affected_Passenger__c afp = new Affected_Passenger__c();
                afp.Event__c = event.Id;
                afp.Name = 'Gold Frequentflyer'+i;
                afp.Passenger__c = con.Id;
                afp.SendEmail__c  = false;
                afp.PNR__c = '123456';
                if(event.DelayFailureCode__c != null) {
                    afp.TECH_PostFlight__c = true;
                    afp.TECH_PreFlight__c = true;
                } else if(event.Non_Delay_Failure_Code__c != null && event.Non_Delay_Failure_Code__c != 'Flight Cancellation') {
                    afp.TECH_PostFlight__c = true;
                } else if(event.DelayFailureCode__c == 'Flight Cancellation') {
                    afp.TECH_PreFlight__c = true;
                    afp.SendEmail__c = true;
                    afp.OffloadRequest__c = null;
                }
                afpList.add(afp);
                i++;
            }
            insert afpList;
        }
    }
    
    @istest 
    static void testFlightEventsLinkage() {
        Id rtIdVoice = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('CCC_Voice_RecordTypeDevName')).getRecordTypeId();
        Case caseRecord = new Case(RecordTypeId = rtIdVoice, Booking_PNR__c='123456');
        insert caseRecord;
        Event__c eventRecord = [ SELECT Name FROM Event__c LIMIT 1 ];
        FlightEventLinkage.getFlightEvents(caseRecord.Id);
        FlightEventLinkage.getLinkedFlightIdsFromCase(caseRecord.Id);
        FlightEventLinkage.createLinkedFlightEvents(caseRecord.Id, eventRecord);
     }
    
    @istest 
    static void testFlightEventsLinkageNegative() {
        FlightEventLinkage.getFlightEvents(null);
        FlightEventLinkage.getLinkedFlightIdsFromCase(null);
        FlightEventLinkage.createLinkedFlightEvents(null, null);
     }
}