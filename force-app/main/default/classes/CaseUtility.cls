public class CaseUtility {
    // FINAL VARIABLES
    private static final String BU_OTHERS = CustomSettingsUtilities.getConfigDataMap('BusinessUnitOthers');
    private static final Integer UATPCARDLENGTH = 15;
    private static final Integer CREDITCARDLENGTH = 16;
    public static Map<String,Schema.RecordTypeInfo> caseRecTypeMap =  Schema.SObjectType.Case.getRecordTypeInfosByName();
    public static final List<RecordType> caseActiveRecordTypeList=[SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Case' AND isActive = true];

    public static Map<String,String> caseRecordType() {
        Map<String,String> caseRecordTypes = new Map<String,String>();
        for(RecordType listofRType: caseActiveRecordTypeList)
                caseRecordTypes.put(listofRType.Id, listofRType.DeveloperName);

        return caseRecordTypes;
    }
    public static Set<String> mapQCCRecordTypes() {
        Set<String> mapQCCRecordTypes = new Set<String>();
        for(QCC_Case_Record_Types__mdt qcc: [Select MasterLabel From QCC_Case_Record_Types__mdt]){
            mapQCCRecordTypes.add(qcc.MasterLabel);
        }
        return mapQCCRecordTypes;
    }
    /*
    public static Map<String, Set<String>> mapQCCRecordTypes() {
        Set<String> mapQCCRecordTypes = new Set<String>();
        for(QCC_Case_Record_Types__mdt qcc: [Select MasterLabel, Business_Unit__c From QCC_Case_Record_Types__mdt]){
            mapQCCRecordTypes.add(qcc.Business_Unit__c, qcc.MasterLabel);
            if(mapQCCRecordTypes.containsKey(qcc.Business_Unit__c)){
                mapQCCRecordTypes.get(qcc.Business_Unit__c).add(qcc.MasterLabel);
            }else{
                mapQCCRecordTypes.put(qcc.Business_Unit__c, new Set<String>{qcc.MasterLabel});
            }
        }
        return mapQCCRecordTypes; 
    }*/
    public static Id caseRecordTypeId(String rName) {
        Id caseRecId = caseRecTypeMap.get(rName).getRecordTypeId();
        return caseRecId;
    }

/*--------------------------------------------------------------------------------------      
Method Name:        getRecordTypeIdByDevName
Description:        To fetch record type id based on the developer name of the record type.
					NULL is returned, if no such record type is found.
Parameter:          Developer name of the record type
Returned Value:     Id of the record type
--------------------------------------------------------------------------------------*/    
    public static Id getRecordTypeIdByDevName(String developerName) {
        Schema.RecordTypeInfo recordTypeInfo;
        if(developerName != NULL) {
            recordTypeInfo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName);
            if (recordTypeInfo != NULL) {
                return recordTypeInfo.getRecordTypeId();
            }
        }
        return NULL;
    }
/*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        mapBUnitToCaseRecordTypes
    Description:        To map business unit and record type ids based on values in metatada. 
                        If no business unit value is present then corresponding record type are mapped to Others business unit.
    Returned Value:     A Map with business unit as key and a map containing record type developer name and id as key-value pair.     
---------------------------------------------------------------------------------------------------------------------------------------*/    
    public static Map<String, Map<String, Id>> mapBUnitToCaseRecordTypes() {
        Map<String, String> apiNamesBUMap = new Map<String, String>();
        Map<String, Map<String, Id>> buToRecTypeMap = new Map<String, Map<String, Id>>();
        String businessUnit;
        try {
            for (QCC_Case_Record_Type_List__mdt mdtRecord : QCC_Case_Record_Type_List__mdt.getAll().values()) {
                if (String.isBlank(mdtRecord.Business_Unit__c)) {
                    apiNamesBUMap.put(mdtRecord.DeveloperName, null);
                } else {
                    apiNamesBUMap.put(mdtRecord.DeveloperName, mdtRecord.Business_Unit__c);
                }
            }
            if (!apiNamesBUMap.isEmpty()) {
                for (RecordType recType : caseActiveRecordTypeList) {
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
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'mapBUnitToCaseRecordTypes', '', '', false, '', ex);
        }
        return buToRecTypeMap;
    }
/*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        queryQueueGroups
    Description:        To query all the queues that are created for Case object
    Returned Value:     A Map containing queue id and Group object as key-value pair.     
---------------------------------------------------------------------------------------------------------------------------------------*/    
    public static Map<Id,Group> queryQueueGroups() {
        Map<Id, Group> queueMap = new Map<Id, Group>();
        try {
            queueMap =  new Map<Id, Group>([ SELECT Id, DeveloperName, Name FROM Group 
                                                WHERE Type='Queue' 
                                                AND Id IN (SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Case') ]);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'queryQueueGroups', '', '', false, '', ex);
        }
        return queueMap;
    } 
/*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        getQueueIdByDevName
    Description:        To fetch the queue(group object) id by its developer name passed in as parameter
    Returned Value:     Id   
---------------------------------------------------------------------------------------------------------------------------------------*/    
    public static Id getQueueIdByDevName(Map<Id, Group> queueMap, String devName) {
        try {
            if (queueMap != null) {
                for (Group groupRecord : queueMap.values()) {
                    if (String.isNotBlank(groupRecord.DeveloperName) && groupRecord.DeveloperName.equalsIgnoreCase(devName)) {
                        return groupRecord.Id;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'getQueueIdByDevName', '', '', false, '', ex);
        }
        return null;
    } 
    public static List<QualtricsSurvey__mdt> getQualtrics() {
        List<QualtricsSurvey__mdt> qualtricsList = new List<QualtricsSurvey__mdt>();
        try {
            Map<String, QualtricsSurvey__mdt> qualtricsMdts = QualtricsSurvey__mdt.getAll();
            if (qualtricsMdts != null) {
                for (QualtricsSurvey__mdt qualtricsRecord : qualtricsMdts.values()) {
                    qualtricsList.add(qualtricsRecord);
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'getQualtrics', '', '', false, '', ex);
        }
        return qualtricsList;
    }
/*----------------------------------------------------------------------------------------------------------------   
    Method Name:        maskCreditCardAndUATPCardNumbers
    Description:        Jira CRM-5358- mask credit card and UATP card numbers on case description and on 
                        email messagebody which are separated By Spaces.
    Parameter:          String
------------------------------------------------------------------------------------------------------------------*/
    public static String maskCreditCardAndUATPCardNumbers(String description) {
        try {
            if (String.isNotBlank(description)) {
                if (CREDITCARDLENGTH > UATPCARDLENGTH) {
                    description = maskCardInfos(description, CREDITCARDLENGTH);
                    description = maskCardInfos(description, UATPCARDLENGTH);
                } else {
                    description = maskCardInfos(description, UATPCARDLENGTH);
                    description = maskCardInfos(description, CREDITCARDLENGTH);
                }
            } 
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'maskCreditCardAndUATPCardNumbers', '', '', false, '', ex);
        }
        return description;
    }
/*----------------------------------------------------------------------------------------------------------------   
    Method Name:        maskCardInfos
    Description:        Common method to mask numbers separated by spaces or hypen which takes description 
                        and number spaces excluding delimiter as input
    Parameter:          String, number length
------------------------------------------------------------------------------------------------------------------*/
    public static String maskCardInfos(String description, Integer cardLength) {
        try {
            Integer startIndex, index, numberLength = 0;
            Boolean isFlagSet = false;
            Integer[] charArray = description.getChars();
            for (index = 0; index < charArray.size(); index++) {
                if (charArray[index] >= 48 && charArray[index] <= 57) { // ASCII Code of 0 is 48 and 9 is 57
                    if (isFlagSet) {
                        ++numberLength;            
                    } else {
                        numberLength = 1;
                        startIndex = index;
                        isFlagSet = true;
                    }
                } else if (charArray[index] != 32 && charArray[index] != 45) { // ASCII Code of space is 32 and hypen is 45
                    if (isFlagSet && (numberLength == cardLength) && (cardLength != index-startIndex)) {
                        for (Integer j = 1; startIndex < index; startIndex++) {
                            if (charArray[startIndex] >= 48 && charArray[startIndex] <= 57) {
                                if (j > 4) {
                                    charArray[startIndex] = 88; // ASCII Code of X is 88
                                }
                                ++j;
                            }
                        }
                    }
                    isFlagSet = false;
                }
            }
            if (isFlagSet && (numberLength == cardLength) && (cardLength != index-startIndex)) {
                for (Integer j = 1; startIndex < index; startIndex++) {
                    if (charArray[startIndex] >= 48 && charArray[startIndex] <= 57) {
                        if (j > 4) {
                            charArray[startIndex] = 88; // ASCII Code of X is 88
                        }
                        ++j;
                    }
                }
            }
            description = String.fromCharArray(charArray);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'maskCardInfos', '', '', false, '', ex);
        }
        return description;
    }

    /* @Purpose:Method Created to get the document url for Hyperforce Migration CRM -
       @input parameters:
       @return type:                 */
    public static String getDyanamicUrlForFreightLogo() {
        try {
            Document documentRecord = [ SELECT Id FROM Document WHERE DeveloperName = 'Freight_Logo' LIMIT 1 ];
            if(documentRecord != null) {
                return String.format('{0}/servlet/servlet.ImageServer?id={1}&oid={2}', new String[]{ URL.getSalesforceBaseUrl().toExternalForm(), String.valueOf(documentRecord.Id), UserInfo.getOrganizationId() });
            }
        }  catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'getDyanamicUrlForFreightLogo', '', '', false, '', ex);
        }
        return '';
    }

    public static Map<Id,Affected_Passenger__c> queryAffectedPassengers(Set<Id> caseIds, String rtId) {
        Map<Id, Affected_Passenger__c> affectedPassengerMap = new Map<Id, Affected_Passenger__c>();
        //Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId()
        if (caseIds != null && !caseIds.isEmpty()) {
            affectedPassengerMap = new Map<Id, Affected_Passenger__c>(
                [ SELECT Id, Name, Passenger_Sequence__c, Case__c, Salutation__c, Passenger_Type__c, New_Salutation__c, 
                    QAC_Passenger_Id__c, FirstName__c, LastName__c, New_First_Name__c, New_Last_Name__c, CreatedDate, 
                    FrequentFlyerNumber__c, QAC_Flight_Number__c, Ticket_Number__c, Date_of_Birth__c, LastModifiedDate 
                    FROM Affected_Passenger__c WHERE Case__c IN :caseIds AND RecordTypeId = :rtId ]
            );
        }
        return affectedPassengerMap;
    }

    public static Map<Id,Flight__c> queryFlights(Set<Id> caseIds, String rtId) {
        Map<Id, Flight__c> flightMap = new Map<Id, Flight__c>();
        // Schema.SObjectType.Flight__c.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId()
        if (caseIds != null && !caseIds.isEmpty()) {
            flightMap = new Map<Id, Flight__c>(
                [ SELECT Id, Name, Case__c FROM Flight__c 
                    WHERE Case__c IN :caseIds AND RecordTypeId = :rtId ]
            );
        }
        return flightMap;
    }

    public static Map<Id,WorkOrder> queryWorkOrders(Set<Id> caseIds, String rtId) {
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        //Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId()
        if (caseIds != null && !caseIds.isEmpty()) {
            workOrderMap = new Map<Id, WorkOrder>(
                [ SELECT Id, WorkOrderNumber, StartDate, EndDate, Travel_Type__c, Pricebook2Id, 
                    Pricebook2.Name, CurrencyIsoCode, LineItemCount, Sub_Total__c, GST__c, TotalPrice, 
                    CreatedDate, LastModifiedDate, LastModifiedBy.Name, CaseId,
                    ( SELECT Id, WorkOrderId, WorkOrder.WorkOrderNumber, Product2Id, Product2.ProductCode,
                        Product2.Name, Quantity, UnitPrice, Subtotal, TotalPrice FROM WorkOrderLineItems )
                    FROM WorkOrder WHERE CaseId IN :caseIds AND RecordTypeId = :rtId ]
            );
        }
        return workOrderMap;  
    }

    public static Map<Id,User> queryUsers(Set<Id> userIds) {
        Map<Id, User> userMap = new Map<Id, User>();
        Set<String> nonCCATPermission = new Set<String>(Label.QCC_Non_CCAT_Permission.split(';'));
        Set<String> nonValidUsers = new Set<String>{ 'System Admin Updates', 'Integration User', 'Deployment User' };
        if (userIds != null && !userIds.isEmpty()) {
            userMap = new Map<Id, User>(
                [ SELECT Id, FirstName, LastName, Name, Email, GSA_User__c, Location__c,CCAT_User__c,Operational_Group__c, UserRole.Name FROM User 
                    WHERE (Id IN :userIds) OR (Name IN :nonValidUsers) ]
            );
        }
        return userMap;
    }

    public static Map<Id,Group> queryGroups(Set<Id> userAndGroupIds) {
        Map<Id, Group> groupMap = new Map<Id, Group>();
        if (userAndGroupIds != null && !userAndGroupIds.isEmpty()) {
            groupMap = new Map<Id, Group>(
                [ SELECT Id, Name  FROM Group 
                    WHERE Id IN :userAndGroupIds ]
            );
        }
        return groupMap;
    }

    public static Map<Id, Account> queryAccounts() {
        Map<Id, Account> accountMap = new Map<Id, Account>([ SELECT Id, Name, RecordTypeId, BillingCountry, Email__c,Freight_Region__c FROM Account ]);
        return accountMap;
    }

/*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        queryContacts
    Description:        To query contacts containing email ids passed in as parameter
    Returned Value:     List of contacts.     
---------------------------------------------------------------------------------------------------------------------------------------*/    
    public static List<Contact> queryContacts(String rtId, Set<String> emailIds) {
        List<Contact> contactList = new List<Contact>();
        try {
            if (emailIds != null && !emailIds.isEmpty()) {
                contactList = [ SELECT Id, Email, AccountId, Account.Name, Account.RecordTypeId FROM Contact 
                                    WHERE RecordTypeId = :rtId AND Email IN :emailIds
                                    ORDER BY CreatedDate DESC ];
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'queryContacts', '', '', false, '', ex);
        }
        return contactList;
    }

/*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        queryAccounts
    Description:        To query accounts containing account ids passed in as parameter
    Returned Value:     Map of account id and account as key-value pair.     
---------------------------------------------------------------------------------------------------------------------------------------*/    
    public static Map<Id,Account> queryAccounts(String rtId, Set<Id> accountIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        try {
            if (accountIds != null && !accountIds.isEmpty()) {
                accountMap = new Map<Id, Account>([ SELECT Id, Name, RecordTypeId, BillingCountry, Email__c,Freight_Region__c FROM Account 
                                                        WHERE RecordTypeId = :rtId AND Id IN :accountIds 
                                                        ORDER BY CreatedDate DESC ]);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'queryAccounts', '', '', false, '', ex);
        }
        return accountMap;
    }

    /*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        queryAccounts
    Description:        To query accounts containing account ids passed in as parameter
    Returned Value:     Map of account id and account as key-value pair.     
    ---------------------------------------------------------------------------------------------------------------------------------------*/    
    public static Map<Id,Account> queryAccounts(Set<Id> accountIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        try {
            if (accountIds != null && !accountIds.isEmpty()) {
                accountMap = new Map<Id, Account>([ SELECT Id, Name, RecordTypeId, BillingCountry, Email__c FROM Account 
                                                        WHERE Id IN :accountIds 
                                                        ORDER BY CreatedDate DESC ]);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'queryAccounts', '', '', false, '', ex);
        }
        return accountMap;
    }

/*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        queryApprovalMatrices
    Description:        To query Approval Matrix 
    Returned Value:     Map of Approval Matrix id and Approval Matrix as key-value pair.     
---------------------------------------------------------------------------------------------------------------------------------------*/
    public static Map<Id,Approval_Matrix__c> queryApprovalMatrices() {
        Map<Id, Approval_Matrix__c> approvalMatrixMap = new Map<Id, Approval_Matrix__c>();
        try {
            approvalMatrixMap = new Map<Id, Approval_Matrix__c>(
                [ SELECT Id, Type__c, Region__c, Manager__c, Team_Lead__c, Level_3_Approver__c FROM Approval_Matrix__c ]
            );
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'queryApprovalMatrices', '', '', false, '', ex);
        }
        return approvalMatrixMap;
    }

    public static Id fetchUserIdByName(Map<Id, User> userMap, String name) {
        if (userMap != null) {
            for (User userRecord : userMap.values()) {
                if (name.equalsIgnoreCase(userRecord.Name)) {
                    return userRecord.Id;
                }
            }
        }
        return null;
    }
/*-------------------------------------------------------------------------------------------------------------------------------------    
    Method Name:        getCCATUserIds
    Description:        Collect all given User Id's if CCAT Agent
    Returned Value:     Set of CCAT User Ids
---------------------------------------------------------------------------------------------------------------------------------------*/
    public static Set<Id> getCCATUserIds(Map<Id, User> userMap) {
        Set<Id> cCATUserIds = new Set<Id>();
        Set<String> locations = new Set<String>(Label.QCC_CCAT_Location.split(';'));
        Set<String> cCATRoles = new Set<String>(Label.QCC_CCAT_Roles.split(';'));
        try {
            if (userMap != null) {
                for (User userRecord : userMap.values()) {
                    if (userRecord.CCAT_User__c	== true) 
                    {
                        cCATUserIds.add(userRecord.Id);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'getCCATUserIds', '', '', false, '', ex);
        }
        return cCATUserIds;
    }
    
    public static Set<Id> getResolutionConsultantIds(Map<Id, User> userMap) {
          Set<Id> resolutionConsultantIds = new Set<Id>();
          try {
            if (userMap != null) {
                for (User userRecord : userMap.values()) {
                    if (userRecord.Operational_Group__c== 'Resolutions') 
                    {
                        resolutionConsultantIds.add(userRecord.Id);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'getResolutionConsultantIds', '', '', false, '', ex);
        }
        return resolutionConsultantIds;
    }
    
    public static Id getAssignmentRuleId(String assignmentRuleName) {
        try {
            AssignmentRule assgnRule = [ SELECT Id FROM AssignmentRule WHERE Name = :assignmentRuleName LIMIT 1 ];
            if (assgnRule != null) {
                return assgnRule.Id;
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'ALL', 'CaseUtility', 'getAssignmentRuleId', '', '', false, '', ex);
        }
        return null;
    }

    
    /*--------------------------------------------------------------------------------------
    Method Name:        qccCaseRecordTypeIds
    Description:        Fetch QCC Case RecordTypes Jira:CRM-8706
    Parameter:
--------------------------------------------------------------------------------------*/
    public static Set<Id> qccCaseRecordTypeIds(){
        Set<Id> setQCCRectype = new Set<Id>();
        Id recTypeQCCCompliment = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Compliment RecType'));
        setQCCRectype.add(recTypeQCCCompliment);
        Id recTypeCCCBaggage = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
        setQCCRectype.add(recTypeCCCBaggage);
        Id recTypeCCCComplaint = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType'));
        setQCCRectype.add(recTypeCCCComplaint);
        Id recTypeCCCInsurance = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType'));
        setQCCRectype.add(recTypeCCCInsurance);
        Id recTypeCCCMedical = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType'));
        setQCCRectype.add(recTypeCCCMedical);
        Id recTypeCCCQuery = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Query RecType'));
        setQCCRectype.add(recTypeCCCQuery);
        Id recTypeCCCFAR = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Further Action RecType'));
        setQCCRectype.add(recTypeCCCFAR);
        Id recTypeCCCEvent = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType'));
        setQCCRectype.add(recTypeCCCEvent);
        Id recTypeCCOTSR = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC On The Spot Recovery RecType'));
        setQCCRectype.add(recTypeCCOTSR);
        //Added as part of the Jira CRM-4804
        Id recTypeCCCRefund = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Refund RecType'));
        setQCCRectype.add(recTypeCCCRefund);
        
        //Id recTypeCCCVoice = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case CCC Voice'));
        //setQCCRectype.add(recTypeCCCVoice);
        
        //GRAPHITE-1152: Case Status -Enhancement
        Id recTypeEliteProcess = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Elite Process RecType'));
        setQCCRectype.add(recTypeEliteProcess);
        Id recTypeAssistance = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Assistance RecType'));
        setQCCRectype.add(recTypeAssistance);
        Id recTypeDisruption = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Disruption RecType'));
        setQCCRectype.add(recTypeDisruption);
        Id recTypeSpecificNeeds = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Specific Needs RecType'));
        setQCCRectype.add(recTypeSpecificNeeds);
        
        return setQCCRectype;
    }

    /*--------------------------------------------------------------------------------------
        Method Name:        getDomainFromEmailField
        Description:        Extract domain name alone from email address supplied
        Parameter:
    --------------------------------------------------------------------------------------*/

    public static String getDomainFromEmailField(String emailAddress) {
        if (String.isBlank(emailAddress)) {
            return '';
        }
        //return emailAddress.substringAfter('@').substringBefore('.');
        return emailAddress.substringAfter('@');
    } 
}