/*********************************************************************************
Name         : QCC_LoyaltyStatusEventCaseCreation
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 03 December 2019
Usages       : This class is used to Create case from Loyalty Event
*********************************************************************************/
public class QCC_LoyaltyStatusEventCaseCreation{
   
    public QCC_LoyaltyStatusEventCaseCreation(List<QCC_Loyalty_Status__e> listLoyaltyStatus){
        try{
            Map<String, QCC_Platform_Event_Switch__c> switchSettings = QCC_UtilityHelper.getPlatformEventSwitch();
            //Assignment Rule
            String ruleName = System.Label.QCC_AssignmentRuleName; 
            AssignmentRule rule = [SELECT Id FROM AssignmentRule WHERE Name = :ruleName LIMIT 1];
            Database.DMLOptions dmlOption = new Database.DMLOptions();
            dmlOption.assignmentRuleHeader.assignmentRuleId= rule.id;
            
            String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
            List<sObject> newCaseRecordList = new List<sObject>(); // Collection of Case to be created
            //GET THE CONTACT INFO
            Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   
            Map<String,Contact> contactInfo = new Map<String,Contact>(); // Map<FF number, Contact Record>
            for(QCC_Loyalty_Status__e loyaltyEvent :listLoyaltyStatus){
                //Contacts' FF Number with leading zeros are currently saved on contact object with the leading zeros stripped out (by the code accConRshipUpdateonContacts.UpdateFrequentFlyerNumber)
                //Thus before querying contacts based on FF Number, need to stripped out leading zeros to get the macthing contacts.
                String ffNumber = String.valueOf(loyaltyEvent.memberId__c);
                String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');
                contactInfo.put(ffNumWithOutLeadingZeros,NULL);
            }
            for(Contact contactRecord : [SELECT Id,frequent_flyer_number__c FROM Contact where frequent_flyer_number__c IN: contactInfo.keySet() AND RecordTypeId =: individualContactRecordTypeId]){
                contactInfo.put(contactRecord.frequent_flyer_number__c,contactRecord);
            }
            
            //Group Loyalty Status Record per Event
        	Map<String,List<QCC_Loyalty_Status__e>> loyaltyStatusPerEventMap = QCC_UtilityHelper.groupLoyaltyEventType(listLoyaltyStatus);
            //Get the source-to-target mapping per event type
            String loyaltyEventTypeNames = '';
            //1. Collect the event type names for case creation
            for (String eventType : loyaltyStatusPerEventMap.keyset()) {
                String caseEventTypeName = 'CREATE_CASE_'+eventType;
                loyaltyEventTypeNames = (loyaltyEventTypeNames != '') ? loyaltyEventTypeNames + ',\'' + caseEventTypeName + '\'' : '\'' + caseEventTypeName + '\'';
            }
            //2. Build the where condition clause
            String conditionClauseInsert = ' WHERE  Module_Name__c IN (' + loyaltyEventTypeNames + ')';
            system.debug('>>>QCC_LoyaltyStatusEventCaseCreation - conditionClauseInsert: ' + conditionClauseInsert);
            //3. Call the dynamic soql to retrieve the source-to-target mapping records grouped by module name
            Map<String,List<sObject>> metaObjectsByModuleName = QCC_UtilityHelper.getObjMap(metaName, 'Module_Name__c', conditionClauseInsert);
            system.debug('>>>>QCC_LoyaltyStatusEventCaseCreation - metaObjectsByModuleName: ' + metaObjectsByModuleName);
            
            Set<String> previousTierSet = new Set<String>();
            previousTierSet.addAll(Label.QCC_Welcome_to_Platinum_Previous_Tier.split(';'));
                     
            for(String loyaltyEventType : loyaltyStatusPerEventMap.keySet()){
                // For MEMBER_TIER_UPGRADE Event Type additional checking needed
                List<QCC_Loyalty_Status__e> loyaltyEventList = new List<QCC_Loyalty_Status__e>();
                if(loyaltyEventType == 'MEMBER_TIER_UPGRADE'){
                    for(QCC_Loyalty_Status__e loyalty : loyaltyStatusPerEventMap.get(loyaltyEventType)){
                        if(!previousTierSet.contains(loyalty.previousTier__c) && (loyalty.effectiveTier__c == 'FFPO' || loyalty.effectiveTier__c == 'CLPO')){ // Check if Previous tier is NOT on the list
                            loyaltyEventList.add(loyalty); // Add it to list of Loyalty Event for processing
                        }
                    }
                }else{ // If not MEMBER_TIER_UPGRADE process all event
                    loyaltyEventList.addall(loyaltyStatusPerEventMap.get(loyaltyEventType));
                }
                
                System.debug('loyaltyEventList: ' + loyaltyEventList);

                String moduleName = 'CREATE_CASE_'+loyaltyEventType;
                //GRAPHITE-1787 Check whether the switch for case creation is active
                if (switchSettings.containsKey(moduleName)) {
                    if(switchSettings.get(moduleName).Active__c){
                        //Collection of Field from Metada for Creating NEW Case record
                        List<sObject> metaObjects = metaObjectsByModuleName.get(moduleName);
                        system.debug('>>>Events Loop - ' + loyaltyEventType + ': ' + metaObjects);

                        if (metaObjects != NULL) {
                            //Check if there's metadata for source to target and Loyalty Status event record for processing.
                            if(metaObjects.size() > 0 && loyaltyEventList.size() > 0){
                                List<Case> newCaseRecords = QCC_UtilityHelper.transformSourceToTargetObjects (moduleName, loyaltyEventList, metaObjects, 'Case', null, null);
                                if(!newCaseRecords.isEmpty()){
                                    for(Case newCase : newCaseRecords){
                                        //Contacts' FF Number with leading zeros are currently saved on contact object with the leading zeros stripped out (by the code accConRshipUpdateonContacts.UpdateFrequentFlyerNumber)
                                        //Thus before getting contacts based on FF Number, need to stripped out leading zeros to get the macthing contacts.
                                        String ffNumber = String.valueOf(newCase.Frequent_Flyer_Number__c);
                                        String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');
                                        newCase.ContactId = (contactInfo.containsKey(ffNumWithOutLeadingZeros)) ? contactInfo.get(ffNumWithOutLeadingZeros).Id : NULL; // Link the Contact record if any, it will return NULL if there's no contact
                                        newCaseRecordList.add(newCase);   // Collection of Case to be created
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            System.debug('newCaseRecordList: ' + newCaseRecordList);

            // Insert New Case Record
            if(newCaseRecordList.size() > 0){
            	//insert newCaseRecordList
                Database.SaveResult[] saveResultList = Database.insert(newCaseRecordList, false);
                //Create the log record for those save result that fails
                QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'QCC Loyalty Status Event - Create Case', 'QCC_LoyaltyStatusEventCaseCreation', '');
            }
    	}catch(Exception ex){
            System.debug('>>>exception: '+ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC Loyalty Status Event - Create Case', 'QCC_LoyaltyStatusEventCaseCreation', 'QCC_LoyaltyStatusEventCaseCreation', '', '', true, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }
}