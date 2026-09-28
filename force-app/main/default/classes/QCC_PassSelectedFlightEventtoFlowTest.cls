/*========================================================================================================================
 * Created By   : Gnanavelu
 * Description  : Test Class for QCC_PassSelectedFlightEventtoFlow 
 * JIRA         : CRM-3943
 
Modified By : Venkata Suresh Kumar (TCS Team), 19-June-2026
Desc : Remediated test class failures. Updated PassSelectedFlightEventtoFlowTest() method.
==========================================================================================================================*/
@isTest
public class QCC_PassSelectedFlightEventtoFlowTest {
    
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
                               Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences //CRM-11910 - RBAC Updated Profile name to QCC Customer Journey Manager
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        insert u1;
        //CRM-11908 Update metadata rerferences
        //CRM-11910 - RBAC added permissions to test user
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
            Contact con        = TestUtilityDataClassQantas.createContact(acc.Id);
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
            events.add(newEvent5);

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
            events.add(newEvent6);

            insert events;
        }
    }
    
    
    @isTest
    public static void PassSelectedFlightEventtoFlowTest()
    {
        //Insert Trigger Settings
     /*   List<Trigger_Status__c> trgrStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        insert trgrStatus;
        
        Id eventRecordtypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get('Active_Event').getRecordTypeId(); 
        
        List<Event__c> eventList = new List<Event__c>();
        Event__c event = new Event__c();
        event.Name = 'QF0001 100919S';
        event.FlightNumber__c = 'QF0001';
        event.Flight_Status__c = 'LANDED';
        event.DeparturePort__c = 'SIN';
        event.ArrivalPort__c = 'LHR';
        event.IntDom__c = 'International';
        event.RecordTypeId = eventRecordtypeId;
        
        eventList.add(event);
        insert eventList;*/
        
         UserRole ur = [select Id from UserRole where DeveloperName = 'QF_QDC_CJM' ];//new UserRole(Name = 'QF-QDC-CJM', developerName= 'QF_QDC_CJM');
        //insert ur;
        User u1 = [Select Username, ProfileId from User where Username = 'sampleuser1username@sample.com'];
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        u1.ProfileId = profMap.get('QCC Customer Journey Manager').Id;
        u1.UserRoleId = ur.Id;
        update u1;


        Event__c event1   = [Select Id, Status__c, IsEventReopened__c,ReOpenedReason__c  From Event__c where  Status__c= 'Closed' Limit 1];
        String statusAssignEvent = CustomSettingsUtilities.getConfigDataMap('Event Open Status');
        List<Event__c> evetlst = new List<Event__c>();
        evetlst.add(event1);
        
        System.runAs(u1){
		Event__c newEvent4   = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Closed','Closed', 'Flight Cancellation','Domestic');
		newEvent4.CloseAction__c = 'Recoveries created and comms sent';
		newEvent4.NoCommsReason__c = 'test';
		newEvent4.FlightNumber__c = 'QF0004';
		newEvent4.DeparturePort__c = 'SYD';
		newEvent4.ArrivalPort__c = 'MEL';
		newEvent4.ScheduledDepDate__c = System.today();
		Insert newEvent4;
		evetlst.add(newEvent4);
		
        Test.startTest();
        Test.setCurrentPage(Page.QCC_GetSelectedFlightEvents);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(evetlst);
        stdSetController.setSelected(evetlst);
        QCC_PassSelectedFlightEventtoFlow ext = new QCC_PassSelectedFlightEventtoFlow(stdSetController);
        Test.stopTest();
        }
    }
    
}