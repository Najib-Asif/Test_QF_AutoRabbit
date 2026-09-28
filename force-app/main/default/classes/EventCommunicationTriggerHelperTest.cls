@isTest
private class EventCommunicationTriggerHelperTest
{
    static 
    {
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> listTriggerConfigs = new List<Trigger_Status__c>();
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createFlightFailureSetting());
        
        for(Trigger_Status__c triggerStatus : listTriggerConfigs){
            if(triggerStatus.Name != 'EventTriggerCreateEventComms'){
                triggerStatus.Active__c = false;
            }
            
        }
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventCommunicationTriggerSetting());
        insert listTriggerConfigs;
        // Create Account
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        // CRETAE contact
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        // create eVENT
        

    }

    private static Event__c createEvent(String eventType){
        Id recordTypeEventActive = GenericUtils.getObjectRecordTypeId('Event__c', eventType);
        Event__c newEvent = new Event__c();
        newEvent.RecordTypeId = recordTypeEventActive;
        newEvent.Status__c = CustomSettingsUtilities.getConfigDataMap('Event Open Status');
        newEvent.DelayFailureCode__c = 'Diversion Due to Weather';
        newEvent.DeparturePort__c='SYD';
        newEvent.ArrivalPort__c='MEL';
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
    }
    
    private static List<Affected_Passenger__c> createAffectedPassenger(Id eventId, List<Contact> listContact){
        List<Affected_Passenger__c> listAffectedPassenger = new List<Affected_Passenger__c>();
        for(Integer i = 1; i <= listContact.size(); i++){
            Affected_Passenger__c passenger = new Affected_Passenger__c();
            passenger.Affected__c = true;
            passenger.Name = 'AFDP-TEST' + String.valueOf(i);
            passenger.Failure_Code__c = 'Diversion Due to Weather';
            passenger.Passenger__c = listContact[i-1].Id;
            passenger.Event__c = eventId;
            passenger.Email__c = String.valueOf(i) + 'afftest@testabc.com';
            passenger.Cabin__c ='First Class'; 
            passenger.FF_Tier__c = 'Silver';
            passenger.FrequentFlyerTier__c ='Silver';
            passenger.RecoveryIsCreated__c = false;
            passenger.TECH_PreFlight__c = true;
            passenger.TECH_PostFlight__c = true;

            if(i == 2){
                passenger.Cabin__c ='Business'; 
                passenger.FF_Tier__c = 'Non-Tiered';
                passenger.FrequentFlyerTier__c = 'Non-Tiered';
                passenger.FrequentFlyerNumber__c = '0006142209';
                passenger.DeparturePort__c='SYD';
                passenger.ArrivalPort__c='JFK';
            }
            if(i == 3){
                passenger.Cabin__c ='Premium Economy'; 
                passenger.FF_Tier__c = 'Gold';
                passenger.FrequentFlyerTier__c = 'Gold';
                passenger.DeparturePort__c='SYD';
                passenger.ArrivalPort__c='MEL';
            }

            listAffectedPassenger.add(passenger);
        }
        System.debug(listAffectedPassenger);
        insert listAffectedPassenger;
        return listAffectedPassenger;
    }

    @isTest
    static void test1(){
        Event__c eventTest = createEvent('Flight Event - Active');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;
        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);

        eventTest.Status__c = 'Assigned';
        update eventTest;
    }

    

    @isTest
    static void test1a(){
        Event__c eventTest = createEvent('Flight Event - Active');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);
        objFF.OnlyLeg__c = true;
        update objFF;
        eventTest.Status__c = 'Assigned';
        update eventTest;

    }

    @isTest
    static void test1b(){
        Event__c eventTest = createEvent('Flight Event - Active');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);
        
        eventTest.Status__c = 'Assigned';
        update eventTest;
        objFF.OnlyLeg__c = true;
        update objFF;
    }

    @isTest
    static void test1c(){
        Event__c eventTest = createEvent('Flight Event - Active');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Lights';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);
        
        eventTest.Status__c = 'Assigned';
        update eventTest;
        objFF.OnlyLeg__c = true;
        update objFF;
    }

    @isTest
    static void test1d(){
        Event__c eventTest = createEvent('Flight Event - Active');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Lights';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        FlightFailure__c objFF1 = new FlightFailure__c();
        objFF1.Flight_Event__c = eventTest.Id;
        objFF1.Failure_Code__c = 'Wifi';
        objFF1.Affected_Region__c = 'Full Flight';
        objFF1.Affect_Sub_Section__c = 'Full Flight';
        objFF1.Pre_Flight__c = true; 
        objFF1.Post_Flight__c = true;
        insert objFF1;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);
        
        eventTest.Status__c = 'Assigned';
        update eventTest;
    }

    @isTest
    static void test1e(){
        Event__c eventTest = createEvent('Flight Event - Active');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Toilets';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);
        objFF.OnlyLeg__c = true;
        update objFF;
        eventTest.Status__c = 'Assigned';
        update eventTest;

    }

    @isTest
    static void test1f(){
        Event__c eventTest = createEvent('Flight Event - Active');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Lights';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        FlightFailure__c objFF1 = new FlightFailure__c();
        objFF1.Flight_Event__c = eventTest.Id;
        objFF1.Failure_Code__c = 'Wifi';
        objFF1.Affected_Region__c = 'Full Flight';
        objFF1.Affect_Sub_Section__c = 'Full Flight';
        objFF1.Pre_Flight__c = true; 
        objFF1.Post_Flight__c = true;
        insert objFF1;

        FlightFailure__c objFF2 = new FlightFailure__c();
        objFF2.Flight_Event__c = eventTest.Id;
        objFF2.Failure_Code__c = 'Air Turn Back';
        objFF2.Affected_Region__c = 'Full Flight';
        objFF2.Affect_Sub_Section__c = 'Full Flight';
        objFF2.Pre_Flight__c = true; 
        objFF2.Post_Flight__c = true;
        insert objFF2;

        FlightFailure__c objFF3 = new FlightFailure__c();
        objFF3.Flight_Event__c = eventTest.Id;
        objFF3.Failure_Code__c = 'Flight Delay';
        objFF3.Affected_Region__c = 'Full Flight';
        objFF3.Affect_Sub_Section__c = 'Full Flight';
        objFF3.Pre_Flight__c = true; 
        objFF3.Post_Flight__c = true;
        insert objFF3;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);
        
        eventTest.Status__c = 'Assigned';
        update eventTest;
    }

    @isTest
    static void test2(){
        Event__c eventTest = createEvent('Global Event');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);

        eventTest.Status__c = 'Assigned';
        update eventTest;
    }

    @isTest
    static void test3(){
        Event__c eventTest = createEvent('Global Event');

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;
        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);

        eventTest.Status__c = 'Assigned';
        update eventTest;

        EventCommunication__c objEvtComms = new EventCommunication__c();
        objEvtComms.IsGenericContent__c = true;
        objEvtComms.ApologyParagraph__c = 'No reason';
        objEvtComms.RecoveryParagraph__c = 'No reason';
        objEvtComms.IntroParagraph__c = 'No reason';
        objEvtComms.ReasonParagraph__c = 'No reason';
        objEvtComms.OnlyLeg__c = true;
        insert objEvtComms;
    }

    @isTest
    static void test4(){
        Event__c eventGlobalTest = createEvent('Global Event');

        Event__c eventTest = createEvent('Flight Event - Active');


        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;

        insert objFF;
        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);

        eventTest.Status__c = 'Assigned';
        eventTest.GlobalEvent__c = eventGlobalTest.Id;
        update eventTest;

        EventCommunication__c globalEcoms = new EventCommunication__c();
        globalEcoms.IsGlobalEventComms__c = true;
        globalEcoms.FlightEvent__c = eventGlobalTest.Id;

        insert globalEcoms;

        EventCommunication__c objEvtComms = [Select Id, IsGlobalEventComms__c, ApologyParagraph__c, ReasonParagraph__c, 
                                                RecoveryParagraph__c , IntroParagraph__c  From EventCOmmunication__c LIMIT 1];
        //globalEcoms.IsGenericContent__c = true;
        //globalEcoms.ApologyParagraph__c = 'No reason';
        globalEcoms.RecoveryParagraph__c = 'No reason';
        //globalEcoms.IntroParagraph__c = 'No reason';
        //globalEcoms.ReasonParagraph__c = 'No reason';
        update globalEcoms;
    }

    @isTest
    static void test5(){
        Event__c eventGlobalTest = createEvent('Global Event');

        Event__c eventTest = createEvent('Flight Event - Active');


        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        
        insert objFF;

        List<Contact> listContactTest = [select id from contact];
        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);

        EventCommunication__c globalEcoms = new EventCommunication__c();
        globalEcoms.IsGlobalEventComms__c = true;
        globalEcoms.FlightEvent__c = eventGlobalTest.Id;

        insert globalEcoms;
        objFF.OnlyLeg__c = true;
        update objFF;

        eventTest.Status__c = 'Assigned';
        eventTest.GlobalEvent__c = eventGlobalTest.Id;
        update eventTest;

        EventCommunication__c objEvtComms = [Select Id, IsGlobalEventComms__c, ApologyParagraph__c, ReasonParagraph__c, 
                                                RecoveryParagraph__c , IntroParagraph__c  From EventCOmmunication__c LIMIT 1];
        //globalEcoms.IsGenericContent__c = true;
        //globalEcoms.ApologyParagraph__c = 'No reason';
        globalEcoms.RecoveryParagraph__c = 'No reason';
        //globalEcoms.IntroParagraph__c = 'No reason';
        //globalEcoms.ReasonParagraph__c = 'No reason';
        update globalEcoms;
    }
}