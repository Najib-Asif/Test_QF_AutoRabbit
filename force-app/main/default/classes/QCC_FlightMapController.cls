public class QCC_FlightMapController {
	
	@AuraEnabled
	public static string fetchEmailContent(String recId){
		Event__c objEvent = [Select Id, FlightNumber__c, DeparturePort__c, ArrivalPort__c, ScheduledDepDate__c, 
							 DelayFailureCode__c, Non_Delay_Failure_Code__c from Event__c where Id =: recId];
		List<FlightViewWrapper> lstFlightWrap = new List<FlightViewWrapper>();
	    if(objEvent.ScheduledDepDate__c != null){
	    	String fillVal = '0';
        	String scheduleDate = objEvent.ScheduledDepDate__c.Year()+'-'+String.valueOf(objEvent.ScheduledDepDate__c.Month()).leftPad(2,fillVal)+'-'+String.valueOf(objEvent.ScheduledDepDate__c.Day()).leftPad(2,fillVal);
            String departureFrom = Datetime.newInstance(objEvent.ScheduledDepDate__c.addDays(-1), Time.newInstance(0,0,0,0)).format('YYYYMMddHHmm');
            String departureTo = Datetime.newInstance(objEvent.ScheduledDepDate__c.addDays(1), Time.newInstance(23,59,0,0)).format('YYYYMMddHHmm');
             
            system.debug('departureFrom$$$'+departureFrom);

	        if(!String.isBlank(departureFrom) && !String.isBlank(departureTo) && !String.isBlank(objEvent.FlightNumber__c)) 
	        {
	        	//Invoking Flight status API
	        	QCC_FlightStatusAPIResponse flightInfo = QCC_InvokeCAPAPI.invokeFlightStatusAPI(departureFrom, departureTo, objEvent.FlightNumber__c.substring(2, objEvent.FlightNumber__c.length()));

	        	if(flightInfo != Null){
	        		if(flightInfo.flights != null && flightInfo.flights.size()>0){
		                Boolean isFlightFound = false;
						QCC_FlightStatusAPIResponse.flight matchflight = null;

		                //Looping all the flights from the response 
		                for(QCC_FlightStatusAPIResponse.flight flight :  flightInfo.flights){
		                	if(flight.sectors != Null && flight.sectors.size()>0){
		                		for(QCC_FlightStatusAPIResponse.sector sector: flight.sectors){
		                			if(sector.from_x == objEvent.DeparturePort__c && sector.to == objEvent.ArrivalPort__c){
		                				String depSchedule =  sector.departure.scheduled.substringBefore('T');
		                				if(scheduleDate == depSchedule){
		                					matchflight = flight;
		                					break;
		                				}
		                			}
		                		}
		                		if(matchflight != null){
		                			break;
		                		}
		                	}
		                }

		                List<Date> lstDepDate = new List<Date>();
		                //Matched flight
		                if(matchflight != Null){
		                	for(QCC_FlightStatusAPIResponse.sector sector: matchflight.sectors){
		                		FlightViewWrapper flightviewWrap = new FlightViewWrapper();
		                		flightviewWrap.flightNumber = objEvent.FlightNumber__c;
		                		flightviewWrap.departurePort = sector.from_x;
		                		flightviewWrap.arrivalPort = sector.to;
		                		flightviewWrap.arrivalStatus = sector.arrival.status;
		                		flightviewWrap.depStatus = sector.departure.status;
		                		flightviewWrap.depDate = sector.departure.scheduled;
		                		String dateval = flightviewWrap.depDate.substringBefore('T');
		                		List<String> lstDate = dateval.split('-');
		                		Date mydate =  date.newInstance(Integer.valueOf(lstDate[0]), Integer.valueOf(lstDate[1]), Integer.valueOf(lstDate[2]));
		                		lstDepDate.add(mydate);
		                		lstFlightWrap.add(flightviewWrap);
		                	}
		                
			                Map<String, Event__c> mapevent = new Map<String, Event__c>();
			                if(lstDepDate != Null && lstDepDate.size() > 0){
			                	for(Event__c evnt: [select Id, Name, DeparturePort__c , ArrivalPort__c, DelayFailureCode__c, Non_Delay_Failure_Code__c
			                						 from Event__c where FlightNumber__c =: objEvent.FlightNumber__c 
			                		                and ScheduledDepDate__c IN: lstDepDate]){
			                		mapevent.put(evnt.DeparturePort__c+''+evnt.ArrivalPort__c, evnt);
			                	}
			                }

			                for(FlightViewWrapper flightviewWrap : lstFlightWrap){
			                	String key = flightviewWrap.departurePort+''+flightviewWrap.arrivalPort;
			                	Event__c evnt = mapevent != Null? mapevent.get(key): Null;
			                	if(evnt != Null){
			                		flightviewWrap.eventNumber = evnt.Name;
			                		flightviewWrap.eventLink = '/lightning/r/'+evnt.Id+'/view';
			                		flightviewWrap.eventId = evnt.Id;
			                		flightviewWrap.failures = String.isNotBlank(evnt.DelayFailureCode__c)?evnt.DelayFailureCode__c +';':'';
			                		flightviewWrap.failures += String.isNotBlank(evnt.Non_Delay_Failure_Code__c)?evnt.Non_Delay_Failure_Code__c:'';
			                	}
			                }
			            }
		            }
		        }
	        }
	        system.debug(lstFlightWrap);
	        return JSON.serialize(lstFlightWrap);
	    }

		return null;
	}

	public class FlightViewWrapper{
		String flightNumber;
		String departurePort;
		String arrivalPort;
		String eventNumber;
		String eventLink;
		string depStatus;
		string arrivalStatus;
		string depDate;
		String eventId;
		String failures;
	}

}