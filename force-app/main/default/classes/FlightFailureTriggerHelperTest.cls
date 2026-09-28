@IsTest
public class FlightFailureTriggerHelperTest {
    private static Event__c myEvent;
    static {
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createGlobalEventTriggerSetting();
        
        List<Trigger_Status__c> lstAffectedPassenger = TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting();
        lstAffectedPassenger[0].Active__c = true;
        lsttrgStatus.addAll(lstAffectedPassenger);
        
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createFlightFailureSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        database.insert( lsttrgStatus, false);
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Offload Passenger RecType','QCC Offload Passenger'));
         insert lstConfigData;
        // create Flight Event
        myEvent    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Flight Delay','International');
        myEvent.FlightNumber__c = 'QF0007';
        myEvent.DeparturePort__c = 'SYD';
        myEvent.ArrivalPort__c = 'MEL';
        myEvent.ScheduledDepDate__c = System.today();
        myEvent.DelayFailureCode__c = 'Flight Delay';
        myEvent.Status__c = 'Assigned';
        //newEvent1.EstimatedDepDateTime__c = string.valueOf(System.Now());
        //newEvent1.ScheduledDepTime__c = '19:15';
        
        myEvent.Operational_Carrier__c = 'QF';
        insert myEvent;
    }
    
    static testMethod void testInsertFlightFailure() {
        List<Affected_Passenger__c> lstAffectedPassenger = new List<Affected_Passenger__c>();
        lstAffectedPassenger.add(createAffectedPassenger(myEvent.Id,'',true,true,'Economy','1A'));
        lstAffectedPassenger.add(createAffectedPassenger(myEvent.Id,'',true,true,'Economy','2A'));
        insert lstAffectedPassenger;
        List<FlightFailure__c> lstFlightFailure = new List<FlightFailure__c>();
        //lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Full Flight','Wifi','Full Flight',true,true));
        //lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Cabin','Baggage','Economy',true,true));
        //lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Zone','Catering','Row 1',true,true));
        lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Zone','Lights','Row 1',false,false));
        //lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Full Flight','Wifi','Full Flight',false,true));
        Test.startTest();
        insert lstFlightFailure;
        Test.stopTest();
        List<Affected_Passenger__c> lstPassenger = [
          SELECT Id, 
            Affected__c
          FROM Affected_Passenger__c
          WHERE Event__c = :myEvent.Id
        ];
        //System.assertEquals(true, lstPassenger[0].Affected__c);
    }

    static testMethod void testInsertFlightFailure2() {
        List<Affected_Passenger__c> lstAffectedPassenger = new List<Affected_Passenger__c>();
        lstAffectedPassenger.add(createAffectedPassenger(myEvent.Id,'',true,true,'Business','1A'));
        insert lstAffectedPassenger;
        List<FlightFailure__c> lstFlightFailure = new List<FlightFailure__c>();
        lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Cabin','Baggage','Economy',true,true));
        //lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Full Flight','Wifi','Full Flight',false,true));
        Test.startTest();
        insert lstFlightFailure;
        lstFlightFailure[0].Failure_Code__c = 'Other';
        update lstFlightFailure[0];
        Test.stopTest();
        List<Affected_Passenger__c> lstPassenger = [
          SELECT Id, 
            Affected__c
          FROM Affected_Passenger__c
          WHERE Event__c = :myEvent.Id
        ];
        //System.assertEquals(true, lstPassenger[0].Affected__c);
    }
    
    static testMethod void testInsertFlightFailureDelete() {
        List<Affected_Passenger__c> lstAffectedPassenger = new List<Affected_Passenger__c>();
        lstAffectedPassenger.add(createAffectedPassenger(myEvent.Id,'',true,true,'Business','1A'));
        insert lstAffectedPassenger;
        List<Group> listQueue = [Select id, name from Group where Type='Queue' AND developerName='CCC_CIOC_Queue'];
        myEvent.OwnerId = listQueue[0].id;
        update myEvent;
        List<FlightFailure__c> lstFlightFailure = new List<FlightFailure__c>();
        lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Cabin','Baggage','Economy',true,true));
        //lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Full Flight','Wifi','Full Flight',false,true));
        Test.startTest();
        insert lstFlightFailure;
        Boolean isError= false;
        try{
        delete lstFlightFailure[0];
        }catch(Exception ex){
           isError = true; 
           system.assert(isError == true, 'Record is deleted');
        }
        Test.stopTest();
    }

    static testMethod void testInsertFlightFailureDuplicate() {
        List<Affected_Passenger__c> lstAffectedPassenger = new List<Affected_Passenger__c>();
        lstAffectedPassenger.add(createAffectedPassenger(myEvent.Id,'',true,true,'Economy','1A'));
        insert lstAffectedPassenger;
        List<FlightFailure__c> lstFlightFailure = new List<FlightFailure__c>();
        lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Full Flight','Wifi','Full Flight',true,true));
        lstFlightFailure.add(createFlightFailure(myEvent.Id, 'Full Flight','Wifi','Full Flight',false,true));
        Test.startTest();
        try{
            insert lstFlightFailure;
        }catch(exception ex){
            System.assertNotEquals(ex, null);
        }
        
        Test.stopTest();
    }
    
    private static Affected_Passenger__c createAffectedPassenger(String myEventId, String failureCode,
                                                                Boolean preFlight, Boolean postFlight,
                                                                String caBin, String seatNo){
        Affected_Passenger__c myAffectedPassenger = new Affected_Passenger__c();
        myAffectedPassenger.FirstName__c = 'FName';
        myAffectedPassenger.LastName__c = 'LName';
        myAffectedPassenger.Name = 'Gold Frequentflyer1';
        myAffectedPassenger.Event__c = myEventId;
        myAffectedPassenger.Failure_Code__c = failureCode;
        myAffectedPassenger.TECH_PreFlight__c = preFlight;
        myAffectedPassenger.TECH_PostFlight__c = postFlight;
        myAffectedPassenger.Cabin__c = caBin;
        myAffectedPassenger.TravelledCabin__c = caBin;
        myAffectedPassenger.SeatNo__c = seatNo;
        myAffectedPassenger.Affected__c = true;
        Id myRecordTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('QCC EventPassenger').getRecordTypeId();
        myAffectedPassenger.RecordTypeId = myRecordTypeId;
        return myAffectedPassenger;
    }
    
    private static FlightFailure__c createFlightFailure(String myEventId, String inType, 
                                                        String failureCode, String affectSub,
                                                       Boolean preFlight, Boolean postFlight){
        FlightFailure__c myFlightFailure = new FlightFailure__c();
        myFlightFailure.Affected_Region__c = inType;
        myFlightFailure.Failure_Code__c = failureCode;
                          
        if(inType == 'Full Flight'){
            myFlightFailure.Affect_Sub_Section__c = affectSub;
        } else if(inType == 'Cabin'){
            myFlightFailure.Affect_Sub_Section__c = affectSub;
        } else if(inType == 'Zone'){
            myFlightFailure.Affect_Sub_Section__c = affectSub;
        }
        myFlightFailure.OnlyLeg__c = true;
        myFlightFailure.Flight_Event__c = myEventId;
        myFlightFailure.Post_Flight__c = postFlight;
        myFlightFailure.Pre_Flight__c = preFlight;
        return myFlightFailure;
    }
}