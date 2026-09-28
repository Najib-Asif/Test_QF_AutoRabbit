@IsTest
public class DeleteOffloadPassengersSchedulableTest {
    @TestSetUp
    public static void testSetUp(){
        Airport_Code__c dCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c  ='NSW');
        insert dCode;
        Airport_Code__c aCode = new Airport_Code__c(Name = 'MEL', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Melbource', Freight_Airport_State_Code__c  ='NSW');
        insert aCode;
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
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
                               Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        insert u1;
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
            //GRAPHITE-934 Create a new utility method to create contact record with Record Type = Individual Contact
            //Contact con           = TestUtilityDataClassQantas.createContact(acc.Id);
            Contact con = TestUtilityDataClassQantas.createIndividualContact(acc.Id);
            con.Business_Types__c = 'Agency';
            con.Job_Role__c       = 'Other';
            con.Function__c       = 'Other';
            insert con;
            con.AccountId         = acc.id;
            update con;
            List<Event__c> events = new List<Event__c>();
            Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','Domestic');
            newEvent1.OwnerId = u1.Id;
            newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
            newEvent1.ScheduledDepTime__c = '19:15';
            newEvent1.ScheduledDepDate__c = Date.newInstance(2018, 06, 18);
            newEvent1.FlightNumber__c = 'QF0001';
            newEvent1.DeparturePort__c = 'SYD';
            newEvent1.ArrivalPort__c = 'MEL';
            events.add(newEvent1);

            insert events;
            
        }
    }
    
    @IsTest
    Public Static void testQueue(){
        List<Affected_Passenger__c> afpList = new List<Affected_Passenger__c>();
        String offloadRT = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'QCC Offload Passenger');
        Integer i = 1;
        Contact con = [SELECT Id FROM Contact];
        

        for(Event__c event: [SELECT Id, DelayFailureCode__c, Non_Delay_Failure_Code__c FROM Event__c]) {
            System.debug('#####'+event);
            Affected_Passenger__c afp = new Affected_Passenger__c();
            afp.Event__c = event.Id;
            afp.Name = 'Gold Frequentflyer'+i;
            afp.Passenger__c = con.Id;
            afp.RecordTypeId = offloadRT;
            afp.SendEmail__c  = false;
            afp.Affected__c = true;
            afp.ArrivalPort__c = 'MEL';
            afp.DeparturePort__c = 'SYD';
            if(event.DelayFailureCode__c != null) {
                afp.TECH_PostFlight__c = true;
                afp.TECH_PreFlight__c = true;
            } else if(event.Non_Delay_Failure_Code__c != null && event.Non_Delay_Failure_Code__c != 'Flight Cancellation') {
                afp.TECH_PostFlight__c = true;
            } else if(event.DelayFailureCode__c == 'Flight Cancellation') {
                afp.TECH_PreFlight__c = true;
                afp.SendEmail__c = true;
            }
            afpList.add(afp);
            i++;
        }
        insert afpList;
        for(Affected_Passenger__c afp : afpList){
            Test.setCreatedDate(afp.Id, System.today().addDays(-6));
        }
        Test.startTest();
        QCC_DeleteOffloadPassengersSchedulable m = new QCC_DeleteOffloadPassengersSchedulable();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Merge Job', sch, m);
        Test.stopTest();
    }
}