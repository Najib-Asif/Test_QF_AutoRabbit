@Istest
public class QCC_EventFlightDetailsUpdateQueuableTest {
	@testSetup 
    static void setup() {
        List<Qantas_API__c> lstQAPI = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQAPI;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;

            if(ts.Name == 'EventTriggerGetFlightInfo'){
                ts.Active__c = true;
            }
        }
        insert lsttrgStatus;
        //lsttrgStatus = TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting();
        //for(Trigger_Status__c ts : lsttrgStatus){
        //    ts.Active__c = false;
        //}
        //insert lsttrgStatus;
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Journey Manager').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        System.runAs(u1){
            Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Diversion Due to Weather','Domestic');
            newEvent1.ScheduledDepDate__c = System.today();
            newEvent1.DeparturePort__c = 'SYD';
            newEvent1.FlightNumber__c = 'QF7404';
            newEvent1.ArrivalPort__c = 'SYD';
            newEvent1.OwnerId = u1.Id;
            insert newEvent1;
        }
    }
    @IsTest
    public static void testUpdateFlightInfo(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
            Map<String, String> mapHeader = new Map<String, String>();
            
            Test.startTest();
            list<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
            String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
            mapHeader.put('Content-Type', 'application/json');
            
            //lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', Body, mapHeader));
            body = '{  '
                +'   "flights":[  '
                +'		  {  '
                +'			 "marketingCarrier":"QF",'
                +'			 "marketingFlightNo":"0516",'
                +'			 "suffix":"",'
                +'			 "departureAirportCode":"BNE",'
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
                +'			 "estimatedDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
                +'			 "actualDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
                +'			 "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
                +'			 "estimatedArrivalUTCTimeStamp":"28/03/2018 14:05:00",'
                +'			 "actualArrivalUTCTimeStamp":"28/03/2018 14:05:00",'
                +'			 "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
                +'			 "estimatedDepartureLocalTimeStamp":"28/03/2018 14:05:00",'
                +'			 "actualDepartureLocalTimeStamp":"28/03/2018 14:05:00",'
                +'			 "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
                +'			 "estimatedArrivalLocalTimeStamp":"28/03/2018 14:05:00",'
                +'			 "actualArrivalLocalTimeStamp":"28/03/2018 14:05:00",'
                +'			 "primaryBaggageCarousel":"",'
                +'			 "secondaryBaggageCarousel":""'
                +'		  }'
                +'   ]'
                +'}';
            lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', Body, mapHeader));
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));
            
            List<Event__c> lstEvent = [select id, FlightNumber__c, TECH_FlightAPIInvoked__c from Event__c];
            lstEvent[0].FlightNumber__c = 'QF0516';
            lstEvent[0].TECH_FlightAPIInvoked__c = false;
            System.debug(lstEvent[0]);
            update lstEvent;
            Test.stopTest();
            lstEvent = [Select id, name, ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, AirplaneType__c, Plane_Number__c,
                            ScheduledArrDateTime__c,ActualDepaDateTime__c, ActualArriDateTime__c, Scheduled_Arrival_UTC__c, Estimated_Arrival_UTC__c,
                            Actual_Arrival_UTC__c, Scheduled_Depature_UTC__c, Estimated_Departure_UTC__c, Actual_Departure_UTC__c
                            FROM Event__c ];
            System.assertEquals(lstEvent[0].DeparturePort__c , 'SYD');
        }
    }
}