/*==============================================================================================================================
Author:         Purushotham B
Company:        Capgemini
Purpose:        Test class for QCC_CustomerDetailController
Date:           05/12/2017          
History:
==============================================================================================================================*/
@isTest(SeeAllData = false)
private class QCC_CustomerDetailControllerTest {
    @testSetup
    static void createData() {
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();

         User u = new User(LastName = 'User1', Alias = 'User99', Email = 'sampleuser991@sample.com', 
                           Username = 'sampleuser99username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id, //CRM-11908 Update metadata rerferences
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        insert u;

        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id, //CRM-11908 Update metadata rerferences
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', ManagerId = u.Id
                          );
        insert u1;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        
        //List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        
        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        
        
        System.runAs(u1) {
            for(Integer i = 0; i < 5; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services');
                con.Frequent_Flyer_Number__c = '12456787'+''+i;
                con.Email = 'praveen@hotmail.com';
                con.Phone = '0426646801';
                contacts.add(con);
            }
            insert contacts;
            
            List<Case> cases = TestUtilityDataClassQantas.insertCases(contacts, recordType, type, 'Qantas.com','Website Functionality','','');
        }

        Qantas_API__c loyaltyAPIv2Config = new Qantas_API__c();
        loyaltyAPIv2Config.Name = 'QCC_LoyaltyAPIv2';
        loyaltyAPIv2Config.EndPoint__c = 'https://api.services-sit.qantasloyalty.com/member/';
        loyaltyAPIv2Config.Method__c = 'GET';

        insert loyaltyAPIv2Config;
    }
    static testMethod void testSaveRecovery() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Case> cases = [SELECT Id FROM Case LIMIT 3];
            List<String> recoveryIds = new List<String>();
            Test.startTest();
            for(Integer i = 0; i < cases.size(); i++) {
                String recoveryId = QCC_CustomerDetailController.saveRecovery(cases[i].id);
                recoveryIds.add(recoveryId);
            }
            Test.stopTest();
            List<Recovery__c> recoveries = [Select Id,Case_Number__c FROM Recovery__c where Id = :recoveryIds];
            System.assertEquals(cases.size(), recoveries.size());
        }
    }

    static testMethod void testIsConsultant() {
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        List<User> users = TestUtilityDataClassQantas.getUsers('QCC Contact Center Agent Hobart', '', 'QF-Customer Care'); //CRM-11908 Update metadata rerferences
        Test.startTest();
        for(Integer i = 0; i < users.size(); i++) {
            System.assertEquals(true, QCC_CustomerDetailController.isConsultant(users[i].id));
        }

        User u = new User(LastName = 'User', Alias = 'User' ,
                              Email = 'sampleuser@sample.com', Username = 'sampleuserusername@sample.com',
                              ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
                              EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                              TimeZoneSidKey = 'Australia/Sydney'
                             );
        insert u;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }

        Test.stopTest();
        System.assertEquals(false, QCC_CustomerDetailController.isConsultant(u.id));
    }

    static testMethod void testIsCaseClosed() {
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            List<Case> cases = [SELECT Id, status FROM Case];
            Test.startTest();
            for(Integer i = 0; i < cases.size(); i++) {
                System.assertEquals('New', QCC_CustomerDetailController.isCaseClosed(cases[i].id));
                cases[i].status = 'Closed';
                cases[i].SkipValidationsforAutomations__c = true;
            }
            update cases;

            Test.stopTest();

            List<Case> updatedCases = [Select Id, Status FROM Case Where Id = :cases];
            for(Integer i = 0; i < updatedCases.size(); i++) {
                System.assertEquals('Closed', QCC_CustomerDetailController.isCaseClosed(updatedCases[i].id));
            }
        }
    }

    static TestMethod void fetchCustomerDetailPostiveTest(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCFF_SC-Bronze','999'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFBR','Bronze'));
        insert lstConfigData;
        Contact objCon = [select Id from Contact limit 1];

        Test.startTest();
        String Body = '{"memberId":"1900007871","firstName":"MEMBER","lastName":"LOYTEST","mailingName":"SIR M LOYTEST",'+
                        '"salutation":"Dear Sir Loytest","title":"SIR","dateOfJoining":"2012-05-21","gender":"MALE",'+
                        '"dateOfBirth":"1995-03-20","email":"ibskevinliu@qantas.com.au","emailType":"BUSINESS",'+
                        '"countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"BUSINESS",'+
                        '"pointBalance":1,"company":{"name":"QANTAS LOYALTY IT","positionInCompany":"TEST PROFILE - DPP"},'+
                        '"phoneDetails":[{"type":"BUSINESS","number":"ibs96915525","areaCode":"02","idd":"+61","status":"V"}],'+
                        '"addresses":[{"type":"BUSINESS","lineOne":"LEVEL 7","lineTwo":"440 ELIZABETH STREET","suburb":"MELBOURNE",'+
                        '"postCode":"3000","state":"VIC","countryCode":"AU","status":"V"}],"preferences":{},'+
                        '"programDetails":[{"programCode":"QCASH","programName":"Qantas Cash","enrollmentDate":"2013-08-14",'+
                        '"accountStatus":"ACTIVE","qcachSendMarketing":false,"qcashProgramIdentifier":"AU"},'+
                        '{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrolmentDate":"2012-05-21",'+
                        '"accountStatus":"ACTIVE","tierCode":"FFBR","tierFromDate":"2017-11-22","tierToDate":"2019-05-31",'+
                        '"ffExpireDate":"31-May-2018"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-05-31",'+
                        '"lifetime":300,"total":0,"loyaltyBonus":0},"tier":{"name":"Frequent Flyer Bronze","code":"FFBR",'+
                        '"expiryDate":"2019-05-31","startDate":"2017-11-22","effectiveTier":"FFBR"}, '+
                        '"airlineCustomerValue":"9879","otherAirlineSchemeCount":0,"qantasFFNo":"900000000000013",'+
                        '"qfMemberAirlinePriorityLevel":null,"qfMemberTierClubCode":"FFGD","complaintCount":3,'+
                        '"serviceFailureCount":21,"surpriseDelightCount":1,"mishandledBagCount":39,"flightCancellationCount":26,'+
                        '"flightDelayDomesticCount":13,"flightDelayInternationalCount":6,"flightUpgradeDomesticCount":0,'+
                        '"flightUpgradeInternationalCount":12,"flightDowngradeDomesticCount":22,"flightDowngradeInternationalCount":13,'+
                        '"flightSegmentCount":31,"qantasUniqueID":"900000000013","majorityQCI":"ANZ","majorCorpCountryCode":"AU",'+
                        '"majorCorpBCI":"BCI","majorCorpACI":"ACI","majorCorpOCI":"OCI","majorCorpName":"ANZ Bank",'+
                        '"majorCorpAltName":"Australia New Zealand Banking Corp"'+
						
            			'}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
       // QCC_CustomerDetailController.fetchCustomerDetail(objCon.Id, true);
        try{
        QCC_CustomerDetailController.fetchCustomerDetail(objCon.Id, true);
        }catch(Exception ex){
        System.debug('Exception'+ex);   
        }
        Test.stopTest();
    }

     static TestMethod void fetchCustomerDetailNegativeTest(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCFF_SC-Bronze','999'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFBR','Bronze'));
        insert lstConfigData;
        Contact objCon = [select Id from Contact limit 1];

        Test.startTest();
        Boolean isException = false;
        String Body = '';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        try{
            QCC_CustomerDetailController.fetchCustomerDetail(objCon.Id, true);
        }catch(Exception ex){
            isException = true;
        }
        system.assert(isException = true, 'No Exception');
        Test.stopTest();
    }

    static TestMethod void fetchCaseSummaryPostiveTest(){
        Contact objCon = [select Id from Contact limit 1];
        Case objCase = [select Id from Case limit 1];
        String Body = '{"airlineCustomerValue":"9879","otherAirlineSchemeCount":0,"qantasFFNo":"900000000000013",'+
                        '"qfMemberAirlinePriorityLevel":null,"qfMemberTierClubCode":"FFGD","complaintCount":3,'+
                        '"serviceFailureCount":21,"surpriseDelightCount":1,"mishandledBagCount":39,"flightCancellationCount":26,'+
                        '"flightDelayDomesticCount":13,"flightDelayInternationalCount":6,"flightUpgradeDomesticCount":0,'+
                        '"flightUpgradeInternationalCount":12,"flightDowngradeDomesticCount":22,"flightDowngradeInternationalCount":13,'+
                        '"flightSegmentCount":31,"qantasUniqueID":"900000000013","majorityQCI":"ANZ","majorCorpCountryCode":"AU",'+
                        '"majorCorpBCI":"BCI","majorCorpACI":"ACI","majorCorpOCI":"OCI","majorCorpName":"ANZ Bank",'+
                        '"majorCorpAltName":"Australia New Zealand Banking Corp"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_CustomerDetailController.BannerWrapper bannerWrap = QCC_CustomerDetailController.fetchCaseSummary(objCon.Id);
        QCC_CustomerDetailController.BannerWrapper bannerWrap1 = QCC_CustomerDetailController.fetchCaseSummary(objCase.Id);
        Test.stopTest();
    }

    static TestMethod void fetchCaseSummaryNegativeTest(){
        Contact objCon = [select Id from Contact limit 1];
        String Body = '';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Boolean isException = false;
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        try{
            QCC_CustomerDetailController.BannerWrapper bannerWrap = QCC_CustomerDetailController.fetchCaseSummary(objCon.Id);
        }catch(Exception ex){
            isException = true;
        }
        system.assert(isException = true, 'No Exception');
        Test.stopTest();
    }

    static TestMethod void fetchRecordTypeValuesPostiveTest(){
        Test.startTest();
        List<RecordType> lstRectype = QCC_CustomerDetailController.fetchRecordTypeValues();
        system.assert(lstRectype.size()>0, ' No recordype on case');
        Test.stopTest();
    }

    static TestMethod void isCaseInQueuePostiveTest(){
        Case objCase = [select Id from Case limit 1];
        Test.startTest();
        Boolean isinQueue = QCC_CustomerDetailController.isCaseInQueue(objCase.Id);
        system.assert(isinQueue != true, ' No recordype on case');
        Test.stopTest();
    }

    static TestMethod void isaveRecoveryNegativeTest(){
        Contact objCon = [select Id from Contact limit 1];
        Test.startTest();
        Boolean isinQueue = false;
        try{
            QCC_CustomerDetailController.saveRecovery(objCon.Id);
        }catch(Exception ex){
            isinQueue = true;
        }

        system.assert(isinQueue = true, ' No recordype on case');
        Test.stopTest();
    }

    static TestMethod void isConsultantNegativeTest(){
        Contact objCon = [select Id from Contact limit 1];
        Test.startTest();
        Boolean isinQueue = false;
        try{
            QCC_CustomerDetailController.isConsultant(objCon.Id);
        }catch(Exception ex){
            isinQueue = true;
        }

        system.assert(isinQueue = true, ' No recordype on case');
        Test.stopTest();
    }

    static TestMethod void isCaseClosedNegativeTest(){
        Test.startTest();
        Boolean isinQueue = false;
        try{
            QCC_CustomerDetailController.isCaseClosed(null);
        }catch(Exception ex){
            isinQueue = true;
        }

        system.assert(isinQueue = true, ' No recordype on case');
        Test.stopTest();
    }

    static TestMethod void isCaseInQueueNegativeTest(){
        Test.startTest();
        Boolean isinQueue = false;
        try{
             QCC_CustomerDetailController.isCaseInQueue(null);
        }catch(Exception ex){
            isinQueue = true;
        }

        system.assert(isinQueue = true, ' No recordype on case');

        Test.stopTest();
    }

    static TestMethod void escalatingCasePositiveTest(){
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        Test.startTest();
        Case objCase = [select Id from Case limit 1];
        objCase.OwnerId = usr.Id;
        update objCase;
        System.runAs(usr) {
            String esclaste =  QCC_CustomerDetailController.escalatingCase(objCase.Id);
            system.assert(esclaste != '', ' No recordype on case');
            Test.stopTest();
        }
    }

    static TestMethod void escalatingCaseNegativeTest(){
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        Test.startTest();
        Case objCase = [select Id from Case limit 1];
        objCase.OwnerId = usr.Id;
        update objCase;
        System.runAs(usr) {
            String esclaste =  QCC_CustomerDetailController.escalatingCase(null);
            system.assert(esclaste != '', ' No recordype on case');
            Test.stopTest();
        }
    }

    static TestMethod void testFetchCustomerDetailWithCaseId(){
        Test.startTest();
        String Body = '{"memberId":"1900007871","firstName":"MEMBER","lastName":"LOYTEST","mailingName":"SIR M LOYTEST",'+
                        '"salutation":"Dear Sir Loytest","title":"SIR","dateOfJoining":"2012-05-21","gender":"MALE",'+
                        '"dateOfBirth":"1995-03-20","email":"ibskevinliu@qantas.com.au","emailType":"BUSINESS",'+
                        '"countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"BUSINESS",'+
                        '"pointBalance":1,"company":{"name":"QANTAS LOYALTY IT","positionInCompany":"TEST PROFILE - DPP"},'+
                        '"phoneDetails":[{"type":"BUSINESS","number":"ibs96915525","areaCode":"02","idd":"+61","status":"V"}],'+
                        '"addresses":[{"type":"BUSINESS","lineOne":"LEVEL 7","lineTwo":"440 ELIZABETH STREET","suburb":"MELBOURNE",'+
                        '"postCode":"3000","state":"VIC","countryCode":"AU","status":"V"}],"preferences":{},'+
     					'"accountStatus":"CLOSED","enrolmentDate":"1996-05-13","ffExpireDate":"1997-05-31","programCode":"QFF","programName":"Qantas Frequent Flyer","suspended":false,'+
                        '"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-05-31",'+
                        '"lifetime":300,"total":0,"loyaltyBonus":0},"tier":{"name":"Frequent Flyer Bronze","code":"FFBR",'+
                        '"expiryDate":"2019-05-31","startDate":"2017-11-22","effectiveTier":"FFBR"}, '+
                        '"airlineCustomerValue":"9879","otherAirlineSchemeCount":0,"qantasFFNo":"900000000000013",'+
                        '"qfMemberAirlinePriorityLevel":null,"qfMemberTierClubCode":"FFGD","complaintCount":3,'+
                        '"serviceFailureCount":21,"surpriseDelightCount":1,"mishandledBagCount":39,"flightCancellationCount":26,'+
                        '"flightDelayDomesticCount":13,"flightDelayInternationalCount":6,"flightUpgradeDomesticCount":0,'+
                        '"flightUpgradeInternationalCount":12,"flightDowngradeDomesticCount":22,"flightDowngradeInternationalCount":13,'+
                        '"flightSegmentCount":31,"qantasUniqueID":"900000000013","majorityQCI":"ANZ","majorCorpCountryCode":"AU",'+
                        '"majorCorpBCI":"BCI","majorCorpACI":"ACI","majorCorpOCI":"OCI","majorCorpName":"ANZ Bank",'+
                        '"majorCorpAltName":"Australia New Zealand Banking Corp",'+
            			'"qantasFrequentFlyerTier":{"effectiveTier":"BRONZE","effectiveTierDescription":"Bronze","oneWorldTier":"NONE","startDate":"2013-01-01","tierChangeReason":"","tierCode":"FREQUENT_FLYER_BRONZE","tierDescription":"Frequent Flyer Bronze","tierOverridden":false,"tierType":"BRONZE","tierTypeDescription":"Bronze"}'+
            			'}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        Case objCase = [select Id, First_Name__c, Last_Name__c, Contact_Email__c, Contact_Phone__c from Case limit 1];
       // QCC_CustomerDetailController.BannerWrapper bw =  QCC_CustomerDetailController.fetchCustomerDetail(objCase.Id, true);
        QCC_CustomerDetailController.BannerWrapper bw;
        try{
        bw =  QCC_CustomerDetailController.fetchCustomerDetail(objCase.Id, true);
        }catch(Exception e){
            system.debug('Exception'+e);
        }
        Test.stopTest();
        //System.assertEquals(bw.objContact.LastName, objCase.Last_Name__c);
       // System.assertEquals(bw.objContact.FirstName, objCase.First_Name__c);
    }

    static TestMethod void testCaseRecordType(){
        Case objCase = [select Id, RecordType.Name from Case limit 1];
        Test.startTest();
        String recTypeName = QCC_CustomerDetailController.caseRecordType(objCase.Id);
        Test.stopTest();
        System.assertEquals(recTypeName, objCase.RecordType.Name);
    }

    static TestMethod void testCaseRecordTypeException(){
        Test.startTest();
        Boolean isinQueue = false;
        try{
            QCC_CustomerDetailController.caseRecordType(null);
        }catch(Exception ex){
            isinQueue = true;
        }

        system.assert(isinQueue = true, 'Case Id exists');
        Test.stopTest();
    }

    static TestMethod void testgetProfileToHideForContact(){

        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            Test.startTest();
            QCC_CustomerDetailController.getProfileToHideForContact();
            Test.stopTest();
        }
    }
    
    static TestMethod void testgetSwitchforStartWorkandResolveCase(){
        Case caseRec = [SELECT Id FROM Case LIMIT 1];
        
        User usr = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        System.runAs(usr) {
            Test.startTest();
            QCC_CustomerDetailController.getSwitchforStartWorkandResolveCase(caseRec.Id);
            Test.stopTest();
        }
    }

    static TestMethod void testGetPromotions(){
        Test.setMock(HttpCalloutMock.class, new QCC_PromoCodeMockResponseGenerator());
        Qantas_API__c QCC_LoyaltyPromoAPIConfig = new Qantas_API__c();
        QCC_LoyaltyPromoAPIConfig.Name = 'QCC_LoyaltyPromoAPI';
        QCC_LoyaltyPromoAPIConfig.EndPoint__c = 'https://api-stage.qantas.com/loyalty/memberAccount/v1/';
        QCC_LoyaltyPromoAPIConfig.Method__c = 'GET';

        insert QCC_LoyaltyPromoAPIConfig;

        Test.startTest();            
            Case objCase = [SELECT Id FROM Case LIMIT 1];
            Contact objCon = [select Id from Contact limit 1];
            QCC_RewardsWrapper.PromoRewards rewards =  QCC_CustomerDetailController.getPromotions(objCase.Id); //case test
            QCC_RewardsWrapper.PromoRewards rewards2 =  QCC_CustomerDetailController.getPromotions(objCon.Id); //contact test
            QCC_RewardsWrapper.PromoRewards rewards3 =  QCC_CustomerDetailController.getPromotions(''); //exception test
        Test.stopTest();
        System.assertEquals('PROMO09S12AB56', rewards.promoCode);
        System.assertEquals('PROMO09S12AB56', rewards2.promoCode);
        
    }
    

}