/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Queueable APex to create update Passenger and contact
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
15-May-2018      Praveen Sampath               Initial Design
01-Oct-2019      Lora Mae Dapulang             Added line for GRAPHITE-932 & GRAPHITE-936
26-Nov-2019      Raymart Tolentino             Add logic for GRAPHITE-1412
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_CreatePassengerForEvents  implements Queueable , Database.AllowsCallouts{ 
    //Variables 
    public final Event__c objEvent;
    public final Id userID;
    public final Integer pageNumber;
    public Integer counter;
    public static final String preflightStatus = CustomSettingsUtilities.getConfigDataMap('Event Flight Status Pre');
    public static final String postflightStatus = CustomSettingsUtilities.getConfigDataMap('Event Flight Status Post');
     
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        QCC_CreatePassengerForEvents
    Description:        Constructor 
    Parameter:          Event object and Next page number always send as null
    --------------------------------------------------------------------------------------*/ 
    public QCC_CreatePassengerForEvents(Event__c objEvent, Integer pageNumber){
        this.objEvent = objEvent;
        this.pageNumber = pageNumber;
        this.userID = [select id from user where userName =: CustomSettingsUtilities.getConfigDataMap('QCC_QSOAUserName')].Id;
        System.debug('user == '+userID);
        List<Affected_Passenger__c> lstPass=  [SELECT  Id, Counter__c FROM Affected_Passenger__c where  
                                               Event__c =: objEvent.Id ORDER BY Counter__c Limit 1];

        this.counter = 0;
        if(lstPass != Null && lstPass.size()>0){
            this.counter = Integer.ValueOf(lstPass[0].Counter__c);

        }

    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        execute
    Description:        Queueable  execution  
    Parameter:         
    --------------------------------------------------------------------------------------*/ 
    public void execute(QueueableContext context){
        Integer nextPage;
        String  flightStatus;
        Savepoint sp; 
        Boolean isException = false;
        system.debug('preflightStatus$$$$$$$4'+preflightStatus);
        system.debug('postflightStatus$$$$$$$4'+postflightStatus);
        system.debug('objEvent$$$$$$$4'+objEvent);
        QCC_FlightPassengersResponse passResponse;
        try{
            //getting the flight status
            if(String.isNotBlank(objEvent.Flight_Status__c )){
                for(String pre: preflightStatus.split(',')){
                    if(pre.trim() == objEvent.Flight_Status__c){
                        flightStatus = 'PreFlight';
                        break;
                    }
                }
                for(String post: postflightStatus.split(',')){
                    if(post.trim() == objEvent.Flight_Status__c){
                        flightStatus = 'PostFlight';
                        break;
                    }
                }
            }
            //Invoking the Passenger API
            passResponse = QCC_invokeCAPAPI.invokeFlightPassengerAPI(objEvent.FlightNumber__c , objEvent.ScheduledDepDate__c , objEvent.DeparturePort__c , objEvent.ArrivalPort__c, pageNumber);
            system.debug('passResponse########'+passResponse);
            if(passResponse != Null && passResponse.passengers != Null && passResponse.passengers.size()>0){
                nextPage = String.isNotBlank(passResponse.nextPageNumber)?Integer.valueOf(passResponse.nextPageNumber): Null;
                List<QCC_FlightPassengersResponse.passengers> lstPassenger = passResponse.passengers;
                
                Map<String, List<CAPSearchWrapper>> mapToCusSearch = new Map<String, List<CAPSearchWrapper>>();
                Map<String, QCC_FlightPassengersResponse.passengers> mapAll = new Map<String, QCC_FlightPassengersResponse.passengers>();
                Map<String, Affected_Passenger__c> mapAllPassenger = fetchAllPassenger(objEvent.Id);
                Map<String, String> mapPassengerContact = new Map<String, String>();
                List<String>lstResCode = CustomSettingsUtilities.getConfigDataMap('QCC_ValidPassengerResCode').split(';'); 
                Set<String> setResCode = new Set<String>();
                setResCode.addAll(lstResCode);
                //CRM-8862
                Map<String,Contact> allNonFFContactsMap = new Map<String,Contact>();
                List<String> nonFFCnttDetails = new List<String>();
                Affected_Passenger__c objNonFFPassenger;

                //Jira CRM-9035
                Set<String> travelAgentEmailDomains = new Set<String>();
                for(QCC_Travel_Agent_Email_Domains__mdt mdtRecord : QCC_Travel_Agent_Email_Domains__mdt.getAll().values()) {
                    if(mdtRecord != NULL && mdtRecord.isActive__c) {
                        travelAgentEmailDomains.add(mdtRecord.Label);
                    }
                }
                
                //Looping Passengers from the response 
                for(QCC_FlightPassengersResponse.passengers passenger: lstPassenger){
                    if( String.isNotBlank(passenger.reservationStatusCode) && setResCode.contains(passenger.reservationStatusCode)){
                        //All Passenger
                        mapAll.put(passenger.passengerId, passenger);
                        
                        
                        //new Passenger and Passenger with FF Number
                        if((mapAllPassenger == Null || mapAllPassenger.containsKey(passenger.passengerId) != true ) &&
                           String.isNotBlank(passenger.qfFrequentFlyerNumber) && 
                           passenger.qfFrequentFlyerNumber != Null) 
                        {
                            List<CAPSearchWrapper> lstFFNum = mapToCusSearch != Null && mapToCusSearch.get('FF')!= Null?mapToCusSearch.get('FF'): new List<CAPSearchWrapper>();
                            CAPSearchWrapper searchWrap = new CAPSearchWrapper();
                            searchWrap.lastName = String.isNotBlank(passenger.lastName)?passenger.lastName.trim():'';
                            searchWrap.ffNumber = passenger.qfFrequentFlyerNumber;
                            searchWrap.passengerId = passenger.passengerId;
                            lstFFNum.add(searchWrap);
                            mapToCusSearch.put('FF', lstFFNum);
                        } else if (String.isBlank(passenger.qfFrequentFlyerNumber) || passenger.qfFrequentFlyerNumber == Null) { 
                            //CRM-8862: Non FF passengers
                            QCC_ContactWrapper nonFFPayload = new QCC_ContactWrapper();
                            objNonFFPassenger = populateEmailPhone(new Affected_Passenger__c(), passenger.contactDetails, true, travelAgentEmailDomains);
                            nonFFPayload.ffNumber = '';
                            nonFFPayload.lastName = passenger.lastName;
                            nonFFPayload.firstName = passenger.firstName;
                            nonFFPayload.email = objNonFFPassenger.Email__c;
                            nonFFPayload.phone = objNonFFPassenger.Phone_Number__c;
                            nonFFPayload.capId = '';
                            nonFFPayload.isFF = false;
                            nonFFCnttDetails.add(JSON.serialize(nonFFPayload));
                        }
                    }
                }

                List<QCC_FlightPassengersResponse.passengers> lstNewPassenger = new List<QCC_FlightPassengersResponse.passengers>();
                List<Contact> lstCon = new List<Contact>();
                List<Affected_Passenger__c> lstAffPassenger = new List<Affected_Passenger__c>();

                
                List<String> lstValidNewPassenger = new List<String>();
                Map<String, ContactWrapper> mapFFConWrapp = new Map<String, ContactWrapper>();
                //GRAPHITE 932 - set RT to Individual Contact
                Id individualContactRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
                system.debug('mapToCusSearch'+mapToCusSearch);

                //Invoke CAP API and Get all Contact Details for new contacts based on FF Number, Cap ID and Last Name 
                if(mapToCusSearch != Null && mapToCusSearch.size() >0){
                    Map<String, Contact> mapAllcon = new Map<String, Contact>();
                    mapAllcon = createContact(mapToCusSearch);
                    system.debug('222222222'+mapAllcon);
                    if(mapAllcon != Null){
                        for(String ffNumber: mapAllcon.keySet()){
                            if(mapAllcon.get(ffNumber) != Null){
                                Contact objCon = mapAllcon.get(ffNumber);
                                //GRAPHITE 932 - set RT to Individual Contact
                                objCon.RecordTypeId = individualContactRecTypeId;
                                //GRAPHITE 936 - set field as Individual Contact
                                objCon.QCC_TECH_RecordType__c = CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact');
                                ContactWrapper conWrap = new ContactWrapper();
                                conWrap.preferredEmail = objCon.Preferred_Email__c;
                                conWrap.preferredPhone = objCon.Preferred_Phone_Number__c;
                                mapFFConWrapp.put(ffNumber, conWrap);
                                objCon.Preferred_Email__c = '';
                                objCon.Preferred_Phone_Number__c = '';
                                lstCon.add(objCon);
                            }
                        }
                    }
                }
                //Save Point is Set Befor any DML operation
                sp = Database.setSavePoint();
                //Update/Insert Contacts related to Passenger

                //CRM-8862
                if (!nonFFCnttDetails.isEmpty()) {
                    String contactMappingSource = 'ContactWrapper_Field__c';
                    allNonFFContactsMap = QCC_GenericUtils.getNonFFContactForAffectedPassengers(nonFFCnttDetails, contactMappingSource);
                }

                //if(lstCon.size() > 0) upsert lstCon;
                system.debug('>>>lstCon: ' + lstCon);
                //GRAPHITE-1797: Changed the approach for inserting/updating contact records to allow successful records to push through and also for the whole process (Update Passenger) NOT to fail and break.
                //Duplicate rule is getting fired when a customer with leading 0s are inserted/updated for the flight event.
                if(lstCon!=null && lstCon.size() > 0) {
                    Database.UpsertResult[] saveResultList = Database.upsert(lstCon,false);
                }

                //GRAPHITE-953: Re-query the records updated/inserted to be able to retrieve the SSU flag which will be used to determine to create the passenger for a "Heads Up" flight event
                List<Contact> contactsAffected = new List<Contact>([SELECT Id, RecordTypeId, Frequent_Flyer_Number__c, SSU__c FROM Contact WHERE Id IN: lstCon]);
                system.debug('>>>contactsAffected: ' + contactsAffected);

                //Map Passenger ID with Contact 
                for(Contact objCon: contactsAffected){
                    system.debug('>>>objCon.Frequent_Flyer_Number__c: ' + objCon.Frequent_Flyer_Number__c);
                    //GRAPHITE 932 - Added this fix to check the FF Number and get it from mapFFConWrapp based on both leading and non-leading zero. 
                    //Upon investigation, when contact is inserted the apex class method "accConRshipUpdateonContacts.UpdateFrequentFlyerNumber" removes the leading zeros. 
                    //However, the mapFFConWrapp saves FF Number as a key with leading zeros (which is the response of QCC_invokeCAPAPI.invokeFlightPassengerAPI). 
                    //Thus, previously this code was not retrieving the contact record because contact's FF Number will never have leading zeros.
                    //ContactWrapper conWrap = mapFFConWrapp.get(objCon.Frequent_Flyer_Number__c);
                    String ffleadZero =  objCon.Frequent_Flyer_Number__c.leftPad(10,'0');
                    ContactWrapper conWrap = (mapFFConWrapp.containsKey(ffleadZero)) ? mapFFConWrapp.get(ffleadZero) : mapFFConWrapp.get(objCon.Frequent_Flyer_Number__c);
                    //ContactWrapper conWrap = mapFFConWrapp.get(objCon.Frequent_Flyer_Number__c);
                    conWrap.contactId = objCon.Id;
                    //GRAPHITE-953: Set the SSU flag. This will be used to determine to create Passenger for SSU contact for a "Heads Up" flight event
                    conWrap.ssuFlag = objCon.SSU__c;
                    objCon.RecordTypeId = individualContactRecTypeId;
                    mapFFConWrapp.put(objCon.Frequent_Flyer_Number__c, conWrap);
                }
                system.debug('>>>mapFFConWrapp: ' + mapFFConWrapp);
                system.debug('mapAllPassenger########'+mapAllPassenger);
                system.debug('mapAll########'+mapAll);
                
                //Create Passenger record and for all contact 
                for(QCC_FlightPassengersResponse.passengers passenger: mapAll.values()){
                    //Existing Passenger to be updated based on the event status
                    if(mapAllPassenger != null && mapAllPassenger.containsKey(passenger.passengerId)){
                        Affected_Passenger__c objAffPassenger = mapAllPassenger.get(passenger.passengerId);
                        if(passenger.leg != null){
                            objAffPassenger = checkPrePost(objEvent, passenger.leg, objAffPassenger, flightStatus);
                        }else{
                            objAffPassenger.TECH_PreFlight__c = true; 
                        }
                        objAffPassenger.Counter__c = counter+1;
                        //Jira CRM-5590:Fligth Event - Missing Emails
                        objAffPassenger = populateEmailPhone(objAffPassenger, passenger.contactDetails, string.isBlank(objAffPassenger.FrequentFlyerNumber__c), travelAgentEmailDomains);

                        //CRM-8862
                        if (string.isBlank(objAffPassenger.FrequentFlyerNumber__c)) {
                            //CRM-8862 For Non FF Passenger
                            objAffPassenger = populateNonFFContact(objAffPassenger, passenger, allNonFFContactsMap);
                        }
                        lstAffPassenger.add(objAffPassenger);
                  
                    }
                    //New Passenger for the event and contact 
                    else{
                        ContactWrapper conWrap = mapFFConWrapp.containsKey(passenger.qfFrequentFlyerNumber)?mapFFConWrapp.get(passenger.qfFrequentFlyerNumber):Null;
                        system.debug('conWrap##########'+conWrap);
                        system.debug('objEvent##########'+objEvent);
                        system.debug('passenger##########'+passenger);
                        system.debug('flightStatus##########'+flightStatus);
                        system.debug('recordTypeId##########'+objEvent.RecordTypeId);

                        //GRAPHITE-488 LMP 26/08/2019: Added the condition to check the record type for "Head Up" flight event, only create FF passengers and/or SSU passengers
                        Affected_Passenger__c objPass = new Affected_Passenger__c();
                        if (objEvent.RecordTypeId == GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('QCC Flight Event Heads Up'))) {
                            system.debug('>>>create for heads up');
                            //Check the passenger tier code
                            if (passenger.qfTierCode != Null && String.isNOtBlank(passenger.qfTierCode) && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(passenger.qfTierCode))) {
                                system.debug('>>>qfTierCode Value: ' + CustomSettingsUtilities.getConfigDataMap(passenger.qfTierCode));
                                List<String> ffTiersToCheck = Label.QCC_Flight_Event_Heads_Up_Passengers.split(';');
                                system.debug('>>>conWrap: ' + conWrap);
                                if (ffTiersToCheck.contains(CustomSettingsUtilities.getConfigDataMap(passenger.qfTierCode))) {
                                    objPass = createAffPassenger(conWrap, objEvent, passenger,  flightStatus, userID, null, travelAgentEmailDomains);
                                } else if (conWrap != NULL) {
                                    if (conWrap.ssuFlag) { //GRAPHITE-953: Check the passenger's related contact record's SSU flag
                                        objPass = createAffPassenger(conWrap, objEvent, passenger,  flightStatus, userID, null, travelAgentEmailDomains);
                                    }
                                }
                            }
                        } else { //Existing functionality, do for all other record types
                            //Affected_Passenger__c objPass = createAffPassenger(conWrap, objEvent, passenger,  flightStatus, userID);
                            objPass = createAffPassenger(conWrap, objEvent, passenger,  flightStatus, userID, allNonFFContactsMap, travelAgentEmailDomains);
                        }
                        objPass.Counter__c = counter+1;
                        lstAffPassenger.add(objPass);
                    }
                }

                //update/Inset Passenger
                upsert lstAffPassenger;

                //Invoke the next  call if the passenger api have next page
                if(nextPage != Null){
                    System.enqueueJob(new QCC_CreatePassengerForEvents(objEvent, nextPage));
                }else if(nextPage == Null){
                     System.enqueueJob(new QCC_PassengerServiceDetailQueueable(objEvent, 1, counter));
                }
                
                //updating the Token
                if (String.isNotBlank(passResponse.token)) {
                    QCC_GenericUtils.updateToken(passResponse.token, 'QCC_FlightToken');
                }
            }
                    
        }catch(Exception ex){
            if(sp != Null){
                Database.rollback(sp);
            }
            system.debug('Exception###'+ex);
            isException = true;
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Create Passenger API', 'QCC_CreatePassengerForEvents', 
                                     'execute', String.valueOf(passResponse), String.valueOf(''), true,'', ex);
        }finally{
            //update Event
            if(nextPage == Null || isException){
                objEvent.TechPassenger_API_Invoked__c = false;
                objEvent.TECH_PassengerAPIExecuted__c = true;
                update objEvent;
            }
        }
            
    }

    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createContact
    Description:        Craete new Contact by invoking CAP API 
    Parameter:          Last Name of Passenger, CAP ID and Frequent Flyer Number 
    --------------------------------------------------------------------------------------*/ 
    public static Map<String, Contact> createContact(Map<String, List<CAPSearchWrapper>> mapToCusSearch){
        System.debug('%%%Searching customers ' + mapToCusSearch);
        return QCC_CAPCustomerDetailHelper.getContacts(mapToCusSearch);
    }


    /*--------------------------------------------------------------------------------------      
    Method Name:        createAffPassenger
    Description:        Create new contact and link it to Event and Contact  
    Parameter:          Contact Id, Event Id, Passenger Response, Flight Status pre or post
    --------------------------------------------------------------------------------------*/ 
    public static Affected_Passenger__c createAffPassenger(ContactWrapper conWrap, Event__c objEvt, QCC_FlightPassengersResponse.passengers passenger, String flightStatus, String userID,
                         Map<String,Contact> allNonFFContactsMap, Set<String> travelAgentEmailDomains) {
        Affected_Passenger__c objPassenger = new Affected_Passenger__c();
        objPassenger.PassengerId__c = passenger.passengerId;
        String fName = String.isNotBlank(passenger.firstName)?passenger.firstName.toLowerCase().split(' ')[0]:'';
        fName = String.isNotBlank(fName)?fName.capitalize():'';
        
        String lName = String.isNotBlank(passenger.lastName)?passenger.lastName.toLowerCase():'';
        lName = String.isNotBlank(lName)?lName.capitalize():'';
        
        objPassenger.Name = fName+' '+lName;
        
        objPassenger.FirstName__c = fName;
        objPassenger.LastName__c = lName;
        objPassenger.PNR__c = passenger.bookingReference;
        objPassenger.ArrivalPort__c = passenger.offPoint;
        objPassenger.DeparturePort__c = passenger.boardPoint;
        if(objEvt.RecordTypeId == GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Offload Record Type'))){
            objPassenger.RecordTypeId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'QCC Offload Passenger');
        }else{
            objPassenger.RecordTypeId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', CustomSettingsUtilities.getConfigDataMap('QCC EventPassenger'));
        }
        System.debug('userID ##### '+userID);
        objPassenger.OwnerId =objEvt.QCC_AutoCreated__c == true?userID: userinfo.getUserID();
        
        if(passenger.contactDetails != null){
            objPassenger = populateEmailPhone(objPassenger, passenger.contactDetails, String.isBlank(passenger.qfFrequentFlyerNumber), travelAgentEmailDomains);
        }
        //Only For FF Passenger 
        if(conWrap != Null ){
            objPassenger.Passenger__c = conWrap.contactId;
            //IF Booking Email or Phone is Blank, then use FF Email or Phone Number respectively 
            system.debug('QCC_GenericUtils.getIntegerFromString(conWrap.preferredPhone)'+conWrap.preferredPhone);
            if( String.isNotBlank(conWrap.preferredEmail) && QCC_EventGenericUtils.checkEmail(conWrap.preferredEmail)){
                objPassenger.Email__c = conWrap.preferredEmail;
            }
            objPassenger.Phone_Number__c = String.isNotBlank(conWrap.preferredPhone)?QCC_GenericUtils.getIntegerFromString(conWrap.preferredPhone): objPassenger.Phone_Number__c;
        } else if (String.isBlank(passenger.qfFrequentFlyerNumber)) {
            //CRM-8862 For Non FF Passenger
            objPassenger = populateNonFFContact(objPassenger, passenger, allNonFFContactsMap);
        }
        
        objPassenger.Cabin__c = CustomSettingsUtilities.getConfigDataMap('QCC-Cabin'+passenger.bookedCabinClass) ;
        objPassenger.TravelledCabin__c = CustomSettingsUtilities.getConfigDataMap('QCC-Cabin'+passenger.bookedCabinClass) ;
        //Connecting Flight Details
        system.debug('connectingFlight$$$$$$$$$$'+passenger.connectingFlight);
        if(passenger.connectingFlight != null){
            objPassenger = connectingFlight(objPassenger, passenger.connectingFlight[0]);
        }
        
        system.debug('flightStatus$$$$$$$$$$'+passenger.leg);
        if(passenger.leg != null){
            objPassenger = checkPrePost(objEvt, passenger.leg, objPassenger, flightStatus);
        }else{
             objPassenger.TECH_PreFlight__c = true; 
        }
        objPassenger.Event__c = objEvt.Id;
        objPassenger.FrequentFlyerNumber__c = passenger.qfFrequentFlyerNumber;
        if(passenger.qfTierCode != Null && String.isNOtBlank(passenger.qfTierCode) && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(passenger.qfTierCode))){
          objPassenger.FrequentFlyerTier__c = CustomSettingsUtilities.getConfigDataMap(passenger.qfTierCode);
        }

        System.debug('passenger.baggageDetails: ' + passenger.baggageDetails);
        //GRAPHITE-808 Get all baggage details
        if (passenger.baggageDetails != null) {
            for(QCC_FlightPassengersResponse.BaggageDetails item : passenger.baggageDetails) {
                if (item.bagTagNumber != null && item.bagTagNumber != '') {
                    objPassenger.QCC_Checked_Bags__c = objPassenger.QCC_Checked_Bags__c == null ? item.bagTagNumber : objPassenger.QCC_Checked_Bags__c + ', ' + item.bagTagNumber;
                }
            }
        }

        //GRAPHITE-1412 Populate QCC_Class_of_Service__c by bookedReservationClass from the response
        System.debug('passenger.bookedReservationClass: ' + passenger.bookedReservationClass);
        if (passenger.bookedReservationClass != null) {
            objPassenger.QCC_Class_of_Service__c = passenger.bookedReservationClass;
        }
        //Jira: CRM-8879
        objPassenger.SME_ID__c = (passenger.smeId != null && !string.isBlank(passenger.smeId)) ? passenger.smeId : '';
        objPassenger.CORP_ID__c = (passenger.corpId != null && !string.isBlank(passenger.corpId)) ? passenger.corpId : '';

        return objPassenger;
    }


    /*--------------------------------------------------------------------------------------      
    Method Name:       connectingFlight
    Description:       Firest Connection Flight Details
    Parameter:         Passenger and Connecting Flight detail from CAP 
    --------------------------------------------------------------------------------------*/ 
    public static Affected_Passenger__c connectingFlight(Affected_Passenger__c objPassenger, QCC_FlightPassengersResponse.ConnectingFlight connectionInfo){
        objPassenger.ConnectingFlightNumber__c = connectionInfo.carrierCode+''+connectionInfo.flightNo;
        objPassenger.ConnectingFlightDeparturePort__c = connectionInfo.departurePort;
        objPassenger.ConnectingFlightArrivalPort__c = connectionInfo.arrivalPort;
        objPassenger.ConnectingFlightScheduleDeparture__c = connectionInfo.departureLocalDateTime;
        return objPassenger;
    }



    /*--------------------------------------------------------------------------------------      
    Method Name:       populateEmailPhone
    Description:       Populate all email and phone number for non-frequent flyer
    Parameter:         Passenger and contact detail from CAP 
    --------------------------------------------------------------------------------------*/ 
    public static Affected_Passenger__c populateEmailPhone(Affected_Passenger__c objPassenger, QCC_FlightPassengersResponse.ContactDetails contactInfo, Boolean isNonFF, Set<String> travelAgentEmailDomains){
        if(contactInfo != Null){
            if(contactInfo.email != null){
                Map<String, String> mapEmail = new Map<String, String>();

                //Jira CRM-5590:Fligth Event - Missing Emails              
                for(QCC_FlightPassengersResponse.Email yEmail: contactInfo.email){
                    if(yEmail.passengerAssociationIndicator == 'Y'){
                        if(!(mapEmail.containsKey(yEmail.contactSourceCode)) || mapEmail == Null){
                            mapEmail.put(yEmail.contactSourceCode, yEmail.id);
                        }
                    }
                }
                if (mapEmail == Null || mapEmail.size() == 0 ) {
                    for(QCC_FlightPassengersResponse.Email nEmail: contactInfo.email){
                        if(nEmail.passengerAssociationIndicator == 'N'){
                            if(!(mapEmail.containsKey(nEmail.contactSourceCode)) || mapEmail == Null){
                                mapEmail.put(nEmail.contactSourceCode, nEmail.id);
                            }
                        }
                    }
                }
				
                if(mapEmail != Null && mapEmail.size()>0 ){
                    String email = '';
                    if(mapEmail.containskey('AP')){
                        email = mapEmail.get('AP');
                    }else if(mapEmail.containskey('SSR')){
                        email = mapEmail.get('SSR');
                    }else if(mapEmail.containskey('OS')){
                        email = mapEmail.get('OS');   
                    }
                    if(String.isNotBlank(email)){
                        email = email.contains('//')? email.replace('//','@'): email;
                        system.debug('email###'+email);
                        system.debug('QCC_EventGenericUtils.checkEmail(email)###'+QCC_EventGenericUtils.checkEmail(email));
                        if(QCC_EventGenericUtils.checkEmail(email)){
                            objPassenger.Email__c = email;
                            //Jira CRM-9035
                            if (isNonFF && !travelAgentEmailDomains.isEmpty()) {
                                String domain = email.split('@')[1].split('\\.')[0];
                                objPassenger.Email__c = travelAgentEmailDomains.contains(domain.toUpperCase()) ? '' : email;
                            }
                        }
                    }
                }
            }
            
            
            if(contactInfo.phone != null ){
                Map<String, String> mapPhone = new Map<String, String>();
                for(QCC_FlightPassengersResponse.Phone phone: contactInfo.phone){
                    if(phone.passengerAssociationIndicator == 'Y'){
                        mapPhone.put(phone.contactSourceCode,QCC_GenericUtils.getIntegerFromString(phone.phoneNumber));
                    }
                }
                
                if(mapPhone != Null && mapPhone.size()>0 ){
                    if(mapPhone.containskey('AP')){
                        objPassenger.Phone_Number__c = mapPhone.get('AP');
                    }else if(mapPhone.containskey('SSR')){
                         objPassenger.Phone_Number__c = mapPhone.get('SSR');
                    }else if(mapPhone.containskey('OS')){
                         objPassenger.Phone_Number__c = mapPhone.get('OS');
                    }
                }
            }
        }
        return objPassenger;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchAllPassenger
    Description:        To Get all the existing Passenger for the event  
    Parameter:          Event Id
    --------------------------------------------------------------------------------------*/ 
    public static Map<String, Affected_Passenger__c> fetchAllPassenger(Id eventID){

        Map<String, Affected_Passenger__c> mapAffectPassenger = new Map<String, Affected_Passenger__c>();
        for(Affected_Passenger__c objPassenger: [Select Id, PassengerId__c, Passenger__c, TECH_PostFlight__c, 
                                                 TECH_PreFlight__c, Counter__c, FrequentFlyerNumber__c, Phone_Number__c, Email__c   from Affected_Passenger__c
                                                  where Event__c =: eventID])
        {
            mapAffectPassenger.put(objPassenger.PassengerId__c, objPassenger);
        }
        system.debug('1111111111111'+mapAffectPassenger);
        return mapAffectPassenger;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        checkPrePost
    Description:        Determine if the passenger is post flight Passenger or preflight Passenger 
    Parameter:          Event, List<leg>, Affected Passenger
    --------------------------------------------------------------------------------------*/ 
    public static Affected_Passenger__c checkPrePost( Event__c objEvt, List<QCC_FlightPassengersResponse.leg> lstLeg, Affected_Passenger__c objPassenger, String flightStatus){
        
        if(flightStatus == 'PreFlight' || string.isBlank(flightStatus) || 
            lstLeg == Null || lstLeg.size() == 0)
        {
            objPassenger.TECH_PreFlight__c = true; 
        }
        
        for(QCC_FlightPassengersResponse.Leg leg: lstLeg){
            if(flightStatus == 'PostFlight' && leg.originPort == objEvt.DeparturePort__c && 
               leg.boardStatus == 'BDD')
            {
                objPassenger.TECH_PostFlight__c = true;
            }
            else{
                objPassenger.TECH_PreFlight__c = true; 
            }
            if(leg.originPort == objEvt.DeparturePort__c  && leg.destinationPort == objEvt.ArrivalPort__c){
                objPassenger.SeatNo__c = leg.seatNo;
                if(leg.regrade != Null){
                    objPassenger.TravelledCabin__c =  CustomSettingsUtilities.getConfigDataMap('QCC-Cabin'+leg.regrade.cabinCode);
                }
            }
        }
        return objPassenger;
    }

    
    /*--------------------------------------------------------------------------------------      
    Method Name:        populateNonFFContact jira CRM-8862
    Description:        this method will attach the Non FF individual contact to the passenger record.
    Parameter:          Affected_Passenger__c, QCC_FlightPassengersResponse.passengers, Map<String,Contact>
    --------------------------------------------------------------------------------------*/ 
    public static Affected_Passenger__c populateNonFFContact(Affected_Passenger__c objPassenger, QCC_FlightPassengersResponse.passengers passenger, Map<String,Contact> allNonFFContactsMap) {
        try {
            String firstName = (String.isNotBlank(passenger.firstName) && passenger.firstName != null ) ? passenger.firstName.deleteWhitespace().toLowerCase() : '';
            String lastName = (String.isNotBlank(passenger.lastName) && passenger.lastName != null ) ? passenger.lastName.deleteWhitespace().toLowerCase() : '';
            String phoneNumber = (String.isNotBlank(objPassenger.Phone_Number__c) && objPassenger.Phone_Number__c != null) ? String.valueOf(objPassenger.Phone_Number__c).deleteWhitespace().toLowerCase() : '';
            String email = (String.isNotBlank(objPassenger.Email__c) && objPassenger.Email__c != null) ? String.valueOf(objPassenger.Email__c).deleteWhitespace().toLowerCase() : '';
            String nonFFCntKey = firstName + lastName + phoneNumber + email; 
                 //If there is no non FF individual contact, then mapping to null placeholder contact
            objPassenger.Passenger__c = (allNonFFContactsMap != null && !allNonFFContactsMap.isEmpty() && allNonFFContactsMap.get(nonFFCntKey) != NULL) ? allNonFFContactsMap.get(nonFFCntKey).Id : QCC_GenericUtils.fetchContactForNonFFCase().Id;
        } catch (Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Create Passenger API', 'QCC_CreatePassengerForEvents', 
                                     'populateNonFFContact', String.valueOf(passenger), String.valueOf(''), true,'', ex);
        }
        return objPassenger;
    }

   public class CAPSearchWrapper{
        public string lastName;
        public String ffNumber;
        public String capId;
        public String passengerId;
   }

   public class ContactWrapper{
        public String contactId;
        public String ffNumber;
        public String preferredEmail;
        public String preferredPhone;
        //GRAPHITE-953: Added wrapper field to capture SSU flag. This will be used to determine to create Passenger for SSU contact for a "Heads Up" flight event
        public Boolean ssuFlag;
   }
}