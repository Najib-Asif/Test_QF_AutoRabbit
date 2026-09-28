/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath 
Company:       Capgemini
Description:   QCC Display Booking Controlller
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
31-Oct-2017      Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_DisplayBookingController {
       
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchCAPBookingViaFFNumber
    Description:        To get List of booking information from  FF Number CRM-6052
    Parameter:          RecordId,pageNumber
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static QCC_CustomerFlightsWrapper.CustomerFlightsWrapper fetchCAPBookingViaFFNumber(String recordId, Integer pageNumber){
        try {
                Contact objCon = contactSelect(recordId);
                String tokenTicketStatus = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken'); // token for tickeStatus api
                string ffNumber = objCon.Frequent_Flyer_Number__c;
                System.debug('pageNumber========> ' + pageNumber);
                Datetime today = system.today();
                Datetime timestamp = today.addDays(365);
                Datetime timestampMinusYear = today.addDays(-365);
                Long timestampStr = timestamp.getTime();
                Long timestampMinusYearStr = timestampMinusYear.getTime();
                QCC_CustomerFlightsWrapper.CustomerFlightsWrapper flightBookings = QCC_InvokeCAPAPI.invokeProductFlightsCAPAPI(ffNumber, tokenTicketStatus, timestampStr, timestampMinusYearStr, pageNumber, false);
                System.debug('flightBookings========> ' + flightBookings);
                return flightBookings;
        } catch(Exception ex) {
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_DisplayBookingController', 
                                    'fetchCAPBookingViaFFNumber', '', '', false,'', ex);
        }
        return null;
    }
       
    //Commenting this method as part of CRM-6052
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchCAPBooking
    Description:        To get List of booking information from CAP system
    Parameter:          RecordId,Integer
    --------------------------------------------------------------------------------------
    @AuraEnabled
    public static QCC_BookingSummaryWrapper fetchCAPBooking(String recordId, Integer pageNumber){
        try{
            Contact objCon = contactSelect(recordId);
            //String capID = '710000000017';
            String capID = objCon.CAP_ID__c;
            String bookingPerPage ='10';
                        
            QCC_BookingSummaryWrapper booking = QCC_InvokeCAPAPI.invokeBookingCAPAPI(capID, bookingPerPage, pageNumber);
            return booking;
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_DisplayBookingController', 
                                    'fetchCAPBooking', '', '', false,'', ex);
        }
        return null;
    }
    */ 

    

    /*--------------------------------------------------------------------------------------      
    Method Name:        contactSelect
    Description:        Fetch the Contact Information
    Parameter:          ID
    --------------------------------------------------------------------------------------*/ 
    private static Contact contactSelect (Id recordId) {
        String recId = recordId;
        Contact objCon;
        if(recId.startsWith('003')){
            objCon = [SELECT Id, CAP_ID__c, FirstName, LastName, Frequent_Flyer_Number__c FROM Contact 
                      WHERE Id =: recordId];
        }
        else if(recId.startsWith('500')){
            Case objCase = [Select Id, ContactId, Contact.CAP_ID__c, Contact.Frequent_Flyer_Number__c, Contact.FirstName,
                            Contact.LastName from Case where Id =: recordId];
            objCon = objCase.Contact;

        }
        return objCon;
    }
    
    //Commenting this method as part of CRM-6052
    /*--------------------------------------------------------------------------------------      
    Method Name:        caseSelect
    Description:        Fetch the Contact Information
    Parameter:          ID
    --------------------------------------------------------------------------------------
    private static Case caseSelect (Id recordId) {
        String recId = recordId;
        Case objCase;
        if(recId.startsWith('003')){
            objCase = [Select Id, ContactId, Contact.CAP_ID__c, Departure_Date_Time__c, Contact.Frequent_Flyer_Number__c, Contact.FirstName,
                            Contact.LastName from Case where ContactId =: recordId];
        }
        else if(recId.startsWith('500')){
            Case cs = [Select Id, ContactId, Contact.CAP_ID__c, Departure_Date_Time__c, Contact.Frequent_Flyer_Number__c, Contact.FirstName,
                            Contact.LastName from Case where Id =: recordId];
            objCase = cs;

        }
        return objCase;
    }*/ 

}