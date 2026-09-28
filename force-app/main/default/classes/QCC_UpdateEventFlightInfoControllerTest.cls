@IsTest
public class QCC_UpdateEventFlightInfoControllerTest {
    @testSetup 
    static void setup() {
        List<Qantas_API__c> lstQAPI = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQAPI;
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createDelayCode();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        insert lsttrgStatus;
        //lsttrgStatus = TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting();
        //for(Trigger_Status__c ts : lsttrgStatus){
        //    ts.Active__c = false;
        //}
        //insert lsttrgStatus;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Journey Manager').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        System.runAs(u1){
            Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Diversion Due to Weather','Domestic');
            newEvent1.ScheduledDepDate__c = System.today();
            newEvent1.FlightNumber__c = 'QF0516';
            
            newEvent1.DeparturePort__c = 'LHR';
            newEvent1.ArrivalPort__c = 'SYD';
            newEvent1.ScheduledDepDate__c = Date.newInstance(2018,10,10);
            newEvent1.OwnerId = u1.Id;
            insert newEvent1;
        }
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_QSOAUserName','sampleuser1username@sample.com'));
        insert lstConfigData;

    }
    @IsTest
    public static void testUpdateFlightInfo(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
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
            Test.startTest();
            List<Event__c> lstEvent = [select id from Event__c];
            String rs = QCC_UpdateEventFlightInfoController.submitUpdateforEvent(lstEvent[0].id);
            Test.stopTest();
            System.assertEquals(rs, 'Success: flight info updated');
        }
    }
	
    @IsTest
    public static void testUpdateFlightInfo2(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        list<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
        Map<String, String> mapHeader = new Map<String, String>();
        String body = '{  '
            +'   "flights":[  '
            +'        {  '
            +'           "marketingCarrier":"QF",'
            +'           "marketingFlightNo":"0516",'
            +'           "suffix":"",'
            +'           "departureAirportCode":"LHR",'
            +'           "departureAirportName":"BRISBANE",'
            +'           "arrivalAirportCode":"SYD",'
            +'           "arrivalAirportName":"KINGSFORD SMITH",'
            +'           "departureTerminal":"",'
            +'           "departureGate":"",'
            +'           "arrivalTerminal":"",'
            +'           "arrivalGate":"",'
            +'           "equipmentTailNumber":null,'
            +'           "equipmentTypeCode":"146",'
            +'           "equipmentSubTypeCode":"14Z",'
            +'           "flightStatus":"",'
            +'           "flightDuration":"90",'
            +'           "delayDuration":null,'
            +'           "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
            +'           "estimatedDepartureUTCTimeStamp":null,'
            +'           "actualDepartureUTCTimeStamp":null,'
            +'           "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
            +'           "estimatedArrivalUTCTimeStamp":null,'
            +'           "actualArrivalUTCTimeStamp":null,'
            +'           "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
            +'           "estimatedDepartureLocalTimeStamp":null,'
            +'           "actualDepartureLocalTimeStamp":null,'
            +'           "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
            +'           "estimatedArrivalLocalTimeStamp":null,'
            +'           "actualArrivalLocalTimeStamp":null,'
            +'           "primaryBaggageCarousel":"",'
            +'           "secondaryBaggageCarousel":""'
            +'           ,"delay": [{'
            +'           "reasonCode": "580",'
            +'           "shortDescription": "IT",'
            +'           "longDescription": "max 200 chars",'
            +'           "delayDuration": "100"'
            +'           }]'
            +'        }'
            +'   ]'
            +'}';

        //lstRes.add(new QCC_CAPFlightInfoMock.MockRes(404, 'Not Found', Body, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', Body, mapHeader));

        body = '{  '
                +'   "flights":[  '
                +'      {  '
                +'         "flightNumbers":[  '
                +'            {  '
                +'               "airline":"QF",'
                +'               "code":9,'
                +'               "primary":true,'
                +'               "originDate":"2018-10-10",'
                +'               "threeLetterAirline":"QFA"'
                +'            }'
                +'         ],'
                +'         "sectors":[  '
                +'            {  '
                +'               "sectorId":"QF9_PER_LHR_21052018",'
                +'               "from":"LHR",'
                +'               "to":"MEL",'
                +'               "departure":{  '
                +'                  "estimated":"2018-05-21T18:45:00+08:00",'
                +'                  "actual":"",'
                +'                  "scheduled":"2018-05-21T18:45:00+08:00",'
                +'                  "status":"Estimated",'
                +'                  "terminal":"T3",'
                +'                  "gate":"",'
                +'                  "boardingStatus":"",'
                +'                  "eligibleForSubscription":true'
                +'               },'
                +'               "arrival":{  '
                +'                  "estimated":"2018-05-22T05:05:00+01:00",'
                +'                  "actual":"2018-05-22T05:05:00+01:00",'
                +'                  "scheduled":"2018-05-22T05:05:00+01:00",'
                +'                  "status":"Landed",'
                +'                  "terminal":"",'
                +'                  "gate":"",'
                +'                  "eligibleForSubscription":true'
                +'               },'
                +'               "sectorDiversion":"PLANNED"'
                +'            }'
                +'         ]'
                +'      },'
                +'      {  '
                +'         "flightNumbers":[  '
                +'            {  '
                +'               "airline":"QF",'
                +'               "code":9,'
                +'               "primary":true,'
                +'               "originDate":"2018-10-10",'
                +'               "threeLetterAirline":"QFA"'
                +'            }'
                +'         ],'
                +'         "sectors":[  '
                +'            {  '
                +'               "sectorId":"QF9_MEL_PER_22052018",'
                +'               "from":"MEL",'
                +'               "to":"SYD",'
                +'               "departure":{  '
                +'                  "estimated":"2018-05-22T15:15:00+10:00",'
                +'                  "actual":"2018-05-22T15:13:00+10:00",'
                +'                  "scheduled":"2018-05-22T15:15:00+10:00",'
                +'                  "status":"Departed",'
                +'                  "terminal":"T2",'
                +'                  "gate":"",'
                +'                  "boardingStatus":"CLOSED",'
                +'                  "eligibleForSubscription":false'
                +'               },'
                +'               "arrival":{  '
                +'                  "estimated":"2018-05-22T16:51:00+08:00",'
                +'                  "actual":"2018-05-22T16:46:00+08:00",'
                +'                  "scheduled":"2018-05-22T17:15:00+08:00",'
                +'                  "status":"Landed",'
                +'                  "terminal":"T3",'
                +'                  "gate":"18",'
                +'                  "eligibleForSubscription":false'
                +'               },'
                +'               "sectorDiversion":"PLANNED"'
                +'            }'
                +'         ]'
                +'      }'
                +'   ],'
                +'   "lastUpdatedDateTime":"2018-05-24T07:37:36.526Z"'
                +'}';

        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', Body, mapHeader));
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));
            Test.startTest();
            List<Event__c> lstEvent = [select id from Event__c];
            List<Id> setId = new List<Id>();
            for(Event__c ev:lstEvent){
                setId.add(ev.id);
            }

            String rs = QCC_EventFlightInfoUpdateHelper.updateMultiSectorFlightInfoforEvent(setId);


            Test.stopTest();
            System.assertEquals(rs, 'Success: flight info updated');
        }
    }

    @IsTest
    public static void testUpdateFlightInfo3(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        list<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
        Map<String, String> mapHeader = new Map<String, String>();
        String body = '{  '
            +'   "flights":[  '
            +'        {  '
            +'           "marketingCarrier":"QF",'
            +'           "marketingFlightNo":"0516",'
            +'           "suffix":"",'
            +'           "departureAirportCode":"LHR",'
            +'           "departureAirportName":"BRISBANE",'
            +'           "arrivalAirportCode":"SYD",'
            +'           "arrivalAirportName":"KINGSFORD SMITH",'
            +'           "departureTerminal":"",'
            +'           "departureGate":"",'
            +'           "arrivalTerminal":"",'
            +'           "arrivalGate":"",'
            +'           "equipmentTailNumber":null,'
            +'           "equipmentTypeCode":"146",'
            +'           "equipmentSubTypeCode":"14Z",'
            +'           "flightStatus":"",'
            +'           "flightDuration":"90",'
            +'           "delayDuration":null,'
            +'           "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
            +'           "estimatedDepartureUTCTimeStamp":null,'
            +'           "actualDepartureUTCTimeStamp":null,'
            +'           "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
            +'           "estimatedArrivalUTCTimeStamp":null,'
            +'           "actualArrivalUTCTimeStamp":null,'
            +'           "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
            +'           "estimatedDepartureLocalTimeStamp":null,'
            +'           "actualDepartureLocalTimeStamp":null,'
            +'           "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
            +'           "estimatedArrivalLocalTimeStamp":null,'
            +'           "actualArrivalLocalTimeStamp":null,'
            +'           "primaryBaggageCarousel":"",'
            +'           "secondaryBaggageCarousel":""'
            +'           ,"delay": [{'
            +'           "reasonCode": "580",'
            +'           "shortDescription": "IT",'
            +'           "longDescription": "max 200 chars",'
            +'           "delayDuration": "100"'
            +'           }]'
            +' 			,"airDiversion": {'
            +'            "unScheduledArrivalAirport": "SYD"'
            +'        		}'
            +'        }'
            +'   ]'
            +'}';

        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(404, 'Not Found', Body, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', Body, mapHeader));

        body = '{  '
                +'   "flights":[  '
                +'      {  '
                +'         "flightNumbers":[  '
                +'            {  '
                +'               "airline":"QF",'
                +'               "code":9,'
                +'               "primary":true,'
                +'               "originDate":"2018-07-10",'
                +'               "threeLetterAirline":"QFA"'
                +'            }'
                +'         ],'
                +'         "sectors":[  '
                +'            {  '
                    +'"sectorId": "QF1_SYD_SIN_06072018",'
                    +'"from": "SYD",'
                    +'"to": "SIN",'
                +'               "departure":{  '
                        +'"estimated": "2018-07-06T15:55:00+10:00",'
                        +'"actual": "2018-07-06T15:55:00+10:00",'
                        +'"scheduled": "2018-07-06T15:55:00+10:00",'
                        +'"status": "Departed",'
                        +'"terminal": "",'
                +'                  "gate":"",'
                +'                  "boardingStatus":"",'
                        +'"eligibleForSubscription": false'
                +'               },'
                +'               "arrival":{  '
                        +'"estimated": "2018-07-07T01:45:00+08:00",'
                        +'"actual": "2018-07-06T22:00:00+08:00",'
                        +'"scheduled": "2018-07-06T22:15:00+08:00",'
                        +'"status": "Landed",'
                +'                  "terminal":"",'
                +'                  "gate":"",'
                        +'"eligibleForSubscription": false'
                +'               },'
                +'               "sectorDiversion":"PLANNED"'
                +'      },'
                +'      {  '
                    +'"sectorId": "QF1_SIN_LHR_06072018",'
                    +'"from": "SIN",'
                    +'"to": "LHR",'
                +'               "departure":{  '
                        +'"estimated": "2018-07-06T23:55:00+08:00",'
                        +'"actual": "2018-07-06T23:55:00+08:00",'
                        +'"scheduled": "2018-07-06T23:55:00+08:00",'
                        +'"status": "Cancelled",'
                        +'"terminal": "",'
                +'                  "gate":"",'
                        +'"boardingStatus": "",'
                +'                  "eligibleForSubscription":false'
                +'               },'
                +'               "arrival":{  '
                        +'"estimated": "2018-07-07T16:55:00+01:00",'
                        +'"actual": "",'
                        +'"scheduled": "2018-07-07T06:55:00+01:00",'
                        +'"status": "Cancelled",'
                        +'"terminal": "",'
                        +'"gate": "",'
                +'                  "eligibleForSubscription":false'
                +'               },'
                +'               "sectorDiversion":"PLANNED"'
                +'            }'
                +'         ]'
                +'      }'
                +'   ],'
                +'   "lastUpdatedDateTime":"2018-05-24T07:37:36.526Z"'
                +'}';

        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', Body, mapHeader));
        
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));
            Test.startTest();
            List<Event__c> lstEvent = [select id, ScheduledDepDate__c from Event__c];
            lstEvent[0].ScheduledDepDate__c = Date.valueOf('2018-03-28');
            String rs = QCC_UpdateEventFlightInfoController.submitUpdateforEvent(lstEvent[0].id);
            Test.stopTest();
            System.assertEquals(rs, '');
        }
    }

    @IsTest
    public static void testUpdateFlightInfo4(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        list<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
        Map<String, String> mapHeader = new Map<String, String>();
        String body = '{  '
            +'   "flights":[  '
            +'        {  '
            +'           "marketingCarrier":"QF",'
            +'           "marketingFlightNo":"0516",'
            +'           "suffix":"",'
            +'           "departureAirportCode":"LHR",'
            +'           "departureAirportName":"BRISBANE",'
            +'           "arrivalAirportCode":"SYD",'
            +'           "arrivalAirportName":"KINGSFORD SMITH",'
            +'           "departureTerminal":"",'
            +'           "departureGate":"",'
            +'           "arrivalTerminal":"",'
            +'           "arrivalGate":"",'
            +'           "equipmentTailNumber":null,'
            +'           "equipmentTypeCode":"146",'
            +'           "equipmentSubTypeCode":"14Z",'
            +'           "flightStatus":"",'
            +'           "flightDuration":"90",'
            +'           "delayDuration":null,'
            +'           "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
            +'           "estimatedDepartureUTCTimeStamp":null,'
            +'           "actualDepartureUTCTimeStamp":null,'
            +'           "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
            +'           "estimatedArrivalUTCTimeStamp":null,'
            +'           "actualArrivalUTCTimeStamp":null,'
            +'           "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
            +'           "estimatedDepartureLocalTimeStamp":null,'
            +'           "actualDepartureLocalTimeStamp":null,'
            +'           "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
            +'           "estimatedArrivalLocalTimeStamp":null,'
            +'           "actualArrivalLocalTimeStamp":null,'
            +'           "primaryBaggageCarousel":"",'
            +'           "secondaryBaggageCarousel":""'
            +'           ,"delay": [{'
            +'           "reasonCode": "580",'
            +'           "shortDescription": "IT",'
            +'           "longDescription": "max 200 chars",'
            +'           "delayDuration": "100"'
            +'           }]'
            +'        }'
            +'   ]'
            +'}';

        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(404, 'Not Found', Body, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(404, 'Not Found', Body, mapHeader));
        
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));
            Test.startTest();
            List<Event__c> lstEvent = [select id from Event__c];
            String rs = QCC_UpdateEventFlightInfoController.submitUpdateforEvent(lstEvent[0].id);
            Test.stopTest();
            System.assertEquals(rs, '');
        }
    }

    @IsTest
    static void testParseFlightStatusAPIResponse() {
        String json=        '{'+
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
        QCC_FlightStatusAPIResponse obj = QCC_FlightStatusAPIResponse.parse(json);
        System.assert(obj != null);
    }

    @IsTest
    static void testParseFlightInfoResponse() {
        String json=  '{  '
            +'   "flights":[  '
            +'        {  '
            +'           "marketingCarrier":"QF",'
            +'           "marketingFlightNo":"0516",'
            +'           "suffix":"1",'
            +'           "departureAirportCode":"LHR",'
            +'           "departureAirportName":"BRISBANE",'
            +'           "arrivalAirportCode":"SYD",'
            +'           "arrivalAirportName":"KINGSFORD SMITH",'
            +'           "departureTerminal":"1",'
            +'           "departureGate":"1",'
            +'           "arrivalTerminal":"1",'
            +'           "arrivalGate":"1",'
            +'           "equipmentTailNumber":null,'
            +'           "equipmentTypeCode":"146",'
            +'           "equipmentSubTypeCode":"14Z",'
            +'           "flightStatus":"1",'
            +'           "flightDuration":"90",'
            +'           "delayDuration":null,'
            +'           "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
            +'           "estimatedDepartureUTCTimeStamp":null,'
            +'           "actualDepartureUTCTimeStamp":null,'
            +'           "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
            +'           "estimatedArrivalUTCTimeStamp":null,'
            +'           "actualArrivalUTCTimeStamp":null,'
            +'           "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
            +'           "estimatedDepartureLocalTimeStamp":null,'
            +'           "actualDepartureLocalTimeStamp":null,'
            +'           "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
            +'           "estimatedArrivalLocalTimeStamp":null,'
            +'           "actualArrivalLocalTimeStamp":null,'
            +'           "primaryBaggageCarousel":"",'
            +'           "secondaryBaggageCarousel":""'
            +'           ,"delay": [{'
            +'           "reasonCode": "580",'
            +'           "shortDescription": "IT",'
            +'           "longDescription": "max 200 chars",'
            +'           "delayDuration": "100"'
            +'           }]'
            +'        }'
            +'   ]'
            +'}';
        QCC_FlightInfoResponse obj = (QCC_FlightInfoResponse) System.JSON.deserialize(json, QCC_FlightInfoResponse.class);
        System.assert(obj != null);
    }

    static TestMethod void updatePassengerforEventTest(){
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'QCC_PassengerAPIInvokeMSG';
        qc.Config_Value__c = 'Success';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;

        Event__c objEvent = [select id from Event__c limit 1];
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.FlightNumber__c = '0001';
        objEvent.ScheduledDepDate__c = System.today();
        objEvent.DeparturePort__c = 'MEL';
        objEvent.ArrivalPort__c = 'SYD';
        update objEvent;
        System.assert(objEvent.Id != Null, 'Event is not updated');
        Map<String, String> mapHeader= new Map<String, String>();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', '{"Response": "Sucess"}', mapHeader));
			String res = QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
            System.assert(res == 'Success', 'Message is not matching ');
            Event__c objEventUpd = [select id, TechPassenger_API_Invoked__c from Event__c where Id =: objEvent.Id];
            System.assert(objEventUpd.TechPassenger_API_Invoked__c == true, 'passenger API is Not Invoked');
        Test.stopTest();
    }

    static TestMethod void updatePassengerforEventNegativeTest(){
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'QCC_PassengerAPIInvokeMSG';
        qc.Config_Value__c = 'Success';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        Event__c objEvent = [select id from Event__c limit 1];
        Test.startTest();
        Boolean isException = false;
        try{
            String res = QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        }catch(Exception ex){
            isException = true;
        }
        System.assert(isException == true, 'Exception is not thrown when required feilds are missing');
        Test.stopTest();
    }

    static TestMethod void updatePassengerforEventMultipleTest(){
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'QCC_PassengerAPIinProgressMSG';
        qc.Config_Value__c = 'API Already Invoked';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        Event__c objEvent = [select id, TechPassenger_API_Invoked__c from Event__c limit 1];
        objEvent.TechPassenger_API_Invoked__c = true;
        update objEvent;
        Test.startTest();
            String res = QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
            System.assert(res == 'API Already Invoked', 'Message is not matching ');
            Event__c objEventUpd = [select id, TechPassenger_API_Invoked__c from Event__c where Id =: objEvent.Id];
            System.assert(objEventUpd.TechPassenger_API_Invoked__c == true, 'passenger API is Not Invoked');
        Test.stopTest();
    }
}