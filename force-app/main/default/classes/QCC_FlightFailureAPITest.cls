/**************************************************************************************************
* Test Class Name : QCC_FlightFailureAPITest
*
* Description     :
* Unit Test Class for QCC_FlightFailureAPI.
*
* Test Coverage:
* - Flight Cancellation payload processing
* - FlightFailure record creation
* - Response validation
*
**************************************************************************************************/
@IsTest
private class QCC_FlightFailureAPITest {
    
      @TestSetup
static void setupData() {

    insert new List<Trigger_Status__c>{

        new Trigger_Status__c(
            Name = 'FltFlrTrgCheckDuplicateFF',
            Active__c = true
        ),

        new Trigger_Status__c(
            Name = 'FltFlrTrgAddFailureCodePassEvt',
            Active__c = true
        ),

        new Trigger_Status__c(
            Name = 'FltFlrTrgUpdateEmailCom',
            Active__c = true
        ),

        new Trigger_Status__c(
            Name = 'FltFlrTrgFlightFailureDeleteCheck',
            Active__c = true
        )
    };
}

    //=========================================================================
    // Constants
    //=========================================================================

    private static final String REQUEST_URI =
        '/services/apexrest/QCCFlightFailure';

    //=========================================================================
    // Test Methods
    //=========================================================================

    /**
     * Verifies Flight Cancellation payload creates a FlightFailure record.
     */
    @IsTest
    static void testFlightCancellation_CreateFlightFailure() {

        // Given
        RestRequest req = new RestRequest();
        req.requestURI = REQUEST_URI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            getFlightCancellationPayload()
        );

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        // When
        Test.startTest();
        QCC_FlightFailureAPI.upsertFlightFailure();
        Test.stopTest();

        // Then
        System.assertEquals(
            200,
            res.statusCode,
            res.responseBody == null
                ? 'No Response'
                : res.responseBody.toString()
        );

        List<FlightFailure__c> failures = [
            SELECT Id,
                   Source_Id__c,
                   Source__c,
                   Flight_Number__c,
                   Failure_Code__c,
                   Operating_Carrier__c,
                   DepartureAirport__c,
                   ArrivalAirport__c,
                   OgsMessageId__c,
                   CategoryCode__c,
                   TypeCode__c,
                   DisruptionSubType__c,
                   IsWithinControl__c
            FROM FlightFailure__c
            WHERE Source_Id__c =
                '/disruptionengine/flight-disruption-processor-150'
        ];

        System.assertEquals(
            1,
            failures.size(),
            'One Flight Failure record should be created'
        );

        FlightFailure__c ff = failures[0];

        System.assertEquals(
            '/disruptionengine/flight-disruption-processor-150',
            ff.Source_Id__c
        );

        System.assertEquals(
            'Disruption Engine',
            ff.Source__c
        );

        System.assertEquals(
            'Flight Cancellation',
            ff.Failure_Code__c
        );

        System.assertEquals(
            '0550',
            ff.Flight_Number__c
        );

        System.assertEquals(
            'QF',
            ff.Operating_Carrier__c
        );

        System.assertEquals(
            'SYD',
            ff.DepartureAirport__c
        );

        System.assertEquals(
            'BNE',
            ff.ArrivalAirport__c
        );

        System.assertEquals(
            '150',
            ff.OgsMessageId__c
        );

        System.assertEquals(
            'OPER',
            ff.CategoryCode__c
        );

        System.assertEquals(
            'SEC',
            ff.TypeCode__c
        );

        System.assertEquals(
            'CANCEL',
            ff.DisruptionSubType__c
        );

        System.assertEquals(
            false,
            ff.IsWithinControl__c
        );
    }

    //=========================================================================
    // Test Data
    //=========================================================================

    private static String getFlightCancellationPayload() {

        return '{' +
            '"specversion":"1.0",' +
            '"type":"com.qantas.disruption.flight_disruption.created.v1",' +
            '"source":"/disruptionengine/flight-disruption-processor",' +
            '"id":"150",' +
            '"datacontenttype":"application/*+avro",' +
            '"subject":"flight=550,eventType=CANCEL",' +
            '"time":"2026-07-14T04:29:16.998987674Z",' +
            '"sourceGenerationTime":"2026-07-13T15:00:00.600Z",' +
            '"traceparent":"05-123-72ddcd457b4dd0ad-150",' +
            '"data":{' +
                '"operatingCarrier":"QF",' +
                '"flightNumber":"0550",' +
                '"scheduledDepartureDateLocal":"2026-07-17",' +
                '"scheduledDepartureTimeUtc":"2026-07-16T10:00:00.000Z",' +
                '"estimatedArrivalTimeUtc":null,' +
                '"estimatedDepartureTimeUtc":null,' +
                '"departureAirport":"SYD",' +
                '"arrivalAirport":"BNE",' +
                '"flightDisruptionInfo":{' +
                    '"eventCreationTimeUtc":"2026-07-13T15:00:00.600Z",' +
                    '"ogsMessageId":"150",' +
                    '"disruptionType":"FLIGHT_CANCEL",' +
                    '"disruptionSubType":"CANCEL",' +
                    '"delayDuration":null,' +
                    '"disruptionReason":{' +
                        '"categoryCode":"OPER",' +
                        '"typeCode":"SEC",' +
                        '"employeeMessage":"Security screening disruptions impacting arrival/departure schedule.",' +
                        '"description":"Security screening disruptions impacting flight schedule",' +
                        '"isWithinControl":false,' +
                        '"additionalNotes":null' +
                    '}' +
                '}' +
            '}' +
        '}';
    }
}