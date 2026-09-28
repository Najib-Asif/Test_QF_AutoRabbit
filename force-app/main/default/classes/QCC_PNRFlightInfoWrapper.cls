public class QCC_PNRFlightInfoWrapper {
    
    
    @AuraEnabled public Booking booking;

    public class Booking {
        @AuraEnabled public String reloc;
        @AuraEnabled public String travelPlanId;
        @AuraEnabled public String bookingId;
        @AuraEnabled public String creationDate;
        @AuraEnabled public String lastUpdatedTimeStamp;
        @AuraEnabled public List<Segments> segments;
    }

    public class Segments {
        @AuraEnabled public String segmentId;
        @AuraEnabled public String segmentTattoo;
        @AuraEnabled public String marketingCarrierAlphaCode;
        @AuraEnabled public String marketingFlightNumber;
        @AuraEnabled public String marketingFlightSuffix;
        @AuraEnabled public String departureAirportCode;
        @AuraEnabled public String arrivalAirportCode;
        @AuraEnabled public String operatingCarrierAlphaCode;
        @AuraEnabled public String operatingFlightNumber;
        @AuraEnabled public String operatingFlightSuffix;
        @AuraEnabled public String departureCityCode;
        @AuraEnabled public String arrivalCityCode;
        @AuraEnabled public String departureLocalDate;
        @AuraEnabled public String departureLocalTime;
        @AuraEnabled public String actualDepartureLocalDate;
        @AuraEnabled public String actualDepartureLocalTime;
        @AuraEnabled public String departureTerminalCode;
        @AuraEnabled public String arrivalLocalDate;
        @AuraEnabled public String arrivalLocalTime;
        @AuraEnabled public String actualArrivalLocalDate;
        @AuraEnabled public String actualArrivalLocalTime;
        @AuraEnabled public String arrivalTerminalCode;
        @AuraEnabled public String departureUTCDate;
        @AuraEnabled public String departureUTCTime;
        @AuraEnabled public String arrivalUTCDate;
        @AuraEnabled public String arrivalUTCTime;
        @AuraEnabled public String departureDow;
        @AuraEnabled public String dateVar;
        @AuraEnabled public String flightTypeCode;
        @AuraEnabled public String aircraftTypeCode;
        @AuraEnabled public String codeShareFlightTypeCode;
        @AuraEnabled public String codeShareAgreementTypeCode;
        @AuraEnabled public List<Disrupts> disrupts;


        // Added by Purushotham for prepopulation purpose
        @AuraEnabled public String airline;
        @AuraEnabled public String marketingAirline;
        @AuraEnabled public String departureAirport;
        @AuraEnabled public String departureCity;
        @AuraEnabled public String departureCountry;
        @AuraEnabled public String arrivalAirport;
        @AuraEnabled public String arrivalCity;
        @AuraEnabled public String arrivalCountry;
        @AuraEnabled public String departureDateTime;
        @AuraEnabled public Datetime departureUTCDateTime;
        @AuraEnabled public String actualDepartureDateTime;
        @AuraEnabled public String arrivalDateTime;
        @AuraEnabled public Datetime arrivalUTCDateTime;
        @AuraEnabled public String actualArrivalDateTime;
        @AuraEnabled public String bookedCabinClass;
        @AuraEnabled public String bookedReservationClass;
    }
    public class Disrupts {
        @AuraEnabled public String type;
        @AuraEnabled public String legDepartureAirportCode; 
        @AuraEnabled public String legArrivalAirportCode;
        @AuraEnabled public String unScheduledArrivalAirport; 
        @AuraEnabled public List<Detail> details;
    }
    public class Detail {
        @AuraEnabled public String reasonCode;
        @AuraEnabled public String shortDescription; 
        @AuraEnabled public String longDescription; 
        @AuraEnabled public String delayDuration; 
    }
    
}