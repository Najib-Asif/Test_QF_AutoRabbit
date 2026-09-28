@IsTest
public class QCC_OffloadEventReportControllerTest {
	@TestSetUp
    public static void setupData(){
        Airport_Code__c dCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c  ='NSW');
        insert dCode;
        Airport_Code__c aCode = new Airport_Code__c(Name = 'MEL', QF_Freight_Presence__c =TRUE, Freight_Station_Name__c = 'Melbource', Freight_Airport_State_Code__c  ='NSW');
        insert aCode;
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
    	TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
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
        insert lstConfigData;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        Event__c newEvent    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Offload','Assigned', 'Flight Delay','International');
        newEvent.FlightNumber__c = 'QF0008';
        newEvent.DeparturePort__c = 'SYD';
        newEvent.ArrivalPort__c = 'MEL';
        newEvent.ScheduledDepDate__c = System.today();
        insert newEvent;
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
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
    }
    
    @IsTest
    public static void testGetData1(){
        event__c ev = [select Id from event__c limit 1];
        List<QCC_OffloadEventReportController.OffloadData> lstOD = QCC_OffloadEventReportController.getData(ev.Id);
    }
    @IsTest
    public static void testGetData2(){
        Affected_Passenger__c ev = [select Id from Affected_Passenger__c limit 1];
        List<QCC_OffloadEventReportController.OffloadData> lstOD = QCC_OffloadEventReportController.getData(ev.Id);
    }
}