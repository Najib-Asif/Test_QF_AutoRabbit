@isTest
private class QCC_AffectPassengerFilterControllerTest
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
    	List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
    	// create eVENT
    	
    	Event__c newEvent1 = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
    	newEvent1.Non_Delay_Failure_Code__c = 'Catering;Toilets;Wifi';

        insert newEvent1;
	}

	@isTest
	static void fetchEventFailuresValuesTest()
	{
		Event__c objEvent = [Select Id, DelayFailureCode__c, Non_Delay_Failure_Code__c from Event__c ];
		Test.startTest();
		QCC_AffectPassengerFilterController.fetchEventFailuresValues(objEvent.Id);
		QCC_AffectPassengerFilterController.createReportURL(objEvent.Id, 'Non_Delay_Failure_Code__c');
		Test.stopTest();
	}
	private static Event__c createEvent(String eventType){
    	Id recordTypeEventActive = GenericUtils.getObjectRecordTypeId('Event__c', eventType);
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
}