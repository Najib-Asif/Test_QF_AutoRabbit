/*----------------------------------------------------------------------------------------------------------------------
    Author:        Purushotham
    Company:       Capgemini
    Description:   Fetches booking details from CAP system and then updates the case
    Inputs:
    Test Class:
 ************************************************************************************************
    History
 ************************************************************************************************
    20-Dec-2017      Purushotham               Initial Design
    26-May-2021      Venkat Amiya              QSFR-17
   -----------------------------------------------------------------------------------------------------------------------*/
public class QCC_CaseCreator implements Queueable, Database.AllowsCallouts {
	private static String BookingFound = 'No';
	private static String FlightFound = 'No';
	private static String PassengerFound;
	private static String FlightPassengerFound;
	private static String HistoricalFlight = 'No';
	private Case objCase;
	private String sessionId;

	public QCC_CaseCreator(Case caseInfo, String sessionInfo){
		this.objCase = [SELECT CaseNumber, Id, Type, Description, Status, Resolution_Method__c, Closed_By__c, Booking_PNR__c, Flight_Number__c,
		                ContactId, Group__c, Origin, Conga_Email_Template_ID__c, Conga_Template_ID__c, Contact_Email__c,
		                Actual_Departure_Date_Time__c, Actual_Arrival_Date_Time__c, Arrival_Delay_Time__c, Arrival_Delay_Time_Hours__c,
		                Arrival_Delay_Time_Mins__c, Departure_Delay_Time_Hours__c, Departure_Delay_Time_Mins__c, Departure_Delay_Time__c,
		                Ticket_Status__c,Fare_Total__c,Ticket_Number__c,Suburb__c,Street__c,State__c,Settlement_Value__c,Refund_Type__c,
		                Refund_Amount__c,Rebooked_Flight_Number__c,Rebooked_Flight_Delay_Mins__c,Rebooked_Flight_Delay_Hours__c,
		                Rebooked_Flight_Actual_Arrival_Date_Time__c,Post_Code__c,Passenger_Last_Name__c,Passenger_First_Name__c,
		                Lost_Property_Name__c,Located_Date__c,Ticket_Issue_Date__c,
		                Disrupt_Type__c,Departure_Date_Time__c,Departure_City__c,Delivery_Port__c,
		                Delivery_Date__c,Delay_Reason__c,Booking_Change_Fee__c,Cancelled_Date__c,Cancellation_Fee__c,
		                Baggage_File_Reference__c,Arrival_Date_Time__c,Arrival_City__c, Country__c, Flight_Cancellation__c, Sector__c,QCC_enableAssignmentRules__c, TECH_SelectedPassengers__c, First_Name__c, Last_Name__c
		                FROM Case WHERE Id = :caseInfo.Id];
		this.sessionId = sessionInfo;
		system.debug('sessionId#########'+sessionId);
	}

	public void execute(QueueableContext context) {
		try {
			System.debug('Reached QCC_CaseCreator');
			String insuranceCase = CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type');

			Case cs = objCase;
			Contact capCon = new Contact();

			Map<String, Airport_Code__c> airportCodesMap = new Map<String, Airport_Code__c>();


			List<Airport_Code__c> airportCodes = [SELECT Name, Freight_Station_Name__c, Freight_Airport_Country_Name__c FROM Airport_Code__c];

			for(Airport_Code__c codes: airportCodes) {
				airportCodesMap.put(codes.Name, codes);
			}

			if(cs.Origin == CustomSettingsUtilities.getConfigDataMap('QCC_Red App') || cs.Origin == CustomSettingsUtilities.getConfigDataMap('QCC Qantas')) {
				String caseType = cs.Type;
				String caseDesc = cs.Description;
				String fcr = 'No';

				if(cs.ContactId != null) {
					if(String.isNotBlank(caseType)) {
						if(caseType == 'On the Spot Recovery') {
							cs.Status = String.isBlank(cs.Status) ? CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed') : cs.Status;
						}
					}
					if(cs.Status == CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')) {
						cs.Resolution_Method__c = String.isBlank(cs.Resolution_Method__c) ? 'Case auto closed' : cs.Resolution_Method__c;
						cs.Closed_By__c = UserInfo.getUserId();
					}

					capCon = [SELECT Id, CAP_ID__c, Frequent_Flyer_Number__c FROM Contact WHERE Id = :cs.ContactId];

					// For FF
					//CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
					if(capCon.Frequent_Flyer_Number__c != null && cs.Booking_PNR__c != null && cs.Flight_Number__c != null) {

						///////////////////////////   Booking Summary ///////////////////////
						//Jira: CRM-6052
						String tokenTicketStatus = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken'); // token for tickeStatus api
                        
                        Datetime today = system.today();
                        Datetime timestamp = today.addDays(365);
                        Datetime timestampMinusYear = today.addDays(-365);
                        Long timestampStr = timestamp.getTime();
                        Long timestampMinusYearStr = timestampMinusYear.getTime();
                        
                        QCC_CustomerFlightsWrapper.CustomerFlightsWrapper bookingSummary = QCC_InvokeCAPAPI.invokeProductFlightsCAPAPI(capCon.Frequent_Flyer_Number__c, tokenTicketStatus, timestampStr, timestampMinusYearStr, 1, true);                      
						System.debug('Booking Summary = '+bookingSummary);
						if(bookingSummary != null && bookingSummary.flights.size() > 0) {
                            //Jira: CRM-6052
                            for(QCC_CustomerFlightsWrapper.FlightsDetailWrapper booking: bookingSummary.flights) {
								if(booking.reloc == cs.Booking_PNR__c) {
									BookingFound = 'Yes';
									cs.PNR_Verified__c = true;
									String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
									String[] DateStr = String.isNotBlank(booking.creationDate) ? (booking.creationDate).replace('-', ' ').split(' ') : null;
									String creationDate = DateStr[2]+'/'+DateStr[1]+'/'+DateStr[0];
									System.debug('creationDate = '+creationDate);
									cs.TECH_bookingCreationDate__c = creationDate;
									///////////////////Jira: CRM-6052 ///////////////////
                                    cs.TECH_bookingArchivalData__c = 'false';
									/////////////////////   Booking Retrieve Flights ///////////////////
									//Jira: CRM-6052
									QCC_PNRFlightInfoWrapper flightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(cs.Booking_PNR__c, creationDate, token, false, 'false');
									System.debug('flightInfo = '+flightInfo);
									if(flightInfo != null && flightInfo.booking != null && flightInfo.booking.segments.size() > 0) {
                                        //Jira: CRM-6052
										//CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
										cs = updateCaseInfo(flightInfo.booking.segments, cs, token, creationDate, airportCodesMap, capCon.Frequent_Flyer_Number__c, false, 'false');
									}
									///////////////// Check Flight History /////////////////
									if(FlightFound == 'No') {
										if(cs.Group__c == 'Booking Cancelled by Customer' || cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupFCQ') ||
										   cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupDF') || cs.Group__c == 'Flight Disruptions') {
											/////////// Need to call API ////////////
											QCC_PNRFlightInfoWrapper flightInfoHist = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(cs.Booking_PNR__c, creationDate, token, true, 'true');
											if(flightInfoHist != null && flightInfoHist.booking != null && flightInfoHist.booking.segments.size() > 0) {
												//CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
												cs = updateCaseInfo(flightInfoHist.booking.segments, cs, token, creationDate, airportCodesMap, capCon.Frequent_Flyer_Number__c, true, 'true');
											}

										}
									}
									break;
								}
							}
						}
					}

					// For Non-FF
					else if(cs.Booking_PNR__c != null && cs.Flight_Number__c != null && cs.Last_Name__c != null) {
						String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
						/////////////////////   Booking Retrieve Flights ///////////////////
						QCC_PNRFlightInfoWrapper flightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(cs.Booking_PNR__c, cs.Last_Name__c, token, 'false');
						System.debug('flightInfo = '+flightInfo);
						if(flightInfo != null && flightInfo.booking != null && flightInfo.booking.reloc == cs.Booking_PNR__c) {
							BookingFound = 'Yes';
							cs.PNR_Verified__c = true;
							String creationDate = flightInfo.booking.creationDate;
							System.debug('creationDate = '+creationDate);
							cs.TECH_bookingCreationDate__c = creationDate;
							cs.TECH_bookingArchivalData__c = 'false';
							if(flightInfo.booking.segments.size() > 0) {
								//CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
								cs = updateCaseInfo(flightInfo.booking.segments, cs, token, creationDate, airportCodesMap, capCon.Frequent_Flyer_Number__c, false, 'false');
							}
						}
					}

					Integer minutes = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('Recent Case Duration')) * -1;
					Integer currentHour = System.now().hour();
					Datetime startTime = Datetime.newInstance(System.now().year(), System.now().month(), System.now().day(), currentHour, 0, 0);
					System.debug('startTime ----'+startTime);
					//List<Case> recentCase = [SELECT Id FROM Case WHERE Id != :cs.Id AND ContactId = :capCon.Id and createddate > :System.now().addMinutes(minutes) Order By createddate desc limit 1];
					List<Case> recentCases;
					if(String.isNotBlank(capCon.Frequent_Flyer_Number__c)) {
						recentCases = [SELECT Id FROM Case WHERE Id != :cs.Id AND ContactId = :capCon.Id and createddate > :startTime and createddate < :System.now() Order By createddate desc];
					} else {
						//recentCases = [SELECT Id FROM Case WHERE Id != :cs.Id AND First_Name__c = :cs.First_Name__c AND Last_Name__c = :cs.Last_Name__c and createddate > :startTime and createddate < :System.now() Order By createddate desc];
					}

					if(recentCases != null && recentCases.size() > 0) {
						List<Case_Relationships__c> relationShips = new List<Case_Relationships__c>();
						for(Case c: recentCases) {
							Case_Relationships__c caseRelationObj = new Case_Relationships__c();
							caseRelationObj.Case_1__c = c.Id;
							caseRelationObj.Case_2__c = cs.Id;
							relationShips.add(caseRelationObj);
						}

						if(relationShips != null && relationShips.size() > 0) {
							insert relationShips;
						}

						//cs.Linked_Case__c = recentCase[0].Id;
					}

					PassengerFound = String.isBlank(PassengerFound) ? 'No' : PassengerFound;
					FlightPassengerFound = String.isBlank(FlightPassengerFound) ? 'No' : FlightPassengerFound;

					if(cs.Status != CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed') && (BookingFound == 'No' || FlightFound == 'No' || PassengerFound == 'No' || (FlightPassengerFound == 'No' && HistoricalFlight != 'Yes'))) {
						String comments = 'All of the required bookings information has not been successfully added to the case:' +
						                  '\nBooking (PNR) details found?: ' + BookingFound +
						                  '\nFlight details found?: ' + FlightFound +
						                  '\nPassenger details found?: ' + PassengerFound +
						                  '\nFlight Passenger details found?: ' + FlightPassengerFound +
						                  '\nPlease check the booking details and add the required booking to the case';

						if(!Test.isRunningTest()) {
							ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, comments);
						}

						if(cs.Type == insuranceCase) {
							cs.FCR__c = false;
							cs.QCC_enableAssignmentRules__c = false;
							cs.Assign_using_active_assignment_rules__c = true;
							cs.Is_Response_Requested__c = 'Yes';
						}
						//update cs;
					}
					else {

						if(cs.Type == insuranceCase) {
							/////////// Call to Insurance Letters Business Rules and has to pass Integration = "Yes"
							fcr = QCC_EmailButtonController.getCaseValues(null, cs.Type, true, cs);

							if(fcr.equalsIgnoreCase('Yes')) {
								cs.FCR__c = true;
								cs.Auto_Close_on_Email_Sent__c = true;

								////// NEWLY ADDED -- START ///////
								String emailTemplateId;
								String templateId;
								List<QCC_Email_Template_Setting__mdt> emailTemplateDetails = [SELECT Id, EmailTemplateName__c, TemplateGroup__c, AutoCloseCase__c FROM QCC_Email_Template_Setting__mdt WHERE Type__c =: cs.Type AND Group__c =: cs.Group__c AND Category__c =: cs.Refund_Type__c LIMIT 1];

								if(emailTemplateDetails.size() > 0) {
									emailTemplateId = QCC_GenericUtils.fetchSalesforceEmailTemplate(emailTemplateDetails[0].EmailTemplateName__c);

									String emailTemplateName = '%' + emailTemplateDetails[0].EmailTemplateName__c + '%';
									List<APXTConga4__Conga_Template__c> congaTemplateList = [SELECT Id, APXTConga4__Name__c, Email_Template_Name__c, APXTConga4__Template_Group__c, APXTConga4__Template_Type__c FROM APXTConga4__Conga_Template__c WHERE Email_Template_Name__c LIKE: emailTemplateName AND APXTConga4__Template_Group__c =: emailTemplateDetails[0].TemplateGroup__c];
									if(congaTemplateList != null && congaTemplateList.size() > 0) {
										templateId = congaTemplateList[0].Id;
									}
								}
								//QSFR-17 Changes Start
								if(cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupDF')|| cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupPBNS')) {
									cs.Conga_Template_ID__c = '';
								}
								else{
									cs.Conga_Template_ID__c = templateId;
								}
								//QSFR-17 Changes End
								cs.Conga_Email_Template_ID__c = emailTemplateId;//Could be any template, not necessarily Conga Template.
								cs.Conga_Template_ID__c = templateId;
								//cs.Conga_Workflow_Trigger__c = true;
								//cs.Close_Case__c = emailTemplateDetails[0].AutoCloseCase__c;*/
								////// NEWLY ADDED -- END ///////
							} else if(fcr.equalsIgnoreCase('Ineligible')) {
								cs.FCR__c = true;
								cs.Conga_Template_ID__c = '';
								cs.Auto_Close_on_Email_Sent__c = true;

								List<QCC_Email_Template_Setting__mdt> emailTemplateDetails = [SELECT Id, EmailTemplateName__c, TemplateGroup__c, AutoCloseCase__c FROM QCC_Email_Template_Setting__mdt WHERE Type__c =: 'Ineligible Insurance Letter' AND Group__c =: cs.Group__c LIMIT 1];
								if(emailTemplateDetails != null && emailTemplateDetails.size() > 0) {
									cs.Conga_Email_Template_ID__c = QCC_GenericUtils.fetchSalesforceEmailTemplate(emailTemplateDetails[0].EmailTemplateName__c);
								}
								/*APXTConga4__Conga_Email_Template__c congaEmailTemplate = [SELECT Id FROM APXTConga4__Conga_Email_Template__c WHERE Type__c = 'Ineligible Insurance Letter' AND Group__c = :cs.Group__c];
								   if(congaEmailTemplate != null) {
								    cs.Conga_Email_Template_ID__c = congaEmailTemplate.Id;
								   }*/
							} else {
								cs.FCR__c = false;
								cs.Is_Response_Requested__c = 'Yes';
								if(cs.Status != CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')) {
									cs.QCC_enableAssignmentRules__c = false;
									cs.Assign_using_active_assignment_rules__c = true;
								}
							}
						}
						//update cs;
					}
				}
				else {
					if(cs.Type == insuranceCase) {
						cs.FCR__c = false;
						cs.Is_Response_Requested__c = 'Yes';
						if(cs.Status != CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')) {
							cs.QCC_enableAssignmentRules__c = false;
							cs.Assign_using_active_assignment_rules__c = true;
						}
					}
					//update cs;
				}

				update cs;
				system.debug('sessionId########'+sessionId);
				if(fcr.equalsIgnoreCase('Yes') || fcr.equalsIgnoreCase('Ineligible')) {
					ID jobID = System.enqueueJob(new CongaMailScheduler(sessionId, cs));
				}
			}

		} catch (Exception ex) {
			System.debug('Exception## '+ex.getMessage());
			CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Auto Case Creation', 'QCC_CaseCreator',
			                         'autoCaseProcess', String.valueOf(''), String.valueOf(''),false,'', ex);
		}
	}

	public static Case updateCaseInfo(List<QCC_PNRFlightInfoWrapper.Segments> segments, Case cs, String token, String creationDate, Map<String, Airport_Code__c> airportCodesMap, String ffNumber, Boolean isHistory, String archivalData) {
		try {
			// QDCUSCON - 4425, 4522 -- START
			String insuranceCase = CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type');
			List<String> passengersSelectedInWebForm = new List<String>();
			List<String> matchedPassengers = new List<String>();
			Map<String, LegInformation> mapPassIdToLegInfo = new Map<String, LegInformation>();
			if(cs.Type == insuranceCase && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) {
				System.debug('cs.TECH_SelectedPassengers__c = '+cs.TECH_SelectedPassengers__c);
				PassengerWrapper pw = cs.TECH_SelectedPassengers__c != null ? (PassengerWrapper)JSON.deserialize(cs.TECH_SelectedPassengers__c, PassengerWrapper.class) : null;
				if(pw != null) {
					for(Passenger p: pw.passengers) {
						System.debug('Full Name = '+p.firstName+' '+p.lastName);
						String fullName = (p.firstName+p.lastName).toUpperCase();
						passengersSelectedInWebForm.add(fullName);
					}
				}
			}
			// QDCUSCON - 4425 -- END

			for(QCC_PNRFlightInfoWrapper.Segments segment: segments) {
				if(cs.Flight_Number__c == segment.operatingFlightNumber) {
					FlightFound = 'Yes';
					/////// Map Flight Details to Case ///////
					cs.TECH_BookingSegmentId__c = segment.segmentId;
					cs.TECH_BookingSegmentTattoo__c = segment.segmentTattoo;
					if(String.isBlank(cs.Airline__c)) {
						String airlines = String.isNotBlank(segment.operatingCarrierAlphaCode) ? CustomSettingsUtilities.getAirlineCarrierCodes(segment.operatingCarrierAlphaCode) : '';
						cs.Airline__c = airlines != null ? airlines : 'Non partner Airline';
					}

					cs.Flight_Number_With_Code__c = segment.operatingCarrierAlphaCode + segment.operatingFlightNumber.replaceFirst('^0+','');

					cs.Departure_Airport_Code__c = String.isBlank(cs.Departure_Airport_Code__c) ? segment.departureAirportCode : cs.Departure_Airport_Code__c;
					cs.Arrival_Airport_Code__c = String.isBlank(cs.Arrival_Airport_Code__c) ? segment.arrivalAirportCode : cs.Arrival_Airport_Code__c;
					if(airportCodesMap != null) {
						if(airportCodesMap.containsKey(cs.Departure_Airport_Code__c)) {
							cs.Departure_Airport__c = airportCodesMap.get(cs.Departure_Airport_Code__c).Freight_Station_Name__c;
							cs.Departure_City__c = airportCodesMap.get(cs.Departure_Airport_Code__c).Freight_Station_Name__c;
							cs.Departure_Country__c = airportCodesMap.get(cs.Departure_Airport_Code__c).Freight_Airport_Country_Name__c;
						}

						if(airportCodesMap.containsKey(cs.Arrival_Airport_Code__c)) {
							cs.Arrival_Airport__c = airportCodesMap.get(cs.Arrival_Airport_Code__c).Freight_Station_Name__c;
							cs.Arrival_City__c = airportCodesMap.get(cs.Arrival_Airport_Code__c).Freight_Station_Name__c;
							cs.Arrival_Country__c = airportCodesMap.get(cs.Arrival_Airport_Code__c).Freight_Airport_Country_Name__c;
						}
					}

					///if(cs.Departure_Date_Time__c == null) {
					if(String.isNotBlank(segment.departureLocalDate) && String.isNotBlank(segment.departureLocalTime)) {
						cs.Departure_Date_Time__c = segment.departureLocalDate+' '+segment.departureLocalTime;
					}
					//}

					//if(cs.Departure_UTC_Date_Time__c == null) {
					cs.Departure_UTC_Date_Time__c = QCC_GenericUtils.convertStringtoDateTime(segment.departureUTCDate,segment.departureUTCTime);
					//}

					//if(cs.Actual_Departure_Date_Time__c == null) {
					if(String.isNotBlank(segment.actualDepartureLocalDate) && String.isNotBlank(segment.actualDepartureLocalTime)) {
						cs.Actual_Departure_Date_Time__c = segment.actualDepartureLocalDate+' '+segment.actualDepartureLocalTime;
					}

					//}

					//if(cs.Arrival_Date_Time__c == null) {
					if(String.isNotBlank(segment.arrivalLocalDate) && String.isNotBlank(segment.arrivalLocalTime)) {
						cs.Arrival_Date_Time__c = segment.arrivalLocalDate+ ' ' +segment.arrivalLocalTime;
					}
					//}

					//if(cs.Arrival_UTC_Date_Time__c == null) {
					cs.Arrival_UTC_Date_Time__c = QCC_GenericUtils.convertStringtoDateTime(segment.arrivalUTCDate,segment.arrivalUTCTime);
					//}

					//if(cs.Actual_Arrival_Date_Time__c == null) {
					if(String.isNotBlank(segment.actualArrivalLocalDate) && String.isNotBlank(segment.actualArrivalLocalTime)) {
						cs.Actual_Arrival_Date_Time__c = segment.actualArrivalLocalDate+' '+segment.actualArrivalLocalTime;
					}
					//}

					if(String.isNotBlank(segment.departureAirportCode) && String.isNotBlank(segment.arrivalAirportCode) && String.isBlank(cs.Sector__c)) {
						cs.Sector__c = segment.departureAirportCode + ' ' + segment.arrivalAirportCode;
					}

					cs.Flight_Type_Code__c = CustomSettingsUtilities.getConfigDataMap('QCC_'+segment.flightTypeCode);
					cs.Aircraft_Type_Code__c = segment.aircraftTypeCode;
					cs.Segment_Id__c = segment.segmentId;

					String flightSegmentsTable = '<html><table border="1" width="100%">';
					flightSegmentsTable = flightSegmentsTable + '<thead><tr><th>Flight Number</th><th>Departure Date</th><th>Departure Port</th><th>Arrival Port</th></tr></thead>';
					flightSegmentsTable = flightSegmentsTable + '<tbody><tr><td>'+segment.operatingCarrierAlphaCode+segment.operatingFlightNumber.replaceFirst('^0+','')+'</td>';
					flightSegmentsTable = flightSegmentsTable + '<td>'+segment.departureLocalDate+'</td>';
					flightSegmentsTable = flightSegmentsTable + '<td>'+segment.departureAirportCode+'</td>';
					flightSegmentsTable = flightSegmentsTable + '<td>'+segment.arrivalAirportCode+'</td></tr></tbody></table></html>';

					cs.Flight_Segments__c = flightSegmentsTable;

					if(segment.disrupts != null && segment.disrupts.size() > 0) {
						for(QCC_PNRFlightInfoWrapper.Disrupts disrupt: segment.disrupts) {
							if(disrupt.type.equalsIgnoreCase('DELAY') && disrupt.details.size() > 0) {
								cs.Flight_Delay__c = true;
								for(QCC_PNRFlightInfoWrapper.Detail detail: disrupt.details) {
									if(detail.shortDescription != 'WEATHER' && detail.shortDescription != 'WEA') {
										cs.Delay_Reason__c = 'Operational';
										break;
									} else {
										cs.Delay_Reason__c = 'Weather';
									}
								}
							}
							else if(disrupt.type.equalsIgnoreCase('CANCELLED')) {
								cs.Flight_Cancellation__c = true;
							}
						}
					}

					//////////////////// Booking Retrieve Passengers ////////////////
					QCC_PNRPassengerInfoWrapper passengerInfo = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI(cs.Booking_PNR__c, creationDate, token, archivalData);
					System.debug('passengerInfo = '+passengerInfo);
					if(passengerInfo != null && passengerInfo.booking != null && passengerInfo.booking.passengers != null && passengerInfo.booking.passengers.size() > 0) {
						for(QCC_PNRPassengerInfoWrapper.Passengers passenger: passengerInfo.booking.passengers) {
							// QDCUSCON - 4425 -- START
							if(cs.Type == insuranceCase && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) {
								String fullName = (passenger.firstName+passenger.lastName).toUpperCase();
								if(passengersSelectedInWebForm.size() > 0 && passengersSelectedInWebForm.contains(fullName)) {
									PassengerFound = PassengerFound != 'No' ? 'Yes' : PassengerFound;
									matchedPassengers.add(JSON.serialize(passenger));
									mapPassIdToLegInfo.put(passenger.passengerId, null);
								}
							}
							// QDCUSCON - 4425 -- END

							// Added First Name and Last Name check to consider Non-FF scenario
							//CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
							if(ffNumber.replaceFirst('^0+', '').equalsIgnoreCase(passenger.qantasFFNo.replaceFirst('^0+', '')) || (cs.Last_Name__c.equalsIgnoreCase(passenger.lastName) && cs.First_Name__c.equalsIgnoreCase(passenger.firstName))) {
								//////  Map Passenger Details to Case //////
								cs.Passenger_Id__c = passenger.passengerId;
								cs.Passenger_First_Name__c = passenger.firstName;
								cs.Passenger_Last_Name__c = passenger.lastName;
								cs.ABN_Number__c = passenger.smeId;
								cs.Qantas_Corporate_Identifier__c = passenger.corpId;

								////////////// Booking Flight Passenger Details //////
								if(cs.Type != insuranceCase || (cs.Type == insuranceCase && cs.Group__c != 'Proof of Boarding or No Show' && cs.Group__c != 'Flight Cancelled by Qantas' && cs.Group__c != 'Booking Cancelled by Customer')) {
									PassengerFound = 'Yes';
									QCC_PNRLegStatusInfoWrapper flightPassenger;
									if(!isHistory) {
										flightPassenger = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(cs.Booking_PNR__c, creationDate, passenger.passengerId, segment.segmentId, token, false, archivalData);
									}
									else {
										flightPassenger = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(cs.Booking_PNR__c, creationDate, passenger.passengerTattoo, segment.segmentTattoo, token, true, archivalData);
									}

									System.debug('flightPassenger = '+flightPassenger);
									if(flightPassenger != null && flightPassenger.booking != null && flightPassenger.booking.passengerFlightStatus != null && flightPassenger.booking.passengerFlightStatus.size() > 0) {
										for(QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus pfs: flightPassenger.booking.passengerFlightStatus) {
											if(String.isBlank(cs.Cabin_Class__c)) {
												if(pfs.bookedCabinClass == 'P') {
													cs.Cabin_Class__c = 'First';
												} else if(pfs.bookedCabinClass == 'J') {
													cs.Cabin_Class__c = 'Business';
												} else if(pfs.bookedCabinClass == 'W') {
													cs.Cabin_Class__c = 'Premium Economy';
												} else if(pfs.bookedCabinClass == 'Y') {
													cs.Cabin_Class__c = 'Economy';
												}
											}

											cs.Passenger_Segment_Id__c = pfs.passengerSegmentId;

											if(pfs.leg != null && pfs.leg.size() > 0) {
												//////// Map Flight & Flight Passenger Details to Case /////
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
													cs.Seat_Number__c = leg.seatNumber;
												}
												flightLegFlownTable = flightLegFlownTable + '</tbody></table></html>';
												cs.Flight_Leg_Flown_Statuses__c = flightLegFlownTable;

												cs.Check_In_Status__c = boardingStatus;
												FlightPassengerFound = 'Yes';
											}
										}
									}
								}

								QCC_PNRSSRInfoWrapper pnrSSR;
								if(!isHistory) {
									pnrSSR = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI(cs.Booking_PNR__c, creationDate, passenger.passengerId, segment.segmentId, token, false, archivalData);
								}
								else {
									pnrSSR = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI(cs.Booking_PNR__c, creationDate, passenger.passengerTattoo, segment.segmentTattoo, token, true, archivalData);
								}
								System.debug('pnrSSR = '+pnrSSR);
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
								if(cs.Type != insuranceCase || (cs.Type == insuranceCase && cs.Group__c != 'Proof of Boarding or No Show' && cs.Group__c != 'Flight Cancelled by Qantas' && cs.Group__c != 'Booking Cancelled by Customer')) {
									break;
								}
							}
						}

						System.debug('mapPassIdToLegInfo --> '+mapPassIdToLegInfo );
						if(cs.Type == insuranceCase && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) {
							QCC_PNRLegStatusInfoWrapper flightPassenger;
							//if(!isHistory) {
							flightPassenger = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(cs.Booking_PNR__c, creationDate, '', '', token, false, archivalData);
							//}
							//else {
							//    flightPassenger = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(cs.Booking_PNR__c, creationDate, passenger.passengerTattoo, segment.segmentTattoo, token, true, archivalData);
							//}

							System.debug('flightPassenger = '+flightPassenger);
							System.debug('SegmentId = '+segment.segmentId);
							if(flightPassenger != null && flightPassenger.booking != null && flightPassenger.booking.passengerFlightStatus != null && flightPassenger.booking.passengerFlightStatus.size() > 0) {
								System.debug('pfs -- '+flightPassenger.booking.passengerFlightStatus);
								for(QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus pfs: flightPassenger.booking.passengerFlightStatus) {
									if(mapPassIdToLegInfo.containsKey(pfs.passengerId) && segment.segmentId == pfs.segmentId) {
										LegInformation legInfo = new LegInformation();
										if(String.isBlank(legInfo.cabinClass)) {
											if(pfs.bookedCabinClass == 'P') {
												legInfo.cabinClass = 'First';
											} else if(pfs.bookedCabinClass == 'J') {
												legInfo.cabinClass = 'Business';
											} else if(pfs.bookedCabinClass == 'W') {
												legInfo.cabinClass = 'Premium Economy';
											} else if(pfs.bookedCabinClass == 'Y') {
												legInfo.cabinClass = 'Economy';
											}
										}

										String seatNumber;
										if(pfs.leg != null && pfs.leg.size() > 0) {
											//////// Map Flight & Flight Passenger Details to Case /////
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

											FlightPassengerFound = FlightPassengerFound != 'No' ? 'Yes' : FlightPassengerFound;
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
									FlightPassengerFound = 'No';
									mapPassIdToLegInfo.remove(key);
								}
							}
						}
					}

					break;
				}
			}
			if(matchedPassengers.size() > 0 && cs.Type == insuranceCase && (cs.Group__c == 'Proof of Boarding or No Show' || cs.Group__c == 'Flight Cancelled by Qantas' || cs.Group__c == 'Booking Cancelled by Customer')) {
				System.debug('matchedPassengers = '+matchedPassengers);
				System.debug('LegInformation = '+mapPassIdToLegInfo);
				QCC_DisplayPAXController.createAffectedPassenger(cs.Id, matchedPassengers, mapPassIdToLegInfo, true);
			}
		} catch (Exception ex) {
			System.debug('Exception## '+ex.getMessage());
			CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Auto Case Creation', 'QCC_CaseCreator',
			                         'updateCaseInfo', String.valueOf(''), String.valueOf(''),false,'', ex);
		}

		return cs;
	}

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