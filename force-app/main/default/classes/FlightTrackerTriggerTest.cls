/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Test class for FlightTrackerTriggerHelper
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
21-June-2018             Purushotham B          Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class FlightTrackerTriggerTest {
    @testSetup
    static void createData() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createFlightTrackerTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createFlightFailureSetting());
        insert lsttrgStatus;
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
    }
    
    static testMethod void testPopulateUTCFields() {
        List<Flight_Tracker__c> flts = new List<Flight_Tracker__c>();
        Integer i = 0;
        for(i = 0; i < 50; i++) {
            Flight_Tracker__c flt = new Flight_Tracker__c();
            flt.Flight_Number__c = '2301';
            flt.Departure_Airport__c = String.valueOf(i) ;
            flt.Arrival_Airport__c = String.valueOf(i + 1);
            flt.EstimatedArrDateTime__c = '2018-01-10T10:00:00.000+10:00';
            flt.ScheduledArrDateTime__c = '2018-01-10T10:00:00.000+10:00';
            flt.ScheduledDepTime__c = '2018-01-10T10:00:00.000+10:00';
            flt.ActualArriDateTime__c = '2018-01-10T12:00:00.000+10:00';
            flt.Event_Name__c = 'ESTIMATE_CHANGE';
            flts.add(flt);
        }
        
        Test.startTest();
        insert flts;
        Test.stopTest();
        Datetime resultantDateTime = Datetime.newInstanceGmt(2018, 01, 10, 00, 00, 00);
        Datetime resultantDateTime2 = Datetime.newInstanceGmt(2018, 01, 10, 02, 00, 00);
        List<Flight_Tracker__c> flgs = [SELECT Id, Scheduled_Arrival_UTC__c, Scheduled_Depature_UTC__c, Estimated_Arrival_UTC__c, Actual_Arrival_UTC__c, IntDom__c FROM Flight_Tracker__c];
        for(i = 0; i < flgs.size(); i++) {
            System.assertEquals(resultantDateTime, flgs[i].Scheduled_Arrival_UTC__c);
            System.assertEquals(resultantDateTime, flgs[i].Scheduled_Depature_UTC__c);
            System.assertEquals(resultantDateTime2, flgs[i].Actual_Arrival_UTC__c);
            System.assertEquals(resultantDateTime, flgs[i].Estimated_Arrival_UTC__c);
            System.assertEquals('Domestic', flgs[i].IntDom__c);
        }
    }
    
    static testMethod void testPopulateUTCFieldsException() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '52';
        flt.Departure_Airport__c = 'SYD';
        flt.Arrival_Airport__c = 'SIN';
        flt.EstimatedArrDateTime__c = '2018-01-10T10:100000+++++';
        flt.Event_Name__c = 'FLIGHT_PLAN';
        Test.startTest();
        insert flt;
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'FlightTrackerTriggerHelper'];
        System.assertEquals(1, logs.size(), 'Log for FlightTrackerTriggerHelper not found');
    }
    
    static testMethod void testQCC_FetchFlightInfoQueueable() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'CNS';
        flt.Arrival_Airport__c = 'TSV';
        flt.Event_Name__c = 'FLIGHT_CANCEL';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.LocalScheduleDate__c = flt.Origin_Date__c;
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightAPI(flt);
        insert flt;
        Test.stopTest();
        Flight_Tracker__c flg = [SELECT Id, Operational_Carrier__c, Aircraft_Type__c, Aircraft_Registration__c FROM Flight_Tracker__c WHERE Id = :flt.Id];
        System.assertEquals('QF', flg.Operational_Carrier__c);
        System.assertEquals('DH8-DH4', flg.Aircraft_Type__c);
        System.assertEquals('VHQOH', flg.Aircraft_Registration__c);
    }
    
    static testMethod void testFlightCancelFirstSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'CNS';
        flt.Arrival_Airport__c = 'TSV';
        flt.Event_Name__c = 'FLIGHT_CANCEL';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T09:05:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T10:00:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        System.debug('flt####'+flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() == 0, 'Events not inserted');
    }
    
    static testMethod void testEstimateChangeFirstSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'CNS';
        flt.Arrival_Airport__c = 'TSV';
        flt.Event_Name__c = 'ESTIMATE_CHANGE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T09:05:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T10:00:00+10:00';
        flt.EstimatedArrDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() ==0, 'Events not inserted');
    }
    
    static testMethod void testAirDiversionTerminatedFirstSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'CNS';
        flt.Arrival_Airport__c = 'TSV';
        flt.Event_Name__c = 'AIR_DIVERSION';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T09:05:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T10:00:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() == 0, 'Events not inserted');
    }
    
    static testMethod void testAirDiversionContinuedFirstSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'CNS';
        flt.Arrival_Airport__c = 'TSV';
        flt.Event_Name__c = 'AIR_DIVERSION';
        flt.Sub_Event_Name__c = 'AIR_DIVERT_AND_CONTINUE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T09:05:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T10:00:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() == 0, 'Events not inserted');
    }
    
    static testMethod void testAirReturn() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'CNS';
        flt.Arrival_Airport__c = 'TSV';
        flt.Event_Name__c = 'AIR_RETURN';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T09:05:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T10:00:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() == 0, 'Events not inserted');
    }
    
    static testMethod void testFlightCancelLastSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'FLIGHT_CANCEL';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() == 0, 'Events not inserted');
    }
    
    static testMethod void testEstimateChangeLastSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'ESTIMATE_CHANGE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.EstimatedArrDateTime__c = '2018-06-19T18:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-19T18:00:00.000+10:00';
        flt.EstimatedDepDateTime__c = '2018-06-19T11:40:00.000+10:00';
        flt.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() == 0, 'Events not inserted');
    }
    
    static testMethod void testEstimateChangeLastSector2() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '02301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'ESTIMATE_CHANGE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.EstimatedArrDateTime__c = '2018-06-20T12:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-20T12:00:00.000+10:00';
        flt.EstimatedDepDateTime__c = '2018-06-19T11:40:00.000+10:00';
        flt.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() ==0, 'Events not inserted');
    }
    
    static testMethod void testAirDiversionTerminatedLastSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'AIR_DIVERSION';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() == 0, 'Events not inserted');
    }
    
    static testMethod void testAirDiversionContinuedLastSector() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'AIR_DIVERSION';
        flt.Sub_Event_Name__c = 'AIR_DIVERT_AND_CONTINUE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        List<Event__c> events = [SELECT Id FROM Event__c];
        System.assert(events.size() ==0, 'Events not inserted');
    }
    
    static testMethod void testExistingEventFltTracker() {
        Event__c evt = new Event__c();
        evt.FlightNumber__c = 'QF2301';
        evt.ScheduledDepDate__c = Date.newInstance(2018, 06, 19);
        evt.Scheduled_Arrival_UTC__c = GenericUtils.parseStringToUTC('2018-06-19T12:25:00+10:00');
        evt.ArrivalPort__c = 'ROK';
        evt.DelayFailureCode__c = 'Flight Cancellation';
        evt.Scheduled_Depature_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        insert evt;
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Airline__c = 'QF';
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'FLIGHT_CANCEL';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-19T12:45:00+10:00';
        flt.EstimatedDepDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        Event__c e = [SELECT Id, ActualDepaDateTime__c FROM Event__c WHERE Id = :evt.Id];
        System.assertEquals(GenericUtils.parseStringToLocalDateTime(flt.ActualDepaDateTime__c).formatGmt('dd/MM/YYYY HH:mm:ss'), e.ActualDepaDateTime__c);
    }

    static testMethod void testExistingEventFltTracker2() {
        Event__c evt = new Event__c();
        evt.FlightNumber__c = 'QF2301';
        evt.ScheduledDepDate__c = Date.newInstance(2018, 06, 19);
        evt.Scheduled_Arrival_UTC__c = GenericUtils.parseStringToUTC('2018-06-19T12:25:00+10:00');
        evt.ArrivalPort__c = 'ROK';
        evt.DelayFailureCode__c = 'Flight Delay';
        evt.Scheduled_Depature_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        insert evt;
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Airline__c = 'QF';
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'AIR_DIVERSION';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-19T12:45:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        Event__c e = [SELECT Id, ActualDepaDateTime__c, DelayFailureCode__c FROM Event__c WHERE Id = :evt.Id];
        System.assertEquals(GenericUtils.parseStringToLocalDateTime(flt.ActualDepaDateTime__c).formatGmt('dd/MM/YYYY HH:mm:ss'), e.ActualDepaDateTime__c);
        System.assert(e.DelayFailureCode__c.contains('Diversion'), 'Delay failure code not updated');
    }

    static testMethod void testExistingEventFltTracker3() {
        Event__c evt = new Event__c();
        evt.FlightNumber__c = 'QF2301';
        evt.ScheduledDepDate__c = Date.newInstance(2018, 06, 19);
        evt.Scheduled_Arrival_UTC__c = GenericUtils.parseStringToUTC('2018-06-19T12:25:00+10:00');
        evt.ArrivalPort__c = 'ROK';
        evt.DelayFailureCode__c = 'Flight Delay';
        evt.Scheduled_Depature_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        insert evt;
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Airline__c = 'QF';
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'ESTIMATE_CHANGE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-19T17:45:00+10:00';
        flt.EstimatedArrDateTime__c = '2018-06-19T17:45:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        Event__c e = [SELECT Id, ActualDepaDateTime__c, DelayFailureCode__c FROM Event__c WHERE Id = :evt.Id];
        //System.assertEquals(GenericUtils.parseStringToLocalDateTime(flt.ActualDepaDateTime__c).formatGmt('dd/MM/YYYY HH:mm:ss'), e.ActualDepaDateTime__c);
        System.assert(e.DelayFailureCode__c.equalsIgnoreCase('Flight Delay'), 'Delay Failure Code not updated');
    }

    static testMethod void testExistingEventFltTracker4() {
        Event__c evt = new Event__c();
        evt.FlightNumber__c = 'QF2301';
        evt.ScheduledDepDate__c = Date.newInstance(2018, 06, 19);
        evt.Scheduled_Arrival_UTC__c = GenericUtils.parseStringToUTC('2018-06-19T12:25:00+10:00');
        evt.ArrivalPort__c = 'ROK';
        evt.DelayFailureCode__c = 'Flight Cancellation';
        evt.Scheduled_Depature_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        insert evt;
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Airline__c = 'QF';
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'ESTIMATE_CHANGE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-19T14:45:00+10:00';
        flt.EstimatedArrDateTime__c = '2018-06-19T14:45:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        Event__c e = [SELECT Id, ActualDepaDateTime__c, DelayFailureCode__c FROM Event__c WHERE Id = :evt.Id];
        //System.assertEquals(GenericUtils.parseStringToLocalDateTime(flt.ActualDepaDateTime__c).formatGmt('dd/MM/YYYY HH:mm:ss'), e.ActualDepaDateTime__c);
        //System.assert(e.DelayFailureCode__c.equalsIgnoreCase('Flight Delay'), 'Delay Failure Code not updated');
    }

    static testMethod void testExistingEventFltTracker5() {
        Event__c evt = new Event__c();
        evt.FlightNumber__c = 'QF2301';
        evt.ScheduledDepDate__c = Date.newInstance(2018, 06, 19);
        evt.Scheduled_Arrival_UTC__c = GenericUtils.parseStringToUTC('2018-06-19T12:25:00+10:00');
        evt.ArrivalPort__c = 'ROK';
        evt.DelayFailureCode__c = 'Flight Delay';
        evt.Scheduled_Depature_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        insert evt;
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Airline__c = 'QF';
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'ESTIMATE_CHANGE';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-06-20T10:45:00+10:00';
        flt.EstimatedArrDateTime__c = '2018-06-20T10:45:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        Event__c e = [SELECT Id, ActualDepaDateTime__c, DelayFailureCode__c FROM Event__c WHERE Id = :evt.Id];
        //System.assertEquals(GenericUtils.parseStringToLocalDateTime(flt.ActualDepaDateTime__c).formatGmt('dd/MM/YYYY HH:mm:ss'), e.ActualDepaDateTime__c);
        System.assert(e.DelayFailureCode__c.equalsIgnoreCase('Flight Delay'), 'Delay Failure Code not updated');
    }

    static testMethod void testExistingFlightTracker() {
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Airline__c = 'QF';
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'MKY';
        flt.Arrival_Airport__c = 'ROK';
        flt.Event_Name__c = 'FLIGHT_PLAN';
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt.Actual_Departure_UTC__c = null;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        flt = QCC_FlightTrackerInformationAPI.invokeFlightStatus(flt);
        insert flt;
        Test.stopTest();
        flt.Event_Name__c = 'AIR_DIVERSION';
        flt.NewArrivalPort__c = 'SYD';
        update flt; 
        List<Event__c> events = [SELECT Id, DelayFailureCode__c, Diverted_Port__c FROM Event__c];
    }
}