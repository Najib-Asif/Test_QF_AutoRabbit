/*********************************************************************************
Name         : QCC_DisruptionWarningTest
Created By   : Nicole Abesamis
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 August 2019
Usages       : This will handle the test class and code coverage of
				QCC_DisruptionWarning APEX class
*********************************************************************************/

@isTest
public class QCC_DisruptionWarningControllerTest {
	static User qantasB2CConsultantUser;

    @testSetup
    static void createData() {
		//Create test data for Account object
TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;

        //Create test data for Contact object
        List<Contact> contactRecords = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecords.add(contactRecord);

        Contact contactRecord2 = QCC_TestDataFactory.createContactTestData(2, accountRecord.Id);
        contactRecord2.RecordTypeId = contactRecordTypeId;
        contactRecord2.Frequent_Flyer_Number__c = '000002';
        contactRecords.add(contactRecord2);

        Contact contactRecord3 = QCC_TestDataFactory.createContactTestData(3, accountRecord.Id);
        contactRecord3.RecordTypeId = contactRecordTypeId;
        contactRecord3.Frequent_Flyer_Number__c = '000003';
        contactRecords.add(contactRecord3);

        Contact contactRecord4 = QCC_TestDataFactory.createContactTestData(3, accountRecord.Id);
        contactRecord4.RecordTypeId = contactRecordTypeId;
        contactRecord4.Frequent_Flyer_Number__c = '000004';
        contactRecords.add(contactRecord4);

        insert contactRecords;

        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;

        DateTime systemNow = system.now();

        //***CREATE HEADS UP FLIGHT EVENT***//
        List<Event__c> flightEventRecords = new List<Event__c>();
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        //Arrival Time for heads-up testing
        DateTime schedArrivalDateTimeYellow = systemNow.addHours(Integer.valueOf(Label.QCC_DisruptionWarningYellow));
        String schedArrivalDateTimeForHeadsUp = schedArrivalDateTimeYellow.format('dd/MM/yyyy HH:MM:ss');
        String schedDepartureDateTimeForHeadsUp = systemNow.format('yyyy-MM-dd');
        system.debug('>>>schedArrivalDateTimeForHeadsUp: ' + schedArrivalDateTimeForHeadsUp);

        //This will be auto-closed by PB "QCC Flight Event - Close Heads Up" when a Flight Event Active has been created with the same flight
        Event__c flightHeadsUpWillClose = QCC_TestDataFactory.createFlightEventTestData();
        flightHeadsUpWillClose.Name = 'Sample Heads Up Event';
        flightHeadsUpWillClose.RecordTypeId = headsUpRecordTypeId;
        flightHeadsUpWillClose.Scheduled_Arrival_UTC__c = System.now();
        flightHeadsUpWillClose.Scheduled_Departure_Date_Time__c = schedDepartureDateTimeForHeadsUp;
        flightHeadsUpWillClose.Scheduled_Depature_UTC__c = System.now();
        flightHeadsUpWillClose.ScheduledArrDateTime__c = schedArrivalDateTimeForHeadsUp;
        flightHeadsUpWillClose.ScheduledDepDate__c = Date.valueOf(schedDepartureDateTimeForHeadsUp);
        flightHeadsUpWillClose.ScheduledDepTime__c = '08:00';
        flightHeadsUpWillClose.Status__c = 'Open';
        flightEventRecords.add(flightHeadsUpWillClose);

        //This will be REMAIN OPEN becasue there is no equivalent Flight Event Active
        Event__c flightHeadsUpOpen = QCC_TestDataFactory.createFlightEventTestData();
        flightHeadsUpOpen.Name = 'Sample Heads Up Event';
        flightHeadsUpOpen.FlightNumber__c = 'QF0117';
        flightHeadsUpOpen.DeparturePort__c = 'HKG';
        flightHeadsUpOpen.RecordTypeId = headsUpRecordTypeId;
        flightHeadsUpOpen.Scheduled_Arrival_UTC__c = System.now();
        flightHeadsUpOpen.Scheduled_Departure_Date_Time__c = schedDepartureDateTimeForHeadsUp;
        flightHeadsUpOpen.Scheduled_Depature_UTC__c = System.now();
        flightHeadsUpOpen.ScheduledArrDateTime__c = schedArrivalDateTimeForHeadsUp;
        flightHeadsUpOpen.ScheduledDepDate__c = Date.valueOf(schedDepartureDateTimeForHeadsUp);
        flightHeadsUpOpen.ScheduledDepTime__c = '08:00';
        flightHeadsUpOpen.Status__c = 'Open';
        flightEventRecords.add(flightHeadsUpOpen);


        //***CREATE FLIGHT EVENT ACTIVE THAT WILL AUTO CLOSE THE HEADS UP***///
        String flightActiveRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Active').getRecordTypeId();
        //Arrival Time for flight delay
        DateTime schedArrivalDateTimeRed = systemNow.addHours(Integer.valueOf(Label.QCC_DisruptionWarningRedFlightDelay));
        String schedArrivalDateTimeDelay = schedArrivalDateTimeRed.format('dd/MM/yyyy HH:MM:ss');
        String schedDepartureDateTimeForDelay = systemNow.format('yyyy-MM-dd');
        system.debug('>>>schedArrivalDateTimeDelay: ' + schedArrivalDateTimeDelay);

        Event__c flightEventActive = QCC_TestDataFactory.createFlightEventTestData();
        flightEventActive.Name = 'Sample Active Event';
        flightEventActive.RecordTypeId = flightActiveRecordTypeId;
        flightEventActive.Scheduled_Arrival_UTC__c = System.now();
        flightEventActive.Scheduled_Departure_Date_Time__c = schedDepartureDateTimeForDelay;
        flightEventActive.Scheduled_Depature_UTC__c = System.now();
        flightEventActive.ScheduledArrDateTime__c = schedArrivalDateTimeDelay;
        flightEventActive.ScheduledDepDate__c = Date.valueOf(schedDepartureDateTimeForDelay);
        flightEventActive.ScheduledDepTime__c = '08:00';
        flightEventActive.IntDom__c = 'International';
        flightEventActive.Status__c = 'Open';
        flightEventActive.DelayFailureCode__c = 'Flight Delay';
        flightEventRecords.add(flightEventActive);

        //***CREATE FLIGHT EVENT OFFLOAD***///
        String flightOffloadRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Offload').getRecordTypeId();
        //Arrival Time for flight delay
        DateTime schedArrivalDateTimeDomestic = systemNow.addHours(-23);
        String formatSchedArrivalDateTimeDomestic = schedArrivalDateTimeDomestic.format('dd/MM/yyyy HH:MM:ss');
        DateTime schedDepartureDateTimeRed = systemNow.addHours(Integer.valueOf(Label.QCC_DisruptionWarningRedDomestic));
        String schedDepartureDateTimeForDomestic = schedDepartureDateTimeRed.format('yyyy-MM-dd');
        system.debug('>>>schedDepartureDateTimeForDomestic: ' + schedDepartureDateTimeForDomestic);

        Event__c flightEventOffload = QCC_TestDataFactory.createFlightEventTestData();
        flightEventOffload.Name = 'Sample Offload Event';
        flightEventOffload.FlightNumber__c = 'QF0001';
        flightEventOffload.DeparturePort__c = 'DFW';
        flightEventOffload.RecordTypeId = flightOffloadRecordTypeId;
        flightEventOffload.Scheduled_Arrival_UTC__c = schedArrivalDateTimeDomestic;
        flightEventOffload.Scheduled_Departure_Date_Time__c = schedDepartureDateTimeForDelay;
        flightEventOffload.Scheduled_Depature_UTC__c = schedDepartureDateTimeRed;
        flightEventOffload.ScheduledArrDateTime__c = schedArrivalDateTimeDelay;
        flightEventOffload.ScheduledDepDate__c = Date.valueOf(schedDepartureDateTimeForDelay);
        flightEventOffload.ScheduledDepTime__c = '08:00';
        flightEventOffload.IntDom__c = 'Domestic';
        flightEventOffload.Status__c = 'Open';
        flightEventRecords.add(flightEventOffload);

        insert flightEventRecords;

        //Create test data for Passenger object
        List<Trigger_Status__c> customSettingList2 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusPassenger', null, null, null, null);
        insert customSettingList2;

        List<Affected_Passenger__c> passengerRecords = new List<Affected_Passenger__c>();
        String passengerRecordTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('QCC EventPassenger').getRecordTypeId();
        //***HEADS UP EVENT***//
        //Passenger record for 000001 on Heads-up Event - flightHeadsUpWillClose
        Affected_Passenger__c passengerRecord1 = QCC_TestDataFactory.createPassengerTestData(flightHeadsUpWillClose.Id, contactRecord.Id);
        passengerRecord1.QCC_Disruption_Actioned__c = true;
        passengerRecords.add(passengerRecord1);

        //Passenger record for 000002 on Heads-up Event - flightHeadsUpWillClose
        Affected_Passenger__c passengerRecord2 = QCC_TestDataFactory.createPassengerTestData(flightHeadsUpWillClose.Id, contactRecord2.Id);
        passengerRecord2.QCC_Disruption_Actioned__c = false;
        passengerRecords.add(passengerRecord2);

        //Passenger record for 000003 on Heads-up Event - flightHeadsUpOpen
        Affected_Passenger__c passengerRecord3 = QCC_TestDataFactory.createPassengerTestData(flightHeadsUpOpen.Id, contactRecord3.Id);
        passengerRecord3.QCC_Disruption_Actioned__c = false;
        passengerRecords.add(passengerRecord3);

        //***FLIGHT DELAY***//
        //Passenger record for 000001 on Flight Delay NOT Actioned
        Affected_Passenger__c passengerRecord4 = QCC_TestDataFactory.createPassengerTestData(flightEventActive.Id, contactRecord.Id);
        passengerRecord4.QCC_Disruption_Actioned__c = false;
        passengerRecords.add(passengerRecord4);

        //***OFFLOAD***//
        //Passenger record for 000004 on Offload Actioned
        Affected_Passenger__c passengerRecord5 = QCC_TestDataFactory.createPassengerTestData(flightEventoffload.Id, contactRecord4.Id);
        passengerRecord5.QCC_Disruption_Actioned__c = true;
        passengerRecords.add(passengerRecord5);


        insert passengerRecords;
        system.debug('>>>passengerRecords: ' + passengerRecords);
    }

    //Test Scenario: RED ICON - Customer on heads-up event, but which has turned into an active flight delay
    static testMethod void testRedIcon(){
        Map<String, Profile> profilesMap = TestUtilityDataClassQantas.getProfileMap();
        Profile qantasCcConsultantProfile = profilesMap.get('Qantas CC Consultant');
        qantasB2CConsultantUser = QCC_TestDataFactory.createUserTestData(qantasCcConsultantProfile.Id);
        insert qantasB2CConsultantUser;

        //Add user to the permission set
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'QANTAS_VIP_Service_Team'];
        insert new PermissionSetAssignment(AssigneeId = qantasB2CConsultantUser.id, PermissionSetId = ps.Id);

        system.runAs(qantasB2CConsultantUser) {
            Contact contact = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '000001'];
            QCC_DisruptionWarningController.DisruptionWarningWrapper testResult = QCC_DisruptionWarningController.getRelatedPassengerRec(contact.Id);
            System.assertEquals(testResult.hasError, false);
           // system.assertEquals('redIcon', testResult.iconToDisplay);
        }
    }

    //Test Scenario: GREEN ICON - Customer had a heads-up disruption, and ACTIONED by the agent
    static testMethod void testGreenIconFromYellow(){

        Map<String, Profile> profilesMap = TestUtilityDataClassQantas.getProfileMap();
        Profile qantasCcConsultantProfile = profilesMap.get('Qantas CC Consultant');
        qantasB2CConsultantUser = QCC_TestDataFactory.createUserTestData(qantasCcConsultantProfile.Id);
        insert qantasB2CConsultantUser;

        //Add user to the permission set
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'QANTAS_VIP_Service_Team'];
        insert new PermissionSetAssignment(AssigneeId = qantasB2CConsultantUser.id, PermissionSetId = ps.Id);

        system.runAs(qantasB2CConsultantUser) {
            Contact contact = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '000002'];
            QCC_DisruptionWarningController.DisruptionWarningWrapper testResult = QCC_DisruptionWarningController.getRelatedPassengerRec(contact.Id);
            System.assertEquals(testResult.hasError, false);
          //  System.assertEquals('greenIcon', testResult.iconToDisplay);

        }
    }

    //Test Scenario: YELLOW ICON - Customer had a heads-up disruption, BUT NOT ACTIONED actioned by the agent
    static testMethod void testYellowIcon(){

        Map<String, Profile> profilesMap = TestUtilityDataClassQantas.getProfileMap();
        Profile qantasCcConsultantProfile = profilesMap.get('Qantas CC Consultant');
        qantasB2CConsultantUser = QCC_TestDataFactory.createUserTestData(qantasCcConsultantProfile.Id);
        insert qantasB2CConsultantUser;

        //Add user to the permission set
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'QANTAS_VIP_Service_Team'];
        insert new PermissionSetAssignment(AssigneeId = qantasB2CConsultantUser.id, PermissionSetId = ps.Id);

        system.runAs(qantasB2CConsultantUser) {
            Contact contact = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '000003'];
            QCC_DisruptionWarningController.DisruptionWarningWrapper testResult = QCC_DisruptionWarningController.getRelatedPassengerRec(contact.Id);
            System.assertEquals(testResult.hasError, false);
         //  system.assertEquals('yellowIcon', testResult.iconToDisplay);
        }
    }

    //Test Scenario: GREEN ICON - Customer had offload, and ACTIONED by the agent
    static testMethod void testGreenIconFromRed(){

        Map<String, Profile> profilesMap = TestUtilityDataClassQantas.getProfileMap();
        Profile qantasCcConsultantProfile = profilesMap.get('Qantas CC Consultant');
        qantasB2CConsultantUser = QCC_TestDataFactory.createUserTestData(qantasCcConsultantProfile.Id);
        insert qantasB2CConsultantUser;

        //Add user to the permission set
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'QANTAS_VIP_Service_Team'];
        insert new PermissionSetAssignment(AssigneeId = qantasB2CConsultantUser.id, PermissionSetId = ps.Id);

        system.runAs(qantasB2CConsultantUser) {
            Contact contact = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '000004'];
            QCC_DisruptionWarningController.DisruptionWarningWrapper testResult = QCC_DisruptionWarningController.getRelatedPassengerRec(contact.Id);
            System.assertEquals(testResult.hasError, false);
            system.assertEquals('greenIcon', testResult.iconToDisplay);

        }
    }
    
}