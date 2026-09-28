/*********************************************************************************
Name         : QCC_PreDepartureEventTriggerHelper
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 1 October 2019
Usages       : Holds all the functionality logic for the Pre Departure platform events

Change History:
======================================================================================================================
Name            Jira      Description                                             
======================================================================================================================
Raymart Tolentino      G        Added method "creatLog" for logging all events that come through to salesforce to aid in monitoring and investigation
Francis Bagtas      G-1199      Added createQantasHostRecord a process to create/update Qantas host record
Tanya Kumari    CRM-10522       RBAC for System Admin 15/05/2026
*********************************************************************************/
public without sharing class QCC_PreDepartureEventTriggerHelper implements TriggerHelper.Processor {
    public static Map<Id, QCC_Pre_Departure_Event__e> oldRecMap = new Map<Id, QCC_Pre_Departure_Event__e>();
    public static String functionName = 'QCC - Pre Departure Event Payload';
    public static Map<String,QCC_Platform_Event_Switch__c> switchSettings = new Map<String,QCC_Platform_Event_Switch__c>(); // Map<Module Name, Platform Event Switch>
    
    public void processTrigger(List<QCC_Pre_Departure_Event__e> newRecs, List<QCC_Pre_Departure_Event__e> oldRecs, TriggerHelper.Action triggerAction){
        
        // Get Platform event switch
        switchSettings = QCC_UtilityHelper.getPlatformEventSwitch();
        
        if (triggerAction == TriggerHelper.Action.AFTERINSERT) {
            if (QCC_UtilityHelper.checkIfTriggerStatusIsActive('QCC_Pre_Departure_Event_Create_Log')) {
                createLog(newRecs);
            }

            String qantasHostEventType = Label.QCC_QantasHost_EventType;
            if(switchSettings.containsKey(qantasHostEventType) &&  switchSettings.get(qantasHostEventType).Active__c){ //Switch Checking
            	createQantasHostRecord(newRecs);
            }
            
            createCaseFromPredepartureEvent(newRecs);
        }
    }
    
    /**
    *  Description of the purpose of the class method. 
    *  @name buildOldRecMap
    *  @param oldRecs - List of records before any changes gets saved
    *  @return <parameter> - <Description about the return parameter>
    *  @throws exception-<exception description>
    */
    private static void buildOldRecMap(List<QCC_Pre_Departure_Event__e> oldRecs) {      
        for (QCC_Pre_Departure_Event__e acc : oldRecs) {
            oldRecMap.put(acc.Id, acc);
        }
    }
    
    public static void createLog(List<QCC_Pre_Departure_Event__e> platformEventRecords){
        List<Log__c> logRecords = new List<Log__c>();
        for (QCC_Pre_Departure_Event__e platformEventRecord : platformEventRecords) {
            String payload = JSON.serialize(platformEventRecord);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(functionName, 'QCC_PreDepartureEventTriggerHelper', 'createLog', payload, '', false, '', null, '');
            logRecords.add(logRecord);
        }
        
        QCC_LogUtilityHelper.createLogRecords(logRecords);
    }
    
    /**
    *  Description of the purpose of the class method. 
    *  For GRAPHITE-194, GRAPHITE-96, GRAPHITE-158, GRAPHITE-208, GRAPHITE-160, GRAPHITE-162, GRAPHITE-210, GRAPHITE-1785
    *  @name createCaseFromPredepartureEvent
    *  @param predepartureRecordList - List of Predeparture Event records
    *  @return <parameter> - <Description about the return parameter>
    *  @throws exception-<exception description>
    */
    public static void createCaseFromPredepartureEvent(List<QCC_Pre_Departure_Event__e> predepartureRecordList){
        //Individual Contact Record Type ID generated from the Custom Settings
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   
        Map<String, List<sObject>> otherRefDataMap = new Map<String, List<sObject>>();// otherRefData use for source to target
        List<Case> caseToCreateList = new List<Case>(); // List of Case to Create
        //Map of <FF Number, List of Pre departure events related to the frequent flyer>
		Map<String,List<QCC_Pre_Departure_Event__e>> ffNumber_preDepartureEvents_Map = new Map<String,List<QCC_Pre_Departure_Event__e>>();
    	for (QCC_Pre_Departure_Event__e predepEvent : predepartureRecordList) {
            if(predepEvent.qantasFFNo__c != null){ // For Predeparture with Frequent Flyer Number
                //Contacts' FF Number with leading zeros are currently saved on contact object with the leading zeros stripped out (by the code accConRshipUpdateonContacts.UpdateFrequentFlyerNumber)
                //Thus before querying contacts based on FF Number, need to stripped out leading zeros to get the macthing contacts.
                String ffNumber = String.valueOf(predepEvent.qantasFFNo__c);
                String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');
                List<QCC_Pre_Departure_Event__e> preDepatureEvents_Temp = (ffNumber_preDepartureEvents_Map.containskey(ffNumWithOutLeadingZeros)) ? ffNumber_preDepartureEvents_Map.get(ffNumWithOutLeadingZeros) : new List<QCC_Pre_Departure_Event__e>();
                preDepatureEvents_Temp.add(predepEvent);
                ffNumber_preDepartureEvents_Map.put(ffNumWithOutLeadingZeros,preDepatureEvents_Temp);
            }
		}

        //Query Contact record based on the qantasFFNo from the Pre-departure event record. Note that Contact record type should be Individual Contact
        Map<String, Contact> contactMaps = new Map<String, Contact>();
        List<Id> contactIdList = new List<Id>();
        for(Contact con : [SELECT Name, Id, Frequent_Flyer_Number__c, RecordType.Name FROM Contact WHERE Frequent_Flyer_Number__c IN: ffNumber_preDepartureEvents_Map.keySet() AND RecordTypeId =: individualContactRecordTypeId]){
            contactMaps.put(con.Frequent_Flyer_Number__c, con);    
            contactIdList.add(con.Id);
            // Build Source to Target Other Reference data
            List<sObject> contactRec_temp = (otherRefDataMap.containsKey(con.Frequent_Flyer_Number__c) ? otherRefDataMap.get(con.Frequent_Flyer_Number__c) : new List<sObject>());
            contactRec_temp.add(con);
            otherRefDataMap.put(con.Frequent_Flyer_Number__c,contactRec_temp);
        }
        
        // Get Contact Wathclist Record
        Map<Id,List<QCC_Contact_Watchlist__c>> contactWatchlistMap = new Map<Id,List<QCC_Contact_Watchlist__c>>();
        for(QCC_Contact_Watchlist__c watchlistRecord : [SELECT Id,QCC_Contact__c FROM QCC_Contact_Watchlist__c WHERE QCC_Contact__c IN: contactIdList AND QCC_Watchlist_End_Date__c >= TODAY AND QCC_Watchlist_Start_Date__c <= TODAY]){
            List<QCC_Contact_Watchlist__c> watchlistList_Temp = (contactWatchlistMap.containskey(watchlistRecord.QCC_Contact__c)) ? contactWatchlistMap.get(watchlistRecord.QCC_Contact__c) : new List<QCC_Contact_Watchlist__c>();
            watchlistList_Temp.add(watchlistRecord);
            contactWatchlistMap.put(watchlistRecord.QCC_Contact__c,watchlistList_Temp);
        }
        
        //Get the Event Type names to be used as module name criteria when querying the source-to-target records 
        String predepartureEventTypeNames = '';
        for(QCC_Platform_Event_Switch__c eventSwitch : switchSettings.values()){
            if (eventSwitch.Platform_Event__c == 'QCC_Pre_Departure_Event__e' && eventSwitch.Active__c) {
                predepartureEventTypeNames = (predepartureEventTypeNames != '') ? predepartureEventTypeNames + ',\'' + eventSwitch.Module_Name__c + '\'' : '\'' + eventSwitch.Module_Name__c + '\'';
            }
        }
        
        system.debug('>>>predepartureEventTypeNames: ' + predepartureEventTypeNames);
		String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
        String conditionClauseInsert = ' WHERE  Module_Name__c IN (' + predepartureEventTypeNames + ')';
        Map<String,List<sObject>> metaObjectsByModuleName = QCC_UtilityHelper.getObjMap(metaName, 'Module_Name__c', conditionClauseInsert);
        system.debug('>>>>metaObjectsByModuleName: ' + metaObjectsByModuleName); 
        
        //Retrieve the filter for tier on Custom Settings Grouped by Module name as a key
        Map<String,Set<String>> tiercodePerModulename = new Map<String,Set<String>>(); // Holds the value of Tier per module name on the Switch
        for(String modulename : metaObjectsByModuleName.keySet()){
            if(switchSettings.get(modulename).Tier__c != NULL) {
                tiercodePerModulename.put(modulename,new Set<String>(switchSettings.get(modulename).Tier__c.split(';')));
            }
        }
        
        // Exclude Predeparture Event Record without Salesforce Contact
        List<QCC_Pre_Departure_Event__e> predepartureWithContactRecordList = new List<QCC_Pre_Departure_Event__e>();
        for(String predepFFno : ffNumber_preDepartureEvents_Map.keySet()){
            if(contactMaps.containsKey(predepFFno)){
				predepartureWithContactRecordList.addAll(ffNumber_preDepartureEvents_Map.get(predepFFno));
            }
        }
        
        // Loop Pre-departure Record with Contact
        List<Contact> contactToUpdateList = new List<Contact>(); // List of Contact to Update
        List<Complimentary_Upgrade__c> complimentaryRecordToCreateList = new List<Complimentary_Upgrade__c>(); // List of Complimentary Record to Create
        for(QCC_Pre_Departure_Event__e predepartureRec : predepartureWithContactRecordList){
            String ffNumber = String.valueOf(predepartureRec.qantasFFNo__c);
            String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');

            String predepartureEventType = predepartureRec.eventType__c;
            String modulename = ''; // Determine the value of Module name base on EventType
            if(predepartureEventType == 'PAX_SEG_UPGRADE' && switchSettings.containsKey(predepartureEventType) &&  switchSettings.get(predepartureEventType).Active__c){ //Switch Checking
                modulename = predepartureEventType;   
            }else if(predepartureEventType == 'PAX_SEG_UPGRADE_EXCEPTION'){
                String modulename_temp = predepartureEventType +' '+ predepartureRec.reason__c;
                if(switchSettings.containsKey(modulename_temp) &&  switchSettings.get(modulename_temp).Active__c){ //Switch Checking
                    modulename = modulename_temp;
                }
            }
            
            if(modulename != ''){
                //Tier Checking
                if(tiercodePerModulename.containsKey(modulename) && ((tiercodePerModulename.get(modulename).contains(predepartureRec.qantasTierClubCode__c)) || tiercodePerModulename.get(modulename).size()==0 ) ){ //Tier Checking
                    boolean isCreateCase = true;

                    // Additional checking for Review Complimentary Upgrade - Watchlist, Contact should be on Watchlist record
                    if (modulename == 'PAX_SEG_UPGRADE' && contactMaps.containsKey(ffNumWithOutLeadingZeros)) {
                    	Contact contactRecordForPreFlightWatchlist = contactMaps.get(ffNumWithOutLeadingZeros);
                        if(!contactWatchlistMap.containsKey(contactRecordForPreFlightWatchlist.Id)){
                        	isCreateCase = false;
                        }
                    }

                    if(isCreateCase){
                    // Construct Case record using Source to Target
                    List<sObject> metaObjects = metaObjectsByModuleName.get(modulename);
                    List<Case> caseRecord = QCC_UtilityHelper.transformSourceToTargetObjects(modulename, new List<QCC_Pre_Departure_Event__e>{predepartureRec}, metaObjects, 'Case', null, otherRefDataMap);
                    caseToCreateList.addAll(caseRecord);
                }
            }
        }

            //Check if switch for Pre-Flight Watchlist is active
            String preFlightModuleName = Label.QCC_PreFlightWatchlist_ModuleName;
            if(switchSettings.containsKey(preFlightModuleName) &&  switchSettings.get(preFlightModuleName).Active__c){
                //GRAPHITE-2184 Prevent creation of case record if contact is not existing. Watchlist will not be available if the contact is not yet created
                if (contactMaps.containsKey(ffNumWithOutLeadingZeros)) {
                    Contact contactRecordForPreFlightWatchlist = contactMaps.get(ffNumWithOutLeadingZeros);
                    System.debug('contactRecordForPreFlightWatchlist: ' + contactRecordForPreFlightWatchlist);

                    //Generate date that will be compared to departureLocalDate__c
                    //Label.QCC_PreFlightWatchlistAdditionalDays current valus is "2"
                    Date preFlightWatchlistDate = System.today().addDays(Integer.valueOf(Label.QCC_PreFlightWatchlistAdditionalDays));
                    System.debug('predepartureRec.departureLocalDate__c: ' + predepartureRec.departureLocalDate__c);
                    System.debug('preFlightWatchlistDate: ' + preFlightWatchlistDate);

                    //Compare the departureLocalDate__c value to today's date + 2
                    //GRAPHITE-2184 Do not create case if contact dont have watchlist record
                    if(predepartureRec.departureLocalDate__c == preFlightWatchlistDate && contactWatchlistMap.containsKey(contactRecordForPreFlightWatchlist.Id)){
                        if(tiercodePerModulename.containsKey(preFlightModuleName) && ((tiercodePerModulename.get(preFlightModuleName).contains(predepartureRec.qantasTierClubCode__c)) || tiercodePerModulename.get(preFlightModuleName).size()==0 ) ){ //Tier Checking
                            // Construct Case record using Source to Target
                            List<sObject> metaObjects = metaObjectsByModuleName.get(preFlightModuleName);
                            List<Case> caseRecord = QCC_UtilityHelper.transformSourceToTargetObjects(preFlightModuleName, new List<QCC_Pre_Departure_Event__e>{predepartureRec}, metaObjects, 'Case', null, otherRefDataMap);
                            caseToCreateList.addAll(caseRecord);
                        }
                    }
                }
            }

            //Update Last Flight Date
            Contact con = contactMaps.get(ffNumWithOutLeadingZeros);
            con.QCC_Last_Flight_Date__c = predepartureRec.departureLocalDate__c;    
            contactToUpdateList.add(con);
            
            // Create Complimentary Record
            String complimentaryModulename = 'COMPLIMENTARY_'+predepartureEventType;
            if (switchSettings.containsKey(complimentaryModulename) && switchSettings.get(complimentaryModulename).Active__c) { // Switch Checking
                List<sObject> metaObjects = metaObjectsByModuleName.get(complimentaryModulename);
                List<Complimentary_Upgrade__c> complimentaryRecord = QCC_UtilityHelper.transformSourceToTargetObjects(complimentaryModulename, new List<QCC_Pre_Departure_Event__e>{predepartureRec}, metaObjects, 'Complimentary_Upgrade__c', null, otherRefDataMap);
                complimentaryRecordToCreateList.addAll(complimentaryRecord);
            }
            
        } // EOF For Loop Pre-departure Record with Contact
        
        // Insert New Case Record
        if(caseToCreateList.size() > 0){
            //insert caseToCreateList
            Database.SaveResult[] saveResultList = Database.insert(caseToCreateList, false);
            //Create the log record for those save result that fails
            QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC Predeparture Event - Create Case', 'QCC_PreDepartureEventTriggerHelper', '');
        }
        
        if(complimentaryRecordToCreateList.size() > 0){
			//insert complimentaryRecordToCreateList
            Database.SaveResult[] complimentarySaveResultList = Database.insert(complimentaryRecordToCreateList, false);
            //Create the log record for those save result that fails
            QCC_LogUtilityHelper.DatabaseResultsWrapper complimentaryDatabaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(complimentarySaveResultList, 'QCC Predeparture Event - Create Complimentary Upgrade', 'QCC_PreDepartureEventTriggerHelper', '');            
        }
        
        //Update Contact
        Database.SaveResult[] contactSaveResultList = Database.update(contactToUpdateList, false);
        QCC_LogUtilityHelper.DatabaseResultsWrapper contactDatabaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(contactSaveResultList, 'QCC Predeparture Event - Update Contact', 'QCC_PreDepartureEventTriggerHelper', '');    
    }
    
    // GRAPHITE - 1159 : Qantas Host Record Creation/Update
    public static void createQantasHostRecord(List<QCC_Pre_Departure_Event__e> newRecs){
        
        List<QCC_First_Host__c> qantasHostToUpsertLists = new List<QCC_First_Host__c>();
        Set<Id> qantasHostIds = new Set<Id>();

        Set<String> pnrSet = new Set<String>();
        Set<String> flightNoSet = new Set<String>();
        Set<String> departurePortSet = new Set<String>();
        Set<Date> departureLocalDateSet = new Set<Date>();
        Set<String> frequentFlyerSet = new Set<String>();
        Set<String> aiportCodeSet = new Set<String>();
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();

        //List all details which is part of the criteria whether a Qantas Host record will be inserted or updated
        for (QCC_Pre_Departure_Event__e preDepRecords : newRecs){
            //GRAPHITE-2179 Prevent creation of qantas host records if eventType__c is not PAX_SEG_PRE_DEP
            if (preDepRecords.eventType__c == Label.QCC_QantasHost_EventType) {
                pnrSet.add(preDepRecords.reloc__c);
                flightNoSet.add(preDepRecords.OperatingFlightNo__c);
                departurePortSet.add(preDepRecords.departureAirportCode__c);
                departureLocalDateSet.add(preDepRecords.departureLocalDate__c);
                frequentFlyerSet.add(preDepRecords.qantasFFNo__c);
                aiportCodeSet.add(preDepRecords.departureAirportCode__c);
                aiportCodeSet.add(preDepRecords.arrivalAirportCode__c);
                firstNameSet.add(preDepRecords.firstName__c);
                lastNameSet.add(preDepRecords.lastName__c);
            }
        }

        //Get Qantas Host Record for checking later if record exist or not.
        Map<String,QCC_First_Host__c> qantasHostWithFFnoMap = new Map<String,QCC_First_Host__c>();
        Map<String,QCC_First_Host__c> qantasHostWithOutFFnoMap = new Map<String,QCC_First_Host__c>();
        List<QCC_First_Host__c> qantasHostList = [
            SELECT Id, QCC_PNR__c, QCC_Flight_No__c, QCC_Departure_Airport__c, QCC_Departure_Local_Date__c,
            QCC_Flight_Departure_Time__c,QCC_Frequent_Flyer_Number__c,QCC_First_Host_First_Name__c,QCC_Contact_Lastname__c
            FROM QCC_First_Host__c
            WHERE QCC_PNR__c IN: pnrSet AND QCC_Flight_No__c IN: flightNoSet AND QCC_Departure_Airport__c IN: departurePortSet
            AND QCC_Departure_Local_Date__c IN: departureLocalDateSet
            AND (QCC_Frequent_Flyer_Number__c IN: frequentFlyerSet OR (QCC_Contact_Lastname__c IN: lastNameSet AND QCC_First_Host_First_Name__c IN: firstNameSet))
        ];
        System.debug('>>qantasHostList: ' + qantasHostList);

        for(QCC_First_Host__c qantasHost : qantasHostList){
            if(qantasHost.QCC_Frequent_Flyer_Number__c != '' && qantasHost.QCC_Frequent_Flyer_Number__c != NULL){
                //List all Qantas Host records with Frequent Flyer Number
                //GRAPHITE-1872 Remove leading zero before generating the key to compare PreDeparture event to Qantas Host record
                String ffNumberWithoutLeadingZero = qantasHost.QCC_Frequent_Flyer_Number__c.replaceFirst('^0+','');
                String qantasHostKeyWithFFno  = qantasHost.QCC_PNR__c + ffNumberWithoutLeadingZero + qantasHost.QCC_Flight_No__c + qantasHost.QCC_Departure_Airport__c + qantasHost.QCC_Departure_Local_Date__c;
                qantasHostWithFFnoMap.put(qantasHostKeyWithFFno,qantasHost);
            }else{
                //List all Qantas Host records without Frequent Flyer Number
                String qantasHostKeyWOFFno = qantasHost.QCC_First_Host_First_Name__c+qantasHost.QCC_Contact_Lastname__c+qantasHost.QCC_PNR__c + qantasHost.QCC_Flight_No__c + qantasHost.QCC_Departure_Airport__c + qantasHost.QCC_Departure_Local_Date__c;
                qantasHostWithOutFFnoMap.put(qantasHostKeyWOFFno,qantasHost);
            }
        }
        system.debug('qantasHostWithFFnoMap : ' + qantasHostWithFFnoMap);
        system.debug('qantasHostWithOutFFnoMap : ' + qantasHostWithOutFFnoMap);
        
        //Generate map for otherRefDataMap needed for Source to Target
        Map<String,List<sObject>> otherRefDataMap = new Map<String,List<sObject>>();

        //Include Airport data to otherRefDataMap
        for(Airport_Code__c airport : [SELECT Id,Name FROM Airport_Code__c WHERE Name IN: aiportCodeSet]){
            otherRefDataMap.put(airport.Name,new List<Airport_Code__c>{airport});
        }

        //Included System Admin to otherRefDataMap
        //Included four new System Admin profiles which has been created as part of RBAC System Admin
        for(User usr : [SELECT id,Name from User where (Profile.Name='System Administrator') OR (Profile.Name='Qantas System Administrator') OR (Profile.Name='Qantas System Admin - SND') OR (Profile.Name='Qantas System Admin - QCC') OR (Profile.Name='Qantas System Admin - Freight') with SYSTEM_MODE]){ //CRM 12908 Added for Code Security Remediation
            otherRefDataMap.put(usr.Name,new List<User>{usr});
        }
        
        System.debug('>>otherRefDataMap: ' + otherRefDataMap);

        try{
            //Retrive the filter for Carrier code from a custom label
            Set<String> operatingCarrierCodeSet = new Set<String>();
            operatingCarrierCodeSet.addAll(Label.QCC_Operating_Carrier_for_Qantas_Host.split(';'));
            System.debug('>>operatingCarrierCodeSet: ' + operatingCarrierCodeSet);
            
            //Retrieve the filter for Domestic International Flag from a custom Label
            Set<String> domesticInternationalSet = new Set<String>();
            domesticInternationalSet.addAll(Label.QCC_Domestic_International_Filter_for_Qantas_Host.split(';'));
            System.debug('>>domesticInternationalSet: ' + domesticInternationalSet);

            List<QCC_Pre_Departure_Event__e> forInsertPredepartureEventList = new List<QCC_Pre_Departure_Event__e>();
            List<QCC_Pre_Departure_Event__e> forUpdatePredepartureEventList = new List<QCC_Pre_Departure_Event__e>();
            List<QCC_First_Host__c> qantasHostUpsertList = new List<QCC_First_Host__c>();
            for (QCC_Pre_Departure_Event__e preDepRecords : newRecs){ // Loop Pre-Departure Record
                //GRAPHITE-2179 Prevent creation of qantas host records if eventType__c is not PAX_SEG_PRE_DEP
                if (preDepRecords.eventType__c == Label.QCC_QantasHost_EventType) {
                    //Not all Pre-Departure event record will create Qantas host. Only those Carrier Code = "QF" , Dom/International = "I" , Flight No < "0400"
                    if (operatingCarrierCodeSet.contains(preDepRecords.operatingCarrierCode__c) && domesticInternationalSet.contains(preDepRecords.domesticInternationalInd__c) && Integer.valueOf(preDepRecords.OperatingFlightNo__c) < 0400){
                        String preDepartureKey = '';
                        Map<String,QCC_First_Host__c> existingQantasHostMap = new Map<String,QCC_First_Host__c>();
                        //Check whether Predeparture Event for Qantas Host have Frequent Flyer, If None use the Passenger FirstName LastName as part of the Key.
                        if (preDepRecords.qantasFFNo__c != null) {
                            //GRAPHITE-1872 Remove leading zero before generating the key to compare PreDeparture event to Qantas Host record
                            String ffNumberWithoutLeadingZero = preDepRecords.qantasFFNo__c.replaceFirst('^0+','');
                            preDepartureKey = preDepRecords.Reloc__c + ffNumberWithoutLeadingZero + preDepRecords.OperatingFlightNo__c + preDepRecords.departureAirportCode__c + preDepRecords.departureLocalDate__c;
                            existingQantasHostMap = qantasHostWithFFnoMap;
                        } else {
                            preDepartureKey = preDepRecords.firstName__c + preDepRecords.lastName__c + preDepRecords.Reloc__c + preDepRecords.OperatingFlightNo__c + preDepRecords.departureAirportCode__c + preDepRecords.departureLocalDate__c;
                            existingQantasHostMap = qantasHostWithOutFFnoMap;
                        }

                        System.debug('>>preDepartureKey: ' + preDepartureKey);
                        System.debug('>>existingQantasHostMap: ' + existingQantasHostMap);

                        //Create a new Qantas Host record if there is no existing record based on the key otherwise update the existing record.
                        if (existingQantasHostMap.containsKey(preDepartureKey)) {
                            QCC_First_Host__c qantasHost = existingQantasHostMap.get(preDepartureKey);
                            //The preDepRecords is Ready Only and will not be able to write some value so we need to pass it to a new cloned Event.
                            QCC_Pre_Departure_Event__e newPredeparture = preDepRecords.clone(false,true,true,false);
                            //Assign to which Qantas host record this Pre departure Event Record is linked
                            newPredeparture.put('Reference_Id__c',qantasHost.id);
                            //Collect all the records to be updated
                            forUpdatePredepartureEventList.add(newPredeparture);
                        } else {
                            //Collect all the records to be inserted
                            forInsertPredepartureEventList.add(preDepRecords);
                        }
                    }
                }
            }
            
            System.debug('>>forUpdatePredepartureEventList: ' + forUpdatePredepartureEventList);
            System.debug('>>forInsertPredepartureEventList: ' + forInsertPredepartureEventList);

            // Collection of Field from Metada for Creating NEW Qantas Host record
            String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
            String conditionClauseInsert = ' WHERE  Module_Name__c = \''+Label.QCC_PreDepartureQantasHostInsert_Modulename+'\'';
            List<sObject> metaObjectsInsert = QCC_UtilityHelper.getObjRecords (metaName, conditionClauseInsert);
            
            // Collection of Field from Metada for Creating UPDATING Qantas Host record
            String conditionClauseUpdate = ' WHERE  Module_Name__c = \''+Label.QCC_PreDepartureQantasHostUpdate_Modulename+'\'';
            List<sObject> metaObjectsUpdate = QCC_UtilityHelper.getObjRecords (metaName, conditionClauseUpdate);
            
            if(forInsertPredepartureEventList.size() > 0){
                List<QCC_First_Host__c> qantasHostForInsert = QCC_UtilityHelper.transformSourceToTargetObjects (Label.QCC_PreDepartureQantasHostInsert_Modulename, forInsertPredepartureEventList, metaObjectsInsert, 'QCC_First_Host__c', null, otherRefDataMap);
                qantasHostUpsertList.addall(qantasHostForInsert);
            }
            
            if(forUpdatePredepartureEventList.size() > 0){
                List<QCC_First_Host__c> qantasHostForUpdate = QCC_UtilityHelper.transformSourceToTargetObjects (Label.QCC_PreDepartureQantasHostInsert_Modulename, forUpdatePredepartureEventList, metaObjectsUpdate, 'QCC_First_Host__c', null, otherRefDataMap);
                qantasHostUpsertList.addall(qantasHostForUpdate);
            }
            
            System.debug('>>qantasHostUpsertList: ' + qantasHostUpsertList);

            Map<String, List<String>> resultMap = new Map<String, List<String>>();
            Database.UpsertResult[] saveResultList = Database.upsert(qantasHostUpsertList, QCC_First_Host__c.Id, false);
            for(Database.UpsertResult saveResult : saveResultList) {
                if(saveResult.isSuccess()) {
                    qantasHostIds.add(saveResult.id);
                }else{
                    List<String> resultMessageList = new List<String>();
                    for(Database.Error err : saveResult.getErrors()) {
                        resultMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    resultMap.put(saveResult.getId(), resultMessageList);
                }
            }
            //Create the log record for those save result that fails
            List<Log__c> logRecords = new List<Log__c>();
            for(String recordId: resultMap.keyset()){
                for(String resultMessage : resultMap.get(recordId)) {
                    logRecords.add(QCC_LogUtilityHelper.generateLogRecord('QCC Create Qantas Host Record', 'QCC_PreDepartureEventTRiggerHelper', 'createQantasHostRecord', '', '', false, recordId, null, resultMessage));
                }
            }
            if (!logRecords.isEmpty()) {
                QCC_LogUtilityHelper.createLogRecords(logRecords);
            }
            
            system.debug('>>qantasHostIds : ' + qantasHostIds);
            // Lora Mae Dapulang | GRAPHITE-1058 : Populate Qantas Host Contact field, or create Case for null Contact
            if(qantasHostIds.size() > 0){
                database.executeBatch(new QCC_QantasHostLookUpContactBatch(qantasHostIds), 1);    
            }
            
        } catch (Exception ex) {
            //TO-DO: Error Handling
            system.debug('ERROR : ' + ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(functionName, 'QCC_PreDepartureEventTriggerHelper', 'createQantasHostRecord', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }
    
}