public class QCC_DisplayPAXController {

    /*--------------------------------------------------------------------------------------       
    Method Name:        initialize
    Description:        sending the list of Passenger to LC 
    Parameter:          Case recordId
    --------------------------------------------------------------------------------------*/

    @AuraEnabled
    public static String initialize(String recordId){
        //create list of passenger
        List<QCC_PNRPassengerInfoWrapper.Passengers> lstDisplay = new List<QCC_PNRPassengerInfoWrapper.Passengers>();
        //get the current case
        Case cs = [Select id, Booking_PNR__c, TECH_bookingCreationDate__c, TECH_bookingArchivalData__c from Case where id=:recordId limit 1];
        
        //get list of created Passenger
        Map<String, Affected_Passenger__c> mapCreatedPassenger = new Map<String, Affected_Passenger__c>();
        for(Affected_Passenger__c passenger : [Select id,FirstName__c, LastName__c, PassengerId__c, 
                                                PNR__c,RecoveryIsCreated__c, FrequentFlyerNumber__c,
                                                FrequentFlyerTier__c, Affected__c, Case__c 
                                                from Affected_Passenger__c Where case__c=:recordId]) {
            mapCreatedPassenger.put(passenger.PassengerId__c, passenger);
        }

        //list of Column display
        List<displayColumn> listColumn = new List<displayColumn>();
        listColumn.add(new displayColumn('First Name', 'firstName', 'text'));
        listColumn.add(new displayColumn('Last Name', 'lastName', 'text'));

        try{
            //call out to API to get list of passenger
            QCC_PNRPassengerInfoWrapper lstAPIPassenger = getListPassenger(cs.Booking_PNR__c, cs.TECH_bookingCreationDate__c, cs.TECH_bookingArchivalData__c);
            System.debug(lstAPIPassenger);
            if(lstAPIPassenger != null && lstAPIPassenger.booking != null && lstAPIPassenger.booking.passengers != null){
                //mark created Passenger as isAdded=true
                for(QCC_PNRPassengerInfoWrapper.Passengers pass : lstAPIPassenger.booking.passengers){
                    pass.isAdded = mapCreatedPassenger.containsKey(pass.passengerId);
                    lstDisplay.add(pass);
                    System.debug(lstDisplay[lstDisplay.size()-1]);
                }
            }
            //object wrapper for sendding data to LC
            PassengerInfoWrapper piw = new PassengerInfoWrapper();
            piw.displayPassenger = lstDisplay;
            piw.displayColumn = listColumn;

            return JSON.serialize(piw).replaceALL('type_x', 'type');
        }catch(exception ex){
            System.debug(ex.getMessage());
        }
        

        return null;
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        getListPassenger
    Description:        Callout to API 
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static QCC_PNRPassengerInfoWrapper getListPassenger(String pnrStr, String createdDate, String archivalData){
        QCC_PNRPassengerInfoWrapper output = new QCC_PNRPassengerInfoWrapper();

        try{
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            System.debug(token);

            output = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI(pnrStr, createdDate, token, archivalData);
        }catch(exception ex){
            //System.debug(ex.getStackTrace());
            System.debug(ex.getMessage());
        }

        return output;
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        deleteAffectedPassenger
    Description:        Delete Affected Passenger when the checkbox is unchecked
    Parameter:          
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<String> deleteAffectedPassenger(String caseId, List<String> lstPassengerId){
        try{
            Case cs = [Select id, Booking_PNR__c, TECH_bookingCreationDate__c, TECH_bookingArchivalData__c 
                        from Case where id=:caseId limit 1];
            List<String> output = new List<String>();
            List<Affected_Passenger__c> lstAFP = [Select id,FirstName__c, LastName__c, PassengerId__c, 
                                                PNR__c,RecoveryIsCreated__c, FrequentFlyerNumber__c,
                                                FrequentFlyerTier__c, Affected__c, Case__c 
                                                from Affected_Passenger__c Where case__c=:cs.Id AND PassengerId__c IN :lstPassengerId];
            for(Affected_Passenger__c pass : lstAFP){
                output.add(pass.passengerId__c);
            }
            if(lstAFP.size() > 0){
                delete lstAFP;
                return output;
            }
        }catch(exception ex){
            
        }
        return new List<String>();
    }


    /*--------------------------------------------------------------------------------------       
    Method Name:        createAffectedPassenger
    Description:        Create new Affected Passenger when the checkbox is checked
    Parameter:          
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<String> createAffectedPassenger(String caseId, List<String> listPass, Map<String, QCC_CaseCreator.LegInformation> mapPassIdToLegInfo, Boolean isAutoCase){
        try{
            //get current Case
            Case cs = [Select id, Booking_PNR__c, TECH_bookingCreationDate__c, TECH_bookingArchivalData__c, TECH_BookingSegmentId__c, TECH_BookingSegmentTattoo__c 
                            from Case where id=:caseId limit 1];

            Map<String, String> mapQantasId_PassId = new Map<String,String>();
            //List<String> listEmptyQantasIs = new List<String>();
            Map<String, Map<String, Object>> mapPassId_Passenger = new Map<String, Map<String, Object>>();

            //parse data from client side
            for(String jsonStr : listPass){
                Map<String, Object> pass = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
                if(String.isBlank(String.valueOf(pass.get('qantasFFNo'))) || String.valueOf(pass.get('qantasFFNo')) != 'null'){
                    //listEmptyQantasIs.add(String.valueOf(pass.get('passengerId')));
                }else{
                    //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
                    mapQantasId_PassId.put(String.valueOf(pass.get('qantasFFNo')).replaceFirst('^0+',''), String.valueOf(pass.get('passengerId')));
                }
                
                mapPassId_Passenger.put(String.valueOf(pass.get('passengerId')), pass);
            }
            System.debug(mapPassId_Passenger.keySet());
            //filter out all the created affected passenger of the Case
            For(Affected_Passenger__c afp : [select name, id, firstname__c, lastname__c, passengerId__c 
                                            from affected_passenger__c where passengerId__c IN :mapPassId_Passenger.keyset() 
                                            AND case__c=:caseId]){
                if(mapPassId_Passenger.containsKey(afp.passengerId__c)){
                    mapPassId_Passenger.remove(afp.passengerId__c);
                }
            }
            System.debug(mapPassId_Passenger.keySet());
            System.debug(mapQantasId_PassId.keySet());

            // Added by Puru - QDCUSCON - 4522 -- START
            if(!isAutoCase) {
                mapPassIdToLegInfo = new Map<String, QCC_CaseCreator.LegInformation>();
                String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
                System.debug(token);
                QCC_PNRLegStatusInfoWrapper flightPassenger = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(cs.Booking_PNR__c, cs.TECH_bookingCreationDate__c, '', '', token, false, cs.TECH_bookingArchivalData__c);
                
                System.debug('flightPassenger = '+flightPassenger);
                if(flightPassenger != null && flightPassenger.booking != null && flightPassenger.booking.passengerFlightStatus != null && flightPassenger.booking.passengerFlightStatus.size() > 0) {
                    for(QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus pfs: flightPassenger.booking.passengerFlightStatus) {
                        if(mapPassId_Passenger.containsKey(pfs.passengerId) && cs.TECH_BookingSegmentId__c == pfs.segmentId) {
                            QCC_CaseCreator.LegInformation legInfo = new QCC_CaseCreator.LegInformation();
                            if(String.isBlank(legInfo.cabinClass)) {
                                if(pfs.bookedCabinClass == 'P') {
                                    legInfo.cabinClass = 'First';
                                } else if(pfs.bookedCabinClass == 'J') {
                                    legInfo.cabinClass = 'Business';
                                } else if(pfs.bookedCabinClass == 'W') {
                                    legInfo.cabinClass = 'Premium Economy';
                                } else if(pfs.bookedCabinClass == 'Y') {
                                    legInfo.cabinClass = 'Economy';
                                }
                            }
                            
                            if(pfs.leg != null && pfs.leg.size() > 0) {
                                //////// Map Flight & Flight Passenger Details to Case /////
                                String flightLegFlownTable = '<html><table border="1" width="100%">';
                                flightLegFlownTable = flightLegFlownTable + '<thead><tr><th>Departure Airport</th><th>Arrival Airport</th><th>Status</th></tr></thead><tbody>';
                                
                                String boardingStatus = 'Boarded';
                                for(QCC_PNRLegStatusInfoWrapper.Leg leg: pfs.leg) {
                                    flightLegFlownTable = flightLegFlownTable + '<tr><td>'+leg.originAirportCode+'</td>';
                                    flightLegFlownTable = flightLegFlownTable + '<td>'+leg.destinationAirportCode+'</td>';
                                    
                                    if(leg.boardingStatusCode == 'NBD') {
                                        flightLegFlownTable = flightLegFlownTable + '<td>Not Flown</td></tr>';
                                        boardingStatus = 'Not Boarded';
                                    } else if(leg.boardingStatusCode == 'BDD') {
                                        flightLegFlownTable = flightLegFlownTable + '<td>Flown</td></tr>';
                                    }
                                }
                                flightLegFlownTable = flightLegFlownTable + '</tbody></table></html>';
                                legInfo.flightLegFlownStatus = flightLegFlownTable;
                                legInfo.boardingStatus = boardingStatus;
                            }
                            mapPassIdToLegInfo.put(pfs.passengerId, legInfo);
                        }
                        
                    }
                }
            }
            // Added by Puru - QDCUSCON - 4522 -- END
            //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
            List<Contact> lstCon = [select Id, Name, Cap_ID__c, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c from Contact where Frequent_Flyer_Number__c IN :mapQantasId_PassId.keyset()];
            List<Affected_Passenger__c> lstAFP = new List<Affected_Passenger__c>(); 
            List<String> output = new list<String>();

            //create Passenger with Contact
            for(Contact con : lstCon){
                //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
                String key = String.ValueOf(mapQantasId_PassId.get(con.Frequent_Flyer_Number__c));
                if(mapPassId_Passenger.containsKey(key)){
                    Map<String, Object> pass = mapPassId_Passenger.get(key);

                    Affected_Passenger__c afp = new Affected_Passenger__c();
                    afp.Name = con.Name;
                    afp.Passenger__c = con.id;
                    afp.firstName__c = String.ValueOf(pass.get('firstName'));
                    afp.lastName__c = String.ValueOf(pass.get('lastName'));
                    afp.PNR__c = cs.Booking_PNR__c;
                    afp.case__c = cs.Id;
                    afp.passengerId__c = key;
                    afp.recordtypeId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'Insurance Letter');
                    afp.FrequentFlyerNumber__c = con.Frequent_Flyer_Number__c;
                    afp.FrequentFlyerTier__c = con.Frequent_Flyer_Tier__c;

                    // Added by Puru - QDCUSCON - 4522 -- START
                    if(mapPassIdToLegInfo != null && mapPassIdToLegInfo.containsKey(key)) {
                        afp.Boarding_Status__c = mapPassIdToLegInfo.get(key).boardingStatus;
                        afp.Cabin__c = mapPassIdToLegInfo.get(key).cabinClass;
                        afp.Flight_Leg_Flown_Statuses__c = mapPassIdToLegInfo.get(key).flightLegFlownStatus;
                    }
                    // Added by Puru - QDCUSCON - 4522 -- END

                    output.add(afp.passengerId__c);
                    lstAFP.add(afp);
                    mapPassId_Passenger.remove(key);
                }
            }
            System.debug(mapPassId_Passenger);

            //create Passenger without Contact
            for(String key : mapPassId_Passenger.keySet()){
                Map<String, Object> pass = mapPassId_Passenger.get(key);

                Affected_Passenger__c afp = new Affected_Passenger__c();
                afp.Name = (pass.get('prefix')!= null ? (pass.get('prefix') +' '):'')+ pass.get('firstName')+' '+pass.get('lastName');
                afp.firstName__c = String.ValueOf(pass.get('firstName'));
                afp.lastName__c = String.ValueOf(pass.get('lastName'));
                afp.PNR__c = cs.Booking_PNR__c;
                afp.case__c = cs.Id;
                afp.passengerId__c = key;
                afp.recordtypeId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'Insurance Letter');
                afp.FrequentFlyerNumber__c = String.ValueOf(pass.get('qantasFFNo'));

                // Added by Puru - QDCUSCON - 4522 -- START
                if(mapPassIdToLegInfo != null && mapPassIdToLegInfo.containsKey(key)) {
                    afp.Boarding_Status__c = mapPassIdToLegInfo.get(key).boardingStatus;
                    afp.Cabin__c = mapPassIdToLegInfo.get(key).cabinClass;
                    afp.Flight_Leg_Flown_Statuses__c = mapPassIdToLegInfo.get(key).flightLegFlownStatus;
                }
                // Added by Puru - QDCUSCON - 4522 -- END

                output.add(afp.passengerId__c);
                lstAFP.add(afp);
            }

            if(lstAFP.size() > 0){
                insert lstAFP;
                return output;
            }else{
                return output;
            }
            
        }catch(exception ex){
            System.debug(ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Add Passenger', 'QCC_DisplayPAXController', 
                                 'createAffectedPassenger', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        return new List<String>();
    }

    /*--------------------------------------------------------------------------------------       
    Method Name:        createAffectedPassenger
    Description:        Create new Affected Passenger when the checkbox is checked
    Parameter:          Using QCC_CaseCreatorV2 parameter
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<String> createAffectedPassengerV2(String caseId, List<String> listPass, Map<String, QCC_CaseCreatorV2.LegInformation> mapPassIdToLegInfo, Boolean isAutoCase){
        try{
            //get current Case
            Case cs = [Select id, Booking_PNR__c, TECH_bookingCreationDate__c, TECH_bookingArchivalData__c, TECH_BookingSegmentId__c, TECH_BookingSegmentTattoo__c 
                            from Case where id=:caseId limit 1];

            Map<String, String> mapQantasId_PassId = new Map<String,String>();
            //List<String> listEmptyQantasIs = new List<String>();
            Map<String, Map<String, Object>> mapPassId_Passenger = new Map<String, Map<String, Object>>();

            //parse data from client side
            for(String jsonStr : listPass){
                Map<String, Object> pass = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
                if(String.isBlank(String.valueOf(pass.get('qantasFFNo'))) || String.valueOf(pass.get('qantasFFNo')) != 'null'){
                    //listEmptyQantasIs.add(String.valueOf(pass.get('passengerId')));
                }else{
                    //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
                    mapQantasId_PassId.put(String.valueOf(pass.get('qantasFFNo')).replaceFirst('^0+',''), String.valueOf(pass.get('passengerId')));
                }
                
                mapPassId_Passenger.put(String.valueOf(pass.get('passengerId')), pass);
            }
            System.debug(mapPassId_Passenger.keySet());
            //filter out all the created affected passenger of the Case
            For(Affected_Passenger__c afp : [select name, id, firstname__c, lastname__c, passengerId__c 
                                            from affected_passenger__c where passengerId__c IN :mapPassId_Passenger.keyset() 
                                            AND case__c=:caseId]){
                if(mapPassId_Passenger.containsKey(afp.passengerId__c)){
                    mapPassId_Passenger.remove(afp.passengerId__c);
                }
            }
            System.debug(mapPassId_Passenger.keySet());
            System.debug(mapQantasId_PassId.keySet());

            // Added by Puru - QDCUSCON - 4522 -- START
            if(!isAutoCase) {
                mapPassIdToLegInfo = new Map<String, QCC_CaseCreatorV2.LegInformation>();
                String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
                System.debug(token);
                QCC_PNRLegStatusInfoWrapper flightPassenger = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(cs.Booking_PNR__c, cs.TECH_bookingCreationDate__c, '', '', token, false, cs.TECH_bookingArchivalData__c);
                
                System.debug('flightPassenger = '+flightPassenger);
                if(flightPassenger != null && flightPassenger.booking != null && flightPassenger.booking.passengerFlightStatus != null && flightPassenger.booking.passengerFlightStatus.size() > 0) {
                    for(QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus pfs: flightPassenger.booking.passengerFlightStatus) {
                        if(mapPassId_Passenger.containsKey(pfs.passengerId) && cs.TECH_BookingSegmentId__c == pfs.segmentId) {
                            QCC_CaseCreatorV2.LegInformation legInfo = new QCC_CaseCreatorV2.LegInformation();
                            if(String.isBlank(legInfo.cabinClass)) {
                                if(pfs.bookedCabinClass == 'P') {
                                    legInfo.cabinClass = 'First';
                                } else if(pfs.bookedCabinClass == 'J') {
                                    legInfo.cabinClass = 'Business';
                                } else if(pfs.bookedCabinClass == 'W') {
                                    legInfo.cabinClass = 'Premium Economy';
                                } else if(pfs.bookedCabinClass == 'Y') {
                                    legInfo.cabinClass = 'Economy';
                                }
                            }
                            
                            if(pfs.leg != null && pfs.leg.size() > 0) {
                                //////// Map Flight & Flight Passenger Details to Case /////
                                String flightLegFlownTable = '<html><table border="1" width="100%">';
                                flightLegFlownTable = flightLegFlownTable + '<thead><tr><th>Departure Airport</th><th>Arrival Airport</th><th>Status</th></tr></thead><tbody>';
                                
                                String boardingStatus = 'Boarded';
                                for(QCC_PNRLegStatusInfoWrapper.Leg leg: pfs.leg) {
                                    flightLegFlownTable = flightLegFlownTable + '<tr><td>'+leg.originAirportCode+'</td>';
                                    flightLegFlownTable = flightLegFlownTable + '<td>'+leg.destinationAirportCode+'</td>';
                                    
                                    if(leg.boardingStatusCode == 'NBD') {
                                        flightLegFlownTable = flightLegFlownTable + '<td>Not Flown</td></tr>';
                                        boardingStatus = 'Not Boarded';
                                    } else if(leg.boardingStatusCode == 'BDD') {
                                        flightLegFlownTable = flightLegFlownTable + '<td>Flown</td></tr>';
                                    }
                                }
                                flightLegFlownTable = flightLegFlownTable + '</tbody></table></html>';
                                legInfo.flightLegFlownStatus = flightLegFlownTable;
                                legInfo.boardingStatus = boardingStatus;
                            }
                            mapPassIdToLegInfo.put(pfs.passengerId, legInfo);
                        }
                        
                    }
                }
            }
            // Added by Puru - QDCUSCON - 4522 -- END
            //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
            List<Contact> lstCon = [select Id, Name, Cap_ID__c, Frequent_Flyer_Number__c, Frequent_Flyer_Tier__c from Contact where Frequent_Flyer_Number__c IN :mapQantasId_PassId.keyset()];
            List<Affected_Passenger__c> lstAFP = new List<Affected_Passenger__c>(); 
            List<String> output = new list<String>();

            //create Passenger with Contact
            for(Contact con : lstCon){
                //CRM-6433: qantasUniqueId field value was removed for PNR passengers info response.
                String key = String.ValueOf(mapQantasId_PassId.get(con.Frequent_Flyer_Number__c));
                if(mapPassId_Passenger.containsKey(key)){
                    Map<String, Object> pass = mapPassId_Passenger.get(key);

                    Affected_Passenger__c afp = new Affected_Passenger__c();
                    afp.Name = con.Name;
                    afp.Passenger__c = con.id;
                    afp.firstName__c = String.ValueOf(pass.get('firstName'));
                    afp.lastName__c = String.ValueOf(pass.get('lastName'));
                    afp.PNR__c = cs.Booking_PNR__c;
                    afp.case__c = cs.Id;
                    afp.passengerId__c = key;
                    afp.recordtypeId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'Insurance Letter');
                    afp.FrequentFlyerNumber__c = con.Frequent_Flyer_Number__c;
                    afp.FrequentFlyerTier__c = con.Frequent_Flyer_Tier__c;

                    // Added by Puru - QDCUSCON - 4522 -- START
                    if(mapPassIdToLegInfo != null && mapPassIdToLegInfo.containsKey(key)) {
                        afp.Boarding_Status__c = mapPassIdToLegInfo.get(key).boardingStatus;
                        afp.Cabin__c = mapPassIdToLegInfo.get(key).cabinClass;
                        afp.Flight_Leg_Flown_Statuses__c = mapPassIdToLegInfo.get(key).flightLegFlownStatus;
                    }
                    // Added by Puru - QDCUSCON - 4522 -- END

                    output.add(afp.passengerId__c);
                    lstAFP.add(afp);
                    mapPassId_Passenger.remove(key);
                }
            }
            System.debug(mapPassId_Passenger);

            //create Passenger without Contact
            for(String key : mapPassId_Passenger.keySet()){
                Map<String, Object> pass = mapPassId_Passenger.get(key);

                Affected_Passenger__c afp = new Affected_Passenger__c();
                afp.Name = (pass.get('prefix')!= null ? (pass.get('prefix') +' '):'')+ pass.get('firstName')+' '+pass.get('lastName');
                afp.firstName__c = String.ValueOf(pass.get('firstName'));
                afp.lastName__c = String.ValueOf(pass.get('lastName'));
                afp.PNR__c = cs.Booking_PNR__c;
                afp.case__c = cs.Id;
                afp.passengerId__c = key;
                afp.recordtypeId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'Insurance Letter');
                afp.FrequentFlyerNumber__c = String.ValueOf(pass.get('qantasFFNo'));

                // Added by Puru - QDCUSCON - 4522 -- START
                if(mapPassIdToLegInfo != null && mapPassIdToLegInfo.containsKey(key)) {
                    afp.Boarding_Status__c = mapPassIdToLegInfo.get(key).boardingStatus;
                    afp.Cabin__c = mapPassIdToLegInfo.get(key).cabinClass;
                    afp.Flight_Leg_Flown_Statuses__c = mapPassIdToLegInfo.get(key).flightLegFlownStatus;
                }
                // Added by Puru - QDCUSCON - 4522 -- END

                output.add(afp.passengerId__c);
                lstAFP.add(afp);
            }

            if(lstAFP.size() > 0){
                insert lstAFP;
                return output;
            }else{
                return output;
            }
            
        }catch(exception ex){
            System.debug(ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Add Passenger', 'QCC_DisplayPAXController', 
                                 'createAffectedPassenger', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        return new List<String>();
    }

    public class displayColumn{
        public String label{get;set;}
        public String fieldName{get;set;}
        public String type_x{get;set;}

        public displayColumn(String label, String fieldName, String inputType){
            this.label = label;
            this.fieldName = fieldName;
            this.type_x = inputType;
        }
    }

    public class PassengerInfoWrapper{
        public List<displayColumn> displayColumn{get;set;}
        public List<QCC_PNRPassengerInfoWrapper.Passengers> displayPassenger{get;set;}
    }
}