/*----------------------------------------------------------------------------------------------------------------------
History
************************************************************************************************

16-Dec-2025     Capgemini-Philip     CRM-10358:Updated SOQL and DMLs for additional security                     

-----------------------------------------------------------------------------------------------------------------------*/
@isTest
private class EventTriggerHelperTest {
    @testSetup 
    static void setup() {
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        TestUtilityDataClassQantas.insertQantasConfigData();
        //List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();       
        //lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createFlightFailureSetting());
        for(Trigger_Status__c ts : lsttrgStatus){
            //if(ts.Name == 'EventTriggerUpdateEventFields')
            //ts.Active__c = false;
        }
        insert lsttrgStatus;
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_QSOAUserName','sampleuser1username@sample.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Non-TieredEventField','NoOfNonTieredPassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('BronzeEventField','NoOfBronzePassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SilverEventField','NoOfSilverPassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GoldEventField','NoOfGoldPassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('PlatinumEventField','NoOfPlatinumPassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Platinum OneEventField','NoOfPlatinumOnePassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Chairman\'s LoungeEventField','NoOfChairmansLoungePassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Chairman\'s Lounge Platinum Onefld','NoOfCLPlatinumOnePassenger__c'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Offload Passenger RecType','QCC Offload Passenger'));
        insert lstConfigData;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();

        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                               Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Team Lead').Id,
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        insert u1;
        System.debug(u1);
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }

        System.runAs(u1){
            Account acc        = TestUtilityDataClassQantas.createAccountOfQantasCorporateEmailAccount();
            acc.ABN_Tax_Reference__c = '11111111111';
            insert acc;
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup acc: '+acc);
            //Contact con        = TestUtilityDataClassQantas.createContact(acc.Id);
            //GRAPHITE-934
            Contact con = TestUtilityDataClassQantas.createIndividualContact(acc.Id);
            con.Business_Types__c = 'Agency';
            con.Job_Role__c       = 'Other';
            con.Function__c       = 'Other';
            insert con;
            con.AccountId         = acc.id;
            update con; 
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup con: '+con);
            System.debug('ZZZ in EmailMessageTriggerHelperTest testsetup con Acc Name: '+con.Account.Name);
            List<Event__c> events = new List<Event__c>();
            Event__c eventGlobal    = TestUtilityDataClassQantas.createEventWithValues('Global Event','Assigned', 'Flight Delay','Domestic');
            eventGlobal.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
            eventGlobal.GlobalEventName__c='Name';
            eventGlobal.Global_Event_Type__c='Airport Event';
            eventGlobal.Global_Event_Sub_Type__c='Fog';
            events.add(eventGlobal);

            Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
            newEvent1.ScheduledDepDate__c = System.today();
            newEvent1.Actual_Arrival_UTC__c = System.now();
            newEvent1.Estimated_Arrival_UTC__c = System.now();
            newEvent1.Operational_Carrier__c = 'QF';
            newEvent1.FlightNumber__c = 'QF0001';
            newEvent1.DeparturePort__c = 'SYD';
            newEvent1.ArrivalPort__c = 'MEL';
            events.add(newEvent1);
            Event__c newEvent2    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
            newEvent2.FlightNumber__c = 'QF0002';
            newEvent2.DeparturePort__c = 'SYD';
            newEvent2.ArrivalPort__c = 'MEL';
            newEvent2.ScheduledDepDate__c = System.today();
            events.add(newEvent2);
            Event__c newEvent3    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Cancellation','Domestic');
            newEvent3.NotifyEventOwner__c = true;
            newEvent3.FlightNumber__c = 'QF0003';
            newEvent3.DeparturePort__c = 'SYD';
            newEvent3.ArrivalPort__c = 'MEL';
            newEvent3.ScheduledDepDate__c = System.today();
            newEvent3.NotificationDateTime__c = System.Now().addHours(5);
            events.add(newEvent3);
            Event__c newEvent4   = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Closed','Closed', 'Flight Cancellation','Domestic');
            //newEvent4.OwnerId = u1.Id;
            newEvent4.CloseAction__c = 'Recoveries created and comms sent';
            newEvent4.NoCommsReason__c = 'test';
            newEvent4.FlightNumber__c = 'QF0004';
            newEvent4.DeparturePort__c = 'SYD';
            newEvent4.ArrivalPort__c = 'MEL';
            newEvent4.ScheduledDepDate__c = System.today();

            Event__c newEvent5   = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
            //newEvent4.OwnerId = u1.Id;
            //newEvent5.CloseAction__c = 'Comms not required';
            //newEvent5.NoCommsReason__c = 'test';
            newEvent5.Non_Delay_Failure_Code__c = '';
            newEvent5.Actual_Departure_UTC__c = System.Now();
            newEvent5.Scheduled_Depature_UTC__c = System.Now();
            newEvent5.FlightNumber__c = 'QF0005';
            newEvent5.DeparturePort__c = 'SYD';
            newEvent5.ArrivalPort__c = 'MEL';
            newEvent5.ScheduledDepDate__c = System.today();
            //events.add(newEvent5);

            Event__c newEvent6   = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Cancellation','Domestic');
            //newEvent4.OwnerId = u1.Id;
            //newEvent5.CloseAction__c = 'Comms not required';
            //newEvent5.NoCommsReason__c = 'test';
            newEvent6.Non_Delay_Failure_Code__c = '';
            newEvent6.FlightNumber__c = 'QF0006';
            newEvent6.DeparturePort__c = 'SYD';
            newEvent6.ArrivalPort__c = 'MEL';
            newEvent6.ScheduledDepDate__c = System.today();
            newEvent6.Actual_Departure_UTC__c = System.Now();
            newEvent6.Scheduled_Depature_UTC__c = System.Now().addHours(10);
            //events.add(newEvent6);

            insert events;
        }
    }

    /*static testMethod void testUpdateEventFields() {
        UserRole ur = [select Id from UserRole where DeveloperName = 'QF_QDC_CJM' ];//new UserRole(Name = 'QF-QDC-CJM', developerName= 'QF_QDC_CJM');
        //insert ur;
        User u1 = [Select Username, ProfileId from User where Username = 'sampleuser1username@sample.com'];
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        u1.ProfileId = profMap.get('Qantas CC Journey Manager').Id;
        u1.UserRoleId = ur.Id;
        update u1;

        Event__c event1   = [Select Id, Status__c, IsEventReopened__c,ReOpenedReason__c  From Event__c where  Status__c= 'Closed' Limit 1];
        String statusAssignEvent = CustomSettingsUtilities.getConfigDataMap('Event Open Status');
        
        System.runAs(u1){
            Test.startTest();
            event1.IsEventReopened__c = true;
            event1.ReOpenedReason__c ='test';
            event1.Status__c = statusAssignEvent;
            event1.CloseAction__c = '';
            update event1;
            Event__c eventAssigned  = [Select Id, Status__c From Event__c where id =: event1.id];
            system.assertEquals(statusAssignEvent, eventAssigned.Status__c);
            Test.stopTest();
        }
    }
	*/


    //static testMethod void testUpdateEventFields2() {
    //    Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
    //    User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'testUpdateEventFields@testUpdateEventFields.com', 
    //                           Username = 'testUpdateEventFields@testUpdateEventFields.com', ProfileId = profMap.get('Qantas CC Journey Manager').Id,
    //                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
    //                           TimeZoneSidKey = 'Australia/Sydney'
    //                          );        
    //    insert u1;
    //    //add User to chatter group
    //    List<CollaborationGroupMember> grMem = new List<CollaborationGroupMember>();
    //    Map<Id, CollaborationGroup> lstChatterGroup = new Map<ID, CollaborationGroup>([select id, name 
    //                                                                   from CollaborationGroup 
    //                                                                   where name in ('Qantas Event Group -- CJM', 'Qantas Event Group -- CCC')]);
    //    for(CollaborationGroup cg : lstChatterGroup.values()){
    //        grMem.add(New CollaborationGroupMember(CollaborationGroupId = cg.Id, MemberId = u1.id));
            
    //    }

    //    if(grMem.size() > 0){
    //        Database.insert(grMem, true);
    //    }

    //    //Event__c event1   = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
    //    //event1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
    //    //event1.NotificationDateTime__c = System.now().addMinutes(-1);
    //    String statusAssignEvent = CustomSettingsUtilities.getConfigDataMap('Event Assigned Status');
    //    Event__c event1   = [Select Id, Status__c From Event__c where Status__c= 'Closed' Limit 1];
    //    System.runAs(u1){
    //        Test.startTest();
    //        //insert event1;
    //        event1.IsEventReopened__c = true;
    //        event1.ReOpenedReason__c ='test';
    //        event1.OwnerId = u1.Id;
    //        update event1;
    //        Event__c eventAssigned  = [Select Id, Status__c From Event__c where id =: event1.id];
    //        system.assertEquals(statusAssignEvent, eventAssigned.Status__c);
    //        Test.stopTest();
    //    }
    //}

    static testMethod void testUpdateEventArrivingAtDestination_AutoClosedEvent() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        Event__c event1   = [Select Id, Status__c From Event__c where Status__c= 'Assigned' AND EstimatedDepDateTime__c = '2018-06-19 11:40:00' And DelayFailureCode__c='Flight Delay' Limit 1];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        event1.Estimated_Arrival_UTC__c = Datetime.now().addMinutes(-30);
        event1.Scheduled_Arrival_UTC__c = Datetime.now().addMinutes(-45);
        update event1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: event1.id];
        system.assertEquals('Assigned', eventClosed.Status__c);
        Test.stopTest();
    }


    static testMethod void testUpdateEventArrivingAtDestination_2() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepDate__c = System.today();
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.Actual_Arrival_UTC__c = System.now().addHours(10);
        newEvent1.Estimated_Arrival_UTC__c = System.now().addHours(10);
        newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        newEvent1.Status__c = 'Assigned';
        insert newEvent1;
        newEvent1.DelayFailureCode__c = 'Flight Cancellation';
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Assigned', eventClosed.Status__c);
        Test.stopTest();
    }

    static testMethod void testUpdateEventArrivingAtDestination_3() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Cancellation','Domestic');
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = System.today();
        
        newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        newEvent1.Status__c = 'Assigned';
        insert newEvent1;
        newEvent1.Actual_Arrival_UTC__c = System.now();
        newEvent1.Estimated_Arrival_UTC__c = System.now();
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Assigned', eventClosed.Status__c);
        Test.stopTest();
    }
    
    static testMethod void testUpdateEventArrivingAtDestination_4() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Cancellation','Domestic');
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = System.today();
        
        newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        newEvent1.Status__c = 'Assigned';
        insert newEvent1;
        newEvent1.Actual_Arrival_UTC__c = System.now();
        newEvent1.Estimated_Arrival_UTC__c = System.now();
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Assigned', eventClosed.Status__c);
        Test.stopTest();
    }

    static testMethod void tesClosedEvent_1() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Cancellation','Domestic');
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = System.today();
        
        //newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        insert newEvent1;
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(newEvent1.Id, listContactTest);
        //newEvent1.Actual_Arrival_UTC__c = System.now();
        //newEvent1.Estimated_Arrival_UTC__c = System.now();
        newEvent1.CloseAction__c = 'Recoveries created and comms sent';
        newEvent1.Status__c = 'Closed';
        update newEvent1;


        newEvent1.IsEventReopened__c = true;
        newEvent1.ReOpenedReason__c ='test';
        newEvent1.Status__c = 'Assigned';
        newEvent1.CloseAction__c = '';
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Assigned', eventClosed.Status__c);
        Test.stopTest();
    }
    static testMethod void tesClosedEvent_2() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Cancellation','Domestic');
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = System.today();
        
        //newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        insert newEvent1;

        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(newEvent1.Id, listContactTest);
        //newEvent1.Actual_Arrival_UTC__c = System.now();
        //newEvent1.Estimated_Arrival_UTC__c = System.now();
        newEvent1.CloseAction__c = 'Recoveries created and comms sent';
        newEvent1.Status__c = 'Closed';
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Closed', eventClosed.Status__c);
        Test.stopTest();
    }

    static testMethod void tesClosedEvent_3() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Global Event','Assigned', '','');
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        newEvent1.ScheduledDepDate__c = System.today();
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = System.today();
        
        //newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        insert newEvent1;
        Event__c newEvent2    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
        newEvent2.FlightNumber__c = 'QF0008';
        newEvent2.DeparturePort__c = 'SYD';
        newEvent2.ArrivalPort__c = 'MEL';
        newEvent2.ScheduledDepDate__c = System.today();
        newEvent2.GlobalEvent__c = newEvent1.id;
        insert newEvent2;
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(newEvent2.Id, listContactTest);
        //newEvent1.Actual_Arrival_UTC__c = System.now();
        //newEvent1.Estimated_Arrival_UTC__c = System.now();
        newEvent1.CloseAction__c = 'Comms not required';
        newEvent1.Status__c = 'Closed';
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Closed', eventClosed.Status__c);
        Test.stopTest();
    }
    
    static testMethod void tesClosedEvent_4() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
        newEvent1.FlightNumber__c = 'QF007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        newEvent1.ScheduledDepDate__c = System.today();
        //newEvent1.EstimatedDepDateTime__c = string.valueOf(System.Now());
        //newEvent1.ScheduledDepTime__c = '19:15';
        
        newEvent1.Operational_Carrier__c = 'QF';
        insert newEvent1;
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(newEvent1.Id, listContactTest);
        System.debug('##Test: '+newEvent1);
        newEvent1.CloseAction__c = 'Comms sent';
        newEvent1.Status__c = 'Closed';
        update newEvent1;
        System.debug('##Test: '+newEvent1);
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Closed', eventClosed.Status__c);
        Test.stopTest();
    }
    
    static testMethod void tesClosedEvent_5() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Global Event','Assigned', '','');
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        newEvent1.ScheduledDepDate__c = System.today();
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = System.today();
        
        //newEvent1.Operational_Carrier__c = 'QF';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        insert newEvent1;
        Event__c newEvent2    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
        newEvent2.FlightNumber__c = 'QF0008';
        newEvent2.DeparturePort__c = 'SYD';
        newEvent2.ArrivalPort__c = 'MEL';
        newEvent2.ScheduledDepDate__c = System.today();
        newEvent2.GlobalEvent__c = newEvent1.id;
        insert newEvent2;
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(newEvent2.Id, listContactTest);
        //newEvent1.Actual_Arrival_UTC__c = System.now();
        //newEvent1.Estimated_Arrival_UTC__c = System.now();
        newEvent1.CloseAction__c = 'Comms sent';
        newEvent1.Status__c = 'Closed';
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Closed', eventClosed.Status__c);
        Test.stopTest();
    }
    
    static testMethod void testAddStopEvent() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
        newEvent1.FlightNumber__c = 'QF0007';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        newEvent1.ScheduledDepDate__c = System.today();
        newEvent1.DelayFailureCode__c = 'Air Turn Back';
        //newEvent1.EstimatedDepDateTime__c = string.valueOf(System.Now());
        //newEvent1.ScheduledDepTime__c = '19:15';
        
        newEvent1.Operational_Carrier__c = 'QF';
        insert newEvent1;
        
        newEvent1.DelayFailureCode__c = 'Add Stop';
        update newEvent1;
        newEvent1.CloseAction__c = CustomSettingsUtilities.getConfigDataMap('Event Close Action Comms sent');
        newEvent1.Status__c = 'Closed';
        update newEvent1;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent1.id];
        system.assertEquals('Closed', eventClosed.Status__c);
        Test.stopTest();
    }
    
    static testMethod void tesClosedEvent_Offload() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Offload','Assigned', 'Flight Delay','International');
        newEvent.FlightNumber__c = 'QF0008';
        newEvent.DeparturePort__c = 'SYD';
        newEvent.ArrivalPort__c = 'MEL';
        newEvent.ScheduledDepDate__c = System.today();
        insert newEvent;
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        List<Affected_Passenger__c> listPassengersTest = new List<Affected_Passenger__c>();
        
        Affected_Passenger__c passenger1 = new Affected_Passenger__c();
        passenger1.Affected__c = true;
        passenger1.Name = 'AFDP-TEST'+ 1;
        passenger1.Event__c = newEvent.Id;
        passenger1.Email__c = 'afftest@testabc.com';
        passenger1.Cabin__c ='First Class'; 
        passenger1.FF_Tier__c = 'Silver';
        passenger1.FrequentFlyerTier__c ='Silver';
        passenger1.RecoveryIsCreated__c = false;
        passenger1.TECH_PreFlight__c = true;
        passenger1.TECH_PostFlight__c = true;
        passenger1.offloadRequest__c = 'Accepted';
        listPassengersTest.add(passenger1);
        
        Affected_Passenger__c passenger2 = new Affected_Passenger__c();
        passenger2.Affected__c = true;
        passenger2.Name = 'AFDP-TEST'+ 1;
        passenger2.Event__c = newEvent.Id;
        passenger2.Email__c = 'afftest@testabc.com';
        passenger2.Cabin__c ='Economy'; 
        passenger2.FF_Tier__c = 'Silver';
        passenger2.FrequentFlyerTier__c ='Silver';
        passenger2.RecoveryIsCreated__c = false;
        passenger2.TECH_PreFlight__c = true;
        passenger2.TECH_PostFlight__c = true;
        passenger2.offloadRequest__c = 'Accepted';
        listPassengersTest.add(passenger2);
        
        Affected_Passenger__c passenger3 = new Affected_Passenger__c();
        passenger3.Affected__c = true;
        passenger3.Name = 'AFDP-TEST'+ 3;
        passenger3.Event__c = newEvent.Id;
        passenger3.Email__c = '3afftest@testabc.com';
        passenger3.Cabin__c ='Premium Economy'; 
        passenger3.FF_Tier__c = 'Silver';
        passenger3.FrequentFlyerTier__c ='Silver';
        passenger3.RecoveryIsCreated__c = false;
        passenger3.TECH_PreFlight__c = true;
        passenger3.TECH_PostFlight__c = true;
        passenger3.offloadRequest__c = 'Accepted';
        listPassengersTest.add(passenger3);
        
        Affected_Passenger__c passenger4 = new Affected_Passenger__c();
        passenger4.Affected__c = true;
        passenger4.Name = 'AFDP-TEST'+ 4;
        passenger4.Event__c = newEvent.Id;
        passenger4.Email__c = '4afftest@testabc.com';
        passenger4.Cabin__c ='Business'; 
        passenger4.FF_Tier__c = 'Silver';
        passenger4.FrequentFlyerTier__c ='Silver';
        passenger4.RecoveryIsCreated__c = false;
        passenger4.TECH_PreFlight__c = true;
        passenger4.TECH_PostFlight__c = true;
        passenger4.offloadRequest__c = 'Accepted';
        listPassengersTest.add(passenger4);
        
        Affected_Passenger__c passenger5 = new Affected_Passenger__c();
        passenger5.Affected__c = true;
        passenger5.Name = 'AFDP-TEST'+ 5;
        passenger5.Event__c = newEvent.Id;
        passenger5.Email__c = 'afftest@testabc.com';
        passenger5.Cabin__c ='First Class'; 
        passenger5.FF_Tier__c = 'Silver';
        passenger5.FrequentFlyerTier__c ='Silver';
        passenger5.RecoveryIsCreated__c = false;
        passenger5.TECH_PreFlight__c = true;
        passenger5.TECH_PostFlight__c = true;
        passenger5.offloadRequest__c = 'Declined';
        listPassengersTest.add(passenger5);
        
        Affected_Passenger__c passenger6 = new Affected_Passenger__c();
        passenger6.Affected__c = true;
        passenger6.Name = 'AFDP-TEST'+ 6;
        passenger6.Event__c = newEvent.Id;
        passenger6.Email__c = 'afftest@testabc.com';
        passenger6.Cabin__c ='Economy'; 
        passenger6.FF_Tier__c = 'Silver';
        passenger6.FrequentFlyerTier__c ='Silver';
        passenger6.RecoveryIsCreated__c = false;
        passenger6.TECH_PreFlight__c = true;
        passenger6.TECH_PostFlight__c = true;
        passenger6.offloadRequest__c = 'Declined';
        listPassengersTest.add(passenger6);
        
        Affected_Passenger__c passenger7 = new Affected_Passenger__c();
        passenger7.Affected__c = true;
        passenger7.Name = 'AFDP-TEST'+ 7;
        passenger7.Event__c = newEvent.Id;
        passenger7.Email__c = '7afftest@testabc.com';
        passenger7.Cabin__c ='Premium Economy'; 
        passenger7.FF_Tier__c = 'Silver';
        passenger7.FrequentFlyerTier__c ='Silver';
        passenger7.RecoveryIsCreated__c = false;
        passenger7.TECH_PreFlight__c = true;
        passenger7.TECH_PostFlight__c = true;
        passenger7.offloadRequest__c = 'Declined';
        listPassengersTest.add(passenger7);
        
        Affected_Passenger__c passenger8 = new Affected_Passenger__c();
        passenger8.Affected__c = true;
        passenger8.Name = 'AFDP-TEST'+ 8;
        passenger8.Event__c = newEvent.Id;
        passenger8.Email__c = '8afftest@testabc.com';
        passenger8.Cabin__c ='Business'; 
        passenger8.FF_Tier__c = 'Silver';
        passenger8.FrequentFlyerTier__c ='Silver';
        passenger8.RecoveryIsCreated__c = false;
        passenger8.TECH_PreFlight__c = true;
        passenger8.TECH_PostFlight__c = true;
        passenger8.offloadRequest__c = 'Declined';
        listPassengersTest.add(passenger8);
        
        
        Affected_Passenger__c passenger9 = new Affected_Passenger__c();
        passenger9.Affected__c = true;
        passenger9.Name = 'AFDP-TEST'+ 9;
        passenger9.Event__c = newEvent.Id;
        passenger9.Email__c = 'afftest@testabc.com';
        passenger9.Cabin__c ='First Class'; 
        passenger9.FF_Tier__c = 'Silver';
        passenger9.FrequentFlyerTier__c ='Silver';
        passenger9.RecoveryIsCreated__c = false;
        passenger9.TECH_PreFlight__c = true;
        passenger9.TECH_PostFlight__c = true;
        passenger9.offloadRequest__c = 'Unable to contact';
        listPassengersTest.add(passenger9);
        
        Affected_Passenger__c passenger10 = new Affected_Passenger__c();
        passenger10.Affected__c = true;
        passenger10.Name = 'AFDP-TEST'+ 10;
        passenger10.Event__c = newEvent.Id;
        passenger10.Email__c = 'afftest@testabc.com';
        passenger10.Cabin__c ='Economy'; 
        passenger10.FF_Tier__c = 'Silver';
        passenger10.FrequentFlyerTier__c ='Silver';
        passenger10.RecoveryIsCreated__c = false;
        passenger10.TECH_PreFlight__c = true;
        passenger10.TECH_PostFlight__c = true;
        passenger10.offloadRequest__c = 'Unable to contact';
        listPassengersTest.add(passenger10);
        
        Affected_Passenger__c passenger11 = new Affected_Passenger__c();
        passenger11.Affected__c = true;
        passenger11.Name = 'AFDP-TEST'+ 11;
        passenger11.Event__c = newEvent.Id;
        passenger11.Email__c = '11afftest@testabc.com';
        passenger11.Cabin__c ='Premium Economy'; 
        passenger11.FF_Tier__c = 'Silver';
        passenger11.FrequentFlyerTier__c ='Silver';
        passenger11.RecoveryIsCreated__c = false;
        passenger11.TECH_PreFlight__c = true;
        passenger11.TECH_PostFlight__c = true;
        passenger11.offloadRequest__c = 'Unable to contact';
        listPassengersTest.add(passenger11);
        
        Affected_Passenger__c passenger12 = new Affected_Passenger__c();
        passenger12.Affected__c = true;
        passenger12.Name = 'AFDP-TEST'+ 12;
        passenger12.Event__c = newEvent.Id;
        passenger12.Email__c = '12afftest@testabc.com';
        passenger12.Cabin__c ='Business'; 
        passenger12.FF_Tier__c = 'Silver';
        passenger12.FrequentFlyerTier__c ='Silver';
        passenger12.RecoveryIsCreated__c = false;
        passenger12.TECH_PreFlight__c = true;
        passenger12.TECH_PostFlight__c = true;
        passenger12.offloadRequest__c = 'Unable to contact';
        listPassengersTest.add(passenger12);
        
        insert listPassengersTest;
        
        newEvent.CloseAction__c = 'Comms not required';
        newEvent.Status__c = 'Closed';
        update newEvent;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent.id];
        system.assertEquals('Closed', eventClosed.Status__c);
        Test.stopTest();
    }
    
    static testMethod void testReOpenEvent_Offload() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        Test.startTest();
        Event__c newEvent    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Offload','Assigned', 'Flight Delay','International');
        newEvent.FlightNumber__c = 'QF0012';  
        newEvent.DeparturePort__c = 'SYD';
        newEvent.ArrivalPort__c = 'MEL';
        newEvent.ScheduledDepDate__c = System.today();
        insert newEvent;
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);
        
        
        newEvent.CloseAction__c = 'Comms not required';
        newEvent.Status__c = 'Closed';
        update newEvent;
        Event__c eventClosed   = [Select Id, Status__c From Event__c where id =: newEvent.id];
        system.assertEquals('Closed', eventClosed.Status__c);
        
        newEvent.IsEventReopened__c = true;
        update newEvent;
        
        Test.stopTest();
    }

    //static testMethod void testUpdateEventArrivingAtDestination_FlightDelayLessThan5Hours() {
    //    User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
    //    Event__c event1   = [Select Id, Status__c, DelayFailureCode__c From Event__c where Status__c= 'Assigned' And DelayFailureCode__c='Flight Delay' Limit 1];
        
    //    Test.startTest();
    //    event1.Estimated_Arrival_UTC__c = Datetime.now().addMinutes(-20);
    //    event1.Scheduled_Arrival_UTC__c = Datetime.now().addMinutes(-90);
    //    update event1;
    //    Event__c eventDelayed   = [Select Id, DelayFailureCode__c From Event__c where id =: event1.id];
    //    system.assertEquals('Flight Delay', eventDelayed.DelayFailureCode__c);
    //    Test.stopTest();
    //}

    //static testMethod void testUpdateEventArrivingAtDestination_FlightDelayGreaterThan20Hours() {
    //    User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
    //    Event__c event1   = [Select Id, Status__c, DelayFailureCode__c From Event__c where Status__c= 'Assigned' And DelayFailureCode__c='Flight Delay' Limit 1];
        
    //    Test.startTest();
    //    event1.Estimated_Arrival_UTC__c = Datetime.now().addMinutes(-20);
    //    event1.Scheduled_Arrival_UTC__c = Datetime.now().addMinutes(-1800);
    //    update event1;
    //    Event__c eventDelayed   = [Select Id, DelayFailureCode__c From Event__c where id =: event1.id];
    //    system.assertEquals('Flight Delay', eventDelayed.DelayFailureCode__c);
    //    Test.stopTest();
    //}

    //static testMethod void testUpdateEventArrivingAtDestination_FlightDelayLessBetween5And20Hours() {
    //    User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
    //    Event__c event1   = [Select Id, Status__c, DelayFailureCode__c From Event__c where Status__c= 'Assigned' And DelayFailureCode__c='Flight Delay' Limit 1];
        
    //    Test.startTest();
    //    event1.Estimated_Arrival_UTC__c = Datetime.now().addMinutes(-20);
    //    event1.Scheduled_Arrival_UTC__c = Datetime.now().addMinutes(-450);
    //    update event1;
    //    Event__c eventDelayed   = [Select Id, DelayFailureCode__c From Event__c where id =: event1.id];
    //    system.assertEquals('Flight Delay', eventDelayed.DelayFailureCode__c);
    //    Test.stopTest();
    //}

    static testMethod void testUpdateAffectedPassenger() {
        List<Affected_Passenger__c> afpList = new List<Affected_Passenger__c>();
        Integer i = 1;
        Contact con = [SELECT Id FROM Contact];
        Event__c newEvent    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', '','Domestic');
        newEvent.DelayFailureCode__c = 'Flight Cancellation';
        newEvent.FlightNumber__c = 'QF0008';
        newEvent.DeparturePort__c = 'SYD';
        newEvent.ArrivalPort__c = 'MEL';
        newEvent.ScheduledDepDate__c = System.today();
        insert newEvent;
        List<Event__C> eventList = [SELECT Id, DelayFailureCode__c, Non_Delay_Failure_Code__c FROM Event__c where Status__c != 'Closed'];
        for(Event__c event: eventList) {
            Affected_Passenger__c afp = new Affected_Passenger__c();
            afp.Event__c = event.Id;
            afp.Name = 'Gold Frequentflyer'+i;
            afp.Passenger__c = con.Id;
            if(event.DelayFailureCode__c == 'Flight Cancellation') {
                afp.TECH_PreFlight__c = true;
                event.DelayFailureCode__c = 'Flight Delay';
            }
            else if(event.DelayFailureCode__c != null) {
                afp.TECH_PostFlight__c = true;
                afp.TECH_PreFlight__c = true;
                if(event.DelayFailureCode__c == 'Flight Delay') {
                    event.Non_Delay_Failure_Code__c = 'A/C Downgrade';
                    event.DelayFailureCode__c = null;
                }
                else if(event.DelayFailureCode__c == 'Flight Delay'){
                    event.DelayFailureCode__c = 'Flight Cancellation';
                }
                
            } else if(event.Non_Delay_Failure_Code__c != null && event.Non_Delay_Failure_Code__c != 'Flight Cancellation') {
                afp.TECH_PostFlight__c = true;
            }
            afpList.add(afp);
            i++;
        }
        Affected_Passenger__c afp = new Affected_Passenger__c();
        afp.Event__c = eventList[0].Id;
        afp.Name = 'Gold Frequentflyer'+i;
        afp.Passenger__c = con.Id;
        afpList.add(afp);
        if(afpList != null) {
            insert afpList;
        }
        List<Affected_Passenger__c> totalAfp = [SELECT Id, Affected__c FROM Affected_Passenger__c WHERE Event__c = :newEvent.Id ORDER BY Id];
        System.assertEquals(false, totalAfp[0].Affected__c);
        Test.startTest();
        //update eventList;
        Test.stopTest();
        List<Affected_Passenger__c> updatedTotalAfp = [SELECT Id, Affected__c FROM Affected_Passenger__c WHERE Event__c = :newEvent.Id ORDER BY Id];
        System.assertEquals(false, updatedTotalAfp[0].Affected__c);
    }

    static testMethod void testCreateRecovery() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        Event__c event1   = [Select Id, Status__c, recordtypeId From Event__c where Status__c = 'Assigned' Limit 1];
        String statusAssignEvent = CustomSettingsUtilities.getConfigDataMap('Event Assigned Status');
        List<Trigger_Status__c> listConfigTrigger =  TestUtilityDataClassQantas.createContactTriggerSetting();
        listConfigTrigger.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        for(Trigger_Status__c triggerConfig: listConfigTrigger){
            triggerConfig.Active__c = false;
        }
        insert listConfigTrigger;
        // Create Account
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        // CRETAE contact
        //List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        //GRAPHITE-934
        List<Contact> listContactTest = TestUtilityDataClassQantas.getIndividualContacts(listAccountTest);

        // CREATE affected Passenger
        List<Affected_Passenger__c> listPassengersTest = createAffectedPassenger(event1.Id, listContactTest);
        System.runAs(u1){
            Test.startTest();
            try{
            event1.Status__c = 'Closed';
            event1.IsEventReopened__c = false;
            event1.EstimatedDepDateTime__c = '29/10/2018 19:00:00';
            event1.ScheduledDepTime__c = '19:15';
            event1.CloseAction__c  = CustomSettingsUtilities.getConfigDataMap('Event Close Action Recovery And Comms');
            event1.RecordTypeId = GenericUtils.getObjectRecordTypeId('Event__c', 'Flight Event - Closed');
            update event1;
            Event__c eventClosed  = [Select Id, Status__c From Event__c where id =: event1.id];
            system.assertEquals('Closed', eventClosed.Status__c);
            }catch (Exception ex){}
            Test.stopTest();
        }
        
    }

    static testMethod void testCreateRecovery_Error() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        Event__c event1   = [Select Id, Status__c From Event__c where Status__c = 'Assigned' Limit 1];
        String statusAssignEvent = CustomSettingsUtilities.getConfigDataMap('Event Assigned Status');
        
        System.runAs(u1){
            Test.startTest();
            event1.Status__c = 'Closed';
            event1.IsEventReopened__c = false;
            event1.EstimatedDepDateTime__c = '2018/06/19 11:40:00';
            event1.ScheduledDepTime__c = '19:15';
            event1.CloseAction__c  = CustomSettingsUtilities.getConfigDataMap('Event Close Action Recovery And Comms');
            event1.RecordTypeId = GenericUtils.getObjectRecordTypeId('Event__c', 'Flight Event - Closed');
            try{

                 update event1;
                }catch(Exception ex){
                    //system.assert(ex.getMessage().contains(CustomSettingsUtilities.getConfigDataMap('Recovery Submitted No Passenger Msg')));
                }
            Test.stopTest();
        }
    }

    static testMethod void testInvokePaggengerAPI() {
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        Event__c event1   = [Select Id, Status__c From Event__c where Status__c = 'Assigned' Limit 1];
        String statusAssignEvent = CustomSettingsUtilities.getConfigDataMap('Event Assigned Status');
        List<Qantas_API__c> listAPIConfig = TestUtilityDataClassQantas.createQantasAPI();
        insert listAPIConfig;
        System.runAs(u1){
            String Body = '{"passengers": [{"passengerId": "527522793835393", "customerId": "710000000025","firstName": "GOLD","lastName": "FREQUENTFLYER",' +
            '"namePrefix": "MS","genderTypecode": "F","paxTypeCode": null,"dateOfBirth": null,"qfFrequentFlyerNumber": "0006142209",' +
            '"qfTierCode": "FFGD","bookingReference": "TYDSN6","bookingCreationDate": "2018-02-02","bookingId": "86837460060226","segmentId": "10209019122211170",' +
            '"segmentTattoo": 4, "passengerSegId": "9701041296764256", "offPoint": "BNE", "marketingCarrier": "QF", "marketingFlightNumber": "0516",' +
            '"bookedCabinClass": "Y", "bookedReservationClass": "Q", "reservationStatusCode": "HK", "leg": [ { "sequenceNumber": 1, "originPort": "SYD",' +
            '"destinationPort": "BNE","checkinStatus": "CRJ","boardStatus": "NBD","seatNo": null}],' +
            '"customerContactDetails": { "address": [{ "typeCode": "H", "line1": "15", "line2": "", "line3": "", "line4": "hassall st",' +
            '"suburb": "westmead", "postCode": "2145", "state": "nsw", "country": "AU", "countryName": "AUSTRALIA" },' + 
            '{ "typeCode": "B", "line1": "55", "line2": "", "line3": "bellavue",  "line4": "good st", "suburb": "westmead", "postCode": "2145",' + 
            '"state": "nsw", "country": "AU", "countryName": "AUSTRALIA"  }  ], "email": [ { "typeCode": "H", "id": "gold.frequentflyer1@mailinator.com" } ],' + 
            '"phone": [ { "typeCode": "H",  "phoneCountryCode": "61", "phoneAreaCode": "02", "phoneLineNumber": "99789034", "phoneExtension": "" }] },' +
            '"otherLoyaltyDetails": { "homeCity": null,  "tier": { "old": null, "new": null, "changeDate": null },' +
            '"domesticTravelPreference": { "meal": { "code": null, "description": null }, "seat": { "code": null, "description": null } },' +
            '"internationalTravelPreference": { "meal": { "code": null, "description": null }, "seat": { "code": null, "description": null } },'+
            '"epLinkedIndicator": null } } ] }';
            Map<String, String> mapHeader= new Map<String, String>();
            mapHeader.put('Content-Type', 'application/json');
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
            event1.Operational_Carrier__c = 'QF';
            event1.FlightNumber__c = 'QF1234';
            event1.ScheduledDepDate__c = System.today();
            event1.DeparturePort__c = 'FEN';
            event1.ArrivalPort__c =  'MEL';

            
            update event1;
            Test.stopTest();
        }
    }


    private static List<Affected_Passenger__c> createAffectedPassenger(Id eventId, List<Contact> listContact){
        List<Affected_Passenger__c> listAffectedPassenger = new List<Affected_Passenger__c>();
        for(Integer i = 1; i <= listContact.size(); i++){
            Affected_Passenger__c passenger = new Affected_Passenger__c();
            passenger.Affected__c = true;
            passenger.Name = 'AFDP-TEST' + String.valueOf(i);
            passenger.Passenger__c = listContact[i-1].Id;
            passenger.Event__c = eventId;
            passenger.Email__c = String.valueOf(i) + 'afftest@testabc.com';
            passenger.Cabin__c ='First Class'; 
            passenger.FF_Tier__c = 'Silver';
            passenger.FrequentFlyerTier__c ='Silver';
            passenger.RecoveryIsCreated__c = false;
            passenger.TECH_PreFlight__c = true;
            passenger.TECH_PostFlight__c = true;
            if(i == 2){
                passenger.Cabin__c ='Business'; 
                passenger.FF_Tier__c = 'Non-Tiered';
                passenger.FrequentFlyerTier__c = 'Non-Tiered';
                passenger.FrequentFlyerNumber__c = '0006142209';
            }
            if(i == 3){
                passenger.Cabin__c ='Premium Economy'; 
                passenger.FF_Tier__c = 'Gold';
                passenger.FrequentFlyerTier__c = 'Gold';
            }

            listAffectedPassenger.add(passenger);
        }
        insert listAffectedPassenger;
        return listAffectedPassenger;
    }
}