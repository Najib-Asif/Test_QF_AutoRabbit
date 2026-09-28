/*----------------------------------------------------------------------------------------------------------------------
Author:        
Company:       Capgemini
Description:   
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
05-May-2018

-----------------------------------------------------------------------------------------------------------------------*/
public class EventTriggerHelper { 
    public static final String postflightStatus = CustomSettingsUtilities.getConfigDataMap('Event Flight Status Post');
    public static final String preflightStatus = CustomSettingsUtilities.getConfigDataMap('Event Flight Status Pre');
    public static final    Map<String, Id> mapqueue = getAllQueues();
    //Jira: CRM-9036
    private static final String EMPTY_STRING = '';
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateEventFields
    Description:        All Before Trigger Functionalities
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void updateEventFields(List<Event__c> lstEvent,  Map<Id, Event__c> oldEventMap) {
        // All Static Values
        Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));
        Id recTypeActiveEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
        Id recTypeOffloadEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Offload Record Type'));
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        String statusOpenEvent = CustomSettingsUtilities.getConfigDataMap('Event Open Status');
        String statusAssignedEvent = CustomSettingsUtilities.getConfigDataMap('Event Assigned Status');
        String statusInprogressEvent = CustomSettingsUtilities.getConfigDataMap('Event Inprogress Status');
        List<Group> listQueueCIOC = [Select id, name from Group where Type='Queue' AND developerName='CCC_CIOC_Queue'];
        // get Profile Id by Name
        //CRM-11908 Update metadata rerferences
        //CRM-11910 - RBAC Updated Profile name to QCC Customer Journey Manager
        Map<String, Profile> mapProfiles = getProfileMapByProfileNames(new List<String>{'Qantas CC Consultant', 'Qantas CC Journey Manager','Qantas CC Team Lead', 'Qantas CC Operational Manager', 'Qantas Pre Journey CC Consultant',
        'QCC Contact Center Agent Hobart','QCC Contact Center Agent Manila','QCC Contact Center Agent Capetown','QCC Contact Center Agent Suva','QCC Contact Center Agent Auckland','QCC Contact Center Agent Mumbai','QCC Operational Manager','QCC Customer Journey Manager'});
        List<String> listEventIds = new List<String>();
        for(Event__c objEvt : lstEvent){
            Event__c oldEvent = OldEventMap != Null? oldEventMap.get(objEvt.Id): Null;
            if(objEvt.Id != null && objEvt.recordTypeId == recTypeOffloadEvent){
                listEventIds.add(objEvt.Id);
            }
        }
        List<Affected_Passenger__c> listOffloadPassengers = [Select id, OffloadRequest__c, event__c, cabin__c from Affected_Passenger__c 
                                                             where event__c IN :listEventIds];
        
        for(Event__c objEvt : lstEvent){
            Event__c oldEvent = OldEventMap != Null? oldEventMap.get(objEvt.Id): Null;
            
            //update the Tech RecordType Field for Duplication rule 
            if(objEvt.recordTypeId == recTypeOffloadEvent ){
                objEvt.TECH_RecordType_Duplication__c = CustomSettingsUtilities.getConfigDataMap('Event Offload Record Type');
            }else if(objEvt.recordTypeId == recTypeClosedEvent || objEvt.recordTypeId == recTypeActiveEvent ){
                objEvt.TECH_RecordType_Duplication__c = CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type') 
                                                        + ' ' + CustomSettingsUtilities.getConfigDataMap('Event Active Record Type');
            }
            
            //Event Name Population
            if(objEvt.RecordTypeId == recTypeActiveEvent && (oldEvent == Null ||  
                    oldEvent.FlightNumber__c != objEvt.FlightNumber__c || 
                    objEvt.ScheduledDepDate__c != objEvt.ScheduledDepDate__c || 
                    objEvt.DeparturePort__c != objEvt.DeparturePort__c || 
                    objEvt.ArrivalPort__c != objEvt.ArrivalPort__c))
            {
                if(String.isNotBlank(objEvt.FlightNumber__c) && String.isNotBlank(objEvt.DeparturePort__c) && 
                  String.isNotBlank(objEvt.ArrivalPort__c) && objEvt.ScheduledDepDate__c!= Null ) 
                {
                    objEvt = QCC_EventGenericUtils.generateEventName(objEvt);
                } 
            }
            
            //set the OFF name for offload Event
            if(objEvt.RecordTypeId == recTypeOffloadEvent && (oldEvent == Null ||  
                    oldEvent.FlightNumber__c != objEvt.FlightNumber__c || 
                    objEvt.ScheduledDepDate__c != objEvt.ScheduledDepDate__c || 
                    objEvt.DeparturePort__c != objEvt.DeparturePort__c || 
                    objEvt.ArrivalPort__c != objEvt.ArrivalPort__c))
            {
                objEvt = QCC_EventGenericUtils.generateEventName(objEvt);
                objEvt.Name = 'OFF '+ objEvt.Name;
            }
            
            //New Event is Created, Flight Event should be owned by CJM
            if(oldEvent == Null && (UserInfo.getProfileId() == mapProfiles.get('Qantas CC Journey Manager').Id || UserInfo.getProfileId() == mapProfiles.get('QCC Customer Journey Manager').Id)){ //CRM-11908 Update metadata rerferences //CRM-11910 - RBAC Updated Profile name to QCC Customer Journey Manager
                objEvt.OwnerId = mapqueue.get('CJM Queue');  
            }
            
            if(oldEvent == Null || oldEvent.scheduledDepDate__c != objEvt.scheduledDepDate__c){
                objEvt.Scheduled_Departure_Date_Time__c = String.valueOf(objEvt.scheduledDepDate__c);
            }

            //Update if it Confirmed Overnight 
            if((oldEvent == Null || objEvt.ScheduledDepDate__c != oldEvent.ScheduledDepDate__c ||
                objEvt.ScheduledDepTime__c != oldEvent.ScheduledDepTime__c || 
                objEvt.EstimatedDepDateTime__c != oldEvent.EstimatedDepDateTime__c) && 
                objEvt.ScheduledDepDate__c != Null && String.isNotBlank(objEvt.ScheduledDepTime__c) &&  
               String.isNotBlank(objEvt.EstimatedDepDateTime__c))
            {
                DateTime scheduleDateTime = DateTime.newInstance(objEvt.ScheduledDepDate__c.year(),
                                                                 objEvt.ScheduledDepDate__c.month(), 
                                                                 objEvt.ScheduledDepDate__c.day(), 
                                                                 Integer.valueOf(objEvt.ScheduledDepTime__c.split(':')[0]),
                                                                 Integer.valueOf(objEvt.ScheduledDepTime__c.split(':')[1]), 0);
                List<String> listDateTime = objEvt.EstimatedDepDateTime__c.split(' ');
                DateTime estimateDateTime = QCC_GenericUtils.convertStringtoDateTime(listDateTime[0], listDateTime[1]);
                if(!scheduleDateTime.isSameDay(estimateDateTime) && ( (scheduleDateTime.addHours(5) < estimateDateTime) )){
                    objEvt.Overnight__c = 'Confirmed Overnight';
                }else if(objEvt.Overnight__c == 'Confirmed Overnight'){
                    objEvt.Overnight__c = '';
                }
                
            }
            
            //Update QSOA External ID field 
            if(objEvt.FlightNumber__c != Null && objEvt.ScheduledDepDate__c != Null && 
               objEvt.ArrivalPort__c != Null && (oldEvent == Null || 
                                                 objEvt.FlightNumber__c != oldEvent.FlightNumber__c ||
                                                 objEvt.ScheduledDepDate__c != oldEvent.ScheduledDepDate__c ||
                                                 objEvt.ArrivalPort__c != oldEvent.ArrivalPort__c ))
            {
                objEvt.TECH_FlightTrackerId__c = objEvt.FlightNumber__c+''+objEvt.ScheduledDepDate__c+''+objEvt.ArrivalPort__c;
            }
            
            //Update Satus to Assigned
            if(objEvt.Status__c == statusOpenEvent && objEvt.RecoveryPlanCompleted__c == true &&
               objEvt.RecoveryPlanCompleted__c != oldEvent.RecoveryPlanCompleted__c)
            {
                objEvt.OwnerId = mapqueue.get('Assigned Queue');
                objEvt.Status__c = statusAssignedEvent; 
            }
            
            //update offload numbers for offload Event
            if(objEvt.RecordTypeId == recTypeOffloadEvent && objEvt.Status__c == statusClosedEvent){
                //clear out the number for recounting
                objEvt.NoOfPax_OffloadedFrom_Economy__c = 0;
                objEvt.NoOfPax_OffloadedFrom_Premium_Eco__c = 0;
                objEvt.NoOfPax_OffloadedFrom_Business__c = 0;
                objEvt.NoOfPax_OffloadedFrom_First_Class__c = 0;
                objEvt.Total_no_of_pax_accepted__c = 0;
                objEvt.Total_no_of_pax_Declined__c = 0;
                objEvt.Total_no_of_pax_not_Reachable__c = 0;
                
                //loop through list of Passenger for counting
                for(integer i = 0; i < listOffloadPassengers.size(); i++){
                    Affected_passenger__c afp = listOffloadPassengers[i];
                    if(afp.Event__c == objEvt.id){
                        //add passenger to the count number if condition matched
                        switch on afp.Cabin__c {
                            When 'Economy' {
                                switch on afp.OffloadRequest__c {
                                    When 'Accepted' {
                                        objEvt.NoOfPax_OffloadedFrom_Economy__c++;
                                        objEvt.Total_no_of_pax_accepted__c++;
                                    }
                                    When 'Declined' {
                                        objEvt.Total_no_of_pax_Declined__c++;
                                    }
                                    When 'Unable to contact' {
                                        objEvt.Total_no_of_pax_not_Reachable__c++;
                                    }
                                    
                                }
                            }
                            When 'Premium Economy' {
                                switch on afp.OffloadRequest__c {
                                    When 'Accepted' {
                                        objEvt.NoOfPax_OffloadedFrom_Premium_Eco__c++;
                                        objEvt.Total_no_of_pax_accepted__c++;
                                    }
                                    When 'Declined' {
                                        objEvt.Total_no_of_pax_Declined__c++;
                                    }
                                    When 'Unable to contact' {
                                        objEvt.Total_no_of_pax_not_Reachable__c++;
                                    }
                                    
                                }
                            }
                            When 'Business' {
                                switch on afp.OffloadRequest__c {
                                    When 'Accepted' {
                                        objEvt.NoOfPax_OffloadedFrom_Business__c++;
                                        objEvt.Total_no_of_pax_accepted__c++;
                                    }
                                    When 'Declined' {
                                        objEvt.Total_no_of_pax_Declined__c++;
                                    }
                                    When 'Unable to contact' {
                                        objEvt.Total_no_of_pax_not_Reachable__c++;
                                    }
                                    
                                }
                            }
                            When 'First Class' {
                                switch on afp.OffloadRequest__c {
                                    When 'Accepted' {
                                        objEvt.NoOfPax_OffloadedFrom_First_Class__c++;
                                        objEvt.Total_no_of_pax_accepted__c++;
                                    }
                                    When 'Declined' {
                                        objEvt.Total_no_of_pax_Declined__c++;
                                    }
                                    When 'Unable to contact' {
                                        objEvt.Total_no_of_pax_not_Reachable__c++;
                                    }
                                    
                                }
                            }
                        }
                        
                        //remove passenger to shorten passengerlist -> run faster
                        listOffloadPassengers.remove(i);
                        i--;
                    }
                }
            }
            
            // QDCUSCON-3173 -close Event: Update the Record Type to Closed Event when event is closed
            // added filter for OFFLOAD Event
            if(objEvt.Status__c == statusClosedEvent && !objEvt.IsEventReopened__c)
            {
                if(objEvt.RecordTypeId == recTypeActiveEvent){
                    objEvt.RecordTypeId = recTypeClosedEvent;
                }

                //Assign to Cost Queue
                if(objEvt.DelayCostsCompleted__c == true){
                    objEvt.ownerId = mapqueue.get('Closed Queue');   
                }
                else{
                    if(objEvt.GlobalEvent__c == Null){
                        objEvt.ownerId = mapqueue.get('Cost Queue');     
                    }
                }
            }
            
            // Reopen Event Logics
            //logic for NON OFFLOAD Event
            if(oldEvent != null && !oldEvent.IsEventReopened__c && objEvt.IsEventReopened__c && objEvt.RecordTypeId != recTypeOffloadEvent){
                
                if(objEvt.RecordTypeId == recTypeClosedEvent){
                   objEvt.RecordTypeId = recTypeActiveEvent;
                } 
                if(UserInfo.getProfileId() == mapProfiles.get('Qantas CC Journey Manager').Id || UserInfo.getProfileId() == mapProfiles.get('QCC Customer Journey Manager').Id){ //CRM-11908 Update metadata rerferences //CRM-11910 - RBAC Updated Profile name to QCC Customer Journey Manager
                    objEvt.Status__c = statusOpenEvent;
                    objEvt.DelayCostsCompleted__c = false;
                    objEvt.RecoveryPlanCompleted__c = false;
                    objEvt.OwnerId = mapqueue.get('CJM Queue');
                    //Jira: CRM-9036
                    objEvt.CloseAction__c = EMPTY_STRING;
                    objEvt.NoCommsReason__c = EMPTY_STRING;
                //CRM-11908 Update metadata rerferences    
                }else if( UserInfo.getProfileId() == mapProfiles.get('Qantas CC Team Lead').Id || 
                          UserInfo.getProfileId() == mapProfiles.get('Qantas CC Operational Manager').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('Qantas CC Consultant').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Hobart').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Manila').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Capetown').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Suva').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Auckland').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Mumbai').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Operational Manager').Id)
                {
                    objEvt.OwnerId = UserInfo.getUserId();
                    objEvt.Status__c = statusAssignedEvent; 
                }else if(UserInfo.getProfileId() == mapProfiles.get('Qantas Pre Journey CC Consultant').Id){
                    objEvt.OwnerId = UserInfo.getUserId();
                    objEvt.Status__c = statusInprogressEvent; 
                }
                
            }
            
            // Reopen Event Logics
            //logic for OFFLOAD Event
            if(oldEvent != null && !oldEvent.IsEventReopened__c && objEvt.IsEventReopened__c && objEvt.RecordTypeId == recTypeOffloadEvent){
                
                if(UserInfo.getProfileId() == mapProfiles.get('Qantas CC Journey Manager').Id || UserInfo.getProfileId() == mapProfiles.get('QCC Customer Journey Manager').Id){ //CRM-11908 Update metadata rerferences //CRM-11910 - RBAC Updated Profile name to QCC Customer Journey Manager
                    objEvt.Status__c = statusOpenEvent;
                    objEvt.OwnerId = UserInfo.getUserId();
                //CRM-11908 Update metadata rerferences
                }else if( UserInfo.getProfileId() == mapProfiles.get('Qantas CC Team Lead').Id || 
                          UserInfo.getProfileId() == mapProfiles.get('Qantas CC Operational Manager').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('Qantas CC Consultant').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Hobart').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Manila').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Capetown').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Suva').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Auckland').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Contact Center Agent Mumbai').Id ||
                          UserInfo.getProfileId() == mapProfiles.get('QCC Operational Manager').Id)
                {
                    objEvt.OwnerId = listQueueCIOC[0].Id;
                    objEvt.Status__c = statusAssignedEvent; 
                }else if(UserInfo.getProfileId() == mapProfiles.get('Qantas Pre Journey CC Consultant').Id){
                    objEvt.OwnerId = listQueueCIOC[0].Id;
                    objEvt.Status__c = statusInprogressEvent; 
                }else {
                    objEvt.Status__c = statusOpenEvent;
                    objEvt.OwnerId = UserInfo.getUserId();
                }
            }
            
            // QDCUSCON-4124: save Non-Delay Failure Code to the text version so it can be tracked as field history
            if(oldEvent == Null || oldEvent.Non_Delay_Failure_Code__c != objEvt.Non_Delay_Failure_Code__c) {
                objEvt.TECH_NonDelayFailureCode__c = objEvt.Non_Delay_Failure_Code__c;
            }
            
            //Asign to CJM, when taking back from CC COnsultants
            if(oldEvent != Null && objEvt.Status__c == statusOpenEvent && oldEvent.Status__c == statusAssignedEvent && 
               String.isNotBlank(objEvt.ReasonForTakingBackEvent__c) &&  
               objEvt.ReasonForTakingBackEvent__c != 'New Failure From QSOA' ) {
                objEvt.OwnerId = mapqueue.get('CJM Queue');
            }
        }
        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePaggengerAPI
    Description:        Invoke Passenger API only once when all details are added to Flight Event
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void invokePaggengerAPI(List<Event__c> eventLst, Map<Id, Event__c> oldEventMap){
        try{
            Set<Id> setEventId = new Set<Id>();
            List<Event__c> lstEventObj = new List<Event__c>();
            for(Event__c objEvent: eventLst){
                Event__c oldEvent = oldEventMap != Null?oldEventMap.get(objEvent.Id): Null;
                
                if(objEvent.Operational_Carrier__c != Null && 
                   objEvent.FlightNumber__c != Null &&  objEvent.ScheduledDepDate__c != Null && 
                   objEvent.DeparturePort__c != Null && objEvent.ArrivalPort__c != Null && objEvent.TECH_FlightAPIInvoked__c &&
                   (oldEvent == Null || (oldEvent != Null && 
                                         objEvent.TECH_FlightAPIInvoked__c != oldEvent.TECH_FlightAPIInvoked__c)) &&
                   objEvent.TechPassenger_API_Invoked__c != true && objEvent.TECH_PassengerAPIExecuted__c != true)
                {
                    setEventId.add(objEvent.Id);
                }

                //When Flight is Departed 
                if(oldEvent != Null && oldEvent.Actual_Departure_UTC__c == Null &&
                    objEvent.Actual_Departure_UTC__c != Null && objEvent.TechPassenger_API_Invoked__c != true) //CRM-8770: duplicate passengers issue
                {
                    setEventId.add(objEvent.Id);
                }      
            }
            
            if(setEventId.size()>0){
                for(Event__c objEvent: [Select Id, Name, ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, AirplaneType__c, Plane_Number__c,
                                        ScheduledArrDateTime__c,ActualDepaDateTime__c, ActualArriDateTime__c, Scheduled_Arrival_UTC__c, Estimated_Arrival_UTC__c,
                                        Actual_Arrival_UTC__c, Scheduled_Depature_UTC__c, Estimated_Departure_UTC__c, Actual_Departure_UTC__c, RecordTypeId,
                                        Operating_Carrier__c,  EstimatedDepDateTime__c,TechPassenger_API_Invoked__c, TECH_FlightTrackerId__c,
                                        ArrivalPort__c, Operational_Carrier__c, Flight_Status__c, QCC_AutoCreated__c
                                        FROM Event__c where  Id IN: setEventId ])
                {
                    objEvent.TechPassenger_API_Invoked__c = true;
                    QCC_CreatePassengerForEvents fetchPassengers = new QCC_CreatePassengerForEvents(objEvent, null);
                    ID jobID = System.enqueueJob(fetchPassengers);
                    lstEventObj.add(objEvent);
                }
                update lstEventObj;
            }
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Event Trigger', 'EventTriggerHelper', 
                                    'invokePaggengerAPI', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
   /*--------------------------------------------------------------------------------------      
    Method Name:        autoCloseEvent
    Description:        Event Auto Closure when Delay/Cancellation is no more valid
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void autoCloseEvent(List<Event__c> lstEvent, Map<Id, Event__c> oldEventMap){
        String domestic = CustomSettingsUtilities.getConfigDataMap('Event Domestic IntDom');
        String international = CustomSettingsUtilities.getConfigDataMap('Event International IntDom');
        Integer oneHourInMinute = String.isNotBlank(CustomSettingsUtilities.getConfigDataMap('DomesticDelayLimitInMinutes'))?Integer.ValueOf(CustomSettingsUtilities.getConfigDataMap('DomesticDelayLimitInMinutes')): 120;
        Integer oneMinuteInMinisecond = 60000;
        Integer twoHoursInMinute =  String.isNotBlank(CustomSettingsUtilities.getConfigDataMap('InternationalDelayLimitInMinutes'))?Integer.ValueOf(CustomSettingsUtilities.getConfigDataMap('InternationalDelayLimitInMinutes')):180;
        Set<Id> setEventId = new Set<Id>();
        Set<Id> setFreightEventId = new Set<Id>();
        
        for(Event__c objEvt: lstEvent){
            if(objEvt.RecordTypeId == GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'))){
                system.debug('objEvt$$$$'+objEvt);
                Integer fNo = Integer.valueOf(objEvt.FlightNumber__c.subString(2));
                Integer freightLowRange = String.IsNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_FreightLowRange'))?Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_FreightLowRange')):3000;
                Integer freightHighRange = String.IsNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_FreightHighRange'))?Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_FreightHighRange')):10000;
                    
                if(String.IsNotBlank(objEvt.FlightNumber__c) && !objEvt.IsEventReopened__c && (fNo > freightLowRange && fNo < freightHighRange)){
                    setEventId.add(objEvt.Id);
                    setFreightEventId.add(objEvt.Id);
                }
                else if((objEvt.DelayFailureCode__c == 'Flight Delay' || objEvt.DelayFailureCode__c == 'Flight Cancellation') && 
                   String.isBlank(objEvt.Non_Delay_Failure_Code__c) && !objEvt.IsEventReopened__c)
                {
                    if(objEvt.DelayFailureCode__c == 'Flight Delay' && objEvt.Actual_Departure_UTC__c != Null){
                        DateTime departureDT = objEvt.Actual_Departure_UTC__c;
                        Decimal remainedDelayTime = Decimal.valueOf((departureDT.getTime() - objEvt.Scheduled_Depature_UTC__c.getTime())/oneMinuteInMinisecond);
                        if((remainedDelayTime < oneHourInMinute && objEvt.IntDom__c == domestic) 
                           || (remainedDelayTime < twoHoursInMinute && objEvt.IntDom__c == international)){
                               setEventId.add(objEvt.Id);
                           }
                        
                    }else if(objEvt.DelayFailureCode__c == 'Flight Cancellation' && objEvt.Scheduled_Depature_UTC__c != Null){
                        Long currentTime = system.now().getTime();
                        Long schduleTime = objEvt.Scheduled_Depature_UTC__c.getTime();
                        Integer timeDif = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_FlightCancellationTimeCheck'));
                        system.debug('currentTime$$$'+currentTime);
                        system.debug('schduleTime$$$'+schduleTime);
                        system.debug('timeDif$$$'+timeDif);
                        system.debug('schduleTime-currentTime)/6000$$$'+(schduleTime-currentTime/(6000*24)));
                        if((schduleTime-currentTime)/6000 >= timeDif){
                            setEventId.add(objEvt.Id);
                        }
                    }
                }
            }
        }
        
        if(setEventId.size()>0){
            String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
            String autoClosedAction = CustomSettingsUtilities.getConfigDataMap('Event Auto-Closed CloseAction');
            Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));
            String queueName = CustomSettingsUtilities.getConfigDataMap('QCC_AutoCloseQueueName');
           
            for(Event__c objEvt: lstEvent){
                if(setEventId.contains(objEvt.Id)){
                    objEvt.Status__c = statusClosedEvent;
                    objEvt.CloseAction__c = autoClosedAction;
                    objEvt.Closed_Date_Time__c =  Datetime.now();
                    objEvt.Closed_By__c = UserInfo.getUserId();
                    objEvt.NotifyEventOwner__c = false;
                    objEvt.NotifyChatterGroup__c = false; 
                    objEvt.IsEventReopened__c = false;
                    objEvt.RecordTypeId = recTypeClosedEvent;
                    objEvt.OwnerId = mapqueue.get('Closed Queue');
                    objEvt.DelayCostsCompleted__c = true;
                    objEvt.RecoveryPlanCompleted__c = true;
                    
                    if(String.IsNotBlank(objEvt.FlightNumber__c)){
                        Integer fNo = Integer.valueOf(objEvt.FlightNumber__c.subString(2));
                        if(fNo > 3000){
                            setEventId.add(objEvt.Id);
                        }
                    }                   
                    if(setFreightEventId.size()>0 && setFreightEventId.contains(objEvt.Id)){
                        objEvt.NoCommsReason__c = 'Event is automatically closed as flight Number is in Freight Range';
                    }else if(objEvt.DelayFailureCode__c == 'Flight Delay'){
                        objEvt.NoCommsReason__c = 'Event is automatically closed as flight is no longer delayed by more than the threshold and there is no in-flight disruptions';
                    }
                    else if(objEvt.DelayFailureCode__c == 'Flight Cancellation'){
                        objEvt.NoCommsReason__c = 'Event is automatically closed as flight cancelled before the threshold time.';
                    }
                }
            }
        }
    }
    
    //QDCUSCON-3394
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateEventArrivingAtDestination
    Description:        Notify the Owner when Flight about to land on the location
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void updateEventArrivingAtDestination(List<Event__c> lstEvent, Map<Id, Event__c> oldEventMap) {
        Integer oneMinuteInMinisecond = 60000;
        Integer halfHourInMinute = 30;
        
        // Get the value of closed Event status from config data customsetting
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        // Get the value of Assigned Event status from config data customsetting
        String statusAssignedEvent = CustomSettingsUtilities.getConfigDataMap('Event Assigned Status');
        // Get the value of domestic IntDom from config data customsetting
        String domestic = CustomSettingsUtilities.getConfigDataMap('Event Domestic IntDom');
        // Get the value of international IntDom from config data customsetting
        String international = CustomSettingsUtilities.getConfigDataMap('Event International IntDom');
        // Get the value of Event Auto-Closed from config data customsetting
        String autoClosedAction = CustomSettingsUtilities.getConfigDataMap('Event Auto-Closed CloseAction');
        // Get Id of Closed Event Record Type
        Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));
        String queueName = CustomSettingsUtilities.getConfigDataMap('QCC_AutoCloseQueueName');
        Group objQueueName;
        if(String.isNotBlank(queueName)){
            objQueueName = [select id from Group where type = 'Queue' and DeveloperName =: queueName];
        }
        
        for(Event__c objEvt : lstEvent){
            if(objEvt.RecordTypeId == GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'))){
                Event__c oldEvent = OldEventMap != Null? oldEventMap.get(objEvt.Id): Null;
                String ownerId = String.valueof(objEvt.OwnerId);
                system.debug('objEvt$$$$$$$'+objEvt);
                system.debug('oldEvent$$$$$$$'+oldEvent);
                //Updating Delay Failure Code
                //update the Delay Code if needed.
                //only update Delay code if the Code is Delay, do nothing for Flight diversion
                DateTime arrivalDT = objEvt.Actual_Arrival_UTC__c != Null?objEvt.Actual_Arrival_UTC__c:objEvt.Estimated_Arrival_UTC__c!= Null? objEvt.Estimated_Arrival_UTC__c: Null;
                if(arrivalDT != Null){
                    Boolean isNotifyValid = false;
                    Decimal remainedNowAndEst = Decimal.valueOf((arrivalDT.getTime()-Datetime.now().getTime())/oneMinuteInMinisecond);
                    system.debug('remainedNowAndEst$$$$$$$$$$$$'+remainedNowAndEst);
                    System.debug('condition: '+objEvt);
                    System.debug('condition: '+((objEvt.Status__c == statusAssignedEvent || objEvt.Status__c == 'Open') &&
                             (oldEvent == Null || objEvt.OwnerId != oldEvent.OwnerId ||
                              objEvt.Status__c != oldEvent.Status__c ||
                              objEvt.Estimated_Arrival_UTC__c != oldEvent.Estimated_Arrival_UTC__c ||
                              objEvt.Actual_Arrival_UTC__c != oldEvent.Actual_Arrival_UTC__c ||
                              ( (String.isBlank(oldEvent.Non_Delay_Failure_Code__c) || !oldEvent.Non_Delay_Failure_Code__c.containsIgnoreCase('Flight Cancellation'))
                               && String.isNotBlank(oldEvent.Non_Delay_Failure_Code__c) && (objEvt.Non_Delay_Failure_Code__c != null && objEvt.Non_Delay_Failure_Code__c.containsIgnoreCase('Flight Cancellation'))))));
                    //only run when the time is less than 30mins
                    if(remainedNowAndEst <= halfHourInMinute){
                        //Notify the owner it is new event or Estimate and Actual where null prior
                        if(oldEvent == Null || (oldEvent.Estimated_Arrival_UTC__c == Null && oldEvent.Actual_Arrival_UTC__c == Null)){
                            isNotifyValid = true;
                        }
                        
                    }else if( (objEvt.Status__c == statusAssignedEvent || objEvt.Status__c == 'Open') &&
                             (oldEvent == Null || objEvt.OwnerId != oldEvent.OwnerId ||
                              objEvt.Status__c != oldEvent.Status__c ||
                              objEvt.Estimated_Arrival_UTC__c != oldEvent.Estimated_Arrival_UTC__c ||
                              objEvt.Actual_Arrival_UTC__c != oldEvent.Actual_Arrival_UTC__c ||
                              ( (String.isBlank(oldEvent.DelayFailureCode__c) || !oldEvent.DelayFailureCode__c.containsIgnoreCase('Flight Cancellation'))
                               && String.isNotBlank(oldEvent.DelayFailureCode__c) && objEvt.DelayFailureCode__c.containsIgnoreCase('Flight Cancellation'))))
                    {
                        isNotifyValid = true;
                    }
                    system.debug('isNotifyValid####'+isNotifyValid);
                    
                    //Update the Notification
                    if(isNotifyValid){
                        if(ownerId.startsWithIgnoreCase('00G')){
                            objEvt.NotifyChatterGroup__c = true;
                            objEvt.NotifyEventOwner__c = false;
                        }else if(ownerId.startsWithIgnoreCase('005')){
                            objEvt.NotifyEventOwner__c = true;
                            objEvt.NotifyChatterGroup__c = false;
                        }
                        system.debug('objEvt.DelayFailureCode__c######'+objEvt.DelayFailureCode__c);
                        if(String.isNotBlank(objEvt.DelayFailureCode__c) && objEvt.DelayFailureCode__c.containsIgnoreCase('Flight Cancellation')){
                            objEvt.NotificationDateTime__c = system.now();
                        }else{
                            objEvt.NotificationDateTime__c = arrivalDT.addMinutes(-30);
                        }
                    }  
                }
            }
        }
    }
    
    //end QDCUSCON-3394 
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateEventFightInfo
    Description:        Invoke Flight API to Populate all the required values from CAP
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void updateEventFightInfo(List<Event__c> lstEvent,  Map<Id, Event__c> oldEventMap) {
        try{
            List<Id> submitForUpdateIds = new List<Id>();
            
            //handle insert and update flow
            for(Event__c ev : lstEvent){
                 if(ev.RecordTypeId == GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'))){
                     if( !ev.TECH_FlightAPIInvoked__c &&  String.isNotBlank(ev.FlightNumber__c) && 
                        String.isNotBlank(ev.DeparturePort__c) && String.isNotBlank(ev.ArrivalPort__c) 
                        && ev.ScheduledDepDate__c != Null){
                            submitForUpdateIds.add(ev.id);
                        }
                 }
            }
            
            
            
            if(submitForUpdateIds.size() > 0){
                QCC_EventFlightDetailsUpdateQueuable getFlightDetailJob = new QCC_EventFlightDetailsUpdateQueuable(submitForUpdateIds);
                ID jobID = System.enqueueJob(getFlightDetailJob);
            }
        }
        catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Event Trigger', 'EventTriggerHelper', 
                                    'updateEventFightInfo', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createRecovery
    Description:        Invoke FlightEvent is closed as Event Close Action Recovery And Comms
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void createRecovery(List<Event__c> lstEvent, Map<Id, Event__c> mapOldEvent){
        Set<Id> setEventIds = new Set<Id>();
        Boolean isError = false;
        for(Event__c objEvt: lstEvent){
            Event__c oldEvent = mapOldEvent != Null? mapOldEvent.get(objEvt.Id): Null;
            if( (oldEvent == null || oldEvent.Status__c != CustomSettingsUtilities.getConfigDataMap('Event Closed Status'))
               && objEvt.Status__c == CustomSettingsUtilities.getConfigDataMap('Event Closed Status')
               && objEvt.CloseAction__c == CustomSettingsUtilities.getConfigDataMap('Event Close Action Recovery And Comms')
               && !objEvt.RecoveryIsCreated__c){
                   setEventIds.add(objEvt.Id);
               }
        }
        System.debug('================================setEventIds '+ setEventIds);
        System.debug('================================lstEvent '+ lstEvent);
        System.debug('================================mapOldEvent '+ mapOldEvent);
        
        if(setEventIds.size()>0){
            Integer numberAffectedPassengers = [SELECT count() FROM Affected_Passenger__c 
                                                WHERE Affected__c = TRUE AND TECH_OfferedQantasPoints__c >0 AND
                                                Event__c =: setEventIds LIMIT 50000];
            if(numberAffectedPassengers == Null || numberAffectedPassengers == 0){
                isError = true;
            }
        }
        try{
            for(Event__c objEvt: lstEvent){
                if(setEventIds.contains(objEvt.Id)){
                    if(isError){
                        objEvt.addError(CustomSettingsUtilities.getConfigDataMap('Recovery Submitted No Passenger Msg'));
                    }else{
                        //Database.executeBatch(new QCC_EventSubmitRecoveriesBatchable(objEvt.Id), 10);
                        Database.executeBatch(new QCC_EventSubmitFFContRecoveriesBatchable(objEvt.Id), 10);
                        Database.executeBatch(new QCC_EventSubmitNonFFRecoveriesBatchable(objEvt.Id), 10);
                    }
                }
            }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Event Trigger', 'EventTriggerHelper', 
                                    'createRecovery', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        sendCommsOnEventClosure
    Description:        Invoked only when Flight event is closed as Event Close Action Comms sent
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void sendCommsOnEventClosure(List<Event__c> lstEvent, Map<Id, Event__c> mapOldEvent){
        Set<Id> setEventId = new Set<Id>();
        Set<Id> setGlobalEventId = new Set<Id>();
        Set<Id> setGlobalEventIdNoComms = new Set<Id>();
        List<Affected_Passenger__c> lstAftPass = new List<Affected_Passenger__c>();
        List<Event__c> lstEvt = new List<Event__c>();
        // Get Id of Closed Event Record Type
        Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));
        // Get Id of Actice Event Record Type 
        Id recTypeActiveEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
        Id recTypeGlobalEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Global Record Type'));
        for(Event__c objEvt: lstEvent){
            system.debug('objEvt####'+objEvt);
            system.debug('recTypeClosedEvent####'+recTypeClosedEvent);
            system.debug('recTypeActiveEvent####'+recTypeActiveEvent);
            system.debug('recTypeGlobalEvent####'+recTypeGlobalEvent);
            Event__c oldEvent = mapOldEvent.get(objEvt.Id);
            if(oldEvent.Status__c != objEvt.Status__c &&
               objEvt.Status__c == CustomSettingsUtilities.getConfigDataMap('Event Closed Status') && 
               objEvt.CloseAction__c == CustomSettingsUtilities.getConfigDataMap('Event Close Action Comms sent'))
            {
                if(objEvt.RecordTypeId == recTypeClosedEvent || objEvt.RecordTypeId == recTypeActiveEvent){
                    setEventId.add(objEvt.Id);
                }else if(objEvt.RecordTypeId == recTypeGlobalEvent){
                    setGlobalEventId.add(objEvt.Id);
                }
            }else if(oldEvent.Status__c != objEvt.Status__c &&
                    objEvt.Status__c == CustomSettingsUtilities.getConfigDataMap('Event Closed Status') && 
                    objEvt.CloseAction__c == CustomSettingsUtilities.getConfigDataMap('Event Close Action Comms not required') &&
                    objEvt.RecordTypeId == recTypeGlobalEvent)
            {
                setGlobalEventIdNoComms.add(objEvt.Id);
            }
        }
        system.debug('setGlobalEventId######'+setGlobalEventId);
        
        if(setEventId.size()>0){
            string query = 'Select Id, SendEmail__c, Event__c, Event__r.GlobalEvent__c  from Affected_Passenger__c where Event__c ';
            Integer batchCount =  String.isNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_CommsLimit'))? Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_CommsLimit')): 200;
            database.executeBatch(new QCC_CloseEventWithCommsBatchable(setEventId, query), batchCount);
        }
        
        if(setGlobalEventId.size()>0 || setGlobalEventIdNoComms.size()>0){
            if(setGlobalEventId.size()>0){
                string query = 'Select Id, SendEmail__c, Event__c, Event__r.GlobalEvent__c  from Affected_Passenger__c where Event__r.GlobalEvent__c ';
                Integer batchCount =  String.isNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_CommsLimit'))? Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_CommsLimit')): 200;
                database.executeBatch(new QCC_CloseEventWithCommsBatchable(setGlobalEventId, query), batchCount);
            }
            
            for(Event__c objEvt: [select Id, GlobalEvent__c, Status__c from Event__c where 
                                  (GlobalEvent__c IN: setGlobalEventId or GlobalEvent__c IN: setGlobalEventIdNoComms)and
                                   Status__c !=: CustomSettingsUtilities.getConfigDataMap('Event Closed Status')])
            {
                objEvt.Status__c =  CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
                if(setGlobalEventId.contains(objEvt.GlobalEvent__c)){
                    objEvt.CloseAction__c = CustomSettingsUtilities.getConfigDataMap('Event Close Action Comms sent');
                }
                else if(setGlobalEventIdNoComms.contains(objEvt.GlobalEvent__c)){
                    objEvt.CloseAction__c = CustomSettingsUtilities.getConfigDataMap('Event Close Action Comms not required');
                }
                objEvt.Closed_Date_Time__c =  Datetime.now();
                objEvt.Closed_By__c = UserInfo.getUserId();
                objEvt.NotifyEventOwner__c = false;
                objEvt.NotifyChatterGroup__c = false; 
                objEvt.IsEventReopened__c = false;
                objEvt.RecordTypeId = recTypeClosedEvent;
                objEvt.OwnerId = mapqueue.get('Closed Queue');
                lstEvt.add(objEvt);
            }
        }
        //system.debug('lstAftPass###'+lstAftPass);
        if(lstAftPass.size() > 0)
            update lstAftPass;
        if(lstEvt.size() > 0)
            update lstEvt;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createTaskforEvent
    Description:        when Task is owned by indiviuals and event is not closed 
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void createTaskforEvent(List<Event__c> lstEvent, Map<Id, Event__c> mapOldEvent){
        Map<Id, Event__c> mapEvent = new Map<Id, Event__c>();
        Map<Id, Task> mapTask = new Map<Id, Task>();
        List<Task> lstTask = new List<Task>();
        Id recTypeActiveEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
        
        for(Event__c objEvent: lstEvent){
            String ownerVal = objEvent.ownerId;
            Event__c oldEvent = mapOldEvent != Null? mapOldEvent.get(objEvent.Id): Null;
            if(objEvent.NotifyEventOwner__c && objEvent.RecordTypeId == recTypeActiveEvent && ownerVal.startsWith('005') &&
               (oldEvent == Null || objEvent.OwnerId != oldEvent.ownerId ||
                objEvent.NotifyEventOwner__c != oldEvent.NotifyEventOwner__c ||
                objEvent.NotificationDateTime__c != oldEvent.NotificationDateTime__c))
            {
                mapEvent.put(objEvent.Id, objEvent);
            }
        }
        
        delete [select Id, whatId from task where whatId IN: mapEvent.keyset()];
        
        for(Event__c objEvent: mapEvent.values()){
            String subject = 'Flight '+objEvent.FlightNumber__c+' for event '+objEvent.Name+' will be landing shortly, please prepare to send the appropriate communications if required';
            Task task = new Task();
            task.WhatId = objEvent.Id;
            task.OwnerId = objEvent.OwnerId;
            task.Subject = subject;
            task.priority= 'High';
            task.status = 'Not Started';
            task.description = 'New  Work';
            task.ActivityDate = date.newinstance(objEvent.NotificationDateTime__c.year(), objEvent.NotificationDateTime__c.month(), objEvent.NotificationDateTime__c.day());
            task.IsReminderSet = true;
            task.ReminderDateTime = objEvent.NotificationDateTime__c;
            lstTask.add(task);
        }
        upsert lstTask;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:       createEventComms
    Description:       Invoked when Flight Event is moved to assigned
    Parameter:         new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void createEventComms(List<Event__c> lstEvent, Map<Id, Event__c> mapOldEvent){
        Set<Id> setEventIds = new Set<Id>();
        Set<Id> setGlobalEventIds = new Set<Id>();
        Id recTypeActiveEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
        Id recTypeGlobalEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Global Record Type'));
        system.debug('lstEvent####'+lstEvent);
        for(Event__c objEvent: lstEvent){
            Event__c oldEvent = mapOldEvent != Null? mapOldEvent.get(objEvent.Id): Null;
            if(objEvent.Status__c == 'Assigned' &&
               (oldEvent == Null || objEvent.Status__c != oldEvent.Status__c))
            {
                if(objEvent.RecordTypeId ==  recTypeActiveEvent){
                    setEventIds.add(objEvent.Id);
                }
                else if(objEvent.RecordTypeId ==  recTypeGlobalEvent){
                    setGlobalEventIds.add(objEvent.Id);
                }
            }
          
        }
        system.debug('setEventIds####'+setEventIds);
        if(setEventIds.size()>0){
            QCC_EventGenericUtils.createEmailCommsForEvents(setEventIds);
        }
        
        if(setGlobalEventIds.size()>0){
            QCC_EventGenericUtils.createCommsForGlobalEvent(setGlobalEventIds);
        }
    } 
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createChildRecord
    Description:        Auto Create Action Plan and Cost, when new flight event is created
    Parameter:          new List (only on Insert)
    --------------------------------------------------------------------------------------*/      
    public static void createChildRecord(List<Event__c> lstEvent,  Map<Id, Event__c> mapOldEvent){
        List<Cost__c> lstCost = new List<Cost__c>();
        List<FlightFailure__c> lstFF = new List<FlightFailure__c>();
        Id recTypeActiveEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
        Id recTypeOffloadEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Offload Record Type'));
        Id recTypeGlobalEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Global Record Type'));
        
        for(Event__c objEvent: lstEvent){
            Event__c oldEvent = mapOldEvent == Null? Null: mapOldEvent.get(objEvent.Id);
            if(oldEvent == Null || objEvent.RecordTypeId != oldEvent.RecordTypeId){
                //Active Recordtype
                if(recTypeActiveEvent == objEvent.RecordTypeId || recTypeGlobalEvent == objEvent.RecordTypeId){
                    Cost__c objCost = new Cost__c();
                    objCost.FlightEvent__c = objEvent.Id; 
                    lstCost.add(objCost);
                }
                //Offload Recordtype
                if(recTypeOffloadEvent == objEvent.RecordTypeId){
                    FlightFailure__c objFF = new FlightFailure__c();
                    objFF.Failure_Code__c = 'Offload';
                    objFF.Affected_Region__c = 'Full Flight';
                    objFF.Affect_Sub_Section__c = 'Full Flight';
                    objFF.Flight_Event__c = objEvent.Id; 
                    lstFF.add(objFF);
                }
            }
        }
        insert lstFF;
        insert lstCost;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        convertRecordtype
    Description:        Convert from Offload Event to Active Flight Event, when new delay failure code
                        is added. For Delay only on departure move to active.
    Parameter:          new List
    --------------------------------------------------------------------------------------*/      
    public static void convertRecordtype(List<Event__c> lstEvent){
        Id recTypeActiveEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
        Id recTypeOffloadEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Offload Record Type'));
        for(Event__c objEvt: lstEvent){
            if(objEvt.RecordTypeId == recTypeOffloadEvent && String.isNotBlank(objEvt.DelayFailureCode__c)){
                if(objEvt.ActualDepaDateTime__c != Null && 
                    (objEvt.DelayFailureCode__c == 'Flight Delay' || objEvt.Non_Delay_Failure_Code__c.split(';').size()>1))
                {
                    objEvt.RecordTypeId = recTypeActiveEvent;
                }else if(objEvt.DelayFailureCode__c != 'Flight Delay'){
                    objEvt.RecordTypeId = recTypeActiveEvent;
                }
            }
        }
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getProfileMapByProfileNames
    Description:        Get the Map of all profiles, (Profile Name, Profile)
    Parameter:          List of Profile Names
    --------------------------------------------------------------------------------------*/      
    private static Map<String, Profile> getProfileMapByProfileNames(List<String> profileNames){
        Map<String, Profile> profileMap = new Map<String, Profile>();
        List<Profile> profiles = [SELECT Name, Id FROM Profile WHERE Name IN: profileNames];
        
        for(Profile p: profiles){
            profileMap.put(p.Name, p);
        }
        return profileMap;
    }


    /*--------------------------------------------------------------------------------------      
    Method Name:       postEventClosedAction
    Description:       Updates Flight Delay Reason, Owner to Cost are closed Queue.
    Parameter:         Map New and Map or Old 
    --------------------------------------------------------------------------------------*/      
    public static void postEventClosedAction(Map<Id, Event__c> newEventMap, Map<Id, Event__c> oldEventMap){
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        list<id> listClosedEvent = new List<Id>();
        Id recTypeClosedEvent = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type'));

        for(Event__c ev : newEventMap.values()){
            if(oldEventMap == null || (oldEventMap.get(ev.Id).Status__c != ev.Status__c)){
                if(ev.Status__c == statusClosedEvent && ev.RecordTypeId == recTypeClosedEvent &&
                    ev.DelayFailureCode__c == 'Flight Delay'){
                    listClosedEvent.add(ev.id);
                }
            }
        }
        if(listClosedEvent.size() == 0){
            return;
        }
        QCC_EventClosedPostActionQueueable queuableJob = new QCC_EventClosedPostActionQueueable(new List<Id>(newEventMap.keyset()));
        ID jobID = System.enqueueJob(queuableJob);
    }
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:       updateEventCost
    Description:       Update Total Recovery Points provided to Customer
    Parameter:         List of Events, Old Map
    --------------------------------------------------------------------------------------*/      
    public static void updateEventCost(List<Event__c> lstEvent, Map<Id, Event__c> oldEventMap){
        List<String> lstEventIds = new List<String>();
        //get list of event which has RecoveryIsCreated__c == true
        for(Event__c ev : lstEvent){
            Event__c oldEvent = oldEventMap.get(ev.Id);
            if(oldEvent.RecoveryIsCreated__c != true && ev.RecoveryIsCreated__c == true ){
                lstEventIds.add(ev.Id);
            }
        }
        //calculate the list of Cost from list of event
        Map<String, Decimal> mapEvent_TotalCost = new Map<String, Decimal>();
        for(Affected_Passenger__c afp : [Select Id,TECH_OfferedQantasPoints__c, Event__c From Affected_Passenger__c 
                                         Where RecoveryIsCreated__c = true and Event__c IN:lstEventIds])
        {
            Decimal total = mapEvent_TotalCost.containsKey(afp.Event__c)?mapEvent_TotalCost.get(afp.Event__c):0;
            total+= afp.TECH_OfferedQantasPoints__c;
            mapEvent_TotalCost.put(afp.Event__c, total);
        }

        //update Cost Total_Recovery_Points__c
        List<Cost__c> lstCost = new List<Cost__c>();
        for(Cost__c c : [Select Id, Total_Recovery_Points__c, FlightEvent__c from Cost__c  where 
                         FlightEvent__c IN :mapEvent_TotalCost.keyset()])
        {
            c.Total_Recovery_Points__c = mapEvent_TotalCost.get(c.FlightEvent__c);
            lstCost.add(c);
        }

        if(lstCost.size() > 0){
            Database.update(lstCost);
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:       manualAddStop
    Description:       Manually Add Stop Event 
    Parameter:         List of Events, Old Map
    --------------------------------------------------------------------------------------*/      
    public static void manualAddStop(List<Event__c> lstEvent, Map<Id, Event__c> oldEventMap){
        String userName = UserInfo.getUserName();
        Map<Id, Event__c> mapEvent = new Map<Id, Event__c>();
        Map<Id, String> mapOldDelay = new Map<Id, String>();
        Map<String, Event__c> mapFlightNum = new Map<String, Event__c>();
        List<FlightFailure__c> lstDelFF = new List<FlightFailure__c>();
        List<FlightFailure__c> lstInsertFF = new List<FlightFailure__c>();
        List<Flight_Tracker__c> lstDelFT = new List<Flight_Tracker__c>();
        List<Flight_Tracker__c> lstUpdateFT = new List<Flight_Tracker__c>();
        Set<String> setFlightNumber = new Set<String>();
        Set<Date> setOriginDate = new Set<Date>();
        Set<Id> setAddFltEvt = new Set<Id>();

        for(Event__c objEvt: lstEvent){
            Event__c oldEvt = oldEventMap.get(objEvt.Id);
            if(userName != CustomSettingsUtilities.getConfigDataMap('QCC_QSOAUserName') && 
               objEvt.DelayFailureCode__c == 'Add Stop' && objEvt.DelayFailureCode__c != oldEvt.DelayFailureCode__c)
            {
                mapEvent.put(objEvt.Id, objEvt);
                setFlightNumber.add(objEvt.FlightNumber__c);
                setOriginDate.add(objEvt.OriginDate__c);
                if(String.isNotBlank(oldEvt.DelayFailureCode__c)){
                    mapOldDelay.put(objEvt.Id, oldEvt.DelayFailureCode__c);
                }
            }
        }
        
        system.debug('mapEvent###'+mapEvent);
        system.debug('mapOldDelay###'+mapOldDelay);

        if(mapEvent != Null && mapEvent.size()>0){

            //Query the Flight Failure and Delete
            for(FlightFailure__c objFF: [select Id, Flight_Event__c, Failure_Code__c from FlightFailure__c where 
                                        Flight_Event__c IN: mapEvent.keyset()])
            {
                if(mapOldDelay.containsKey(objFF.Flight_Event__c) && mapOldDelay.get(objFF.Flight_Event__c) == objFF.Failure_Code__c){
                    lstDelFF.add(objFF);
                }
                else if(objFF.Failure_Code__c == 'Add Stop'){
                    setAddFltEvt.add(objFF.Flight_Event__c);
                }
            }

            //Create Add Stop FF
            for(Id evtId: mapEvent.keyset()){
                if(setAddFltEvt.size() == 0 || !(setAddFltEvt.contains(evtId))){
                    Event__c objEvt = mapEvent.get(evtId);
                    FlightFailure__c objFF = new FlightFailure__c();
                    objFF.Failure_Code__c = objEvt.DelayFailureCode__c;
                    objFF.Pre_Flight__c = true;
                    objFF.Flight_Event__c = evtId;
                    objFF.Affected_Region__c = 'Full Flight';
                    objFF.Affect_Sub_Section__c = 'Full Flight';
                    lstInsertFF.add(objFF);
                }
            }
            system.debug('lstDelFF###'+lstDelFF);
            system.debug('lstInsertFF###'+lstInsertFF);
            delete lstDelFF;
            insert lstInsertFF;

            Map<String, List<Flight_Tracker__c>> mapFT = new Map<String, List<Flight_Tracker__c>>();
            //Merge Flight Tracker
            for(Flight_Tracker__c objFT: [select Id,Flight_Number__c, Event_Name__c, Departure_Airport__c , Arrival_Airport__c, 
                                          Origin_Date__c, TrackerType__c, MessageId__c from Flight_Tracker__c where 
                                          Flight_Number__c IN: setFlightNumber and Origin_Date__c IN: setOriginDate])
            {
                List<Flight_Tracker__c> lstFT = mapFT.containsKey(objFT.Flight_Number__c)? mapFT.get(objFT.Flight_Number__c): new List<Flight_Tracker__c>();
                lstFT.add(objFT);
                mapFT.put(objFT.Flight_Number__c, lstFT);
            }

            for(String flightNumber: mapFlightNum.keyset()){
                Event__c objEvt = mapFlightNum.get(flightNumber);
                List<Flight_Tracker__c> lstFT = mapFT.containsKey(flightNumber)?mapFT.get(flightNumber): Null;
                if(lstFT != Null){
                    for(Flight_Tracker__c objFT: lstFT){
                        if(objEvt.DeparturePort__c == objFT.Departure_Airport__c && objEvt.ArrivalPort__c == objFT.Arrival_Airport__c)
                        {
                            objFT.NewArrivalPort__c = objEvt.Diverted_Port__c;
                            lstUpdateFT.add(objFT);
                        }
                        else{
                            if(objFT.Departure_Airport__c == objEvt.Diverted_Port__c && objFT.Arrival_Airport__c == objEvt.Diverted_Port__c){
                                lstDelFT.add(objFT);
                            }
                        }
                    }
                }
            }
            delete lstDelFT;
            update lstUpdateFT;
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:       validateEventBeforeAssigningToCC
    Description:       Validate all the checklist are complted before asssigning to customer care
    Parameter:         List of Events, Old Map
    --------------------------------------------------------------------------------------*/      
    public static void validateEventBeforeAssigningToCC(List<Event__c> lstEvent, Map<Id, Event__c> oldEventMap){

        Map<Id, Integer> mapActPlanCount = new Map<Id, Integer>();

        for(Event__c objEvt: lstEvent){
            Event__c oldEvt = oldEventMap != Null ? oldEventMap.get(objEvt.Id): Null;
            if(objEvt.RecoveryPlanCompleted__c && (oldEvt == Null || 
                    objEvt.RecoveryPlanCompleted__c != oldEvt.RecoveryPlanCompleted__c))
            {
                mapActPlanCount.put(objEvt.Id, 0);
            }
        }

        if(mapActPlanCount.size() > 0){
            for(EventActionPlan__c objEvtPlan: [select Id, FlightEvent__c, ActionCompleted__c from EventActionPlan__c 
                                                where FlightEvent__c IN: mapActPlanCount.keyset() and ActionCompleted__c !=: true])
            {
                Integer count = mapActPlanCount.get(objEvtPlan.FlightEvent__c)+1;
                mapActPlanCount.put(objEvtPlan.FlightEvent__c, count);
            }
            for(Event__c objEvt: lstEvent){
                if(mapActPlanCount.containsKey(objEvt.Id) && mapActPlanCount.get(objEvt.Id) > 0){
                    objEvt.addError(label.IOC_ChecklistValidation);
                }
            }
        }
    } 

    /*--------------------------------------------------------------------------------------      
    Method Name:       getAllQueues
    Description:       All Different Flight Event Queues
    Parameter:        
    --------------------------------------------------------------------------------------*/      
    public static  Map<String, Id> getAllQueues(){
        Map<String, Id> mapqueue = new Map<String, Id>();
        List<String> lstQueues = new List<String>();
        lstQueues.add('QCC_EventCostQueue');
        lstQueues.add('QCC_EventClosedQueue');
        lstQueues.add('QCC_EventsAssigned');
        lstQueues.add('CCC_CJM_Queue');

        for(Group objQueue: [Select Id, Name, DeveloperName from Group where Type = 'Queue' and 
                             DeveloperName IN: lstQueues])
        {
            String queueType = CustomSettingsUtilities.getConfigDataMap(objQueue.DeveloperName);
            mapqueue.put(queueType, objQueue.Id);
        }
        return mapqueue;
    }

}