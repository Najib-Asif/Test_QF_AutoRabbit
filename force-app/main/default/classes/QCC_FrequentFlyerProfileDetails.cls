/*----------------------------------------------------------------------------------------------------------------------
Author:        Van Cabezas
Company:       Accenture
Description:   Class for retrieving frequent flyer information from Loyalty API. Used in QCC_FFProfileDetailsFlowHelper.
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
09-Mar-2023      Van Cabezas                   ADT-92 Initial Creation
06-Apr-2023      Jamie Wang                    ADT-461 add getContactDetails for create a case flow
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_FrequentFlyerProfileDetails {
    /************************************
* Purpose      : Getting Frequent Flyer Datas from API
* Parameter    : Frequent Flyer Number
* Returns      : List
* Throws       :
* Expectations : 
************************************/
    public static QCC_FrequentFlyerProfileDetailsWrapper getFFProfileAndContactDetails(String ffNumber, QCC_FrequentFlyerProfileDetailsWrapper singleQffProfile) {
        //QCC_FrequentFlyerProfileDetailsWrapper singleQffProfile = new QCC_FrequentFlyerProfileDetailsWrapper();
        
        //***START - Loyalty Profile API***//
        singleQffProfile.ffNumber = ffNumber;
        system.debug('QCC_FrequentFlyerProfileDetailsWrapper +++ ' + ffNumber);
        String loyaltyProfileResponse = QCC_InvokeCAPAPI.invokeLoyaltyRawProfileAPI(ffNumber);
        String loyaltyProfileMissingInfo = '';
        Map<String, Object> loyaltyProfileResponseMap = (String.isNotBlank(loyaltyProfileResponse)) ? (Map<String, Object>) JSON.deserializeUntyped(loyaltyProfileResponse) : new Map<String, Object>();
        system.debug('>>>loyaltyProfileResponseMap: ' + JSON.serializePretty(loyaltyProfileResponseMap));
        
        if (loyaltyProfileResponseMap.containsKey('title')) {
            //singleQffProfile.title = (String) loyaltyProfileResponseMap.get('title');
            singleQffProfile.title = convertToProperCase((String) loyaltyProfileResponseMap.get('title'));
        } else {
            loyaltyProfileMissingInfo = (String.isBlank(loyaltyProfileMissingInfo)) ? 'Title' : loyaltyProfileMissingInfo + ', ' + 'Title';
        }
        
        if (loyaltyProfileResponseMap.containsKey('firstName')) {
            //singleQffProfile.firstName = (String) loyaltyProfileResponseMap.get('firstName');
            singleQffProfile.firstName = convertToProperCase((String) loyaltyProfileResponseMap.get('firstName'));
        } else {
            loyaltyProfileMissingInfo = (String.isBlank(loyaltyProfileMissingInfo)) ? 'First Name' : loyaltyProfileMissingInfo + ', ' + 'First Name';
        }
        
        if (loyaltyProfileResponseMap.containsKey('lastName')) {
            //singleQffProfile.lastName = (String) loyaltyProfileResponseMap.get('lastName');
            singleQffProfile.lastName = convertToProperCase((String) loyaltyProfileResponseMap.get('lastName'));
        } else {
            loyaltyProfileMissingInfo = (String.isBlank(loyaltyProfileMissingInfo)) ? 'Last Name' : loyaltyProfileMissingInfo + ', ' + 'Last Name';
        }
        
        if (loyaltyProfileResponseMap.containsKey('preferredName')) {
            //singleQffProfile.preferredName = (String) loyaltyProfileResponseMap.get('preferredName');
            singleQffProfile.preferredName = convertToProperCase((String) loyaltyProfileResponseMap.get('preferredName'));
        } else {
            loyaltyProfileMissingInfo = (String.isBlank(loyaltyProfileMissingInfo)) ? 'Preferred Name' : loyaltyProfileMissingInfo + ', ' + 'Preferred Name';
        }
        
        if (String.isNotBlank(loyaltyProfileMissingInfo)) {
            //loyaltyProfileMissingInfo = 'Unable to retrieve latest contact\'s ' + loyaltyProfileMissingInfo + ' at this time.';
            singleQffProfile.withProfileAPIException = true;
            singleQffProfile.profileAPIExceptionMsg = loyaltyProfileMissingInfo;
        }
        //***END - Loyalty Profile API***//
        
        //***START - Loyalty Contact API***//
        String loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyRawContact(ffNumber);
        Map<String, Object> loyaltyContactResponseMap = (String.isNotBlank(loyaltyContactResponse)) ? (Map<String, Object>) JSON.deserializeUntyped(loyaltyContactResponse) : new Map<String, Object>();
        
        System.debug('>>>loyaltyContactResponse: ' + JSON.serializePretty(loyaltyContactResponseMap));
        
        List<Object> addressesObjs = (loyaltyContactResponseMap.containsKey('addresses')) ? (List<Object>)loyaltyContactResponseMap.get('addresses') : new List<Object>();
        List<Object> phonesObjs = (loyaltyContactResponseMap.containsKey('phones')) ? (List<Object>)loyaltyContactResponseMap.get('phones') : new List<Object>();
        List<Object> emailsObjs = (loyaltyContactResponseMap.containsKey('emails')) ? (List<Object>)loyaltyContactResponseMap.get('emails') : new List<Object>();
        
        if (addressesObjs.isEmpty() || phonesObjs.isEmpty() || emailsObjs.isEmpty()) {
            singleQffProfile.withContactAPIException = true;
            singleQffProfile.contactAPIExceptionMsg = '';
            if (phonesObjs.isEmpty()) {
                singleQffProfile.contactAPIExceptionMsg = (String.isBlank(singleQffProfile.contactAPIExceptionMsg)) ? 'Phone Number' : singleQffProfile.contactAPIExceptionMsg + ', ' + 'Phone Number';
            }
            
            if (emailsObjs.isEmpty()) {
                singleQffProfile.contactAPIExceptionMsg = (String.isBlank(singleQffProfile.contactAPIExceptionMsg)) ? 'Email' : singleQffProfile.contactAPIExceptionMsg + ', ' + 'Email';
            }
            
            if (addressesObjs.isEmpty()) {
                singleQffProfile.contactAPIExceptionMsg = (String.isBlank(singleQffProfile.contactAPIExceptionMsg)) ? 'Address' : singleQffProfile.contactAPIExceptionMsg + ', ' + 'Address';
            }
        }
        
        for (Object phoneyObj : phonesObjs) {
            Map<String, Object> phoneNum = (Map<String, Object>) phoneyObj;
            if((Boolean)phoneNum.get('preferred') == true){
                //singleQffProfile.phoneNumber = phoneNum.get('countryCode') + '' + phoneNum.get('number_Z');
                singleQffProfile.phoneNumber = (String)phoneNum.get('e164Format');
                break;
            }
        }
        
        for (Object emailObj : emailsObjs) {
            Map<String, Object> emailAdd = (Map<String, Object>) emailObj;
            if((Boolean)emailAdd.get('preferred') == true){
                singleQffProfile.email = (String) emailAdd.get('emailAddress');
                break;
            }
        }
        
        for (Object addressObj : addressesObjs) {
            Map<String, Object> address = (Map<String, Object>) addressObj;
            if((Boolean)address.get('preferred') == true){
                String lineOne = (String)address.get('lineOne');
                String lineTwo = (String)address.get('lineTwo');
                singleQffProfile.street = string.isEmpty(lineTwo) ? lineOne : lineOne + ' ' + lineTwo;
                singleQffProfile.suburb = (String)address.get('suburb');
                singleQffProfile.state = (String)address.get('state');
                singleQffProfile.postcode = (String)address.get('postCode');
                singleQffProfile.countryName = (String)address.get('countryName');
                
                
                break;
            }
        }
        //***END - Loyalty Contact API***// 
        
        //***START - Loyalty Tier API***//
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTiersponse = QCC_InvokeCAPAPI.invokeQCCTierAPI(ffNumber);
        system.debug('@@@@ test loyaltyTiersponse' + loyaltyTiersponse);
        //Tier loyaltyTiersponse Check
        if (loyaltyTiersponse == NULL) {
            singleQffProfile.withTierAPIException = true;
            //singleQffProfile.tierAPIExceptionMsg = 'Unable to retrieve latest contact\'s Tier information at this time.';
            singleQffProfile.tierAPIExceptionMsg = 'Tier Information';
        } else {
            if(loyaltyTiersponse.qantasFrequentFlyerTier!=null)
            {
                String effectiveTier = (string) loyaltyTiersponse.qantasFrequentFlyerTier.effectiveTier;
                String qffTier =  CustomSettingsUtilities.getConfigDataMap(/*program.tierCode) CRM-5003*/effectiveTier);
                singleQffProfile.qffTier = qffTier;

                //CRM-7027 commented as part of field mapping
                //Date tierAnniversaryDate = date.valueOf(loyaltyTiersponse.qantasFrequentFlyerTier.startDate);
                Date tierAnniversaryDate;
                if(loyaltyTiersponse.qantasFrequentFlyerTier.expiryDate!=null)
                tierAnniversaryDate=date.valueOf(loyaltyTiersponse.qantasFrequentFlyerTier.expiryDate);

                system.debug('the value of tierAnniversaryDate'+tierAnniversaryDate);

                if(tierAnniversaryDate!=null)
                singleQffProfile.tierAnniversaryDate = tierAnniversaryDate;

                //singleQffProfile.tierAnniversaryDateString = loyaltyTiersponse.qantasFrequentFlyerTier.startDate;
                if(loyaltyTiersponse.qantasFrequentFlyerTier.expiryDate!=null)
                singleQffProfile.tierAnniversaryDateString = loyaltyTiersponse.qantasFrequentFlyerTier.expiryDate;
            }
            
        }
        //***END - Loyalty Tier API***//
        
        system.debug('>>>getFFProfileDetails - singleQffProfile: ' + JSON.serializePretty(singleQffProfile));
        return singleQffProfile;
        
    }
    
    public static QCC_FrequentFlyerProfileDetailsWrapper getFFDetails(String ffNumber, Contact existingContact) {
        List<QCC_FrequentFlyerProfileDetailsWrapper> listQffProfiles = new List<QCC_FrequentFlyerProfileDetailsWrapper>();
        QCC_FrequentFlyerProfileDetailsWrapper singleQffProfile = new QCC_FrequentFlyerProfileDetailsWrapper();
        
        //***START - Loyalty Profile, Contact and Tier API***//
        singleQffProfile = getFFProfileAndContactDetails(ffNumber, singleQffProfile);
        //***END - Loyalty Profile API***//
        
        //***START - Loyalty Tier, Program, Account API***//
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTiersponse = QCC_InvokeCAPAPI.invokeQCCTierAPI(ffNumber);
        QCC_LoyaltyResponseWrapper.Programs loyaltyProgramResponse = QCC_InvokeCAPAPI.invokeQCCProgramAPI(ffNumber);
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount loyaltyAccountResponse = QCC_InvokeCAPAPI.invokeQCCAccountAPI(ffNumber);
        List<QCC_LoyaltyResponseWrapper.programs> programWrapperList = new List<QCC_LoyaltyResponseWrapper.programs>();
        
        system.debug('>>>loyaltyTiersponse: ' + JSON.serializePretty(loyaltyTiersponse));
        system.debug('>>>loyaltyProgramResponse: ' + JSON.serializePretty(loyaltyProgramResponse));
        system.debug('>>>loyaltyAccountResponse: ' + JSON.serializePretty(loyaltyAccountResponse));
        
        Boolean isChanged = false;
        Contact objCon = existingContact;
        Boolean isUpdateTier = false;
        Integer statusLifeTime;
        Integer pointBalance;

        //Jira: CRM-8740
        singleQffProfile.lifteTimeTier = loyaltyTiersponse != null ? loyaltyTiersponse.qantasFrequentFlyerTier.lifetimeTier : '';
        

        System.debug('>> print the level description from response'+loyaltyTiersponse?.pointsClubTier?.levelDescription);
        //Jira: CRM-9670 Start
        if(loyaltyTiersponse != null && loyaltyTiersponse.pointsClubTier.levelDescription != null && loyaltyTiersponse.pointsClubTier.levelDescription != '')
        {
            singleQffProfile.levelDescription = loyaltyTiersponse != null ? loyaltyTiersponse.pointsClubTier?.levelDescription : '';
            isChanged=true;
        }
        System.debug('>> print the level description'+singleQffProfile?.levelDescription);
        //Jira: CRM-9670 End

        //Program loyaltyProgramResponse Check
        if (loyaltyProgramResponse == NULL) {
            singleQffProfile.withProgramAPIException = true;
            //singleQffProfile.programAPIExceptionMsg = 'Unable to retrieve latest contact\'s Program information at this time.';
            singleQffProfile.programAPIExceptionMsg = 'Program Information';
        } else {
            Date programJoinDate = date.valueOf(loyaltyProgramResponse.enrolmentDate);
            singleQffProfile.memberSuspended = loyaltyProgramResponse.suspended;
            singleQffProfile.joinDateString = loyaltyProgramResponse.enrolmentDate;
            singleQffProfile.joinDate = programJoinDate;
            
            programWrapperList.add(loyaltyProgramResponse);
        }
        
        //Account loyaltyAccountResponse Check
        if (loyaltyAccountResponse == NULL) {
            singleQffProfile.withAccountAPIException = true;
            //singleQffProfile.accountAPIExceptionMsg = 'Unable to retrieve latest contact\'s Account information at this time.';
            singleQffProfile.accountAPIExceptionMsg = 'Account Information';
        } else {
            if(loyaltyAccountResponse.statusCredits!=null)
            {
                //CRM-7027 commented as part of field mapping
                //statusLifeTime = loyaltyAccountResponse.statusCredits.lifetime;
                if(loyaltyAccountResponse.statusCredits.total!=null)
                statusLifeTime = loyaltyAccountResponse.statusCredits.total;

                system.debug('>>> the value of statusLifeTime'+statusLifeTime);
            }
            
            pointBalance = loyaltyAccountResponse.pointBalance;
            singleQffProfile.statusLifeTimeInt = statusLifeTime;
            singleQffProfile.statusLifeTimeTotal = String.valueOf(statusLifeTime.format());
            singleQffProfile.pointsBalanceInt = pointBalance;
            singleQffProfile.pointsBalance = String.valueOf(pointBalance.format());
        }
        //TO-DO: Can we persist on first time creation? Check in existing Lookup Frequent Flyer feature
        
        //Loyalty Tier, Join Date Check
        System.debug('>>>Loyalty Tier Check');
        if (objCon != NULL) { //if existing contact
            if(objCon.QCC_TECH_Member_Tier_Downgrade_Date__c == null || objCon.QCC_TECH_Member_Tier_Downgrade_Date__c <= Date.today()){
                isUpdateTier = true;
            }
            
            if(programWrapperList != Null && programWrapperList.size()>0){
                system.debug('programWrapperList >>>> '+ programWrapperList);
                for(QCC_LoyaltyResponseWrapper.programs program: programWrapperList) {
                    system.debug('programWrapperList >>>> Loop');
                    if (loyaltyTiersponse != null && loyaltyTiersponse.qantasFrequentFlyerTier.effectiveTier =='CHAIRMANS_LOUNGE_PLATINUM_ONE' && isUpdateTier) {
                        //String formattedString = String.format('Chairman\'\'{0} {1}', new String[]{'s', 'Lounge Platinum One'});
                        singleQffProfile.qffTier = System.Label.QCC_CL_P1;
                        isChanged = true;
                        system.debug('programWrapperList >>>> Loop' + singleQffProfile.qffTier);
                    } else {
                        if(loyaltyTiersponse != null && program.programCode!='CL' && program.programCode=='QFF' && objCon.Frequent_Flyer_tier__c != CustomSettingsUtilities.getConfigDataMap(loyaltyTiersponse.qantasFrequentFlyerTier.effectiveTier) && isUpdateTier) {
                            String effectiveTier = loyaltyTiersponse.qantasFrequentFlyerTier.effectiveTier;
                            String tierDescription = loyaltyTiersponse.qantasFrequentFlyerTier.tierDescription;
                            System.debug('tierDescription===========> ' + tierDescription);
                            if (effectiveTier != null && (effectiveTier.equalsIgnoreCase('SILVER') || effectiveTier.equalsIgnoreCase('GOLD'))) {
                                if (tierDescription != null && (tierDescription.equals('Frequent Flyer Lifetime Gold') || tierDescription.equals('Frequent Flyer Lifetime Silver'))) {
                                    effectiveTier = 'LIFETIME_' + effectiveTier;   
                                }
                            }
                            singleQffProfile.qffTier = CustomSettingsUtilities.getConfigDataMap(effectiveTier);
                            isChanged = true;
                            system.debug('program.programCode!=CL' + singleQffProfile.qffTier);
                        }
                        
                        //Chairman's Lounge Functionality
                        //else if(program.programCode=='CL' && program.accountStatus=='ACTIVE' && isUpdateTier) {
                        else if (program.programCode != null && program.accountStatus != null 
                                && program.programCode.equals('CL') && program.accountStatus.equals('ACTIVE') && isUpdateTier) {
                            singleQffProfile.qffTier = System.Label.QCC_Chairmans_Lounge;
                            isChanged = true;
                            system.debug('program.programCode==CL && program.accountStatus==ACTIVE' + singleQffProfile.qffTier);
                        }
                        system.debug('Outside >>>> ' + singleQffProfile.qffTier);
                    }
                }
            }
            singleQffProfile.qffTierDisplay = objCon.Frequent_Flyer_Tier__c;
            system.debug('qff tier >>>>> ' + singleQffProfile.qffTier);
            
            
            if(loyaltyProgramResponse != null) {
                if(loyaltyProgramResponse.enrolmentDate != Null && objCon.Year_of_Joining__c != Date.valueOf(loyaltyProgramResponse.enrolmentDate) ||
                   objCon.QCC_Frequent_Flyer_Anniversary_Date__c != Date.valueOf(loyaltyProgramResponse.enrolmentDate)) {
                       singleQffProfile.joinDate = Date.valueOf(loyaltyProgramResponse.enrolmentDate);
                       //existing code today, but code above uses startDate (as was advised during discussion with Loyalty)

                       //singleQffProfile.tierAnniversaryDate = Date.valueOf(loyaltyProgramResponse.enrolmentDate); 
                       

                       isChanged = true;
                   }  
            }
            
            if(loyaltyAccountResponse != Null){
                if(objCon.Points_Balance__c != loyaltyAccountResponse.pointBalance){
                    singleQffProfile.pointsBalanceInt = pointBalance;
                    isChanged = true;
                }
                if(loyaltyAccountResponse.statusCredits != Null && objCon.Status_Credits__c != loyaltyAccountResponse.statusCredits.lifetime){
                    singleQffProfile.statusLifeTimeInt = statusLifeTime;
                    isChanged = true;
                }
            }
            
            String setting = 'SC-'+objCon.Frequent_Flyer_tier__c;
            //String setting = objCon.Frequent_Flyer_tier__c;
            system.debug('>>>setting: '+setting);
            /* Integer statusCredit = loyaltyResponse.statusCredits != Null && loyaltyResponse.statusCredits.lifetime != Null? loyaltyResponse.statusCredits.lifetime: 0;*/ /*CRM-5003*/
            
            //CRM-7027 commented as part of field mapping
            //Integer statusCredit = loyaltyAccountResponse.statusCredits != Null && loyaltyAccountResponse.statusCredits.lifetime != Null? loyaltyAccountResponse.statusCredits.lifetime: 0;
            
            Integer statusCredit;
            if(loyaltyAccountResponse!=null && loyaltyAccountResponse.statusCredits != Null && loyaltyAccountResponse.statusCredits.total != Null) 
            statusCredit=loyaltyAccountResponse.statusCredits.total;
            
            Integer nextLevel = String.isBlank(CustomSettingsUtilities.getConfigDataMap(setting))?statusCredit:Integer.valueOf(CustomSettingsUtilities.getConfigDataMap(setting));
            Integer remaining;
            if(nextLevel!=null && statusCredit!=null)
            remaining= nextLevel-statusCredit;

            system.debug('@@@ the value of next level'+nextLevel);
            system.debug('@@@ the value of statusCredit'+statusCredit);
            system.debug('@@@ the value of remaining'+remaining);
            system.debug('@@@ the value of objCon.QCC_Status_credits_till_next_Level__c'+objCon.QCC_Status_credits_till_next_Level__c);

            if(objCon!=null && remaining!=null && objCon.QCC_Status_credits_till_next_Level__c != remaining ){
                //objCon.QCC_Status_credits_till_next_Level__c = remaining;
                singleQffProfile.statusCreditsTillNextLevelInt = remaining;
                singleQffProfile.statusCreditsTillNextLevel = String.valueOf(remaining.format());
                isChanged = true;
            }
            else if(objCon!=null && remaining!=null && objCon.QCC_Status_credits_till_next_Level__c == remaining)
            {
                
                singleQffProfile.statusCreditsTillNextLevelInt = integer.valueof(objCon.QCC_Status_credits_till_next_Level__c);
                singleQffProfile.statusCreditsTillNextLevel = String.valueOf(objCon.QCC_Status_credits_till_next_Level__c.format());
            }
            
        }
        //***END - Loyalty Tier, Program, Account API***//
        
        singleQffProfile.isChanged = isChanged;
        system.debug('>>>singleQffProfile: ' + JSON.serializePretty(singleQffProfile));
        return singleQffProfile;
    }
    
    /************************************
* Purpose      : get contact information from Contact__c for lwc to launch the Create Case Flow
* Parameter    : record Id
* Returns      : contact ID and Frequent_Flyer_Number__c, first name, last name, email and phone, address coming from API
* Throws       :
* Expectations : 
************************************/
    public class ContactResult {
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String street;
        @AuraEnabled public String suburb;
        @AuraEnabled public String state;
        @AuraEnabled public String postcode;
        @AuraEnabled public String countryName;
        @AuraEnabled public Id contactId;
    }
    @AuraEnabled
    public static ContactResult getContactDetails(Id recordId){
        try {
            Contact contact = [SELECT Id, Frequent_Flyer_Number__c, FirstName, LastName, Email, Phone,CountryName__c,MailingState  FROM Contact WHERE Id = :recordId];
            
            //Return early if Frequent_Flyer_Number__c is empty
            if (String.isEmpty(contact.Frequent_Flyer_Number__c)) {
                ContactResult result = new ContactResult();
                result.firstName = contact.FirstName;
                result.lastName = contact.LastName;
                result.email = contact.Email;
                result.phone = contact.Phone;
                result.contactId = contact.Id;
                result.street = '';
                result.suburb = '';
                result.state = '';
                result.postcode = '';
                result.countryName = '';
                return result;
            }
            String loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyRawContact(contact.Frequent_Flyer_Number__c);
            
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(loyaltyContactResponse);
            System.debug('responseMap@@@@' + responseMap);
            System.debug('responseMap addresses@@@@' + JSON.serialize(responseMap.get('addresses')));
            List<Object> addressesObjs = (List<Object>)responseMap.get('addresses');
            System.debug('responseMap@@@@' + addressesObjs);
            ContactResult result = new ContactResult();
            result.firstName = contact.FirstName;
            result.lastName = contact.LastName;
            result.email = contact.Email;
            result.phone = contact.Phone;
            result.contactId = contact.Id;
            System.debug('result@@@@@' + result);
            for (Object addressObj : addressesObjs) {
                Map<String, Object> address = (Map<String, Object>) addressObj;
                if((Boolean)address.get('preferred') == true){
                    String lineOne = (String)address.get('lineOne');
                    String lineTwo = (String)address.get('lineTwo');
                    result.street = string.isEmpty(lineTwo) ? lineOne : lineOne + ' ' + lineTwo;
                    result.suburb = (String)address.get('suburb');
                    result.state = (String)address.get('state');
                    result.postcode = (String)address.get('postCode');
                    result.countryName = (String)address.get('countryName');
                    break;
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String convertToProperCase(String value) {
        String properCaseValue = value.toLowerCase();
        properCaseValue = properCaseValue.capitalize();
        return properCaseValue;
    }
    
}