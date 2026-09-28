@IsTest
public class QCC_AddEventstoGlobalEventControllerTest {
	
	private static Event__c globalEvent;
	private static List<Event__c> listEvent;
    static Event__c globalHeadsUpEvent;


	static {

		TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createFlightTrackerTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createFlightFailureSetting());
        for(Trigger_Status__c ts : lsttrgStatus){
            //ts.Active__c = false;
        }
        insert lsttrgStatus;

        List<Trigger_Status__c> lsttrgStatusEvent = TestUtilityDataClassQantas.createEventTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatusEvent){
            ts.Active__c = false;
        }
        insert lsttrgStatusEvent;

		globalEvent = new Event__c();
    	listEvent = new List<Event__c>();

    	//String airportEvents = 'Snowfall;High Winds;Volcano';
    	//Event__c globalEvent = new Event__c();
        Id recTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Event').getRecordTypeId();
        //globalEvent.Name = 'test global event';
        //globalEvent.Airport_Event_Type__c = airportEvents;
        globalEvent.RecordTypeId = recTypeId;
    	insert globalEvent;

    	for(Integer i = 0; i < 5; i++){
    		Event__c itemEvent = new Event__c();
            itemEvent.FlightNumber__c = 'QF000'+i;
            itemEvent.departurePort__c = 'SYD';
            itemEvent.arrivalPort__c = 'MEL';
            itemEvent.ScheduledDepDate__c = Date.newInstance(2018, 10, 10);
            itemEvent.Scheduled_Depature_UTC__c = DateTime.newInstanceGmt(2018, 10, 10, 0, 0, 0);
    		itemEvent.GlobalEvent__c = globalEvent.Id;
            itemEvent.TECH_FlightTrackerId__c = i+'';
    		listEvent.add(itemEvent);
    	}
        Event__c itemEvent = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Closed','Assigned', 'Flight Delay','International');
        itemEvent.FlightNumber__c = 'QF000'+5;
        itemEvent.departurePort__c = 'SYD';
        itemEvent.arrivalPort__c = 'MEL';
        itemEvent.ScheduledDepDate__c = Date.newInstance(2018, 10, 10);
        itemEvent.Scheduled_Depature_UTC__c = DateTime.newInstanceGmt(2018, 10, 10, 0, 0, 0);
        itemEvent.GlobalEvent__c = globalEvent.Id;
        itemEvent.TECH_FlightTrackerId__c = 5+'';
        itemEvent.Status__c = 'Closed';
        itemEvent.CloseAction__c = 'Event Auto-Closed';
        listEvent.add(itemEvent);
        
        Event__c itemEvent1 = new Event__c();
        itemEvent1.FlightNumber__c = 'QF4000';
        itemEvent1.departurePort__c = 'SYD';
        itemEvent1.arrivalPort__c = 'MEL';
        itemEvent1.ScheduledDepDate__c = Date.newInstance(2018, 10, 10);
        itemEvent1.Scheduled_Depature_UTC__c = DateTime.newInstanceGmt(2018, 10, 10, 0, 0, 0);
        itemEvent1.GlobalEvent__c = globalEvent.Id;
        itemEvent1.TECH_FlightTrackerId__c = 6+'';

        listEvent.add(itemEvent1);
        	
    	insert listEvent;
        
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '0001';
        flt.Departure_Airport__c = 'SYD';
        flt.Arrival_Airport__c = 'MEL';
        flt.Event_Name__c = 'FLIGHT_CANCEL'; 
        flt.EstimatedArrDateTime__c = '2018-10-10T10:00:00.000+10:00';
        flt.ScheduledArrDateTime__c = '2018-10-10T10:00:00.000+10:00';
        //flt.ScheduledDepTime__c = '2018-10-10T10:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-10-10T12:00:00.000+10:00';
        flt.Origin_Date__c = Date.newInstance(2018, 10, 10);
        flt.Scheduled_Depature_UTC__c = DateTime.newInstance(2018, 10, 10, 10, 00, 00);
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,10,10,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        flt.Airline__c = 'QF';
        
        flt.ScheduledDepTime__c = '10/10/2018 10:00:00';
        flt.ScheduledArrDateTime__c = '2018-10-10T10:00:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightAPI(flt);
        //flt.TECH_Flight_Tracker_Id__c = 'trackerID';
        insert flt;
        System.debug('Flight Tracker: '+flt);

        //insert Global HeadsUp Event record
        Id recordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Event__c' and Name = 'Global Heads Up'].Id;
        globalHeadsUpEvent = QCC_TestDataFactory.createGlobalHeadsUpEvent(recordTypeId);
        insert globalHeadsUpEvent;

        //Set Custom Settings Trigger_Status__c to false
        List<QantasConfigData__c> customSettingListRecordType = QCC_TestDataFactory.createRecordTypeConfigData();
        insert customSettingListRecordType;
	}

    //1st testmethod for getFieldSets method
    static testMethod void testMethodGetFieldSets() {
        Test.startTest();
        QCC_AddEventstoGlobalEventController.DataInitWrapper dataInitWrapper = QCC_AddEventstoGlobalEventController.getFieldSets(globalHeadsUpEvent.Id);
        QCC_AddEventstoGlobalEventController.parseStringToGMT('2018-10-01T00:00:00.000Z');
        Test.stopTest();

        System.assertEquals(true, dataInitWrapper.listFieldSets.size() > 0);
        System.assertEquals(true, String.isNotBlank(dataInitWrapper.columnSets));
    }

    //2nd testmethod for getFieldSets method
    static testMethod void testMethodGetFieldSets2() {

        Test.startTest();
        QCC_AddEventstoGlobalEventController.DataInitWrapper dataInitWrapper = QCC_AddEventstoGlobalEventController.getFieldSets(listEvent[0].Id);
        QCC_AddEventstoGlobalEventController.parseStringToGMT('2018-10-01T00:00:00.000Z');
        Test.stopTest();
        
        System.assertEquals(true, dataInitWrapper.listFieldSets.size() > 0);
        System.assertEquals(true, String.isNotBlank(dataInitWrapper.columnSets));
    }

    //1st testmethod for getDataEvent method
    static testMethod void testMethodGetDataEvents() {
    	QCC_AddEventstoGlobalEventController.DataInitWrapper dataInitWrapper = QCC_AddEventstoGlobalEventController.getFieldSets(globalHeadsUpEvent.Id);

        for(Integer i = 0; i < dataInitWrapper.listFieldSets.size(); i++){
            if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure UTC From'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2017-10-10T00:00:00.000Z';
            } else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure UTC To'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2019-10-10T00:00:00.000Z';
            } else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure Date From'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2017-10-10';
            } else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure Date To'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2019-10-10';
            }
            else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Flight Number'){
                dataInitWrapper.listFieldSets[i].fieldValue = 'QF0001';
            }
        }

        System.debug('==dataInitWrapper.listFieldSets==  '+dataInitWrapper.listFieldSets);

        Test.startTest();
        List<Event__c> lstEvents = QCC_AddEventstoGlobalEventController.getDataEvents(JSON.serialize(dataInitWrapper.listFieldSets), dataInitWrapper.columnSets);
        Test.stopTest();

        System.assertEquals(true, dataInitWrapper.listFieldSets.size() > 0);
        System.assertEquals(true, String.isNotBlank(dataInitWrapper.columnSets));
    }

    //2nd testmethod for getDataEvent method
    static testMethod void testMethodGetDataEvents2() {
    	QCC_AddEventstoGlobalEventController.DataInitWrapper dataInitWrapper = QCC_AddEventstoGlobalEventController.getFieldSets(listEvent[0].Id);
        
        for(Integer i = 0; i < dataInitWrapper.listFieldSets.size(); i++){
            if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure UTC From'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2017-10-10T00:00:00.000Z';
            } else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure UTC To'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2019-10-10T00:00:00.000Z';
            } else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure Date From'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2017-10-10';
            } else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Scheduled Departure Date To'){
                dataInitWrapper.listFieldSets[i].fieldValue = '2019-10-10';
            }
            else if(dataInitWrapper.listFieldSets[i].fieldLabel == 'Flight Number'){
                dataInitWrapper.listFieldSets[i].fieldValue = 'QF0001';
            }
        }
        
        System.debug('==dataInitWrapper.listFieldSets==  '+dataInitWrapper.listFieldSets);
        
        Test.startTest();
        List<Event__c> lstEvents = QCC_AddEventstoGlobalEventController.getDataEvents(JSON.serialize(dataInitWrapper.listFieldSets), dataInitWrapper.columnSets);
        Test.stopTest();
        
        System.assertEquals(true, dataInitWrapper.listFieldSets.size() > 0);
        System.assertEquals(true, String.isNotBlank(dataInitWrapper.columnSets));
    }

    //testmethod for addEventsToGlobalEvent method
    static testMethod void testMethodAddEventsToGlobalEvent() {
        //System.debug([select id,TECH_Flight_Tracker_Id__c from flight_tracker__c]);
    	//QCC_AddEventstoGlobalEventController.DataInitWrapper dataInitWrapper = QCC_AddEventstoGlobalEventController.getFieldSets(listEvent[0].Id);
        //System.debug(dataInitWrapper.listFieldSets);
        List<String> lstEventId = new List<String>();

        for(Event__c item : listEvent){
        	lstEventId.add(item.Id);
        }
		String failureJson = '{"Failure_Code__c":"Flight Delay","Affected_Region__c":"Full Flight","Affect_Sub_Section__c":"Full Flight","Pre_Flight__c":true,"Post_Flight__c":false}';
        List<String> lsTracker = new List<String>();
        Flight_Tracker__c flt = [select id, TECH_Flight_Tracker_Id__c from Flight_Tracker__c limit 1];
        lsTracker.add(flt.TECH_Flight_Tracker_Id__c);

        System.debug('failureJson  ' + failureJson);

        Test.startTest();
        try{
            QCC_AddEventstoGlobalEventController.addEventsToGlobalEvent(lstEventId, lsTracker, globalEvent.Id, failureJson);
        }catch(Exception ex){
            System.debug('failureJson  ' + ex);
        }
        Test.stopTest();
        
        List<Event__c> lstEvent = [
            SELECT Id
            	,GlobalEvent__c
            FROM Event__c
            WHERE Id IN :lstEventId
        ];

        System.assertEquals(globalEvent.Id, lstEvent[0].GlobalEvent__c);
    }
}