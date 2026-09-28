@isTest
private class QCC_FlightMapControllerTest
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
        		ts.Active__c = false;        	
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
            Event__c newEvent3    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent3.OwnerId = u1.Id;
            newEvent3.ScheduledDepDate__c = Date.newInstance(2018, 05, 22);
            newEvent3.DeparturePort__c = 'SYD';
            newEvent3.FlightNumber__c = 'QF0001';
            newEvent3.ArrivalPort__c = 'SIN';
            events.add(newEvent3);
            //Event__c newEvent4   = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            //newEvent4.OwnerId = u1.Id;
            //newEvent4.ScheduledDepDate__c = System.today();
            //newEvent4.DeparturePort__c = 'SYD';
            //newEvent4.FlightNumber__c = 'QF0516';
            //newEvent4.ArrivalPort__c = 'LHR';
            //events.add(newEvent4);

            insert events;
        }
	}

	@isTest
	static void testFetchEmailContent(){
		User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
			List<Event__c> lstEvent = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
										ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, NoCommsReason__c, DelayFailureCode__c,
										RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c, ArrivalPort__c 
										From Event__c Where Recordtype.name = 'Flight Event - Active' AND DelayFailureCode__c='Flight Delay' AND IntDom__c='Domestic' limit 1];
			Test.startTest();
			Map<String, String> mapHeader = new Map<String, String>();
	        String body = '{'+
        '   "flights":['+
        '       {'+
        '           "flightNumbers":['+
        '               {'+
        '                   "airline":"QF",'+
        '                   "code":1,'+
        '                   "primary":true,'+
        '                   "originDate":"2018-05-22",'+
        '                   "threeLetterAirline":"QFA",'+
        '                   "registrationNumber":"VHOQD"'+
        '               }'+
        '           ],'+
        '           "sectors":['+
        '               {'+
        '                   "sectorId":"QF1_SYD_SIN_22052018",'+
        '                   "from_x":"SYD",'+
        '                   "to":"SIN",'+
        '                   "departure":'+
        '                   {'+
        '                       "estimated":"2018-05-22T15:55:00+10:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-22T15:55:00+10:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"T1",'+
        '                       "gate":"8",'+
        '                       "boardingStatus":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "arrival":'+
        '                   {'+
        '                       "estimated":"2018-05-22T22:15:00+08:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-22T22:15:00+08:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"",'+
        '                       "gate":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "sectorDiversion":"PLANNED"'+
        '               },'+
        '               {'+
        '                   "sectorId":"QF1_SIN_LHR_22052018",'+
        '                   "from_x":"SIN",'+
        '                   "to":"LHR",'+
        '                   "departure":'+
        '                   {'+
        '                       "estimated":"2018-05-22T23:55:00+08:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-22T23:55:00+08:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"",'+
        '                       "gate":"",'+
        '                       "boardingStatus":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "arrival":'+
        '                   {'+
        '                       "estimated":"2018-05-23T06:55:00+01:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-23T06:55:00+01:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"",'+
        '                       "gate":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "sectorDiversion":"PLANNED"'+
        '               }'+
        '           ]'+
        '       }'+
        '   ]'+
        '   ,"lastUpdatedDateTime":"2018-05-22T00:12:35.686Z"'+
        '}';
	        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
			QCC_FlightMapController.fetchEmailContent( lstEvent[0].Id);
			System.debug('after update: '+lstEvent);
			Test.stopTest();
		}
	}
}