@isTest
private class QCC_EmailPreviewControllerTest
{
	@TestSetUp
	static void TestSetUp()
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
                passenger.FrequentFlyerNumber__c = '0006142209';
			}
			if(i == 3){
				passenger.Cabin__c ='Premium Economy'; 
				passenger.FF_Tier__c = 'Gold';
                passenger.FrequentFlyerTier__c = 'Gold';
			}

			listAffectedPassenger.add(passenger);
		}
		System.debug(listAffectedPassenger);
		insert listAffectedPassenger;
		return listAffectedPassenger;
	}

	@isTest
	static void testFetchEmailContent(){
		EventCommunication__c objEvtComms = [Select Id, IsGlobalEventComms__c From EventCOmmunication__c];
		QCC_EmailPreviewController.fetchEmailContent(objEvtComms.Id);
	}

	@isTest
	static void testFetchEmailContent2(){
		EventCommunication__c objEvtComms = [Select Id, IsGlobalEventComms__c From EventCOmmunication__c];
		QCC_EmailPreviewController.fetchEmailContent(objEvtComms.Id, 'FFRecovery');
	}

	@isTest
	static void testFetchEmailContent3(){
		EventCommunication__c objEvtComms = [Select Id, IsGlobalEventComms__c From EventCOmmunication__c];
		QCC_EmailPreviewController.fetchEmailContent(objEvtComms.Id, 'NFFRecovery');
	}

	@isTest
	static void testFetchEmailContent4(){
		EventCommunication__c objEvtComms = [Select Id, IsGlobalEventComms__c, ApologyParagraph__c, ReasonParagraph__c, 
												RecoveryParagraph__c , IntroParagraph__c  From EventCOmmunication__c];
		objEvtComms.IsGenericContent__c = true;
		objEvtComms.ApologyParagraph__c = 'No reason';
		objEvtComms.RecoveryParagraph__c = 'No reason';
		objEvtComms.IntroParagraph__c = 'No reason';
		objEvtComms.ReasonParagraph__c = 'No reason';
		update objEvtComms;
		QCC_EmailPreviewController.fetchEmailContent(objEvtComms.Id);
	}
}