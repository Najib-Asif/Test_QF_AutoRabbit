@isTest
private class QCC_RevoveriesCallLoyaltyAPIQueueTest {
      private static final Id RTID_Rec_CustomerConnect = GenericUtils.getObjectRecordTypeId('Recovery__c', 'Customer Connect');

    
    private static List<Contact> listContactTest = new List<Contact>();
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
        //List<Trigger_Status__c> enableContactTrigger = TestUtilityDataClassQantas.enableTriggers();

        List<Trigger_Status__c> listTriggerStatusUpdate = [SELECT Id, Active__c FROM Trigger_Status__c];

        for(Trigger_Status__c triggerStatus : listTriggerStatusUpdate){
            triggerStatus.Active__c = false;
        }
        update listTriggerStatusUpdate;
        // Create Account
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        // CRETAE contact
        List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        listContactTest[0].Frequent_Flyer_Number__c = '0001511830'; 
        update listContactTest;
        // create eVENT
        Event__c eventTest = createEvent();
        Case caseTest = createCase(listContactTest[0].Id, eventTest.Id);
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
      

        newRecovery.Type__c = CustomSettingsUtilities.getConfigDataMap('RecoveryType');
        newRecovery.Contact__c = contactId;
        newRecovery.recordtypeId = RTID_Rec_CustomerConnect;
        newRecovery.Amount__c = 20;
        newRecovery.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusInitiated');
        newRecovery.Case_Number__c = caseId;
        insert newRecovery;
        return newRecovery;
    }

    @isTest static void testCallLoyaltyAPIQueueFailed() {
        String Body = '{ "success": false, "message": "fail"}';
        Map<String, String> mapHeader= new Map<String, String>();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(500, 'Error', Body, mapHeader));

        List<Recovery__c> recovery = [SELECT Id FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        ID jobID = System.enqueueJob(new QCC_RevoveriesCallLoyaltyAPIQueue(new Set<Id>{recovery[0].Id}));
        Test.stopTest();
        List<Recovery__c>  recoveryAfter = [SELECT Id, Status__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];

    }

    @isTest static void testCallLoyaltyAPIQueueSuccess() {
        String Body = '{ "success": true, "message": "Point Accrual information successfully updated", "member": {'+
                      '"memberid": 0001511830, "pointsbalance": 2 }, "othermemberdetails": { "emailid": "kevinliu@qantas.com.au"'+
                      '}, "reference": { "identifier": 787987122 }, "outcome": { "status": "SUCCESS", "reason": 0, "reasoncode": 0'+
                      '}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));

        List<Recovery__c> recovery = [SELECT Id FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
        ID jobID = System.enqueueJob(new QCC_RevoveriesCallLoyaltyAPIQueue(new Set<Id>{recovery[0].Id}));
        Test.stopTest();
        List<Recovery__c>  recoveryAfter = [SELECT Id, Status__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];

    }
    
}