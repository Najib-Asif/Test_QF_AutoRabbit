/**************************************************************************************************
* Class Name    : QCC_FlightFailureAPI
*
* Description   :
* REST API endpoint to receive Flight Disruption events from the Disruption Engine
* and create/update Flight Failure records in Salesforce.
*
* Features:
* - Accepts Flight Disruption payloads via HTTP POST.
* - Validates mandatory request attributes.
* - Maps Flight and Disruption information to FlightFailure__c.
* - Processes only Flight Cancellation events.
* - Upserts Flight Failure records using Source_Id__c as External ID.
* - Returns appropriate success/error responses.
*
* Author        : Pankaj Sharma
* Created Date  : 10.07.2026
**************************************************************************************************/
@RestResource(urlMapping='/QCCFlightFailure')
global with sharing class QCC_FlightFailureAPI {
// =========================================================================
// Constants
// =========================================================================

private static final String FAILURE_CANCEL = 'Flight Cancellation';
private static final String FAILURE_DELAY = 'Flight Delay';

private static final String DISRUPTION_CANCEL = 'FLIGHT_CANCEL';
private static final String DISRUPTION_DELAY = 'ESTIMATE_CHANGE';

private static final String SOURCE_SYSTEM = 'Disruption Engine';
private static final String FULL_FLIGHT = 'Full Flight';
    
    
    
    // =========================================================================
    // REST Endpoint
    // =========================================================================

    /**
     * Processes incoming Flight Failure requests.
     */
    @HttpPost
    global static void upsertFlightFailure() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {

            String requestBody = getRequestBody(req);
            String resBody;

            // Deserialize incoming payload
            FlightRequestWrapper wrapper = parseRequest(requestBody);

            // Validate mandatory fields
            validateWrapper(wrapper);

            // Generate unique source identifier
            String externalKey = wrapper.source + '-' + wrapper.id;

            // Map payload to FlightFailure record
            FlightFailure__c record =
                mapToFlightFailure(wrapper, externalKey);

            Database.UpsertResult sr;

            // Process only Flight Cancellation events
            if (record.Failure_Code__c == FAILURE_CANCEL) {

                sr = Database.upsert(
                    record,
                    FlightFailure__c.Source_Id__c,
                    false
                );

            } else {

                res.statusCode = 400;
                resBody = 'Only Flight Cancellation events are processed';
                res.responseBody = Blob.valueOf(resBody);
                return;
            }

            // Handle response
            handleUpsertResponse(req,res, sr);

        } catch (Exception ex) {

            res.statusCode = 400;

            String resBody = 'Error returned: ' + ex.getMessage();

            res.responseBody = Blob.valueOf(resBody);

         
        }
    }

    // =========================================================================
    // Request Processing Methods
    // =========================================================================

    /**
     * Retrieves request payload.
     *
     * @param req Incoming REST request
     * @return JSON payload
     */
    private static String getRequestBody(RestRequest req) {

        if (req.requestBody != null) {
            return req.requestBody.toString();
        }
          return req.requestBody.toString();
    }

    /**
     * Converts JSON payload into wrapper object.
     *
     * @param requestBody Raw request payload
     * @return FlightRequestWrapper object
     */
    private static FlightRequestWrapper parseRequest(
        String requestBody
    ) {

        requestBody = requestBody.replace(
            '"time"',
            '"eventTime"'
        );

        return (FlightRequestWrapper)
            JSON.deserialize(
                requestBody,
                FlightRequestWrapper.class
            );
    }

    // =========================================================================
    // Validation Methods
    // =========================================================================

    /**
     * Validates mandatory request attributes.
     *
     * @param wrapper Request wrapper
     * @throws CustomException
     */
private static void validateWrapper(FlightRequestWrapper wrapper) {

    if (
        wrapper == null ||
        String.isBlank(wrapper.id) ||
        String.isBlank(wrapper.source)
    ) {
        throw new CustomException(
            'Mandatory fields missing: source/id'
        );
    }
}

    // =========================================================================
    // Flight Failure Mapping Methods
    // =========================================================================

    /**
     * Maps incoming request data to FlightFailure__c.
     *
     * @param wrapper Request wrapper
     * @param externalKey External Id
     * @return FlightFailure__c record
     */
    private static FlightFailure__c mapToFlightFailure(
        FlightRequestWrapper wrapper,
        String externalKey
    ) {

        FlightFailure__c rec = new FlightFailure__c();

        rec.Source_Id__c = externalKey;
        rec.Source__c = SOURCE_SYSTEM;

        if (wrapper.data == null) {
            return rec;
        }

        mapFlightDetails(rec, wrapper.data);

        mapDisruptionDetails(
            rec,
            wrapper.data.flightDisruptionInfo
        );

        return rec;
    }

    // =========================================================================
    // Flight Details Mapping
    // =========================================================================

    /**
     * Maps flight-level information.
     *
     * @param rec Flight Failure record
     * @param data Flight data
     */
    private static void mapFlightDetails(
        FlightFailure__c rec,
        Data data
    ) {

        rec.Flight_Number__c = data.flightNumber;
        rec.Operating_Carrier__c = data.operatingCarrier;
        rec.DepartureAirport__c = data.departureAirport;
        rec.ArrivalAirport__c = data.arrivalAirport;

        rec.DepartureDateLocal__c =
            parseDate(data.scheduledDepartureDateLocal);

        rec.ScheduledDepartureTimeUtc__c =
            parseDateTime(data.scheduledDepartureTimeUtc);

        rec.EstimatedArrivalTimeUtc__c =
            parseDateTime(data.estimatedArrivalTimeUtc);

        rec.EstimatedDepartureTimeUtc__c =
            parseDateTime(data.estimatedDepartureTimeUtc);
    }

    // =========================================================================
    // Disruption Details Mapping
    // =========================================================================

    /**
     * Maps disruption-related information.
     *
     * @param rec Flight Failure record
     * @param info Disruption details
     */
    private static void mapDisruptionDetails(
        FlightFailure__c rec,
        FlightDisruptionInfo info
    ) {

        if (info == null) {
            return;
        }

        rec.DisruptionSubType__c = info.disruptionSubType;
        rec.OgsMessageId__c = info.ogsMessageId;
        rec.DelayDuration__c = info.delayDuration;

        rec.EventCreationTimeUtc__c =
            parseDateTime(info.eventCreationTimeUtc);

        mapDisruptionReason(
            rec,
            info.disruptionReason
        );

        // Default values
        rec.Pre_Flight__c = true;
        rec.Affect_Sub_Section__c = FULL_FLIGHT;
        rec.Affected_Region__c = FULL_FLIGHT;

        // Determine Failure Code based on disruption type
        if (info.disruptionType == DISRUPTION_CANCEL) {

            rec.Failure_Code__c = FAILURE_CANCEL;

        } else if (
            info.disruptionType == DISRUPTION_DELAY
        ) {

            rec.Failure_Code__c = FAILURE_DELAY;
        }
    }

    // =========================================================================
    // Disruption Reason Mapping
    // =========================================================================

    /**
     * Maps disruption reason information.
     *
     * @param rec Flight Failure record
     * @param reason Disruption reason details
     */
    private static void mapDisruptionReason(
        FlightFailure__c rec,
        DisruptionReason reason
    ) {

        if (reason == null) {
            return;
        }

        rec.CategoryCode__c = reason.categoryCode;
        rec.TypeCode__c = reason.typeCode;
        rec.IsWithinControl__c = reason.isWithinControl;
        rec.EmployeeMessage__c = reason.employeeMessage;
        rec.Description__c = reason.description;
        rec.AdditionalNotes__c = reason.additionalNotes;

        // Configure Disruption Category
        rec.Disruption_Category__c =
            getConfigValue(
                'DisruptionReasonRootCause_',
                reason.categoryCode
            );

        // Configure Disruption Type
        rec.Disruption_Type__c =
            getConfigValue(
                'DisruptionReasonPrimRootCause_',
                reason.typeCode
            );
    }

    // =========================================================================
    // Utility Methods
    // =========================================================================

    /**
     * Converts String date value to Date.
     *
     * @param val Date string
     * @return Date
     */
    private static Date parseDate(String val) {

        return String.isBlank(val)
            ? null
            : Date.valueOf(val);
    }
    
      /**
     * Converts String datetime value to Datetime.
     *
     * @param val Date string
     * @return Date
     */
    
    private static Datetime parseDateTime(String val) {

    if (String.isBlank(val)) {
        return null;
    }

    return Datetime.valueOfGmt(
        val.replace('T', ' ')
           .replace('Z', '')
    );
}

    /**
     * Retrieves configuration value from custom settings.
     *
     * @param prefix Configuration prefix
     * @param key Configuration key
     * @return Configured value
     */
    private static String getConfigValue(
        String prefix,
        String key
    ) {

        if (String.isBlank(key)) {
            return null;
        }

        return CustomSettingsUtilities.getConfigDataMap(
            prefix + key
        );
    }

    // =========================================================================
    // Response Handling
    // =========================================================================

    /**
     * Handles API response after record upsert.
     *
     * @param res REST Response
     * @param sr Upsert Result
     */
    private static void handleUpsertResponse(
        RestRequest req,
        RestResponse res,
        Database.UpsertResult sr
       
    ) {

        if (sr != null && sr.isSuccess()) {

            res.statusCode = 200;
            res.responseBody =
                Blob.valueOf('Flight Failure Created');

        } else if (sr != null) {

            for (Database.Error err : sr.getErrors()) {

                res.statusCode = 400;

                res.responseBody = Blob.valueOf(
                    'Error returned: '
                    + err.getStatusCode()
                    + ' - '
                    + err.getMessage()
                );
                string inboundPayload = req.requestBody.toString();
        Log__c logRecordOutbound = QCC_LogUtilityHelper.generateLogRecord('QCC - Inbound Flight Failure REST API', 'QCC_FlightFailureAPI', 'upsertFlightFailure', '', inboundPayload, false, '', null, '');
        QCC_LogUtilityHelper.createLogRecord(logRecordOutbound);
            }
        }
    }

    // =========================================================================
    // Custom Exception
    // =========================================================================

    public class CustomException extends Exception {}

    // =========================================================================
    // Wrapper Classes
    // =========================================================================

    global class FlightRequestWrapper {
        public String specversion;
        public String type;
        public String source;
        public String id;
        public String datacontenttype;
        public String subject;
        public String eventTime;
        public String sourceGenerationTime;
        public String traceparent;
        public Data data;
    }

    global class Data {
        public String operatingCarrier;
        public String flightNumber;
        public String scheduledDepartureDateLocal;
        public String scheduledDepartureTimeUtc;
        public String estimatedArrivalTimeUtc;
        public String estimatedDepartureTimeUtc;
        public String departureAirport;
        public String arrivalAirport;
        public FlightDisruptionInfo flightDisruptionInfo;
    }

    global class FlightDisruptionInfo {
        public String eventCreationTimeUtc;
        public String ogsMessageId;
        public String disruptionType;
        public String disruptionSubType;
        public String delayDuration;
        public DisruptionReason disruptionReason;
    }

    global class DisruptionReason {
        public String categoryCode;
        public String typeCode;
        public String employeeMessage;
        public String description;
        public Boolean isWithinControl;
        public String additionalNotes;
    }
}