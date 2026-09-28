@isTest
private class QCC_CAPCustomerDetailHelperTest {
    static{
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> listTriggerConfigs = new List<Trigger_Status__c>();
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        for(Trigger_Status__c triggerStatus : listTriggerConfigs){
            triggerStatus.Active__c = false;
        }
        insert listTriggerConfigs;
        List<Contact> contactList = new List<Contact>();
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '0006142207' , CAP_ID__c = '710000000023');
        // Create new contact - Update existing record
        Contact contact2 = new Contact(Firstname='David',Lastname='Boon' , Frequent_Flyer_Number__c = '00061422028' , CAP_ID__c ='710000000006');
        // Create new contact - Update existing record
        Contact contact3 = new Contact(Firstname='Gold',Lastname='FrequentFlyer' , Frequent_Flyer_Number__c = '00061422023' , CAP_ID__c ='710000000025', TECH_previousIds__c = '700000000037' );
        Contact contact4 = new Contact(Firstname='Gold',Lastname='FrequentFlyer' , Frequent_Flyer_Number__c = '00061422021' , CAP_ID__c ='700000000037');
        contactList.add(contact1);
        contactList.add(contact2);
        contactList.add(contact3);
        contactList.add(contact4);
        insert contactList;
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
    }
    @isTest static void testMethodGetContacts() {
        // Implement test code
        Map<String, List<QCC_CreatePassengerForEvents.CAPSearchWrapper>> mapToCusSearch = new Map<String, List<QCC_CreatePassengerForEvents.CAPSearchWrapper>>();
        List<QCC_CreatePassengerForEvents.CAPSearchWrapper> listCap = new List<QCC_CreatePassengerForEvents.CAPSearchWrapper>();
        
        QCC_CreatePassengerForEvents.CAPSearchWrapper wapper1 = new QCC_CreatePassengerForEvents.CAPSearchWrapper();
        wapper1.lastName = 'Chairmanslounge';
        wapper1.ffNumber = '0006142207';
        //wapper1.capId = '710000000023';
        wapper1.passengerId = '123456789';
        QCC_CreatePassengerForEvents.CAPSearchWrapper wapper2 = new QCC_CreatePassengerForEvents.CAPSearchWrapper();
        wapper2.lastName = 'boon';
        wapper2.ffNumber = '2345678782';
        //wapper2.capId = '710000000006';
        wapper2.passengerId = '123456788';
        
        listCap.add(wapper1);
        listCap.add(wapper2);
        mapToCusSearch.put('CAP', listCap);
        System.debug('Map====>'+mapToCusSearch);
        
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        Map<String , Contact> allContacts;
        Test.startTest(); 
        if(mapToCusSearch.size() > 0){
            //CRM-6427: CIP Decommissioning
         //  allContacts = QCC_CAPCustomerDetailHelper.getContacts(mapToCusSearch);
        }
        Test.stopTest();
        // Added by Purushotham on 25 SEP 2018 - Start
       // System.assertNotEquals(wapper1.capId, allContacts.get(wapper1.ffNumber).CAP_ID__c);
       // System.assertEquals(wapper2.ffNumber, allContacts.get(wapper2.ffNumber).Frequent_Flyer_Number__c);
        // Added by Purushotham on 25 SEP 2018 - End
    }
    
}