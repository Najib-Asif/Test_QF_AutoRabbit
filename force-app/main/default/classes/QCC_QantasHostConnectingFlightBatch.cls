/*********************************************************************************
Name         : QCC_QantasHostConnectingFlightBatch
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE - GRAPHITE-1174
Created Date : 25 Oct 2019
Usages       : This class is used for populating connecting flight fields in Qantas Host record from matching flight
*********************************************************************************/
global class QCC_QantasHostConnectingFlightBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
	public String token;
    public String query;
    Qantas_API__c qantasAPI;
    Set<Id> qantasHostIds;  
    List<QCC_First_Host__c> qantasHostRecordsToUpdate = new List<QCC_First_Host__c>();
    
    global QCC_QantasHostConnectingFlightBatch(Set<Id> qantasHostIdSet){
		qantasHostIds = qantasHostIdSet;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //Build the Query
        //@todo: pull from SOQL setting query and scope 
        query = 'SELECT QCC_Arrival_Local_Date__c, QCC_Arrival_Local_Time__c, QCC_Frequent_Flyer_Number__c,QCC_Departure_Airport_Code__c,QCC_Departure_Local_Date__c, QCC_Flight_Departure_Time__c, QCC_Arrival_Airport_Code__r.Name '+
            	'FROM QCC_First_Host__C ' +
            	'WHERE id IN :qantasHostIds AND QCC_TECH_GetConnectingFlights__c = TRUE';
        if(Test.isRunningTest()){
            //Prevent more than one execute batch in test class
            query = query + ' LIMIT 1';
        }
        System.debug('>>>query: ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<QCC_First_Host__C> scope){
        try{
            Set<String> aiportCodeSet = new Set<String>();
            System.debug('>>>execute');
            String token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_CustomerRetrieveFlightsToken');
            System.debug('>>>token: '+token);
            qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CustomerRetrieveFlightsAPI');
            System.debug('>>>qantasAPI: '+qantasAPI);
            Map<Id,String> flightConnectingAirportCodesMap = new Map<Id,String>();
            
            for(QCC_First_Host__C qantasHostRecord : scope){
                System.debug('>>>qantasHostRecord: '+qantasHostRecord);
                //Datetime range for api callout
                Date qantasHostDate = qantasHostRecord.QCC_Departure_Local_Date__c;
                Time  qantasHostTime = qantasHostRecord.QCC_Flight_Departure_Time__c;
                
                //year, month, day, hour, min, sec,
                Datetime departueDateTime = Datetime.newInstance(qantasHostDate.year(), qantasHostDate.month(), qantasHostDate.day(), qantasHostTime.hour(), qantasHostTime.minute(), qantasHostTime.second());
                System.debug('>>>departueDateTime: '+departueDateTime);
                
                //Date range for callout is 23 hours before  departure datetime and 23 hours after
                Datetime fromDateTime =QCC_UtilityHelper.preventGmtConversion(departueDateTime); 
                Datetime toDateTime = fromDateTime.addHours(Integer.valueOf(Label.QCC_RetrieveConnectingFlight_Coverage_Hours));
                fromDateTime =  fromDateTime.addHours(Integer.valueOf('-'+Label.QCC_RetrieveConnectingFlight_Coverage_Hours));
                
                System.debug('>>>fromDateTime: '+fromDateTime);
                System.debug('>>>toDateTime: '+toDateTime);
                System.debug('>>>fromDateTime Timestamp: '+String.valueOf(fromDateTime.getTime()));
                System.debug('>>>toDateTime Timestamp: '+String.valueOf(fromDateTime.getTime()));
                
                System.debug('>>>callout retrieve connecting flight');
                QCC_CustomerFlightsWrapper.CustomerFlightsWrapper flightWrapper = QCC_InvokeCAPAPI.invokeRetrieveCustomerFlightsAPI(token,qantasAPI, qantasHostRecord.QCC_Frequent_Flyer_Number__c,fromDateTime,toDateTime);//'1900005073'
                
                Date arrivalQantasHostDate = qantasHostRecord.QCC_Arrival_Local_Date__c;
                Time  arrivalQantasHostTime = qantasHostRecord.QCC_Arrival_Local_Time__c;
                Datetime qantasHostarrivalDateTime = Datetime.newInstance(arrivalQantasHostDate.year(), arrivalQantasHostDate.month(), arrivalQantasHostDate.day(), arrivalQantasHostTime.hour(), arrivalQantasHostTime.minute(), arrivalQantasHostTime.second());
                qantasHostarrivalDateTime = QCC_UtilityHelper.preventGmtConversion(qantasHostarrivalDateTime); 
                
                if(flightWrapper !=  null){
                    for(QCC_CustomerFlightsWrapper.FlightsDetailWrapper flightInfo : flightWrapper.flights){
                        //*ReturnedFlight_DeparturePort = CurrentFlight_ArrivalPort AND 
                        //*ReturnedFlight_ScheduledDepartureTime > CurrentFlight_ScheduledArrivalTime AND
                        //* ReturnedFlight_ScheduledDepartureTime <= (CurrentFlight_ScheduledArrivalTime + 5 hours) 
                        Datetime flightDepartureDateTime = QCC_GenericUtils.convertStringtoDateTime(flightInfo.departureLocalDate, flightInfo.departureLocalTime);
                        flightDepartureDateTime = QCC_UtilityHelper.preventGmtConversion(flightDepartureDateTime); 
                        System.debug('>>>departureAirportCode: '+ flightInfo.departureAirportCode);
                        System.debug('>>qantasHostArrivalAirportCode: '+qantasHostRecord.QCC_Arrival_Airport_Code__r.Name);
                        System.debug('>>>qantasHostarrivalDateTime: '+qantasHostarrivalDateTime);
                        System.debug('>>>flightDepartureDateTime: '+flightDepartureDateTime); 
                        if(flightInfo.departureAirportCode == qantasHostRecord.QCC_Arrival_Airport_Code__r.Name &&
                            flightDepartureDateTime > qantasHostarrivalDateTime &&
                            flightDepartureDateTime <= qantasHostarrivalDateTime.addHours(5)
                          ){
                              System.debug('>>>found connecting flight');
                              qantasHostRecord.QCC_CONX_Flight_No__c = flightInfo.operatingFlightNumber; 
                              qantasHostRecord.QCC_CONX_Departure_Local_Date__c = flightInfo.departureLocalDate; 
                              qantasHostRecord.QCC_CONX_Scheduled_Departure_Date_Time__c = flightInfo.departureLocalTime; 
                              qantasHostRecord.QCC_TECH_GetConnectingFlights__c = FALSE;
                              // GRAPHITE-2185 : Additional Field to update on Qantas host related to connecting flight information
							  qantasHostRecord.QCC_CONX_PNR__c = flightInfo.reloc;

                              //Collect connecting flight departure and arrival airport codes
                              aiportCodeSet.add(flightInfo.arrivalAirportCode);
                              aiportCodeSet.add(flightInfo.departureAirportCode);
                              
                              //Map Qantas Host Id with departure and arrival airport codes
                              flightConnectingAirportCodesMap.put(qantasHostRecord.id, flightInfo.departureAirportCode +','+ flightInfo.arrivalAirportCode);
                              
                              qantasHostRecordsToUpdate.add(qantasHostRecord);
                          }
                    }
                }
                            
            }
            
            System.debug('>>>aiportCodeSet: '+aiportCodeSet);
            System.debug('>>>flightConnectingAirportCodesMap: '+flightConnectingAirportCodesMap);
            Map<String,Airport_Code__c> airportDetailMap = new Map<String,Airport_Code__c>();
            for(Airport_Code__c airport : [SELECT Id,Name FROM Airport_Code__c WHERE Name IN: aiportCodeSet]){
                airportDetailMap.put(airport.Name,airport);
            }
            
            System.debug('>>>airportDetailMap: '+airportDetailMap);
            Integer index = 0;
            for(QCC_First_Host__c qantasHost : qantasHostRecordsToUpdate){
                List<String> airportCodes =  flightConnectingAirportCodesMap.get(qantasHost.Id).split(',');
                System.debug('>>>airportCodes: '+ airportCodes);
                String departureAirport = airportCodes[0];
                String arrivalAirport = airportCodes[1];
                
                qantasHostRecordsToUpdate[index].QCC_CONX_Departure_Airport__c = airportDetailMap.containsKey(departureAirport) ? airportDetailMap.get(departureAirport).Id : null;
                qantasHostRecordsToUpdate[index].QCC_CONX_Arrival_Airport__c   = airportDetailMap.containsKey(arrivalAirport)   ? airportDetailMap.get(arrivalAirport).Id : null;
                    
                index = index + 1;
            }
            
            update qantasHostRecordsToUpdate;
            System.debug('>>>qantasHostRecordsToUpdate: '+qantasHostRecordsToUpdate);
        }catch(Exception ex){
            System.debug('>>>exception: '+ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC Qantas Host - Retrieve connecting flight', 'QCC_QantasHostConnectingFlightBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        List<id> qantasHostIdList = new List<id>();
        qantasHostIdList.addAll(qantasHostIds);
        if(qantasHostIdList.size() > 0 ){
            System.debug('>>>qantasHostIdList'+qantasHostIdList);
         	QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference(qantasHostIdList);   
        }
    }
  
}