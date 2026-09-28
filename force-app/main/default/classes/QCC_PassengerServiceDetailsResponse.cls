public with sharing class QCC_PassengerServiceDetailsResponse {
    public class SeatService {
        public Integer otherTattoo;
        public String keyword;
        public String keywordSource;
        public String carrierCode;
        public String status;
        public String paxSegRelType;
        public String chargeableInd;
        public String rfic;
        public String rfisc;
        public String specialAsisstancePaxTypeCode;
        public String seatNumber;
        public String freeText;
    }

    public class BaggageService {
        public Integer otherTattoo;
        public String keyword;
        public String keywordSource;
        public String carrierCode;
        public String status;
        public String paxSegRelType;
        public String chargeableInd;
        public String rfic;
        public String rfisc;
        public String bagQty;
        public String bagWgt;
        public String bagWgtUOMCode;
        public String freeText;
    }

    public class Flight {
        public String carrier;
        public String flightNo;
        public String departureDate;
        public String departurePort;
        public String arrivalPort;
        public String suffix;
    }

    public class Documents {
        public Integer otherTattoo;
        public String keyword;
        public String keywordSource;
        public String carrierCode;
        public String status;
        public String paxSegRelType;
        public String docNumber;
        public String docTypeCode;
        public String firstName;
        public String midName;
        public String lastName;
        public String gender;
        public String birthDate;
        public String issueDate;
        public String expiryDate;
        public String issuePlaceText;
        public String nationality;
        public String freeText;
    }

    public class Passenger {
        public String passengerId;
        public String bookingId;
        public String passengerSegmentId;
        public List<MealService> mealService;
        public List<BaggageService> baggageService;
        public List<SeatService> seatService;
        public List<Documents> documents;
        public List<OtherService> otherService;
    }

    public class MealService {
        public Integer otherTattoo;
        public String keyword;
        public String keywordSource;
        public String carrierCode;
        public String status;
        public String paxSegRelType;
        public String chargeableInd;
        public String rfic;
        public String rfisc;
        public String freeText;
    }
    
    public class OtherService {
        public Integer otherTattoo;
        public String keyword;
        public String keywordSource;
        public String carrierCode;
        public String status;
        public String paxSegRelType;
        public String chargeableInd;
        public String rfic;
        public String rfisc;
        public String freeText;
    }

    public Flight flight;
    public String nextPageNo{get;set;}
    public List<Passenger> passenger;
    public String errorMessage{get;set;}
    
    public static QCC_PassengerServiceDetailsResponse parse(String json) {
        return (QCC_PassengerServiceDetailsResponse) System.JSON.deserialize(json, QCC_PassengerServiceDetailsResponse.class);
    }
}