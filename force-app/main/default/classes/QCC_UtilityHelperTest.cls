/*********************************************************************************
Name         : QCC_UtilityHelperTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 27 January 2020
Usages       : This will handle the test class and code coverage of
QCC_UtilityHelper APEX class
*********************************************************************************/
@isTest
public class QCC_UtilityHelperTest {
    
    @testSetup
    static void createData() {
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType1','Agency Account;Charter Account;Customer Account;Global Account;Other Account;Prospect Account;Regional Account;Person Account'));        
        insert lstConfigData;
        
        //Create test data for Flight Event object
        List<Trigger_Status__c> caseCustomSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert caseCustomSettingList;
        
        List<Trigger_Status__c> customSettingListQantasHost = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusQantasHost', null, null, null, null);
        insert customSettingListQantasHost;
        
        Trigger_Status__c triggerStatus = new Trigger_Status__c();
        triggerStatus.Name = 'UseNamedCred';
        triggerStatus.Active__c = True;
        insert triggerStatus;
        
        Test.startTest();
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '5395838';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.QCC_Last_Activity_Date__c = System.today().addDays(-90);
        contactRecord.QCC_TECH_MobilePhoneAreaCode__c ='21';
        contactRecord.QCC_TECH_MobilePhoneCountryCode__c ='678';
        contactRecord.QCC_TECH_MobilePhoneNumber__c ='723618';
        insert contactRecord;
        
        Contact contactRecord2 = QCC_TestDataFactory.createContactTestData(88, accountRecord.Id);
		contactRecord2.FirstName = 'Test First';
		contactRecord2.LastName = 'Test Lastname';
		contactRecord2.QCC_TECH_TravelSMSPhoneCountryCode__c = '61';
		contactRecord2.QCC_TECH_TravelSMSPhoneNumber__c ='411587469';
		insert contactRecord2;
        
        QCC_First_Host__c qantasHostRec = QCC_TestDataFactory.createFirstHostTestData(contactRecord.Id, null);
        qantasHostRec.QCC_Online_Form_Submission_Date__c = System.today();
        qantasHostRec.QCC_Flight_No__c = '0004';
        qantasHostRec.QCC_PNR__c ='000001';
        qantasHostRec.QCC_Spa_Booking_Status__c = 'Confirmed';
        insert qantasHostRec;
        
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;
        
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QCC Elite Process').getRecordTypeId();
        Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRecord.RecordTypeId = caseRecordTypeId;
        caseRecord.Assign_using_active_assignment_rules__c = true;
        caseRecord.description = 'Legal'; //include hotword to test preTravel recordtype
        caseRecord.type = 'Review Complimentary Upgrade - Meal';
        caseRecord.Comments__c = Label.QCC_Case_Assignment_Flag;
        insert caseRecord;
        
        /** /Create test data for Trigger_Status__c
List<Trigger_Status__c> caseCustomSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
insert caseCustomSettingList;
//Create test data for Case object
List<Case> caseRecords = new List<Case>();
String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QCC Elite Process').getRecordTypeId();
System.debug('caseRecordtypeID : ' + caseRecordTypeId);
Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
caseRecord.RecordTypeId = caseRecordTypeId;
caseRecord.Assign_using_active_assignment_rules__c = true;
caseRecord.description = 'Legal'; //include hotword to test preTravel recordtype
caseRecord.type = 'Review Complimentary Upgrade - Meal';
insert caseRecord;
System.debug('>>>caseRecord: '+caseRecord);
**/
        Test.stopTest();
    }
    
    static testMethod void test1(){
        Test.startTest();
        
        Trigger_Status__c triggerStatus = new Trigger_Status__c();
        triggerStatus.Name = 'UseNamedCred';
        triggerStatus.Active__c = True;
        insert triggerStatus;
       List<Id> userIds = new List<Id>{UserInfo.getUserId()};

        QCC_UtilityHelper.getObjRecords('Case', ' WHERE Id != null');
        QCC_UtilityHelper.getObjMap('QCC_Source_to_Target_Object_Mapping__mdt', 'Module_Name__c', '');
        QCC_UtilityHelper.processDatetime('01/01/2020 10:11:00');
        QCC_UtilityHelper.getLocalDateTime();
        QCC_UtilityHelper.getSOQLSettingRecordByModuleName('Test');
        QCC_UtilityHelper.getListOfCCATUser(userIds);
        QCC_UtilityHelper.getListResolutionConsultant(userIds);
        QCC_UtilityHelper.getLocalDateTime();
        QCC_UtilityHelper.parseStringtoTime('10:11');
        QCC_UtilityHelper.getAllUserFromPublicGroup('Qantas VIP Service Team');
        QCC_UtilityHelper.getDomainURL();
        QCC_UtilityHelper.getDyanamicUrl();
        
            QCC_UtilityHelper.getAllUserByIds(userIds);
        QCC_UtilityHelper.getListFromString('Sample 1,Sample 2,Sample 3', ',');
        QCC_UtilityHelper.checkIfWithinBusinessHours('QCC Qantas Host SMS', System.now());
        QCC_UtilityHelper.checkIfWithinBusinessHours('QCC Qantas Host SMS1', System.now());
        QCC_UtilityHelper.convertStringToTime('11:11:11');
        QCC_UtilityHelper.preventGmtConversion(System.today());
        
        Contact contactRecord = [SELECT Id, Name, Account.Name,QCC_TECH_MobilePhoneAreaCode__c,QCC_TECH_MobilePhoneCountryCode__c,QCC_TECH_MobilePhoneNumber__c FROM Contact LIMIT 1];
        QCC_UtilityHelper.getValueFromSObject('Name', contactRecord);
        QCC_UtilityHelper.getValueFromSObject('Account.Name', contactRecord);
        QCC_UtilityHelper.PhoneNumbertoE164('23','238','0232329');
        QCC_UtilityHelper.removeLeadingZero('086');
         List<String> fieldNameList = new List<string>{'QCC_TECH_MobilePhoneAreaCode__c','QCC_TECH_MobilePhoneCountryCode__c','QCC_TECH_MobilePhoneNumber__c'};
        QCC_UtilityHelper.generateConcatenatedFieldValues(fieldNameList,contactRecord);
        QCC_UtilityHelper.checkIfFieldValueChanged(fieldNameList,contactRecord,contactRecord);
        User currentLoginUser = [SELECT Id, Location__c, UserRole.Name, CCAT_User__c FROM User WHERE Id =: UserInfo.getUserId()];
        QCC_UtilityHelper.isCCATAgent(currentLoginUser);
        QCC_UtilityHelper.isCCATUser(userIds);
        
        Test.stopTest();
    }
    
    static testMethod void test2(){
        String moduleName = 'Quarterly Health Check Call';
        QCC_SOQL_Setting__mdt soqlSetting;
        
        try {
            soqlSetting = [
                SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c 
                FROM QCC_SOQL_Setting__mdt 
                WHERE Module_Name__c =: moduleName
                LIMIT 1
            ];
        } catch(Exception ex) {
            soqlSetting = null;
        }
        
        if (soqlSetting != null) {
            
            String targetRecordTypeId = Schema.getGlobalDescribe().get(soqlSetting.Target_Object__c).getDescribe().getRecordTypeInfosByName().get(soqlSetting.Target_Record_Type__c).getRecordTypeId();
            String conditionClause = ' WHERE Module_Name__c = \'' + moduleName + '\''; 
            List<sObject> metaObjects = QCC_UtilityHelper.getObjRecords ('QCC_Source_to_Target_Object_Mapping__mdt', conditionClause);
            String queryString = QCC_SpecialLogicUtilityHelper.generateAdditionalFilterForDynamicSOQL(soqlSetting.Module_Name__c, soqlSetting.Query_String__c);
            List<Contact> contactList = Database.query(queryString);
            Test.startTest();
            
            QCC_UtilityHelper.transformSourceToTargetObjects(moduleName, contactList, metaObjects, 'Case', targetRecordTypeId, null);
            
            Test.stopTest();
        }
    }
    
    static testMethod void test3(){
        List<Qantas_API__c> qantasAPIRecords = [SELECT Id, Token__c FROM Qantas_API__c];
        QCC_UtilityHelper.updateQantasAPIToken(qantasAPIRecords[0], 'sample');
    }
    
    static testMethod void test4(){
        List<User> userRecords = [SELECT Id, UserRoleId FROM User WHERE IsActive = true AND UserRoleId != null LIMIT 5];
        List<Id> userRoleIds = new List<Id>();
        
        Map<Id, List<UserRole>> userRoleMap = QCC_UtilityHelper.getUserRoleHierarchyMap();
        for(User userRecord : userRecords) {
            userRoleIds.add(userRecord.UserRoleId);
            QCC_UtilityHelper.getSubHierarchyRoleIds(userRecord.UserRoleId, userRoleMap);
        }
        QCC_UtilityHelper.getAllUserByUserRoleIds(userRoleIds);
    }
    
    static testMethod void groupLoyaltyEventTypeTest(){
        
        test.startTest();
        List<QCC_Loyalty_Status__e> LoyaltyStatus = QCC_UtilityHelper.createDynamicObjectRecords('QCC_Loyalty_Status__e', 'QCCTestDataLoyaltyPlatformEvents_WithCaseCreation', null, null, null, null);
        QCC_UtilityHelper.groupLoyaltyEventType(LoyaltyStatus);
        test.stopTest();
    }
    
    static testMethod void getSOQLSettingByDeveloperNameTest(){
        
        test.startTest();
        QCC_UtilityHelper.getSOQLSettingByDeveloperName('Quarterly_Health_Check_Call');
        test.stopTest();
    }
    
    static testMethod void getAllCaseStreamSwitchTest(){
        
        test.startTest();
        QCC_UtilityHelper.getAllCaseStreamSwitch(true);
        test.stopTest();
    }
    
    static testMethod void getSourceToTargetRecordsByModuleNamesTest(){
        List<String> listTring = new List<String>{'test', 'test'};
            
            test.startTest();
        QCC_UtilityHelper.getSourceToTargetRecordsByModuleNames(listTring);
        test.stopTest();
    }
    
    static testMethod void getPlatformEventSwitchTest(){
        
        test.startTest();
        QCC_UtilityHelper.getPlatformEventSwitch();
        test.stopTest();
    }
    
    @future
    public static void QCC_QantasHostSpaBookingQueueableTest(){
        
         String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        
        //Account Record
        /*Account accRecord = QCC_TestDataFactory.createAccountTestData(88);
		insert accRecord;*/
        
        //Contact Record
        Contact conRecord = [SELECT Id, SSU__c, QCC_TECH_TravelSMSPhoneCountryCode__c,
                             QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c,
                             QCC_Travel_Email__c, Email
                             FROM Contact Limit 1];
        
        contact conRecord1 = [SELECT Id,  SSU__c, QCC_TECH_TravelSMSPhoneCountryCode__c,
                             QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c,
                             QCC_Travel_Email__c, Email
                             FROM Contact 
                             WHERE FirstName = 'Test First' ];
        
        
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendSMSMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        
        QCC_First_Host__c qantasHostRec = [SELECT Id, QCC_Spa_Request_Outcome__c, QCC_Cabin__c, 
                                           QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c,
                                           QCC_First_Host_Contact__c, QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c,
                                           QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c, QCC_Departure_Airport__c,
                                           QCC_Carrier_Code__c, QCC_Flight_No__c
                                           FROM QCC_First_Host__c 
                                           LIMIT 1];
        
        
        QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = new QCC_UtilityHelper.QantasHostTemplateWrapper();
        myWrapper.emailTemplateAPIName = 'QantasHostConfirmationEmailSYD';
        myWrapper.contactRecord = conRecord1 ;
        myWrapper.qantasHostRecord = qantasHostRec;
        
        qantasHostToSendSMSMap.put(qantasHostRec.Id, myWrapper);
        QCC_UtilityHelper.sendQantasHostSMS(qantasHostToSendSMSMap, 'Spa Booking Status');
        //QCC_UtilityHelper.sendQantasHostSMS(qantasHostToSendSMSMap, 'Online Form Submission');
    }
    static testMethod void sendQantasHostSMSTest(){
        test.startTest();
        QCC_QantasHostSpaBookingQueueableTest();
        test.stopTest();
    }
    
     @future
    public static void QCC_QantasHostOnlineFormSendSMSQueueableTest(){
        
         String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        
        //Contact Record
        Contact conRecord = [SELECT Id, SSU__c, QCC_TECH_TravelSMSPhoneCountryCode__c,
                             QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c,
                             QCC_Travel_Email__c, Email
                             FROM Contact Limit 1];
        
        contact conRecord1 = [SELECT Id,  SSU__c, QCC_TECH_TravelSMSPhoneCountryCode__c,
                             QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c,
                             QCC_Travel_Email__c, Email
                             FROM Contact 
                             WHERE  FirstName = 'Test First' ];
        
        
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendSMSMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        
        QCC_First_Host__c qantasHostRec = [SELECT Id, QCC_Spa_Request_Outcome__c, QCC_Cabin__c, 
                                           QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c,
                                           QCC_First_Host_Contact__c, QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c,
                                           QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c, QCC_Departure_Airport__c,
                                           QCC_Carrier_Code__c, QCC_Flight_No__c
                                           FROM QCC_First_Host__c 
                                           LIMIT 1];
        
        
        QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = new QCC_UtilityHelper.QantasHostTemplateWrapper();
        myWrapper.emailTemplateAPIName = 'QantasHostConfirmationEmailSYD';
        myWrapper.contactRecord = conRecord1 ;
        myWrapper.qantasHostRecord = qantasHostRec;
        
        qantasHostToSendSMSMap.put(qantasHostRec.Id, myWrapper);
        QCC_UtilityHelper.sendQantasHostSMS(qantasHostToSendSMSMap, 'Online Form Submission');
    }
    static testMethod void sendQantasHostSMSCall(){
        test.startTest();
        QCC_QantasHostOnlineFormSendSMSQueueableTest();
        test.stopTest();
    }
     @future
    public static void QCC_QantasHostSendSMSQueueableTest(){
        
         String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        
        //Contact Record
        Contact conRecord = [SELECT Id, SSU__c, QCC_TECH_TravelSMSPhoneCountryCode__c,
                             QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c,
                             QCC_Travel_Email__c, Email
                             FROM Contact Limit 1];
        
        contact conRecord1 = [SELECT Id,  SSU__c, QCC_TECH_TravelSMSPhoneCountryCode__c,
                             QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c,
                             QCC_Travel_Email__c, Email
                             FROM Contact 
                             WHERE  FirstName = 'Test First'];
        
        
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendSMSMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        
        QCC_First_Host__c qantasHostRec = [SELECT Id, QCC_Spa_Request_Outcome__c, QCC_Cabin__c, 
                                           QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c,
                                           QCC_First_Host_Contact__c, QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c,
                                           QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c, QCC_Departure_Airport__c,
                                           QCC_Carrier_Code__c, QCC_Flight_No__c
                                           FROM QCC_First_Host__c 
                                           LIMIT 1];
        
        
        QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = new QCC_UtilityHelper.QantasHostTemplateWrapper();
        myWrapper.emailTemplateAPIName = 'QantasHostConfirmationEmailSYD';
        myWrapper.contactRecord = conRecord1 ;
        myWrapper.qantasHostRecord = qantasHostRec;
        
        qantasHostToSendSMSMap.put(qantasHostRec.Id, myWrapper);
        QCC_UtilityHelper.sendQantasHostSMS(qantasHostToSendSMSMap, 'Qantas Host Communication Matrix');
    }
    
    static testMethod void QCC_QantasHostSendSMSQueueableCall(){
        test.startTest();
        QCC_QantasHostSendSMSQueueableTest();
        test.stopTest();
    }
    
    static testMethod void sendQantasHostEmailTest(){
        //Contact Record
        Contact conRecord = [SELECT Id, SSU__c, QCC_TECH_TravelSMSPhoneCountryCode__c,
                             QCC_TECH_TravelSMSPhoneNumber__c, QCC_TECH_MobilePhoneCountryCode__c,
                             QCC_Travel_Email__c, Email
                             FROM Contact Limit 1];
        
        //Qantas Hos Record
        QCC_First_Host__c qantasHostRec = [SELECT Id, QCC_Spa_Request_Outcome__c, QCC_Cabin__c, 
                                           QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c,
                                           QCC_First_Host_Contact__c, QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c,
                                           QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c, QCC_Departure_Airport__c,
                                           QCC_Carrier_Code__c, QCC_Flight_No__c
                                           FROM QCC_First_Host__c 
                                           LIMIT 1];
        
        Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper> qantasHostToSendSMSMap = new Map<Id, QCC_UtilityHelper.QantasHostTemplateWrapper>();
        QCC_UtilityHelper.QantasHostTemplateWrapper myWrapper = new QCC_UtilityHelper.QantasHostTemplateWrapper();
        myWrapper.emailTemplateAPIName = 'QantasHostConfirmationEmailSYD';
        myWrapper.contactRecord = conRecord ;
        myWrapper.qantasHostRecord = qantasHostRec;
        
        qantasHostToSendSMSMap.put(qantasHostRec.Id, myWrapper);
        
        test.startTest();
        QCC_UtilityHelper.sendQantasHostEmail(qantasHostToSendSMSMap);
        test.stopTest();
    }
    
    
    static testMethod void getQantasHostCommunicationTemplateTest(){
        
        List<QCC_Qantas_Host_Communication_Template__mdt> qantasHostTemplates = [
            SELECT Id, Order_Sequence__c, Cabin__c, Is_Top_Platinum_One__c, Frequent_Flyer_Tier__c, Tier_Effective_Tier__c, 
            Departure_Port__c, Excluded_Flights__c, SMS_Template_API_Name__c, Email_Template_API_Name__c, 
            Online_Form_Submission_Email_Template__c, Online_Form_Submission_SMS_Template__c
            FROM QCC_Qantas_Host_Communication_Template__mdt
            ORDER BY Order_Sequence__c
            LIMIT 10000
        ];
        
        QCC_First_Host__c qantasHostRec = [SELECT Id, QCC_Spa_Request_Outcome__c, QCC_Cabin__c, 
                                           QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c,
                                           QCC_First_Host_Contact__c, QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c,
                                           QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c, QCC_Departure_Airport__c,
                                           QCC_Carrier_Code__c, QCC_Flight_No__c
                                           FROM QCC_First_Host__c 
                                           LIMIT 1];
        
        test.startTest();
        QCC_UtilityHelper.getQantasHostCommunicationTemplate(qantasHostRec, qantasHostTemplates );
        test.stopTest();
    }
    
    static testMethod void assignVIPCaseUsingAssignmentRuleTest(){
        List<Case> caseList = [SELECT Id, Comments__c  FROM Case];
        
        
        test.startTest();
        QCC_UtilityHelper.assignVIPCaseUsingAssignmentRule(caseList);
        test.stopTest();
    }
    
    static testMethod void getSpaBookingCommsTemplateTest(){
        //Qantas Hos Record
        QCC_First_Host__c qantasHostRec = [SELECT Id, QCC_Spa_Request_Outcome__c, QCC_Cabin__c, 
                                           QCC_First_Host_Contact__r.QCC_Top_Platinum_One__c,
                                           QCC_First_Host_Contact__c, QCC_First_Host_Contact__r.Frequent_Flyer_Tier__c,
                                           QCC_First_Host_Contact__r.QCC_Tier_Effective_Tier__c, QCC_Departure_Airport__c,
                                           QCC_Carrier_Code__c, QCC_Flight_No__c, QCC_Spa_Booking_Status__c, QCC_Preferred_Contact_Channel__c
                                           FROM QCC_First_Host__c 
                                           LIMIT 1];
        List<QCC_Spa_Booking_Comms__mdt> spaBookingCommsList = [SELECT Preffered_Contact_Method__c, Spa_Booking_Status__c, 
                                                                       Template_Name__c
                                                                FROM QCC_Spa_Booking_Comms__mdt
                                                               WHERE Spa_Booking_Status__c = 'Confirmed'];
        test.startTest();
        
        QCC_UtilityHelper.getSpaBookingCommsTemplate(qantasHostRec, spaBookingCommsList);
        test.stopTest();
    }
    
}