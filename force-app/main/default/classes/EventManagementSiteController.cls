public without sharing class EventManagementSiteController {

    private static final String TOKEN_PARAMS_DELIMITER = '_';
    private static final String ATTRIBUTE_CN = 'campaignName'; // Param 0
    private static final String ATTRIBUTE_CMN = 'campaignMemberName'; // Param 1
    private static final String ATTRIBUTE_CMI = 'campaignMemberId'; // Param 2
    //private static final String ATTRIBUTE_FRD = 'finalRSVPDate'; // Param 3
    private static final String ATTRIBUTE_IE = 'isExpired'; 
    private static final String ATTRIBUTE_IV = 'isValid';
    private static final String ATTRIBUTE_IR = 'isResponded';
    private static final String RESPONSE_ACCEPT = 'accept';
    private static final String RESPONSE_REJECT = 'reject';
    private static final String MESSAGE_ACCEPT = 'Thank you, {0}, for accepting the ticket. We hope you enjoy the event.';
    private static final String MESSAGE_REJECT = 'We appreciate you letting us know, {0}, We\'re sorry you won\'t be able to attend. We hope to see you at a future event.';
    private static final String MESSAGE_INVALID = 'We\'re sorry, but an error occurred during your registration. To resolve this, please click the registration link within the email again.';
    
    public static Map<String, String> createTokenMap(String token){
        Map<String, String> tokenMap = new Map<String, String>{ ATTRIBUTE_IV => String.valueOf(false) };
        String[] tokenParameters = decodeToken(token);
        if (tokenParameters == null || tokenParameters.size() != 4) {
            return tokenMap;
        }
        tokenMap.put(ATTRIBUTE_CN, tokenParameters[0]);
        tokenMap.put(ATTRIBUTE_CMN, tokenParameters[1]);
        tokenMap.put(ATTRIBUTE_CMI, tokenParameters[2]);
        tokenMap.put(ATTRIBUTE_IE, String.valueOf(hasTokenExpired(tokenParameters[3])));
        tokenMap.put(ATTRIBUTE_IV, String.valueOf(true));
        return tokenMap;
    }
    
    public static boolean hasTokenExpired(String dateString) { 
        try {
            Date dateFromString = Date.valueOf(dateString);
            Date todaysDate = System.today();
            if (todaysDate.daysBetween(dateFromString) >= 0) {
                return false;
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage()); 
        }
        return true;
    }

    public static String[] decodeToken(String token) {
        String[] tokenParams;
        try {
            token = EncodingUtil.urlDecode(token, 'UTF-8');
            token = EncodingUtil.base64Decode(token).toString();
            return token.split(TOKEN_PARAMS_DELIMITER);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        return tokenParams;
    }

    @AuraEnabled
    public static Map<String, String> getInitialData(String token) {
        Map<String, String> tokenMap = createTokenMap(token);
        Map<String, String> dataMap = new Map<String, String>();
        dataMap.put(ATTRIBUTE_CN, tokenMap.get(ATTRIBUTE_CN));
        dataMap.put(ATTRIBUTE_CMN, tokenMap.get(ATTRIBUTE_CMN));
        dataMap.put(ATTRIBUTE_IE, tokenMap.get(ATTRIBUTE_IE));
        dataMap.put(ATTRIBUTE_IV, tokenMap.get(ATTRIBUTE_IV));
        dataMap.put(ATTRIBUTE_IR, isResponded(token));
        return dataMap;
    }

    public static String isResponded(String token) {
        try {
            Event_Response__c eRecord = [ SELECT Token__c FROM Event_Response__c WHERE Token__c = :token LIMIT 1 ];
            if (eRecord != null) {
                return 'true';
            }
        } catch (Exception ex) {
            System.debug('Exception occurred - isResponded - '+ex.getMessage());
        }
        return 'false';
    }

    @AuraEnabled
    public static Boolean createEventResponse(String token, String responseValue) {
        try {
            Map<String, String> tokenMap = createTokenMap(token);
            String campaignMemberId = tokenMap.get(ATTRIBUTE_CMI);
            String eventResponseStatus;
            if (RESPONSE_ACCEPT.equals(responseValue)) {
                eventResponseStatus = 'Accepted';
            } else if (RESPONSE_REJECT.equals(responseValue)) {
                eventResponseStatus = 'Declined';
            }
            if (Boolean.valueOf(tokenMap.get(ATTRIBUTE_IV)) && !Boolean.valueOf(tokenMap.get(ATTRIBUTE_IE))
                && String.isNotBlank(campaignMemberId) && String.isNotBlank(eventResponseStatus)
                && Schema.sObjectType.Event_Response__c.fields.Campaign_Member_Id__c.isCreateable() 
                && Schema.sObjectType.Event_Response__c.fields.Status__c.isCreateable())
            {
                Event_Response__c eRObj = new Event_Response__c();
                eRObj.Campaign_Member_Id__c = campaignMemberId;
                eRObj.Status__c = eventResponseStatus;
                eRObj.Token__c = token;
                insert eRObj;
                return true;
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        return false;
    }
}