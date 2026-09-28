/*----------------------------------------------------------------------------------------------------------------------
Author:        
Company:       Capgemini
Description:   
Inputs:
Test Class: AffectedPassengerTriggerHelperTest   
************************************************************************************************
History
************************************************************************************************
05-May-2018                    
28-Sep-2019		GRAPHITE-119,114,115,116 - Added new method for automatically creating cases for Flight Event Active
-----------------------------------------------------------------------------------------------------------------------*/
public class AffectedPassengerTriggerHelper {
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        isAffectedPassenger
    Description:        All Before Trigger Functionalities
    Parameter:          new List and old Map records
    --------------------------------------------------------------------------------------*/      
    public static void isAffectedPassenger(List<Affected_Passenger__c> lstAffectedPassengers, Map<Id, Affected_Passenger__c> oldAFPMap) {
        try {
            Set<Id> setAllEvnId = new Set<Id>();
            Set<Id> setEvnId = new Set<Id>();
            Map<Id, List<FlightFailure__c>> mapFltFailure = new Map<Id, List<FlightFailure__c>>();
            Map<Id, List<EventCommunication__c>> mapEvtComms = new Map<Id, List<EventCommunication__c>>();
            
            //Check if Pre and Post Flight is changed
            for(Affected_Passenger__c objPas: lstAffectedPassengers){
                Affected_Passenger__c objOldPas = oldAFPMap != Null? oldAFPMap.get(objPas.Id): Null;
                if(objOldPas == Null || objPas.TECH_PreFlight__c != objOldPas.TECH_PreFlight__c || 
                   objPas.TECH_PostFlight__c != objOldPas.TECH_PostFlight__c)
                {
                    setAllEvnId.add(objPas.Event__c);
                    if( String.isBlank(objPas.GlobalEvent__c) ){
                        setEvnId.add(objPas.Event__c);
                    }else{
                        setEvnId.add(objPas.GlobalEvent__c);
                    }
                }
            }
            
            if(setEvnId.size()>0 && setAllEvnId.size()>0){
                
                //Get All Failures Related to the Event
                mapFltFailure = QCC_EventGenericUtils.queryFlightFailures(setAllEvnId);   
                
                //Get All Events Related to the Event
                mapEvtComms = QCC_EventGenericUtils.queryEvtComms(setEvnId);
                
                for(Affected_Passenger__c objPas: lstAffectedPassengers){
                    List<FlightFailure__c> lstFltFailure = mapFltFailure.containsKey(objPas.Event__c)? mapFltFailure.get(objPas.Event__c): new List<FlightFailure__c>();
                    List<EventCommunication__c> lstEvtComms = mapEvtComms.containsKey(objPas.Event__c)? mapEvtComms.get(objPas.Event__c): new List<EventCommunication__c>();
                    if(lstFltFailure != Null){
                        objPas = QCC_EventGenericUtils.updatePassengerFailureCode(objPas, lstFltFailure, lstEvtComms);
                    }
                }
                
            }
        } catch(Exception ex){
            System.debug('Exception: '+ex.getMessage());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Affected Passenger Trigger', 'AffectedPassengerTriggerHelper', 
                                    'isAffectedPassenger', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        updateFullEmailBody
Description:        Add the mail content of email in FullEmailBody field
Parameter:          new List and old Map records
--------------------------------------------------------------------------------------*/      
    public static void updateFullEmailBody(List<Affected_Passenger__c> lstAffectedPassengers, Map<Id, Affected_Passenger__c> oldAFPMap){
        set<ID> setPassId = new Set<Id>();
       
        //Check if Pre and Post Flight is changed
        for(Affected_Passenger__c objPas: lstAffectedPassengers){
            Affected_Passenger__c objOldPas = oldAFPMap != Null? oldAFPMap.get(objPas.Id): Null;
            if(objOldPas.SendEmail__C != objPas.SendEmail__c && objPas.SendEmail__c == true)
            {
                setPassId.add(objPas.Id);
                
            }
        }
        if(setPassId.size()>0){
            Map<Id, Id> mapPassengerTemplate = new Map<Id, Id>();
            Set<String> setEmailTemplateName = new Set<String>();
            setEmailTemplateName.add('QCC_PassengerCommsWithOutRecovery');
            setEmailTemplateName.add('QCC_PassengerCommsWithRecoveryFF');
            setEmailTemplateName.add('QCC_PassengerCommsWithRecoveryNFF');
            setEmailTemplateName.add('QCC_GlobalTemplate');
            
            Map<String, Id> mapObj = new Map<String, Id>();
            Contact objCon = new Contact();
            List<Contact> lstCon = [Select Id from Contact where Email = 'noreplyiocevents@qantas.com.au' Limit 1];
            if(lstCon == Null || lstCon.size() == 0){
                objCon = [Select Id from Contact where Email != Null Limit 1];
            }else{
                objCon = lstCon[0];
            }
            for(EmailTemplate objET: [ select Id, Name, Body, Subject, HTMLValue  from EmailTemplate where 
                                      Name IN: setEmailTemplateName])
            {
                mapObj.put(objET.Name, objET.Id);
            }
            Set<Id> nullContactPassengers = new Set<Id>();
            for(Affected_Passenger__c objPas: [select id,passenger__r.recordtype.DeveloperName from Affected_Passenger__c where id in :setPassId ]){
                if(objPas.passenger__r.recordtype.DeveloperName == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Placeholder').getDeveloperName()){
                    nullContactPassengers.add(objPas.Id);
                }
            }
            system.debug('nullContactPassengers#####'+nullContactPassengers);
            for(Affected_Passenger__c objPas: lstAffectedPassengers){
                if(setPassId.contains(objPas.Id)){
                    Id ETId;
                    if(String.isNotBlank(objPas.GlobalEvent__c)){
                        ETId =  mapObj.get('QCC_GlobalTemplate');
                    }else if(objPas.TECH_OfferedQantasPoints__c >0 && objPas.TECH_OfferedQantasPoints__c != Null && 
                             objPas.EventCloseAction__c == CustomSettingsUtilities.getConfigDataMap('Event Close Action Recovery And Comms'))
                    {
                        if(String.isNotBlank(objPas.FrequentFlyerNumber__c)){
                            ETId =   mapObj.get('QCC_PassengerCommsWithRecoveryFF');
                        }
                        else if(objPas.Passenger__c!=Null && !nullContactPassengers.contains(objPas.Id)){
                            ETId =   mapObj.get('QCC_PassengerCommsWithRecoveryNFF');
                        }
                        else{
                            ETId =   mapObj.get('QCC_PassengerCommsWithOutRecovery');
                        }
                        
                    }else{
                        ETId =   mapObj.get('QCC_PassengerCommsWithOutRecovery');
                    }
                    mapPassengerTemplate.put(objPas.Id, ETId);
                    //objPas.FullEmailBody__c = 'Email Body will be added';QCC_EmailPreviewController.formEmailConent(objPas.Id, ETId, objCon.Id);
                }
            }
            
            if(mapPassengerTemplate.size() > 0){
                Map<Id, String> mapEmailContent = new Map<Id, String>();
                system.debug('mapEmaixlContent####'+mapPassengerTemplate);
                mapEmailContent = formEmailConent(mapPassengerTemplate, objCon.Id);
                system.debug('mapEmailContent####'+mapEmailContent.keyset());
                for(Affected_Passenger__c objPas: lstAffectedPassengers){
                    system.debug('mapEmailContentinside ####'+mapEmailContent.get(objPas.Id));
                    objPas.FullEmailBody__c = mapEmailContent.get(objPas.Id);
                }
            }
        }
    }
    
    public static Map<Id, String> formEmailConent(Map<Id, Id> mapPassengerTemplate, String conId){
        Map<Id, String> mapEmailContent = new Map<Id, String>();
        List<Id> lstWhatId = new List<Id>();
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        for(Id whatId: mapPassengerTemplate.keyset()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'praveen.sampath@capgemini.com'};
            mail.setToAddresses(toAddresses);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            mail.setWhatId(whatId);
            mail.setTemplateId(mapPassengerTemplate.get(whatId));
            mail.setTargetObjectId(conId);
            allMails.add(mail);
            lstWhatId.add(whatId);
            system.debug('Mail tempalte ########'+mapPassengerTemplate.get(whatId));
        }
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(allMails);
        Database.rollback(sp);
        
        system.debug('allMails####'+allMails.size());
        system.debug('lstWhatId####'+lstWhatId);
        
        Integer i =0;
        for(Messaging.SingleEmailMessage mail: allMails){
             system.debug('mail####'+mail.getSubject());
            String mailHtmlBody = mail.getPlainTextBody();
            String mailSubject = mail.getSubject();
            String response = 'Subject : '+ mailSubject+' \r\n\r\nEmail Body :'+mailHtmlBody.trim();
            mapEmailContent.put(lstWhatId[i], response);
            i++;
        }
        return mapEmailContent;
    }

    public static void updateAirportName(list<Affected_Passenger__c> lstPassenger){
        Map<String, String> airportName = new Map<String, String>();
        for(Airport_Code__c eachCode : [SELECT Id, Name, Freight_Station_Name__c, Freight_Airport_State_Code__c
                                              FROM Airport_Code__c limit 40000]){
            airportName.put(eachCode.Name, eachCode.Freight_Station_Name__c);                                  
        }

        for(Affected_Passenger__c afp : lstPassenger){
            if(!String.isBlank(afp.ArrivalPort__c)){
                afp.Arrival_Port_Name__c = airportName.get(afp.ArrivalPort__c);
                if(String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(afp.Arrival_Port_Name__c))){
                    afp.Arrival_Port_Name__c = CustomSettingsUtilities.getConfigDataMap(afp.Arrival_Port_Name__c);
                }
            }
            if(!String.isBlank(afp.DeparturePort__c)){
                afp.Departure_Port_Name__c = airportName.get(afp.DeparturePort__c);
                if(String.isNotBlank(CustomSettingsUtilities.getConfigDataMap(afp.Departure_Port_Name__c))){
                    afp.Departure_Port_Name__c = CustomSettingsUtilities.getConfigDataMap(afp.Departure_Port_Name__c);
                }
            }
        }
    } 

    public static void rollupPassengerBasedonTier(List<Affected_Passenger__c> lstAffectedPassengers, Map<Id, Affected_Passenger__c> oldAFPMap){
        Set<Id> setEventId = new Set<Id>();
        List<Event__c> lstEvt = new List<Event__c>();
        
        if(lstAffectedPassengers != Null){
            //Insert and update
            for(Affected_Passenger__c objAffPass: lstAffectedPassengers){
                Affected_Passenger__c oldAffPass = oldAFPMap != Null? oldAFPMap.get(objAffPass.Id): Null;
                if((oldAffPass == Null && objAffPass.Affected__c == true) || 
                   (oldAffPass != Null && objAffPass.Affected__c != oldAffPass.Affected__c))
                {
                    setEventId.add(objAffPass.Event__c);
                }
            }
        }
        
        //Delete Of Passenger
        if(lstAffectedPassengers == Null && oldAFPMap != Null){
            for(Affected_Passenger__c objAffPass: oldAFPMap.values()){
                setEventId.add(objAffPass.Event__c);
            }  
        }
        
        
        if(setEventId.size()>0){
            Map<Id, Event__c> mapEvent = new Map<Id, Event__c>([select Id from Event__c where Id IN: setEventId]);
            AggregateResult[] groupedResults = [SELECT Event__c, FrequentFlyerTier__c, count(Id) FROM 
                                                Affected_Passenger__c where  Event__c IN: setEventId 
                                                GROUP BY Event__c, FrequentFlyerTier__c];
            for (AggregateResult ar : groupedResults)  {
                System.debug('Campaign ID' + ar.get('Event__c'));
                System.debug('Average amount' + ar.get('FrequentFlyerTier__c'));
                System.debug('Average amount' + ar.get('expr0'));
                String EvtId = String.ValueOf(ar.get('Event__c'));
                String Tier = String.ValueOf(ar.get('FrequentFlyerTier__c'));
                String fieldName =  CustomSettingsUtilities.getConfigDataMap(Tier+'fld');
                fieldName = String.isNotBlank(fieldName)?fieldName:CustomSettingsUtilities.getConfigDataMap(Tier+'EventField');
                if(String.isNotBlank(fieldName)){
                    Event__c objEvent = mapEvent.get(EvtId);
                    objEvent.put(fieldName, Integer.valueOf(ar.get('expr0')));
                    mapEvent.put(objEvent.Id, objEvent);
                }
            }
            lstEvt.addAll(mapEvent.values());
            update lstEvt;
        }
    }

    public static void populateContactOnOffload(List<Affected_Passenger__c> lstAffectedPassengers, Map<Id, Affected_Passenger__c> oldAFPMap){
        List<Case> lstCase = new List<Case>();
        for(Affected_Passenger__c objPass: lstAffectedPassengers){
            Affected_Passenger__c oldPass = oldAFPMap != Null? oldAFPMap.get(objPass.Id): Null;
            system.debug('oldPass####'+oldPass);
            system.debug('objPass####'+objPass);
            
            //check for affected if offloadRequest is check Accepted
            if((objPass.OffloadRequest__c == 'Accepted' || objPass.OffloadRequest__c == 'Declined') && objPass.Affected__c == false && 
                objPass.RecordTypeId == GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', CustomSettingsUtilities.getConfigDataMap('QCC Offload Passenger RecType')))
            {
                objPass.Affected__c = true;
            }else if(objPass.OffloadRequest__c != 'Accepted' && objPass.OffloadRequest__c != 'Declined' && objPass.Affected__c  == true && 
                     objPass.RecordTypeId == GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', CustomSettingsUtilities.getConfigDataMap('QCC Offload Passenger RecType')))
            {
                objPass.Affected__c = false;
            }
            
            if(objPass.OffloadRequest__c == 'Accepted' && objPass.OffloadRequest__c != oldPass.OffloadRequest__c){
                if(objPass.Passenger__c == Null){
                    QCC_GenericUtils.ContactWrap conWrap = QCC_GenericUtils.fetchContactForNonFFCases();
                    objPass.Passenger__c = conWrap.objCon.ID; 
                }
            }
        }
    }
    
    public static void createOffloadCase(List<Affected_Passenger__c> lstAffectedPassengers, Map<Id, Affected_Passenger__c> oldAFPMap){
        List<Case> lstCase = new List<Case>();
        for(Affected_Passenger__c objPass: lstAffectedPassengers){
            Affected_Passenger__c oldPass = oldAFPMap != Null? oldAFPMap.get(objPass.Id): Null;
            system.debug('oldPass####'+oldPass);
            system.debug('objPass####'+objPass);
            if(objPass.OffloadRequest__c == 'Accepted' && objPass.OffloadRequest__c != oldPass.OffloadRequest__c){
                Case objCase = new Case();
                objCase.ContactId = objPass.Passenger__c;
                objCase.Contact_Email__c = objPass.Email__c;
                objCase.Cabin_Class__c = objPass.Cabin__c;
                objCase.FF_Tier__c = objPass.FrequentFlyerTier__c;
                objCase.Group__c = CustomSettingsUtilities.getConfigDataMap('Case Group Event');
                objCase.Priority = CustomSettingsUtilities.getConfigDataMap('Case Priority Medium');
                objCase.First_Name__c = objPass.FirstName__c;
                objCase.Last_Name__c = objPass.LastName__c; 
                objCase.Event__c = objPass.Event__c;
                objCase.Flight_Number__c = objPass.FlightNumber__c;
                objCase.Arrival_Airport_Code__c = objPass.ArrivalPort__c;
                objCase.Departure_Airport_Code__c = objPass.DeparturePort__c;
                objCase.Departure_Date_Time__c = objPass.ScheduleDepDateTime__c;
                objCase.Arrival_Date_Time__c = objPass.ScheduleArrDateTime__c;
                objCase.Subject = 'Passenger has agreed to offload from '+objPass.FlightNumber__c;
                objCase.Description = objPass.OffloadComments__c;
                objCase.Origin = CustomSettingsUtilities.getConfigDataMap('Case Origin Event');
                objCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
                objCase.Type = CustomSettingsUtilities.getConfigDataMap('Case Type Event');
                objCase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Offload RecType'));
                lstCase.add(objCase);
            }
        }
        insert lstCase;
    }

    public static void checkVIPPassenger(List<Affected_Passenger__c> lstAffectedPassengers, Map<Id, Affected_Passenger__c> oldAFPMap) {
        Map<String, List<String>> contactToPassengers_Map = new Map<String, List<String>>(); //Map of <ContactId, List<PassengerIds>>. In case where a single contact is mapped to multiple passenger entries
        Set<Id> affectedPassengerIds = new Set<Id>();
        //GRAPHITE-2221 Create a new set to check if the case is already existing
        Set<String> frequentFlyerNumbers = new Set<String>();
        Set<String> flightNumbers = new Set<String>();
        Set<String> pnrs = new Set<String>();

        //GRAPHITE-2221 Create a map to list all existing passenger in the bulk to check if they have existing case records.
        //Key: FlightNumber__c + PNR__c + FrequentFlyerNumber__c
        Map<Id, Affected_Passenger__c> passengerMap = new Map<Id, Affected_Passenger__c>();

        //Get only the passengers who are part of the VIP based on their Frequent Flyer Tier
        for (Affected_Passenger__c passenger : lstAffectedPassengers) {
            List<String> vipTiers = Label.QCC_Flight_Event_VIPs.split(';');
            system.debug('>>>checkVIPPassenger - vipTiers: ' + vipTiers);
            if (vipTiers.contains(passenger.FrequentFlyerTier__c)) {
                affectedPassengerIds.add(passenger.Id);
            }

            //Passenger may not have a vip Tier, but is marked as SSU. Collect still the contact Id to be used in querying the Contact records with the SSU flag
            if (passenger.Passenger__c != NULL) {
                String contactId_key = passenger.Passenger__c;
                List<String> passengerIds_Temp = (contactToPassengers_Map.containsKey(contactId_key)) ? contactToPassengers_Map.get(contactId_key) : new List<String>();
                passengerIds_Temp.add(passenger.Id);
                contactToPassengers_Map.put(contactId_key, passengerIds_Temp);
            }

            //GRAPHITE-2221 Store the existing passenger to the map
            passengerMap.put(passenger.Id, passenger);

            frequentFlyerNumbers.add(passenger.FrequentFlyerNumber__c);
            flightNumbers.add(passenger.FlightNumber__c);
            pnrs.add(passenger.PNR__c);
        }
        system.debug('>>>checkVIPPassenger - contactToPassengers_Map: ' + contactToPassengers_Map);
        system.debug('passengerMap: ' + passengerMap);

        //Check if the contact is SSU
        if (!contactToPassengers_Map.isEmpty()) {
            for (Contact con : [SELECT Id, Name, SSU__c FROM Contact WHERE Id IN : contactToPassengers_Map.keySet() AND SSU__c = TRUE]) {
                String contactId_key = con.Id;
                for (String passengerId : contactToPassengers_Map.get(contactId_key)) {
                    affectedPassengerIds.add(passengerId);
                }
            }
        }

        //Exclude passengers with disruption case already created for the same flight event
        Map<String, Case> disruptionCaseMap = new Map<String, Case>();
        String recordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('QCC Case Disruption'));
        List<Case> caseRecords = [
            SELECT Id, Passenger_Id__c, RecordTypeId, Flight_Number__c,
            Booking_PNR__c, Frequent_Flyer_Number__c
            FROM Case
            WHERE RecordTypeId =:recordTypeId
            AND Frequent_Flyer_Number__c IN :frequentFlyerNumbers
            AND Flight_Number__c IN :flightNumbers
            AND Booking_PNR__c IN :pnrs
        ];
        System.debug('existingCaseRecords: ' + caseRecords);
        for (Case caseRec : caseRecords) {
            String disruptionCaseKey = caseRec.Flight_Number__c + '###' + caseRec.Booking_PNR__c + '###' + caseRec.Frequent_Flyer_Number__c;
            disruptionCaseMap.put(disruptionCaseKey, caseRec);
        }

        Set<Id> passengersToCreateDisruptionCase = new Set<Id>();
        List<Case> caseRecordsToUpdatePassengerId = new List<Case>();
        for(String affectedPassengerId : affectedPassengerIds) {
            Affected_Passenger__c passengerRecord = passengerMap.get(affectedPassengerId);
            String disruptionPassengerKey = passengerRecord.FlightNumber__c + '###' + passengerRecord.PNR__c + '###' + passengerRecord.FrequentFlyerNumber__c;
            System.debug('disruptionPassengerKey: ' + disruptionPassengerKey);

            //GRAPHITE-2221 Create a disruption case if not existing. Otherwise update the Passenger_Id__c of the case record.
            if (!disruptionCaseMap.containsKey(disruptionPassengerKey)) {
                passengersToCreateDisruptionCase.add(affectedPassengerId);
            } else {
                Case caseRecordToUpdate = disruptionCaseMap.get(disruptionPassengerKey);
                caseRecordToUpdate.Passenger_Id__c = passengerRecord.Id;
                caseRecordsToUpdatePassengerId.add(caseRecordToUpdate);
        }
        }
        System.debug('passengersToCreateDisruptionCase: ' + passengersToCreateDisruptionCase);
        System.debug('caseRecordsToUpdatePassengerId: ' + caseRecordsToUpdatePassengerId);

        if (!affectedPassengerIds.isEmpty() && !System.isBatch()) {
            createDisruptionCase(passengersToCreateDisruptionCase, JSON.serialize(caseRecordsToUpdatePassengerId));
        }
    }

    @future
    public static void createDisruptionCase (Set<Id> affectedPassengerIds, String caseRecordsToUpdate) {
        //Get the custom metadata type for this object
        String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
        List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords (metaName, '');
        system.debug('>>>createDisruptionCase - metaObjects: ' + metaObjects);

        //Compile the Source to Target Mapping into a Map with key of Module Name
        Map<String, List<sObject>> moduleNameMapping = new Map<String, List<sObject>>();
        for (sObject moduleRec : metaObjects) {
            String moduleName = String.valueOf(moduleRec.get('Module_Name__c'));
            List<sObject> mappingList_Temp = (moduleNameMapping.containskey(moduleName)) ? moduleNameMapping.get(moduleName) : new List<sObject>();
            mappingList_Temp.add(moduleRec);
            moduleNameMapping.put(moduleName,mappingList_Temp);
        }

        //Get other reference data to be used for determinig fields values
        String referenceDataName = 'QCC_Curfew_Port__c';
        List<sObject> otherRefereceDataObjects = QCC_UtilityHelper.getObjRecords (referenceDataName, '');
        system.debug('>>>createDisruptionCase - otherRefereceDataObjects: ' + otherRefereceDataObjects);

        Map<String, List<sObject>> otherRefDataNameMapping = new Map<String, List<sObject>>();
        for (sObject referenceRec : otherRefereceDataObjects) {
            String keyName = String.valueOf(referenceRec.get('Name'));
            List<sObject> referenceList_Temp = (otherRefDataNameMapping.containskey(keyName)) ? otherRefDataNameMapping.get(keyName) : new List<sObject>();
            referenceList_Temp.add(referenceRec);
            otherRefDataNameMapping.put(keyName,referenceList_Temp);
        }


        Map<String,List<Affected_Passenger__c>> sourceRecords_Map = new Map<String,List<Affected_Passenger__c>>();
        //Get the SOQL Module Name from the QCC SOQL Setting custom metadata type. Should there be any change in the query, then no need to update the code.
        String soqlModuleName = Label.QCC_FlightEventCaseCreation_ModuleName;
        QCC_SOQL_Setting__mdt customMetadataRecord = [
                SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c, Filter_Condition__c
                FROM QCC_SOQL_Setting__mdt
                WHERE Module_Name__c =: soqlModuleName LIMIT 1
            ];
        String affectedPassengerQuery = customMetadataRecord.Query_String__c + ' ' + customMetadataRecord.Filter_Condition__c;
        system.debug('>>>affectedPassengerQuery: ' + affectedPassengerQuery);
        //Query the affected passengers for which cases will be created
        for (Affected_Passenger__c passenger : database.query(affectedPassengerQuery)) {
            //Process only the passenger record that has a corresponding Module Name as maintained in the custom metadata type (Source to Target Mapping)
            if (moduleNameMapping.containsKey(passenger.QCC_TECH_Case_Module_Name__c)) {
                String moduleName = passenger.QCC_TECH_Case_Module_Name__c;
                //Build the sourceRecords_Map to group records of similar module name together
                List<Affected_Passenger__c> sourceRecords_Temp = (sourceRecords_Map.containsKey(moduleName)) ? sourceRecords_Map.get(moduleName) : new List<Affected_Passenger__c>();
                sourceRecords_Temp.add(passenger);
                sourceRecords_Map.put(moduleName,sourceRecords_Temp);

            }
        }

        system.debug('>>>createDisruptionCase - sourceRecords_Map: ' + sourceRecords_Map);

        List<sObject> disruptionCase_ForUpsert = new List<sObject>();
        //Loop through the source records to initiate creation of case
        for (String moduleName : sourceRecords_Map.keySet()) {
            List<sObject> targetMetaObjects = moduleNameMapping.get(moduleName);
            system.debug('>>>targetMetaObjects: ' + targetMetaObjects);
            List<sObject> records = (List<sObject>)sourceRecords_Map.get(moduleName);

            String recordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('QCC Case Disruption'));

            List<sObject> newRecords = QCC_UtilityHelper.transformSourceToTargetObjects (moduleName, records, targetMetaObjects, 'Case', recordTypeId, otherRefDataNameMapping);
            system.debug('>>>newRecords: ' + newRecords);
            disruptionCase_ForUpsert.addAll(newRecords);
        }

        system.debug('>>>disruptionCase_ForUpsert: ' + disruptionCase_ForUpsert);

        List<Database.UpsertResult> upsertResultList = new List<Database.UpsertResult>();
        Map<String, List<String>> resultMap = new Map<String, List<String>>();

        if (!disruptionCase_ForUpsert.isEmpty()) {
            List<Database.SaveResult> saveResultList = Database.insert(disruptionCase_ForUpsert,false);
            system.debug('New Case saveResultList: ' + saveResultList);

            QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC Create Disruption Case', 'AffectedPassengerTriggerHelper', 'createDisruptionCase');
        }

        //GRAPHITE-2221 Deserialize the case record to add in the list to update
        List<Case> disruptionCasesToUpdate = (List<Case>)JSON.deserialize(caseRecordsToUpdate, List<Case>.class);
        System.debug('disruptionCasesToUpdate: ' + disruptionCasesToUpdate);
        if (!disruptionCasesToUpdate.isEmpty()) {
            List<Database.SaveResult> saveResultList = Database.update(disruptionCasesToUpdate,false);
            system.debug('New Case saveResultList: ' + saveResultList);

            QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC Update Disruption Case', 'AffectedPassengerTriggerHelper', 'createDisruptionCase');
        }
    }
}