@isTest(SeeAllData = false)
public class FreqFlyerSearchControllerTest {
    @testSetup
    static void createData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        insert lsttrgStatus;
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
    }
    
   /* public static User createTestUser(Id roleId, Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + sandboxName + '.com',
                              Username = uniqueName + '@test' + sandboxName + '.com',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId,
                              UserRoleId = roleId);
        system.debug('userinfo'+tuser);
        return tuser;    
    } */
    static testMethod void invokeWebServiceCAPTestData() {
        //QantasConfigData start
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCFF_SC-Bronze','999'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFBR','Bronze'));
        insert lstConfigData;
        //QantasConfigData end
        List<Case> CasList = new List<Case>();
        List<Account> accList = new List<Account>();
        List<Frequent_Flyer_Information__c> FFList = new List<Frequent_Flyer_Information__c>();    
        ID recID;
        
        accList = QL_TestUtilityData.getAccounts();
        // Load Cases
        Case cs = new Case(Accountid=accList[0].ID,Status ='Not yet assigned - with Account Manager',Justification__c ='NA',Frequent_Flyer_Number__c ='0002750079');
        insert cs;
        recID = cs.id;
        Test.starttest();
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
            '{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrollmentDate":"2012-05-21",'+
            '"accountStatus":"ACTIVE","tierCode":"FFBR","tierFromDate":"2017-11-22","tierToDate":"2019-05-31",'+
            '"ffExpireDate":"31-May-2018"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-05-31",'+
            '"lifetime":300,"total":0,"loyaltyBonus":0},"tier":{"name":"Frequent Flyer Bronze","code":"FFBR",'+
            '"expiryDate":"2019-05-31","startDate":"2017-11-22","effectiveTier":"FFBR"}, '+
            '"airlineCustomerValue":"9879","otherAirlineSchemeCount":0,"qantasFFNo":"0002750079",'+
            '"qfMemberAirlinePriorityLevel":null,"qfMemberTierClubCode":"FFGD","complaintCount":3,'+
            '"serviceFailureCount":21,"surpriseDelightCount":1,"mishandledBagCount":39,"flightCancellationCount":26,'+
            '"flightDelayDomesticCount":13,"flightDelayInternationalCount":6,"flightUpgradeDomesticCount":0,'+
            '"flightUpgradeInternationalCount":12,"flightDowngradeDomesticCount":22,"flightDowngradeInternationalCount":13,'+
            '"flightSegmentCount":31,"qantasUniqueID":"900000000013","majorityQCI":"ANZ","majorCorpCountryCode":"AU",'+
            '"majorCorpBCI":"BCI","majorCorpACI":"ACI","majorCorpOCI":"OCI","majorCorpName":"ANZ Bank",'+
            '"majorCorpAltName":"Australia New Zealand Banking Corp"}';
        //  String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';               
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        FreqFlyerSearchController.invokeWebServiceCAP(recID);
        Test.stoptest();
    }
    static testMethod void createFreqFlyerTestData() {
        //QantasConfigData start
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCCFF_SC-Bronze','999'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('FFBR','Bronze'));
        
        insert lstConfigData;
        
        //QantasConfigData end
        List<Case> CasList = new List<Case>();
        List<Account> accList = new List<Account>();
        List<Frequent_Flyer_Information__c> FFList = new List<Frequent_Flyer_Information__c>();    
        String FFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Frequent Flyer Request').getRecordTypeId();
        String SORecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Offers Request').getRecordTypeId();
        ID recID;
        
        String results = '[{"key1":"JOYCE P WEST","key2":"456","key3":"xdkzwhzorm@uaowz.qca","key4":"Bronze","key5":"31-Jul-2019","key6":"Status Match","key7":"Gold"}]';    
        accList = QL_TestUtilityData.getAccounts();
        // Load Cases
        Case cs = new Case(Accountid=accList[0].ID,Status ='Not yet assigned - with Account Manager',Justification__c ='NA',Frequent_Flyer_Number__c ='0002750079');
        insert cs;
        
        
        //Dynamically add username & email 
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        system.debug('sandboxName'+sandboxName);
       //String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        system.debug('username:'+uniqueName + '@test' + orgId + sandboxName);
        system.debug('Email:'+uniqueName + '@test' + sandboxName + '.com');
       /* User tuser = new User(firstname = 'zzz01',
                              lastName = 'zzz01',
                              email = uniqueName + '@test' + sandboxName + '.com',
                              Username = uniqueName + '@test' + sandboxName + '.com',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = pf.Id);
        system.debug('userinfo'+tuser);        
        insert tuser; */
        
     //   system.runAs(tuser) {
            for(Integer i = 0; i < 5; i++) {
                Frequent_Flyer_Information__c  ffinfo = new Frequent_Flyer_Information__c(Account__c=accList[0].ID,Case__c =cs.Id,Frequent_Flyer_Number__c = '123',Request_Type__c='Manual Tier Upgrade',Upgrade_Tier_Requested__c='Silver',Current_Tier__c='Silver');
                FFList.add(ffinfo);
            }
            insert FFList;
            recID = cs.id;            
            Test.starttest();
            FreqFlyerSearchController.addParentCase(recID, accList[0].ID, results,FFRecordTypeId);
            Test.stoptest();
      //  }
    } 
}