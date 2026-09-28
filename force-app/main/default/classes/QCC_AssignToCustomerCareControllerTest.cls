@isTest
public class QCC_AssignToCustomerCareControllerTest {
    @testSetup 
    static void setup() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();       
        //lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            //if(ts.Name == 'EventTriggerArrivingAtDestination'){
                ts.Active__c = false;
            //}
        }
        insert lsttrgStatus;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();

        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                               Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Journey Manager').Id,
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        System.runAs(u1){
            Account acc        = TestUtilityDataClassQantas.createAccountOfQantasCorporateEmailAccount();
            acc.ABN_Tax_Reference__c = '11111111111';
            insert acc;
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup acc: '+acc);
            Contact con        = TestUtilityDataClassQantas.createContact(acc.Id);
            con.Business_Types__c = 'Agency';
            con.Job_Role__c       = 'Other';
            con.Function__c       = 'Other';
            insert con;
            con.AccountId         = acc.id;
            update con; 
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup con: '+con);
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup con Acc Name: '+con.Account.Name);
            Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Diversion Due to Weather','Domestic');
            newEvent1.OwnerId = u1.Id;
            insert newEvent1;
        }
    }
    //@isTest
 //   static void testGetBasicInfo(){
 //       User u = [Select id, Name, City,location__c, profileId, profile.Name from User Where id=:UserInfo.getUserId()];
 //       System.assertEquals(QCC_AssignToCustomerCareController.getBasicInfo(), u.profile.Name);
 //   }
    
    @isTest
    static void testAssign1(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
            List<Event__c> lstEvent = [Select id, name,  OwnerId,Status__c from Event__c];
            List<Group> listQueue = [Select id, name from Group where Type='Queue' AND developerName='QCC_EventsAssigned'];

            QCC_AssignToCustomerCareController.doAssignToCustomerCare(lstEvent[0].id);
            lstEvent = [Select id, name,  OwnerId,Status__c from Event__c];
            System.assertEquals(listQueue[0].id , lstEvent[0].OwnerId);
            System.assertEquals('Assigned' , lstEvent[0].Status__c);
        }
    }

    @isTest
    static void testAssign2(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
            List<Event__c> lstEvent = [Select id, name,  OwnerId,Status__c from Event__c];
            
            List<Group> listQueue = [Select id, name from Group where Type='Queue' AND developerName='QCC_EventsAssigned'];
            lstEvent[0].Status__c = 'Assigned';
            lstEvent[0].OwnerId = listQueue[0].id;
            update lstEvent;

            String rs = QCC_AssignToCustomerCareController.doAssignToCustomerCare(lstEvent[0].id);
            System.assertEquals('Error: ' + 'Event is already assigned.', rs);
        }
    }
    @isTest
    static void testAssign3(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
            List<Event__c> lstEvent = [Select id, name,  OwnerId,Status__c from Event__c];
            List<Group> listQueue = [Select id, name from Group where Type='Queue' AND developerName='QCC_EventsAssigned'];
            lstEvent[0].Status__c = 'Assigned';
            update lstEvent;

            QCC_AssignToCustomerCareController.doAssignToCustomerCare(lstEvent[0].id);
            lstEvent = [Select id, name,  OwnerId,Status__c from Event__c];
            System.assertEquals(listQueue[0].id , lstEvent[0].OwnerId);
            System.assertEquals('Assigned' , lstEvent[0].Status__c);
        }
    }
    @isTest
    static void testAssign4(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
            List<Event__c> lstEvent = [Select id, name,  OwnerId,Status__c, recordtypeId from Event__c];
            lstEvent[0].Status__c = 'Closed';
            lstEvent[0].recordtypeId = GenericUtils.getObjectRecordTypeId('Event__c', 'Flight Event - Closed');
            update lstEvent;

            QCC_AssignToCustomerCareController.doAssignToCustomerCare(lstEvent[0].id);
            lstEvent = [Select id, name,  OwnerId,Status__c from Event__c];
            System.assertEquals('Closed' , lstEvent[0].Status__c);
        }
    }
    
    @isTest
    static void testAssign5(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        System.runAs(u){
            List<Event__c> lstEvent = [Select id, name,  OwnerId,Status__c, recordtypeId from Event__c];
            List<Group> listQueue = [Select id, name from Group where Type='Queue' AND developerName='QCC_EventsAssigned'];
            lstEvent[0].Status__c = 'Closed';
            lstEvent[0].recordtypeId = GenericUtils.getObjectRecordTypeId('Event__c', 'Flight Event - Closed');
            update lstEvent;

            String result = QCC_AssignToCustomerCareController.doAssignToCustomerCare('000000000000000');
            System.assertEquals('Error: ' + ' Some error occurred!' , result);
        }
    }
    
}