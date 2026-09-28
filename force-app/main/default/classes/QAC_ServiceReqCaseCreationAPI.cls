/*****************************************************************************************************
 Created By : Ajay Bharathan | TCS | Cloud Developer 
ClassName   : QAC_ServiceReqCaseCreationAPI
TestClass   : QAC_ServiceReqCaseCreationAPI_Test, QAC_ServiceReqCaseCreationProcess_Test, QAC_ServiceReqCaseRetrieval_Test
History
************************************************************************************************
13-Feb-2025      Gandla Mallikarjuna               CRM-9196 Included EMD Details for Seats And Baggage Service Request

******************************************************************************************************/

public class QAC_ServiceReqCaseCreationAPI {

    public class AgencyIdentification {
        public String agencyReference;
        public String agentName;
        public String agentPhone;
        public String agentEmail;
        public String agentPingId;                       //CIAM
    }

    public class Comments {
        public String commentDescription;
        public String creationTimestamp;
    }

    public class Flights {
        public String flightNumber;
        public String cabinClass;
        public String newCabinClass;
        public String couponNumber;
        public String flightDate;
        public String departurePort;
        public String arrivalPort;
        public String arrivalTime;
        public String departureTime;
        public String fareBasis;
    }

    public class Passengers {
        public String salutation;
        public String firstName;
        public String surname;
        public String passengerType;
        public String passengerSequence;
        public String passengerTattoo;
        public String frequentFlyerNumber;
        public String flightNumber;
        public String oldTicketNumber;
        public String ticketNumber;
        public String dateOfBirth;
        public String newSalutation;
        public String newFirstName;
        public String newSurname;
    }

    public class BookingDetails {
        public String bookingReference;
        public String oldBookingReference;
        public String surname;
        public String ticketNumber;
        public String emdNumber;
        public String bookingAgencyReference;
        public String pseudoCityCode;
        public String gds;
        public String pointOfSale;
        public String abn;
        public String qantasCorporateIdentifier;
        public String numberOfPassengers;
        public String travelType;
        public String nextTravelDate;
        public String waiverDate;
        public String gdsJobReference;
        public String ticketingTimeLimit;
        public String highestFrequentFlyerTier;
        public String frequentFlyerReference;
        public String affectedCount;
        public String fareBasis;
        public List<EMDDetails> emdDetails;  //Jira: CRM-9196
        
        public BookingDetails(Case theCase, List<EMD_Details__c> myEMDDetailsList){
            bookingReference = theCase.PNR_number__c;
            oldBookingReference = theCase.Old_PNR_Number__c;
            surname = theCase.Passenger_Name__c;
            ticketNumber = theCase.Ticket_Number__c;
            emdNumber = theCase.EMD_Number__c;
            bookingAgencyReference = theCase.IATA__c;
            pseudoCityCode = theCase.PCC_DI__c;
            gds = theCase.GDS_DI__c;
            pointOfSale = theCase.Point_Of_Sale__c;
            abn = theCase.ABN_Tax_Reference__c;
            qantasCorporateIdentifier = theCase.Qantas_Corporate_Identifier__c;
            numberOfPassengers = String.valueOf(theCase.Number_of_Passengers__c);
            travelType = theCase.Travel_Type__c;
            nextTravelDate = String.valueOf(theCase.First_Flight_Date__c);
            waiverDate = String.valueOf(theCase.Waiver_Date__c);
            gdsJobReference = theCase.GDS_Job_Reference__c;
            ticketingTimeLimit = String.valueOf(theCase.Ticketing_Time_Limit__c);
            highestFrequentFlyerTier = theCase.Customer_Tier__c;
            frequentFlyerReference = theCase.Frequent_Flyer_Number__c;
            fareBasis = theCase.PNR_number__c;
            affectedCount = theCase.Fare_basis_value__c;
            //Jira: CRM-9209
            if (myEMDDetailsList != null && !myEMDDetailsList.isEmpty()) {
                emdDetails = new List<EMDDetails>();
                for (EMD_Details__c eachEMDDetail : myEMDDetailsList) {
                    EMDDetails emdDetail = new EMDDetails();
                    emdDetail.emdNum = eachEMDDetail.EMD_Number__c;
                    emdDetail.emdType = eachEMDDetail.EMD_Type__c;
                    emdDetail.emdId = eachEMDDetail.Id;
                    emdDetails.add(emdDetail);
                }
            }
            
        }
    }

    //Jira: CRM-9196
    public class EMDDetails {
        public String emdNum;
        public String emdType;
        public String emdId;	
    }

    public class FareDetails {
        public String fareType;
        public String privateFareCode;
        public String regionCode;
        public String fareBasis;
        public String fareWithTax;

        public FareDetails(Case theCase){
            fareType = theCase.Fare_Type__c;
            privateFareCode = theCase.Private_Fare_Basis__c;
            regionCode = theCase.Region_Code__c;
            fareBasis = theCase.PNR_number__c;
            fareWithTax = theCase.Fare_Total__c;
        }
    }

    public ServiceRequest serviceRequest;

    public class ServiceRequest {
        public String correlationId;
        public String requestTimeStamp;
        public String parentRequest;
        public String requestCountryCode;
        public String requestLanguage;
        public String requestOrigin;
        public String requestType;
        public String requestSubType1;
        public String requestSubType2;
        public String requestStatus;
        public String remarkCategory;
        public String subject;
        public String description;
        public String totalAttachments;
        public String requestReason;
        public String requestReasonSubType;
        public String otherReason;
        public String authorityStatus;
        public String additionalRequirements;
        public String costOfSale;
        public String isoCurrency;
        public AgencyIdentification agencyIdentification;
        public BookingDetails bookingDetails;
        public FareDetails fareDetails;
        public List<Flights> flights;
        public List<Passengers> passengers;
        public List<Comments> comments;
        public List<AgencyClassification> agencyClassifications;

    }

    public class AgencyClassification {
        public String type;
        public String subType;
    }

    public static QAC_ServiceReqCaseCreationAPI parse(String json) {
        return (QAC_ServiceReqCaseCreationAPI) System.JSON.deserialize(json, QAC_ServiceReqCaseCreationAPI.class);
    }
}