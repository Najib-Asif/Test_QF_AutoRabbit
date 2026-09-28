/*----------------------------------------------------------------------------------------------------------------------
Author:        Abbas
Company:       Capgemini
Description:   This class controls the behaviour of the Email button on the Case Page
Inputs:        Various inputs from the lightning component.
Test Class:     
************************************************************************************************
History
************************************************************************************************
20-Nov-2017      Abbas               Initial Design
8-Mar-2018       Cuong Ly            QDCUSCON-2086. Add functions : fetchEmailTemplateValues, fetchCongaEmailTemplateId 
17-May-2018      Cuong Ly            QDCUSCON 3550. Add functions : getCongaQueryAffectedPassenger, dynamicAffectedPassengerQueryBuilder   
21-May-2018      Cuong Ly            QDCUSCON 4204. Add functions : fetchSalesforceEmailTemplateId
22-June-2018      Nga Do             QDCUSCON 3807, 3808. modified functions : fetchEmailTemplateValues for LP Recoveries          
-----------------------------------------------------------------------------------------------------------------------*/

public class QCC_EmailButtonController {
    /*----------------------------------------------------------------------------------------------      
    Method Name:        userSessionId
    Description:        Gets the Session ID of the Current user of the instance
    Parameter:          NIL
    Return:             String
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public  static String userSessionId() {
        return UserInfo.getSessionId();
    }
    
    
     /*----------------------------------------------------------------------------------------------      
    Method Name:        genericContactInfo
    Description:        Gets the Session ID of the Current user of the instance
    Parameter:          NIL
    Return:             String
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public  static String genericContactInfo() {
        return QCC_GenericUtils.fetchGenericContact();
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        orgServerURLs
    Description:        Gets the Base URL of the Salesforce instance for passing into Conga Email url
    Parameter:          NIL
    Return:             String
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String orgServerURLs() {
        string urler = URL.getSalesforceBaseUrl().toExternalForm();
        return urler;
    }
    /*----------------------------------------------------------------------------------------------      
    Method Name:        getOrgWideAndCaseTypeServer
    Description:        Gets the Org Wide Email Address ID and EFT Conga Email Template Record Id
    Parameter:          Id<Case>
    Return:             null
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String getOrgWideAndCaseTypeServer(Id recId) {
        try {
            List<Case> cs  = new List<Case>();
            cs = [SELECT Id, Type FROM Case WHERE Id = :recId];
            String orgWideId = CustomSettingsUtilities.getConfigDataMap('OrgWideAddress');
            String tempIdCS = CustomSettingsUtilities.getConfigDataMap('EFTEmailTemplateId');
            if(cs.size() > 0){
                return cs[0].Type+','+orgWideId+','+tempIdCS;
            }
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC Email Button', 'QCC_EmailButtonController', 
                                     'getOrgWideAndCaseTypeServer', String.valueOf(''), String.valueOf(''),false,'', ex);
            //throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }
    

    /*----------------------------------------------------------------------------------------------      
    Method Name:        validateCaseDetailsForLetter
    Description:        Calls getCaseVaues to validate case details are ready for preparing Insurance Letter Type.
    Parameter Auto:     null, String, Boolean<true>, Sobject<Case>
    Parameter Manual:   List<Case>
    Return:             List<String>
    ----------------------------------------------------------------------------------------------*/
    @InvocableMethod(label='Validate Case Details Are OK For Letter' description='Validate Case Details Are OK For Letter')
    public static List <String> validateCaseDetailsForLetter(List<Case> caseList){

        List <string> errorList = new List <string>();
        String errorText = '';

        if (caseList.size() > 0){
            for(Case caseListItem : caseList){
                errorText = getCaseValues(  caseListItem.Id,
                                            caseListItem.Type,
                                            false,              //Was this via an integration channel
                                            null);
                errorList.Add(errorText);                            
            }
        }
    
        System.debug('#### QCC_EmailButtonController validateCaseDetailsForLetter - Error List response  : '+ errorList);
     
        return errorList;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        getCaseValues
    Description:        Gets values from Case record when Type = Insurance Letters plus either the 
                        Email Customer button is clicked or the Case is created from Red APP, does
                        validation on the fields and perform validation rules as per QDCUSCON-95.
    Parameter Auto:     null, String, Boolean<true>, Sobject<Case>
    Parameter Manual:   Id<Case>, String, Boolean<false>, null
    Return:             String
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String getCaseValues(Id recId, String insType,boolean fromIntegration, Case cs){
        //Case cs;
        String error;
        String finalErrors = '';
        String FCR_Local_Val = 'No';
        Boolean From_Integration = true;
        
        try {
            
            if(recId != null){
                cs = [SELECT Id,Ticket_Status__c,PNR_Verified__c,Is_Qantas_Issued_Ticket__c,Ticket_Number__c,Issued_by_TravelAgent__c,Segment_Id__c,Disrupt_Type__c,Type,Group__c,Airline__c,Arrival_Delay_Time_Hours__c,Arrival_Delay_Time_Mins__c,Flight_Cancellation__c,Flight_Number__c,Conga_Email_Template_ID__c,Conga_Template_ID__c,Refund_Type__c,FCR__c,Delay_Reason__c,Arrival_Date_Time__c,Actual_Arrival_Date_Time__c  FROM Case WHERE Id = :recId];
            }

            if(cs.Type.equalsIgnoreCase(insType) && (cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupDF')|| cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupFCQ') || cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupPBNS'))){
                if(fromIntegration == false && (cs.Segment_Id__c == null || cs.Segment_Id__c == '')){      
                    System.debug('First Error');
                    error = 'The following business rules have not passed for the requested Insurance Letter:';
                    error = error + '\n The customer can not be found on the booking (PNR) and/or flight';
                }
                if(!String.isBlank(cs.Airline__c)){
                    if(!cs.Airline__c.equalsIgnoreCase('Qantas')){
                        if(cs.Flight_Number__c != null){
                            if(error != null){
                                error = error + '\n Flight: '+cs.Flight_Number__c+' was not operated by Qantas';
                            }else{
                                error = 'The following business rules have not passed for the requested Insurance Letter:';
                                error = error + '\n Flight: '+cs.Flight_Number__c+' was not operated by Qantas';
                            }
                        }else{
                            error = error != null ? error + '\n Flight Number is missing.' : 'The following business rules have not passed for the requested Insurance Letter:\nFlight Number is missing.';
                        }
                        FCR_Local_Val = 'Ineligible';
                    }
                }
                else{
                    error = error != null ? error + '\n There is no airline' : 'The following business rules have not passed for the requested Insurance Letter:\nThere is no airline';
                }
                
                if(cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupFCQ')){
                    if(cs.Flight_Cancellation__c == false){
                        if(cs.Flight_Number__c != null){
                            if(error != null){
                                error = error + '\n Flight: '+cs.Flight_Number__c+' was not cancelled.';
                            }else{
                                error = 'The following business rules have not passed for the requested Insurance Letter:';
                                error = error + '\n Flight: '+cs.Flight_Number__c+' was not cancelled.';
                            }
                            FCR_Local_Val = 'Ineligible';
                        }else{
                            error = error != null ? error + '\n Flight Number is missing.' : 'The following business rules have not passed for the requested Insurance Letter:\nFlight Number is missing.';
                        }
                    } else {
                        if(cs.Ticket_Status__c == null) {
                            error = error != null ? error + '\nTicket Status is missing.' : 'The following business rules have not passed for the requested Insurance Letter:\nTicket Status is missing.';
                        }
                    }
                }
                
                if(cs.Group__c == CustomSettingsUtilities.getConfigDataMap('CaseGroupDF')){
                    Decimal arrivalDelayTimeHours = cs.Arrival_Delay_Time_Hours__c;
                    Decimal arrivalDelayTimeMins = cs.Arrival_Delay_Time_Mins__c;
                    DateTime actArrivalDT;
                    DateTime arrivalDT;
                    if(cs.Actual_Arrival_Date_Time__c != null) {
                        actArrivalDT = QCC_GenericUtils.convertStringtoDateTime(cs.Actual_Arrival_Date_Time__c.substring(0,10),cs.Actual_Arrival_Date_Time__c.substring(11,cs.Actual_Arrival_Date_Time__c.length()));
                    }
                    if(cs.Arrival_Date_Time__c != null) {
                        arrivalDT = QCC_GenericUtils.convertStringtoDateTime(cs.Arrival_Date_Time__c.substring(0,10),cs.Arrival_Date_Time__c.substring(11,cs.Arrival_Date_Time__c.length()));
                    }

                    if(arrivalDelayTimeHours == null && actArrivalDT != null && arrivalDT != null) {
                       arrivalDelayTimeHours = Math.floor((actArrivalDT.getTime() - arrivalDT.getTime())/1000/60/60);
                    }
                    if(arrivalDelayTimeMins == null && actArrivalDT != null && arrivalDT != null) {
                        arrivalDelayTimeMins = Math.floor((actArrivalDT.getTime() - arrivalDT.getTime())/1000/60);
                    }
                    if(arrivalDelayTimeHours <= 0 && arrivalDelayTimeMins <= 15){
                        if(cs.Flight_Number__c != null){
                            if(error != null){
                                error = error + '\n Flight: '+cs.Flight_Number__c+' was not delayed.';  
                            }else{
                                error = 'The following business rules have not passed for the requested Insurance Letter:';
                                error = error + '\n Flight: '+cs.Flight_Number__c+' was not delayed.';  
                            }
                            FCR_Local_Val = 'Ineligible';
                        }else{
                            error = error + '\n Flight number for the Delayed Flight is missing.';
                        }
                    }
                }
                
                if(error == null && FCR_Local_Val != 'Ineligible') {
                    if(cs.Ticket_Status__c != null  && (cs.Ticket_Status__c.equalsIgnoreCase('Open') || cs.Ticket_Status__c.equalsIgnoreCase('Suspended'))){// || cs.Ticket_Status__c != 'Suspended'
                        finalErrors = checkEmptyfields(cs.Group__c,recId,null,cs);
                    }else{
                        finalErrors = checkEmptyfields(cs.Group__c,recId,'not null',cs);
                    }
                }
                
                
                if(finalErrors != null && finalErrors != ''){
                    finalErrors = '\n\n The following email template fields have missing data, please update these fields to generate the letter: \n' + finalErrors;
                }
                if(error != null || (finalErrors !=null && String.isNotBlank(finalErrors))){
                    if(error == null){
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem,finalErrors );                                  
                    }else{
                        if(finalErrors != null){
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, error + finalErrors );    
                        }else{
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, error);       
                        }
                    }
                    
                    //FCR_Local_Val = 'No';
                }else{
                    FCR_Local_Val = 'Yes';
                }
            }
            else if(cs.Type.equalsIgnoreCase(insType) && cs.Group__c == 'Booking Cancelled by Customer'){
                if(!String.isBlank(cs.Airline__c)){
                    if(!cs.Airline__c.equalsIgnoreCase('Qantas')){
                        if(cs.Flight_Number__c != null){
                            if(error != null){
                                error = error + '\n Flight: '+cs.Flight_Number__c+' was not operated by Qantas';
                            }else{
                                error = 'The following business rules have not passed for the requested Insurance Letter:\n';
                                error = error + 'Flight: '+cs.Flight_Number__c+' was not operated by Qantas';
                            }
                        }else{
                            error = error != null ? error + '\n Flight Number is missing.' : 'The following business rules have not passed for the requested Insurance Letter:\nFlight Number is missing.';
                        }
                        FCR_Local_Val = 'Ineligible';
                    }
                }
                else{
                    error = error != null ? error + '\n There is no airline' : 'The following business rules have not passed for the requested Insurance Letter:\nThere is no airline';
                }

                if(FCR_Local_Val != 'Ineligible') {
                    if(cs.Refund_Type__c == 'Tax only Refund' || cs.Refund_Type__c == 'Refunded with Cancellation Policy' || cs.Refund_Type__c == 'Ticket held in Credit'){
                        finalErrors = checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                        if(finalErrors == 'Ineligible') {
                            finalErrors = 'The following business rules have not passed for the requested Insurance Letter:\nTicket is not a Qantas issued ticket.';
                            FCR_Local_Val = 'Ineligible';
                        } else if(finalErrors.contains('Ineligible')) {
                            finalErrors = finalErrors.replace('Ineligible', '');
                        }
                    }else if(String.isBlank(cs.Refund_Type__c)) {
                        //finalErrors = checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                        //if(finalErrors == 'Ineligible') {
                        //    finalErrors = 'The following business rules have not passed for the requested Insurance Letter:\nTicket is not a Qantas issued ticket.';
                        //    FCR_Local_Val = 'Ineligible';
                        //} else if(finalErrors.contains('Ineligible')) {
                        //    finalErrors = finalErrors.replace('Ineligible', '');
                        //}
                        //if(String.isBlank(finalErrors)) {
                        error = 'The following business rules have not passed for the requested Insurance Letter:\nRefund Type is not valid for insurance ticket details.';    
                        //}
                    }
                }
                
                /*if(finalErrors != null && finalErrors != ''){
                    finalErrors = '\n\n The following email template fields have missing data, please update these fields to generate the letter: \n' + finalErrors;
                }*/

                if(error != null || (finalErrors !=null && finalErrors != '')){
                    if(error == null){
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem,finalErrors );                                  
                    }else{
                        if(finalErrors != null){
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, error + finalErrors );    
                        }else{
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem, error);
                        }
                    }
                    //FCR_Local_Val = 'No';
                }else{
                    FCR_Local_Val = 'Yes';
                }
            }
            else if(cs.Type.equalsIgnoreCase(insType)){
                if(cs.Group__c == 'Damaged Baggage'){
                    finalErrors = checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                    if(finalErrors != null){
                        finalErrors = '\n\n The following email template fields have missing data, please update these fields to generate the letter: \n' + checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem,finalErrors );
                        //FCR_Local_Val = 'No';
                    }
                    else{
                        FCR_Local_Val = 'Yes';
                    }
                }else if(cs.Group__c == 'Delayed or Lost Baggage'){
                    finalErrors = checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                    if(finalErrors != null){
                        finalErrors = '\n\n The following email template fields have missing data, please update these fields to generate the letter: \n' + checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem,finalErrors );
                        //FCR_Local_Val = 'No';
                    }
                    else{
                        FCR_Local_Val = 'Yes';
                    }
                }else if(cs.Group__c == 'Personal Property Lost In-flight'){
                    finalErrors = checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                
                    if(finalErrors != null){
                        finalErrors = '\n\n The following email template fields have missing data, please update these fields to generate the letter: \n' + checkEmptyfields(cs.Group__c,recId,cs.Refund_Type__c,cs);
                        System.debug(LoggingLevel.ERROR, 'Finals Errors = '+finalErrors);
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, cs.Id, ConnectApi.FeedElementType.FeedItem,finalErrors );
                        //FCR_Local_Val = 'No';
                    }
                    else{
                        FCR_Local_Val = 'Yes';
                    }
                } else if(cs.Group__c == null){
                    error = '\n Group is missing.';
                }
            }
        
            if(recId != null && FCR_Local_Val == 'Ineligible') {
                String emailTemplateId;
                List<QCC_Email_Template_Setting__mdt> emailTemplateDetails = [SELECT Id, EmailTemplateName__c, TemplateGroup__c, AutoCloseCase__c FROM QCC_Email_Template_Setting__mdt WHERE Type__c =: 'Ineligible Insurance Letter' AND Group__c =: cs.Group__c LIMIT 1];
                if(emailTemplateDetails != null && emailTemplateDetails.size() > 0){
                    emailTemplateId = QCC_GenericUtils.fetchSalesforceEmailTemplate(emailTemplateDetails[0].EmailTemplateName__c);
                }
                return FCR_Local_Val + ',' + emailTemplateId;
            } else {
                return FCR_Local_Val;
            }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC Insurance Rule Validation', 'QCC_EmailButtonController', 
                                     'getCaseValues', String.valueOf(''), String.valueOf(''),false,'', ex);
            return 'No';
            //throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        checkEmptyfields
    Description:        Passes the set of fields to the dynamicCaseQueryBuilder based on the Group
                        Group field if Type = Insurance Letters - Refer Insurance Letters Confluence
                        Page.
    Parameter:          String, Id<Case>, String, SObject<Case>
    Return:             String
    ----------------------------------------------------------------------------------------------*/
    public static String checkEmptyfields(String groupType,Id csId,String refundType,Case auto_case){
       String returnedErrors;
       if(groupType == 'Delayed Flight'){
            returnedErrors = dynamicCaseQueryBuilder('Actual_Departure_Date_Time__c,Actual_Arrival_Date_Time__c,Arrival_Delay_Time_Mins__c,Arrival_Delay_Time_Hours__c,Suburb__c,Street__c,State__c,Post_Code__c,Booking_PNR__c,Flight_Number__c,Departure_Delay_Time_Mins__c,Departure_Delay_Time_Hours__c,Departure_Date_Time__c,Departure_City__c,Delay_Reason__c,Country__c,CaseNumber,Arrival_Date_Time__c,Arrival_City__c',csId,auto_case);
       }else if(groupType == 'Flight Cancelled by Qantas' && (refundType != null && (refundType != 'Open' || refundType != 'Suspended'))){
           //returnedErrors = dynamicCaseQueryBuilder('Ticket_Status__c,Suburb__c,Street__c,State__c,Actual_Arrival_Date_Time__c,Actual_Departure_Date_Time__c,Rebooked_Flight_Number__c,Rebooked_Flight_Delay_Mins__c,Rebooked_Flight_Delay_Hours__c,Rebooked_Flight_Actual_Arrival_Date_Time__c,Post_Code__c,Booking_PNR__c,Passenger_Last_Name__c,Passenger_First_Name__c,Flight_Number__c,Delay_Reason__c,Departure_Delay_Time_Mins__c,Departure_Delay_Time_Hours__c,Departure_Date_Time__c,Departure_City__c,Country__c,CaseNumber,Arrival_Delay_Time_Mins__c,Arrival_Delay_Time_Hours__c,Arrival_City__c,Arrival_Date_Time__c',csId,auto_case);
           returnedErrors = dynamicCaseQueryBuilder('Arrival_City__c,Booking_PNR__c,CaseNumber,Delay_Reason__c,Departure_City__c,Departure_Date_Time__c,Flight_Number__c,Rebooked_Flight_Actual_Arrival_Date_Time__c,Rebooked_Flight_Delay_Hours__c,Rebooked_Flight_Delay_Mins__c,Rebooked_Flight_Number__c,Street__c,Suburb__c,State__c,Post_Code__c,Country__c',csId,auto_case);
       }else if(groupType == 'Flight Cancelled by Qantas' && refundType == null){ 
           //returnedErrors = dynamicCaseQueryBuilder('Ticket_Status__c,Suburb__c,Street__c,State__c,Post_Code__c,Actual_Arrival_Date_Time__c,Actual_Departure_Date_Time__c,Booking_PNR__c,Passenger_Last_Name__c,Passenger_First_Name__c,Flight_Number__c,Departure_Delay_Time_Mins__c,Departure_Delay_Time_Hours__c,Departure_Date_Time__c,Departure_City__c,Country__c,CaseNumber,Delay_Reason__c,Arrival_Delay_Time_Mins__c,Arrival_Delay_Time_Hours__c,Arrival_City__c,Arrival_Date_Time__c',csId,auto_case);
           returnedErrors = dynamicCaseQueryBuilder('Arrival_City__c,Booking_PNR__c,CaseNumber,Delay_Reason__c,Departure_City__c,Departure_Date_Time__c,Flight_Number__c,Street__c,Suburb__c,State__c,Post_Code__c,Country__c',csId,auto_case);
       }else if(groupType == 'Proof of Boarding or No Show'){
            //returnedErrors = dynamicCaseQueryBuilder('Suburb__c,Street__c,State__c,Post_Code__c,Booking_PNR__c,Passenger_Last_Name__c,Passenger_First_Name__c,Flight_Number__c,Flight_Leg_Flown_Statuses__c,Departure_Date_Time__c,Departure_City__c,Country__c,CaseNumber,Arrival_City__c',csId,auto_case);
            returnedErrors = dynamicCaseQueryBuilder('Suburb__c,Street__c,State__c,Post_Code__c,Booking_PNR__c,Flight_Number__c,Departure_Date_Time__c,Departure_City__c,Country__c,CaseNumber,Arrival_City__c',csId,auto_case);
            if(returnedErrors != null){
                returnedErrors += dynamicAffectedPassengerQueryBuilder('Flight_Leg_Flown_Statuses__c,Id', csId, auto_case, true);
            }else{
                returnedErrors = dynamicAffectedPassengerQueryBuilder('Flight_Leg_Flown_Statuses__c,Id', csId, auto_case, true);
            }
            System.debug('ReturnedFrom Dynamic QUery'+ returnedErrors);
       }/*else if(groupType == 'Booking Cancelled by Customer' && String.isBlank(refundType)){
            //returnedErrors = dynamicCaseQueryBuilder('Fare_Total__c,Ticket_Number__c,Suburb__c,Street__c,State__c,Refund_Type__c,Refund_Amount__c,Post_Code__c,Booking_PNR__c,Passenger_Last_Name__c,Passenger_First_Name__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,Booking_Change_Fee__c,CaseNumber,Cancellation_Fee__c',csId,auto_case);
            returnedErrors = dynamicCaseQueryBuilder('Suburb__c,Street__c,State__c,Post_Code__c,Booking_PNR__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,CaseNumber',csId,auto_case);
            //QDCUSCON 3550
            if(returnedErrors != null){
                returnedErrors += dynamicAffectedPassengerQueryBuilder('Ticket_Number__c', csId, auto_case, false);
            }else{
                returnedErrors = dynamicAffectedPassengerQueryBuilder('Ticket_Number__c', csId, auto_case, false);
            }
       }*/else if(groupType == 'Booking Cancelled by Customer' && refundType.equalsIgnoreCase('Ticket held in Credit')){
            //returnedErrors = dynamicCaseQueryBuilder('Fare_Total__c,Ticket_Number__c,Suburb__c,Street__c,State__c,Refund_Type__c,Post_Code__c,Booking_PNR__c,Passenger_Last_Name__c,Passenger_First_Name__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,CaseNumber',csId,auto_case);
            returnedErrors = dynamicCaseQueryBuilder('Suburb__c,Street__c,State__c,Refund_Type__c,Post_Code__c,Booking_PNR__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,CaseNumber',csId,auto_case);
            //QDCUSCON 3550
            if(returnedErrors != null){
                returnedErrors += dynamicAffectedPassengerQueryBuilder('Fare_Total__c,Ticket_Number__c', csId, auto_case, false);
            }else{
                returnedErrors = dynamicAffectedPassengerQueryBuilder('Fare_Total__c,Ticket_Number__c', csId, auto_case, false);
            }
            System.debug('ReturnedFrom Dynamic QUery'+ returnedErrors);
            //End QDCUSCON 3550
       }else if(groupType == 'Booking Cancelled by Customer' && refundType == 'Tax only Refund'){
            //returnedErrors = dynamicCaseQueryBuilder('Fare_Total__c,Ticket_Number__c,Suburb__c,Street__c,State__c,Refund_Type__c,Refund_Amount__c,Post_Code__c,Booking_PNR__c,Passenger_Last_Name__c,Passenger_First_Name__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,CaseNumber,Cancelled_Date__c',csId,auto_case);
            returnedErrors = dynamicCaseQueryBuilder('Suburb__c,Street__c,State__c,Refund_Type__c,Post_Code__c,Booking_PNR__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,CaseNumber,Cancelled_Date__c',csId,auto_case);
            //QDCUSCON 3550
            if(returnedErrors != null){
                returnedErrors += dynamicAffectedPassengerQueryBuilder('Fare_Total__c,Ticket_Number__c,Refund_Amount__c', csId, auto_case, false);
            }else{
                returnedErrors = dynamicAffectedPassengerQueryBuilder('Fare_Total__c,Ticket_Number__c,Refund_Amount__c', csId, auto_case, false);
            }
            //End QDCUSCON 3550
       }else if(groupType == 'Booking Cancelled by Customer' && refundType == 'Refunded with Cancellation Policy'){
            //returnedErrors = dynamicCaseQueryBuilder('Fare_Total__c,Ticket_Number__c,Suburb__c,Street__c,State__c,Refund_Type__c,Refund_Amount__c,Post_Code__c,Booking_PNR__c,Passenger_Last_Name__c,Passenger_First_Name__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,Booking_Change_Fee__c,CaseNumber,Cancellation_Fee__c',csId,auto_case);
            returnedErrors = dynamicCaseQueryBuilder('Suburb__c,Street__c,State__c,Refund_Type__c,Post_Code__c,Booking_PNR__c,Ticket_Issue_Date__c,Flight_Segments__c,Country__c,CaseNumber',csId,auto_case);
            //QDCUSCON 3550
            if(returnedErrors != null){
                returnedErrors += dynamicAffectedPassengerQueryBuilder('Fare_Total__c,Ticket_Number__c,Refund_Amount__c,Booking_Change_Fee__c,Cancellation_Fee__c', csId, auto_case, false);
            }else{
                returnedErrors = dynamicAffectedPassengerQueryBuilder('Fare_Total__c,Ticket_Number__c,Refund_Amount__c,Booking_Change_Fee__c,Cancellation_Fee__c', csId, auto_case, false);
            }
            //End QDCUSCON 3550
       }else if(groupType == 'Damaged Baggage'){
            returnedErrors = dynamicCaseQueryBuilder('Street__c,Suburb__c,State__c,Post_Code__c,Country__c,CaseNumber,Arrival_City__c,Arrival_Date_Time__c,Baggage_File_Reference__c',csId,auto_case);
       }else if(groupType == 'Delayed or Lost Baggage'){
            returnedErrors = dynamicCaseQueryBuilder('Departure_City__c,Located_Date__c,Delivery_Date__c,Delivery_Port__c,Street__c,Suburb__c,State__c,Post_Code__c,Country__c,CaseNumber,Departure_Date_Time__c,Arrival_City__c,Arrival_Date_Time__c,Baggage_File_Reference__c',csId,auto_case);
       }else if(groupType == 'Personal Property Lost In-flight'){
            returnedErrors = dynamicCaseQueryBuilder('Booking_PNR__c,Departure_Date_Time__c,Flight_Number__c,Street__c,Suburb__c,State__c,Post_Code__c,Country__c,CaseNumber,Lost_Property_Name__c',csId,auto_case);
       }

        return returnedErrors;
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        dynamicCaseQueryBuilder
    Description:        Checks if the field queried is null
    Parameter:          String, Id<Case>, SObject<Case>
    Return:             String
    ----------------------------------------------------------------------------------------------*/
    public static String dynamicCaseQueryBuilder(String fieldAPI, Id caseRecId,Case caseDetails){
        String caseComments;
        System.debug('### field API - ' + fieldAPI);
        System.debug('### caseRecId - ' + caseRecId);
        System.debug('### caseDetails - ' + caseDetails);
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Case.fields.getMap();
        if(caseRecId != null){
            String theQuery = 'SELECT '+fieldAPI;
            theQuery += ' FROM Case WHERE Id = \''+ caseRecId +'\'';
            caseDetails = Database.query(theQuery);
        }
        
        List<String> f_api_name =  fieldAPI.split(',');
        //String caseComments = '\n The following email template fields have missing data, please update these fields to generate the letter: \n';
        for(String str: f_api_name){
            if(caseDetails.get(str) == null){
                if(str == 'Arrival_Delay_Time_Hours__c' || str == 'Arrival_Delay_Time_Mins__c') {
                    if(caseDetails.get('Actual_Arrival_Date_Time__c') != null && caseDetails.get('Arrival_Date_Time__c') != null) {
                        continue;
                    }
                }
                if(str == 'Rebooked_Flight_Delay_Mins__c' || str == 'Rebooked_Flight_Delay_Hours__c') {
                    if(caseDetails.get('Rebooked_Flight_Actual_Arrival_Date_Time__c') != null && caseDetails.get('Arrival_Date_Time__c') != null) {
                        continue;
                    }
                }
                if(str == 'Departure_Delay_Time_Hours__c' || str == 'Departure_Delay_Time_Mins__c') {
                    if(caseDetails.get('Actual_Departure_Date_Time__c') != null && caseDetails.get('Departure_Date_Time__c') != null) {
                        continue;
                    }
                }
                
                if(caseComments != null){
                    caseComments = caseComments + fldObjMap.get(str).getDescribe().getLabel() + '\n';
                } else {
                    caseComments = fldObjMap.get(str).getDescribe().getLabel() + '\n';
                }   
            }
        }
        
        return caseComments;
    }
   
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchSalesforceEmailTemplateId
    Description:        Fetches the salesforce email template Id depend on Case information and Email template name
    Parameter:          object of Case
                        name of selected email tempalte
    --------------------------------------------------------------------------------------*/    
    @AuraEnabled        
    public static List<String> fetchSalesforceEmailTemplateId(Case caseObj, String emailTemplateName){
        List<QCC_Email_Template_Setting__mdt> sfEmailTempList;
        List<String> execeptionalOption = new List<String>{'Complaint Template', 'Insurance Letter'};
        if(execeptionalOption.contains(emailTemplateName)){
            // Modified by Purushotham -- Start
            if(caseObj.Type == CustomSettingsUtilities.getConfigDataMap('Case Further Action Required Type') || caseObj.Type == CustomSettingsUtilities.getConfigDataMap('Case Complaint Type')){
                sfEmailTempList = [Select Id, EmailTemplateName__c, TemplateGroup__c, AutoCloseCase__c from QCC_Email_Template_Setting__mdt where Type__c = 'Complaint' AND Group__c =: caseObj.Group__c AND Category__c =: caseObj.Category__c AND  SubCategory__c =: caseObj.Sub_Category__c AND Classification__c =: caseObj.Classification__c AND TemplateOption__c =: emailTemplateName Limit 1]; 
            } else if(caseObj.Type == CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type')) {
                sfEmailTempList = [Select Id, EmailTemplateName__c, TemplateGroup__c, AutoCloseCase__c from QCC_Email_Template_Setting__mdt where Type__c =: caseObj.Type AND Group__c =: caseObj.Group__c AND Category__c =: caseObj.Refund_Type__c Limit 1];
            }
            // Modified by Purushotham -- End
        }else{
            sfEmailTempList = [Select Id, EmailTemplateName__c, TemplateGroup__c, AutoCloseCase__c from QCC_Email_Template_Setting__mdt where EmailTemplateName__c =: emailTemplateName Limit 1];
        }
        
        if(sfEmailTempList.size() > 0){
            // Modified by Purushotham
            String emailTempName = '%' + sfEmailTempList.get(0).EmailTemplateName__c + '%';
            /*if(sfEmailTempList.get(0).EmailTemplateName__c.contains('QCC Digital Lounge Pass')){
                emailTempName = '%QCC Digital Lounge Pass%';
                isLoungePass = 'true';
            }*/
            system.debug('##### emailTempName' + emailTempName);
            system.debug('##### TemplateGroup' + sfEmailTempList.get(0).TemplateGroup__c);
            List<APXTConga4__Conga_Template__c> congaTemplateList = [Select Id, APXTConga4__Name__c, Email_Template_Name__c, APXTConga4__Template_Group__c, APXTConga4__Template_Type__c from APXTConga4__Conga_Template__c where Email_Template_Name__c like: emailTempName AND APXTConga4__Template_Group__c =: sfEmailTempList.get(0).TemplateGroup__c];          
            
            //QDCUSCON 3633, 3705
            String autoCloseCase = 'false';           
            Boolean isAutoCloseCase = isAutoCloseCase(caseObj.id);
            String recoveryInprogress = isAutoCloseCase ? 'false' : 'true';
            if(isAutoCloseCase){
                //check AutoCloseCase condition in Email Template
                autoCloseCase = String.valueOf(sfEmailTempList.get(0).AutoCloseCase__c);
            }
            //end QDCUSCON 3633, 3705
            String sfEmailTemplateId = QCC_GenericUtils.fetchSalesforceEmailTemplate(sfEmailTempList.get(0).EmailTemplateName__c);
            if(congaTemplateList.size() > 0){
                System.debug('#############congaTemplate' + congaTemplateList.get(0).Id);
                return new List<String>{sfEmailTemplateId, congaTemplateList.get(0).Id, autoCloseCase, recoveryInprogress};
            }else{
                return new List<String>{sfEmailTemplateId, '', autoCloseCase, recoveryInprogress};
            }
        }

        return null;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchEmailTemplateValues
    Description:        Fetches the email templates depend on Case record type
    Parameter:          record type name of Case
    --------------------------------------------------------------------------------------*/  
    @AuraEnabled        
    public static List<WrapperEmailTemplate> fetchEmailTemplateValues(String caseRecordType, String caseId){
        //

        system.debug('#######caseRecordType#########' + caseRecordType); 
        List<WrapperEmailTemplate> wrapperEmailTemps = new List<WrapperEmailTemplate>();
        if(caseRecordType != 'CCC Event'){ //Fixed QDCUSCON-4912
        List<Recovery__c> listRecoveryLoungePasses = [SELECT Id, Type__c, Status__c 
                                                        FROM Recovery__c 
                                                        WHERE (Type__c =: CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes')
                                                        OR Type__c=: CustomSettingsUtilities.getConfigDataMap('Recovery IB Lounge Passes'))
                                                        AND Case_Number__c =: caseId AND RecordType.DeveloperName='Customer_Connect'];
        
        if(!listRecoveryLoungePasses.isEmpty()){
            Case currentCase = [SELECT Id, ContactId, Contact.Frequent_Flyer_Number__c, Status FROM Case WHERE Id =: caseId];
            Set<String> recoveryStatus = new Set<String>();
            for(Recovery__c objRecovery : listRecoveryLoungePasses){
                recoveryStatus.add(objRecovery.Status__c);
            }
            if(currentCase.ContactId != null
                && !String.isBlank(currentCase.Contact.Frequent_Flyer_Number__c)
                && (recoveryStatus.contains(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusProcessing'))
                    || recoveryStatus.contains(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved'))
                    || recoveryStatus.contains(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised')))){
                
                wrapperEmailTemps.add(new WrapperEmailTemplate('Digital Lounge Pass - Frequent Flyer', 'QCC Digital Lounge Pass - Frequent Flyer'));
                

            }else if(recoveryStatus.contains(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusAwaitingCustomer'))){
                wrapperEmailTemps.add(new WrapperEmailTemplate('Digital Lounge Pass - Non Frequent Flyer', 'QCC Digital Lounge Pass - Non Frequent Flyer')); 
            }
        }
        }

        List<QCC_EmailTemplateMapping__mdt> emailTempMappingList = [Select Id, name__c, Email_Templates__c, Conga_Email_Templates__c from QCC_EmailTemplateMapping__mdt where name__c =: caseRecordType limit 1]; 

        system.debug('#######emailTempMappingList#########' + emailTempMappingList); 
        if(emailTempMappingList.size() > 0){
            String emailTemplates = emailTempMappingList.get(0).Email_Templates__c;
            String congaEmailTemplates = emailTempMappingList.get(0).Conga_Email_Templates__c;
            List<String> emailTempList = emailTemplates.split(',');  
            List<String> congaEmailTempList = congaEmailTemplates.split(','); 
            if(emailTempList.size() == congaEmailTempList.size()){
                for(Integer i = 0; i < emailTempList.size(); i++){
                    wrapperEmailTemps.add(new WrapperEmailTemplate(emailTempList.get(i), congaEmailTempList.get(i)));
                }
            }
        }
        system.debug('#######wrapperEmailTemps#########' + wrapperEmailTemps);
        if(caseRecordType != 'CCC Event'){ //Fixed QDCUSCON-4912
        List<String> recTypes = new List<String>();//{'EFT Refund','Credit Card Refund'};
        recTypes.addAll(CustomSettingsUtilities.getConfigDataMap('Recovery Templates').split(','));
        String recStatus = CustomSettingsUtilities.getConfigDataMap('CC/EFT Refund Status');
        String qantasPoints = CustomSettingsUtilities.getConfigDataMap('Qantas Points Type');
        List<Case> caseObj = [SELECT Id, (SELECT Id, Type__c FROM Recoveries_Case__r WHERE (Type__c IN :recTypes and Status__c =: recStatus) OR (Type__c =: qantasPoints AND Status__c = 'Awaiting Customer Response')) FROM Case WHERE Id =: caseId];
        System.debug(LoggingLevel.ERROR, 'caseObj[0] ===> ' + caseObj[0]);
        System.debug(LoggingLevel.ERROR, 'caseObj[0].Recoveries_Case__r ===> ' + caseObj[0].Recoveries_Case__r);
        if(caseObj[0].Recoveries_Case__r != null && caseObj[0].Recoveries_Case__r.size() > 0) {
            System.debug('Reached Here!!!!!');
            Boolean isAdded = false;
            Boolean isCCEFTAdded = false;
            for(Recovery__c rec: caseObj[0].Recoveries_Case__r) {
                if(rec.Type__c == qantasPoints && !isAdded) {
                    wrapperEmailTemps.add(new WrapperEmailTemplate('Qantas Points Sign Up', 'QCC_FF Sign Up'));
                    isAdded = true;
                } else if(rec.Type__c != qantasPoints && !isCCEFTAdded) {
                    wrapperEmailTemps.add(new WrapperEmailTemplate('CC Refund Approval and EFT Approval', 'QCC_CC Refund/EFT Approval'));
                    isCCEFTAdded = true;
                    }
                }
            }
        }
        wrapperEmailTemps.sort();
        return wrapperEmailTemps;
    }

     /*--------------------------------------------------------------------------------------      
    Method Name:        isAutoCloseCase
    Description:        Check if Case will be automatically closed or not which depending on status of Recovery
    Parameter:          Id of Case
    --------------------------------------------------------------------------------------*/  
    @AuraEnabled        
    public static Boolean isAutoCloseCase(String caseId){
        //List<Recovery__c> recoveries = [SELECT Id, Case_Number__r.id, Status__c FROM Recovery__c where Case_Number__r.id =: caseId AND (Status__c= 'Awaiting Approval' OR Status__c = 'Rejected') Limit 2];
        AggregateResult[] ARs = [SELECT count(Id) myCount, Status__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect' AND Case_Number__r.id =: caseId GROUP BY Status__c];
        Integer totalRejected = 0;
        Integer totalAwaitingApproval = 0;
        Integer totalOthers = 0;
        for(AggregateResult ar : ARs){
            if(ar.get('Status__c') == 'Rejected'){
                totalRejected = (Integer) ar.get('myCount'); 
            }else if(ar.get('Status__c') == 'Awaiting Approval'){
                totalAwaitingApproval = (Integer) ar.get('myCount');
            }else{
                totalOthers += (Integer) ar.get('myCount');
            }
        }
        Boolean isAutoCloseCase = true;
        if(totalAwaitingApproval > 0){
            isAutoCloseCase = false;
        }else if(totalRejected == 1 && totalOthers == 0){
            isAutoCloseCase = false;
        }
        return isAutoCloseCase;
    }

    public class WrapperEmailTemplate implements Comparable{
        public WrapperEmailTemplate(String emailTemp, String congaEmailTemp){
            emailTemplate = emailTemp;
            congaEmailTemplate = congaEmailTemp;
        }
        
        @AuraEnabled
        public String emailTemplate {get;set;}
        @AuraEnabled
        public String congaEmailTemplate {get;set;}

        public Integer compareTo(Object ObjToCompare) {
            return emailTemplate.CompareTo(((WrapperEmailTemplate)ObjToCompare).emailTemplate);
        }

    }

    private static String congaQueryAffectedPassenger = null;
    /*----------------------------------------------------------------------------------------------      
    Method Name:        getCongaQueryAffectedPassenger
    Description:        Gets conga query Id of QCC Affected Passenger For Insurance Letter
    Return:             conga query Id
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public  static String getCongaQueryAffectedPassenger() {
        if(congaQueryAffectedPassenger == null){       
            String congaQueryName = CustomSettingsUtilities.getConfigDataMap('QCC Affected Passenger Query');
            List<APXTConga4__Conga_Merge_Query__c> congaQueries = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c =: congaQueryName limit 1];
            congaQueryAffectedPassenger = congaQueries[0].Id;
        }
        return congaQueryAffectedPassenger;
    }


    /*----------------------------------------------------------------------------------------------      
    Method Name:        dynamicAffectedPassengerQueryBuilder
    Description:        Checks if the field queried is null and follow business rule of Insurance Letter
    Parameter:          String, Id<Case>, Case, Boolean
    Return:             String
    ----------------------------------------------------------------------------------------------*/
    @TestVisible 
    private static String dynamicAffectedPassengerQueryBuilder(String fieldAPI, Id caseRecId, Case cs, Boolean isPBNS){
        System.debug('### field API - ' + fieldAPI);
        System.debug('### caseRecId - ' + caseRecId);
        System.debug('### case - ' + cs);
        System.debug('### isPBNS - ' + isPBNS);
        System.debug('@@@@dynamicAffectedPassengerQueryBuilder=');
        String passengerComment;
        String error;
        String messages = '';
        List<Affected_Passenger__c> affectedPassengers;
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Affected_Passenger__c.fields.getMap();
        if(caseRecId == null) {
            caseRecId = cs.Id;
        }
        if(caseRecId != null){           
            String theQuery = 'SELECT Name, Is_Qantas_Issued_Ticket__c, Issued_by_TravelAgent__c, ' + fieldAPI;
            theQuery += ' FROM Affected_Passenger__c WHERE case__c = \''+ caseRecId +'\'';
            affectedPassengers = Database.query(theQuery);
            List<String> f_api_name =  fieldAPI.split(',');
            //String passengerComments = '\n The following email template fields have missing data, please update these fields to generate the letter: \n';
            if(affectedPassengers.size() == 0){
               messages = 'There is no passengers associated to the case, please \'Add passengers\''; 
            }
            for(Affected_Passenger__c passenger : affectedPassengers){
                error = null;
                passengerComment = null;
                if(!isPBNS) {
                    if(passenger.Is_Qantas_Issued_Ticket__c == false){
                        return 'Ineligible';
                        //error = '\n The following business rules have not passed for the requested Insurance Letter:';
                        //error = error + '\n ' + passenger.Name + '\'s ticket is not a Qantas issued ticket.\n';
                    }
                    if(passenger.Issued_by_TravelAgent__c == true){
                        if(error != null){
                            error = error + '\n ' + passenger.Name + '\'s ticket was booked by a travel agent.\n';
                        }else{
                            error = '\n The following business rules have not passed for the requested Insurance Letter:';
                            error = error + '\n ' + passenger.Name + '\'s ticket was booked by a travel agent.\n';
                        }
                    }
                }
                
                for(String str: f_api_name){
                    if(passenger.get(str) == null){               
                        if(passengerComment != null){
                            passengerComment = passengerComment + passenger.Name + ' ' + fldObjMap.get(str).getDescribe().getLabel() + '\n';
                        } else {
                            passengerComment = passenger.Name + ' ' + fldObjMap.get(str).getDescribe().getLabel() + '\n';
                        }   
                    }
                }
               
                if(error != null){
                    messages += error;  
                }
                if(passengerComment != null){
                    if(!isPBNS) {
                        passengerComment = '\n The following email template fields have missing data, please update these fields to generate the letter: \n' + passengerComment;
                    }
                    messages += passengerComment;
                }                    
            }
        }     
        System.debug('@@@@messages=' + messages);
        return messages;   
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        hasCaseAffectedPassenger
    Description:        Checks if there's any Passenger for Case
    Parameter:          String
    Return:             Boolean
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean hasCaseAffectedPassenger(String caseRecId){
        Case objCase = [select Id, Origin from case where id =: caseRecId];
        
        return ([select Count() from Affected_Passenger__c Where case__c=:caseRecId limit 1]) > 0;   
    }
}