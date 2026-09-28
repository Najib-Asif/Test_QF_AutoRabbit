/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Rest API Request Apex to create update Passenger and contact
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
11-June-2018      Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/QCCFlightEvent')
global with sharing class QCC_FlightMovementAPI  {

    /*----------------------------------------------------------------------------------------------      
    Method Name:        createFlightMovement
    Description:        Insert Flight Movement Record 
    Parameter:          
    Return:             
    ----------------------------------------------------------------------------------------------*/
    @HttpPost
    global static void createFlightMovement() {
        RestRequest req = RestContext.request;
        RestResponse res =  RestContext.response;
        try{
            Flight_Tracker__c objFlgTrack = new Flight_Tracker__c();
            String resBody;
            
            // Parse through the XML, determine the author and the characters
            String request = req.requestBody.toString();
            DOM.Document xmlDOC = new DOM.Document(); 
            xmlDOC.load(request); 
            DOM.XMLNode rootElement = xmlDOC.getRootElement();
            system.debug('child.getName()#####'+rootElement.getName());

            objFlgTrack = loopAllNodes(rootElement, objFlgTrack);
            Database.UpsertResult sr;
            system.debug('objFlgTrack########'+objFlgTrack);
            //Only if Valid data insert Flight Tracker
            if(String.isNotBlank(objFlgTrack.TrackerType__c) && 
                objFlgTrack.TrackerType__c != 'No Match' &&
                objFlgTrack.Scheduled_Depature_UTC__c != Null && 
                objFlgTrack.Scheduled_Arrival_UTC__c != Null)
            {
                system.debug('objFlgTrack########'+objFlgTrack);
                sr = database.upsert(objFlgTrack, true); 
            }else{
                res.statusCode = 400;
                resBody = 'Error returned: No Response from Dependent system';
            }

            
            
            // Inspect publishing result 
            if (sr != Null && sr.isSuccess()) {
                res.statusCode = 200;
                resBody = 'Flight Movement Created';
            } else if(sr != Null){
                for(Database.Error err : sr.getErrors()) {
                    system.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                    res.statusCode = 400;
                    resBody = 'Error returned: ' + err.getStatusCode() +' - ' + err.getMessage();
                }
            }
            res.responseBody = Blob.valueOf(resBody); 
            system.debug('res####'+res); 
        }catch(Exception ex){
            res.statusCode = 400;
            String resBody = 'Error returned: '+ ex.getMessage();
            res.responseBody = Blob.valueOf(resBody); 
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Flight Movement API', 'QCC_FlightMovementAPI', 
                                     'createFlightMovement', String.valueOf(req), String.valueOf(res), true,'', ex);
        }
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchFlightTracker
    Description:        Query Flight tracker based on Flight Number, originDate and Arrival Port
    Parameter:          ftkey(Airline+FlightNumbe+ArrivalPort+OriginDate)
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchFlightTracker(String ftKey){
        system.debug('ftKey####'+ftKey);
        List<Flight_Tracker__c> lstFT = [Select Id, TrackerType__c, Scheduled_Depature_UTC__c, Scheduled_Arrival_UTC__c,                                               Departure_Airport__c, Flight_Number__c, Origin_Date__c, MessageId__c, 
                                         Arrival_Airport__c, NewArrivalPort__c  from Flight_Tracker__c where 
                                          (Tech_CompositeId__c =: ftKey or Tech_CompositeId_Diverted__c  =: ftKey or 
                                           Tech_CompositeId_Diverted1__c  =: ftKey) ORDER BY LastModifiedDate DESC Limit 1 ];
        if(lstFT != Null && lstFT.size()>0){
            return lstFT[0];
        }
        return Null;
    }


    /*----------------------------------------------------------------------------------------------      
    Method Name:        loopAllNodes
    Description:        Loops the nodes from the QSOA Response
    Parameter:          All Nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c loopAllNodes(DOM.XMLNode node, Flight_Tracker__c objFlgTrack){
        String eventType;
        system.debug('EventName####'+node.getName());
        String port;
        for (Dom.XMLNode child: node.getChildElements()) {
            system.debug('child.getParent().getName()$$$$$'+child.getName());

            //Event Detail
            if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'eventDetails' ){
                for (Dom.XMLNode evnChild: child.getChildElements()) {
                    system.debug('evnChild.getParent().getName()$$$$$'+evnChild.getName());
                    if(evnChild.getName() == 'EventName'){
                        eventType = evnChild.getText().trim();
                    }

                    //Basic Mapping 
                    if (evnChild.getNodeType() == DOM.XMLNodeType.ELEMENT && evnChild.getName() == 'EventID' ){
                        objFlgTrack = fetchEventDetail(evnChild, objFlgTrack);
                    }
                    
                    //get the Port of the message 
                    if(evnChild.getNodeType() == DOM.XMLNodeType.ELEMENT && evnChild.getName() == 'ExternalID' ){
                        for(Dom.XMLNode extNodes: evnChild.getChildElements()){
                            if(extNodes.getName()=='Port'){
                                system.debug('Port of Even##'+extNodes.getText().trim());
                                port = extNodes.getText().trim();
                            }
                        }    
                    }
                }
                //Get the Existing Node
                Flight_Tracker__c objFTExist = fetchFlightTracker(objFlgTrack.Tech_CompositeId__c);
                if(objFTExist != Null){
                    objFlgTrack = objFTExist;
                }else{
                    //Invoke Flight Status 
                    //departureDate, departurePort, flightNo, arrivalPort, carrier
                    objFlgTrack = QCC_FlightTrackerInformationAPI.invokeFlightStatus(objFlgTrack);
                    //Invoke Flight API from CAP

                    if(eventType != 'FLIGHT_PLAN'){
                        objFlgTrack = QCC_FlightTrackerInformationAPI.invokeFlightAPI(objFlgTrack);
                    }
                }       
            }
            system.debug('eventType$$$$$'+eventType);
            system.debug('objFlgTrack$$$$$'+objFlgTrack);
            
            //Adding Event Name
            objFlgTrack.Event_Name__c = eventType;
            //Flight Plan Event
            if(eventType == 'FLIGHT_PLAN'){
                //Leg Detail Information
                if (child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'FlightLegDetails' ){
                    objFlgTrack = fetchFlightPlanDetail(child, objFlgTrack);  
                }

                //Add Message ID to determine AddStop
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    objFlgTrack = addMessageId(child, objFlgTrack);
                    //Check for Add_Stop
                    objFlgTrack = addStopTrackerMerge(objFlgTrack, 'FlightPlan');
                    if(objFlgTrack.Event_Name__c =='ADD_STOP'){
                        eventType = 'ADD_STOP';
                    }
                }
            }
            system.debug('objFlgTrack1111$$$$$'+objFlgTrack);

            //Blocks OFF Event
            if(eventType == 'BLOCKS_OFF'){
                system.debug('child.getName()#####'+child.getName());
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    system.debug('depPort###'+port);
                    system.debug('objFlgTrack.Departure_Airport__c###'+objFlgTrack);
                    if(objFlgTrack.Departure_Airport__c == port){
                        objFlgTrack = fetchBlocksOffDetail(child, objFlgTrack);
                    }
                }
            }

            //Blocks ON Event
            if(eventType == 'BLOCKS_ON'){
                system.debug('child.getName()#####'+child.getName());
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    if(String.isNOTBlank(objFlgTrack.NewArrivalPort__c) && objFlgTrack.NewArrivalPort__c == port){
                        objFlgTrack = fetchBlocksOnDetail(child, objFlgTrack);
                    }
                    else if(String.isBlank(objFlgTrack.NewArrivalPort__c) && objFlgTrack.Departure_Airport__c == port){
                        objFlgTrack = fetchBlocksOnDetail(child, objFlgTrack);
                    }
                }
            }

            //Delay Event
            if(eventType == 'ESTIMATE_CHANGE'){
                system.debug('child.getName()#####'+child.getName());
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    objFlgTrack = fetchEstimateChange(child, objFlgTrack);
                }
            }

            //Delay Event
            if(eventType == 'SCHEDULE_CHANGE'){
                system.debug('child.getName()#####'+child.getName());
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    objFlgTrack = fetchScheduleChange(child, objFlgTrack);
                }
            }

            //Cancellation Event
            if(eventType == 'FLIGHT_CANCEL'){
                system.debug('Flight is Cancelled');
                //Add Message ID to determine AddStop
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    objFlgTrack = addMessageId(child, objFlgTrack);
                    //Check for Add_Stop
                    objFlgTrack = addStopTrackerMerge(objFlgTrack, 'FlightCancelled');
                    if(objFlgTrack.Event_Name__c =='ADD_STOP'){
                        eventType = 'ADD_STOP';
                        objFlgTrack.Flight_Status__c = '';
                    }
                }
            }

            //Diversion Event
            if(eventType == 'AIR_DIVERSION'){
                system.debug('child.getName()#####'+child.getName());
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    objFlgTrack = fetchAirDiversionDetail(child, objFlgTrack);
                }
            }

            //AirReturn Event 
            if(eventType == 'AIR_RETURN'){
                if(child.getNodeType() == DOM.XMLNodeType.ELEMENT && child.getName() == 'subEvents'){
                    objFlgTrack = fetchAirReturnDetail(child, objFlgTrack);
                }
            }
            
            //Ground Return
            if(eventType == 'GROUND_RETURN'){
                objFlgTrack.Actual_Departure_UTC__c = Null;
                objFlgTrack.ActualDepaDateTime__c = '';
            }

        }
        return objFlgTrack;
    }

    
    //Generic Flight Events 
    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchEventDetail
    Description:        Generic Flight Events, This node is present all the responses sent by QSOA
    Parameter:          Event Detail Node and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchEventDetail(DOM.XMLNode eventNode, Flight_Tracker__c objFlgTrack){
        system.debug('node.getName()$$$$$'+eventNode.getName());
        for(Dom.XMLNode node: eventNode.getChildElements()){
            if(node.getName()=='Airline'){
                system.debug('Airline'+node.getText().trim());
                //objFlgTrack.AirlinePrimary__c = node.getText().trim();
                if(objFlgTrack.Airline__c == Null || String.isBlank(objFlgTrack.Airline__c)){
                    objFlgTrack.Airline__c = node.getText().trim() =='QFA'?'QF':'';
                }
            }
            if(node.getName()=='FlightNumber'){
                system.debug('FlightNumber'+node.getText().trim());
                objFlgTrack.Flight_Number__c = QCC_GenericUtils.formatFlightNumber(node.getText().trim());
            }
            if(node.getName()=='Date'){
                system.debug('Date'+node.getText().trim());
                objFlgTrack.Origin_Date__c = Date.valueOf(node.getText().trim());
            }
            if(node.getName()=='ArrivalAirport'){
                system.debug('ArrivalAirport'+node.getText().trim());
                objFlgTrack.Arrival_Airport__c = node.getText().trim();
            }
            if(node.getName()=='DepartureAirport'){
                system.debug('DepartureAirport'+node.getText().trim());
                objFlgTrack.Departure_Airport__c = node.getText().trim();
            }
        }
        String compositeId = objFlgTrack.Flight_Number__c + '' + objFlgTrack.Origin_Date__c + '' + objFlgTrack.Arrival_Airport__c + '' + objFlgTrack.Departure_Airport__c;
        objFlgTrack.Tech_CompositeId__c = compositeId;
        return objFlgTrack;
    }


    //Flight Plan Event, Flight Type D/I and Schedule Departure and Arrival Innfo
    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchFlightPlanDetail
    Description:        Flight Plan Event, Flight Type D/I and Schedule Departure and Arrival Innfo
    Parameter:          Specific to Flight Plan nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchFlightPlanDetail(DOM.XMLNode node, Flight_Tracker__c objFlgTrack){
        //Estimate Delay Change 
        for(Dom.XMLNode legChild: node.getChildElements()){
            if(legChild.getNodeType() == DOM.XMLNodeType.ELEMENT && legChild.getName() == 'Identifier'){
                for(Dom.XMLNode identifier: legChild.getChildElements()){
                    if(identifier.getName()=='FlightClassification'){
                        system.debug('FlightClassification'+identifier.getText().trim());
                        objFlgTrack.IntDom__c = identifier.getText().trim();
                    }
                   /* if(identifier.getName()=='FlightClassification'){
                        system.debug('FlightClassification'+identifier.getText().trim());
                        objFlgTrack.FlightClassification__c = identifier.getText().trim();
                    }
                    if(identifier.getName()=='FlightClassification'){
                        system.debug('FlightClassification'+identifier.getText().trim());
                        objFlgTrack.FlightClassification__c = identifier.getText().trim();
                    }*/
                    for(Dom.XMLNode code: identifier.getChildElements()){
                        if(code.getName()=='Airline2'){
                            system.debug('Airline2'+code.getText().trim());
                            objFlgTrack.Airline__c = code.getText().trim();
                        }
                    }
                }    
            }

            if(legChild.getNodeType() == DOM.XMLNodeType.ELEMENT && legChild.getName() == 'Departure'){
                for(Dom.XMLNode depature: legChild.getChildElements()){
                    if(depature.getName()=='Schedule'){
                        system.debug('depature time'+depature.getText().trim());
                        objFlgTrack.ScheduledDepTime__c = depature.getText().trim();
                        objFlgTrack.Scheduled_Depature_UTC__c = GenericUtils.parseStringToUTC(objFlgTrack.ScheduledDepTime__c);
                    }
                } 
            }

            if(legChild.getNodeType() == DOM.XMLNodeType.ELEMENT && legChild.getName() == 'Arrival'){
                for(Dom.XMLNode arrival: legChild.getChildElements()){
                    if(arrival.getName()=='Schedule'){
                        system.debug('arrival time'+arrival.getText().trim());
                        objFlgTrack.ScheduledArrDateTime__c = arrival.getText().trim();
                        objFlgTrack.Scheduled_Arrival_UTC__c = GenericUtils.parseStringToUTC(objFlgTrack.ScheduledArrDateTime__c);
                    }
                } 
            }
            String acGroup;
            String acType;

            if(legChild.getNodeType() == DOM.XMLNodeType.ELEMENT && legChild.getName() == 'Operation'){
                for(Dom.XMLNode operation: legChild.getChildElements()){
                    if(operation.getName()=='AircraftGroup'){
                        system.debug('AircraftGroup'+operation.getText().trim());
                        acGroup = operation.getText().trim();
                    }
                    if(operation.getName()=='AircraftType'){
                        system.debug('AircraftType'+operation.getText().trim());
                        acType = operation.getText().trim();
                    }
                    if(operation.getName()=='AircraftRegistration'){
                        system.debug('AircraftRegistration'+operation.getText().trim());
                        objFlgTrack.Aircraft_Registration__c = operation.getText().trim();
                    }
                } 
            }
            objFlgTrack.Aircraft_Type__c = acGroup+'-'+acType;
        }
        return objFlgTrack;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchEstimateChange
    Description:        Estimate change on Arrival or Departure
    Parameter:          Specidic to Estimate Change nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchEstimateChange(DOM.XMLNode estimate, Flight_Tracker__c objFlgTrack){
        system.debug('estimate$$$$$'+estimate.getName());
        for(Dom.XMLNode estimateInfo: estimate.getChildElements()){
            system.debug('estArrival'+estimateInfo.getName());
            if(estimateInfo.getNodeType() == DOM.XMLNodeType.ELEMENT && estimateInfo.getName() == 'otherDetails'){
                for(Dom.XMLNode estimateNode: estimateInfo.getChildElements()){
                    system.debug('estArrival'+estimateNode.getName());
                    
                    if(estimateNode.getNodeType() == DOM.XMLNodeType.ELEMENT && estimateNode.getName() == 'ArrivalTimeDetails'){
                        for(Dom.XMLNode estArrival: estimateNode.getChildElements()){
                            if(estArrival.getName()=='newTime'){
                                system.debug('estArrival'+estArrival.getText().trim());
                                objFlgTrack.EstimatedArrDateTime__c = estArrival.getText().trim();
                            }
                        }
                    }

                    if(estimateNode.getNodeType() == DOM.XMLNodeType.ELEMENT && estimateNode.getName() == 'departureTimeDetails'){
                        for(Dom.XMLNode estDeparture: estimateNode.getChildElements()){
                            if(estDeparture.getName()=='newTime'){
                                system.debug('estDeparture'+estDeparture.getText().trim());
                                objFlgTrack.EstimatedDepDateTime__c = estDeparture.getText().trim();
                            }
                        }
                    }
                }

            }
        }
        return objFlgTrack;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchScheduleChange
    Description:        Schedule change on Arrival or Departure
    Parameter:          Specidic to Schedule change nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchScheduleChange(DOM.XMLNode estimate, Flight_Tracker__c objFlgTrack){
        system.debug('estimate$$$$$'+estimate.getName());
        for(Dom.XMLNode estimateInfo: estimate.getChildElements()){
            system.debug('estArrival'+estimateInfo.getName());
            if(estimateInfo.getNodeType() == DOM.XMLNodeType.ELEMENT && estimateInfo.getName() == 'otherDetails'){
                for(Dom.XMLNode estimateNode: estimateInfo.getChildElements()){
                    system.debug('estArrival'+estimateNode.getName());
                    
                    if(estimateNode.getNodeType() == DOM.XMLNodeType.ELEMENT && estimateNode.getName() == 'ArrivalTimeDetails'){
                        for(Dom.XMLNode estArrival: estimateNode.getChildElements()){
                            if(estArrival.getName()=='newTime'){
                                system.debug('estArrival'+estArrival.getText().trim());
                                objFlgTrack.ScheduledArrDateTime__c = estArrival.getText().trim();
                            }
                        }
                    }

                    if(estimateNode.getNodeType() == DOM.XMLNodeType.ELEMENT && estimateNode.getName() == 'departureTimeDetails'){
                        for(Dom.XMLNode estDeparture: estimateNode.getChildElements()){
                            if(estDeparture.getName()=='newTime'){
                                system.debug('estDeparture'+estDeparture.getText().trim());
                                objFlgTrack.ScheduledDepTime__c = estDeparture.getText().trim();
                            }
                        }
                    }
                }

            }
        }
        return objFlgTrack;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchBlocksOffDetail
    Description:        Actual Departure Time
    Parameter:          Specific to Blocks off nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchBlocksOffDetail(DOM.XMLNode blocksOffEvn, Flight_Tracker__c objFlgTrack){
        system.debug('blocksOffNode$$$$$'+blocksOffEvn.getName());
        for(Dom.XMLNode blocksOffNode: blocksOffEvn.getChildElements()){
             if(blocksOffNode.getNodeType() == DOM.XMLNodeType.ELEMENT && blocksOffNode.getName() == 'subEventDetails'){
                for(Dom.XMLNode actual: blocksOffNode.getChildElements()){
                    if(actual.getName()=='SubEventTime'){
                        system.debug('subEventDetails'+actual.getText().trim());
                        objFlgTrack.ActualDepaDateTime__c = actual.getText().trim();

                    }
                }
            }
        }
        return objFlgTrack;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchBlocksOnDetail
    Description:        Actual Arrival Time
    Parameter:          Specific to Blocks ON nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchBlocksOnDetail(DOM.XMLNode blocksOnEvn, Flight_Tracker__c objFlgTrack){
        system.debug('blocksOnEvnNode$$$$$'+blocksOnEvn.getName());
        for(Dom.XMLNode blocksOnNode: blocksOnEvn.getChildElements()){
             if(blocksOnNode.getNodeType() == DOM.XMLNodeType.ELEMENT && blocksOnNode.getName() == 'subEventDetails'){
                for(Dom.XMLNode actual: blocksOnNode.getChildElements()){
                    if(actual.getName()=='SubEventTime'){
                        system.debug('subEventDetails'+actual.getText().trim());
                        objFlgTrack.ActualArriDateTime__c = actual.getText().trim();
						
                    }
                }
            }
        }
        return objFlgTrack;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchAirDiversionDetail
    Description:        Air Diversion related events 
    Parameter:          Specific to Diversion nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchAirDiversionDetail(DOM.XMLNode airDiversion, Flight_Tracker__c objFlgTrack){
        for(Dom.XMLNode diversion: airDiversion.getChildElements()){
            if(diversion.getNodeType() == DOM.XMLNodeType.ELEMENT && diversion.getName() == 'arrivalAirport' && diversion.getParent().getName() == 'movement'){
                for(Dom.XMLNode divPort: diversion.getChildElements()){
                    if(divPort.getName()=='airportCode'){
                        system.debug('airportCode'+divPort.getText().trim());
                        objFlgTrack.NewArrivalPort__c = divPort.getText().trim();
                    }
                }    
            }
            else if(diversion.getNodeType() == DOM.XMLNodeType.ELEMENT && diversion.getName() == 'SubEventName' && diversion.getParent().getName() == 'subEventDetails'){
                system.debug('Diversion sub Type'+diversion.getText().trim());
                objFlgTrack.Sub_Event_Name__c = diversion.getText().trim();
            }
            else{
                fetchAirDiversionDetail(diversion, objFlgTrack);
            }
        }
        return objFlgTrack;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        fetchAirReturnDetail
    Description:        Air Return related events 
    Parameter:          Specific to Air return nodes and Flight_Tracker__c object
    Return:             Flight_Tracker__c
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c fetchAirReturnDetail(DOM.XMLNode airReturn, Flight_Tracker__c objFlgTrack){
        for(Dom.XMLNode airRet: airReturn.getChildElements()){
            if(airRet.getNodeType() == DOM.XMLNodeType.ELEMENT && airRet.getName() == 'ArrivalTimeDetails' && airRet.getParent().getName() == 'otherDetails'){
                for(Dom.XMLNode newTimeArr: airRet.getChildElements()){
                    if(newTimeArr.getName()=='newTime'){
                        system.debug('UPDATED ARRIVAL TIME'+newTimeArr.getText().trim());
                        objFlgTrack.EstimatedArrDateTime__c = newTimeArr.getText().trim();
                    }
                } 
                fetchAirReturnDetail(airRet, objFlgTrack);   
            }
            else if(airRet.getNodeType() == DOM.XMLNodeType.ELEMENT && airRet.getName() == 'departureTimeDetails' && airRet.getParent().getName() == 'otherDetails'){
                for(Dom.XMLNode newTimeDep: airRet.getChildElements()){
                    if(newTimeDep.getName()=='newTime'){
                        system.debug('UPDATED Depature TIME'+newTimeDep.getText().trim());
                        objFlgTrack.EstimatedDepDateTime__c = newTimeDep.getText().trim();
                    }
                }
                fetchAirReturnDetail(airRet, objFlgTrack);    
            }
            else{
                fetchAirReturnDetail(airRet, objFlgTrack);
            }
        }
        return objFlgTrack;
    }

    public static Flight_Tracker__c addMessageId(DOM.XMLNode msgNode, Flight_Tracker__c objFlgTrack){
        for(Dom.XMLNode msg: msgNode.getChildElements()){
            if(msg.getNodeType() == DOM.XMLNodeType.ELEMENT && msg.getName() == 'otherDetails' && msg.getParent().getName() == 'subEvents'){
                for(Dom.XMLNode msgId: msg.getChildElements()){
                    if(msgId.getName()=='OGSMessageID'){
                        system.debug('msgId$$$$'+msgId.getText().trim());
                        objFlgTrack.MessageId__c = msgId.getText().trim();
                    }
                }
            }
        }
        return objFlgTrack;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:        addStopTrackerMerge
    Description:        Add Stop Event is not direct from QSOA, its idetermined based on Flight Plan and Cancellation
    Parameter:          Flight_Tracker__c object
    Return:             Flight_Tracker__c object
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c addStopTrackerMerge(Flight_Tracker__c objFT, String currentMsg){
        //Flight_Tracker__c objFt = objFlgTrack;
        List<Flight_Tracker__c> lstFT = new List<Flight_Tracker__c>();
        lstFT.add(objFT);

        for(Flight_Tracker__c objFlgTrack: [select Id,Flight_Number__c, Event_Name__c, Departure_Airport__c , Arrival_Airport__c, 
                                            Origin_Date__c, TrackerType__c, MessageId__c, Scheduled_Arrival_UTC__c, Scheduled_Depature_UTC__c
                                            from Flight_Tracker__c where  Flight_Number__c =: objFt.Flight_Number__c and 
                                            Origin_Date__c =: objFT.Origin_Date__c and MessageId__c =: objFT.MessageId__c])
        {
            lstFT.add(objFlgTrack);
        }
       
        system.debug('lstFT'+lstFT);
        if(lstFT != Null && lstFT.size()==3){
            Set<String> setDepPort = new Set<String>();
            Set<String> setArrPort = new Set<String>();
            List<Flight_Tracker__c> lstDelFT = new List<Flight_Tracker__c>();
            for(Flight_Tracker__c objFlgTrack: lstFT){
                setDepPort.add(objFlgTrack.Departure_Airport__c);
                setArrPort.add(objFlgTrack.Arrival_Airport__c);
                if(objFlgTrack.Event_Name__c == 'FLIGHT_CANCEL'){
                    objFT = objFlgTrack;
                }else if(objFlgTrack.Event_Name__c == 'FLIGHT_PLAN'){
                    if(objFlgTrack.Id != Null){
                        lstDelFT.add(objFlgTrack);
                    }
                }
            } 

            if(setDepPort.size() == 2 && setArrPort.size() == 2){
                setDepPort.remove(objFT.Departure_Airport__c);
                setArrPort.remove(objFT.Arrival_Airport__c);
                if(setDepPort.size() == 1 && setArrPort.size() == 1 && setDepPort.equals(setArrPort)){
                    delete lstDelFT;
                    List<String> lstDiv = new List<String>();
                    lstDiv.addAll(setDepPort);
                    objFT.NewArrivalPort__c = lstDiv[0];
                    objFT.Event_Name__c = 'ADD_STOP';
                }
            } 
        }
        return objFT;
    }


    
}