public class QCC_viewBookingWrapper {
    @AuraEnabled public string pnr;//max 6 chars"(PNR)
    @AuraEnabled public String departureAirportCode;// max 3 chars"(DEP Departure Port)
    @AuraEnabled public String arrivalAirportCode; // max 3 chars"(ARR Arrival Port)
    @AuraEnabled public String departureLocalDate; // dd/mm/yyyy format (departure date)
    //@AuraEnabled public String departureLocalTime; // HH:mm:ss format(departure date)
    @AuraEnabled public String reservationStatusCode; // max 2 chars, inventory status code" (Flight Status)
    @AuraEnabled public string ticketStatus;// (Current Ticketing Status)
    @AuraEnabled public Boolean lastPage;
    @AuraEnabled public String errMsg;
    @AuraEnabled public String creationDate; // dd/mm/yyyy format
    
}