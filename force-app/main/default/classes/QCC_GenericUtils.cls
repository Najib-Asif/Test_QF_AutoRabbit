/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   QCC Generic Utility Class 
Inputs:
Test Class:    QCC_GenericUtilsTest,QCC_PNRSearchControllerTest,QCC_CreatePassengerForEventsTest,QCC_SearchContactInfoControllerTest,QCC_FFProfileDetailsFlowHelperTest
************************************************************************************************
History
************************************************************************************************
24-Oct-2017     Praveen Sampath                 Initial Design
31-Oct-2017     Praveen Sampath                 getCAPValidToken
18-May-2018     Cuong Ly                        fetchSalesforceEmailTemplate
01-Oct-2019     Lora Mae Dapulang               Added line for GRAPHITE-932 & GRAPHITE-936 
05-Nov-2019     Leslie May Padilla              Added invocable method doNothing which can be used for Process Builders to issue a non-action step
23-Mar-2023     Leslie Padilla                  ADT-140: Updating current case creation logic across channels to ensure that "not null" Contact is attached 
                                                if 4pt ID is provided (FirstName, LastName, Email, Phone)
                                                Added new method getNonFFContactForCase
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QCC_GenericUtils {

    private static final String BU_OTHERS = CustomSettingsUtilities.getConfigDataMap('BusinessUnitOthers');
    public static Boolean isFromQAC = false;
    public static List<QantasConfigData__c> listDelayCode{get;set;}
    private static final Integer HOURS_TO_BE_ADDED_NONPROD = -1;
    private static final Integer HOURS_TO_BE_ADDED_PROD = -45;
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getCAPValidToken
    Description:        get CAP ValidToken from CAP system while invoking the Service
    Parameter:          tokenType
    --------------------------------------------------------------------------------------*/  
    public static String getCAPValidToken(String tokenType)
    {
        //CRM-5575 Automated token refresh for the loyalty subscription
        return getAPIGatewayValidToken(tokenType, false);
    }
        
    /*--------------------------------------------------------------------------------------      
    Method Name:        getCAPValidToken
    Description:        get CAP ValidToken from CAP system while invoking the Service, 
                        CRM-5575 Automated token refresh for the loyalty subscription
    Parameter:          tokenType, isTokenUpdated
    --------------------------------------------------------------------------------------*/  
    public static String getCAPValidToken(String tokenType, boolean isTokenUpdated){
        return getAPIGatewayValidToken(tokenType, isTokenUpdated);
    } 
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getAPIGatewayValidToken
    Description:        get Valid Token from API Gateway based on WSO2 system while invoking the Service
                        //CRM-5575 Automated token refresh for the loyalty subscription
    Parameter:          tokenType
    --------------------------------------------------------------------------------------*/  
    public static String getAPIGatewayValidToken(String tokenType)
    {
        return getAPIGatewayValidToken(tokenType, false);
    }
        
    /*--------------------------------------------------------------------------------------      
    Method Name:        getAPIGatewayValidToken
    Description:        get Valid Token from API Gateway based on WSO2 system while invoking the Service
    Parameter:          tokenType, isTokenUpdated
    --------------------------------------------------------------------------------------*/  
    public static String getAPIGatewayValidToken(String tokenType, boolean isTokenUpdated){
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI(tokenType);
        String tokenVal = '';        
        //CRM-5701 Identifying if it's a non prod environment for token refresh
        Integer hoursToBeAdded = 0;
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            hoursToBeAdded = HOURS_TO_BE_ADDED_NONPROD;            
        }else{
            hoursToBeAdded = HOURS_TO_BE_ADDED_PROD;
        }
        //CRM-5575 Automated token refresh for the loyalty subscription
        if(isTokenUpdated || qantasAPI.LastModifiedDate < System.now().addHours(hoursToBeAdded) || qantasAPI.Token__c == Null ){
            QCC_CAPTokenWrapper token;
            try {
                token = QCC_InvokeCAPAPI.invokeTokenAPIGateway(qantasAPI);  
            } catch(Exception e) {
            }
            
            if(token == null) return null;
            
            tokenVal = token.token_type+' '+token.access_token;
            tokenVal = tokenVal.capitalize();
            //QCC_GenericUtils.updateToken(tokenVal, tokenType);
        }
        else{
            tokenVal = qantasAPI.Token__c;
        }
        return tokenVal;
    } 
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchGenericContact
    Description:        get Contact that has a genereic email 
    Parameter:          
    --------------------------------------------------------------------------------------*/  
    public static String fetchGenericContact(){
        String email = CustomSettingsUtilities.getConfigDataMap('QCC_ContactEmail');
        String lastName = CustomSettingsUtilities.getConfigDataMap('QCC_NoReplyContactLastName');
        Contact objCon = [Select Id, Email from Contact where LastName =: lastName and Email =: email limit 1];
        
        if(objCon!=null)
        return objCOn.Id;
        else 
        return null;
        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateToken
    Description:        Update token if not matching with the current value in custom setting
    Parameter:          
    --------------------------------------------------------------------------------------*/
    /*Need to comment as the token will be same for all services that are having same Client Id, Client Secret, Endpoint and Scope
    public static void updateToken(String token, string settingName){
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI(settingName);
        
        if(qantasAPI.Token__c != token)
        {
            qantasAPI.Token__c = token;
            update qantasAPI;
        }
        
    }*/
    // Need to uncomment when the above method is commented
    public static void updateToken(String token, string settingName){
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI(settingName);
        
        if(qantasAPI.Token__c != token && String.isNotBlank(token))
        {
            List<Qantas_API__c> apisWithSameCredentialsToUpdate = new List<Qantas_API__c>();
            for(Qantas_API__c api : retrieveAPIsWithSameCredentials(qantasAPI)) {
                api.Token__c = token;
                apisWithSameCredentialsToUpdate.add(api);
            }
            if(apisWithSameCredentialsToUpdate != null && apisWithSameCredentialsToUpdate.size() > 0) {
                update apisWithSameCredentialsToUpdate;
            }            
        }
    }
    
    private static List<Qantas_API__c> retrieveAPIsWithSameCredentials(Qantas_API__c qantasAPI) {
        List<Qantas_API__c> allQantasAPIs = new List<Qantas_API__c>();
        allQantasAPIs = [SELECT Id, Name FROM Qantas_API__c WHERE ClientId__c = :qantasAPI.ClientId__c AND ClientSecret__c = :qantasAPI.ClientSecret__c AND EndPoint__c = :qantasAPI.EndPoint__c AND Scope__c = :qantasAPI.Scope__c];
        return allQantasAPIs;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        fetchContact
Description:        Fetch Contact Details
Parameter:          CaseWrapper
--------------------------------------------------------------------------------------*/ 
    // public static List<Contact> fetchContact(QCCCaseWrapper qccCaseWrap){
    //   List<Contact> lstCon = new List<Contact>();
    //   if(!String.isBlank(qccCaseWrap.capId)){
    //    lstCon = [Select Id, AccountId from Contact where CAP_ID__c   =: qccCaseWrap.capId];
    //    }else if(!String.isBlank(qccCaseWrap.ffNumber)){
    //        lstCon = [Select Id, AccountId from Contact where Frequent_Flyer_Number__c =: qccCaseWrap.ffNumber];
    //    }
    //    return lstCon;
    //}
    
    
    /*--------------------------------------------------------------------------------------      
Method Name:        mogrifyJSON
Description:        Json for Invoke CAP system
Parameter:          String,Map
--------------------------------------------------------------------------------------*/ 
    public static String mogrifyJSON(String data, Map<String, String> replacements) {
        // Regex to match the start of the line and the key
        // surrounded by quotes and ending with a colon
        String regexFormat = '(?m)^\\s*"{0}"\\s*:';
        
        // Replacement format of the new key surrounded by
        // quotes and ending with a colon
        String replacementFormat = '"{0}" :';
        
        // Since our JSON can come in formatted however the
        // endpoint wants, we need to format it to a standard
        // we know and can handle
        String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
        
        // Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            // Generate our regex based on the key
            String regex = String.format(
                regexFormat,
                new List<String> {key}
            );
            
            // Generate our replacement
            String replacement = String.format(
                replacementFormat,
                new List<String> {replacements.get(key)}
            );
            
            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
        
        return formattedJSON;
    }
    
    public static void postToCaseWithMention(Case caseIn , String content){
        try {
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            mentionSegmentInput.id = caseIn.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            textSegmentInput.text = content;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = caseIn.Id;
            
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
        } catch(Exception ex) {
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Case Trigger', 'QCC_GenericUtils', 
                                    'postToCaseWithMention', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
        
    }
    
    public static Datetime convertStringtoDateTime(String dateValue,String timeValue){
        String[] actualDepDateStr = String.isNotBlank(dateValue) ? (dateValue).replace('-', ' ').replace('/', ' ').split(' ') : null;
        String[] actualDepTimeStr = String.isNotBlank(timeValue) ? (timeValue).replace(':', ' ').split(' ') : null;
        Datetime dt = null;
        if(actualDepDateStr != null && actualDepTimeStr != null) {
            Integer dd = Integer.valueOf(actualDepDateStr[0]);
            Integer mm = Integer.valueOf(actualDepDateStr[1]);
            Integer yy = Integer.valueOf(actualDepDateStr[2]);
            Integer hh = Integer.valueOf(actualDepTimeStr[0]);
            Integer mi = Integer.valueOf(actualDepTimeStr[1]);
            Integer ss = Integer.valueOf(actualDepTimeStr[2]);
            dt = Datetime.newInstance(yy, mm, dd, hh, mi, ss);
        }
        return dt;
    }
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchSalesforceEmailTemplate
    Description:        get Id of Salesforce EmailTemplate 
    Parameter:          email template name
    --------------------------------------------------------------------------------------*/  
    public static String fetchSalesforceEmailTemplate(String emailTemplateName){
        List<EmailTemplate> emailTemplates = [Select Id from EmailTemplate where Name =: emailTemplateName limit 1];
        if(emailTemplates.size() > 0){
            return emailTemplates.get(0).Id;
        }else{
            return '';
        }
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        formatFlightNumber
    Description:        add '0' prefix to flight number to follow format xxxx 
    Parameter:          flight number
    --------------------------------------------------------------------------------------*/ 
    public static String formatFlightNumber(String flightNumber){
        Integer len = flightNumber.length();
        String formatString = '0000' + flightNumber;
        return formatString.right(4);
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchContactForNonFFCase
    Description:        Fetch the latest contact or create a new contact in case if the latest 
    Case Holds Morethan 10k Cases
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static Contact fetchContactForNonFFCase(){
        String recordtypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC_PlaceHolderAccRectype'));
        List<Contact> lstCon = [Select Id, AccountId, LastName from Contact where RecordTypeId =: recordtypeId Order By CreatedDate DESC limit 1]; 
        
        Integer caseCount = 0;
        Contact objCon = Null;
        if(lstCon != Null && lstCon.size()>0){
            objCon = lstCon[0];
            caseCount = [Select count() from Case where ContactId =: objCon.Id];
        }
        
        if(caseCount >= 10000 || lstCon == Null || lstCon.size() ==0){
            Integer count = (objCon != Null && objCon.LastName.remove('Null').isNumeric())?Integer.valueOf(objCon.LastName.remove('Null'))+1: 1;
            
            //Placeholder Account creation : JIRA# : CRM-6163
            Account objAcc = createPlaceholderAccount(count);
            
            //Null Contact creation 
            Contact objNewCon = new Contact();
            objNewCon.AccountId = objAcc.Id;
            objNewCon.LastName = 'Null'+count;
            objNewCon.Description = CustomSettingsUtilities.getConfigDataMap('QCC_GenericConDescription');
            objNewCon.RecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC_PlaceHolderAccRectype'));
            //CRM-9358
            objNewCon.Email = CustomSettingsUtilities.getConfigDataMap('QCC_ContactEmail');
            insert objNewCon;
            return objNewCon;
        }
        return objCon;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchContactForNonFFCases
    Description:        Fetch the latest contact or create a new contact if the  
                        contact Holds Morethan 10k Cases. Also, returns the case count.
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static ContactWrap fetchContactForNonFFCases(){
        String recordtypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC_PlaceHolderAccRectype'));
        List<Contact> lstCon = [Select Id, AccountId, LastName from Contact where RecordTypeId =: recordtypeId Order By CreatedDate DESC limit 1]; 
        ContactWrap conWrap = new ContactWrap();
        Integer caseCount = 0;
        Contact objCon = Null;
        if(lstCon != Null && lstCon.size()>0){
            objCon = lstCon[0];
            caseCount = [Select count() from Case where ContactId =: objCon.Id];
            conWrap.objCon = objCon;
            conWrap.count = caseCount;
        }
        
        if(caseCount >= 10000 || lstCon == Null || lstCon.size() ==0){
            Integer count = (objCon != Null && objCon.LastName.remove('Null').isNumeric())?Integer.valueOf(objCon.LastName.remove('Null'))+1: 1;
            
            //Placeholder Account creation : JIRA# : CRM-6163
            Account objAcc = createPlaceholderAccount(count);

            Contact objNewCon = new Contact();
            objNewCon.AccountId = objAcc.Id;
            objNewCon.LastName = 'Null'+count;
            objNewCon.Description = CustomSettingsUtilities.getConfigDataMap('QCC_GenericConDescription');
            objNewCon.RecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC_PlaceHolderAccRectype'));
            //CRM-9358
            objNewCon.Email = CustomSettingsUtilities.getConfigDataMap('QCC_ContactEmail');
            insert objNewCon;
            conWrap.objCon = objNewCon;
            conWrap.count = 0;
        }
        
        return conWrap;
    }
    
    public class ContactWrap{
        public Contact objCon;
        public Integer count;
    }

    public static Integer stringToInteger(string val){
        if(String.isBlank(val))
            return 0;
        while(val.startsWith('0')){
            val = val.removeStart('0');
        }
        return Integer.valueOf(val);
    }
    
    public Static Contact fetchContactForFFCase(QCC_ContactWrapper contactWrap){
        Contact objCon = new Contact();
        String ffNumber = contactWrap.ffNumber;
        String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');
        String ffNumWithLeadingZeros = '0%'+ffNumWithOutLeadingZeros;
        //GRAPHITE 932 - set RT to Individual Contact
        Id individualContactRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
        //CRM-7179
        //Commenting this Query as it has wrong params to search an existing contact CRM-7800
       // List<Contact> lstCon = [Select Id, Frequent_Flyer_Number__c, LastName, FirstName, Frequent_Flyer_Tier__c,Email, Phone, CAP_ID__c, AccountId
           //                    from Contact where lastName =:contactWrap.lastName AND FirstName =:contactWrap.firstName AND  (Frequent_Flyer_Number__c =: ffNumWithOutLeadingZeros or Frequent_Flyer_Number__c like :ffNumWithLeadingZeros) AND RecordTypeId =:individualContactRecTypeId ORDER BY CAP_ID__c NULLS LAST];
        //Replcaed Query to search an existing contact CRM-7800
        List<Contact> lstCon = [Select Id, Frequent_Flyer_Number__c, LastName, FirstName, Frequent_Flyer_Tier__c,Email, Phone, CAP_ID__c, AccountId
                               from Contact where (Frequent_Flyer_Number__c =: ffNumWithOutLeadingZeros or Frequent_Flyer_Number__c like :ffNumWithLeadingZeros) AND RecordTypeId =:individualContactRecTypeId ORDER BY CAP_ID__c NULLS LAST];
        objCon.Frequent_Flyer_Tier__c = CustomSettingsUtilities.getConfigDataMap(contactWrap.ffTier);
        objCon.CAP_ID__c = contactWrap.capId;
        objCon.RecordTypeId = individualContactRecTypeId;
        objCon.QCC_TECH_RecordType__c = CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact');
        if(lstCon != Null & !lstCon.isEmpty()) {
            if(lstCon.size() == 1) {
                objCon = lstCon[0];
            } else if(lstCon.size() > 1) {
                for(Contact con : lstCon) {
                    String ffReplaceZerosfromSearchList = con.Frequent_Flyer_Number__c.replaceFirst('^0+','');
                    if(ffNumWithOutLeadingZeros == ffReplaceZerosfromSearchList) {
                        objCon = con;
                        break;
                    }
                }
            }
        } else {
            objCon.FirstName = contactWrap.firstName;
            objCon.LastName = contactWrap.lastName;
            //CRM-7179
            objCon.Email = contactWrap.email;
            objCon.Phone = contactWrap.phone;
            objCon.Frequent_Flyer_Number__c = ffNumWithOutLeadingZeros;//contactWrap.ffNumber;
        }
        
        if(objCon != null) {
            upsert objCon;
        }
        return objCon;
    }
    
    public static String doTrim(String str) {
        return String.isNotBlank(str) ? str.trim() : str;
    }

    public static String getDelayReason(String delayCode, String shortDes){
        if(listDelayCode == null || listDelayCode.size()== 0 ){
            listDelayCode = [select name, Config_Description__c, Config_Value__c from QantasConfigData__c where Config_Description__c = 'DelayCode'];
        }
        for(QantasConfigData__c qcd : listDelayCode){
            if(qcd.name.contains(delayCode+'_'+shortDes)){
                return qcd.Config_Value__c.split(' - ')[0];
            }
        }
        return '';
    }
    
    public static String getIntegerFromString(String str){
        if(String.isNotBlank(str)){
            str = str.remove(':');
        }
           
        if(String.isNotBlank(str) && (str.isAlphanumeric() || str.isAlphanumericSpace())){
            Pattern ptr = Pattern.compile('[^0-9]');
            String intValue = ptr.matcher(str).replaceAll('');
            return intValue;
        }
        return null;
    }
    
    //GRAPHITE-934: As part of Data Migration, this method has been created to "do nothing" when the current user has the QCC_Bypass_Account_Contact_Case_Triggers permission       
    @InvocableMethod(label='Do Nothing' description = 'Used for redirecting a condition to do nothing and exit the process')        
    public static void doNothing() {}
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getNonFFContactForCase
    Description:        Fetch either NULL contact (RecordType = Placeholder) or Non FF Contact (RecordType = Individual)
    Parameter:          List<String> contactDetails - QCC_ContactWrapper sent either by CaseAPI via QCC_SearchContactAPI or CaseTrigger
                        String contactMappingSource - source reference field from custom metadata. If coming from CaseAPI: ContactWrapper_Field__c. If coming from CaseTrigger: Case_Field__c
    --------------------------------------------------------------------------------------*/ 
    public static Map<String,Contact> getNonFFContactForCase(List<String> contactDetails, String contactMappingSource){
        Contact finalContact = new Contact(); //output
        Map<String,String> contactFieldMapping = new Map<String,String>();
        Map<Integer,Map<String,Object>> contactInfoMap = new Map<Integer,Map<String,Object>>();
        Set<String> contactFieldKeys = new Set<String>();
        Map<String,Contact> uniqueContactsMap = new Map<String,Contact>();
        Map<String,Contact> existingContactsMap = new Map<String,Contact>();
        Map<String,Contact> newContactsMap = new Map<String,Contact>();
        Map<String,Contact> allContactsMap = new Map<String,Contact>();
        
        String duplicateRuleName = CustomSettingsUtilities.getConfigDataMap('QCC Non FF Contact Duplicate Rule Name');
        Id b2cRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));    //Individual Contact RTid 
        //String individualRecordTypeName = String.valueOf(Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosById().get(b2cRecTypeId).getName());
        String individualRecordTypeName = String.valueOf(Contact.sObjectType.getDescribe().getRecordTypeInfosById().get(b2cRecTypeId).getName());
        //Get active duplicate rule
        List<DuplicateRule> dupeRules = new List<DuplicateRule>([SELECT Id, DeveloperName, IsActive FROM DuplicateRule where DeveloperName =: duplicateRuleName AND IsActive = TRUE LIMIT 1]);
        
        //If duplicate rule is active, then Non FF Contact creation process will take place
        if (!dupeRules.isEmpty()) {
            //Loop through the list of contactDetails (QCC_ContactWrapper)
            Integer count = 1;
            for (String con : contactDetails) {
                Map<String,Object> contactAttributes = (Map<String,Object>)JSON.deserializeUntyped(con);
                contactInfoMap.put(count, contactAttributes);
                count = count + 1;
            }
            //Get source field to contact field map
            for (QCC_Non_FF_Case_Contact_Mapping__mdt fieldMap : [SELECT Case_Field__c, Contact_Field__c, ContactWrapper_Field__c, Compound_Field__c FROM QCC_Non_FF_Case_Contact_Mapping__mdt ORDER BY MasterLabel]) {
                contactFieldMapping.put(fieldMap.Contact_Field__c, String.valueOf(fieldMap.get(contactMappingSource)));
                String fieldKey = (String.IsNotBlank(fieldMap.Compound_Field__c)) ? fieldMap.Compound_Field__c : fieldMap.Contact_Field__c;
                contactFieldKeys.add(fieldKey);
            }
            string reqPhoneNumber = '';
            string reqFirstName = '';
            string reqLastName = '';
            string reqEmail = '';
            //Loop through the contact details
            for (Integer key : contactInfoMap.keySet()) {
                Map<String,Object> contactInfoFields = contactInfoMap.get(key);
                Boolean missingInfo = false;
                String contactKey = '';
                Contact nonFFContact = new Contact();
                //Default contact field values
                nonFFContact.RecordTypeId = b2cRecTypeId;
                nonFFContact.QCC_TECH_RecordType__c = individualRecordTypeName;
                
                //Get case field to contact field map
                for (String conKeyField : contactFieldMapping.keySet()) {
                    String referenceField = contactFieldMapping.get(conKeyField);
                    if (contactInfoFields.containsKey(referenceField)) {
                        String contactInfoValue = String.valueOf(contactInfoFields.get(referenceField));
                        if (String.isNotBlank(contactInfoValue)) {
                            if(referenceField == 'phone') {
                                reqPhoneNumber = contactInfoValue;
                            }
                            if(referenceField == 'firstName') {
                                reqFirstName = contactInfoValue;
                            }
                            if(referenceField == 'lastName') {
                                reqLastName = contactInfoValue;
                            }
                            if(referenceField == 'email') {
                                reqEmail = contactInfoValue;
                            }
                            nonFFContact.put(conKeyField, contactInfoValue);
                            contactKey = contactKey + contactInfoValue;
                        } else {
                            missingInfo = true;
                        }
                        
                    } else {
                        missingInfo = true;
                    }
                }
                
                if (!missingInfo) {
                    contactKey = contactKey.deleteWhitespace();
                    uniqueContactsMap.put(contactKey, nonFFContact);
                }
            }
            if (!uniqueContactsMap.isEmpty()) {
                //Find duplicates
                existingContactsMap = getExistingContactMatches (uniqueContactsMap.values(), contactFieldKeys, duplicateRuleName);
                allContactsMap.putAll(existingContactsMap);
                String reqPhoneNumberFormat = '';
                //Collect new contacts to be created
                
                for (String conKey : uniqueContactsMap.keySet()) {
                    if (conKey.toLowerCase() != null && !existingContactsMap.containsKey(conKey.toLowerCase())) { // check against existing matching contacts
                        newContactsMap.put(conKey, uniqueContactsMap.get(conKey));
                    } 
                }
                if (!newContactsMap.isEmpty()) {
                    // check phone number with last 9 digit
                    //Check to correct the format of the phone number
                    //INC2864341: Adding phone Number length check.
                    if(reqPhoneNumber!=null && reqPhoneNumber!= '' && reqPhoneNumber != '131313' && reqPhoneNumber.length() > 4) {
                        reqPhoneNumberFormat = QCC_VoiceUtils.checkIfValidPhone(reqPhoneNumber);

                        List<Contact> findDuplicateContactwithPhone = new List<Contact>();
                        if(reqPhoneNumberFormat!=null && reqPhoneNumberFormat!= '') {
                            String reqPhoneNoFormat = '%'+reqPhoneNumberFormat.right(9);
                            findDuplicateContactwithPhone = [SELECT Id, FirstName, LastName, Name, Email, Phone FROM Contact 
                                                                            WHERE FirstName =:reqFirstName AND LastName =:reqLastName AND Email =:reqEmail AND Phone Like:reqPhoneNoFormat];
                        }
                        if(findDuplicateContactwithPhone != null && !findDuplicateContactwithPhone.isEmpty()) {
                            allContactsMap.putAll(findDuplicateContactwithPhone);
                        } else {
                            insert newContactsMap.values();
                        }
                        allContactsMap.putAll(newContactsMap);
                    } 
                } 
            }
            
        }
        return allContactsMap;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getNonFFContactForAffectedPassengers
    Description:        Fetch Non FF Contact (RecordType = Individual)
    Parameter:          List<String> contactDetails - QCC_ContactWrapper sent either by CaseAPI via QCC_CreatePassengerForEvents
                        String contactMappingSource - source reference field from custom metadata. If coming from CaseAPI: ContactWrapper_Field__c. If coming from CaseTrigger: Case_Field__c
    --------------------------------------------------------------------------------------*/ 
    public static Map<String,Contact> getNonFFContactForAffectedPassengers(List<String> contactDetails, String contactMappingSource){
        Map<Integer,Map<String,Object>> contactInfoMap = new Map<Integer,Map<String,Object>>();
        Map<String,String> contactFieldMapping = new Map<String,String>();
        Map<String,Contact> newContactsMap = new Map<String,Contact>();
        Map<String,Contact> allContactsMap = new Map<String,Contact>();
        Set<String> contactFieldKeys = new Set<String>();
        
        String duplicateRuleName = CustomSettingsUtilities.getConfigDataMap('QCC Non FF Contact Duplicate Rule Name');
        Id b2cRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));    //Individual Contact RTid 
        String individualRecordTypeName = String.valueOf(Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosById().get(b2cRecTypeId).getName());
        
        //Get active duplicate rule
        List<DuplicateRule> dupeRules = new List<DuplicateRule>([SELECT Id, DeveloperName, IsActive FROM DuplicateRule where DeveloperName =: duplicateRuleName AND IsActive = TRUE LIMIT 1]);
        
        //If duplicate rule is active, then Non FF Contact creation process will take place
        if (!dupeRules.isEmpty()) {
            //Loop through the list of contactDetails (QCC_ContactWrapper)

            for (QCC_Non_FF_Case_Contact_Mapping__mdt fieldMap : [SELECT Case_Field__c, Contact_Field__c, ContactWrapper_Field__c, Compound_Field__c FROM QCC_Non_FF_Case_Contact_Mapping__mdt ORDER BY MasterLabel]) {
                contactFieldMapping.put(fieldMap.Contact_Field__c, String.valueOf(fieldMap.get(contactMappingSource)));
                String fieldKey = (String.IsNotBlank(fieldMap.Compound_Field__c)) ? fieldMap.Compound_Field__c : fieldMap.Contact_Field__c;
                contactFieldKeys.add(fieldKey);
            }

            //Loop through the contact details
            for (String con : contactDetails) {
                Map<String,Object> contactInfoFields = (Map<String,Object>)JSON.deserializeUntyped(con);
                Boolean missingInfo = false;
                String contactKey = '';
                Contact nonFFContact = new Contact();
                //Default contact field values
                nonFFContact.RecordTypeId = b2cRecTypeId;
                nonFFContact.QCC_TECH_RecordType__c = individualRecordTypeName;
                
                //Get case field to contact field map
                for (String conKeyField : contactFieldMapping.keySet()) {
                    String referenceField = contactFieldMapping.get(conKeyField);
                    if (contactInfoFields.containsKey(referenceField)) {
                        String contactInfoValue = String.valueOf(contactInfoFields.get(referenceField));
                        if (String.isNotBlank(contactInfoValue)) {
                            nonFFContact.put(conKeyField, contactInfoValue);
                            contactKey = contactKey + contactInfoValue;
                        } else {
                            missingInfo = true;
                        }
                        
                    } else {
                        missingInfo = true;
                    }
                }
                
                if (!missingInfo) {
                    contactKey = contactKey.deleteWhitespace().toLowerCase();
                    allContactsMap.put(contactKey, nonFFContact);
                }
            }
            if (!allContactsMap.isEmpty()) {
                //Find duplicates
                Map<String,Contact> existingContactsMap = getExistingContactMatches (allContactsMap.values(), contactFieldKeys, duplicateRuleName);
                allContactsMap.putAll(existingContactsMap);
                String reqPhoneNumberFormat = '';
                //Collect new contacts to be created

                Set<string> reqPhoneNumber = new Set<String>();
                Set<string> reqFirstName = new Set<String>();
                Set<string> reqLastName = new Set<String>();
                Set<string> reqEmail = new Set<String>();
                
                for (String conKey : allContactsMap.keySet()) {
                    if (conKey != null && !existingContactsMap.containsKey(conKey)) { // check against existing matching contacts
                        Contact x = allContactsMap.get(conKey);

                        String val = String.valueOf(x?.Phone);
                        if(String.isNotBlank(val) && val != '131313'&& val.length() > 4) { 
                            val = QCC_VoiceUtils.checkIfValidPhone(val);
                            val = '%'+val.right(9);
                            reqPhoneNumber.add(val); 
                        } else {
                            continue;
                        }

                        val = String.valueOf(x?.FirstName);
                        if(String.isNotBlank(val)) { reqFirstName.add(val); }

                        val = String.valueOf(x?.LastName);
                        if(String.isNotBlank(val)) { reqLastName.add(val); }

                        val = String.valueOf(x?.Email);
                        if(String.isNotBlank(val)) { reqEmail.add(val); }

                        newContactsMap.put(conKey, allContactsMap.get(conKey));
                        
                    } 
                }
                if (!newContactsMap.isEmpty()) {
                    // check phone number with last 9 digit
                    //Check to correct the format of the phone number

                    List<Contact> findDuplicateContactwithPhone = [SELECT Id, FirstName, LastName, Name, Email, Phone FROM Contact 
                                                                    WHERE FirstName in :reqFirstName AND LastName in :reqLastName AND Email in:reqEmail AND Phone Like:reqPhoneNumber];
                    for (Contact x : findDuplicateContactwithPhone) {
                        String contactKey = '';
                        for (String field : contactFieldMapping.keySet()) {
                            String val = String.valueOf(x.get(field));
                            contactKey = contactKey + val;
                        }
                        if (newContactsMap.containsKey(contactKey)) {
                            allContactsMap.put(contactKey,x);
                            newContactsMap.remove(contactKey);
                        }
                    }
                    if(!newContactsMap.isEmpty()) {
                        insert newContactsMap.values();
                        allContactsMap.putAll(newContactsMap);
                    }
                } 
            }
            
        }
        return allContactsMap;
    }
    
    //ADT-140: Retrieve contact matches based on unique combination of contact fields
    public static Map<String,Contact> getExistingContactMatches(List<Contact> contacts, Set<String> contactFieldsToMatch, String duplicaterule) {
        Map<String,Contact> existingContactsMap = new Map<String,Contact>();
        Set<Id> matchingContactIds = new Set<Id>();
        
        //Find duplicates
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(contacts);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                if (dupeResult.duplicaterule == duplicaterule) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        if (!matchResult.getMatchRecords().isEmpty()) { //if match found
                            for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                                Contact existingCon = (Contact)matchRecord.getRecord();
                                String contactKey = '';
                                for (String field : contactFieldsToMatch) {
                                    contactKey = contactKey + String.valueOf(matchRecord.getRecord().get(field));
                                }
                                contactKey = contactKey.deleteWhitespace();
                                contactKey = contactKey.toLowerCase(); //Fix to address case-sensitivity when using map key to match
                                existingContactsMap.put(contactKey, existingCon);
                            }
                        }
                        
                    }
                    break;
                }
                
            }
        }
        
        return existingContactsMap;
    }
    public static Account createPlaceholderAccount(Integer count)
    {
        Account objAcc = new Account(Name='null Null'+count, Type='Person Account');
        objAcc.RecordTypeId = GenericUtils.getObjectRecordTypeId('Account', 'Person Account');
        insert objAcc;
        return objAcc;
    }
    
    /*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        mapBUnitToContactRecordTypes
    Description:        To map business unit and record type ids based on values in metatada. 
                        If no business unit value is present then corresponding record type are mapped to Others business unit.
    Returned Value:     A Map with business unit as key and a map containing record type developer name and id as key-value pair.     
---------------------------------------------------------------------------------------------------------------------------------------*/    
public static Map<String, Map<String, Id>> mapBUnitToContactRecordTypes() {
    Map<String, String> apiNamesBUMap = new Map<String, String>();
    Map<String, Map<String, Id>> buToRecTypeMap = new Map<String, Map<String, Id>>();
    String businessUnit;
    try {
        /*for (Contacts_Record_Type_List__mdt mdtRecord : Contacts_Record_Type_List__mdt.getAll().values()) {
            if (String.isBlank(mdtRecord.Business_Unit__c)) {
                apiNamesBUMap.put(mdtRecord.DeveloperName, null);
            } else {
                apiNamesBUMap.put(mdtRecord.DeveloperName, mdtRecord.Business_Unit__c);
            }
        }
        if (!apiNamesBUMap.isEmpty()) {
            for (RecordType recType : [ SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Contact' AND IsActive=TRUE ]) {
                businessUnit = apiNamesBUMap.get(recType.DeveloperName);
                if (businessUnit == null) {
                    businessUnit = BU_OTHERS;
                }
                if (buToRecTypeMap.get(businessUnit) == null) {
                    buToRecTypeMap.put(businessUnit, new Map<String, Id>{recType.DeveloperName => recType.Id});
                } else {
                    buToRecTypeMap.get(businessUnit).put(recType.DeveloperName, recType.Id);
                }
            }
        }*/
    } catch (Exception ex) {
        CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'QCC_GenericUtils', 'mapBUnitToContactRecordTypes', '', '', false, '', ex);
    }
    return buToRecTypeMap;
    } 
    
    /*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        getStateCodeByStateName
    Description:        This Method will return state ISO code, from the state name. INC2836704: CRM-9880
    Returned Value:     string stateCode.     
---------------------------------------------------------------------------------------------------------------------------------------*/   
    public static String getStateCodeByStateName(String stateName) {
        String stateISOCode = stateName;
        try {
            Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
            List<Schema.PicklistEntry> stateCodeList = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry stateCode : stateCodeList){
                if (stateName != NULL && (stateCode.getLabel().equalsIgnoreCase(stateName.trim())
                                         || stateCode.getValue().equalsIgnoreCase(stateName.trim()))) {
                    stateISOCode = stateCode.getValue();
                    break;
                }

            }

        } catch (Exception ex) {
        CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'QCC_GenericUtils', 'getStateCodeByStateName', '', '', false, '', ex);
        }
        return stateISOCode;
    }
}