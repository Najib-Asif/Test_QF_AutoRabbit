@isTest
public class QCC_DeleteFlightTrackersBatchProcessTest {
    static testMethod void test() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createFlightTrackerTriggerSetting();
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Flight_Tracker__c> flts = new List<Flight_Tracker__c>();
        Integer i = 0;
        for(i = 0; i < 200; i++) {
            Flight_Tracker__c flt = new Flight_Tracker__c();
            flt.Flight_Number__c = '2301';
            flt.Departure_Airport__c = String.valueOf(i) ;
            flt.Arrival_Airport__c = String.valueOf(i + 1);
            flt.EstimatedArrDateTime__c = '2018-01-10T10:00:00.000+10:00';
            flt.ScheduledArrDateTime__c = '2018-01-10T10:00:00.000+10:00';
            flt.ScheduledDepTime__c = '2018-01-10T10:00:00.000+10:00';
            flt.ActualArriDateTime__c = '2018-01-10T12:00:00.000+10:00';
            flt.Event_Name__c = 'ESTIMATE_CHANGE';
            flt.Origin_Date__c = Date.newInstance(2018, 06, 25);
            flts.add(flt);
        }
        insert flts;
        Datetime olderDate = Datetime.now().addDays(-8);
        for(Flight_Tracker__c flt: flts) {
            Test.setCreatedDate(flt.Id, olderDate);
        }
        Integer count = [SELECT count() FROM Flight_Tracker__c];
        System.assertEquals(flts.size(), count);
        Test.startTest();
        Database.executeBatch(new QCC_DeleteFlightTrackersBatchProcess());
        Test.stopTest();
        Integer countAfterBatchProcess = [SELECT count() FROM Flight_Tracker__c];
        System.assertEquals(0, countAfterBatchProcess);
    }
}