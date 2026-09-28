/**
 * @description       : Only case origin of Red App and Qantas.com enter the queue job
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 01-10-2024
 * @last modified by  : Praveen Sampath
**/
public class QCC_CaseCreatorV2 implements Queueable, Database.AllowsCallouts {
    // Get a valid token for API calls
    private static final String BOOKING_TOKEN = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
    private static final Map<String, Airport_Code__c> AIRPORT_CODES_MAP = queryAirportCodes();
    
    private static final String CASE_TYPE_INSURANCE = CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type');
    private static final String CASE_ORIGIN_REDAPP = CustomSettingsUtilities.getConfigDataMap('QCC_Red App');
    private static final String CASE_ORIGIN_QANTAS = CustomSettingsUtilities.getConfigDataMap('QCC Qantas');
    private static final String CASE_TYPE_OTSR = CustomSettingsUtilities.getConfigDataMap('Case_Type_OTSR'); // TBA
    private static final String CASE_STATUS_CLOSED = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String CASE_RM_AC = CustomSettingsUtilities.getConfigDataMap('CaseResolutionMethod_AutoClosed');
    private static final String CASE_GROUP_DF = CustomSettingsUtilities.getConfigDataMap('CaseGroupDF');
    private static final String CASE_GROUP_PBNS = CustomSettingsUtilities.getConfigDataMap('CaseGroupPBNS');
    private static final String MDT_QETS_TYPE_IIL = CustomSettingsUtilities.getConfigDataMap('Mdt_QETS_IIL'); // TBA

    private List<Case> caseRecords;
    private String sessionId;

    private static Boolean caseUpdated;
    private static Boolean bookingFound;
    private static Boolean flightFound;
    private static String creationDate;
    private static Boolean passengerFound;
    private static Boolean flightPassengerFound;
    private static Map<String, LegInformation> mapPassIdToLegInfo;
    public static String fcrValueForTestClass;

    public QCC_CaseCreatorV2(List<Case> caseRecords, String sessionId) {
        this.caseRecords = caseRecords;
        this.sessionId = sessionId;
    }

    public void execute(QueueableContext qContext) {
        Set<Id> caseRecordIds = new Set<Id>();
        try {
            List<Case_Relationships__c> relationshipsToBeInserted = new List<Case_Relationships__c>();
            List<Case> casesToBeUpdated = new List<Case>();
            List<Case> caseForCongaScheduler = new List<Case>();
            Map<Id, Contact> contactRecordsMap;
            Set<Id> contactIds = new Set<Id>();
            List<Case> recentCases;
            String firstContactResolutionPossible;
            Contact objContact;
            for (Case objCase : caseRecords) {
                if (objCase.ContactId != null) {
                    contactIds.add(objCase.ContactId);
                }
                caseRecordIds.add(objCase.Id);
            }
            caseRecords = queryCaseRecords(caseRecordIds);
            contactRecordsMap = queryContactRecords(contactIds);
            recentCases = queryRecentCases(contactIds);
            for (Case objCase : caseRecords) {
                caseUpdated = false;
                bookingFound = false;
                flightFound = false;
                passengerFound = false;
                flightPassengerFound = false;
                creationDate = '';
                if (objCase.ContactId != null) {
                    // Retrieve the contact associated with the case
                    objContact = contactRecordsMap.get(objCase.ContactId);
                    // Set the case status and resolution method based on its type
                    setCaseStatusAndResolution(objCase);
                    // Process booking details for the case
                    processBookingDetails(objCase, objContact);
                    // Check for recent cases and create relationships if necessary
                    relationshipsToBeInserted.addAll(processRecentCases(objCase, objContact, recentCases));
                    firstContactResolutionPossible = 'No';
                    // To update required case values for Conga Scheduler or post to chatter and update other case values
                    firstContactResolutionPossible = updateCaseForConga(objCase, firstContactResolutionPossible);
                    if (firstContactResolutionPossible.equals('Yes') || firstContactResolutionPossible.equals('Ineligible')) {
                        caseForCongaScheduler.add(objCase);
                    }
                } else {
                    updateCaseValuesForInsurance(objCase);
                }
                if (caseUpdated) {
                    casesToBeUpdated.add(objCase);
                }
            }
            // Insert the relationships
            if (!relationshipsToBeInserted.isEmpty()) {
                insert relationshipsToBeInserted;
            }
            if (!casesToBeUpdated.isEmpty()) {
                update casesToBeUpdated;
            }
            if (!caseForCongaScheduler.isEmpty()) {
                ID jobID = System.enqueueJob(new CongaMailSchedulerV2(sessionId, caseForCongaScheduler));
            }
        } catch (Exception ex) {
            // Log any exceptions for debugging purposes
            CreateLogs.insertLogRec(
                'Log Exception Logs Rec Type', 'QCC - Auto Case Creation', 'QCC_CaseCreatorV2',
                'execute', '', '', false, String.valueOf(caseRecordIds), ex);
        }
    }

    private static List<Case> queryCaseRecords(Set<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            return new List<Case>();
        }
        return [ SELECT CaseNumber, Id, Type, Description, Status, Resolution_Method__c, Closed_By__c, Booking_PNR__c, Flight_Number__c,
                    ContactId, Group__c, Origin, Conga_Email_Template_ID__c, Conga_Template_ID__c, Contact_Email__c,
                    Actual_Departure_Date_Time__c, Actual_Arrival_Date_Time__c, Arrival_Delay_Time__c, Arrival_Delay_Time_Hours__c,
                    Arrival_Delay_Time_Mins__c, Departure_Delay_Time_Hours__c, Departure_Delay_Time_Mins__c, Departure_Delay_Time__c,
                    Ticket_Status__c,Fare_Total__c,Ticket_Number__c,Suburb__c,Street__c,State__c,Settlement_Value__c,Refund_Type__c,
                    Refund_Amount__c,Rebooked_Flight_Number__c,Rebooked_Flight_Delay_Mins__c,Rebooked_Flight_Delay_Hours__c,
                    Rebooked_Flight_Actual_Arrival_Date_Time__c,Post_Code__c,Passenger_Last_Name__c,Passenger_First_Name__c,
                    Lost_Property_Name__c,Located_Date__c,Ticket_Issue_Date__c, QCC_enableAssignmentRules__c, First_Name__c,
                    Disrupt_Type__c,Departure_Date_Time__c,Departure_City__c,Delivery_Port__c, TECH_SelectedPassengers__c,
                    Delivery_Date__c,Delay_Reason__c,Booking_Change_Fee__c,Cancelled_Date__c,Cancellation_Fee__c, Last_Name__c,
                    Baggage_File_Reference__c,Arrival_Date_Time__c,Arrival_City__c, Country__c, Airline__c, Flight_Cancellation__c,
                    Arrival_Airport_Code__c, Departure_Airport_Code__c,Departure_UTC_Date_Time__c, Flight_Type_Code__c, 
                    Segment_Id__c, Flight_Delay__c, Cabin_Class__c, Passenger_Segment_Id__c, Flight_Leg_Flown_Statuses__c, 
                    Aircraft_Type_Code__c, Check_In_Status__c, Sector__c, Seat_Number__c, Specific_Needs__c
                    FROM Case WHERE Id IN :caseIds ];
    }

    private static Map<String, Airport_Code__c> queryAirportCodes() {
        Map<String, Airport_Code__c> airportCodesMap = new Map<String, Airport_Code__c>();
        for (Airport_Code__c objAirportCode : [ SELECT Name, Freight_Station_Name__c, Freight_Airport_Country_Name__c 
                                                FROM Airport_Code__c ])
        {
            airportCodesMap.put(objAirportCode.Name, objAirportCode);
        }
        return airportCodesMap;
    }

    private static Map<Id, Contact> queryContactRecords(Set<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) {
            return new Map<Id, Contact>();
        }
        return new Map<Id, Contact>([ SELECT Id, CAP_ID__c, Frequent_Flyer_Number__c FROM Contact WHERE Id IN :contactIds ]);
    }

    // Method to set the case status and resolution based on its type
    private static void setCaseStatusAndResolution(Case caseRecord) {
        // If the case type is 'On the Spot Recovery', set its status to closed if not already set
        if (CASE_TYPE_OTSR.equalsIgnoreCase(caseRecord.Type) && String.isBlank(caseRecord.Status)) {
            caseRecord.Status = CASE_STATUS_CLOSED;
            caseUpdated = true;
        }
        // If the case status is closed, set the resolution method and closed by fields
        if (CASE_STATUS_CLOSED.equalsIgnoreCase(caseRecord.Status)) {
            if (String.isBlank(caseRecord.Resolution_Method__c)) {
                caseRecord.Resolution_Method__c = CASE_RM_AC;
            }
            caseRecord.Closed_By__c = UserInfo.getUserId();
            caseUpdated = true;
        }
    }

    private static void updateCaseValuesForInsurance(Case objCase) {
        if (CASE_TYPE_INSURANCE.equalsIgnoreCase(objCase.Type)) {
            objCase.FCR__c = false;
            objCase.Is_Response_Requested__c = 'Yes';
            if (!CASE_STATUS_CLOSED.equals(objCase.Status)) {
                objCase.QCC_enableAssignmentRules__c = false;
                objCase.Assign_using_active_assignment_rules__c = true;
            }
            caseUpdated = true;
        }
    }

    // Method to process booking details based on whether the contact is a frequent flyer or not
    private static void processBookingDetails(Case cs, Contact capCon) {
        
        // Check if the contact has a frequent flyer number and necessary booking details
        if (String.isNotBlank(capCon.Frequent_Flyer_Number__c) && String.isNotBlank(cs.Booking_PNR__c) && String.isNotBlank(cs.Flight_Number__c)) {
            // Process booking for a frequent flyer
            processFrequentFlyerBooking(cs, capCon);
        } else if (String.isNotBlank(cs.Booking_PNR__c)  && String.isNotBlank(cs.Last_Name__c)  && String.isNotBlank(cs.Flight_Number__c) ) { 
            // Process booking for a non-frequent flyer
            processNonFrequentFlyerBooking(cs, capCon);
        }else if(String.isNotBlank(cs.Booking_PNR__c)  && String.isNotBlank(cs.Last_Name__c)){
            processNonFrequentFlyerBooking(cs, capCon);
        }
    }

    // Method to process booking details for a frequent flyer
    private static void processFrequentFlyerBooking(Case cs, Contact capCon) {
        // Calculate timestamps for the booking lookup
        Long[] timestamps = getTimeStamps();
        // Invoke the CAP API to get the booking summary
        QCC_CustomerFlightsWrapper.CustomerFlightsWrapper bookingSummary = QCC_InvokeCAPAPI.invokeProductFlightsCAPAPI(
            capCon.Frequent_Flyer_Number__c, BOOKING_TOKEN, timestamps[0], timestamps[1], 1, true
        );
        QCC_PNRFlightInfoWrapper flightInfoHist;
        if (bookingSummary != null && bookingSummary.flights != null) {
            // Iterate through the flights to find a matching booking
            for (QCC_CustomerFlightsWrapper.FlightsDetailWrapper booking : bookingSummary.flights) {
                if (booking.reloc == cs.Booking_PNR__c) {
                    // Booking found
                    bookingFound = true;
                    cs.PNR_Verified__c = true;
                    // Format the creation date
                    creationDate = formatCreationDate(booking.creationDate);
                    cs.TECH_bookingCreationDate__c = creationDate;
                    cs.TECH_bookingArchivalData__c = 'false';
                    
                    // Retrieve flight information
                    QCC_PNRFlightInfoWrapper flightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(
                        cs.Booking_PNR__c, creationDate, BOOKING_TOKEN, false, 'false'
                    );
                    // Update case information with flight details
                    updateCaseInfo(flightInfo, cs,
                                            capCon.Frequent_Flyer_Number__c, false, 'false');
                    // Check flight history if necessary
                    if ((!flightFound) && shouldCheckFlightHistory(cs)) {
                        // Retrieve historical flight information
                        flightInfoHist = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(
                            cs.Booking_PNR__c, creationDate, BOOKING_TOKEN, true, 'true'
                        );
                    }
                    // Update case information with historical flight details
                    updateCaseInfo(flightInfoHist, cs,
                                            capCon.Frequent_Flyer_Number__c, true, 'true');
                    caseUpdated = true;
                    break; // Exit the loop once the booking is found
                }
            }
        }
    }

    // Helper method to get timestamps for date range calculations
    private static Long[] getTimeStamps() {
        Datetime today = System.today();
        Long timestampFuture = today.addDays(365).getTime();
        Long timestampPast = today.addDays(-365).getTime();
        return new Long[] { timestampFuture, timestampPast };
    }

    // Helper method to format the creation date from the API response
    private static String formatCreationDate(String creationDateStr) {
        if (String.isNotBlank(creationDateStr)) {
            List<String> dateParts = creationDateStr.replace('-', ' ').split(' ');
            if (dateParts.size() == 3) {
                return dateParts[2] + '/' + dateParts[1] + '/' + dateParts[0];
            } else if (dateParts.size() > 0) {
                return creationDateStr;
            }
        }
        return null;
    }

    // Method to determine if flight history should be checked based on the case group
    private static Boolean shouldCheckFlightHistory(Case cs) {
        List<String> groupsToCheck = new List<String>{
            'Booking Cancelled by Customer',
            CustomSettingsUtilities.getConfigDataMap('CaseGroupFCQ'),
            CASE_GROUP_DF,
            'Flight Disruptions'
        };
        return groupsToCheck.contains(cs.Group__c);
    }

    // Method to process booking details for a non-frequent flyer
    private static void processNonFrequentFlyerBooking(Case cs, Contact capCon) {
        // Retrieve flight information using the PNR and last name
        QCC_PNRFlightInfoWrapper flightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(
            cs.Booking_PNR__c, cs.Last_Name__c, BOOKING_TOKEN, 'false'
        );
        if (flightInfo != null && flightInfo.booking != null && flightInfo.booking.reloc == cs.Booking_PNR__c) {
            // Booking found
           
            bookingFound = true;
            cs.PNR_Verified__c = true;
            // Set the creation date
            creationDate = flightInfo.booking.creationDate;
            cs.TECH_bookingCreationDate__c = creationDate;
            cs.TECH_bookingArchivalData__c = 'false';
            
            // Update case information with flight details
            updateCaseInfo(flightInfo, cs, capCon.Frequent_Flyer_Number__c, false, 'false');
            caseUpdated = true;
        }
    }

    // Query recent cases for the contact
    private static List<Case> queryRecentCases(Set<Id> contactIds) {
        List<Case> caseRecords = new List<Case>();
        if (contactIds == null || contactIds.isEmpty()) {
            return caseRecords;
        }
        // Calculate the start time based on the current hour
        Datetime startTime = Datetime.newInstance(System.now().year(), System.now().month(), System.now().day(),
                                                  System.now().hour(), 0, 0);
        for (Case caseRecord : [ SELECT Id, ContactId FROM Case 
                                    WHERE ContactId IN :contactIds AND CreatedDate > :startTime AND CreatedDate < :System.now() 
                                    ORDER BY CreatedDate DESC ])
        {
            caseRecords.add(caseRecord);
        }
        return caseRecords;
    }

    // Method to process recent cases for the contact and create relationships
    private static List<Case_Relationships__c> processRecentCases(Case cs, Contact capCon, List<Case> recentCases) {
        // Create case relationships
        List<Case_Relationships__c> relationships = new List<Case_Relationships__c>();
        if (recentCases == null || String.isBlank(capCon.Frequent_Flyer_Number__c)) {
            return relationships;
        }
        for (Case recentCase : recentCases) {
            if (capCon.Id == recentCase.ContactId && cs.Id != recentCase.Id) {
                relationships.add(new Case_Relationships__c(Case_1__c = recentCase.Id, Case_2__c = cs.Id));
            }
        }
        return relationships;
    }

    // Method to update required case values for Conga Scheduler
    private static String updateCaseForConga(Case cs, String firstContactResolutionPossible) {
        try {
            if (!CASE_STATUS_CLOSED.equals(cs.Status) && (!(bookingFound && flightFound && passengerFound && flightPassengerFound)))
            {
                if(!Test.isRunningTest()) {
                    String comments = 'All of the required bookings information has not been successfully added to the case:' 
                                    +'\nBooking (PNR) details found?: ' + (bookingFound ? 'Yes' : 'No') 
                                    +'\nFlight details found?: ' + (flightFound ? 'Yes' : 'No')
                                    +'\nPassenger details found?: ' + (passengerFound ? 'Yes' : 'No')
                                    +'\nFlight Passenger details found?: ' + (flightPassengerFound ? 'Yes' : 'No')
                                    +'\nPlease check the booking details and add the required booking to the case';
                    ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, comments);
                }
                updateCaseValuesForInsurance(cs);
            } else if (CASE_TYPE_INSURANCE.equals(cs.Type)) {    
                // Call to Insurance Letters Business Rules and has to pass Integration = "Yes"
                firstContactResolutionPossible = QCC_EmailButtonController.getCaseValues(null, cs.Type, true, cs);
                String emailTemplateName;
                List<APXTConga4__Conga_Template__c> congaTemplate;
                String key;
                if (firstContactResolutionPossible.equals('Yes')) {
                    cs.FCR__c = true;
                    cs.Auto_Close_on_Email_Sent__c = true;
                    key = cs.Type + '-' + cs.Group__c + '-' + cs.Refund_Type__c;
                    cs.Conga_Email_Template_ID__c = '';
                    cs.Conga_Template_ID__c = '';
                    for (QCC_Email_Template_Setting__mdt etsMdt : QCC_Email_Template_Setting__mdt.getAll().values()) {
                        if (key.equalsIgnoreCase(etsMdt.Type__c+'-'+etsMdt.Group__c+'-'+etsMdt.Category__c)) {
                            cs.Conga_Email_Template_ID__c = QCC_GenericUtils.fetchSalesforceEmailTemplate(etsMdt.EmailTemplateName__c); //Could be any template, not necessarily Conga Template.
                            emailTemplateName = '%' + etsMdt.EmailTemplateName__c + '%';
                            congaTemplate = [ SELECT Id, APXTConga4__Name__c, Email_Template_Name__c, APXTConga4__Template_Group__c, APXTConga4__Template_Type__c 
                                                FROM APXTConga4__Conga_Template__c 
                                                WHERE APXTConga4__Template_Group__c = :etsMdt.TemplateGroup__c 
                                                AND Email_Template_Name__c LIKE :emailTemplateName ];
                            /*if (congaTemplate == null || CASE_GROUP_DF.equalsIgnoreCase(cs.Group__c) || CASE_GROUP_PBNS.equalsIgnoreCase(cs.Group__c)) {
                                cs.Conga_Template_ID__c = '';
                            } else {
                                cs.Conga_Template_ID__c = congaTemplate.Id;
                            }*/
                            if(congaTemplate!=Null && congaTemplate.size()>0 ){
                                cs.Conga_Template_ID__c = congaTemplate[0].Id;
                            }
                            break;
                        }
                    }
                } else if (firstContactResolutionPossible.equals('Ineligible')) {
                    cs.FCR__c = true;
                    cs.Auto_Close_on_Email_Sent__c = true;
                    cs.Conga_Template_ID__c = '';
                    cs.Conga_Email_Template_ID__c = '';
                    key = MDT_QETS_TYPE_IIL + '-' + cs.Group__c;
                    for (QCC_Email_Template_Setting__mdt etsMdt : QCC_Email_Template_Setting__mdt.getAll().values()) {
                        if (key.equalsIgnoreCase(etsMdt.Type__c + '-' + etsMdt.Group__c)) {
                            cs.Conga_Email_Template_ID__c = QCC_GenericUtils.fetchSalesforceEmailTemplate(etsMdt.EmailTemplateName__c);
                            break;
                        }
                    }
                } else {
                    updateCaseValuesForInsurance(cs);
                }
                caseUpdated = true;
            }
        } catch (Exception ex) {
            // Log any exceptions for debugging purposes
            CreateLogs.insertLogRec(
                'Log Exception Logs Rec Type', 'QCC - Auto Case Creation', 'QCC_CaseCreatorV2',
                'updateCaseForConga', String.valueOf(''), String.valueOf(''), 
                false, String.valueOf(cs.Id), ex
            );
        }
        return firstContactResolutionPossible;
    }

    private static void updateCaseInfo(QCC_PNRFlightInfoWrapper pnrFlightInfoWrapper, Case cs, String ffNumber, Boolean isHistory, String archivalData) { 
        try {
            // QDCUSCON - 4425, 4522 -- START
            List<String> passengersSelectedInWebForm = new List<String>();
            List<String> matchedPassengers = new List<String>();
            mapPassIdToLegInfo = new Map<String, LegInformation>();
            if(CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) {
                PassengerWrapper pw = cs.TECH_SelectedPassengers__c != null ? (PassengerWrapper) JSON.deserialize(cs.TECH_SelectedPassengers__c, PassengerWrapper.class) : null;
                if(pw != null) {
                    for(Passenger p: pw.passengers) {
                        String fullName = (p.firstName+p.lastName).toUpperCase();
                        passengersSelectedInWebForm.add(fullName);
                    }
                }
            }
            // QDCUSCON - 4425 -- END
            if (pnrFlightInfoWrapper == null || pnrFlightInfoWrapper.booking == null || pnrFlightInfoWrapper.booking.segments == null) {
                return;
            }
            system.debug('DJ->'+pnrFlightInfoWrapper.booking.segments.size());
            if(pnrFlightInfoWrapper.booking.segments.size() == 1){
                cs.Flight_Number__c = pnrFlightInfoWrapper.booking.segments[0].operatingFlightNumber;
            }
            // Iterate through the segments to find the matching flight
            
            for (QCC_PNRFlightInfoWrapper.Segments segment : pnrFlightInfoWrapper.booking.segments) {
                if (cs.Flight_Number__c == segment.operatingFlightNumber) {
                    //cs.Flight_Number__c = cs.Flight_Number__c.startswith('QF') ? cs.Flight_Number__c : 'QF'+cs.Flight_Number__c;
                    // Flight found
                    flightFound = true;
                    // Update case with flight details
                    cs.TECH_BookingSegmentId__c = segment.segmentId;
                    cs.TECH_BookingSegmentTattoo__c = segment.segmentTattoo;

                    // Set airline information if not already set
                    if (String.isBlank(cs.Airline__c)) {
                        String airlines = String.isNotBlank(segment.operatingCarrierAlphaCode)
                            ? CustomSettingsUtilities.getAirlineCarrierCodes(segment.operatingCarrierAlphaCode)
                            : '';
                        cs.Airline__c = airlines != null ? airlines : 'Non partner Airline';
                    }

                    // Set flight number with code
                    cs.Flight_Number_With_Code__c = segment.operatingCarrierAlphaCode + segment.operatingFlightNumber.replaceFirst('^0+', '');

                    // Set departure and arrival airport codes
                    cs.Departure_Airport_Code__c = String.isBlank(cs.Departure_Airport_Code__c) ? segment.departureAirportCode : cs.Departure_Airport_Code__c;
                    cs.Arrival_Airport_Code__c = String.isBlank(cs.Arrival_Airport_Code__c) ? segment.arrivalAirportCode : cs.Arrival_Airport_Code__c;

                    // Update airport details from the airport codes map
                    if (AIRPORT_CODES_MAP != null) {
                        if (AIRPORT_CODES_MAP.containsKey(cs.Departure_Airport_Code__c)) {
                            cs.Departure_Airport__c = AIRPORT_CODES_MAP.get(cs.Departure_Airport_Code__c).Freight_Station_Name__c;
                            cs.Departure_City__c = AIRPORT_CODES_MAP.get(cs.Departure_Airport_Code__c).Freight_Station_Name__c;
                            cs.Departure_Country__c = AIRPORT_CODES_MAP.get(cs.Departure_Airport_Code__c).Freight_Airport_Country_Name__c;
                        }

                        if (AIRPORT_CODES_MAP.containsKey(cs.Arrival_Airport_Code__c)) {
                            cs.Arrival_Airport__c = AIRPORT_CODES_MAP.get(cs.Arrival_Airport_Code__c).Freight_Station_Name__c;
                            cs.Arrival_City__c = AIRPORT_CODES_MAP.get(cs.Arrival_Airport_Code__c).Freight_Station_Name__c;
                            cs.Arrival_Country__c = AIRPORT_CODES_MAP.get(cs.Arrival_Airport_Code__c).Freight_Airport_Country_Name__c;
                        }
                    }

                    // Set departure and arrival dates and times
                    if (String.isNotBlank(segment.departureLocalDate) && String.isNotBlank(segment.departureLocalTime)) {
                        cs.Departure_Date_Time__c = segment.departureLocalDate + ' ' + segment.departureLocalTime;
                    }
                    cs.Departure_UTC_Date_Time__c = QCC_GenericUtils.convertStringtoDateTime(segment.departureUTCDate, segment.departureUTCTime);

                    if (String.isNotBlank(segment.actualDepartureLocalDate) && String.isNotBlank(segment.actualDepartureLocalTime)) {
                        cs.Actual_Departure_Date_Time__c = segment.actualDepartureLocalDate + ' ' + segment.actualDepartureLocalTime;
                    }

                    if (String.isNotBlank(segment.arrivalLocalDate) && String.isNotBlank(segment.arrivalLocalTime)) {
                        cs.Arrival_Date_Time__c = segment.arrivalLocalDate + ' ' + segment.arrivalLocalTime;
                    }
                    cs.Arrival_UTC_Date_Time__c = QCC_GenericUtils.convertStringtoDateTime(segment.arrivalUTCDate, segment.arrivalUTCTime);

                    if (String.isNotBlank(segment.actualArrivalLocalDate) && String.isNotBlank(segment.actualArrivalLocalTime)) {
                        cs.Actual_Arrival_Date_Time__c = segment.actualArrivalLocalDate + ' ' + segment.actualArrivalLocalTime;
                    }

                    // Set sector if not already set
                    if (String.isNotBlank(segment.departureAirportCode) && String.isNotBlank(segment.arrivalAirportCode) && String.isBlank(cs.Sector__c)) {
                        cs.Sector__c = segment.departureAirportCode + ' ' + segment.arrivalAirportCode;
                    }

                    // Set flight type code and aircraft type
                    cs.Flight_Type_Code__c = CustomSettingsUtilities.getConfigDataMap('QCC_' + segment.flightTypeCode);
                    cs.Aircraft_Type_Code__c = segment.aircraftTypeCode;
                    cs.Segment_Id__c = segment.segmentId;

                    // Create an HTML table for flight segments
                    String flightSegmentsTable = '<html><table border="1" width="100%">';
                    flightSegmentsTable += '<thead><tr><th>Flight Number</th><th>Departure Date</th><th>Departure Port</th><th>Arrival Port</th></tr></thead>';
                    flightSegmentsTable += '<tbody><tr><td>' + segment.operatingCarrierAlphaCode + segment.operatingFlightNumber.replaceFirst('^0+', '') + '</td>';
                    flightSegmentsTable += '<td>' + segment.departureLocalDate + '</td>';
                    flightSegmentsTable += '<td>' + segment.departureAirportCode + '</td>';
                    flightSegmentsTable += '<td>' + segment.arrivalAirportCode + '</td></tr></tbody></table></html>';

                    cs.Flight_Segments__c = flightSegmentsTable;

                    // Process disrupts to determine delay or cancellation
                    if (segment.disrupts != null) {
                        for (QCC_PNRFlightInfoWrapper.Disrupts disrupt : segment.disrupts) {
                            if (disrupt.type != null && disrupt.type.equalsIgnoreCase('DELAY') && disrupt.details != null) {
                                cs.Flight_Delay__c = true;
                                for (QCC_PNRFlightInfoWrapper.Detail detail : disrupt.details) {
                                    if (detail.shortDescription != 'WEATHER' && detail.shortDescription != 'WEA') {
                                        cs.Delay_Reason__c = 'Operational';
                                        break;
                                    } else {
                                        cs.Delay_Reason__c = 'Weather';
                                    }
                                }
                            } else if (disrupt.type != null && disrupt.type.equalsIgnoreCase('CANCELLED')) {
                                cs.Flight_Cancellation__c = true;
                            }
                        }
                    }

                    // Retrieve passenger information and update the case
                    updatePassengerInfo(cs, segment, ffNumber, isHistory, archivalData, passengersSelectedInWebForm, matchedPassengers);

                    break; // Exit the loop once the flight is processed
                }
            }
            if (!matchedPassengers.isEmpty() && CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) {
                QCC_DisplayPAXController.createAffectedPassengerV2(cs.Id, matchedPassengers, mapPassIdToLegInfo, true);
            }
        } catch (Exception ex) {
            // Log any exceptions for debugging purposes
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QCC - Auto Case Creation', 'QCC_CaseCreatorV2',
                                    'updateCaseInfo', '', '', false, String.valueOf(cs.Id), ex);
        }
    }

    // Method to update passenger information in the case
    private static List<String> updatePassengerInfo(Case cs, QCC_PNRFlightInfoWrapper.Segments segment, String ffNumber, Boolean isHistory, String archivalData, List<String> passengersSelectedInWebForm, List<String> matchedPassengers) {
        // Retrieve passenger information from the CAP API
        QCC_PNRPassengerInfoWrapper passengerInfo = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI(
            cs.Booking_PNR__c, creationDate, BOOKING_TOKEN, archivalData
        );
        if (passengerInfo == null || passengerInfo.booking == null || passengerInfo.booking.passengers == null) {
            return matchedPassengers;
        }
        for (QCC_PNRPassengerInfoWrapper.Passengers passenger : passengerInfo.booking.passengers) {
            // QDCUSCON - 4425 -- START
            if (CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) {
                String fullName = (passenger.firstName+passenger.lastName).toUpperCase();
                if (passengersSelectedInWebForm.contains(fullName)) {
                    matchedPassengers.add(JSON.serialize(passenger));
                    mapPassIdToLegInfo.put(passenger.passengerId, null);
                }
            }
            // QDCUSCON - 4425 -- END
            // Check if the passenger matches the frequent flyer number or name
            if ((ffNumber != null && passenger.qantasFFNo != null && ffNumber.replaceFirst('^0+', '').equalsIgnoreCase(passenger.qantasFFNo.replaceFirst('^0+', ''))) ||
                (cs.Last_Name__c != null && cs.First_Name__c != null && cs.Last_Name__c.equalsIgnoreCase(passenger.lastName) && cs.First_Name__c.equalsIgnoreCase(passenger.firstName))) {
                
                // Update case with passenger details
                cs.Passenger_Id__c = passenger.passengerId;
                cs.Passenger_First_Name__c = passenger.firstName;
                cs.Passenger_Last_Name__c = passenger.lastName;
                cs.ABN_Number__c = passenger.smeId;
                cs.Qantas_Corporate_Identifier__c = passenger.corpId;

                if (!CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) || (CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) && cs.Group__c != 'Proof of Boarding or No Show' && cs.Group__c != 'Flight Cancelled by Qantas' && cs.Group__c != 'Booking Cancelled by Customer'))
                {
                    // Passenger found
                    passengerFound = true;
                    // Retrieve leg status information
                    QCC_PNRLegStatusInfoWrapper flightPassenger = retrieveLegStatusInfo(cs, passenger, segment, isHistory, archivalData);
                    // Update case with flight passenger details
                    updateFlightPassengerInfo(cs, flightPassenger);
                }
                QCC_PNRSSRInfoWrapper pnrSSR;
                if(!isHistory) {
                    pnrSSR = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI(cs.Booking_PNR__c, creationDate, passenger.passengerId, segment.segmentId, BOOKING_TOKEN, false, archivalData);
                } else {
                    pnrSSR = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI(cs.Booking_PNR__c, creationDate, passenger.passengerTattoo, segment.segmentTattoo, BOOKING_TOKEN, true, archivalData);
                }
                if(pnrSSR != null && pnrSSR.booking != null && pnrSSR.booking.ServiceRequest != null) {
                    for(QCC_PNRSSRInfoWrapper.ServiceRequest serviceReq: pnrSSR.booking.ServiceRequest) {
                        if(serviceReq.loyalty != null) {
                            for(QCC_PNRSSRInfoWrapper.Loyalty loyalty: serviceReq.loyalty) {
                                cs.Specific_Needs__c = String.isBlank(cs.Specific_Needs__c) ? loyalty.serviceKeywordCode : cs.Specific_Needs__c+';'+loyalty.serviceKeywordCode;
                            }
                        }
                        if(serviceReq.meal != null) {
                            for(QCC_PNRSSRInfoWrapper.Meal meal: serviceReq.meal) {
                                cs.Specific_Needs__c = String.isBlank(cs.Specific_Needs__c) ? meal.serviceKeywordCode : cs.Specific_Needs__c+';'+meal.serviceKeywordCode;
                            }
                        }
                        if(serviceReq.seat != null) {
                            for(QCC_PNRSSRInfoWrapper.Seat seat: serviceReq.seat) {
                                cs.Specific_Needs__c = String.isBlank(cs.Specific_Needs__c) ? seat.serviceKeywordCode : cs.Specific_Needs__c+';'+seat.serviceKeywordCode;
                            }
                        }
                        if(serviceReq.bag != null) {
                            for(QCC_PNRSSRInfoWrapper.Bag bag: serviceReq.bag) {
                                cs.Specific_Needs__c = String.isBlank(cs.Specific_Needs__c) ? bag.serviceKeywordCode : cs.Specific_Needs__c+';'+bag.serviceKeywordCode;
                            }
                        }
                        if(serviceReq.document != null) {
                            for(QCC_PNRSSRInfoWrapper.Document document: serviceReq.document) {
                                cs.Specific_Needs__c = String.isBlank(cs.Specific_Needs__c) ? document.serviceKeywordCode : cs.Specific_Needs__c+';'+document.serviceKeywordCode;
                            }
                        }
                        if(serviceReq.other != null) {
                            for(QCC_PNRSSRInfoWrapper.Other other: serviceReq.other) {
                                cs.Specific_Needs__c = String.isBlank(cs.Specific_Needs__c) ? other.serviceKeywordCode : cs.Specific_Needs__c+';'+other.serviceKeywordCode;
                            }
                        }
                    }
                }
                if(!CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) || (CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) && cs.Group__c != 'Proof of Boarding or No Show' && cs.Group__c != 'Flight Cancelled by Qantas' && cs.Group__c != 'Booking Cancelled by Customer')) {
                    break; // Exit the loop once the passenger is processed
                }
            }
        }
        // Map leg information from the passenger data
        updatePIForInsurance(cs, segment, archivalData);
        return matchedPassengers;
    }

    // Method to retrieve leg status information for a passenger
    private static QCC_PNRLegStatusInfoWrapper retrieveLegStatusInfo(
        Case cs,
        QCC_PNRPassengerInfoWrapper.Passengers passenger,
        QCC_PNRFlightInfoWrapper.Segments segment,
        Boolean isHistory,
        String archivalData
    ) {
        if (!isHistory) {
            return QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(
                cs.Booking_PNR__c, creationDate, passenger.passengerId, segment.segmentId, BOOKING_TOKEN, false, archivalData
            );
        } else {
            return QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(
                cs.Booking_PNR__c, creationDate, passenger.passengerTattoo, segment.segmentTattoo, BOOKING_TOKEN, true, archivalData
            );
        }
    }

    // Method to map leg information from the passenger data
    private static void updatePIForInsurance(Case cs, QCC_PNRFlightInfoWrapper.Segments segment, String archivalData) {
        if (CASE_TYPE_INSURANCE.equalsIgnoreCase(cs.Type) && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) 
        {
            QCC_PNRLegStatusInfoWrapper flightPassenger = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(cs.Booking_PNR__c, creationDate, '', '', BOOKING_TOKEN, false, archivalData);
            if(flightPassenger != null && flightPassenger.booking != null && flightPassenger.booking.passengerFlightStatus != null && flightPassenger.booking.passengerFlightStatus.size() > 0) 
            {
                for(QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus pfs: flightPassenger.booking.passengerFlightStatus) {
                    if(mapPassIdToLegInfo.containsKey(pfs.passengerId) && segment.segmentId == pfs.segmentId) {
                        LegInformation legInfo = new LegInformation();
                        if(String.isBlank(legInfo.cabinClass)) {
                            legInfo.cabinClass = mapCabinClass(pfs.bookedCabinClass);
                        }
                        String seatNumber;
                        if(pfs.leg != null && pfs.leg.size() > 0) {
                            // Map Flight & Flight Passenger Details to Case
                            String flightLegFlownTable = '<html><table border="1" width="100%">';
                            flightLegFlownTable = flightLegFlownTable + '<thead><tr><th>Departure Airport</th><th>Arrival Airport</th><th>Status</th></tr></thead><tbody>';
                            String boardingStatus = 'Boarded';
                            for(QCC_PNRLegStatusInfoWrapper.Leg leg: pfs.leg) {
                                flightLegFlownTable = flightLegFlownTable + '<tr><td>'+leg.originAirportCode+'</td>';
                                flightLegFlownTable = flightLegFlownTable + '<td>'+leg.destinationAirportCode+'</td>';
                                if(leg.boardingStatusCode == 'NBD') {
                                    flightLegFlownTable = flightLegFlownTable + '<td>Not Flown</td></tr>';
                                    boardingStatus = 'Not Boarded';
                                } else if(leg.boardingStatusCode == 'BDD') {
                                    flightLegFlownTable = flightLegFlownTable + '<td>Flown</td></tr>';
                                }
                                seatNumber = leg.seatNumber;
                            }
                            flightLegFlownTable = flightLegFlownTable + '</tbody></table></html>';
                            legInfo.flightLegFlownStatus = flightLegFlownTable;
                            legInfo.boardingStatus = boardingStatus;
                        }
                        mapPassIdToLegInfo.put(pfs.passengerId, legInfo);
                        if(cs.Passenger_Id__c == pfs.passengerId) {
                            cs.Cabin_Class__c = legInfo.cabinClass;
                            cs.Passenger_Segment_Id__c = pfs.passengerSegmentId;
                            cs.Flight_Leg_Flown_Statuses__c = legInfo.flightLegFlownStatus;
                            cs.Check_In_Status__c = legInfo.boardingStatus;
                            cs.Seat_Number__c = seatNumber;
                        }               
                    }
                }
            }
            for(String key: mapPassIdToLegInfo.keySet()) {
                if(mapPassIdToLegInfo.get(key) == null) {
                    flightPassengerFound = false;
                    mapPassIdToLegInfo.remove(key);
                }
            }
        }
    }

    // Method to update flight passenger information in the case
    private static void updateFlightPassengerInfo(Case cs, QCC_PNRLegStatusInfoWrapper flightPassenger) {
        if (flightPassenger == null || flightPassenger.booking == null || flightPassenger.booking.passengerFlightStatus == null) {
            return;
        }
        for (QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus pfs : flightPassenger.booking.passengerFlightStatus) {
            // Set cabin class based on booked cabin class
            if (String.isBlank(cs.Cabin_Class__c)) {
                cs.Cabin_Class__c = mapCabinClass(pfs.bookedCabinClass);
            }

            cs.Passenger_Segment_Id__c = pfs.passengerSegmentId;

            if (pfs.leg != null) {
                // Create an HTML table for flight leg statuses
                String flightLegFlownTable = '<html><table border="1" width="100%">';
                flightLegFlownTable += '<thead><tr><th>Departure Airport</th><th>Arrival Airport</th><th>Status</th></tr></thead><tbody>';

                String boardingStatus = 'Boarded';
                for (QCC_PNRLegStatusInfoWrapper.Leg leg : pfs.leg) {
                    flightLegFlownTable += '<tr><td>' + leg.originAirportCode + '</td>';
                    flightLegFlownTable += '<td>' + leg.destinationAirportCode + '</td>';

                    if (leg.boardingStatusCode == 'NBD') {
                        flightLegFlownTable += '<td>Not Flown</td></tr>';
                        boardingStatus = 'Not Boarded';
                    } else if (leg.boardingStatusCode == 'BDD') {
                        flightLegFlownTable += '<td>Flown</td></tr>';
                    }
                    cs.Seat_Number__c = leg.seatNumber;
                }
                flightLegFlownTable += '</tbody></table></html>';
                cs.Flight_Leg_Flown_Statuses__c = flightLegFlownTable;

                cs.Check_In_Status__c = boardingStatus;
                flightPassengerFound = true;
            }
        }
    }

    // Helper method to map cabin class codes to descriptions
    private static String mapCabinClass(String cabinClassCode) {
        switch on cabinClassCode {
            when 'P'{
                return 'First';
            }
            when 'J'{
                return 'Business';
            }
            when 'W'{
                return 'Premium Economy';
            }
            when 'Y'{
                return 'Economy';
            }
            when else{
                return '';
            }
        }
    }
    
    // Inner classes for handling passenger data
    public class PassengerWrapper {
        public List<Passenger> passengers;
    }

    public class Passenger {
        public String firstName;
        public String lastName;
    }

    public class LegInformation {
        public String cabinClass;
        public String boardingStatus;
        public String flightLegFlownStatus;
    }
}