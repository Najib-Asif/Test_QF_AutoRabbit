@isTest(seeAllData = false)
private class RecoveryActionPlanControllerTest {
    
    @testSetup
    static void setup() {
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;
        //CRM-11908 Updated Role for the User
        Map<String, UserRole> rolesMap = TestUtilityDataClassQantas.getRoles();
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
            Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU', Location__c = 'Sydney',
            TimeZoneSidKey = 'Australia/Sydney');
        insert u1;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //CRM-11908 Updated Role for the User 
            u1.UserRoleId =  rolesMap.get('QF-QDC-CJM').Id; 
            update u1;
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }
      
        // Create events
       System.runAs(u1){
        List<Event__c> events = new List<Event__c>();
        Event__c newEvent1 = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active', 'Assigned', 'Flight Delay', 'Domestic');
        //newEvent1.OwnerId = u1.Id;
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = Date.newInstance(2018, 06, 18);
        newEvent1.FlightNumber__c = 'QF0401';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        events.add(newEvent1);

        // Add other event records similarly (newEvent2, newEvent3, etc.)

        insert events;
        Event__c objEvt = [Select Id from Event__c limit 1];
        EventActionPlan__c objActionPlan = new EventActionPlan__c();
        objActionPlan.Name = 'CJL: Meals';
        objActionPlan.ActionCompleted__c = true;
        objActionPlan.Comments__c = 'Completed';
        objActionPlan.FlightEvent__c = newEvent1.Id;
        insert objActionPlan; 
       }
    }

    @isTest
        static  void getReimbursementDataTest(){
        
       
     
        Event__c objEvt = [Select Id from Event__c limit 1];
        
        
        Test.startTest();
        List<EventActionPlan__c> result = RecoveryActionPlanController.getReimbursementData(objEvt.Id, 'CJL: Meals');
        Test.stopTest();
        System.assertNotEquals(0, result.size(), 'There should be results.');
        System.assertEquals('CJL: Meals', result[0].Name, 'The action plan name should match.');
    }
}