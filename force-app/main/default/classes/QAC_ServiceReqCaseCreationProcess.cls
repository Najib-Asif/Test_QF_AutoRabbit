/*
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Purpose : to create the service request case records & its child records
 * REST API : QAC_ServiceReqCaseCreationAPI
 * Comments : This class is @RestResource due that our class access 
               modifier is global and with sharing already annotated ADDED COMMENTS due JIRA-5510
 * TestClasses: QAC_ServiceReqCaseCreationProcess_Test
  History
************************************************************************************************
13-Feb-2025      Gandla Mallikarjuna               CRM-9196 Included EMD Details for Seats And Baggage Service Request

*/

@RestResource(urlMapping='/QAC_ServReqCaseCreation/')
global with sharing class QAC_ServiceReqCaseCreationProcess 
{
    public static String responseJSON = '';
    public static String findObject = '';
    public static String waivCombo = '';
    public static Boolean paxSeq = false;
    public static Case myCase;
    public static Map<String,SObject> allPaymentResponses;
    public static Account existingAccount;
    
    @HttpPost
    global static void doServReqCaseCreation()
    {
        // All Responses from Salesforce after processing
        QAC_CaseResponses qacResp = new QAC_CaseResponses();
        QAC_CaseResponses.QACCaseCreationResponse myCaseCreationResp;
        QAC_CaseResponses.PassengerResponse myPassengerResp;
        QAC_CaseResponses.FlightResponse myFlightResp;
        QAC_CaseResponses.ExceptionResponse myExcepResp;
        QAC_CaseResponses.WorkOrderResponse myWOResp;
        QAC_CaseResponses.WorkOrderLineItemResponse myWOLIResp;
        QAC_CaseResponses.ServicePaymentResponse mySPayResp;
        
        // some object responses are returned as lists after processing
        list<QAC_CaseResponses.PassengerResponse> myPassengerRespList = new list<QAC_CaseResponses.PassengerResponse>();
        list<QAC_CaseResponses.FlightResponse> myFlightRespList = new list<QAC_CaseResponses.FlightResponse>();
        list<QAC_CaseResponses.CaseCommentResponse> myCCRespList = new list<QAC_CaseResponses.CaseCommentResponse>();
        list<QAC_CaseResponses.EMDDetailsResponse> myEMDRespList = new list<QAC_CaseResponses.EMDDetailsResponse>();

        
        // local variables for business logic
        String receivedReq;
        String jsonErrMessage;
        Boolean isException = false;
        Integer i = 0;
        Case createdCase;
        list<Flight__c> newFlightsList = new list<Flight__c>();
        list<Affected_Passenger__c> newPassengersList = new list<Affected_Passenger__c>();
        list<CaseComment> newCommentsList = new list<CaseComment>();
        list<EMD_Details__c> newEMDDetailsList = new list<EMD_Details__c>(); //Jira: CRM-9209
        
        // Getting REST JSON from Request and setting to Response codes
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        receivedReq = req.requestBody.toString();
        
        try
        {
            system.debug(' @@ request 1 @@' +receivedReq);
            
            // to convert the received String into object
            QAC_ServiceReqCaseCreationAPI caseApi = QAC_ServiceReqCaseCreationAPI.parse(receivedReq);
            QAC_ServiceReqCaseCreationAPI.FareDetails caseRecFare;
                
            // null check on all the valid object entries of JSON
            if(caseApi.serviceRequest != null)
            {
                // caseRecServReq is the instance of case record details received from JSON
                QAC_ServiceReqCaseCreationAPI.ServiceRequest caseRecServReq = caseApi.serviceRequest;
                
                // caseRecAgencyIdentity is the instance of case record details received from JSON for Agency Identification Section
                QAC_ServiceReqCaseCreationAPI.AgencyIdentification caseRecAgencyIdentity = caseApi.serviceRequest.agencyIdentification;
                
                // caseRecBookRef is the instance of case record details received from JSON for Booking Reference Section
                QAC_ServiceReqCaseCreationAPI.BookingDetails caseRecBookRef = caseApi.serviceRequest.bookingDetails;
                
                // caseRecFare is the instance of case record details received from JSON for Fare Section
                if(caseApi.serviceRequest.fareDetails != null)
                    caseRecFare = caseApi.serviceRequest.fareDetails;
                
                createdCase = doCaseCreation(caseRecServReq,caseRecAgencyIdentity,caseRecBookRef,caseRecFare);
                findObject = 'Case';
                
                // send case response
                insert createdCase;
                system.debug('** createdCase **'+createdCase);
                if(createdCase.Id != null){
                    res.statusCode = 201;
                    
                    myCase = fetchCase(createdCase.Id);
                    myCaseCreationResp = new QAC_CaseResponses.QACCaseCreationResponse('201','Case Created Successfully',myCase);
                    qacResp.serviceRequestCreateResponse = myCaseCreationResp;

                    if (caseApi.serviceRequest.agencyClassifications != null && !caseApi.serviceRequest.agencyClassifications.isEmpty()) {
                        doAgencyClassificationCreation(caseApi.serviceRequest.agencyClassifications, createdCase);
                    }
                    
                    // Flights record creation
                    if(caseApi.serviceRequest.flights != null)
                    {
                        for(QAC_ServiceReqCaseCreationAPI.Flights flightRecResp : caseApi.serviceRequest.flights){
                            if(flightRecResp != null) {
                                newFlightsList.add(doFlightCreation(flightRecResp,createdCase));
                            }
                        }
                        if(!newFlightsList.isEmpty())
                        {
                            findObject = 'Flights';   
                            insert newFlightsList;
                            
                            for(Flight__c eachFlight : newFlightsList){
                                ++i;
                                if(eachFlight.Id != null){
                                    
                                    res.statusCode = 201;
                                    myFlightResp = new QAC_CaseResponses.FlightResponse('201',i+' Flight record(s) Created Successfully',
                                                                                    eachFlight.Id);
                                    myFlightRespList.add(myFlightResp);
                                }
                            }
                            i=0;
                            qacResp.flightResponses = myFlightRespList;
                        }
                    }
                    
                    // Passengers record creation
                    if(caseApi.serviceRequest.passengers != null)
                    {
                        for(QAC_ServiceReqCaseCreationAPI.Passengers passengerRecResp : caseApi.serviceRequest.passengers){
                            if(passengerRecResp != null) {
                                newPassengersList.add(doPassengerCreation(passengerRecResp,createdCase));
                            }
                        }
                        if(!newPassengersList.isEmpty())
                        {
                            findObject = 'Passengers';   
                            insert newPassengersList;
                            for(Affected_Passenger__c eachPassenger : newPassengersList){
                                ++i;
                                if(eachPassenger.Id != null){

                                    paxSeq = true;
                                    res.statusCode = 201;
                                    myPassengerResp = new QAC_CaseResponses.PassengerResponse('201',i+' Passenger record(s) Created Successfully',
                                                                                          eachPassenger.Id);
                                    myPassengerRespList.add(myPassengerResp);
                                }
                            }
                            i=0;
                            qacResp.passengerResponses = myPassengerRespList;
                        }
                    }
                    
                    // do work order, work order line item, service payment record creation
                    if(createdCase.Paid_Service__c){
                        findObject = 'Payment Objects';
                        allPaymentResponses = new Map<String,SObject>(QAC_PaymentsProcess.doPaymentsCreation(waivCombo,system.now(),createdCase,paxSeq));
                        
                        if(!allPaymentResponses.isEmpty()){
                            for(String eachPayResp : allPaymentResponses.keySet())
                            {
                                if(eachPayResp.split('_')[1] == 'WO'){
                                    // WO Response
                                    res.statusCode = 201;
                                    myWOResp = new QAC_CaseResponses.WorkOrderResponse('201','Work Order Created Successfully',eachPayResp.split('_')[0]);
                                    qacResp.workOrderResponse = myWOResp;
                                }    
                                else if(eachPayResp.split('_')[1] == 'WOLI'){
                                    // WOLI Response
                                    res.statusCode = 201;
                                    myWOLIResp = new QAC_CaseResponses.WorkOrderLineItemResponse('201','Work Order Line Item Created Successfully',eachPayResp.split('_')[0]);
                                    qacResp.workOrderLineItemResponse = myWOLIResp;
                                }    
                                else if(eachPayResp.split('_')[1] == 'SP'){
                                    // SP Response
                                    res.statusCode = 201;
                                    Service_Payment__c spObj = (Service_Payment__c) allPaymentResponses.get(eachPayResp);
                                    system.debug('spObj**'+spObj);
                                    mySPayResp = new QAC_CaseResponses.ServicePaymentResponse('201','Service Payment Created Successfully',spObj);
                                    qacResp.servicePaymentResponse = mySPayResp;
                                }    
                            }
                        }
                    }

                    // Case Comments record creation
                    if(caseApi.serviceRequest.comments != null)
                    {
                        for(QAC_ServiceReqCaseCreationAPI.Comments commentsRecResp : caseApi.serviceRequest.comments){
                            if(commentsRecResp != null) {
                                newCommentsList.add(doCaseCommentsCreation(commentsRecResp,createdCase));
                            }
                        }
                        if(!newCommentsList.isEmpty())
                        {
                            findObject = 'Case Comments';   
                            insert newCommentsList;
                            for(CaseComment eachComment : newCommentsList){
                                ++i;
                                if(eachComment.Id != null){
                                    
                                    res.statusCode = 201;
                                    myCCRespList.add(new QAC_CaseResponses.CaseCommentResponse('201',i+' Case Comment record(s) Created Successfully'));
                                }
                            }
                            i=0;
                            qacResp.commentResponses = myCCRespList;
                        }
                    }

                    //Jira: CRM-9209 Emd Details record creation
                    if (caseApi.serviceRequest?.bookingDetails?.emdDetails != null)
                    {
                        for(QAC_ServiceReqCaseCreationAPI.EMDDetails emdDetailsRecResp : caseApi.serviceRequest.bookingDetails.emdDetails){
                            if(emdDetailsRecResp != null) {
                                newEMDDetailsList.add(doEMDDetailsCreation(emdDetailsRecResp, createdCase));
                            }
                        }
                        if (!newEMDDetailsList.isEmpty()) {
                            findObject = 'EMD Details'; 
                            insert newEMDDetailsList;

                            for(EMD_Details__c eachEMDDetail : newEMDDetailsList){
                                ++i;
                                if(eachEMDDetail.Id != null){
                                    res.statusCode = 201;
                                    myEMDRespList.add(new QAC_CaseResponses.EMDDetailsResponse('201',i+' EMD Detail record(s) Created Successfully', eachEMDDetail.Id));
                                }
                            }
                            i=0;
                            qacResp.emdDetailsResponses = myEMDRespList;
                        }

                    }
                }
                
                responseJson += JSON.serializePretty(qacResp,true);
                res.responseBody = Blob.valueOf(responseJson);
            }            
        }
        catch(Exception ex)
        {
            // if exception found, update Logs for Exception details
            system.debug('Exception we got'+ex);
            isException = true;
            res.statusCode = 500;   
            
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Tradesite - QAC_ServiceReqCaseCreationProcess', 'QAC_ServiceReqCaseCreationProcess',
                                    'doServReqCaseCreation', (receivedReq.length() > 32768) ? receivedReq.substring(0,32767) : receivedReq, String.valueOf(''), true,'', ex);
            
            String sfErrMessage = ex.getMessage();
            
            if(ex.getMessage().contains(':')){
                sfErrMessage = ex.getMessage().substringAfter(':');
            }
            
            // exception response for JSON and Non JSON Exceptions
            if(ex.getTypeName().contains('JSON')){
                res.statusCode = 400;
                jsonErrMessage = 'Issue with JSON Format. Please check your Payload';
            }
            else{
                jsonErrMessage = 'Found errors.Please contact Salesforce.';
                jsonErrMessage += (String.isNotBlank(findObject)) ? 'Creation Process Failed for - '+findObject : 'Creation Failed.';
            }
            
            myExcepResp = new QAC_CaseResponses.ExceptionResponse(String.valueOf(res.statusCode),jsonErrMessage,
                                                              'Exception Found',sfErrMessage);
            qacResp.exceptionResponse = myExcepResp;
            
            // create case for exception response as well
            system.debug('QAC Response**'+qacResp);
            responseJson += JSON.serializePretty(qacResp,true);
            res.responseBody = Blob.valueOf(responseJson);
            
        }
        finally{
            // if no exception found, update Logs for Integration details
            if(!isException){
                CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC Tradesite - QAC_ServiceReqCaseCreationProcess', 'QAC_ServiceReqCaseCreationProcess',
                                        'doServReqCaseCreation',(receivedReq.length() > 32768) ? receivedReq.substring(0,32767) : receivedReq, String.valueOf(''), true,'', null);
            }
        }
        res.addHeader('Content-Type', 'application/json');                       //CIAM
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        doCaseCreation
    Description:        Method for Creating Case Record
    Parameter:          QAC_ServiceReqCaseCreationAPI - Service Request, Agency Identification,
                                                        Booking Reference, Fare
    --------------------------------------------------------------------------------------*/
    public static Case doCaseCreation(QAC_ServiceReqCaseCreationAPI.ServiceRequest myServReq, QAC_ServiceReqCaseCreationAPI.AgencyIdentification myAgenIden, QAC_ServiceReqCaseCreationAPI.BookingDetails myBookRef, QAC_ServiceReqCaseCreationAPI.FareDetails myFare)
    {
        Case newCase = new Case();
        // Changes Start: CRM-7538
        List<Object> fldMappings = getMetadataFieldMappings('QAC_ServReqCaseCreation', myServReq.requestOrigin);
        if (fldMappings == null ) return null;
        Object payload = (Object)JSON.deserializeUntyped(JSON.serialize(myServReq));
        for (Object fldMapping : fldMappings) {
            Map<String,Object> fldMappingEntry = (Map<String,Object>)fldMapping;
            
            Object value = String.isNotBlank((String)fldMappingEntry.get('RequestParam')) ? getAttributeValue((String)fldMappingEntry.get('RequestParam'), payload) : (String)fldMappingEntry.get('Value');
            if ((String)fldMappingEntry.get('type') == 'RecordTypeName') value = Schema.SObjectType.Case.getRecordTypeInfosByName().get(String.valueOf(value)).getRecordTypeId();
            if (value != null) newCase.put((String)fldMappingEntry.get('FieldAPI'), typeCastData(value, (String)fldMappingEntry.get('type')));
        }
        //Changes End: CRM-7538
        myCase = fetchCase(myServReq.parentRequest);
        //String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId(); //Commented as a part of CRM-7538

        // Agency Identification	
		existingAccount = fetchAccount(myAgenIden.agencyReference);
        newCase.AccountId = (existingAccount != null) ? existingAccount.Id : null;
        newCase.ParentId = (myCase != null) ? myCase.Id : null;

        if (String.isNotBlank(myAgenIden?.agentPingId)) {                       //CIAM - Block Added
            newCase.Contact = new Contact(PING_ID__c = myAgenIden.agentPingId);
        }
        
        /* Commented as a part of CRM-7538
        newCase.Consultants_Name__c = myAgenIden.agentName;
        newCase.Consultant_Email__c = myAgenIden.agentEmail;
        newCase.Consultant_Phone__c = myAgenIden.agentPhone;
        
        newCase.Subject = myServReq.subject;
        newCase.Description = myServReq.description;
        newCase.Status = myServReq.requestStatus;

        // Service Request
        newCase.RecordTypeId = caseRTId;
        newCase.External_System_Reference_Id__c = myServReq.correlationId;
        newCase.QAC_Request_Country__c = myServReq.requestCountryCode;
        newCase.Type = myServReq.requestType;
        newCase.Origin = myServReq.requestOrigin;
        newCase.Problem_Type__c = myServReq.requestSubType1;
        newCase.Waiver_Sub_Type__c = myServReq.requestSubType2;
        newCase.Remark_Category__c = myServReq.remarkCategory;
        newCase.Total_Attachments__c = String.isNotBlank(myServReq.totalAttachments) ? Decimal.valueOf(myServReq.totalAttachments) : null;
        newCase.Reason_for_Waiver__c = myServReq.requestReason;
        newCase.Request_Reason_Sub_Type__c = myServReq.requestReasonSubType;
        newCase.Request_Reason_Others__c = myServReq.otherReason;
        newCase.Authority_Status__c = myServReq.authorityStatus;
        newCase.Additional_Requirements__c = myServReq.additionalRequirements;
        newCase.Justification__c = 'Not Applicable';
        newCase.Created_From_Website__c = 'QAC';*/
        
		String billCountry = (existingAccount != null) ? existingAccount.BillingCountry : 'AU';
		String cosAPI = getWDMDTField(billCountry);

        if(myServReq.isoCurrency != null)
            newCase.CurrencyIsoCode = myServReq.isoCurrency; 
		else{
			newCase.CurrencyIsoCode = (cosAPI?.substringBetween('Sale_','__')==null) ? 'AUD' : cosAPI.substringBetween('Sale_','__');
		}
			
        Map<String,QAC_Waiver_Default__mdt> waiverMap = getWDData(myServReq.requestSubType1,myServReq.requestSubType2,billCountry);
        if(!waiverMap.isEmpty()){
            waivCombo = myServReq.requestSubType1 + '_' + myServReq.requestSubType2;
            newCase.Cost_of_Sale__c = String.isNotBlank(myServReq?.costOfSale) ? Decimal.valueOf(myServReq.costOfSale) : Double.valueOf(waiverMap?.get(waivCombo)?.get(cosAPI));
            newCase.Approve__c = waiverMap.get(waivCombo)?.Approve__c;
            newCase.Paid_Service__c = waiverMap.get(waivCombo)?.Paid_Service__c;
            newCase.Condition_Met__c = waiverMap.get(waivCombo)?.Condition_Met__c;
        }
        if(myServReq.requestOrigin!='NDC'){
            newCase.GDS_DI__c = QAC_CaseMappingUtility.fetchGDSValues(myBookRef?.gds);
        }											//CRM-7538: Added safe navigation operator
        newCase.Customer_Tier__c = QAC_CaseMappingUtility.fetchCustomerTierValues(myBookRef?.highestFrequentFlyerTier);		//CRM-7538: Added safe navigation operator
        
        /* Commented as a part of CRM-7538
        // Booking Reference
        newCase.PNR_number__c = myBookRef.bookingReference;
        newCase.Old_PNR_Number__c = myBookRef.oldBookingReference;
        newCase.Passenger_Name__c = myBookRef.surname;
        newCase.Ticket_Number__c = myBookRef.ticketNumber;
        newCase.EMD_Number__c = myBookRef.emdNumber;
        newCase.IATA__c = myBookRef.bookingAgencyreference;
        newCase.PCC_DI__c = myBookRef.pseudoCityCode;
        newCase.GDS_DI__c = QAC_CaseMappingUtility.fetchGDSValues(myBookRef.gds);
        newCase.Point_Of_Sale__c = myBookRef.pointOfSale;
        newCase.ABN_Tax_Reference__c = myBookRef.abn;
        newCase.Qantas_Corporate_Identifier__c = myBookRef.qantasCorporateIdentifier;
        newCase.Number_of_Passengers__c = String.isNotBlank(myBookRef.numberOfPassengers) ? Decimal.valueOf(myBookRef.numberOfPassengers) : null;
        newCase.Travel_Type__c = myBookRef.travelType;
        newCase.First_Flight_Date__c = String.isNotBlank(myBookRef.nextTravelDate) ? Date.valueOf(myBookRef.nextTravelDate) : null;
        newCase.Waiver_Date__c = String.isNotBlank(myBookRef.waiverDate) ? Date.valueOf(myBookRef.waiverDate) : null;
        newCase.GDS_Job_Reference__c = myBookRef.gdsJobReference;
        newCase.Ticketing_Time_Limit__c = String.isNotBlank(myBookRef.ticketingTimeLimit) ? Date.valueOf(myBookRef.ticketingTimeLimit) : null;
        newCase.Customer_Tier__c = QAC_CaseMappingUtility.fetchCustomerTierValues(myBookRef.highestFrequentFlyerTier);
        newCase.Frequent_Flyer_Number__c = myBookRef.FrequentFlyerReference;
        newCase.Fare_basis_value__c = myBookRef.fareBasis;
        
        // Fare
        if(myFare != null){
            newCase.Fare_Type__c = myFare.fareType;
            newCase.Private_Fare_Basis__c = myFare.privateFareCode;
            newCase.Region_Code__c = myFare.regionCode;
        }
        */
        return newCase;
    }

    /*--------------------------------------------------------------------------------------     
    Method Name:        doAgencyClassificationCreation
    Description:        Method for upserting Account Classification
    Parameter:          QAC_ServiceReqCaseCreationAPI - Agency Classification, myCase
    --------------------------------------------------------------------------------------*/
    public static void doAgencyClassificationCreation(List<QAC_ServiceReqCaseCreationAPI.AgencyClassification> agencyClassifications, Case myCase) {
        Map<String, Account_Classifications__c> newAccountClassificationsMap = new Map<String, Account_Classifications__c>();
        Id recTypeId = Schema.SObjectType.Account_Classifications__c.getRecordTypeInfosByDeveloperName().get('Account_Classifications').getRecordTypeId();
        for(QAC_ServiceReqCaseCreationAPI.AgencyClassification agencyClassification : agencyClassifications){
            if (String.isNotBlank(agencyClassification.type)) {
                Account_Classifications__c newAccountClassification = new Account_Classifications__c();
                newAccountClassification.Account__c = myCase.AccountId;
                newAccountClassification.RecordTypeId = recTypeId;
                newAccountClassification.Classification__c = agencyClassification.type;
                newAccountClassification.Sub_Classification__c = agencyClassification.subType;
                newAccountClassificationsMap.put(newAccountClassification.Classification__c, newAccountClassification);
            }
        }
        if (!newAccountClassificationsMap.isEmpty()) {
            for (Account_Classifications__c naccClassRec : [select id, Classification__c from Account_Classifications__c where Account__c = :myCase.AccountId and 
                                                                                    RecordTypeId = :recTypeId and 
                                                                                    Classification__c in :newAccountClassificationsMap.keySet()]) {
                newAccountClassificationsMap.remove(naccClassRec.Classification__c);
            }
        }
        if(!newAccountClassificationsMap.isEmpty()) {
            insert newAccountClassificationsMap.values();
        }
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        doFlightCreation
    Description:        Method for inserting Flights Information
    Parameter:          QAC_ServiceReqCaseCreationAPI - Flights Details, myCase
    --------------------------------------------------------------------------------------*/
    public static Flight__c doFlightCreation(QAC_ServiceReqCaseCreationAPI.Flights myFlight, Case myCase){
        
        String flightRTId = Schema.SObjectType.Flight__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        //String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get(RTName).getRecordTypeId();
        
        system.debug('inside flight**');
        
        Flight__c newFlight = new Flight__c();
        newFlight.RecordTypeId = flightRTId;
        newFlight.Case__c = myCase.Id;
        newFlight.Flight_Number__c = myFlight.flightNumber;
        newFlight.Cabin_Class__c = myFlight.cabinClass;
        newFlight.New_Cabin_Class__c = myFlight.newCabinClass;
        newFlight.Coupon_Number__c = myFlight.couponNumber;
        newFlight.Flight_Date__c = String.isBlank(myFlight.flightDate) ? null : Date.valueOf(myFlight.flightDate);
        newFlight.Departure_Airport__c = myFlight.departurePort;
        newFlight.Arrival_Airport__c = myFlight.arrivalPort;
        newFlight.Arrival_Time__c = myFlight.arrivalTime;
        newFlight.Departure_Time__c = myFlight.departureTime;
        newFlight.Fare_Basis__c = myFlight.fareBasis;
        
        return newFlight;
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        doPassengerCreation
    Description:        Method for inserting Passenger Information
    Parameter:          QAC_ServiceReqCaseCreationAPI - Passenger Details, myCase
    --------------------------------------------------------------------------------------*/
    public static Affected_Passenger__c doPassengerCreation(QAC_ServiceReqCaseCreationAPI.Passengers myPassenger, Case myCase){
        
        String passengerRTId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        system.debug('inside Passenger**');
        
        Affected_Passenger__c newPassenger = new Affected_Passenger__c();
        newPassenger.Name = myPassenger.firstName + ' ' + myPassenger.surname;
        newPassenger.RecordTypeId = passengerRTId;
        newPassenger.Case__c = myCase.Id;
        newPassenger.Salutation__c = myPassenger.salutation;
        newPassenger.FirstName__c = myPassenger.firstName;
        newPassenger.LastName__c = myPassenger.surname;
        newPassenger.Passenger_Type__c = myPassenger.passengerType;
        newPassenger.Passenger_Sequence__c = String.isNotBlank(myPassenger.passengerSequence) ? Decimal.valueOf(myPassenger.passengerSequence) : null;
        newPassenger.Passenger_Tattoo_Number__c = String.isNotBlank(myPassenger.passengerTattoo) ? Decimal.valueOf(myPassenger.passengerTattoo) : null;
        newPassenger.FrequentFlyerNumber__c = myPassenger.frequentFlyerNumber;
        newPassenger.QAC_Flight_Number__c = myPassenger.flightNumber;
        newPassenger.Old_Ticket_Number__c = myPassenger.oldTicketNumber;
        newPassenger.Ticket_Number__c = myPassenger.ticketNumber;
        newPassenger.Date_of_Birth__c = String.isNotBlank(myPassenger.dateOfBirth) ? Date.valueOf(myPassenger.dateOfBirth) : null;
        newPassenger.New_First_Name__c = myPassenger.newFirstName;
        newPassenger.New_Salutation__c = myPassenger.newSalutation;
        newPassenger.New_Last_Name__c = myPassenger.newSurname;
        
        return newPassenger;
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        doEMDDetailsCreation
    Description:        Method for inserting EMD Details Information CRM-9209
    Parameter:          QAC_ServiceReqCaseCreationAPI - EMD Details, myCase
    --------------------------------------------------------------------------------------*/
    public static EMD_Details__c doEMDDetailsCreation(QAC_ServiceReqCaseCreationAPI.EMDDetails emdDetails, Case myCase) {
        
        EMD_Details__c newEMDDetails = new EMD_Details__c();
        newEMDDetails.EMD_Number__c = emdDetails.emdNum;
        newEMDDetails.EMD_Type__c = emdDetails.emdType;
        newEMDDetails.Case__c = myCase.Id;
        
        return newEMDDetails;
    }

    /*--------------------------------------------------------------------------------------     
    Method Name:        doCaseCommentsCreation
    Description:        Method for inserting Case Comments Information
    Parameter:          QAC_ServiceReqCaseCreationAPI - Case Comments, myCase
    --------------------------------------------------------------------------------------*/
    public static CaseComment doCaseCommentsCreation(QAC_ServiceReqCaseCreationAPI.Comments myComments, Case myCase){
        
        system.debug('inside CaseComments**');
        
        CaseComment newComment = new CaseComment();
        newComment.CommentBody = myComments.commentDescription;
        newComment.ParentId = myCase.Id;
        
        return newComment;
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        fetchCase
    Description:        Method for Fetching Parent Case from Case Number / Case Id
    Parameter:          caseKey
    --------------------------------------------------------------------------------------*/
    public static Case fetchCase(String caseKey)
    {
        String myQuery;
        Case theCase;
        system.debug('case key**'+caseKey);
        if(String.isNotBlank(caseKey)){
            if(caseKey.isNumeric()){
                myQuery = 'Select Id from Case where CaseNumber = :caseKey';
            }
            else{
                myQuery = 'Select Id,External_System_Reference_Id__c,CaseNumber,PNR_number__c,Passenger_Name__c,Authority_Number__c,CreatedDate from Case where Id = :caseKey';
            }
            for(Case eachCase : Database.query(myQuery)){
                if(eachCase != null)
                    theCase = eachCase;
            }
        }
        return theCase;
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        fetchAccount
    Description:        Method for Fetching Account from Agency QIC / IATA 
    Parameter:          qicCode
    --------------------------------------------------------------------------------------*/
    public static Account fetchAccount(String qicCode){
        Account existingAccount;
        for(Account eachAccount : [Select Id,Name,Email__c,BillingCountry,Phone from Account where Qantas_Industry_Centre_ID__c =: qicCode]){
            if(eachAccount != null){
                existingAccount = eachAccount;
            }
        }
        system.debug('** existing Acc Id**'+existingAccount);
        return existingAccount;
    }

    /*--------------------------------------------------------------------------------------     
    Method Name:        getWDData
    Description:        Method for Fetching QAC_Waiver_Default__mdt Record 
    Parameter:          waiverType
    --------------------------------------------------------------------------------------*/
    public static Map<String,QAC_Waiver_Default__mdt> getWDData(String waiverType, String waiverSubType, String billCountry)
	{
        String Query;
        list<QAC_Waiver_Default__mdt> theCase;
        system.debug('billCountry**'+billCountry);
        String cosAPI = getWDMDTField(billCountry);
		
		Query = 'SELECT MasterLabel,Paid_Service__c,DeveloperName,Waiver_Sub_Type__c,Approve__c,Condition_Met__c,Waiver_Type__c';
		Query += (String.isNotBlank(cosAPI)) ? (',' + cosAPI) : '';
		Query += ' FROM QAC_Waiver_Default__mdt';
		Query += ' WHERE Waiver_Type__c = :waiverType';
		Query += ' AND Waiver_Sub_Type__c = :waiverSubType';

        system.debug('WD Query**'+Query);
	
        Map<String,QAC_Waiver_Default__mdt> allFFMDTmap = new Map<String,QAC_Waiver_Default__mdt>();
        for(QAC_Waiver_Default__mdt eachFFMDT : Database.query(Query))
        {
            if(eachFFMDT != null){
                allFFMDTmap.put(eachFFMDT.Waiver_Type__c+'_'+eachFFMDT.Waiver_Sub_Type__c,eachFFMDT);
            }
        }
        return allFFMDTmap;
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        getWDMDTField
    Description:        Method for Fetching QAC_Waiver_Default__mdt Cost_of_Sale Fields  
    Parameter:          waiverType
    --------------------------------------------------------------------------------------*/
    public static String getWDMDTField(String accCountry){
		
		//Map<String,String> fieldApiLabelMap = new Map<String, String>();
		String costOfSale;
        Schema.DescribeSObjectResult r = QAC_Waiver_Default__mdt.sObjectType.getDescribe();
        for(SObjectField sfield: r.fields.getMap().values()) {
			Schema.DescribeFieldResult dfield = sfield.getDescribe();
			if(dfield.getLabel().contains(accCountry))
			{
				costOfSale = dfield.getName();
				//fieldApiLabelMap.put(dfield.getName(),dfield.getLabel());
				break;
			}
        }	
		return costOfSale;
		//return fieldApiLabelMap;
	}
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        getAttributeValue
    Description:        Method for Getting the attribute value from payload.  
    Parameter:          (String)attr, (Map<String,String>)payload
    --------------------------------------------------------------------------------------*/
    private static String getAttributeValue(String attr, Object payload){
        if (String.isBlank(attr)) {return null;}
        system.debug(attr);
        List<String> a = attr.split('\\.');
        system.debug(a);
        Integer i = 0;
        for (; i<a.size() ; i++) {
            if (payload != null) {payload = ((Map<String,Object>)payload).get(a[i]);}
        }
        return payload != null ? String.valueOf(payload) : null;
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        typeCastData
    Description:        Method for typecasting data as per the field yype  
    Parameter:          (String)value, (String)valType
    --------------------------------------------------------------------------------------*/
    private static Object typeCastData(Object value, String valType){
        if (value == null || (value instanceOf String && String.isBlank((String)value))) return null;
        if (String.isBlank(valType)) valType = 'String';
        switch on valType.toLowerCase() {
            when 'integer' {
                return Integer.valueOf(value);
            }
            when 'decimal' {
                return Decimal.valueOf(String.valueOf(value));
            }
            when 'boolean' {
                return Boolean.valueOf(value);
            }
            when 'dategmt' {
                return Datetime.valueOfGmt((String)value).date();
            }
            when 'date' {
                return Date.valueOf((String)value);
            }
            when 'datetimegmt' {
                return Datetime.valueOfGmt((String)value);
            }
            when 'datetime' {
                return Datetime.valueOf((String)value);
            }
            when 'datejson' {
                return (Date)JSON.deserialize((String)value, Date.class);
            }
            when 'datetimejson' {
                return (Datetime)JSON.deserialize((String)value, Datetime.class);
            }
            when else {
                return value;
            }
        }
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        getMetadataFieldMappings
    Description:        Method for typecasting data as per the field yype  
    Parameter:          (String)mappingName, (String)payloadOrigin
    --------------------------------------------------------------------------------------*/
    private static List<Object> getMetadataFieldMappings(String mappingName, String payloadOrigin){
        if (String.isBlank(mappingName) || String.isBlank(payloadOrigin)) return null;
        Global_Properties__mdt metaRec;
        for (Global_Properties__mdt x: [select Static_Long_Values__c from Global_Properties__mdt where Label = :mappingName limit 1]) 
            metaRec = x;
        
        List<Object> properties = (List<Object>)JSON.deserializeUntyped(metaRec.Static_Long_Values__c);
        for (Object y : properties) {
            String origin = String.valueOf(((Map<String,Object>)y).get('Origin'));
            if (origin == payloadOrigin) {
                return (List<Object>)(((Map<String,Object>)y).get('lstFieldMappin'));
            }
        }
        return null;
    }
}