public class QCC_viewBookings {
    /************************************
     * Purpose      : Getting Booking Details from API
     * Parameter    : Frequent Flyer Number, Page Number
     * Returns      : List
     * Throws       :
     * Expectations : 
     ************************************/
    @AuraEnabled
    public static List<QCC_viewBookingWrapper> getBookingsDetails(List<String> ffNumberList, integer pageNumber) {
        List<QCC_viewBookingWrapper> listOfBookings = new List<QCC_viewBookingWrapper>();
        try{
            QCC_viewBookingWrapper singleBooking;
            String tokenTicketStatus = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken'); // token for tickeStatus api
            string ffNumber = ffNumberList.get(0);
    
            Datetime today = system.today();
            Datetime timestamp = today.addDays(365);
            Datetime timestampMinusYear = today.addDays(-365);
            Long timestampStr = timestamp.getTime();
            Long timestampMinusYearStr = timestampMinusYear.getTime();
                    
            String customerFlights = QCC_InvokeCAPAPI.invokeProductFlightCAPAPI(ffNumber, tokenTicketStatus, timestampStr, timestampMinusYearStr, pageNumber);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(customerFlights);
            Boolean lastPage = responseMap.containsKey('nextPage') ? false : true; 
            system.debug('>>>flights: ' + JSON.serialize(responseMap.get('flights')));
            List<Object> flightObjs = (List<Object>)responseMap.get('flights');
            system.debug('>>>flightObjs: ' + flightObjs);
            
            if(responseMap.containsKey('errorCode')){
                system.debug('Error view ===== ' + responseMap.get('errorCode'));
                singleBooking = new QCC_viewBookingWrapper();
                singleBooking.errMsg = 'No bookings found';
                listOfBookings.add(singleBooking);
                
            }else{
                for (Object obj : flightObjs) {
                    String objString = JSON.serialize(obj);
                    Map<String, Object> flightMap = (Map<String, Object>) JSON.deserializeUntyped(objString);
                    system.debug('>>>flightMap: ' + flightMap.get('reloc'));
                    
                    singleBooking = new QCC_viewBookingWrapper();
                    singleBooking.pnr = String.valueOf(flightMap.get('reloc')); 
                    singleBooking.departureAirportCode = String.valueOf(flightMap.get('departureAirportCode')); 
                    singleBooking.arrivalAirportCode = String.valueOf(flightMap.get('arrivalAirportCode')); 
                    singleBooking.departureLocalDate = String.valueOf(flightMap.get('departureLocalDate')) + ' ' + String.valueOf(flightMap.get('departureLocalTime')); 
                    //singleBooking.departureLocalTime = flightsInfo.departureLocalTime; 
                    singleBooking.reservationStatusCode = String.valueOf(flightMap.get('reservationStatusCode')) != 'HK' ? '!' : '';
                    Datetime departureDate = date.parse(String.valueOf(flightMap.get('departureLocalDate')) );
                    if(departureDate >= today){
                        singleBooking.ticketStatus = (QCC_InvokeCAPAPI.invokeBookingTicketCAPAPI(singleBooking.pnr,tokenTicketStatus) == false) ? '!': '';
                    }
                    else{
                        singleBooking.ticketStatus = '';
                    }
                    
                    singleBooking.creationDate = String.valueOf(flightMap.get('creationDate'));
                    singleBooking.creationDate = String.valueOf(Date.parse(String.valueOf(flightMap.get('creationDate'))));
                    system.debug('>>>QCC_viewBookings creationDate: ' + flightMap.get('creationDate'));
                    system.debug('>>>QCC_viewBookings creationDate: ' + singleBooking.creationDate);
                    singleBooking.lastPage = lastPage;
                    
                    listOfBookings.add(singleBooking);
                }       
            }
        }
        catch (Exception e) {
            system.debug(e.getMessage());
        }
        
        return listOfBookings;
        
    }

    @AuraEnabled(cacheable = true)
    public static List<Contact> getContactForBookingDetails(Id recordId){
    /************************************
     * Purpose      : Query the FFnumber for a contact to get booking detail from getBookingsDetails in LWC.
     * Parameter    : record Id
     * Returns      : contact ID and Frequent_Flyer_Number__c
     * Throws       :
     * Expectations : 
     ************************************/
        try
        {
            String recId = recordId;
            //Jira: CRM-6052 including suggested booking details from Case record page.
            if(recId.startsWith('500'))
            {
                Case cs = [Select Id, ContactId, Frequent_Flyer_Number__c FROM Case where Id =: recId];
                recId = cs.ContactId;
            }
            Contact[] record = [SELECT Id, Frequent_Flyer_Number__c FROM Contact WHERE Id = :recId];
            return record;
            
        } 
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}