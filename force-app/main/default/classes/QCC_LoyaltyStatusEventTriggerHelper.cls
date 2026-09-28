/*********************************************************************************
Name         : QCC_LoyaltyStatusEventTriggerHelper
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 1 October 2019
Usages       : Holds all the functionality logic for the Loyalty Status platform events

Change History:
======================================================================================================================
Name						Jira			Description                                             
======================================================================================================================
Raymart Tolentino			G				Added method "creatLog" for logging all events that come through to salesforce to aid in monitoring and investigation
Lora Mae Dapulang			G-1020			Create new P1/CL/LTP contact in Salesforce via Event Stream. Added method processLoyaltyEventRecords.
Francis Bagtas				G-123			
*********************************************************************************/
public without sharing class QCC_LoyaltyStatusEventTriggerHelper implements TriggerHelper.Processor {
    public static Map<Id, QCC_Loyalty_Status__e> oldRecMap = new Map<Id, QCC_Loyalty_Status__e>();
    public static Map<String, String> contactFFTierMaps = new Map<String, String>();// Map<Contact FF number, Contact FF Tier>
    public static String functionName = 'QCC - Loyalty Status Event Payload';
    
    public void processTrigger(List<QCC_Loyalty_Status__e> newRecs, List<QCC_Loyalty_Status__e> oldRecs, TriggerHelper.Action triggerAction){
        Map<String, Trigger_Status__c> apexSwitch = Trigger_Status__c.getAll();
        
        if (triggerAction == TriggerHelper.Action.AFTERINSERT) {
            if (QCC_UtilityHelper.checkIfTriggerStatusIsActive('QCC_Loyalty_Status_Create_Log')) {
                createLog(newRecs);
            }

            // Process Loyalty Payload
            processLoyaltyEventRecords(newRecs);
        }
    }
    
    /**
	*  Description of the purpose of the class method.
	*  @description Builds map of the record fields before it gets updated
	*  @name buildOldRecMap
	*  @param oldRecs - List of records before any changes gets saved
	*  @return <parameter> - <Description about the return parameter>
	*  @throws exception-<exception description>
	*/
    private static void buildOldRecMap(List<QCC_Loyalty_Status__e> oldRecs) {      
        for (QCC_Loyalty_Status__e acc : oldRecs) {
            oldRecMap.put(acc.Id, acc);
        }
    }
    
    /**
	*  Description of the purpose of the class method.
	*  @description Logs the JSON payload published to the Loyalty Status platform event on the Log object.
	*  @name 		createLog
	*  @param 		List<QCC_Loyalty_Status__e> platformEventRecords - List of platform event records published
	*  @return <parameter> - <Description about the return parameter>
	*  @throws exception-<exception description>
	*/
    public static void createLog(List<QCC_Loyalty_Status__e> platformEventRecords){
        List<Log__c> logRecords = new List<Log__c>();
        for (QCC_Loyalty_Status__e platformEventRecord : platformEventRecords) {
            String payload = JSON.serialize(platformEventRecord);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(functionName, 'QCC_LoyaltyStatusEventTriggerHelper', 'createLog', payload, '', false, '', null, '');
            logRecords.add(logRecord);
        }
        
        QCC_LogUtilityHelper.createLogRecords(logRecords);
    }
    
    
    /**
    *  Description of the purpose of the class method. 
    *  @name memberTierDowngrade
    *  @param Set<String> - Collection of Contact FF no/member Id related to event type MEMBER_TIER_DOWNGRADE
    *  @return <parameter> - <Description about the return parameter>
    *  @throws exception-<exception description>
    */
    public static void downgradeMemberTier(Map<String,QCC_Loyalty_Status__e> contactLoyaltyEventMap){
                
        //Individual Contact Record Type ID generated from the Custom Settings
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   

        //Query Contact record based on the memberId from the Loyalty Status record. Note that Contact record type should be Individual Contact
        List<Contact> contactForUpdateList = new List<Contact>();  
        Date downgradeDate  = System.today().addDays(Integer.valueOf(Label.QCC_MemberTierDowngrade_ScheduledInDays)); // Today + 3 days from custom Label
        for(Contact con : [SELECT Id,QCC_TECH_Member_Tier_Downgrade_Date__c,Frequent_flyer_tier__c,Frequent_Flyer_Number__c FROM Contact WHERE Frequent_Flyer_Number__c IN: contactLoyaltyEventMap.keySet() AND RecordTypeId =: individualContactRecordTypeId]){            
            con.QCC_TECH_Member_Tier_Downgrade_Date__c = downgradeDate; // Set Date to determine when to allow Loyalty Sync Tier when viewing Contact Detail Page.
            if(contactFFTierMaps.containsKey(con.Frequent_Flyer_Number__c)){
            	con.Frequent_flyer_tier__c = contactFFTierMaps.get(con.Frequent_Flyer_Number__c); // Set Contact Frequent Flyer Tier to Previous Value. Batch Job will update the Tier after 3 days.
            }
            contactForUpdateList.add(con);
        }
        System.debug('>>>contactForUpdateList: '+contactForUpdateList);
        //Update Contact
        Database.SaveResult[] contactSaveResultList = Database.update(contactForUpdateList, false);
        QCC_LogUtilityHelper.DatabaseResultsWrapper contactDatabaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(contactSaveResultList, 'QCC_LoyaltyStatusEventTriggerHelper - downgradeMemberTier', 'QCC_LoyaltyStatusEventTriggerHelper', '');
        
        // Schedule Batch Job to Update Contact Tier
        if(contactLoyaltyEventMap.size() > 0){
            System.scheduleBatch(new QCC_MemberTierDowngradeBatch(contactLoyaltyEventMap), 'QCC Member Tier Downgrade ' + datetime.now() , Integer.valueOf(Label.QCC_MemberTierDowngrade_ScheduledInMinutes));
        }
        
    }
    
    /**
    *  Description of the purpose of the class method. 
    *  @description Loop through the Loyaty Event Record and check the event type if switch is on/off on the Custom Settings. Then filter it by Tier.
    *  @name 		processLoyaltyEventRecords
    *  @param 		Loyalty Status Event Record - List of Platform Event Records records
    *  @return <parameter> - <Description about the return parameter>
    *  @throws exception-<exception description>
    */
    public void processLoyaltyEventRecords(List<QCC_Loyalty_Status__e> loyaltyEventRecord){
        List<Log__c> logRecords = new List<Log__c>();
        //Get All Switch
        Map<String, QCC_Platform_Event_Switch__c> switchSettings = QCC_UtilityHelper.getPlatformEventSwitch();
        //Group Loyalty Status Record per Event
        Map<String,List<QCC_Loyalty_Status__e>> loyaltyStatusPerEventMap = QCC_UtilityHelper.groupLoyaltyEventType(loyaltyEventRecord);
		//Map of <FF Number, List of loyalty status events related to the frequent flyer>
		Map<String,List<QCC_Loyalty_Status__e>> ffNumber_LoyaltyEvents_Map = new Map<String,List<QCC_Loyalty_Status__e>>();
		//List of loyalty events where the switch is turned on and the tier criteria is met
        List<QCC_Loyalty_Status__e> filteredLoyatyEventData = new List<QCC_Loyalty_Status__e>();
        // Collection of Contact for MEMBER_TIER_DOWNGRADE
        Map<String,QCC_Loyalty_Status__e> contactForDowngradeMap = new Map<String,QCC_Loyalty_Status__e>(); // MAP<FF number, Loyaty Event>
		
        //Loop Loyalty Record per Event to Process
        for(String loyaltyEventType : loyaltyStatusPerEventMap.keySet()){
            //Checking the switch of each Event type On/Off
            Boolean switchIsActive = false;
            if (switchSettings.containsKey(loyaltyEventType)) {
                //If switch setting exists for the event type, then continue checking
                if(switchSettings.get(loyaltyEventType) != NULL && switchSettings.get(loyaltyEventType).Active__c){
                    switchIsActive = true;
                }
                
            } else {
                //Else if switch does not exist, then log an error
                for (QCC_Loyalty_Status__e platformEventRecord : loyaltyStatusPerEventMap.get(loyaltyEventType)) {
                    String payload = JSON.serialize(platformEventRecord);
                    Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(functionName, 'QCC_LoyaltyStatusEventTriggerHelper', 'processLoyaltyEventRecords', payload, '', true, '', null, 'No switch setup for this event type.');
                    logRecords.add(logRecord);
                }
            }
            
            System.debug('switchIsActive: ' + switchIsActive);
            
            //Filter Loyalty Event Record needed to Process
            //Switch is Active, Proceed on Checking Event valid Tier
            if(switchIsActive){
                //Retrive the filter for tier on the Custom Settings
            	Set<String> tierCodeSet = new Set<String>();
                if(switchSettings.get(loyaltyEventType).Tier__c != NULL) {
                    tierCodeSet.addAll(switchSettings.get(loyaltyEventType).Tier__c.split(';'));
                }
                
                //If Tier for checking is not Empty
                if(tierCodeSet.size() > 0){
                	for(QCC_Loyalty_Status__e loyalty : loyaltyStatusPerEventMap.get(loyaltyEventType)){
                    	if(loyalty.effectiveTier__c == NULL || tierCodeSet.contains(loyalty.effectiveTier__c)){
                        	//Add Loyalty Status Event Record if Effective tier is included on the Settings for the Event
                            filteredLoyatyEventData.add(loyalty);
                    	}
                	}    
                }else{ // If there's no Tier on the Switch meaning we can process all the Event Type
                    filteredLoyatyEventData.addAll(loyaltyStatusPerEventMap.get(loyaltyEventType));
                }   
            }
		}
		
		//Group the loyalty events based on FF Number
		for (QCC_Loyalty_Status__e activeEvent : filteredLoyatyEventData) {
            //Contacts' FF Number with leading zeros are currently saved on contact object with the leading zeros stripped out (by the code accConRshipUpdateonContacts.UpdateFrequentFlyerNumber)
            //Thus before querying contacts based on FF Number, need to stripped out leading zeros to get the macthing contacts.
            String ffNumber = String.valueOf(activeEvent.memberId__c);
            String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');
			List<QCC_Loyalty_Status__e> loyaltyEvents_Temp = (ffNumber_LoyaltyEvents_Map.containskey(ffNumWithOutLeadingZeros)) ? ffNumber_LoyaltyEvents_Map.get(ffNumWithOutLeadingZeros) : new List<QCC_Loyalty_Status__e>();
            loyaltyEvents_Temp.add(activeEvent);
			ffNumber_LoyaltyEvents_Map.put(ffNumWithOutLeadingZeros,loyaltyEvents_Temp);

            // Collection of MEMBER_TIER_DOWNGRADE per Member Id
            if(activeEvent.eventType__c =='MEMBER_TIER_DOWNGRADE'){
            	contactForDowngradeMap.put(ffNumWithOutLeadingZeros,activeEvent);
            }
            
		}
        system.debug('>>>ffNumber_LoyaltyEvents_Map: ' + ffNumber_LoyaltyEvents_Map);
        
        //Call method that will search for existing contacts and call case creation logic depending on the event type
        seachForContactRecord(ffNumber_LoyaltyEvents_Map);
        
        //GRAPHITE-1142 : Platinum One Tier downgrade lag
        //Check if Custom Setting for MemberTierDowngrade is True
        if (switchSettings.containsKey('QCC_MemberTierDowngradeBatch')) {
            if(switchSettings.get('QCC_MemberTierDowngradeBatch').Active__c) {
                downgradeMemberTier(contactForDowngradeMap);
            }
        }
    }
    
    /**
    *  Description of the purpose of the class method. 
    *  @description Checks if the contact record exists or not. If it exists, then updates will be done. If it does not exist, then new contact record will be created.
    *  @name 		seachForContactRecord
    *  @param 		Loyalty Status Event Record - List of Platform Event Records records
    *  @return <parameter> - <Description about the return parameter>
    *  @throws exception-<exception description>
    */
    public static void seachForContactRecord(Map<String,List<QCC_Loyalty_Status__e>> ffNumber_LoyaltyEvents_Map){
        system.debug('>>>seachForContactRecord - ffNumber_LoyaltyEvents_Map: ' + ffNumber_LoyaltyEvents_Map);
        //Individual Contact Record Type ID generated from the Custom Settings
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   

        //Query Contact record based on the memberId from the Loyalty Status record. Note that Contact record type should be Individual Contact
        Map<String, Contact> contactMaps = new Map<String, Contact>();  
        for(Contact con : [SELECT Name, Id, Frequent_Flyer_Number__c, RecordType.Name,Frequent_Flyer_Tier__c FROM Contact WHERE Frequent_Flyer_Number__c IN: ffNumber_LoyaltyEvents_Map.keySet() AND RecordTypeId =: individualContactRecordTypeId]){
            contactMaps.put(con.Frequent_Flyer_Number__c, con);
            contactFFTierMaps.put(con.Frequent_Flyer_Number__c,con.Frequent_Flyer_Tier__c);
        }
        
        //Get the Event Type names to be used as module name criteria when querying the source-to-target records 
        List<QCC_Platform_Event_Switch__c> loyaltyEventSwitches = QCC_Platform_Event_Switch__c.getall().values();
        String loyaltyEventTypeNames = '';
        for (QCC_Platform_Event_Switch__c eventSwitch : loyaltyEventSwitches) {
            if (eventSwitch.Platform_Event__c == 'QCC_Loyalty_Status__e' && !eventSwitch.Module_Name__c.startsWith('CREATE_CASE') && eventSwitch.Active__c) {
                loyaltyEventTypeNames = (loyaltyEventTypeNames != '') ? loyaltyEventTypeNames + ',\'' + eventSwitch.Module_Name__c + '\'' : '\'' + eventSwitch.Module_Name__c + '\'';
            }
        }
        system.debug('>>>loyaltyEventTypeNames: ' + loyaltyEventTypeNames);
        
        //Query the source-to-target mapping records
        String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
        String conditionClauseInsert = ' WHERE  Module_Name__c IN (' + loyaltyEventTypeNames + ')';
        List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords (metaName, conditionClauseInsert);
        
        //Maps for storing contacts which are for create and for update
        Map<String,List<QCC_Loyalty_Status__e>> ffNumber_ToCreateContactList_Map = new Map<String,List<QCC_Loyalty_Status__e>>();
        Map<String,List<QCC_Loyalty_Status__e>> ffNumber_ToUpdateContactList_Map = new Map<String,List<QCC_Loyalty_Status__e>>();
		//List of loyalty events with contacts already existing. This will be used within this thread for calling the class for creating cases.
        List<QCC_Loyalty_Status__e> loyaltyStatusToUpdateContactList = new  List<QCC_Loyalty_Status__e>();
                
        //Check whether the Contact record is existing in Salesforce or not
        for(String ffNumber : ffNumber_LoyaltyEvents_Map.keyset()){
            //If Contact is existing in Salesforce
			if(contactMaps.size() > 0 && contactMaps.containsKey(ffNumber)){
				//Update Contact GRAPHITE-123
				ffNumber_ToUpdateContactList_Map.put(ffNumber,new List<QCC_Loyalty_Status__e>(ffNumber_LoyaltyEvents_Map.get(ffNumber)));
			}else{//If Contact is not existing in Salesforce
				//Add the Loyalty record without existing SF contact in a collection
				ffNumber_ToCreateContactList_Map.put(ffNumber,new List<QCC_Loyalty_Status__e>(ffNumber_LoyaltyEvents_Map.get(ffNumber)));
			}
        }
        system.debug('>>>ffNumber_ToCreateContactList_Map: ' + ffNumber_ToCreateContactList_Map);
        system.debug('>>>ffNumber_ToUpdateContactList_Map: ' + ffNumber_ToUpdateContactList_Map);
        
        // If there are Exiting Contact, update the Record;
        if(!ffNumber_ToUpdateContactList_Map.isEmpty()){
            //Construct the Contact record to be updated
            List<Contact> contactToUpdateList = new List<Contact>();
            for (String ffNumber : ffNumber_ToUpdateContactList_Map.keySet()) {
                List<Contact> contactRecordsFromLoyaltyEvent = QCC_UtilityHelper.createContactFromLoyaltyEvents(ffNumber_ToUpdateContactList_Map.get(ffNumber), metaObjects);
                loyaltyStatusToUpdateContactList.addAll(ffNumber_ToUpdateContactList_Map.get(ffNumber));
                // Populate the Contact Id to update existing Record
                for(Contact contactRecord : contactRecordsFromLoyaltyEvent){
                    if(contactMaps.containsKey(contactRecord.Frequent_Flyer_number__c)){
                        contactRecord.id = contactMaps.get(contactRecord.Frequent_Flyer_number__c).id;
                        contactToUpdateList.add(contactRecord);
                    }
                }
            }
            
            System.debug('contactToUpdateList: ' + contactToUpdateList);
            //update contactToUpdateList;
            Database.SaveResult[] saveResultList = Database.update(contactToUpdateList, false);
            QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC Loyalty Status Event - Update Contact', 'QCC_LoyaltyStatusEventTriggerHelper', 'seachForContactRecord');
            
            //Call method for Case Creation.
            System.debug('loyaltyStatusToUpdateContactList: ' + loyaltyStatusToUpdateContactList);
            new QCC_LoyaltyStatusEventCaseCreation(loyaltyStatusToUpdateContactList);
        }
        
        //Call Queueable apex for Contact creation. Job will be queued per contact.
        if(!ffNumber_ToCreateContactList_Map.isEmpty()){
            //Loop through every FF Number that needs to be created.
            for (String ffNumber : ffNumber_ToCreateContactList_Map.keySet()) {
				QCC_LoyaltyStatusCreateContactQueueable queueableJob = new QCC_LoyaltyStatusCreateContactQueueable();
				queueableJob.ffNumber = ffNumber;
                queueableJob.loyaltyStatusList = ffNumber_ToCreateContactList_Map.get(ffNumber);  
                queueableJob.metaObjects = metaObjects;
				System.enqueueJob(queueableJob);
			}
        }
    }
}