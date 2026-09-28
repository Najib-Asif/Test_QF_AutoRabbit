/*********************************************************************************
Name         : QCC_PassengerConnectingFlightBatch
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 August 2019
Usages       : This class is used to generate csv file and send upload it to Sharepoint
*********************************************************************************/
public class QCC_PassengerConnectingFlightBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{    
    public String token;
    public String query;
    Qantas_API__c qantasAPI;
    List<Id> passengerIdList;
    Id flightEventId;
    
    public QCC_PassengerConnectingFlightBatch(List<Id> passengerIds){
        passengerIdList = passengerIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
       	token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_CustomerRetrieveFlightsToken');
        qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CustomerRetrieveFlightsAPI');
        
        //Build the Query
        query = 'SELECT Id,Event__c,Event__r.Scheduled_Depature_UTC__c,Event__r.Scheduled_Arrival_UTC__c,Event__r.DeparturePort__c,Event__r.ArrivalPort__c,FrequentFlyerNumber__c, Event__r.ScheduledArrDateTime__c, Event__r.ScheduledDepDate__c, Event__r.ScheduledDepTime__c FROM Affected_Passenger__c WHERE ID IN: passengerIdList ';
        if(Test.isRunningTest()){
            //Prevent more than one execute batch in test class
            query = query + ' LIMIT 1';
        }
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Affected_Passenger__c> scope){
        String currentPassengerId = null; // Use for error Log
        try{
            system.debug('scope : '+scope);
            Set<String> marketingCarrierCodeSet = new Set<String>();
            marketingCarrierCodeSet.addAll(Label.QCC_Connecting_Flight_Marketing_Carrier_Code.split(';'));
            List<Affected_Passenger__c> passengerForUpdateList = new List<Affected_Passenger__c>();
            for(Affected_Passenger__c passenger : scope){
                currentPassengerId = passenger.Id;
                Datetime dateFrom = passenger.Event__r.Scheduled_Depature_UTC__c.addHours(Integer.valueOf('-'+Label.QCC_RetrieveConnectingFlight_Coverage_Hours));
                Datetime dateTo = passenger.Event__r.Scheduled_Arrival_UTC__c.addHours(Integer.valueOf(Label.QCC_RetrieveConnectingFlight_Coverage_Hours));
                flightEventId=passenger.Event__c;
                if(passenger.FrequentFlyerNumber__c == NULL || passenger.FrequentFlyerNumber__c == ''){
                    continue; // If passenger doenst have Frequent Flyer number do not proceed on retrieving connecting flight.
                }                
                QCC_CustomerFlightsWrapper.CustomerFlightsWrapper customerFlights = QCC_InvokeCAPAPI.invokeRetrieveCustomerFlightsAPI(token,qantasAPI, passenger.FrequentFlyerNumber__c,dateFrom,dateTo);//'1900005073'
                if(customerFlights != NULL){
                    system.debug('customerFlights: ' + customerFlights);
                    for(QCC_CustomerFlightsWrapper.FlightsDetailWrapper flightsInfo : customerFlights.flights){
                        
                        // Note: Only Connecting flights with Marketing Airline code(QF) are considered. OR values listed on Custom Label
                        if(!marketingCarrierCodeSet.contains(flightsInfo.marketingCarrierAlphaCode)){
                            continue;
                        }
                        
                        Integer marketingFlightNumber = Integer.valueOf(flightsInfo.marketingFlightNumber);
                        Datetime departureDateTime = QCC_UtilityHelper.preventGmtConversion(QCC_UtilityHelper.processDatetime(flightsInfo.departureLocalDate+' '+flightsInfo.departureLocalTime));
                        Datetime arrivalDateTime = QCC_UtilityHelper.preventGmtConversion(QCC_UtilityHelper.processDatetime(flightsInfo.arrivalLocalDate+' '+flightsInfo.arrivalLocalTime));
                        Datetime affectedArrivalDateTime = QCC_UtilityHelper.preventGmtConversion(QCC_UtilityHelper.processDatetime(passenger.Event__r.ScheduledArrDateTime__c));
                        //Datetime affectedDepartureDateTime = passenger.Event__r.Scheduled_Depature_UTC__c;
                        Date scheduledDepartureDate = passenger.Event__r.ScheduledDepDate__c;
                        String scheduledDepartureTime = passenger.Event__r.ScheduledDepTime__c;
                        //Convert the combination of the departure date and time (which is a text) into a DateTime field
                        DateTime affectedDepartureDateTime = DateTime.valueOf(scheduledDepartureDate.year() + '-' + scheduledDepartureDate.month() + '-' + scheduledDepartureDate.day() + ' ' + scheduledDepartureTime + ':00');
                        affectedDepartureDateTime = QCC_UtilityHelper.preventGmtConversion(affectedDepartureDateTime);

                        
                        System.debug('marketingFlightNumber: ' + marketingFlightNumber);
                        System.debug('departureDateTime: ' + departureDateTime);
                        System.debug('arrivalDateTime: ' + arrivalDateTime);
                        System.debug('affectedDepartureDateTime: ' + affectedDepartureDateTime);
                        System.debug('affectedArrivalDateTime: ' + affectedArrivalDateTime);
                        
                        String flightNumber = flightsInfo.marketingCarrierAlphaCode + flightsInfo.marketingFlightNumber;
                        
                        //CHECK INTENATION FLIGHT
                        if(marketingFlightNumber <= 300 || marketingFlightNumber >= 3000){
                            // SCENARIO 1 : International Inbound
                            //Returned_Flight_Number <= 399 OR Returned_Flight_Number >= 3000 AND            <----- marketingFlightNumber
                            //Returned_Flight_Arrival_Port = Affected_Flight_Departure_Port AND              <----- arrivalAirportCode ,Event__c.DeparturePort__c 
                            //Returned_Flight_Departure_Time < Affected_Flight_Departure_Time AND            <----- departureLocalDate + departureLocalTime, affectedDepartureDateTime
                            //Returned_Flight_Arrival_Time >= (Affected_Flight_Departure_Time - 12 hours)    <----- arrivalLocalDate + arrivalLocalTime , affectedDepartureDateTime
                            system.debug('INBOUND');
                            system.debug(flightsInfo.arrivalAirportCode+'  [con Arvl port = event Dep port] '+passenger.Event__r.DeparturePort__c);
                            system.debug(departureDateTime +' [con Dep time < event Dep time] '+ affectedDepartureDateTime);
                            system.debug(arrivalDateTime +' [con Arvl time >= event Dep time] '+ affectedDepartureDateTime.addHours(Integer.valueOf('-'+Label.QCC_ConnectingFlights_Coverage_Hours)));
                            if(flightsInfo.arrivalAirportCode == passenger.Event__r.DeparturePort__c &&
                               departureDateTime < affectedDepartureDateTime && 
                               arrivalDateTime >= affectedDepartureDateTime.addHours(Integer.valueOf('-'+Label.QCC_ConnectingFlights_Coverage_Hours)))
                            {
                                  System.debug('QCC_INTL_IN_CONX : ' + flightNumber);
                                  passenger.QCC_INTL_IN_CONX__c = flightNumber;
                            }
                            
                            // SCENARIO 2 : International Outbound
                            //Returned_Flight_Number <= 399 OR Returned_Flight_Number >= 3000 AND           <----- marketingFlightNumber
                            //Returned_Flight_Departure_Port = Affected_Flight_Arrival_Port AND             <----- departureAirportCode, Event__c.ArrivalPort__c
                            //Returned_Flight_Departure_Time > Affected_Flight_Arrival_Time AND             <----- departureLocalDate + departureLocalTime, affectedArrivalDateTime
                            //Returned_Flight_Departure_Time <= (Affected_Flight_Arrival_Time + 12 hours)   <----- departureLocalDate + departureLocalTime, affectedArrivalDateTime
                            system.debug('OUTBOUND');
                            system.debug(flightsInfo.departureAirportCode +' [con Dep port = event Arvl port] '+passenger.Event__r.ArrivalPort__c );
                            system.debug(departureDateTime +' [con Dep time > event Arvl time] '+ affectedArrivalDateTime );
                            system.debug(departureDateTime +' [con Dep time <= event Arvl time] '+ affectedArrivalDateTime.addHours(Integer.valueOf(Label.QCC_ConnectingFlights_Coverage_Hours)));
                            if(flightsInfo.departureAirportCode == passenger.Event__r.ArrivalPort__c &&
                               departureDateTime > affectedArrivalDateTime && 
                               departureDateTime <= affectedArrivalDateTime.addHours(Integer.valueOf(Label.QCC_ConnectingFlights_Coverage_Hours)))
                            {
                                  System.debug('QCC_INTL_OUT_CONX : ' + flightNumber);
                                  passenger.QCC_INTL_OUT_CONX__c = flightNumber;
                            }
                            
                        }
                        
                        // CHECK DOMESTIC FLIGHT
                        if(marketingFlightNumber >= 400 && marketingFlightNumber <= 2999){
                            // SCENARIO 3  : Domestic Inbound 
                            //Returned_Flight_Number >= 400 AND Returned_Flight_Number <= 2999 AND          <----- marketingFlightNumber
                            //Returned_Flight_Arrival_Port = Affected_Flight_Departure_Port AND             <----- arrivalAirportCode , Event__c.DeparturePort__c 
                            //Returned_Flight_Departure_Time < Affected_Flight_Departure_Time AND           <----- departureLocalDate + departureLocalTime, affectedDepartureDateTime
                            //Returned_Flight_Arrival_Time >= (Affected_Flight_Departure_Time - 12 hours)   <----- arrivalLocalDate + arrivalLocalTime , affectedDepartureDateTime
                            if(flightsInfo.arrivalAirportCode == passenger.Event__r.DeparturePort__c && 
                               departureDateTime < affectedDepartureDateTime && 
                               arrivalDateTime >= affectedDepartureDateTime.addHours(Integer.valueOf('-'+Label.QCC_ConnectingFlights_Coverage_Hours)))
                            {
                                System.debug('QCC_DOM_IN_CONX : ' + flightNumber);
                                passenger.QCC_DOM_IN_CONX__c = flightNumber;
                            }
                            
                            // SCENARIO 4 : Domestic Outbound
                            //Returned_Flight_Number >= 400 AND Returned_Flight_Number <= 2999 AND          <----- marketingFlightNumber
                            //Returned_Flight_Departure_Port = Affected_Flight_Arrival_Port AND             <----- departureAirportCode, Event__c.ArrivalPort__c
                            //Returned_Flight_Departure_Time > Affected_Flight_Arrival_Time AND             <----- departureLocalDate + departureLocalTime, affectedArrivalDateTime
                            //Returned_Flight_Departure_Time <= (Affected_Flight_Arrival_Time + 12 hours)   <----- departureLocalDate + departureLocalTime, affectedArrivalDateTime  
                            // QCC_DOM_OUT_CONX
                            if(flightsInfo.departureAirportCode == passenger.Event__r.ArrivalPort__c && 
                               departureDateTime > affectedArrivalDateTime && 
                               departureDateTime <= affectedArrivalDateTime.addHours(Integer.valueOf(Label.QCC_ConnectingFlights_Coverage_Hours)))
                            {
                                System.debug('QCC_DOM_OUT_CONX : ' + flightNumber);
                                passenger.QCC_DOM_OUT_CONX__c = flightNumber;
                            }
                            
                        }
                    }
                    passengerForUpdateList.add(passenger);
                } // EOF IF customerFlights != NULL
            }// EOF scope for loop
            if(passengerForUpdateList.size() > 0){
                update passengerForUpdateList;
            }
        } catch (Exception ex) {
            //TO-DO: Error Handling
            system.debug('ERROR : ' + ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Passenger Connecting Flights Batch Job', 'QCC_PassengerConnectingFlightBatch', 'execute', '', '', false, currentPassengerId, ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }     
    public void finish(Database.BatchableContext BC){
        // UPDATE QANTAS API FOR IF THERE's NEW TOKEN
        QCC_UtilityHelper.updateQantasAPIToken(CustomSettingsUtilities.getQantasCAPAPI('QCC_CustomerRetrieveFlightsToken'), token);
       if(BC.getJobId() != null){
           AsyncApexJob a = [Select Id, Status,JobType,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email,CreatedDate from AsyncApexJob where Id =:BC.getJobId()];
           if(a.JobType=='Batch Apex' && a.Status=='Completed')
           {
                List<Event__c> getEvent=[select id,IsRecoveryApproved__c from event__c where id=:flightEventId limit 1];
                if(getEvent!=null && getEvent.size()>0)
                {
                    getEvent.get(0).IsRecoveryApproved__c=true;
                    update getEvent;
                }
           }
       }
    }
}