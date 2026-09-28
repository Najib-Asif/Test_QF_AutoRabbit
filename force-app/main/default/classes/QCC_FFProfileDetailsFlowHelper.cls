/*----------------------------------------------------------------------------------------------------------------------
Author:        Leslie Padilla
Company:       Accenture
Description:   Helper Class for Screen Flow QCC Frequent Flyer Profile Details
Inputs:
Test Class:     QCC_FFProfileDetailsFlowHelperTest
************************************************************************************************
History
************************************************************************************************
07-Apr-2023      Leslie Padilla                   ADT-92 Initial Creation
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_FFProfileDetailsFlowHelper {
    @InvocableMethod(callout=true)
    public static List<FlowOutputs> invokeThisMethod(List<FlowInputs> request) {
        List<FlowOutputs> results;
        if (request[0].methodName == 'getFullFrequentFlyerDetails') {
            results = getFullFrequentFlyerDetails(request);
        }
        
        if (request[0].methodName == 'getNewFrequentFlyerDetails') {
            results = getNewFrequentFlyerDetails(request);
        }
        
        return results;
    }
    
    //input details that comes to apex from flow
    public class FlowInputs{
        @InvocableVariable
        public String methodName;
        
        @InvocableVariable
        public Contact contactRecord;
        
        @InvocableVariable
        public String ffNumber;
    }
    
    //output details which goes from apex to flow
    public class FlowOutputs{
        @InvocableVariable
        public QCC_FrequentFlyerProfileDetailsWrapper ffDetails;
        
        @InvocableVariable
        public Boolean forUpdate;
        
        @InvocableVariable
        public String errorMessage;
    }
    
    public static List<FlowOutputs> getNewFrequentFlyerDetails(List<FlowInputs> requests) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowInputs request = requests[0];
        FlowOutputs result = new FlowOutputs();
        String ffNumber = requests[0].ffNumber;
        QCC_FrequentFlyerProfileDetailsWrapper newFFDetails = new QCC_FrequentFlyerProfileDetailsWrapper();
        
        newFFDetails = QCC_FrequentFlyerProfileDetails.getFFProfileAndContactDetails(ffNumber, newFFDetails);
        result.ffDetails = newFFDetails;
        //Collect error messages
        String errorMessage = collectErrorMessages(newFFDetails);
        if (String.isNotBlank(errorMessage)) {
            result.errorMessage = errorMessage;
        }
        
        results.add(result); 
        return results;

    }
    
    public static List<FlowOutputs> getFullFrequentFlyerDetails(List<FlowInputs> requests) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowInputs request = requests[0];
        FlowOutputs result = new FlowOutputs();
        Contact contactRecord = requests[0].contactRecord;
        String ffNumber = requests[0].ffNumber;
        Boolean forUpdate = false;
        
        
        //Call Loyalty API
        QCC_FrequentFlyerProfileDetailsWrapper latestFFDetails = QCC_FrequentFlyerProfileDetails.getFFDetails(ffNumber, contactRecord);
        //Retain already persisted fields if no latest info are is retrieved
        Boolean persistedFieldsChanged = persistedFieldsChanged(latestFFDetails, contactRecord);
        latestFFDetails.firstName = (latestFFDetails.firstName != NULL) ? latestFFDetails.firstName : contactRecord.FirstName;
        latestFFDetails.lastName = (latestFFDetails.lastName != NULL) ? latestFFDetails.lastName : contactRecord.LastName;
        latestFFDetails.email = (latestFFDetails.email != NULL) ? latestFFDetails.email : contactRecord.Email;
        latestFFDetails.phoneNumber = (latestFFDetails.phoneNumber != NULL) ? latestFFDetails.phoneNumber : contactRecord.Phone;
        latestFFDetails.qffTier = (latestFFDetails.qffTier != NULL) ? latestFFDetails.qffTier : contactRecord.Frequent_Flyer_Tier__c;
        latestFFDetails.joinDate = (latestFFDetails.joinDate != NULL) ? latestFFDetails.joinDate : contactRecord.Year_of_Joining__c;
        latestFFDetails.tierAnniversaryDate = (latestFFDetails.tierAnniversaryDate != NULL) ? latestFFDetails.tierAnniversaryDate : contactRecord.QCC_Frequent_Flyer_Anniversary_Date__c;
        latestFFDetails.pointsBalanceInt = (latestFFDetails.pointsBalanceInt != NULL) ? latestFFDetails.pointsBalanceInt : Integer.valueOf(contactRecord.Points_Balance__c);
        latestFFDetails.statusLifeTimeInt = (latestFFDetails.statusLifeTimeInt != NULL) ? latestFFDetails.statusLifeTimeInt : Integer.valueOf(contactRecord.Status_Credits__c);
        
        //INC2836704: CRM-9880
        latestFFDetails.countryName = (latestFFDetails.countryName != NULL) ? latestFFDetails.countryName : contactRecord.CountryName__c;
        if (latestFFDetails.countryName != NULL && latestFFDetails.countryName.equalsIgnoreCase('Australia') ) {
            latestFFDetails.state = (latestFFDetails.state != NULL) ? latestFFDetails.state : contactRecord.MailingState;
        } else {
            latestFFDetails.state = QCC_GenericUtils.getStateCodeByStateName(latestFFDetails.state);
            if (latestFFDetails.state == NULL || String.isEmpty(latestFFDetails.state)) {
                latestFFDetails.state =  contactRecord.MailingState;
            }
        }

        result.ffDetails = latestFFDetails;
        result.forUpdate = persistedFieldsChanged || latestFFDetails.isChanged;
        
        //Collect error messages
        String errorMessage = collectErrorMessages(latestFFDetails);
        if (String.isNotBlank(errorMessage)) {
            result.errorMessage = errorMessage;
        }
        // Update Token
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        
        results.add(result); 
        return results;
    }
    
    public static String collectErrorMessages(QCC_FrequentFlyerProfileDetailsWrapper latestFFDetails) {
        String errorMessage = '';
        //Collect error messages
        if (latestFFDetails.withContactAPIException) {
            errorMessage = (String.isBlank(errorMessage)) ? latestFFDetails.contactAPIExceptionMsg : errorMessage + '<br>' + latestFFDetails.contactAPIExceptionMsg;
        }
        
        if (latestFFDetails.withProfileAPIException) {
            errorMessage = (String.isBlank(errorMessage)) ? latestFFDetails.profileAPIExceptionMsg : errorMessage + '<br>' + latestFFDetails.profileAPIExceptionMsg;
        }
        
        if (latestFFDetails.withTierAPIException) {
            errorMessage = (String.isBlank(errorMessage)) ? latestFFDetails.tierAPIExceptionMsg : errorMessage + '<br>' + latestFFDetails.tierAPIExceptionMsg;
        }
        
        if (latestFFDetails.withProgramAPIException) {
            errorMessage = (String.isBlank(errorMessage)) ? latestFFDetails.programAPIExceptionMsg : errorMessage + '<br>' + latestFFDetails.programAPIExceptionMsg;
        }
        
        if (latestFFDetails.withAccountAPIException) {
            errorMessage = (String.isBlank(errorMessage)) ? latestFFDetails.accountAPIExceptionMsg : errorMessage + '<br>' + latestFFDetails.accountAPIExceptionMsg;
        }
        return errorMessage;
    }
    
    public static Boolean persistedFieldsChanged (QCC_FrequentFlyerProfileDetailsWrapper latestFFDetails, Contact contactRecord) {
        Boolean valuesUpdated = false;
        if (latestFFDetails.firstName != NULL && latestFFDetails.firstName != contactRecord.FirstName) {
            valuesUpdated = true;
        }
        
        if (latestFFDetails.lastName != NULL && latestFFDetails.lastName != contactRecord.LastName) {
            valuesUpdated = true;
        }
        
        if (latestFFDetails.email != NULL && latestFFDetails.email != contactRecord.Email) {
            valuesUpdated = true;
        }
        
        if (latestFFDetails.phoneNumber != NULL && latestFFDetails.phoneNumber != contactRecord.Phone) {
            valuesUpdated = true;
        }
        
        if (latestFFDetails.state != NULL && latestFFDetails.state != contactRecord.MailingState) {
            valuesUpdated = true;
        }
        
        if (latestFFDetails.countryName != NULL && latestFFDetails.countryName != contactRecord.CountryName__c) {
            valuesUpdated = true;
        }
		
        
        if (latestFFDetails.tierAnniversaryDate != NULL && latestFFDetails.tierAnniversaryDate != contactRecord.QCC_Frequent_Flyer_Anniversary_Date__c) {
            valuesUpdated = true;
        }
        
        return valuesUpdated;
    }

}