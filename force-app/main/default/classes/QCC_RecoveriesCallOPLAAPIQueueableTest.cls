@isTest
public class QCC_RecoveriesCallOPLAAPIQueueableTest {
    @testSetup
    static void createTestData(){
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> listConfigEventTrigger = TestUtilityDataClassQantas.createEventTriggerSetting();
        insert listConfigEventTrigger;
        List<Trigger_Status__c> listConfigContactTrigger =  TestUtilityDataClassQantas.createContactTriggerSetting();
        insert listConfigContactTrigger;
        List<Trigger_Status__c> listConfigRecoveryTrigger =  TestUtilityDataClassQantas.createRecoveryTriggerSetting();
        insert listConfigRecoveryTrigger;
        List<Trigger_Status__c> listConfigCaseTrigger =  TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert listConfigCaseTrigger;

        List<Trigger_Status__c> listTriggerStatusUpdate = [SELECT Id, Active__c FROM Trigger_Status__c];

        for(Trigger_Status__c triggerStatus : listTriggerStatusUpdate){
            triggerStatus.Active__c = false;
        }
        update listTriggerStatusUpdate;
        // Create Account
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        // CRETAE contact
        List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        listContactTest[0].Frequent_Flyer_Number__c = '0006142104'; 
        listContactTest[0].CAP_ID__c = '313442'; 
        listContactTest[0].firstname = 'W';
        listContactTest[0].lastname = 'FYSH';
        listContactTest[0].email = 'ibstestonlinesalesqueries@qantas.com.au';
        update listContactTest;
        // create eVENT
        Event__c eventTest = createEvent();
        Case caseTest = createCase(listContactTest[0].Id, eventTest.Id);
        caseTest.first_name__c = listContactTest[0].firstname;
        caseTest.last_name__c = listContactTest[0].lastname;
        update caseTest;
        Recovery__c recoveryTest = createRcovery(caseTest.Id, listContactTest[0].Id);
        List<Qantas_API__c> listAPIConfig = TestUtilityDataClassQantas.createQantasAPI();
        insert listAPIConfig;
    }

    private static Event__c createEvent(){
        Id recordTypeEventActive = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type'));
        Event__c newEvent = new Event__c();
        newEvent.RecordTypeId = recordTypeEventActive;
        newEvent.Status__c = CustomSettingsUtilities.getConfigDataMap('Event Open Status');
        newEvent.DelayFailureCode__c = 'Diversion Due to Weather';
        newEvent.GoldBusiness__c = 1;
        newEvent.GoldEconomy__c = 2;
        newEvent.GoldFirstClass__c = 3;
        newEvent.GoldPremiumEconomy__c = 4;
        newEvent.NonTieredBusiness__c = 5;
        newEvent.NonTieredEconomy__c = 6;
        newEvent.NonTieredFirstClass__c = 7;
        newEvent.NonTieredPremiumEconomy__c = 8;
        newEvent.PlatinumBusiness__c = 9;
        newEvent.PlatinumEconomy__c = 10;
        newEvent.PlatinumFirstClass__c = 11;
        newEvent.PlatinumPremiumEconomy__c = 12;
        newEvent.Platinum1SSUBusiness__c = 13;
        newEvent.Platinum1SSUEconomy__c = 14;
        newEvent.Platinum1SSUFirstClass__c = 15;
        newEvent.Platinum1SSUPremiumEconomy__c = 16;
        newEvent.SilverBusiness__c = 17;
        newEvent.SilverEconomy__c = 18;
        newEvent.SilverFirstClass__c = 19;
        newEvent.SilverPremiumEconomy__c = 20;
        newEvent.BronzeBusiness__c = 21;
        newEvent.BronzeEconomy__c = 22;
        newEvent.BronzeFirstClass__c = 23;
        newEvent.BronzePremiumEconomy__c = 24;
        insert newEvent;
        return newEvent;
    }

    private static Case createCase(String contactId, String eventId){
        Id caseOriginRecTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType'));
        Case newCase = new Case();
        newCase.RecordTypeId = caseOriginRecTypeId;
        newCase.Origin = CustomSettingsUtilities.getConfigDataMap('Case Origin Event');
        newCase.Status = CustomSettingsUtilities.getConfigDataMap('CaseStatusOpen');
        newCase.Type = CustomSettingsUtilities.getConfigDataMap('Case Type Event');
        newCase.ContactId = contactId;
        newCase.Event__c = eventId;
        newCase.Contact_Email__c = 'test@test.com';
        newCase.Subject = CustomSettingsUtilities.getConfigDataMap('Case Subject Event');
        newCase.Cabin_Class__c = 'Premium Economy';
        newCase.FF_Tier__c = 'Gold';
        newCase.Group__c = CustomSettingsUtilities.getConfigDataMap('Case Group Event');
        newCase.Priority = CustomSettingsUtilities.getConfigDataMap('Case Priority Medium');

        insert newCase;
        return newCase;
    }

    private static Recovery__c createRcovery(String caseId, String contactId){

        Recovery__c newRecovery = new Recovery__c();
        newRecovery.Type__c = CustomSettingsUtilities.getConfigDataMap('Qantas Club Lounge Passes');
        newRecovery.Contact__c = contactId;
        newRecovery.Amount__c = 20;
        newRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusSubmitForFinalisation');
        newRecovery.Case_Number__c = caseId;
        insert newRecovery;
        return newRecovery;
    }

    @isTest static void testCallOPLAAPIQueueFailed() {
        List<Contact> contacts = [SELECT Id, Frequent_Flyer_Number__c FROM Contact];
        contacts[0].Frequent_Flyer_Number__c = null;
        update contacts[0];
        String Body = '{ "success": false, "referenceNo": "R-0213412", "errorMessage": "Internal Server Error"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(500, 'Error', Body, mapHeader));

        List<Recovery__c> recovery = [SELECT Id FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        ID jobID = System.enqueueJob(new QCC_RecoveriesCallOPLAAPIQueueable(new Set<Id>{recovery[0].Id}));
        Test.stopTest();
        List<Recovery__c>  recoveryAfter = [SELECT Id, Status__c,process_status__c,LoungePassErrorMessage__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        System.assertEquals('No Frequent Flyer contact available, add Frequent Flyer contact and then resubmit recovery', recoveryAfter[0].LoungePassErrorMessage__c);
    }

    @isTest static void testCallOPLAAPIQueueSuccess() {
        List<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
        String BodyLoyalty = '{"memberId":"0006142104","firstName":"W","lastName":"FYSH","mailingName":"MR W FYSH","salutation":"Dear Mr Fysh","title":"MR","dateOfJoining":"1996-05-13","gender":"MALE","dateOfBirth":"1996-11-07","email":"ibstestonlinesalesqueries@qantas.com.au","emailType":"BUSINESS","countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"HOME","pointBalance":11326,"company":{"name":"DO NOT CHANGE ANYTHING - PH JAMIE X62542","positionInCompany":"TEST PROFILE - DIGITAL DIRECT"},"phoneDetails":[{"type":"BUSINESS","number":"96912542","areaCode":"02","idd":"+61","status":"V"}],"addresses":[{"type":"HOME","lineOne":"10 BOURKE ROAD","suburb":"SYDNEY","postCode":"3000","state":"VIC","countryCode":"AU","status":"I"}],"preferences":{"ffsAirlines":[{"id":1,"number":"SK198253","airline":"CO"}],"leisureInterests":["BALL","CLMU","JAZZ"],"sportInterests":["BABL","BSBL","CYCL","SQSH","ARFB"]},"programDetails":[{"programCode":"QCASH","programName":"Qantas Cash","enrollmentDate":"2015-04-28","accountStatus":"ACTIVE","qcachSendMarketing":false,"qcashProgramIdentifier":"AU","activationFlag":"N"},{"programCode":"QC","programName":"Qantas Club","enrollmentDate":"2017-08-02","expiryDate":"2018-07-31","accountStatus":"PAYMENT_DUE","qcEnrolType":0},{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrollmentDate":"1996-05-13","accountStatus":"ACTIVE","tierCode":"FFPL","tierFromDate":"2017-08-02"},{"programCode":"CL","programName":"Chairmans Lounge","enrollmentDate":"2017-08-02","expiryDate":"2019-08-31","accountStatus":"ACTIVE","clMemberType":"PRIME"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-07-31","lifetime":430,"total":430,"loyaltyBonus":0},"tier":{"name":"Chairmans Lounge","code":"FFPL","startDate":"2017-08-02","effectiveTier":"CLQF"}}';
        String BodyOpla = '{ "success": true, "referenceNo": "R-0213412", "errorMessage": ""}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', BodyLoyalty, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(202, 'Success', BodyOpla, mapHeader));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));
        //Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));

        List<Recovery__c> recovery = [SELECT Id FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        ID jobID = System.enqueueJob(new QCC_RecoveriesCallOPLAAPIQueueable(new Set<Id>{recovery[0].Id}));
        Test.stopTest();
        List<Recovery__c>  recoveryAfter = [SELECT Id, Status__c,LoungePassReference__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        System.assertEquals('R-0213412', recoveryAfter[0].LoungePassReference__c);

    }

    @isTest static void testCallOPLAAPIQueueMissingRequiredField() {
        String BodyLoyalty = '{"memberId":"0006142104","firstName":"W","lastName":"Test","mailingName":"MR W FYSH","salutation":"Dear Mr Fysh","title":"MR","dateOfJoining":"1996-05-13","gender":"MALE","dateOfBirth":"1996-11-07","email":"ibstestonlinesalesqueries@qantas.com.au","emailType":"BUSINESS","countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"HOME","pointBalance":11326,"company":{"name":"DO NOT CHANGE ANYTHING - PH JAMIE X62542","positionInCompany":"TEST PROFILE - DIGITAL DIRECT"},"phoneDetails":[{"type":"BUSINESS","number":"96912542","areaCode":"02","idd":"+61","status":"V"}],"addresses":[{"type":"HOME","lineOne":"10 BOURKE ROAD","suburb":"SYDNEY","postCode":"3000","state":"VIC","countryCode":"AU","status":"I"}],"preferences":{"ffsAirlines":[{"id":1,"number":"SK198253","airline":"CO"}],"leisureInterests":["BALL","CLMU","JAZZ"],"sportInterests":["BABL","BSBL","CYCL","SQSH","ARFB"]},"programDetails":[{"programCode":"QCASH","programName":"Qantas Cash","enrollmentDate":"2015-04-28","accountStatus":"ACTIVE","qcachSendMarketing":false,"qcashProgramIdentifier":"AU","activationFlag":"N"},{"programCode":"QC","programName":"Qantas Club","enrollmentDate":"2017-08-02","expiryDate":"2018-07-31","accountStatus":"PAYMENT_DUE","qcEnrolType":0},{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrollmentDate":"1996-05-13","accountStatus":"ACTIVE","tierCode":"FFPL","tierFromDate":"2017-08-02"},{"programCode":"CL","programName":"Chairmans Lounge","enrollmentDate":"2017-08-02","expiryDate":"2019-08-31","accountStatus":"ACTIVE","clMemberType":"PRIME"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-07-31","lifetime":430,"total":430,"loyaltyBonus":0},"tier":{"name":"Chairmans Lounge","code":"FFPL","startDate":"2017-08-02","effectiveTier":"CLQF"}}';
        String BodyOpla = '{ "success": false, "referenceNo": "R-0213412", "errorMessage": "Missing required field"}';
        List<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', BodyLoyalty, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(400, 'Error', BodyOpla, mapHeader));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));

        List<Recovery__c> recovery = [SELECT Id FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        ID jobID = System.enqueueJob(new QCC_RecoveriesCallOPLAAPIQueueable(new Set<Id>{recovery[0].Id}));
        Test.stopTest();
        List<Recovery__c>  recoveryAfter = [SELECT Id, Status__c, LoungePassErrorMessage__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        System.assertEquals('Customer\'s frequent flyer details are not valid', recoveryAfter[0].LoungePassErrorMessage__c);

    }
}