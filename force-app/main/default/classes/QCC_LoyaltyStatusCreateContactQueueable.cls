/*********************************************************************************
Name         : QCC_LoyaltyStatusCreateContactQueueable
Created By   : Lora Mae Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 3 December 2019
Usages       : Called by QCC_LoyaltyStatusEventTriggerHelper to create Contact record and create cases based on the loyalty events issued for the Frequent Flyer. 
This class expects one FF Number and multiple loyalty events for that FF Number.
Modified Date : 6 October 2021
Comments     : Introduced 3 different callouts to fetch field values for creating contact as part of Member API Version 2 changes CRM - 5003
*********************************************************************************/
public class QCC_LoyaltyStatusCreateContactQueueable implements Queueable, Database.AllowsCallOuts {
    
    public List<QCC_Loyalty_Status__e> loyaltyStatusList = new List <QCC_Loyalty_Status__e>();  
    public String ffNumber;
    public List<sObject> metaObjects = new List<sObject>();
    
    public void execute(QueueableContext context) {
        System.debug('###QCC_LoyaltyStatusCreateContactQueueable.execute');
        //List of wrapper for the Loyalty API Response
        QCC_LoyaltyResponseWrapper loyaltyResponse = new QCC_LoyaltyResponseWrapper();
        List<QCC_LoyaltyResponseWrapper> loyaltyWrapperLists = new List<QCC_LoyaltyResponseWrapper>();
       // List<QCC_LoyaltyResponseWrapper.phoneDetails> phoneWrapperList = new List<QCC_LoyaltyResponseWrapper.phoneDetails>(); // CRM - 5003
         List<QCC_LoyaltyResponseWrapper.Phones> phoneWrapperList = new List<QCC_LoyaltyResponseWrapper.Phones>(); 
         List<QCC_LoyaltyResponseWrapper.Addresses> addressWrapperList = new List<QCC_LoyaltyResponseWrapper.Addresses>();
        //Map collection of FF number and CAP ID from CAP CRE response wherein Map<memberId/ffnumber, CAP ID>
        Map<String, String> ffNumberWithCapIdMap =  new Map<String, String>();
        String lastName;            
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTierResponse;
        
        if(ffNumber != null){
           /* Commented below loyaltyResponse callout and introduced 4 different API callouts as part of
              Member API V2 changes CRM - 5003 */
           // QCC_LoyaltyResponseWrapper loyaltyResponse = QCC_InvokeCAPAPI.invokeLoyaltyAPI(ffNumber);
           
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(ffNumber);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyContactAPI(ffNumber);
            QCC_LoyaltyResponseWrapper.Programs loyaltyProgramResponse = QCC_InvokeCAPAPI.invokeLoyaltyProgramAPI(ffNumber);
            loyaltyTierResponse = QCC_InvokeCAPAPI.invokeLoyaltyTierAPI(ffNumber);
                            
            //If response is not null, get the response and store in a Wrapper
            /*    if(loyaltyResponse != null){  
                System.debug('###customer found!'); 
                phoneWrapperList = loyaltyResponse.phoneDetails;    
                addressWrapperList = loyaltyResponse.addresses;     
                loyaltyWrapperLists.add(loyaltyResponse);   
                System.debug('###loyaltyWrapperLists: ' + loyaltyWrapperLists);                     
                lastName = loyaltyResponse.lastName != null ? loyaltyResponse.lastName : null;              
            }
            */ // CRM-5003
            if(loyaltyContactResponse != null){
                System.debug('###customer found!');
                phoneWrapperList = loyaltyContactResponse.phones;  
                addressWrapperList = loyaltyContactResponse.addresses;
                loyaltyResponse.qantasFrequentFlyerContact = loyaltyContactResponse;
               // loyaltyWrapperLists.add(loyaltyContactResponse);
             //   System.debug('###loyaltyWrapperLists: ' + loyaltyWrapperContactLists);
            }
            if(loyaltyProfileResponse != null){
                lastName = loyaltyProfileResponse.lastName != null ? loyaltyProfileResponse.lastName : null;
                loyaltyResponse.qantasFrequentFlyerProfile = loyaltyProfileResponse;
                //loyaltyWrapperLists.add(loyaltyProfileResponse);   
            }
            if(loyaltyProgramResponse != null){
                loyaltyResponse.programs.add(loyaltyProgramResponse);
               // loyaltyWrapperLists.add(loyaltyProgramResponse);
            }
            if(loyaltyTierResponse != null){
                loyaltyResponse.tierCode = loyaltyTierResponse.qantasFrequentFlyerTier != null ? loyaltyTierResponse.qantasFrequentFlyerTier.tierCode : null;
                loyaltyResponse.effectiveTier =  loyaltyTierResponse.qantasFrequentFlyerTier != null ? loyaltyTierResponse.qantasFrequentFlyerTier.effectiveTier : null;
                //loyaltyResponse.qantasFrequentFlyerTiers.add(loyaltyTierResponse);
              //  loyaltyWrapperLists.add(loyaltyTierResponse);
            }
           loyaltyWrapperLists.add(loyaltyResponse);
        }
        System.debug('###loyaltyRecords.memberId__c response: ' + ffNumber);
        System.debug('###lastName response: ' + lastName);                
        
        //Call QCC_LookupFrequentFlyerController.lookupCustomer callout method for CAP CRE to get the CAP ID
        if(ffNumber != null && lastName != null){
            String response = QCC_LookupFrequentFlyerController.lookupCustomer(ffNumber, lastName, '');
            System.debug('###QCC_LookupFrequentFlyerController.lookupCustomer response: ' + response);                
            //If response is not null, get the CAP ID from the response
            if(response != null) {
                System.debug('###Contact found');
                QCC_LookupFrequentFlyerController.CustomerWrapper cw = (QCC_LookupFrequentFlyerController.CustomerWrapper)JSON.deserialize(response, QCC_LookupFrequentFlyerController.CustomerWrapper.class);
                //Store CAP ID in a Map where FF num  is the key and CAP ID is the Value
                ffNumberWithCapIdMap.put(ffNumber, cw.capId);
            } else if (Test.isRunningTest()) { //Need to add a Mock response if test class is running
                String staticResourceName = 'QCC_Loyalty_Callout_Response';
                StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
                String body = sr.Body.toString();
                //This will just check that the static resource string fits the QCC_LoyaltyResponseWrapper format
                QCC_LoyaltyresponseWrapper responseWrapper = (QCC_LoyaltyresponseWrapper)JSON.deserialize(body, QCC_LoyaltyresponseWrapper.class);
                system.debug('>>>responseWrapper: ' + responseWrapper);
            }
        }        
        
        //If the List for Contact creation is not empty, proceed to the method which creates/updates the Contact record
        List <Contact> contactList = new List <Contact>();  
        List <Contact> contactToCreate = new List <Contact>();        
        List <Contact> contactToUpdate = new List <Contact>(); 
        
        //When multiple loyalty events with same ffnumber are being pushed with split seconds interval, duplicate error is being fired as the Loyalty events considers all the those pushed events as Contact creation.
        //Needed to add while-loop here to allow retry for the purpose of updating the Contact so that when the Contact was created for the first Loyalty Payload that was received, it will then consider the next payloads with the same ffnNumber as Contact update.
        Integer count = 0;
        Integer maxTry = 2;
        while(count < maxTry){            
            system.debug('###count: ' + count);
            system.debug('###maxTry: ' + maxTry);

            try{
                if (!loyaltyWrapperLists.isEmpty()){
                    contactList = createContact(loyaltyWrapperLists, loyaltyStatusList, ffNumberWithCapIdMap, phoneWrapperList, addressWrapperList);
                    System.debug('###contactList: ' + contactList);
                    
                    for(Contact con : contactList){
                        System.debug('###con.id: ' + con.Id);
                        if(con.id == null ){
                            contactToCreate.add(con);
                        }
                        else{
                            contactToUpdate.add(con);
                        }
                    }
                    System.debug('###contactToCreate: ' + contactToCreate);
                    System.debug('###contactToUpdate: ' + contactToUpdate);
                    
                    //Needed to separate DML for update and insert as upsert is not supported in sObjects
                    //Updating of Contact
                    if(!contactToUpdate.isEmpty()){
                        System.debug('###contact is updated ');
                        update contactToUpdate; 
                        //Call method for Case Creation.
                        new QCC_LoyaltyStatusEventCaseCreation(loyaltyStatusList);  
                        //Break the loop upon successful Contact update.
                        break;
                    }
                    //Creation of Contact
                    if(!contactToCreate.isEmpty()){
                        System.debug('###contact is created ');
                        insert contactToCreate; 
                        //Call method for Case Creation.
                        new QCC_LoyaltyStatusEventCaseCreation(loyaltyStatusList);  
                        //Break the loop upon successful Contact creation.
                        break;
                    }               
                } 
                else {
                    break;
                }
            }
            //Log error
            catch(Exception ex) {
                Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC_LoyaltyStatusCreateContactQueueable', 'QCC_LoyaltyStatusCreateContactQueueable', 'execute', '', '', false, '', ex, '');
                QCC_LogUtilityHelper.createLogRecord(logRecord);
                //Increment count to allow another retry
                count ++;
            }
        }
    }
    
    //Method for creating Contact; called on execute method
    public List<Contact> createContact (List<QCC_LoyaltyResponseWrapper>loyaltyWrapperLists, List<QCC_Loyalty_Status__e>loyaltyStatusList, Map<String, String>ffNumberWithCapIdMap,/*List<QCC_LoyaltyResponseWrapper.phoneDetails> phoneWrapperList,(CRM-5003)*/ List<QCC_LoyaltyResponseWrapper.phones> phoneWrapperList,  List<QCC_LoyaltyResponseWrapper.addresses> addressWrapperList){
        System.debug('###QCC_LoyaltyStatusCreateContactQueueable.createContact' );
        System.debug('###createContact loyaltyWrapperLists: ' + loyaltyWrapperLists);
        system.debug('###createContact loyaltyStatusList: ' + loyaltyStatusList);
        
        //Individual Contact Record Type ID generated from the Custom Settings
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));        
        String homeCountryCode;
        String homePhoneAreaCode;
        String homePhoneNumber;        
        String mobileCountryCode;
        String mobilePhoneAreaCode;
        String mobilePhoneNumber;        
        String businessCountryCode;
        String businessPhoneAreaCode;
        String businessPhoneNumber;        
        String homelineOne;        
        String homelineTwo;        
        String businesslineOne;
        String businesslineTwo;
        String frequentFlyerTier;
        
        //Get phone details from response
        /* for(QCC_LoyaltyResponseWrapper.phoneDetails phoneRecord: phoneWrapperList) {*//*(CRM- 5003)*/
        for(QCC_LoyaltyResponseWrapper.phones phoneRecord: phoneWrapperList) {
            if(phoneRecord.type_Z == 'HOME'){
                /*homeCountryCode = phoneRecord.idd != null ? phoneRecord.idd : null;*/ /*(CRM- 5003)*/
                homeCountryCode = phoneRecord.countryCode != null ? phoneRecord.countryCode : null;
                homePhoneAreaCode = phoneRecord.areaCode != null ? phoneRecord.areaCode : null;
                homePhoneNumber = phoneRecord.number_Z != null ? phoneRecord.number_Z : null;
            }   
            else if(phoneRecord.type_Z == 'MOBILE'){
                /*mobileCountryCode = phoneRecord.idd != null ? phoneRecord.idd : null;*//*(CRM- 5003)*/
                mobileCountryCode = phoneRecord.countryCode != null ? phoneRecord.countryCode : null;
                mobilePhoneAreaCode = phoneRecord.areaCode != null ? phoneRecord.areaCode : null;
                mobilePhoneNumber = phoneRecord.number_Z != null ? phoneRecord.number_Z : null;
            }
            else if(phoneRecord.type_Z == 'BUSINESS'){
                /*businessCountryCode = phoneRecord.idd != null ? phoneRecord.idd : null;*//*(CRM- 5003)*/
                businessCountryCode = phoneRecord.countryCode != null ? phoneRecord.countryCode : null;
                businessPhoneAreaCode = phoneRecord.areaCode != null ? phoneRecord.areaCode : null;
                businessPhoneNumber = phoneRecord.number_Z != null ? phoneRecord.number_Z : null;
            }  
        }
        
        //Get address details from response
        for(QCC_LoyaltyResponseWrapper.addresses addressRecord: addressWrapperList) {
            if(addressRecord.type_Z == 'HOME'){
                homelineOne = addressRecord.lineOne != null ? addressRecord.lineOne : null;
                homelineTwo = addressRecord.lineTwo != null ? addressRecord.lineTwo : null;
            }   
            else if(addressRecord.type_Z == 'BUSINESS'){
                businesslineOne = addressRecord.lineOne != null ? addressRecord.lineOne : null;
                businesslineTwo = addressRecord.lineTwo != null ? addressRecord.lineTwo : null;    
            } 
        }   
        
        //Get frequent flyer tier from response
        for(QCC_LoyaltyResponseWrapper loyaltyRecord : loyaltyWrapperLists){ 
            /*  for(QCC_LoyaltyResponseWrapper.programDetails programRecord: loyaltyRecord.programDetails) {*//*CRM- 5003*/
            //loyaltyRecord.tierCode = loyaltyRecord.qantasFrequentFlyerTiers[0].qantasFrequentFlyerTier.tierCode;
            for(QCC_LoyaltyResponseWrapper.programs programRecord: loyaltyRecord.programs) {
             //   system.debug('###programRecord.programCode: ' + programRecord.programCode);
                /*if (loyaltyRecord.tier.code =='CLPO')*/ /*CRM- 5003*/
                if ( loyaltyRecord.tierCode == 'CLPO')
                {
                    frequentFlyerTier = System.Label.QCC_CL_P1;
                }
                else
                { 
                    /*if(programRecord.programCode != 'CL' && programRecord.programCode =='QFF' && frequentFlyerTier != CustomSettingsUtilities.getConfigDataMap(programRecord.tierCode))*/ /*CRM- 5003*/
                    if(programRecord.programCode != 'CL' && programRecord.programCode =='QFF' && frequentFlyerTier != CustomSettingsUtilities.getConfigDataMap(loyaltyRecord.tierCode))
                    {
                        /* frequentFlyerTier = CustomSettingsUtilities.getConfigDataMap(programRecord.tierCode);*/ /*CRM- 5003*/
                        frequentFlyerTier = CustomSettingsUtilities.getConfigDataMap(loyaltyRecord.tierCode);
                    }
                    
                    //Chairman's Lounge Functionality
                    else if(programRecord.programCode =='CL')
                    {
                        frequentFlyerTier = System.Label.QCC_Chairmans_Lounge;
                    }
                }                
                system.debug('###programRecord.programCode: ' + programRecord.programCode);
            }
        }
        
        //Query on Contact record as we need to re-check if the Contact is already existing to allow update on the Contact record
        Map<String, Id> contactMap = new Map<String, Id>();
        for(Contact con : [SELECT Id,Frequent_Flyer_Number__c FROM Contact WHERE Frequent_Flyer_Number__c =: ffNumber AND RecordTypeId =: individualContactRecordTypeId]){
            contactMap.put(con.Frequent_Flyer_Number__c , con.Id);
            system.debug('###contactMap: ' + contactMap.get(con.Frequent_Flyer_Number__c));
        }
        
        //Construct the Contact record to be created. First instantiate and set the fields of the contact based on the related loyalty events attributes by calling createContactFromLoyaltyEvents
        system.debug('>>>Call createContactFromLoyaltyEvents: ' + loyaltyStatusList);
        List<Contact> contactToInsertList = QCC_UtilityHelper.createContactFromLoyaltyEvents(loyaltyStatusList, metaObjects); 
        //After the contact has been set based on the loyalty events, set the other contact information that came from the Loyalty API callout.
        //NOTE: The contactToInsertList will only contain one contact record
        for(Contact contactRecord : contactToInsertList){
            for(QCC_LoyaltyResponseWrapper loyaltyRecord : loyaltyWrapperLists){
                //Check first if the fields were populated from the Loyalty Event, if YES then get the values from the event, if NO then get the values from the response.
                //Stripped out leading zeros for accurate comparison on FF Number
                // - From loyalty respone
                String loyaltyRecFFNumber = String.valueOf(loyaltyRecord.qantasFrequentFlyerProfile.memberId);
                String loyaltyRecFFNumWithOutLeadingZeros = loyaltyRecFFNumber.replaceFirst('^0+','');
                // - From contact record constructed from the event
                String contactRecFFNumber = String.valueOf(contactRecord.Frequent_Flyer_number__c);
                String contactRecFFNumWithOutLeadingZeros = contactRecFFNumber.replaceFirst('^0+','');
                system.debug('###contactRecFFNumWithOutLeadingZeros: ' + contactRecFFNumWithOutLeadingZeros);
                
                if(loyaltyRecFFNumWithOutLeadingZeros == contactRecFFNumWithOutLeadingZeros){
                    contactRecord.Id = (contactMap.containsKey(contactRecFFNumWithOutLeadingZeros)) ? contactMap.get(contactRecFFNumWithOutLeadingZeros) : null;
                    contactRecord.RecordTypeId = individualContactRecordTypeId;
                    contactRecord.FirstName = contactRecord.FirstName == null ? loyaltyRecord.qantasFrequentFlyerProfile.firstName : contactRecord.FirstName;
                    contactRecord.LastName = contactRecord.LastName == null ? loyaltyRecord.qantasFrequentFlyerProfile.lastName : contactRecord.LastName;
                    contactRecord.Salutation = contactRecord.Salutation == null ? loyaltyRecord.qantasFrequentFlyerProfile.title : contactRecord.Salutation;
                    contactRecord.Email = contactRecord.Email == null ? loyaltyRecord.email : contactRecord.Email; 
                    /*contactRecord.Year_of_Joining__c =  Date.valueOf(loyaltyRecord.dateOfJoining);*/ /*CRM- 5003*/
                    contactRecord.Year_of_Joining__c =  Date.valueOf(loyaltyRecord.qantasFrequentFlyerProfile.dateOfBirth);
                    contactRecord.Birthdate = contactRecord.Birthdate == null ? Date.valueOf(loyaltyRecord.qantasFrequentFlyerProfile.dateOfBirth) : contactRecord.Birthdate;
                    contactRecord.CAP_ID__c = ffNumberWithCapIdMap.containsKey(loyaltyRecord.qantasFrequentFlyerProfile.memberId) ? ffNumberWithCapIdMap.get(loyaltyRecord.qantasFrequentFlyerProfile.memberId) : null;
                    /*contactRecord.QCC_Effective_Tier__c = contactRecord.QCC_Effective_Tier__c == null ? loyaltyRecord.Tier.effectiveTier : contactRecord.QCC_Effective_Tier__c; */ /*CRM- 5003*/
                    contactRecord.QCC_Effective_Tier__c = contactRecord.QCC_Effective_Tier__c == null ? loyaltyRecord.effectiveTier : contactRecord.QCC_Effective_Tier__c;                    
                    contactRecord.Frequent_Flyer_Tier__c = contactRecord.Frequent_Flyer_Tier__c == null ? frequentFlyerTier : contactRecord.Frequent_Flyer_Tier__c;    
                    contactRecord.QCC_TECH_HomePhoneCountryCode__c = contactRecord.QCC_TECH_HomePhoneCountryCode__c == null ? homeCountryCode : contactRecord.QCC_TECH_HomePhoneCountryCode__c; 
                    contactRecord.QCC_TECH_HomePhoneAreaCode__c = contactRecord.QCC_TECH_HomePhoneAreaCode__c == null ? homePhoneAreaCode : contactRecord.QCC_TECH_HomePhoneAreaCode__c; 
                    contactRecord.QCC_TECH_HomePhoneNumber__c = contactRecord.QCC_TECH_HomePhoneNumber__c == null ? homePhoneNumber : contactRecord.QCC_TECH_HomePhoneNumber__c; 
                    contactRecord.QCC_TECH_MobilePhoneCountryCode__c = contactRecord.QCC_TECH_MobilePhoneCountryCode__c == null ?  mobileCountryCode : contactRecord.QCC_TECH_MobilePhoneCountryCode__c; 
                    contactRecord.QCC_TECH_MobilePhoneAreaCode__c = contactRecord.QCC_TECH_MobilePhoneAreaCode__c == null ? mobilePhoneAreaCode : contactRecord.QCC_TECH_MobilePhoneAreaCode__c; 
                    contactRecord.QCC_TECH_MobilePhoneNumber__c = contactRecord.QCC_TECH_MobilePhoneNumber__c == null ? mobilePhoneNumber : contactRecord.QCC_TECH_MobilePhoneNumber__c; 
                    contactRecord.QCC_TECH_BusinessPhoneCountryCode__c = contactRecord.QCC_TECH_BusinessPhoneCountryCode__c == null ? businessCountryCode : contactRecord.QCC_TECH_BusinessPhoneCountryCode__c; 
                    contactRecord.QCC_TECH_BusinessPhoneAreaCode__c = contactRecord.QCC_TECH_BusinessPhoneAreaCode__c == null ? businessPhoneAreaCode : contactRecord.QCC_TECH_BusinessPhoneAreaCode__c; 
                    contactRecord.QCC_TECH_BusinessPhoneNumber__c = contactRecord.QCC_TECH_BusinessPhoneNumber__c == null ? businessPhoneNumber : contactRecord.QCC_TECH_BusinessPhoneNumber__c;
                    contactRecord.QCC_TECH_MailingStreetHomeLineOne__c = contactRecord.QCC_TECH_MailingStreetHomeLineOne__c == null ? homelineOne : contactRecord.QCC_TECH_MailingStreetHomeLineOne__c; 
                    contactRecord.QCC_TECH_MailingStreetHomeLineTwo__c = contactRecord.QCC_TECH_MailingStreetHomeLineTwo__c == null ? homelineTwo : contactRecord.QCC_TECH_MailingStreetHomeLineTwo__c; 
                    contactRecord.QCC_TECH_MailingStreetBusinessLineOne__c = contactRecord.QCC_TECH_MailingStreetBusinessLineOne__c == null ? businesslineOne : contactRecord.QCC_TECH_MailingStreetBusinessLineOne__c; 
                    contactRecord.QCC_TECH_MailingStreetBusinessLineTwo__c = contactRecord.QCC_TECH_MailingStreetBusinessLineTwo__c == null ? businesslineTwo : contactRecord.QCC_TECH_MailingStreetBusinessLineTwo__c;
                }
            }
        }
        return contactToInsertList;
    }
}