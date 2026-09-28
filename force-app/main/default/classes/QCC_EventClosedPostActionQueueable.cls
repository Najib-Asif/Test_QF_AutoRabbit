public class QCC_EventClosedPostActionQueueable implements Queueable , Database.AllowsCallouts{

	private List<Id> listIds;
    
    public QCC_EventClosedPostActionQueueable (List<Id> recordIds) {
        this.listIds = recordIds ;
    }

	public void execute(QueueableContext context) {
        try{
    		String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
    		//get list of Closed Event
    		List<Event__c> lstEvent = [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
    									ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, ArrivalPort__c,
    									RecordtypeId, Recordtype.DeveloperName, Recordtype.Name, DelayCostsCompleted__c, GlobalEventName__c 
    									From Event__c Where id In: this.listIds AND Status__c =: statusClosedEvent];
    		if(lstEvent.size() == 0){
    			return;
    		}
    		
            //get queue ids
            //String queueCostName = 'QCC_EventCostQueue';
            //Group costQueue;
            //if(String.isNotBlank(queueCostName)){
            //    costQueue = [select id from Group where type = 'Queue' and DeveloperName =: queueCostName];
            //}

            //String queueClosedName = 'QCC_EventClosedQueue';
            //Group closedQueue;
            //if(String.isNotBlank(queueClosedName)){
            //    closedQueue = [select id from Group where type = 'Queue' and DeveloperName =: queueClosedName];
            //}
            
            List<Event__c> updatePrimaryRootCause = new List<Event__c>();
            list<String> lstEventFlightFailure = new List<String>();
            //Map<String, Event__c> mapGlobalEvent = new Map<String, Event__c>();

            for(Event__c ev : lstEvent){
            	if(	ev.CloseAction__c == 'Event Auto-Closed'){
            		system.debug('auto close: '+ev.id);
            		//process autoclose Event
            		//ev.OwnerId = closedQueue.id;
            		updatePrimaryRootCause.add(ev);
            		lstEventFlightFailure.add(ev.id);

            	//}else if(  (ev.recordtype.DeveloperName =='GlobalEvent' || !String.isBlank(ev.GlobalEventName__c))
             //       && ev.Status__c == statusClosedEvent
             //       &&  (ev.CloseAction__c == 'Comms sent' 
             //           || ev.CloseAction__c == 'Comms not required' 
             //           || ev.CloseAction__c == 'Recoveries created and comms sent' )){
             //       //process global Event
             //       //
             //       system.debug('global event: '+ev.id);
             //       if(ev.DelayCostsCompleted__c == true){
             //           ev.OwnerId = closedQueue.id;
             //       }else{
             //           ev.OwnerId = costQueue.id;
             //       }

             //       mapGlobalEvent.put(ev.id, ev);
                }else if(	ev.recordtype.DeveloperName !='GlobalEvent'
            		&& ev.GlobalEvent__c == Null 
            		&& ev.Status__c == statusClosedEvent
            		&&  (ev.CloseAction__c == 'Comms sent' 
            			|| ev.CloseAction__c == 'Comms not required' 
            			|| ev.CloseAction__c == 'Recoveries created and comms sent' )){

            		//process closed Event
            		system.debug('closed event: '+ev.id);
                    //if(ev.DelayCostsCompleted__c == true){
                    //    ev.OwnerId = closedQueue.id;
                    //}else{
                    //    ev.OwnerId = costQueue.id;
                    //}
            		
            		updatePrimaryRootCause.add(ev);
            	}
            }
            System.debug(lstEventFlightFailure);
            //delete all Flight Failure related to Auto Closed Event
            /* List<FlightFailure__c> listDeleteFlightFailure = [select id from FlightFailure__c 
            													where Flight_Event__c In: lstEventFlightFailure];
            */

            //query all FLight Event associated with GlobalEvent
            //for(Event__c ev : [Select id, OwnerId, CloseAction__c, GlobalEvent__c, Status__c, Primary_Root_Cause__c,
    								//	ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, 
    								//	RecordtypeId, Recordtype.DeveloperName, Recordtype.Name , GlobalEventName__c
    								//	From Event__c Where GlobalEvent__c In: mapGlobalEvent.keyset() ]){
            //	System.debug(ev);
            //	ev.OwnerId = closedQueue.id;
            //	updatePrimaryRootCause.add(ev);
            //}

            

            //update Primary Root Cause
            if(updatePrimaryRootCause.size() > 0){
            	updatePrimaryRootCauseEvent(updatePrimaryRootCause);
            }

            //DML after call out
            /*if(listDeleteFlightFailure.size() > 0){
                delete listDeleteFlightFailure;
            }*/
            //update Global Event OwnerId
            //if(mapGlobalEvent.size() > 0 ){
            //    update mapGlobalEvent.values();
            //}
        }catch(exception ex){
            System.debug(ex.getStackTraceString());
            system.debug('Exception###'+ex.getMessage()); 
            system.debug('Exception###'+ex.getLineNumber()); 
        }

	}


	/*--------------------------------------------------------------------------------------       
    Method Name:        updatePrimaryRootCauseEvent
    Description:        Call to Flight Schedule API single sector flights
    Parameter:          Event listIds
    --------------------------------------------------------------------------------------*/  
   public void updatePrimaryRootCauseEvent(List<Event__c> events){

        try{
            System.debug('start getting Primary_Root_Cause__c');
        	Map<String, QCC_FlightInfoResponse> mapResponse = new Map<String, QCC_FlightInfoResponse>();
            for(event__c ev:events){
            	//create request for getting flight info
            	flightRequest fr = new flightRequest();

                if(fr.departureDate== null || fr.departureDate== ''){
                    if(ev.ScheduledDepDate__c != null){
                        String formatStr = Datetime.newInstance(ev.ScheduledDepDate__c, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                        fr.departureDate = formatStr;
                    }
                }
                if(fr.departurePort== null || fr.departurePort== ''){
                    if(!String.isBlank(ev.DeparturePort__c)){
                        fr.departurePort = ev.DeparturePort__c;
                    }
                }
                if(fr.arrivalPort== null || fr.arrivalPort== ''){
                    if(!String.isBlank(ev.ArrivalPort__c)){
                        fr.arrivalPort = ev.ArrivalPort__c;
                    }
                }
                if(fr.flightNo== null || fr.flightNo== ''){
                    if(!String.isBlank(ev.FlightNumber__c)){
                        String fightNumber = ev.FlightNumber__c;
                        //remove the prefis if needed (Usually 2 characters QF)
                        while(!GenericUtils.checkisNumeric(fightNumber)){
                            fightNumber = fightNumber.substring(1);
                        }
    
                        fr.flightNo = fightNumber;
                    }
                } 
                if(fr.carrier== null || fr.carrier== ''){
                    if(!String.isBlank(ev.FlightNumber__c)){
                        String carrier = ev.FlightNumber__c;  
                        fr.carrier = carrier.substring(0,2);
                    }
                }       

                //calling to Flight schedule api to get departure time and arrival time
	            if(!String.isBlank(fr.departureDate) && !String.isBlank(fr.departurePort) && !String.isBlank(fr.flightNo)){
	                String firKey = fr.toString();
	                QCC_FlightInfoResponse fir ;

	                //store the previous call out to elimiate number of call out
	                if(mapResponse.containsKey(firKey)){
	                	fir = mapResponse.get(firKey);
	                }else{
	                	fir = QCC_InvokeCAPAPI.invokeFlightInfoAPI(fr.departureDate, fr.departurePort, fr.flightNo, fr.arrivalPort, fr.carrier);	
	                	mapResponse.put(firKey, fir);
	                }

	                if(fir != null && fir.flights != null && fir.flights.size()>0){
	                    for(QCC_FlightInfoResponse.flight singleFlight :  fir.flights){
                            //delayDuration use for Primary root delay cause
                            Integer delayDuration = 0;
                            if(ev.FlightNumber__c.contains(singleFlight.marketingFlightNo)){
                                System.debug(LoggingLevel.ERROR, singleFlight);
                                //assign root cause
                                if(singleFlight.delay != null && singleFlight.delay.size() > 0){
                                    for(QCC_FlightInfoResponse.Delay delayReason : singleFlight.delay){
                                        if(delayDuration <= QCC_GenericUtils.stringToInteger(delayReason.delayDuration)){
                                            delayDuration = QCC_GenericUtils.stringToInteger(delayReason.delayDuration);
                                            ev.Primary_Root_Cause__c = QCC_GenericUtils.getDelayReason(delayReason.reasonCode , delayReason.shortDescription);
                                        }
                                    }
                                }
                            }   
	                    }
	                    system.debug('events##########'+ev);                                             
	                }
	            }
            }
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Event', 'QCC_EventClosedPostActionQueueable', 
                                    'updatePrimaryRootCauseEvent', String.valueOf(''), String.valueOf(''),false,'', ex);
        }finally{
        	System.debug(events);
            update events;
            System.debug(events);
        }       
    }

	public class flightRequest{
        public String departureDate{get;set;}
        public String departurePort{get;set;}
        public String arrivalPort{get;set;}
        public String flightNo{get;set;}
        public String carrier{get;set;}
        public flightRequest(){
            departurePort = '';
            departureDate = '';
            arrivalPort = '';
            flightNo = '';
            carrier = '';
        }
        public String toKey(){
        	return departurePort+'_'+departureDate+'_'+arrivalPort+'_'+flightNo+'_'+carrier;
        }
    }
}