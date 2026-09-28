@isTest
private class QCC_EventClosedPostActionQueueableTest
{
	@TestSetUp
	static void TestSetUp()
	{
		TestUtilityDataClassQantas.insertQantasConfigData();
		TestUtilityDataClassQantas.createDelayCode();
		List<Qantas_API__c> lstQAPI = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQAPI;
    	//List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();       
        //lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        for(Trigger_Status__c ts : lsttrgStatus){
        	if(ts.Name != 'EventTriggerPostEventClosedAction' 
        		&& ts.Name != 'EventTriggerDelayCostsCompletedAction' ){
        		ts.Active__c = false;
        	}
        	
        }
        insert lsttrgStatus;
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        insert lstConfigData;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();

        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                               Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
				insert u1;
				//CRM-11908 Update metadata rerferences
				System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }
				
        System.runAs(u1){

            List<Event__c> events = new List<Event__c>();
            //Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Global Event','Assigned', 'Flight Delay','Domestic');
            //newEvent1.OwnerId = u1.Id;
            
            //events.add(newEvent1);
            //Event__c newEvent2    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            //newEvent2.OwnerId = u1.Id;
            //newEvent2.ScheduledDepDate__c = System.today();
            //newEvent2.DeparturePort__c = 'SYD';
            //newEvent2.FlightNumber__c = 'QF0516';
            //newEvent2.ArrivalPort__c = 'LHR';
            //events.add(newEvent2);
            Event__c newEvent3    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
            newEvent3.OwnerId = u1.Id;
            newEvent3.ScheduledDepDate__c = System.today();
            newEvent3.DeparturePort__c = 'SYD';
            newEvent3.FlightNumber__c = 'QF0516';
            newEvent3.ArrivalPort__c = 'LHR';
            events.add(newEvent3);
            Event__c newEvent4   = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent4.OwnerId = u1.Id;
            newEvent4.ScheduledDepDate__c = System.today();
            newEvent4.DeparturePort__c = 'SYD';
            newEvent4.FlightNumber__c = 'QF0516';
            newEvent4.ArrivalPort__c = 'LHR';
            events.add(newEvent4);

            insert events;

            //events[1].GlobalEvent__c = events[0].id;
            //update events;
        }
	}

	@isTest
	static void testAutoClosedEvent(){
		String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        String autoClosedAction = CustomSettingsUtilities.getConfigDataMap('Event Auto-Closed CloseAction');
        Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));
        String queueName = CustomSettingsUtilities.getConfigDataMap('QCC_AutoCloseQueueName');
        Group objQueueName;
        if(String.isNotBlank(queueName)){
            objQueueName = [select id from Group where type = 'Queue' and DeveloperName ='QCC_EventClosedQueue' ];
        }
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
			List<Event__c> lstEvent = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
										ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, NoCommsReason__c, DelayFailureCode__c,
										RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c 
										From Event__c Where Recordtype.name = 'Flight Event - Active' AND DelayFailureCode__c='Flight Delay' AND IntDom__c='Domestic' limit 1];
			for(Event__c objEvt : lstEvent){
				objEvt.Status__c = statusClosedEvent;
	            objEvt.CloseAction__c = autoClosedAction;
	            objEvt.Closed_Date_Time__c =  Datetime.now();
	            objEvt.Closed_By__c = UserInfo.getUserId();
	            objEvt.NotifyEventOwner__c = false;
	            objEvt.NotifyChatterGroup__c = false; 
	            objEvt.IsEventReopened__c = false;
	            objEvt.RecordTypeId = recTypeClosedEvent;
	            objEvt.NoCommsReason__c = 'Event is automatically closed as flight is no longer delayed by more than one hour and there is no in-flight disruptions';
			}
			Test.startTest();
			Map<String, String> mapHeader = new Map<String, String>();
	        String body = '{  '
	            +'   "flights":[  '
	            +'		  {  '
	            +'			 "marketingCarrier":"QF",'
	            +'			 "marketingFlightNo":"0516",'
	            +'			 "suffix":"",'
	            +'			 "departureAirportCode":"LHR",'
	            +'			 "departureAirportName":"BRISBANE",'
	            +'			 "arrivalAirportCode":"SYD",'
	            +'			 "arrivalAirportName":"KINGSFORD SMITH",'
	            +'			 "departureTerminal":"",'
	            +'			 "departureGate":"",'
	            +'			 "arrivalTerminal":"",'
	            +'			 "arrivalGate":"",'
	            +'			 "equipmentTailNumber":null,'
	            +'			 "equipmentTypeCode":"146",'
	            +'			 "equipmentSubTypeCode":"14Z",'
	            +'			 "flightStatus":"",'
	            +'			 "flightDuration":"90",'
	            +'			 "delayDuration":null,'
	            +'			 "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
	            +'			 "estimatedDepartureUTCTimeStamp":null,'
	            +'			 "actualDepartureUTCTimeStamp":null,'
	            +'			 "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
	            +'			 "estimatedArrivalUTCTimeStamp":null,'
	            +'			 "actualArrivalUTCTimeStamp":null,'
	            +'			 "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
	            +'			 "estimatedDepartureLocalTimeStamp":null,'
	            +'			 "actualDepartureLocalTimeStamp":null,'
	            +'			 "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
	            +'			 "estimatedArrivalLocalTimeStamp":null,'
	            +'			 "actualArrivalLocalTimeStamp":null,'
	            +'			 "primaryBaggageCarousel":"",'
	            +'			 "secondaryBaggageCarousel":""'
	            +'           ,"delay": [{'
	            +'           "reasonCode": "580",'
	            +'           "shortDescription": "IT",'
	            +'           "longDescription": "max 200 chars",'
	            +'           "delayDuration": "100"'
	            +'           }]'
	            +' 			,"airDiversion": {'
	            +'            "unScheduledArrivalAirport": "SYD"'
	            +'        		}'
	            +'		  }'
	            +'   ]'
	            +'}';
	        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
			update lstEvent;
			System.debug('after update: '+lstEvent);
			Test.stopTest();

			lstEvent = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
										ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, NoCommsReason__c, DelayFailureCode__c,
										RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c 
										From Event__c Where Status__c = :statusClosedEvent AND DelayFailureCode__c='Flight Delay' AND IntDom__c='Domestic' limit 1];
			 System.assertEquals(lstEvent[0].status__c, 'Closed');
		}
	}

	@isTest
	static void testClosedFlightEvent(){
		String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        String autoClosedAction = CustomSettingsUtilities.getConfigDataMap('Event Close Action Comms sent');
        Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));

        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
			List<Event__c> lstEvent = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
										ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, NoCommsReason__c, DelayFailureCode__c,
										RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c 
										From Event__c Where Recordtype.name = 'Flight Event - Active' AND DelayFailureCode__c='Flight Delay' AND IntDom__c='International' limit 1];
			for(Event__c objEvt : lstEvent){
				objEvt.Status__c = statusClosedEvent;
	            objEvt.CloseAction__c = 'Comms sent';
	            objEvt.Closed_Date_Time__c =  Datetime.now();
	            objEvt.Closed_By__c = UserInfo.getUserId();
	            objEvt.NotifyEventOwner__c = false;
	            objEvt.NotifyChatterGroup__c = false; 
	            objEvt.IsEventReopened__c = false;
	            objEvt.RecordTypeId = recTypeClosedEvent;
	            objEvt.NoCommsReason__c = 'Event is automatically closed as flight is no longer delayed by more than one hour and there is no in-flight disruptions';
			}
			Test.startTest();
			Map<String, String> mapHeader = new Map<String, String>();
	        String body = '{  '
	            +'   "flights":[  '
	            +'		  {  '
	            +'			 "marketingCarrier":"QF",'
	            +'			 "marketingFlightNo":"0516",'
	            +'			 "suffix":"",'
	            +'			 "departureAirportCode":"LHR",'
	            +'			 "departureAirportName":"BRISBANE",'
	            +'			 "arrivalAirportCode":"SYD",'
	            +'			 "arrivalAirportName":"KINGSFORD SMITH",'
	            +'			 "departureTerminal":"",'
	            +'			 "departureGate":"",'
	            +'			 "arrivalTerminal":"",'
	            +'			 "arrivalGate":"",'
	            +'			 "equipmentTailNumber":null,'
	            +'			 "equipmentTypeCode":"146",'
	            +'			 "equipmentSubTypeCode":"14Z",'
	            +'			 "flightStatus":"",'
	            +'			 "flightDuration":"90",'
	            +'			 "delayDuration":null,'
	            +'			 "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
	            +'			 "estimatedDepartureUTCTimeStamp":null,'
	            +'			 "actualDepartureUTCTimeStamp":null,'
	            +'			 "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
	            +'			 "estimatedArrivalUTCTimeStamp":null,'
	            +'			 "actualArrivalUTCTimeStamp":null,'
	            +'			 "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
	            +'			 "estimatedDepartureLocalTimeStamp":null,'
	            +'			 "actualDepartureLocalTimeStamp":null,'
	            +'			 "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
	            +'			 "estimatedArrivalLocalTimeStamp":null,'
	            +'			 "actualArrivalLocalTimeStamp":null,'
	            +'			 "primaryBaggageCarousel":"",'
	            +'			 "secondaryBaggageCarousel":""'
	            +'           ,"delay": [{'
	            +'           "reasonCode": "580",'
	            +'           "shortDescription": "IT",'
	            +'           "longDescription": "max 200 chars",'
	            +'           "delayDuration": "100"'
	            +'           }]'
	            +' 			,"airDiversion": {'
	            +'            "unScheduledArrivalAirport": "SYD"'
	            +'        		}'
	            +'		  }'
	            +'   ]'
	            +'}';
	        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
			update lstEvent;
			System.debug('after update: '+lstEvent);
			Test.stopTest();

			lstEvent = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
										ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, NoCommsReason__c, DelayFailureCode__c,
										RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c 
										From Event__c Where Status__c = :statusClosedEvent AND DelayFailureCode__c='Flight Delay' AND IntDom__c='International' limit 1];
			System.assertEquals(lstEvent[0].Status__c, 'Closed');
		}
	}

	//@isTest
	//static void testClosedGlobalEvent(){
	//	String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
 //       String autoClosedAction = CustomSettingsUtilities.getConfigDataMap('Event Close Action Comms sent');
 //       Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));

 //       User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
 //       System.runAs(u){
	//		List<Event__c> lstEvent = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
	//									ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, NoCommsReason__c, DelayFailureCode__c,
	//									RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c 
	//									From Event__c Where Recordtype.name = 'Global Event' limit 1];
	//		System.debug(lstEvent);
	//		for(Event__c objEvt : lstEvent){
	//			objEvt.Status__c = statusClosedEvent;
	//            objEvt.CloseAction__c = 'Comms sent';
	//            objEvt.Closed_Date_Time__c =  Datetime.now();
	//            objEvt.Closed_By__c = UserInfo.getUserId();
	//            objEvt.NotifyEventOwner__c = false;
	//            objEvt.NotifyChatterGroup__c = false; 
	//            objEvt.IsEventReopened__c = false;
	//            //objEvt.RecordTypeId = recTypeClosedEvent;
	//            objEvt.NoCommsReason__c = 'Event is automatically closed as flight is no longer delayed by more than one hour and there is no in-flight disruptions';
	//		}
	//		Test.startTest();
	//		Map<String, String> mapHeader = new Map<String, String>();
	//        String body = '{  '
	//            +'   "flights":[  '
	//            +'		  {  '
	//            +'			 "marketingCarrier":"QF",'
	//            +'			 "marketingFlightNo":"0516",'
	//            +'			 "suffix":"",'
	//            +'			 "departureAirportCode":"LHR",'
	//            +'			 "departureAirportName":"BRISBANE",'
	//            +'			 "arrivalAirportCode":"SYD",'
	//            +'			 "arrivalAirportName":"KINGSFORD SMITH",'
	//            +'			 "departureTerminal":"",'
	//            +'			 "departureGate":"",'
	//            +'			 "arrivalTerminal":"",'
	//            +'			 "arrivalGate":"",'
	//            +'			 "equipmentTailNumber":null,'
	//            +'			 "equipmentTypeCode":"146",'
	//            +'			 "equipmentSubTypeCode":"14Z",'
	//            +'			 "flightStatus":"",'
	//            +'			 "flightDuration":"90",'
	//            +'			 "delayDuration":null,'
	//            +'			 "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
	//            +'			 "estimatedDepartureUTCTimeStamp":null,'
	//            +'			 "actualDepartureUTCTimeStamp":null,'
	//            +'			 "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
	//            +'			 "estimatedArrivalUTCTimeStamp":null,'
	//            +'			 "actualArrivalUTCTimeStamp":null,'
	//            +'			 "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
	//            +'			 "estimatedDepartureLocalTimeStamp":null,'
	//            +'			 "actualDepartureLocalTimeStamp":null,'
	//            +'			 "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
	//            +'			 "estimatedArrivalLocalTimeStamp":null,'
	//            +'			 "actualArrivalLocalTimeStamp":null,'
	//            +'			 "primaryBaggageCarousel":"",'
	//            +'			 "secondaryBaggageCarousel":""'
	//            +'           ,"delay": [{'
	//            +'           "reasonCode": "580",'
	//            +'           "shortDescription": "IT",'
	//            +'           "longDescription": "max 200 chars",'
	//            +'           "delayDuration": "100"'
	//            +'           }]'
	//            +' 			,"airDiversion": {'
	//            +'            "unScheduledArrivalAirport": "SYD"'
	//            +'        		}'
	//            +'		  }'
	//            +'   ]'
	//            +'}';
	//        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
	//		update lstEvent;
	//		System.debug('after update: '+lstEvent);
	//		Test.stopTest();

	//		List<Event__c> lstEvent1 = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
	//									ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, NoCommsReason__c, DelayFailureCode__c,
	//									RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c 
	//									From Event__c Where GlobalEvent__c=:lstEvent[0].id limit 1];
	//		System.assertEquals(lstEvent1[0].Primary_Root_Cause__c, 'Auto Equipment');
	//	}
	//}
}