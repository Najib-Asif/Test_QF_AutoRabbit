/*********************************************************************************
Name         : QCC_CustomerFlightsWrapper 
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 17 September 2019
Usages       : This class is used in QCC_PassengerConnectingFlightInvocable
*********************************************************************************/

public class QCC_CustomerFlightsWrapper {

    //Wrapper class to process the API response from Customer Retrieve Flights Callout
    public class CustomerFlightsWrapper {    
        @AuraEnabled public List<FlightsDetailWrapper> flights;
        @AuraEnabled public String nextPage;
    }
    
    //Wrapper class to store the customer flights details
    public class FlightsDetailWrapper{
        ///////////////////Jira: CRM-6052 /////////////////////
        @AuraEnabled public String travelPlanId; //max 20 char big int as string
        @AuraEnabled public String bookingId; // max 20 char big int as string"
        @AuraEnabled public String reloc; // max 6 chars"
        @AuraEnabled public String creationDate; // dd/mm/yyyy format
        @AuraEnabled public String currentPassengerQuantity; // max 12 chars int as string"
        @AuraEnabled public String segmentId; // max 20 char big int as string"
        @AuraEnabled public String segmentTattoo; // max 6 small int as string"
        @AuraEnabled public String marketingCarrierAlphaCode; // max 4 chars"
        @AuraEnabled public String marketingFlightNumber; // max 4 chars"
        @AuraEnabled public String marketingFlightSuffix; // max 1 char"
        @AuraEnabled public String departureLocalDate; // dd/mm/yyyy format
        @AuraEnabled public String departureLocalTime; // HH:mm:ss format
        @AuraEnabled public String departureUTCTimestamp; // dd/mm/yyyy HH:mm:ss
        @AuraEnabled public String estimateDepartureLocalDate; // dd/mm/yyyy format
        @AuraEnabled public String estimateDepartureLocalTime; // HH:mm:ss format
        @AuraEnabled public String actualDepartureLocalDate; // dd/mm/yyyy format
        @AuraEnabled public String actualDepartureLocalTime; // HH:mm:ss format
        @AuraEnabled public String arrivalLocalDate; // dd/mm/yyyy format
        @AuraEnabled public String arrivalLocalTime; // HH:mm:ss format
        @AuraEnabled public String estimateArrivalLocalDate; // dd/mm/yyyy format
        @AuraEnabled public String estimateArrivalLocalTime; // HH:mm:ss format
        @AuraEnabled public String actualArrivalLocalDate; // dd/mm/yyyy format
        @AuraEnabled public String actualArrivalLocalTime; // HH:mm:ss format
        @AuraEnabled public boolean informationalSegment; // boolean
        @AuraEnabled public String dateVariance; // max 4 chars tiny int as string, same day or next day"
        @AuraEnabled public String departureAirportCode; // max 3 chars"
        @AuraEnabled public String departureCityCode; // max 4 chars, uplift code"
        @AuraEnabled public String departureCityName; // max 30 chars, Departure City Name"
        @AuraEnabled public String arrivalAirportCode; // max 3 chars"
        @AuraEnabled public String arrivalCityCode; // max 4 chars, discharge code"
        @AuraEnabled public String arrivalCityName; // max 30 chars, Arrival City Name"
        @AuraEnabled public String reservationStatusCode; // max 2 chars, inventory status code"
        @AuraEnabled public String operatingCarrierAlphaCode; // max 4 chars"
        @AuraEnabled public String operatingFlightNumber; // max 4 chars"
        @AuraEnabled public String operatingFlightSuffix; // max 1 char"
        @AuraEnabled public String classOfService; // max 1 char"
        @AuraEnabled public String cabin; // max 1 char, nullable, populated only QF marketed or operated flight
    }

}