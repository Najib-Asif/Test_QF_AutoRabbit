/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Test class for QCC_FlightMovementAPI
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
06-July-2018             Purushotham B          Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_FlightMovementAPITest {
	@testSetup
    static void createData() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createFlightTrackerTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert  lstQantas;
    }
    
    static testMethod void testCreateFlightMovementFlightPlan() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns:ns2="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1" xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><ns2:eventDetails><ns8:EventName xmlns:ns8="urn:www.qantas.com:schema:cdm:common:Events:v1">FLIGHT_PLAN</ns8:EventName><ns8:EventID xmlns:ns8="urn:www.qantas.com:schema:cdm:common:Events:v1"><ns8:Airline>QFA</ns8:Airline><ns8:FlightNumber>2301</ns8:FlightNumber><ns8:Date>2018-06-19</ns8:Date><ns8:ArrivalAirport>TSV</ns8:ArrivalAirport><ns8:DepartureAirport>CNS</ns8:DepartureAirport><ns8:ComercialSuffix/><ns8:Event_SequentID>6</ns8:Event_SequentID><ns8:Sequnet>0</ns8:Sequnet></ns8:EventID><ns8:ExternalID xmlns:ns8="urn:www.qantas.com:schema:cdm:common:Events:v1"><ns8:FlightNumber>2301</ns8:FlightNumber><ns8:Date>2018-06-19</ns8:Date><ns8:Port>CNS</ns8:Port><ns8:Sequent>0</ns8:Sequent></ns8:ExternalID><ns8:EventTime xmlns:ns8="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</ns8:EventTime></ns2:eventDetails><ns2:FlightLegDetails><ns0:Identifier xmlns:ns0="urn:www.qantas.com:schema:cdm:common:Legdata:v1"><ns0:CarrierCode><ns0:Airline3>QFA</ns0:Airline3><ns0:Airline2>QF</ns0:Airline2></ns0:CarrierCode><ns0:FlightNumber>2301</ns0:FlightNumber><ns0:FlightClassification>Domestic</ns0:FlightClassification><ns0:FlightType>Primary</ns0:FlightType><ns0:FlightUTCDate>2018-06-19</ns0:FlightUTCDate><ns0:ServiceType>J</ns0:ServiceType></ns0:Identifier><ns0:Departure xmlns:ns0="urn:www.qantas.com:schema:cdm:common:Legdata:v1"><ns0:Port>CNS</ns0:Port><ns0:Schedule>2018-06-27T13:00:00.000+10:00</ns0:Schedule></ns0:Departure><ns0:Arrival xmlns:ns0="urn:www.qantas.com:schema:cdm:common:Legdata:v1"><ns0:Port>TSV</ns0:Port><ns0:Schedule>2018-06-19T07:35:00.000+10:00</ns0:Schedule></ns0:Arrival><ns0:Status xmlns:ns0="urn:www.qantas.com:schema:cdm:common:Legdata:v1">Planned</ns0:Status><ns0:Operation xmlns:ns0="urn:www.qantas.com:schema:cdm:common:Legdata:v1"><ns0:AircraftGroup>330</ns0:AircraftGroup><ns0:AircraftType>332</ns0:AircraftType><ns0:AircraftRegistration>VHEBQ</ns0:AircraftRegistration><ns0:AircraftOwner><ns0:Airline3>QFA</ns0:Airline3><ns0:Airline2>QF</ns0:Airline2></ns0:AircraftOwner><ns0:PhysicalConfiguration><ns0:CabinClass>J</ns0:CabinClass><ns0:Capacity>36</ns0:Capacity><ns0:CabinClass>Y</ns0:CabinClass><ns0:Capacity>268</ns0:Capacity></ns0:PhysicalConfiguration><ns0:SaleableConfiguration><ns0:CabinClass>J</ns0:CabinClass><ns0:Capacity>36</ns0:Capacity><ns0:CabinClass>Y</ns0:CabinClass><ns0:Capacity>268</ns0:Capacity></ns0:SaleableConfiguration><ns0:LinkedFlights><ns0:Secondary><ns0:CarrierCode><ns0:Airline3>CES</ns0:Airline3><ns0:Airline2>MU</ns0:Airline2></ns0:CarrierCode><ns0:FlightNumber>8433</ns0:FlightNumber><ns0:OriginDate><ns0:Local>2015-06-03</ns0:Local><ns0:UTC>2015-06-03</ns0:UTC><ns0:Sequent>0</ns0:Sequent></ns0:OriginDate></ns0:Secondary><ns0:Secondary><ns0:CarrierCode><ns0:Airline3>UAE</ns0:Airline3><ns0:Airline2>EK</ns0:Airline2></ns0:CarrierCode><ns0:FlightNumber>5769</ns0:FlightNumber><ns0:OriginDate><ns0:Local>2015-06-03</ns0:Local><ns0:UTC>2015-06-03</ns0:UTC><ns0:Sequent>0</ns0:Sequent></ns0:OriginDate></ns0:Secondary></ns0:LinkedFlights><ns0:Passenger><ns0:Total><ns0:Souls>243</ns0:Souls><ns0:Seated>243</ns0:Seated><ns0:Infants>0</ns0:Infants></ns0:Total></ns0:Passenger></ns0:Operation></ns2:FlightLegDetails><ns2:subEvents><ns2:otherDetails><ns2:OGSMessageID>0124825323</ns2:OGSMessageID></ns2:otherDetails></ns2:subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() != 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testCreateFlightMovementFlightCancel() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><eventDetails><EventName xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">FLIGHT_CANCEL</EventName><EventID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><Airline>QF</Airline><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><ArrivalAirport>TSV</ArrivalAirport><DepartureAirport>CNS</DepartureAirport><ComercialSuffix/><Event_SequentID>2</Event_SequentID><Sequnet>0</Sequnet></EventID><ExternalID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><Port>CNS</Port></ExternalID><EventTime xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</EventTime></eventDetails><subEvents><subEventDetails><SubEventName xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">CANCEL</SubEventName><SubEventTime xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">2015-12-01T10:54:56.494+11:00</SubEventTime></subEventDetails><otherDetails><OGSMessageID xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">0124825323</OGSMessageID></otherDetails></subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() > 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testCreateFlightMovementEstimateChange() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><eventDetails><EventName xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">ESTIMATE_CHANGE</EventName><EventID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><Airline>QFA</Airline><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><ArrivalAirport>TSV</ArrivalAirport><DepartureAirport>CNS</DepartureAirport><ComercialSuffix/><Event_SequentID>31</Event_SequentID><Sequnet>0</Sequnet></EventID><ExternalID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><Port>TSV</Port></ExternalID><EventTime xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</EventTime></eventDetails><subEvents><subEventDetails><SubEventName xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">ARRIVAL</SubEventName><SubEventTime xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">2018-12-19T14:48:54.630+11:00</SubEventTime></subEventDetails><otherDetails><ArrivalTimeDetails><oldTime>2018-06-19T11:00:00.000+10:00</oldTime><newTime>2018-06-19T12:35:00.000+10:00</newTime></ArrivalTimeDetails><DepartureTimeDetails><oldTime>2018-06-19T09:05:00+10:00</oldTime><newTime>2018-06-19T09:05:00+10:00</newTime></DepartureTimeDetails><OGSMessageID xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">0124825336</OGSMessageID></otherDetails></subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() > 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testCreateFlightMovementScheduleChange() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><eventDetails><EventName xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">SCHEDULE_CHANGE</EventName><EventID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><Airline>QFA</Airline><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><ArrivalAirport>TSV</ArrivalAirport><DepartureAirport>CNS</DepartureAirport><ComercialSuffix/><Event_SequentID>31</Event_SequentID><Sequnet>0</Sequnet></EventID><ExternalID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><Port>TSV</Port></ExternalID><EventTime xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</EventTime></eventDetails><subEvents><subEventDetails><SubEventName xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">ARRIVAL</SubEventName><SubEventTime xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">2018-12-19T14:48:54.630+11:00</SubEventTime></subEventDetails><otherDetails><ArrivalTimeDetails><oldTime>2018-06-19T10:00:00.000+10:00</oldTime><newTime>2018-06-19T11:35:00.000+10:00</newTime></ArrivalTimeDetails><DepartureTimeDetails><oldTime>2018-06-19T10:00:00.000+10:00</oldTime><newTime>2018-06-19T11:35:00.000+10:00</newTime></DepartureTimeDetails><OGSMessageID xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">0124825336</OGSMessageID></otherDetails></subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() > 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testCreateFlightMovementAirDiversion() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><eventDetails><EventName xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">AIR_DIVERSION</EventName><EventID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><Airline>QF</Airline><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><ArrivalAirport>TSV</ArrivalAirport><DepartureAirport>CNS</DepartureAirport><ComercialSuffix/><Event_SequentID>2</Event_SequentID><Sequnet>0</Sequnet></EventID><ExternalID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><Port>CNS</Port></ExternalID><EventTime xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</EventTime></eventDetails><subEvents><subEventDetails><SubEventName xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1"></SubEventName><SubEventTime xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">2015-12-01T10:54:56.494+11:00</SubEventTime></subEventDetails><otherDetails><OGSMessageID xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">0124825323</OGSMessageID></otherDetails></subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() > 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testCreateFlightMovementBlocksOff() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><eventDetails><EventName xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">BLOCKS_OFF</EventName><EventID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><Airline>QF</Airline><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><ArrivalAirport>TSV</ArrivalAirport><DepartureAirport>CNS</DepartureAirport><ComercialSuffix/><Event_SequentID>2</Event_SequentID><Sequnet>0</Sequnet></EventID><ExternalID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><Port>CNS</Port></ExternalID><EventTime xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</EventTime></eventDetails><subEvents><subEventDetails><SubEventName xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">CANCEL</SubEventName><SubEventTime xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">2015-12-01T10:54:56.494+11:00</SubEventTime></subEventDetails><otherDetails><OGSMessageID xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">0124825323</OGSMessageID></otherDetails></subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() > 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testCreateFlightMovementBlocksOn() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><eventDetails><EventName xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">BLOCKS_ON</EventName><EventID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><Airline>QF</Airline><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><ArrivalAirport>TSV</ArrivalAirport><DepartureAirport>CNS</DepartureAirport><ComercialSuffix/><Event_SequentID>2</Event_SequentID><Sequnet>0</Sequnet></EventID><ExternalID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><Port>CNS</Port></ExternalID><EventTime xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</EventTime></eventDetails><subEvents><subEventDetails><SubEventName xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">CANCEL</SubEventName><SubEventTime xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">2015-12-01T10:54:56.494+11:00</SubEventTime></subEventDetails><otherDetails><OGSMessageID xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">0124825323</OGSMessageID></otherDetails></subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() > 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testCreateFlightMovementAirReturn() {
        String XMLMsg = '<flightOperationsEventMsgRq xmlns="urn:www.qantas.com:schema:cdm:operations:FlightOperations:v1"><eventDetails><EventName xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">AIR_RETURN</EventName><EventID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><Airline>QFA</Airline><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><ArrivalAirport>TSV</ArrivalAirport><DepartureAirport>CNS</DepartureAirport><ComercialSuffix/><Event_SequentID>31</Event_SequentID><Sequnet>0</Sequnet></EventID><ExternalID xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1"><FlightNumber>2301</FlightNumber><Date>2018-06-19</Date><Port>TSV</Port></ExternalID><EventTime xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:www.qantas.com:schema:cdm:common:Events:v1">2015-06-03T05:15:07.834+10:00</EventTime></eventDetails><subEvents><subEventDetails><SubEventName xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">ARRIVAL</SubEventName><SubEventTime xmlns="urn:www.qantas.com:schema:cdm:common:SubEvents:v1">2018-12-19T14:48:54.630+11:00</SubEventTime></subEventDetails><otherDetails><ArrivalTimeDetails><oldTime>2018-06-19T10:00:00.000+10:00</oldTime><newTime>2018-06-19T11:35:00.000+10:00</newTime></ArrivalTimeDetails><DepartureTimeDetails><oldTime>2018-06-19T10:00:00.000+10:00</oldTime><newTime>2018-06-19T11:35:00.000+10:00</newTime></DepartureTimeDetails><OGSMessageID xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">0124825336</OGSMessageID></otherDetails></subEvents></flightOperationsEventMsgRq>';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QCCFlightEvent';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(XMLMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightMovementAPI.createFlightMovement();
        List<Flight_Tracker__c> flts = [SELECT Id FROM Flight_Tracker__c];
        System.assert(flts.size() > 0, 'Flight Trackers not inserted');
        Test.StopTest();   
    }
    
    static testMethod void testAddstop(){
        List<Flight_Tracker__c> lstFT = new List<Flight_Tracker__c>();
        Flight_Tracker__c flt = new Flight_Tracker__c();
        flt.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt.Flight_Number__c = '2301';
        flt.Departure_Airport__c = 'SYD';
        flt.Arrival_Airport__c = 'MEL';
        flt.EstimatedArrDateTime__c = '2018-01-10T10:00:00.000+10:00';
        flt.ScheduledArrDateTime__c = '2018-01-10T10:00:00.000+10:00';
        flt.ScheduledDepTime__c = '2018-01-10T10:00:00.000+10:00';
        flt.ActualArriDateTime__c = '2018-01-10T12:00:00.000+10:00';
        flt.Event_Name__c = 'FLIGHT_CANCEL';
        flt.Airline__c = 'QF';
        lstFT.add(flt);
        
        Flight_Tracker__c flt1 = new Flight_Tracker__c();
        flt1.Flight_Number__c = '2301';
        flt1.Departure_Airport__c = 'SYD';
        flt1.Arrival_Airport__c = 'ROK';
        flt1.Event_Name__c = 'FLIGHT_PLAN';
        flt1.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt1.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt1.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt1.EstimatedArrDateTime__c = '2018-06-19T18:00:00.000+10:00';
        flt1.ActualArriDateTime__c = '2018-06-19T18:00:00.000+10:00';
        flt1.EstimatedDepDateTime__c = '2018-06-19T11:40:00.000+10:00';
        flt1.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt1.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt1.Actual_Departure_UTC__c = null;
        flt1.Airline__c = 'QF';
        flt1.MessageId__c = '123';
        lstFT.add(flt1);
        
        Flight_Tracker__c flt2 = new Flight_Tracker__c();
        flt2.Flight_Number__c = '2301';
        flt2.Departure_Airport__c = 'ROK';
        flt2.Arrival_Airport__c = 'MEL';
        flt2.Event_Name__c = 'FLIGHT_PLAN';
        flt2.Origin_Date__c = Date.newInstance(2018, 06, 19);
        flt2.ScheduledDepTime__c = '2018-06-19T11:40:00+10:00';
        flt2.ScheduledArrDateTime__c = '2018-06-19T12:25:00+10:00';
        flt2.EstimatedArrDateTime__c = '2018-06-19T18:00:00.000+10:00';
        flt2.ActualArriDateTime__c = '2018-06-19T18:00:00.000+10:00';
        flt2.EstimatedDepDateTime__c = '2018-06-19T11:40:00.000+10:00';
        flt2.ActualDepaDateTime__c = '2018-06-19T12:00:00.000+10:00';
        flt2.Estimated_Departure_UTC__c = Datetime.newInstance(2018,6,19,5,0,0);
        flt2.Actual_Departure_UTC__c = null;
        flt2.Airline__c = 'QF';
        flt2.MessageId__c = '123';
        lstFT.add(flt2);
        insert lstFT;
        Test.startTest();
        Flight_Tracker__c objFT = [select Id, Flight_Number__c, Origin_Date__c, Arrival_Airport__c, Event_Name__c, MessageId__c, Departure_Airport__c from Flight_Tracker__c where Event_Name__c = 'FLIGHT_CANCEL' limit 1];
        objFT.MessageId__c = '123';
        QCC_FlightMovementAPI.addStopTrackerMerge(objFT, 'Test');
        Test.stopTest();
    }
}