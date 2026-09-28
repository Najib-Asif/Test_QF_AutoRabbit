@isTest
private class QCC_EventSubmitRecoveriesBatchableTest {

	private static List<Contact> listContactTest = new List<Contact>();
	@testSetup
    static void createTestData(){
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
    	List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
    	// create eVENT
    	Event__c eventTest = createEvent();

        FlightFailure__c objFF = new FlightFailure__c();
        objFF.Flight_Event__c = eventTest.Id;
        objFF.Failure_Code__c = 'Diversion Due to Weather';
        objFF.Affected_Region__c = 'Full Flight';
        objFF.Affect_Sub_Section__c = 'Full Flight';
        objFF.Pre_Flight__c = true; 
        objFF.Post_Flight__c = true;
        insert objFF;

        
    	// CREATE affected Passenger
    	List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);

        eventTest.Status__c = 'Assigned';
        update eventTest;

    }

    private static Event__c createEvent(){
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
                passenger.FrequentFlyerNumber__c = '00000000000001';
			}
			if(i == 3){
				passenger.Cabin__c ='Premium Economy'; 
				passenger.FF_Tier__c = 'Gold';
                passenger.FrequentFlyerTier__c = 'Gold';
			}

			listAffectedPassenger.add(passenger);
		}
		insert listAffectedPassenger;
		return listAffectedPassenger;
	}

    /*private static List<Trigger_Status__c> createContactTriggerStatus(){
       // List<Trigger_Status__c> co
        //return Trigger_Status__c
    }*/
	@isTest static void testEventSubmitRecoveriesBatch() {
		// Implement test code
		Test.startTest();
        List<Event__c> eventSubmitted = [SELECT Id FROM Event__c];
        System.debug([SELECT Id, Name, Passenger__c,Affected__c,  TECH_OfferedQantasPoints__c, Passenger__r.LastName, FirstName__c, LastName__c, 
             Event__c, Email__c, Cabin__c, Passenger__r.Frequent_Flyer_Tier__c, FrequentFlyerTier__c, FrequentFlyerNumber__c
             FROM Affected_Passenger__c Where Event__c =: eventSubmitted[0].Id ]);
        System.debug(eventSubmitted[0].Id );
		Id jobId = Database.executeBatch(new QCC_EventSubmitNonFFRecoveriesBatchable(eventSubmitted[0].Id), 50); 
		Id jobId2 = Database.executeBatch(new QCC_EventSubmitFFContRecoveriesBatchable(eventSubmitted[0].Id), 50); 
		
		Test.stopTest();

		List<Affected_Passenger__c> listAffectedUpdated = [SELECT Id, RecoveryIsCreated__c FROM Affected_Passenger__c WHERE Event__c =: eventSubmitted[0].Id AND RecoveryIsCreated__c = true]; 
		//Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id FROM Case WHERE Event__c =: eventSubmitted[0].Id]);
		//List<Recovery__c> listRecovery = [SELECT Id FROM Recovery__c WHERE Case_Number__c IN: mapCases.keySet()];
		//System.assertEquals(3, listAffectedUpdated.size());
	}
	
}