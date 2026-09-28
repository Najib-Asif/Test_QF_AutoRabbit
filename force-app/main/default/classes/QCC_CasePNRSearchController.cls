public with sharing class QCC_CasePNRSearchController {
	@AuraEnabled
	public static String getInitInfo(String caseId){
		String output = '';
		Case cs = [select id, Last_Name__c, First_Name__c, Booking_PNR__c FROM Case where id =:caseId limit 1];
		output = cs.Booking_PNR__c;
		return output;
	}

	/*--------------------------------------------------------------------------------------      
    Method Name:        fetchCAPBooking
    Description:        To get List of booking information from CAP system
    Parameter:          caseId ,pnr
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static QCC_BookingSummaryWrapper fetchCAPBooking(String caseId, String pnr, Boolean archivalData){
        try{
            String archival = String.valueOf(archivalData);
            Case cs = [select id, Last_Name__c, First_Name__c, Booking_PNR__c FROM Case where id =:caseId limit 1];
            String lastname = cs.Last_Name__c;
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            System.debug('call api');
            QCC_PNRFlightInfoWrapper pnrFlightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(pnr, lastname, token, archival);
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');

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
    Method Name:        fetchCAPBookingWithLastName
    Description:        To get List of booking information from CAP system, using for QCC Voice Search by PNR Subflow
    Parameter:          caseId ,pnr, lastname
    Story:              ADT-189
    Author:             Jamie Wang
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static QCC_BookingSummaryWrapper fetchCAPBookingWithLastName(String caseId, String pnr, Boolean archivalData , String lastName){
        try{
            pnr = QCC_GenericUtils.doTrim(pnr);
            String archival = String.valueOf(archivalData);
            String inputLastname = lastName;
            inputLastname = QCC_GenericUtils.doTrim(inputLastname);
            inputLastname = EncodingUtil.urlEncode(inputLastname, 'UTF-8').replaceAll('\\+','%20');
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            System.debug('call api');
            QCC_PNRFlightInfoWrapper pnrFlightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(pnr, inputLastname, token, archival);
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            System.debug('pnrFlightInfo ' +pnrFlightInfo);
            QCC_BookingSummaryWrapper bookingInfo = null;
            if(pnrFlightInfo != null){
                bookingInfo = new QCC_BookingSummaryWrapper();
                bookingInfo.bookings = new List<QCC_BookingSummaryWrapper.bookings>();
                QCC_BookingSummaryWrapper.bookings singleBooking = new QCC_BookingSummaryWrapper.bookings();
                
                List<String> splittedDate = pnrFlightInfo.booking.creationDate.split('/');
                system.debug('@@@@ pnrFlightInfo.booking.creationDatee ' + pnrFlightInfo.booking.creationDate);
                String creationDate = splittedDate[2]+'-'+splittedDate[1]+'-'+splittedDate[0];
                System.debug('@@@@ creation Date' + creationDate);
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
    Method Name:        updateCasePNR
    Description:        To update the PNR of the Case record based on the inpputted text
    Parameter:          caseId ,pnr
    Story:              ADT-202
    Author:             Darwin Herbert Lubas
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static void updateCasePNR(String caseId, String pnr){
        System.debug('@@@@ updateCasePNR caseId' + caseId);
        System.debug('@@@@ updateCasePNR pnr> ' + pnr);
        pnr = QCC_GenericUtils.doTrim(pnr);
    	Case mcase = [SELECT Id, Booking_PNR__c FROM Case WHERE Id =: caseId ];
        mcase.Booking_PNR__c = pnr;
        try{
            update mcase;
            System.debug('@@@@ in TRY updateCasePNR mcase PNR: '+ mcase.Booking_PNR__c);
        }
        catch(DMLException ex){
            System.debug('@@@@Exception'+ ex);
            CreateLogs.insertLogRec( 'Log Exception ', 'QCC_CasePNRSearchController', 'QCC_CasePNRSearchController', 
                                    'updateCasePNR', '', '', false,'', ex);
        }
	}


    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchCAPBookingWithCreationDate
    Description:        To get List of booking information from CAP system, using for QCC Voice Search by PNR Subflow
    Parameter:          caseId, pnr, isHistory, archivalData, creationDate
    Story:              ADT-181
    Author:             Darwin Herbert Lubas
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static QCC_BookingSummaryWrapper fetchCAPBookingWithCreationDate(String caseId, String pnr, Boolean isHistory ,Boolean archivalData , String creationDate){
        try{
            system.debug('@@@@ fetchCAPBookingWithCreationDate');
            String archival = String.valueOf(archivalData);
            String inputCreationDate = creationDate;
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            System.debug('call api');
            QCC_PNRFlightInfoWrapper pnrFlightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(pnr, inputCreationDate, token, isHistory,archival);
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            System.debug('@@@@ WithCreationDate pnrFlightInfo ' +pnrFlightInfo);
            QCC_BookingSummaryWrapper bookingInfo = null;
            if(pnrFlightInfo != null){
                bookingInfo = new QCC_BookingSummaryWrapper();
                bookingInfo.bookings = new List<QCC_BookingSummaryWrapper.bookings>();
                QCC_BookingSummaryWrapper.bookings singleBooking = new QCC_BookingSummaryWrapper.bookings();
                
                //List<String> splittedDate = pnrFlightInfo.booking.creationDate.split('/');
                List<String> splittedDate = creationDate.split('/');
                //String creationDate = splittedDate[2]+'-'+splittedDate[1]+'-'+splittedDate[0];
                // If fail create new string variable for String creationDate
                creationDate = splittedDate[2]+'-'+splittedDate[1]+'-'+splittedDate[0];
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
    
}