public with sharing class QCC_CasePNRSearchFlowController {

	/*--------------------------------------------------------------------------------------      
    Method Name:        fetchCAPBooking
    Description:        To get List of booking information from CAP system
    Parameter:          caseId ,pnr
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static QCC_BookingSummaryWrapper fetchCAPBooking(String lastName, String pnr, Boolean archivalData){
        try{
            String archival = String.valueOf(archivalData);
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            System.debug('call api');
            QCC_PNRFlightInfoWrapper pnrFlightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(pnr, lastName, token, archival);
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            System.debug('#### fetchCAPBooking : ' + pnrFlightInfo);

            QCC_BookingSummaryWrapper bookingInfo = null;
            if(pnrFlightInfo != null){
                bookingInfo = new QCC_BookingSummaryWrapper();
                bookingInfo.bookings = new List<QCC_BookingSummaryWrapper.bookings>();
                QCC_BookingSummaryWrapper.bookings singleBooking = new QCC_BookingSummaryWrapper.bookings();
                
                List<String> splittedDate = pnrFlightInfo.booking.creationDate.split('/');
                String creationDate = splittedDate[2]+'-'+splittedDate[1]+'-'+splittedDate[0];
                singleBooking.creationDate = creationDate;
                singleBooking.reloc = pnrFlightInfo.booking.reloc;
                singleBooking.bookingId = pnrFlightInfo.booking.bookingId;
                singleBooking.lastUpdatedTimeStamp = pnrFlightInfo.booking.lastUpdatedTimeStamp;
                singleBooking.archivalData = archival;

                Integer sgTatoo = 100000;
                for(QCC_PNRFlightInfoWrapper.Segments sg : pnrFlightInfo.booking.segments){
                    if(sgTatoo > Integer.valueOf(sg.segmentTattoo)){
                        sgTatoo = Integer.valueOf(sg.segmentTattoo);
                        singleBooking.departurePort = sg.departureAirportCode;
                        singleBooking.arrivalPort = sg.arrivalAirportCode;
                        singleBooking.departureTimeStamp = sg.departureLocalDate + ' ' + sg.departureLocalTime;
                    }
                }

                bookingInfo.bookings.add(singleBooking);
            }

            return bookingInfo;
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_CasePNRSearchController', 
                                    'fetchCAPBooking', '', '', false,'', ex);
        }
        return null;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        lookupCustomer
    Description:        Fetch Customer Information from CAP system
    Parameter:          String
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String lookupCustomer(String capId) {
        return QCC_LookupFrequentFlyerController.lookupCustomer('', '', capId);
    }
    

}