/*********************************************************************************
Name         : ContactTriggerHelper
Created By   : Lora Mae S. Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 27 September 2019
Usages       : Automatically creates an Individual record based on the FF# of the inserted Contact reord.
*********************************************************************************/

public without sharing class ContactTriggerHelper {
    
    //used in preventing recursive trigger calls
    public static Boolean isFirstTime = true;
    
    //get Contact Record and Search for Existing Individual Record using Frequent Flyer #
    public static void createIndividualRecord(Map <Id,Contact> contactNewMap){
        system.debug('###contactNewMap.values(): ' + contactNewMap.values());        
        
        //get Contact recordTypes
        Integer ffNumSize = Integer.valueOf(Label.QCC_Frequent_Flyer_Number_Length);															//ffnum size from custom label
        Id b2bRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Contact'));				//Contact RTid
        Id b2cRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));    //Individual Contact RTid         
        
        //map FFnumber with Contact Id
        List<Contact> conListIndiLookupToUpdate = new List<Contact>();							//stores contacts to be updated
        Set<Id> contactIdSets = new Set<Id>();    												//stores all ContactIds
        
        Map<String, List<Id>> contactMap = new Map<String, List<Id>>();        
        for (Contact contactRecord : contactNewMap.values()){            													//iterate triggernewMap
            System.debug('###contactRecord.Frequent_Flyer_Number__c:  ' + contactRecord.Frequent_Flyer_Number__c);
            if (contactRecord.Frequent_Flyer_Number__c != NULL && contactRecord.IndividualId == NULL){						//process will only execute if the contact is not yet linked to an Individual record	
                String ffNumber = String.valueOf(contactRecord.Frequent_Flyer_Number__c);
                String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');
                List<Id> contactIdLists = (contactMap.containsKey(ffNumWithOutLeadingZeros) ? contactMap.get(ffNumWithOutLeadingZeros) : new List<Id>());
                contactIdLists.add(contactRecord.Id);
                contactMap.put(ffNumWithOutLeadingZeros, contactIdLists);													//populate contactMap
                contactIdSets.add(contactRecord.Id);																		//add all contact ids in a Set
            }
        }        
        system.debug('###contactMapvalues: ' + contactMap.values());
        
        //update existing Individual record
        Map<String, Individual> individualMap = new Map<String, Individual>();   
        List<Individual> individualForUpsert = new List<Individual>();
        for(Individual ind : [SELECT Id, Name, QCC_B2B_Contact__c, QCC_B2C_Contact__c, QCC_Frequent_Flyer_Number__c FROM Individual WHERE QCC_Frequent_Flyer_Number__c IN: contactMap.keySet()]){
            individualMap.put(ind.QCC_Frequent_Flyer_Number__c, ind);
        } 
        
        for(String ffKey : contactMap.keyset()){																//iterate keyset
            system.debug('###ffKey: ' + ffKey);
            
            for(Id conID : contactMap.get(ffKey)){
                Contact con = contactNewMap.get(conID);                
                Id indId = (individualMap.containsKey(ffKey)) ?  individualMap.get(ffKey).Id : null;   			//set indID value             
                Individual individualRec = new Individual (QCC_Frequent_Flyer_Number__c = ffKey);				//instance of Investigation record
                
                if(indId != NULL) {
                    individualRec.Id = indId;
                }
                /*Following requirement is out-of-scope until a business case to maintain two-way lookups has been determined
if (con.RecordTypeId == b2bRecTypeId) {																						//populate lookup based on RT
individualRec.QCC_B2B_Contact__c = con.Id;
} 
else if (con.RecordTypeId == b2cRecTypeId) {																				//populate lookup based on RT
individualRec.QCC_B2C_Contact__c = con.Id;
}*/
                individualRec.QCC_Frequent_Flyer_Number__c = ffKey;
                individualRec.LastName = con.LastName;  
                individualForUpsert.add(individualRec);
            }
        }
        system.debug('###individualForUpsert: ' + individualForUpsert);
        
        //try catch for DML
        try{
            if (individualForUpsert.size() > 0){
                upsert individualForUpsert;
                
                /*Following requirement is out-of-scope until a business case to maintain two-way lookups has been determined
//iterate individualForUpsert List
for (Individual individualInstance : individualForUpsert) {
if (individualInstance.QCC_B2B_Contact__c != NULL){
conListIndiLookupToUpdate.add(new Contact (Id = individualInstance.QCC_B2B_Contact__c, IndividualId = individualInstance.Id));
}
if (individualInstance.QCC_B2C_Contact__c != NULL){
conListIndiLookupToUpdate.add(new Contact (Id = individualInstance.QCC_B2C_Contact__c, IndividualId = individualInstance.Id));
}
}

//DML for updating IndividualId field on Contact object
if (conListIndiLookupToUpdate.size() > 0){
update conListIndiLookupToUpdate;
}*/
                
                //iterate individualForUpsert List to link it to the Contact
                for (Individual individualInstance : individualForUpsert) {
                    String ffNumber = individualInstance.QCC_Frequent_Flyer_Number__c;
                    system.debug('>>>Individual - ffNumber: ' + ffNumber);
                    for(Id conID : contactMap.get(ffNumber)){
                        Contact con = contactNewMap.get(conID);
                        //GRAPHITE 936 - set field as Individual Contact. This is used by Duplicate Rule to detecth duplicates for B2C contacts.
                        String b2cRecordTypeName = (con.RecordTypeId == b2cRecTypeId) ? 'Individual Contact' : '';
                        conListIndiLookupToUpdate.add(new Contact (Id = conID, IndividualId = individualInstance.Id, QCC_TECH_RecordType__c = b2cRecordTypeName));
                    }
                    
                }
                
                //DML for updating IndividualId field on Contact object
                if (conListIndiLookupToUpdate.size() > 0){
                    update conListIndiLookupToUpdate;
                }
            }
        }        
        //log error
        catch(Exception ex) {
            contactNewMap.values().get(0).adderror(ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('ContactTriggerHelper', 'ContactTriggerHelper', 'createIndividualRecord', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
            
        }
    }      
    
    //GRAPHITE-1373 : Changes to process builders for loyalty data
    // This method will create a Welcome to SSU Case if the Contact if set to SSU=True
    public static void createCaseForSsuContact(List<Contact> newContactList, Map<Id, Contact> oldContactMap){
        //Get Contact with SSU flag was set to true from false or null(new)
        List<Contact> contactToProcessList = new List<Contact>();
        oldContactMap = (oldContactMap == NULL) ? new Map<Id, Contact>() : oldContactMap;
        Id individualRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
        for (Contact contactRecord : newContactList) {
            if (contactRecord.RecordTypeId == individualRecordTypeId) {
                if(oldContactMap.containsKey(contactRecord.Id)){ // Existing record
                    if (oldContactMap.get(contactRecord.Id).SSU__c != contactRecord.SSU__c && contactRecord.SSU__c) { // From False, updated to True
                        contactToProcessList.add(contactRecord);
                    }
                }else if(contactRecord.SSU__c){ // New Record and SSU flag is true
                    contactToProcessList.add(contactRecord);
                }
            }
        }
        system.debug('contactToProcessList : ' + contactToProcessList);
        if(contactToProcessList.size() > 0){
            String metaName = 'QCC_Source_to_Target_Object_Mapping__mdt';
            String conditionClauseInsert = ' WHERE  Module_Name__c =\'' + Label.QCC_Welcome_to_SSU_Module + '\'';
            Map<String,List<sObject>> metaObjectsByModuleName = QCC_UtilityHelper.getObjMap(metaName, 'Module_Name__c', conditionClauseInsert);
            system.debug('>>>>metaObjectsByModuleName: ' + metaObjectsByModuleName);
            
            List<sObject> metaObjects = metaObjectsByModuleName.get(Label.QCC_Welcome_to_SSU_Module);
            List<Case> caseRecord = QCC_UtilityHelper.transformSourceToTargetObjects(Label.QCC_Welcome_to_SSU_Module, contactToProcessList, metaObjects, 'Case', null, null);
            
            //insert caseRecord
            Database.SaveResult[] saveResultList = Database.insert(caseRecord, false);
            //Create the log record for those save result that fails
            QCC_LogUtilityHelper.DatabaseResultsWrapper databaseDMLResult = QCC_LogUtilityHelper.getDatabaseResults(saveResultList, 'Contact Trigger - createCaseForSsuContact', 'ContactTriggerHelper', '');
            
        }
    }
    
    //GRAPHITE-2397 Transfer the logic from QCC Contact - Update Contact Phone and Address Details process builder to trigger
    public static void updateContactPhoneAndAddressDetails(List<Contact> newContacts, Map<Id, Contact> oldContactMap) {
        System.debug('ContactTriggerHelper.updateContactPhoneAndAddressDetails');
        Id individualRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
        
        //This will set the oldContactMap to a new Map if it is null
        oldContactMap = (oldContactMap == NULL) ? new Map<Id, Contact>() : oldContactMap;
        
        //This will be used as the concatenation template for generating field values and to check if we need to process that concatenation logic
        List<String> businessPhoneFieldNames = new List<String>{'QCC_TECH_BusinessPhoneCountryCode__c', 'QCC_TECH_BusinessPhoneAreaCode__c', 'QCC_TECH_BusinessPhoneNumber__c'};
            List<String> homePhoneFieldNames = new List<String>{'QCC_TECH_HomePhoneCountryCode__c', 'QCC_TECH_HomePhoneAreaCode__c', 'QCC_TECH_HomePhoneNumber__c'};
                List<String> mobilePhoneFieldNames = new List<String>{'QCC_TECH_MobilePhoneCountryCode__c', 'QCC_TECH_MobilePhoneAreaCode__c', 'QCC_TECH_MobilePhoneNumber__c'};
                    List<String> travelSMSPhoneFieldNames = new List<String>{'QCC_TECH_TravelSMSPhoneCountryCode__c', 'QCC_TECH_TravelSMSPhoneAreaCode__c', 'QCC_TECH_TravelSMSPhoneNumber__c'};
                        List<String> mailingStreetFieldNames = new List<String>{'QCC_TECH_MailingStreetHomeLineOne__c', 'QCC_TECH_MailingStreetHomeLineTwo__c'};
                            List<String> otherStreetFieldNames = new List<String>{'QCC_TECH_MailingStreetBusinessLineOne__c', 'QCC_TECH_MailingStreetBusinessLineTwo__c'};
                                
                                for(Contact newContact : newContacts) {
                                    if (newContact.RecordTypeId == individualRecordTypeId) {
                                        if (!oldContactMap.containsKey(newContact.Id)) {
                                            //Populate all these fields if new record.
                                            newContact.Business_Phone__c = QCC_UtilityHelper.generateConcatenatedFieldValues(businessPhoneFieldNames, newContact);
                                            newContact.HomePhone = QCC_UtilityHelper.generateConcatenatedFieldValues(homePhoneFieldNames, newContact);
                                            newContact.MobilePhone = QCC_UtilityHelper.generateConcatenatedFieldValues(mobilePhoneFieldNames, newContact);
                                            newContact.QCC_Travel_SMS__c = QCC_UtilityHelper.generateConcatenatedFieldValues(travelSMSPhoneFieldNames, newContact);
                                            newContact.MailingStreet = QCC_UtilityHelper.generateConcatenatedFieldValues(mailingStreetFieldNames, newContact);
                                            newContact.OtherStreet = QCC_UtilityHelper.generateConcatenatedFieldValues(otherStreetFieldNames, newContact);
                                            System.debug('QCC_TECH_MobilePhoneCountryCode__c : ' + newContact.QCC_TECH_MobilePhoneCountryCode__c);
                                            System.debug('QCC_TECH_MobilePhoneAreaCode__c : ' + newContact.QCC_TECH_MobilePhoneAreaCode__c);
                                            System.debug('QCC_TECH_MobilePhoneNumber__c : ' + newContact.QCC_TECH_MobilePhoneNumber__c);
                                            System.debug('QCC_TECH_BusinessPhoneCountryCode__c : ' + newContact.QCC_TECH_BusinessPhoneCountryCode__c);
                                            System.debug('QCC_TECH_BusinessPhoneAreaCode__c : ' + newContact.QCC_TECH_BusinessPhoneAreaCode__c);
                                            System.debug('QCC_TECH_BusinessPhoneNumber__c : ' + newContact.QCC_TECH_BusinessPhoneNumber__c);
                                            System.debug('QCC_TECH_HomePhoneCountryCode__c : ' + newContact.QCC_TECH_HomePhoneCountryCode__c);
                                            System.debug('QCC_TECH_HomePhoneAreaCode__c : ' + newContact.QCC_TECH_HomePhoneAreaCode__c);
                                            System.debug('QCC_TECH_HomePhoneNumber__c : ' + newContact.QCC_TECH_HomePhoneNumber__c);
                                            if(newContact.QCC_TECH_MobilePhoneCountryCode__c!=Null ||newContact.QCC_TECH_MobilePhoneAreaCode__c!=Null ||newContact.QCC_TECH_MobilePhoneNumber__c!=Null)
                                            {
                                                newContact.Formatted_Mobile_Phone__c = QCC_UtilityHelper.PhoneNumbertoE164(newContact.QCC_TECH_MobilePhoneCountryCode__c,newContact.QCC_TECH_MobilePhoneAreaCode__c,newContact.QCC_TECH_MobilePhoneNumber__c);
                                                system.debug('newContact.Formatted_Mobile_Phone__c' +newContact.Formatted_Mobile_Phone__c);
                                            }
                                            if(newContact.QCC_TECH_BusinessPhoneCountryCode__c!=Null ||newContact.QCC_TECH_BusinessPhoneAreaCode__c!=Null ||newContact.QCC_TECH_BusinessPhoneNumber__c!=Null)
                                            {
                                                newContact.Formatted_Business_Phone__c = QCC_UtilityHelper.PhoneNumbertoE164(newContact.QCC_TECH_BusinessPhoneCountryCode__c,newContact.QCC_TECH_BusinessPhoneAreaCode__c,newContact.QCC_TECH_BusinessPhoneNumber__c);
                                                system.debug('newContact.Formatted_Business_Phone__c' +newContact.Formatted_Business_Phone__c);
                                            }
                                            if(newContact.QCC_TECH_HomePhoneCountryCode__c!=Null ||newContact.QCC_TECH_HomePhoneAreaCode__c!=Null ||newContact.QCC_TECH_HomePhoneNumber__c!=Null)
                                            {
                                                newContact.Formatted_Home_Phone__c = QCC_UtilityHelper.PhoneNumbertoE164(newContact.QCC_TECH_HomePhoneCountryCode__c,newContact.QCC_TECH_HomePhoneAreaCode__c,newContact.QCC_TECH_HomePhoneNumber__c);
                                                system.debug('newContact.Formatted_Home_Phone__c' +newContact.Formatted_Home_Phone__c);
                                                
                                            } 
                                        } else {
                                            //Populate fields only if any of the field value got changed upon update.
                                            Contact oldContact = oldContactMap.get(newContact.Id);
                                            System.debug('QCC_TECH_MobilePhoneCountryCode__c old: ' +   oldContact.QCC_TECH_MobilePhoneCountryCode__c);
                                            System.debug('QCC_TECH_MobilePhoneAreaCode__c old : ' + oldContact.QCC_TECH_MobilePhoneAreaCode__c);
                                            System.debug('QCC_TECH_MobilePhoneNumber__c old : ' + oldContact.QCC_TECH_MobilePhoneNumber__c);
                                            
                                            System.debug('QCC_TECH_MobilePhoneCountryCode__c new: ' +   newContact.QCC_TECH_MobilePhoneCountryCode__c);
                                            System.debug('QCC_TECH_MobilePhoneAreaCode__c new : ' + newContact.QCC_TECH_MobilePhoneAreaCode__c);
                                            System.debug('QCC_TECH_MobilePhoneNumber__c new : ' + newContact.QCC_TECH_MobilePhoneNumber__c);
                                            
                                            
                                            //Update Contact.Business_Phone__c
                                            if (QCC_UtilityHelper.checkIfFieldValueChanged(businessPhoneFieldNames, newContact, oldContact)) {
                                                
                                                newContact.Business_Phone__c = QCC_UtilityHelper.generateConcatenatedFieldValues(businessPhoneFieldNames, newContact);
                                                newContact.Formatted_Business_Phone__c = QCC_UtilityHelper.PhoneNumbertoE164(newContact.QCC_TECH_BusinessPhoneCountryCode__c,newContact.QCC_TECH_BusinessPhoneAreaCode__c,newContact.QCC_TECH_BusinessPhoneNumber__c);
                                                system.debug('newContact.Formatted_Business_Phone__c' +newContact.Formatted_Business_Phone__c);
                                                
                                            }
                                            
                                            //Update Contact.HomePhone
                                            if (QCC_UtilityHelper.checkIfFieldValueChanged(homePhoneFieldNames, newContact, oldContact)) {
                                                newContact.HomePhone = QCC_UtilityHelper.generateConcatenatedFieldValues(homePhoneFieldNames, newContact);
                                                newContact.Formatted_Home_Phone__c = QCC_UtilityHelper.PhoneNumbertoE164(newContact.QCC_TECH_HomePhoneCountryCode__c,newContact.QCC_TECH_HomePhoneAreaCode__c,newContact.QCC_TECH_HomePhoneNumber__c);
                                                system.debug('newContact.Formatted_Home_Phone__c' +newContact.Formatted_Home_Phone__c);
                                            }
                                            
                                            //Update Contact.MobilePhone
                                            if (QCC_UtilityHelper.checkIfFieldValueChanged(mobilePhoneFieldNames, newContact, oldContact)) {
                                                newContact.MobilePhone = QCC_UtilityHelper.generateConcatenatedFieldValues(mobilePhoneFieldNames, newContact);
                                                newContact.Formatted_Mobile_Phone__c= QCC_UtilityHelper.PhoneNumbertoE164(newContact.QCC_TECH_MobilePhoneCountryCode__c,newContact.QCC_TECH_MobilePhoneAreaCode__c,newContact.QCC_TECH_MobilePhoneNumber__c);
                                                system.debug('newContact.Formatted_Mobile_Phone__c' +newContact.Formatted_Mobile_Phone__c);
                                            }
                                            
                                            //Update Contact.QCC_Travel_SMS__c
                                            if (QCC_UtilityHelper.checkIfFieldValueChanged(travelSMSPhoneFieldNames, newContact, oldContact)) {
                                                newContact.QCC_Travel_SMS__c = QCC_UtilityHelper.generateConcatenatedFieldValues(travelSMSPhoneFieldNames, newContact);
                                            }
                                            
                                            //Update Contact.MailingStreet
                                            if (QCC_UtilityHelper.checkIfFieldValueChanged(mailingStreetFieldNames, newContact, oldContact)) {
                                                newContact.MailingStreet = QCC_UtilityHelper.generateConcatenatedFieldValues(mailingStreetFieldNames, newContact);
                                            }
                                            
                                            //Update Contact.OtherStreet
                                            if (QCC_UtilityHelper.checkIfFieldValueChanged(otherStreetFieldNames, newContact, oldContact)) {
                                                newContact.OtherStreet = QCC_UtilityHelper.generateConcatenatedFieldValues(otherStreetFieldNames, newContact);
                                            }
                                        }
                                        System.debug('newContact after logic: ' + newContact);
                                    }
                                }
    }
}