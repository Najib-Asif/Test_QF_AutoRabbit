public class QCC_AddEventstoGlobalEventController {
    
    @AuraEnabled
    public static DataInitWrapper getFieldSets(Id recordId){ //GRAPHITE-496: Added Id to retrieve the record's record type
        
        Event__c record = [SELECT Id, RecordTypeId, RecordType.Name, Affected_Ports__c, Start_Date__c, QCC_Local_Start_Time__c, End_Date__c, QCC_Local_End_Time__c FROM Event__c WHERE Id =: recordId];
        System.debug('==record.RecordType.Name==' + record.RecordType.Name);
        System.debug('==record.RecordTypeId==' + record.RecordTypeId);
        DataInitWrapper dataInitWrapper = new DataInitWrapper();

        //GRAPHITE-496: if record type is "Global Heads Up", then display different set of fields
        if (record.RecordTypeId == GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('QCC Flight Event Global Heads Up'))) {
            dataInitWrapper.listFieldSets = getFieldSetMember('Event__c','QCC_GlobalHeadsUp_SearchableFields', record);
            dataInitWrapper.columnSets = getColumns('QCC_AddEventstoGlobalHeadsUpEvent');
        } else {
            dataInitWrapper.listFieldSets = getFieldSetMember('Event__c','QCC_SearchableFields', null);
        dataInitWrapper.columnSets = getColumns('QCC_AddEventstoGlobalEvent');
        }
        //dataInitWrapper.listFieldSets = getFieldSetMember('Event__c','QCC_SearchableFields');
        //dataInitWrapper.columnSets = getColumns('QCC_AddEventstoGlobalEvent');


        System.debug('==dataInitWrapper.listFieldSets==' + dataInitWrapper.listFieldSets);
        System.debug('==dataInitWrapper.columnSets==' + dataInitWrapper.columnSets);
        
        return dataInitWrapper;
    }
    
    @AuraEnabled
    public static List<Event__c> getDataEvents(String lstFieldSetMemberStr, String lstColumnsStr){
        try{
            //get list field+condition for flight event search
            List<FieldSetMemberWrapperClass> lstFieldSetMember = (List<FieldSetMemberWrapperClass>)JSON.deserialize(lstFieldSetMemberStr,List<FieldSetMemberWrapperClass>.class);
            List<DisplayColumn> lstColumns = (List<DisplayColumn>)JSON.deserialize(lstColumnsStr,List<DisplayColumn>.class);
            //build flight event search query //GRAPHITE-496: Added Record Type field on the query to be able to check it and prevent scenarios not applicable to Global Heads Up event
            String sqlStr = 'SELECT Id, Name, TECH_FlightTrackerId__c, ScheduledDepDate__c, Scheduled_Departure__c, ScheduledDepTime__c, ArrivalPort__c, DeparturePort__c, FlightNumber__c, Primary_Root_Cause__c, RecordTypeName__c, QCC_Number_of_SSUs__c, QCC_Number_of_VIPs__c';
            //GRAPHITE-496: Capture the Local Time and End Time of the Global Heads Up to be used for filtering out flight events that are scheduled on the same Departure Date,
            //BUT not within the time set
            DateTime eventStartDateTime = null;
            DateTime eventEndDateTime = null;

            for(displayColumn item : lstColumns){
                if(sqlStr.indexOf(item.fieldName) == -1){ 
                    sqlStr += ',' + item.fieldName;
                }
            }
            sqlStr += ' FROM Event__c ';
            String sqlConditions = '';
            for(Integer i = 0; i < lstFieldSetMember.size(); i++){
                FieldSetMemberWrapperClass item = lstFieldSetMember[i];
                
                if(String.isNotBlank(item.fieldValue)){
                    if(item.fieldType.toUpperCase() == 'DATETIME'){
                        if(item.isFromDateTime){
                            System.debug(item.fieldValue);
                            DateTime gmtDateTimeFrom = parseStringToGMT(item.fieldValue);
                            sqlConditions += ' AND ' + item.fieldAPIName + ' >= :gmtDateTimeFrom';
                        }
                        if(item.isToDateTime){
                            System.debug(item.fieldValue);
                            DateTime gmtDateTimeTo = parseStringToGMT(item.fieldValue);
                            sqlConditions += ' AND ' + item.fieldAPIName + ' <= :gmtDateTimeTo';
                        }
                    } 
                    else if(item.fieldType.toUpperCase() == 'DATE'){
                        if(item.isFromDateTime){
                            System.debug(item.fieldValue);
                            sqlConditions += ' AND ' + item.fieldAPIName + ' >= ' + item.fieldValue;
                        }
                        if(item.isToDateTime){
                            System.debug(item.fieldValue);
                            sqlConditions += ' AND ' + item.fieldAPIName + ' <= ' + item.fieldValue;
                        }
                    } else if ((item.isFromDateTime || item.isToDateTime) && item.fieldType == 'text') { //GRAPHITE-496: Added this condition to evaluate the Start and End Date Time parameter for searching when event is "Global Heads Up"

                        if(item.isFromDateTime){
                            System.debug(item.fieldValue);
                            Date gmtDateTimeFrom = item.startDate;
                            sqlConditions += ' AND ' + item.fieldAPIName + ' >= :gmtDateTimeFrom';
                            system.debug('>>>gmtDateTimeFrom=' + gmtDateTimeFrom);
                            //Capture the global heads up Start Time to be used later for further filtering out of events that do not fall on the specified time
                            eventStartDateTime = item.FromDateTime;
                            system.debug('>>>eventStartDateTime: ' + eventStartDateTime);
                        }
                        if(item.isToDateTime){
                            System.debug(item.fieldValue);
                            Date gmtDateTimeTo = item.endDate;
                            sqlConditions += ' AND ' + item.fieldAPIName + ' <= :gmtDateTimeTo';
                            system.debug('>>>gmtDateTimeTo=' + gmtDateTimeTo);
                            //Capture the global heads up Start Time to be used later for further filtering out of events that do not fall on the specified time
                            eventEndDateTime = item.toDateTime;
                            system.debug('>>>eventEndDateTime: ' + eventEndDateTime);
                        }
                    }
                    else {
                        sqlConditions += ' AND ' + item.fieldAPIName + ' = ' + '\'' + item.fieldValue + '\' ';
                    }
                }
            }
            
            //adding Not Closed Condition + not mapping to Event Condition
            sqlConditions += ' AND (Status__c != \'Closed\' OR (Status__c = \'Closed\' AND CloseAction__c = \'Event Auto-Closed\'))';
            sqlConditions += ' AND GlobalEvent__c = null';
            //filter out Offload RecordType
            Id recTypeOffloadEvent = GenericUtils.getObjectRecordTypeId('Event__c', 'Flight Event - Offload');
            //sqlConditions += ' AND recordtypename__c !=  \'FlightEventOffload\' ';
            //GRAPHITE-496: Added condition to not include Global as there is no flight number and it's erroring out on the line below that gets the flight number
            sqlConditions += ' AND (recordtypename__c != \'FlightEventOffload\' AND recordtypename__c != \'GlobalEvent\' AND recordtypename__c != \'QCC_Global_Heads_Up\') ';
            //sqlConditions += ' AND recordTypeId != \''+recTypeOffloadEvent+ '\'';
            if(String.isNotBlank(sqlConditions)){
                sqlConditions = sqlConditions.replaceFirst('AND', 'WHERE');
                sqlStr += sqlConditions;
            }
            System.debug('==sqlStr==' + sqlStr);
            List<Event__c> lstFlightEvent = Database.query(sqlStr);
            
            //get list of TECH_FlightTrackerId__c
            Set<String> listFlightTrackerId = new Set<String>();
            for(event__c ev : lstFlightEvent){
                if(!String.isBlank(ev.TECH_FlightTrackerId__c)){
                    listFlightTrackerId.add(ev.TECH_FlightTrackerId__c);
                }
            }
            
            //build flight tracker search query
            String trackerSqlStr = 'SELECT Id, TECH_Flight_Tracker_Id__c, Airline__c, Flight_Number__c, Flight_Status__c, IntDom__c, ';
            trackerSqlStr += ' Operational_Carrier__c, Aircraft_Type__c, Aircraft_Registration__c, Departure_Airport__c, Arrival_Airport__c, ';
            trackerSqlStr += ' ScheduledDepTime__c, Scheduled_Depature_UTC__c, ScheduledArrDateTime__c, Scheduled_Arrival_UTC__c, EstimatedDepDateTime__c, ';
            trackerSqlStr += ' Estimated_Departure_UTC__c, ActualDepaDateTime__c, Actual_Departure_UTC__c, EstimatedArrDateTime__c, Estimated_Arrival_UTC__c, ';
            trackerSqlStr += ' ActualArriDateTime__c, Actual_Arrival_UTC__c, Event_Name__c, NewArrivalPort__c, TrackerType__c, Origin_Date__c ';
            trackerSqlStr += ' FROM Flight_Tracker__c ';
            String trackerSqlConditions = '';
            DateTime scheduleDepDateFrom = null;
            DateTime scheduleDepDateTo = null;
            for(Integer i = 0; i < lstFieldSetMember.size(); i++){
                FieldSetMemberWrapperClass item = lstFieldSetMember[i];
                
                //translate fieldname from Flight Event -> Flight Tracker
                if(item.fieldAPIName == 'FlightNumber__c'){
                    item.fieldAPIName = 'Flight_Number__c';
                }else if(item.fieldAPIName == 'DeparturePort__c' || item.fieldAPIName == 'Affected_Ports__c'){ //GRAPHITE-496: Translate the Affected Ports field from Event
                    item.fieldAPIName = 'Departure_Airport__c';
                }else if(item.fieldAPIName == 'ArrivalPort__c'){
                    item.fieldAPIName = 'Arrival_Airport__c';
                }else if(item.fieldAPIName == 'ScheduledDepDate__c'){
                    item.fieldAPIName = 'Scheduled_Depature_UTC__c';
                }else if(item.fieldAPIName == 'Plane_Number__c'){
                    item.fieldAPIName = 'Aircraft_Registration__c';
                }
                
                if(String.isNotBlank(item.fieldValue)){
                    if(item.fieldType.toUpperCase() == 'DATETIME'){
                        if(item.isFromDateTime){
                            DateTime gmtDateTimeFrom = parseStringToGMT(item.fieldValue);
                            trackerSqlConditions += ' AND ' + item.fieldAPIName + ' >= :gmtDateTimeFrom';
                        }
                        if(item.isToDateTime){
                            DateTime gmtDateTimeTo = parseStringToGMT(item.fieldValue);
                            trackerSqlConditions += ' AND ' + item.fieldAPIName + ' <= :gmtDateTimeTo';
                        }
                    }
                    else if(item.fieldType.toUpperCase() == 'DATE'){
                        if(item.isFromDateTime){
                            //adding time suffix for 0h 0m 0s
                            trackerSqlConditions += ' AND ' + item.fieldAPIName + ' >= ' + item.fieldValue +'T00:00:00.000Z';
                            if(item.fieldAPIName == 'Scheduled_Depature_UTC__c'){
                                scheduleDepDateFrom = Date.newInstance(Integer.valueOf(item.fieldValue.split('-')[0]),Integer.valueOf(item.fieldValue.split('-')[1]),Integer.valueOf(item.fieldValue.split('-')[2]));
                            }
                        }
                        if(item.isToDateTime){
                            //adding time suffix for 23h 59m 59s
                            trackerSqlConditions += ' AND ' + item.fieldAPIName + ' <= ' + + item.fieldValue +'T23:59:59.999Z';
                            if(item.fieldAPIName == 'Scheduled_Depature_UTC__c'){
                                scheduleDepDateTo = Date.newInstance(Integer.valueOf(item.fieldValue.split('-')[0]),Integer.valueOf(item.fieldValue.split('-')[1]),Integer.valueOf(item.fieldValue.split('-')[2]));
                            }
                        }
                    }
                    else if(item.fieldAPIName == 'Flight_Number__c'){
                        //search for QF0001 or 0001
                        String numberOnly = item.fieldValue;
                        while(!numberOnly.isNumeric()){
                            numberOnly = numberOnly.substring(1);
                        }
                        trackerSqlConditions += ' AND (' + item.fieldAPIName + ' = ' + '\'' + item.fieldValue 
                            						+ '\' OR ' + item.fieldAPIName + ' = ' + '\'' + numberOnly + '\' ) ';
                    }
                    else if ((item.isFromDateTime || item.isToDateTime) && item.fieldType == 'text') { //GRAPHITE-496: Added this condition to evaluate the Start and End Date Time parameter for searching when event is "Global Heads Up"

                        if(item.isFromDateTime){
                            System.debug(item.fieldValue);
                            //DateTime gmtDateTimeFrom = Datetime.valueOf(string.valueOf(item.fromDateTime).replace(' ', 'T') +'Z');
                            //DateTime gmtDateTimeFrom = item.fromDateTime;
                            Date gmtDateTimeFrom = item.startDate;
                            sqlConditions += ' AND ' + item.fieldAPIName + ' >= :gmtDateTimeFrom';
                            system.debug('>>>gmtDateTimeFrom=' + gmtDateTimeFrom);
                            //eventStartTime = item.fromDateTime.getTime();
                        }
                        if(item.isToDateTime){
                            System.debug(item.fieldValue);
                            //DateTime gmtDateTimeTo = Datetime.valueOf(string.valueOf(item.toDateTime).replace(' ', 'T') +'Z');
                            //DateTime gmtDateTimeTo = item.toDateTime;
                            Date gmtDateTimeTo = item.endDate;
                            sqlConditions += ' AND ' + item.fieldAPIName + ' <= :gmtDateTimeTo';
                            system.debug('>>>gmtDateTimeTo=' + gmtDateTimeTo);
                        }
                    }
                    else {
                        trackerSqlConditions += ' AND ' + item.fieldAPIName + ' = ' + '\'' + item.fieldValue + '\' ';
                    }
                }
            }
            //adding Not Closed Condition + not mapping to Event Condition
            trackerSqlConditions += ' AND TECH_Flight_Tracker_Id__c NOT IN :listFlightTrackerId ';
            if(String.isNotBlank(trackerSqlConditions)){
                trackerSqlConditions = trackerSqlConditions.replaceFirst('AND', 'WHERE');
                trackerSqlStr += trackerSqlConditions;
            }
            System.debug('==trackerSqlStr==' + trackerSqlStr);
            List<Flight_Tracker__c> lstFlightTracker = Database.query(trackerSqlStr);
            
            //create Flight Event from flight Tracker
            String queueId = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'CCC CJM Queue'].Id;
            List<Event__c> flightEvent = new List<Event__c>();
            Map<String, Flight_Tracker__c> flightTrackerIds = new Map<String, Flight_Tracker__c>();
            for(Flight_Tracker__c objFlgTrack : lstFlightTracker){
                flightTrackerIds.put(objFlgTrack.TECH_Flight_Tracker_Id__c, objFlgTrack);
            }
            
            //filter out all Tracker that has Flight Event attached to other Global Event
            for(Event__c ev : [Select id, TECH_FlightTrackerId__c, GlobalEvent__c FROM Event__c where GlobalEvent__c != null 
                               AND TECH_FlightTrackerId__c IN :flightTrackerIds.keyset()]){
            	flightTrackerIds.remove(ev.TECH_FlightTrackerId__c);
            }
            
            //create event from FlightTracker Search Results
            for(Flight_Tracker__c objFlgTrack : flightTrackerIds.values()){
                try{
                    flightEvent.addAll(FlightTrackerTriggerHelper.createEventData(objFlgTrack, queueId));
                }catch(exception ex){
                    System.debug(ex.getMessage() + '-'+ex.getStackTraceString());
                } 
            }
            
            for(event__c objEvt : flightEvent){
                objEvt = QCC_EventGenericUtils.generateEventName(objEvt);
                objEvt.Name = '*'+objEvt.name;
            }
            
            if(!flightEvent.isEmpty()){
                lstFlightEvent.addAll(flightEvent);
            }
			
			//filter out freight Flight
			//filter out Flight with date outside of range
            Integer freightLowRange = String.IsNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_FreightLowRange'))?Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_FreightLowRange')):3000;
            Integer freightHighRange = String.IsNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_FreightHighRange'))?Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_FreightHighRange')):10000;
            for(integer i = 0; i < lstFlightEvent.size(); i++){
                system.debug('>>>lstFlightEvent ' + i + ': ' + lstFlightEvent[i]);
                Integer fNo = Integer.valueOf(lstFlightEvent[i].FlightNumber__c.subString(2));
                if(fNo > freightLowRange && fNo < freightHighRange){
					lstFlightEvent.remove(i);
                    i--;
                    continue;
                }
                if(scheduleDepDateFrom != null && lstFlightEvent[i].ScheduledDepDate__c < scheduleDepDateFrom){
                    lstFlightEvent.remove(i);
                    i--;
                    continue;
                }
                if(scheduleDepDateTo != null && lstFlightEvent[i].ScheduledDepDate__c > scheduleDepDateTo){
                    lstFlightEvent.remove(i);
                    i--;
                    continue;
                }

                //GRAPHITE-496: Remove flights that are not within the specified time for Global Heads Up event
                if (eventStartDateTime != null && eventEndDateTime != null) {
                    //Convert the text field Scheduled_Departure__c to a DateTime
                    Integer hh = (lstFlightEvent[i].ScheduledDepTime__c != null) ? Integer.valueOf(lstFlightEvent[i].ScheduledDepTime__c.substringBefore(':')) : 0;
                    Integer mm = (lstFlightEvent[i].ScheduledDepTime__c != null) ? Integer.valueOf(lstFlightEvent[i].ScheduledDepTime__c.substringAfter(':')) : 0;
                    Time affectedEventDepartureTime = Time.newInstance(hh, mm, 0, 0);
                    DateTime affectedEventDepDateTime = DateTime.newInstanceGMT(lstFlightEvent[i].ScheduledDepDate__c, affectedEventDepartureTime);
                    system.debug('>>>affectedEventDepDateTime: ' + affectedEventDepDateTime);
                    //Remove the flight if it is not within the global heads up time
                    if (affectedEventDepDateTime < eventStartDateTime || affectedEventDepDateTime > eventEndDateTime) {
                        lstFlightEvent.remove(i);
                        i--;
                        continue;
                    }
                }
            }
            
            
            //return to front end
            return lstFlightEvent;
        }catch(exception ex){
            System.debug(ex.getMessage() + '-'+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + '-'+ex.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void addEventsToGlobalEvent(List<String> lstEventId, List<String> lstTracker, String globalEventId, String flightFailureJson){
        try{
            Id recTypeActiveEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
            List<Event__c> lstEvent = [
                SELECT Id, Status__c, CloseAction__c, GlobalEvent__c, DeparturePort__c, ArrivalPort__c,
                IsEventReopened__c, ReOpenedReason__c, Re_Opened_By__c, Re_Opened_Date_Time__c,FlightNumber__c, 
                DelayCostsCompleted__c, RecoveryPlanCompleted__c, ScheduledDepDate__c ,Primary_Root_Cause__c
                FROM Event__c
                WHERE Id IN :lstEventId
            ];
            
            for(Event__c objEvent : lstEvent){
                objEvent.GlobalEvent__c = globalEventId;
                if(objEvent.Status__c == 'Closed' && objEvent.CloseAction__c == 'Event Auto-Closed'){
                    objEvent.RecordTypeId = recTypeActiveEvent;
                    objEvent.Status__c = 'Open';
                    objEvent.CloseAction__c = null;
                    objEvent.IsEventReopened__c = true; 
                    objEvent.ReOpenedReason__c = 'Linked to a global Event by CJM';
                    objEvent.Re_Opened_By__c = userInfo.getUserId();
                    objEvent.Re_Opened_Date_Time__c = system.now();
                    objEvent.DelayCostsCompleted__c = false;
                    objEvent.RecoveryPlanCompleted__c = false;
                }
            }
            
            //create Flight Event from flight Tracker
            
            String queueId = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'CCC CJM Queue'].Id;
            List<Event__c> flightTrackerEvent = new List<Event__c>();
            for(Flight_Tracker__c objFlgTrack : [SELECT Id, TECH_Flight_Tracker_Id__c, Airline__c, Flight_Number__c, Flight_Status__c, 
                                                 IntDom__c, Operational_Carrier__c, Aircraft_Type__c, Aircraft_Registration__c, 
                                                 Departure_Airport__c, Arrival_Airport__c,  ScheduledDepTime__c, Scheduled_Depature_UTC__c, 
                                                 ScheduledArrDateTime__c, Scheduled_Arrival_UTC__c, EstimatedDepDateTime__c, Origin_Date__c,
                                                 Estimated_Departure_UTC__c, ActualDepaDateTime__c, Actual_Departure_UTC__c, 
                                                 EstimatedArrDateTime__c, Estimated_Arrival_UTC__c,   ActualArriDateTime__c, 
                                                 Actual_Arrival_UTC__c, Event_Name__c, NewArrivalPort__c, TrackerType__c FROM Flight_Tracker__c
                                                 WHERE TECH_Flight_Tracker_Id__c IN :lstTracker]){
                try{
                    flightTrackerEvent.addAll(FlightTrackerTriggerHelper.createEventData(objFlgTrack, queueId));
                }catch(exception ex){
                    System.debug(ex.getMessage() + '-'+ex.getStackTraceString());
                } 
            }
            
           	//getting root cause
            if(!flightTrackerEvent.isEmpty()){
                //getting Root Cause
                flightTrackerEvent = updatePrimaryRootCauseEvent(flightTrackerEvent);
                for(Event__c item : flightTrackerEvent){
                    //link to Global Event
                    //Move to after Insert Flight Failure
                	//item.GlobalEvent__c = globalEventId;
                    item = QCC_EventGenericUtils.generateEventName(item);
            	}
            }
            if(!lstEvent.isEmpty()){
                //getting Root Cause
                lstEvent = updatePrimaryRootCauseEvent(lstEvent);
            }
            
            //update existing Flight Event
            if(!lstEvent.isEmpty()){
                update lstEvent;
            }
            //insert newly created Flight Event to Global Event
            if(!flightTrackerEvent.isEmpty()){
                insert flightTrackerEvent;
                
                if(!String.isBlank(flightFailureJson)){
                    flightFailureJson = flightFailureJson.replace('__c', '');//remove trailling __c for json deserialize
                    FlightFailureInfo failureInfo = (FlightFailureInfo)JSON.deserialize(flightFailureJson, FlightFailureInfo.class);
                    System.debug(failureInfo);
                    List<FlightFailure__c> listFF = new List<FlightFailure__c>();
                    for(Event__c ev : flightTrackerEvent){
                        System.debug(ev);
                        System.debug(ev.Status__c);
                        System.debug(ev.Global_Event__c);
                        FlightFailure__c objFF = new FlightFailure__c();
                        objFF.Flight_Event__c = ev.Id;
                        objFF.Failure_Code__c = failureInfo.Failure_Code;
                        objFF.Affected_Region__c = failureInfo.Affected_Region;
                        objFF.Affect_Sub_Section__c = failureInfo.Affect_Sub_Section;
                        objFF.Pre_Flight__c = failureInfo.Pre_Flight == 'true' ? true : false; 
                        objFF.Post_Flight__c = failureInfo.Post_Flight == 'true' ? true : false;
                        
                        listFF.add(objFF);
                    }
                    if(!listFF.isEmpty()){
                        insert listFF;
                    }
                }
                
                for(Event__c item : flightTrackerEvent){
                    //link to Global Event
                	item.GlobalEvent__c = globalEventId;
            	}
                update flightTrackerEvent;
            }
            
        } catch(exception ex) {
            System.debug(ex.getMessage() + '-'+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + '-'+ex.getStackTraceString());
        }
        
    }
    
    // 2018-10-25T04:54:00.000Z
    @TestVisible
    private static DateTime parseStringToGMT(String dateTimeStr){
        try{
            dateTimeStr = dateTimeStr.left(19);
            Integer year = integer.valueOf((dateTimeStr.split('T')[0]).split('-')[0]);
            Integer month = integer.valueOf((dateTimeStr.split('T')[0]).split('-')[1]);
            Integer day = integer.valueOf((dateTimeStr.split('T')[0]).split('-')[2]);
            Integer hour = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[0]);
            Integer minute = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[1]);
            Integer second = integer.valueOf((dateTimeStr.split('T')[1]).split(':')[2]);
            DateTime output = DateTime.newInstanceGmt(year, month, day, hour, minute, second);
            return output;
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return null;
    }
    
    public static List<FieldSetMemberWrapperClass> getFieldSetMember(String objectName , String fieldSetName, Event__c record){
        
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        //Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        Schema.SObjectType sObj = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        try{
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
                Boolean isDateField = false;
                FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
                wrapper.fieldType = String.valueOf(fieldMember.getType());
                wrapper.fieldLabel = fieldMember.getLabel();
                wrapper.fieldAPIName = fieldMember.getFieldPath();
                // change date field to datetime field
                String currFieldType = String.valueOf(fieldMember.getType());
                
                if((currFieldType == 'date' || currFieldType == 'datetime') && fieldSetName != 'QCC_GlobalHeadsUp_SearchableFields'){
                    isDateField = true;
                    wrapper.fieldLabel = fieldMember.getLabel() + ' From';
                    wrapper.isFromDateTime = true;
                }
                wrapperList.add(wrapper);
                // add datetime To
                if(isDateField && fieldSetName != 'QCC_GlobalHeadsUp_SearchableFields'){
                    FieldSetMemberWrapperClass wrapperTo = new FieldSetMemberWrapperClass();
                    wrapperTo.fieldType = currFieldType;
                    wrapperTo.fieldAPIName = fieldMember.getFieldPath();
                    wrapperTo.fieldLabel = fieldMember.getLabel() + ' To';
                    wrapperTo.isToDateTime = true;
                    wrapperList.add(wrapperTo);
                }

                //GRAPHITE-496: Set these fields with default value based on the "Global Heads Up" event known field values for searching affected events
                if (fieldSetName == 'QCC_GlobalHeadsUp_SearchableFields' && record != NULL) {
                    if (wrapper.fieldAPIName == 'Affected_Ports__c') {
                        wrapper.fieldAPIName = 'DeparturePort__c';
                        wrapper.fieldValue = record.Affected_Ports__c;
                        wrapper.isDisabled = 'true';
                    }

                    //if (wrapper.fieldAPIName == 'Scheduled_Departure__c') {
                    if (wrapper.fieldAPIName == 'ScheduledDepDate__c' && fieldSetName == 'QCC_GlobalHeadsUp_SearchableFields') {
                        system.debug('>>>fieldAPIName = ScheduledDepDate__c: ' + wrapper.fieldAPIName);
                        Date startDate = record.Start_Date__c;
                        Time startTime = record.QCC_Local_Start_Time__c;
                        DateTime startDateTimeDisplay = DateTime.valueOf(startDate.year() + '-' + startDate.month() + '-' + startDate.day() + ' ' + startTime);
                        DateTime startDateTime = DateTime.newInstanceGmt(startDate, startTime);
                        //DateTime startDateTime = GenericUtils.parseStringToGMT(startDateTimeDisplay.format('DD-MM-YYYY HH:mm:ss'));
                        system.debug('>>>startDate=' + startDate + '; startTime=' + startTime);
                        system.debug('>>>startDateTime: ' + startDateTime);

                        wrapper.fieldLabel = 'Start Date Time';
                        wrapper.fieldType = 'text';
                        //wrapper.fieldValue = String.valueOf(startDateTime.format('dd/mm/yyyy hh:mm'));
                        wrapper.fieldValue = String.valueOf(startDateTimeDisplay);
                        wrapper.isFromDateTime = true;
                        wrapper.fromDateTime = startDateTime;
                        wrapper.startDate = startDate;
                        wrapper.startTime = String.valueOf(startTime);
                        //wrapper.startTime = startTime;
                        wrapper.isDisabled = 'true';

                        //Construct the End Date Time
                        FieldSetMemberWrapperClass wrapperTo = new FieldSetMemberWrapperClass();
                        Date endDate = record.End_Date__c;
                        Time endTime = record.QCC_Local_End_Time__c;
                        DateTime endDateTimeDisplay = DateTime.valueOf(endDate.year() + '-' + endDate.month() + '-' + endDate.day() + ' ' + endTime);
                        DateTime endDateTime = DateTime.newInstanceGmt(endDate, endTime);
                        //DateTime endDateTime = GenericUtils.parseStringToGMT(endDateTimeDisplay.format('DD-MM-YYYY HH:mm:ss'));
                        system.debug('>>>endDate=' + endDate + '; endTime=' + endTime);
                        system.debug('>>>endDateTime: ' + endDateTime);

                        wrapperTo.fieldLabel = 'End Date Time';
                        wrapperTo.fieldAPIName = fieldMember.getFieldPath();
                        wrapperTo.fieldType = 'text';
                        //wrapperTo.fieldValue = String.valueOf(endDateTime.format('dd/mm/yyyy hh:mm'));
                        wrapperTo.fieldValue = String.valueOf(endDateTimeDisplay);
                        wrapperTo.isToDateTime = true;
                        wrapperTo.toDateTime = endDateTime;
                        wrapperTo.endDate = endDate;
                        wrapperTo.endTime = String.valueOf(endTime);
                        //wrapper.endTime = endTime;
                        wrapperTo.isDisabled = 'true';
                        wrapperList.add(wrapperTo);

                    }

                }
            }
            System.debug('#### wrapperList ' + wrapperList);
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return wrapperList;
    }
    
    public class DataInitWrapper {
        @AuraEnabled
        public String columnSets {get;set;}
        @AuraEnabled
        public List<FieldSetMemberWrapperClass> listFieldSets {get;set;}
    }
    
    public class FieldSetMemberWrapperClass {
        @AuraEnabled
        public String fieldType                          {get;set;}
        @AuraEnabled
        public String fieldLabel                         {get;set;}
        @AuraEnabled
        public String fieldAPIName                       {get;set;}
        @AuraEnabled
        public String fieldValue                         {get;set;}
        @AuraEnabled
        public Boolean isFromDateTime {get; set;} // use when field type is datetime
        @AuraEnabled
        public Boolean isToDateTime {get; set;} // use when field type is datetime
        @AuraEnabled
        public String isDisabled                         {get;set;} //GRAPHITE-496: Added this attribute to cater for dynamically disbaling search fields with default values.
        @AuraEnabled
        public DateTime fromDateTime                       {get;set;} //GRAPHITE-496: Added this attribute to save the actual date and time value
        @AuraEnabled
        public DateTime toDateTime                       {get;set;} //GRAPHITE-496: Added this attribute to save the actual date and time value
        @AuraEnabled
        public Date startDate                       {get;set;} //GRAPHITE-496: Added this attribute to save the actual date and time value
        @AuraEnabled
        public String startTime                       {get;set;} //GRAPHITE-496: Added this attribute to save the actual date and time value
        @AuraEnabled
        public Date endDate                       {get;set;} //GRAPHITE-496: Added this attribute to save the actual date and time value
        @AuraEnabled
        public String endTime                       {get;set;} //GRAPHITE-496: Added this attribute to save the actual date and time value


        public FieldSetMemberWrapperClass(){
            this.fieldType = '';
            this.fieldLabel = '';
            this.fieldAPIName = '';
            this.fieldValue = '';
            this.isFromDateTime = false;
            this.isToDateTime = false;
        }
    }
    
    public static String getColumns(String componentName) {
        try{
            List<displayColumn> listColumn = new List<displayColumn>();
            for(QCC_Data_Table__mdt dataTable: [SELECT ComponentName__c
                                                ,Order__c
                                                ,FieldAPI__c
                                                ,FieldLabel__c
                                                ,Sortable__c
                                                ,Type__c 
                                                FROM QCC_Data_Table__mdt
                                                WHERE ComponentName__c  = :componentName 
                                                Order By Order__c]) {
                                                    String fieldLabel = dataTable.FieldLabel__c;
                                                    String fieldAPI = dataTable.FieldAPI__c;
                                                    String fieldDataType = dataTable.Type__c;
                                                    Boolean sortable = dataTable.Sortable__c;
                                                    TypeAttributes typeAttribute = (TypeAttributes)System.JSON.deserialize('{ "label": { "fieldName": "'+fieldAPI+'" }, "variant": "base", "title": { "fieldName": "'+fieldAPI+'"}}', TypeAttributes.Class);
                                                    
                                                    listColumn.add(new displayColumn(fieldLabel, fieldAPI, fieldDataType, sortable, typeAttribute));
                                                }
            return JSON.serialize(listColumn).replaceALL('type_x', 'type');
        }catch(exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
        return '';
    }
    
    @AuraEnabled
    public static List<Event__c> updatePrimaryRootCauseEvent(List<Event__c> events){

        try{
            System.debug('start getting Primary_Root_Cause__c');
        	Map<String, QCC_FlightInfoResponse> mapResponse = new Map<String, QCC_FlightInfoResponse>();
            for(event__c ev:events){
                System.debug(ev);
                //format the Date
                ev.ScheduledDepDate__c = Date.newInstance(ev.ScheduledDepDate__c.year(), ev.ScheduledDepDate__c.month(), ev.ScheduledDepDate__c.day());
            
                if(!String.isBlank(ev.Primary_Root_Cause__c)){
                    continue;
                }
                
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
                    System.debug(firKey);
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
            
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Event', 'QCC_AddEventstoGlobalEventController', 
                                    'updatePrimaryRootCauseEvent', String.valueOf(''), String.valueOf(''),false,'', ex);
        }finally{
            String token = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken');
            QCC_GenericUtils.updateToken(token, 'QCC_FlightToken');
        	System.debug(events);
            return events;
        }       
        return events;
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
    
    // Wrapper class to hold the structure of columns attribute of lightning:datatable tag
    public class DisplayColumn {
        public String label{get;set;}
        public String fieldName{get;set;}
        public String type_x{get;set;}
        public Boolean sortable;
        public TypeAttributes typeAttributes;
        
        public DisplayColumn (String label, String fieldName, String inputType, Boolean sortable,TypeAttributes typeAttributes){
            this.label = label;
            this.fieldName = fieldName;
            this.type_x = inputType;
            this.sortable = sortable;
            this.typeAttributes = typeAttributes;
        }
    }
    
    public class TypeAttributes {
        public Label label;
        public String variant;
        public String year;
        public String month;
        public String day;
        public String hour;
        public String minute;
        public Label title;
    }
    
    public class Label {
        public String fieldName;
    }
    
    public class FlightFailureInfo{
        public String Failure_Code {get;set;}	//
        public String Affected_Region{get;set;}	//
        public String Affect_Sub_Section{get;set;}
        public String Pre_Flight{get;set;}
        public String Post_Flight{get;set;}
    }
}