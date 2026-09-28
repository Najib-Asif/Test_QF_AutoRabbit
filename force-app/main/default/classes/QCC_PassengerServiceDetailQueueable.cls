public class QCC_PassengerServiceDetailQueueable  implements Queueable , Database.AllowsCallouts{ 
    
    //Variables 
    public final Event__c objEvent;
    public final Integer pageNumber;
    public Integer counter;
    
    public QCC_PassengerServiceDetailQueueable(Event__c objEvent, Integer pageNumber, Integer counter){
        this.objEvent = objEvent;
        this.pageNumber = pageNumber;
        this.counter = counter;
    }
    
    public void execute(QueueableContext context) {
        Integer nextPage;
        String  flightStatus;
        Savepoint sp; 
        String operatingCarrier = this.objEvent.FlightNumber__c.left(2);
        String operatingFightNumber = this.objEvent.FlightNumber__c;
        //remove the prefis if needed (Usually 2 characters QF)
        while(!GenericUtils.checkisNumeric(operatingFightNumber)){
            operatingFightNumber = operatingFightNumber.substring(1);
        }
        String departureDate = Datetime.newInstance(this.objEvent.ScheduledDepDate__c, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
        
        QCC_PassengerServiceDetailsResponse passResponse;
        try{
            //Invoking the Passenger API
            passResponse = QCC_invokeCAPAPI.invokePassengerServiceDetails(operatingCarrier, operatingFightNumber, 
                                                                          departureDate, objEvent.DeparturePort__c, 
                                                                          objEvent.ArrivalPort__c, pageNumber);
            system.debug('passResponse########'+passResponse);
            if(passResponse != Null && passResponse.passenger != Null && passResponse.passenger.size()>0){
                nextPage = String.isNotBlank(passResponse.nextPageNo)?Integer.valueOf(passResponse.nextPageNo): Null;
                List<QCC_PassengerServiceDetailsResponse.Passenger> lstPassenger = passResponse.passenger;
                
                Map<String, QCC_PassengerServiceDetailsResponse.Passenger> mapAll = new Map<String, QCC_PassengerServiceDetailsResponse.Passenger>();
                for(QCC_PassengerServiceDetailsResponse.Passenger pass : passResponse.passenger){
                    mapAll.put(pass.passengerId, pass);
                }
                
                Map<String, Affected_Passenger__c> mapAllPassenger = fetchAllPassenger(objEvent.Id, mapAll.keySet());
                if(mapAllPassenger.isEmpty()){
                    return;
                }
                /*Map<String, String> mapKeywordCode_Text = new Map<String, String>();
                for(QantasConfigData__c cfg : [Select id, Name, Config_Description__c, Config_Value__c 
                                               FROM QantasConfigData__c WHere Config_Description__c='SSR Keyword']){
                                                   mapKeywordCode_Text.put(cfg.name, cfg.Config_Value__c);
                                               }
                */
                for(QCC_PassengerServiceDetailsResponse.Passenger pass : passResponse.passenger){
                    system.debug('pass########'+pass);
                    if(mapAllPassenger.containsKey(pass.PassengerId)){
                        Affected_Passenger__c afp = mapAllPassenger.get(pass.passengerId);
                        String keyword = afp.Special_Request__c;
                        if(String.isBlank(keyword)){
                            keyword = '';
                        }
                        //get all the keyword from response to assign for passenger
                        if(pass.mealService != null && pass.mealService.size() > 0){
                            for(QCC_PassengerServiceDetailsResponse.MealService item : pass.mealService){
                                if(!keyword.containsIgnoreCase(item.keyword) && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(item.keyword))){
                                    keyword += ';' + item.keyword;       
                                }                          
                            }
                        }
                        
                        if(pass.BaggageService != null && pass.BaggageService.size() > 0){
                            for(QCC_PassengerServiceDetailsResponse.BaggageService item : pass.BaggageService){
                                if(!keyword.containsIgnoreCase(item.keyword) && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(item.keyword))){
                                    keyword += ';' + item.keyword;       
                                }
                            }
                        }
                        
                        if(pass.seatService != null && pass.seatService.size() > 0){
                            for(QCC_PassengerServiceDetailsResponse.SeatService item : pass.seatService){
                                if(!keyword.containsIgnoreCase(item.keyword) && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(item.keyword))){
                                    keyword += ';' + item.keyword;       
                                }
                            }
                        }
                        
                        if(pass.documents != null && pass.documents.size() > 0){
                            for(QCC_PassengerServiceDetailsResponse.Documents item : pass.documents){
                                if(!keyword.containsIgnoreCase(item.keyword) && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(item.keyword))){
                                    keyword += ';' + item.keyword;       
                                }
                            }
                        }
                        
                        if(pass.otherService != null && pass.otherService.size() > 0){
                            for(QCC_PassengerServiceDetailsResponse.OtherService item : pass.otherService){
                                if(!keyword.containsIgnoreCase(item.keyword) && String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(item.keyword))){
                                    keyword += ';' + item.keyword;       
                                }
                            }
                        }
                        keyword = keyword.removeStart(';');
                        
                        afp.Special_Request__c = keyword;

                        //GRAPHITE-808 Include a logic for Chaffeur and Link PNR
                        if(pass.otherService != null && pass.otherService.size() > 0){
                            for(QCC_PassengerServiceDetailsResponse.OtherService item : pass.otherService){
                                List<String> chauffeurKeywords = QCC_UtilityHelper.getListFromString(Label.QCC_Passenger_Chauffeur_Keywords, ';');
                                if (chauffeurKeywords.contains(item.keyword)) {
                                    afp.QCC_Chauffeur_Drive__c = afp.QCC_Chauffeur_Drive__c != null ? afp.QCC_Chauffeur_Drive__c + ', ' + item.keyword : item.keyword;
                                }

                                List<String> linkPNRKeywords = QCC_UtilityHelper.getListFromString(Label.QCC_Passenger_Link_PNR_Keywords, ';');
                                if (linkPNRKeywords.contains(item.keyword)) {
                                    afp.QCC_Link_PNR__c = afp.QCC_Link_PNR__c != null ? afp.QCC_Link_PNR__c + ', ' + item.keyword : item.keyword;
                                }
                            }
                        }
                    }
                }
                
                //Save Point is Set Befor any DML operation
                sp = Database.setSavePoint();
                if(mapAllPassenger.values().size() > 0){
                    update mapAllPassenger.values();
                }
            }
            
            
            if(nextPage != Null){
                System.enqueueJob(new QCC_PassengerServiceDetailQueueable(objEvent, nextPage, counter));
            }else if(this.counter > 0){
                System.enqueueJob(new QCC_DeletePassengerForEvents(objEvent, this.counter));
            }
        }catch(Exception ex){
            if(sp != Null){
                Database.rollback(sp);
            }
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Passenger Detail API', 'QCC_PassengerServiceDetailQueueable', 
                                    'execute', String.valueOf(passResponse), String.valueOf(''), true,'', ex);
        }finally{
            //update Event
            if(nextPage == Null){
                  //GRAPHITE-1146 : Retrieve Connecting Flight for each Event Passenger
                QCC_PassengerConnectingFlightInvocable.retrieveCustomerFlight(new List<Event__c>{objEvent});
            }
        }
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchAllPassenger
    Description:        To Get all the existing Passenger for the event  
    Parameter:          Event Id
    --------------------------------------------------------------------------------------*/ 
    public static Map<String, Affected_Passenger__c> fetchAllPassenger(Id eventID, Set<String> passengerIds){
        
        Map<String, Affected_Passenger__c> mapAffectPassenger = new Map<String, Affected_Passenger__c>();
        for(Affected_Passenger__c objPassenger: [Select Id, PassengerId__c, Passenger__c, TECH_PostFlight__c, 
                                                 TECH_PreFlight__c, Counter__c, Special_Request__c, QCC_Chauffeur_Drive__c, QCC_Link_PNR__c  from Affected_Passenger__c
                                                 where Event__c =: eventID AND PassengerId__c IN : passengerIds])
        {
            mapAffectPassenger.put(objPassenger.PassengerId__c, objPassenger);
        }
        system.debug('1111111111111'+mapAffectPassenger);
        return mapAffectPassenger;
    }
}