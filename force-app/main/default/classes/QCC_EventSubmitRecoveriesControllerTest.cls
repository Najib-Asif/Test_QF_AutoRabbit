@isTest
private class QCC_EventSubmitRecoveriesControllerTest {
	
	private static List<Contact> listContactTest = new List<Contact>();
	@testSetup
    static void createTestData(){
    	TestUtilityDataClassQantas.insertQantasConfigData();
    	List<Trigger_Status__c> listConfigEventTrigger = TestUtilityDataClassQantas.createEventTriggerSetting();
    	insert listConfigEventTrigger;
    	List<Trigger_Status__c> listConfigContactTrigger =  TestUtilityDataClassQantas.createContactTriggerSetting();
    	insert listConfigContactTrigger;
    	List<Trigger_Status__c> listConfigRecoveryTrigger =  TestUtilityDataClassQantas.createRecoveryTriggerSetting();
    	insert listConfigRecoveryTrigger;
        List<Trigger_Status__c> listConfigAffectedPassengerTrigger = TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting();
        insert listConfigAffectedPassengerTrigger;

        List<Trigger_Status__c> listTriggerStatusUpdate = [SELECT Id, Active__c FROM Trigger_Status__c];

        for(Trigger_Status__c triggerStatus : listTriggerStatusUpdate){
            triggerStatus.Active__c = false;
        }
        update listTriggerStatusUpdate;
    	// Create Account
    	List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
    	// CRETAE contact
    	List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
    	// create eVENT
    	Event__c eventTest = createEvent();

    	// CREATE affected Passenger
    	List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(eventTest.Id, listContactTest);

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
			passenger.Passenger__c = listContact[i-1].Id;
			passenger.Event__c = eventId;
			passenger.Email__c = String.valueOf(i) + 'afftest@testabc.com';
			passenger.Cabin__c ='First Class'; 
			passenger.FF_Tier__c = 'Silver';
            passenger.FrequentFlyerTier__c ='Silver';
			if(i == 2){
				passenger.Cabin__c ='Business'; 
				passenger.FF_Tier__c = 'Non-Tiered';
                passenger.FrequentFlyerTier__c = 'Non-Tiered';
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
	@isTest static void testcreateRecoveries() {
		
        List<Event__c> eventSubmitted = [SELECT Id FROM Event__c];
		Test.startTest();
			String messageResult = QCC_EventSubmitRecoveriesController.createRecoveries(eventSubmitted[0].Id); 
		Test.stopTest();
		System.assertEquals(CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Initializing'), messageResult);
	}

	@isTest static void testEventRecoveriesCreated() {
		List<Event__c> eventSubmitted = [SELECT Id, RecoveryIsCreated__c FROM Event__c];
        eventSubmitted[0].RecoveryIsCreated__c = true;
        update eventSubmitted;
		Test.startTest(); 
			String messageResult = QCC_EventSubmitRecoveriesController.createRecoveries(eventSubmitted[0].Id); 
		Test.stopTest();
		System.assertEquals(CustomSettingsUtilities.getConfigDataMap('Recovery Submitted Error Message'), messageResult);
	}
	@isTest static void testEventNoAffectedPassenger() {
		List<Event__c> eventSubmitted = [SELECT Id, RecoveryIsCreated__c FROM Event__c];
        List<Affected_Passenger__c> affectedPassengers = [SELECT Id FROM Affected_Passenger__c where Event__c =: eventSubmitted[0].Id];
        delete affectedPassengers;
		Test.startTest(); 
			String messageResult = QCC_EventSubmitRecoveriesController.createRecoveries(eventSubmitted[0].Id); 
		Test.stopTest();
		System.assertEquals(CustomSettingsUtilities.getConfigDataMap('Recovery Submitted No Passenger Msg'), messageResult);
	}
	
}