public class QCC_BookingSummaryWrapper {

        @AuraEnabled public List<Bookings> bookings;
        @AuraEnabled public String nextPageNumber;
    

    public class Bookings {
         @AuraEnabled public String reloc;
         @AuraEnabled public String travelPlanId;
         @AuraEnabled public String bookingId;
         @AuraEnabled public String creationDate;
         @AuraEnabled public String currentPassengerQuantity;
         @AuraEnabled public String segmentType;
         @AuraEnabled public String departureTimeStamp;
         @AuraEnabled public String departurePort;
         @AuraEnabled public String departureCity;
         @AuraEnabled public String arrivalPort;
         @AuraEnabled public String arrivalCity;
         @AuraEnabled public String lastUpdatedTimeStamp;
         @AuraEnabled public String archivalData;
    }

}