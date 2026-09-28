/*********************************************************************************
Name         : QCC_QantasHostConnectingFlightBatchTest
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 11 Nov 2019
Usages       : This will handle the test class and code coverage of apex class below
                -QCC_QantasHostConnectingFlightBatch 

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_QantasHostConnectingFlightBatchTest {
@testSetup
    static void setUpTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Qantas_Api__c
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingListQantasHost = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusQantasHost', null, null, null, null);
        insert customSettingListQantasHost;

        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.Frequent_Flyer_Number__c = '1234512345';
        contactRecord.RecordTypeId = contactRecordTypeId;
        
        insert contactRecord;
        
        //create test data for airport code
        Airport_Code__c airport1 =QCC_TestDataFactory.createAirportCodeTestData();
        insert airport1;
        Airport_Code__c airport2 =QCC_TestDataFactory.createAirportCodeTestData();
        airport2.Name = 'PER';
		airport2.Freight_Station_Name__c = 'Perth';
        insert airport2;
                
       
        //Create test data for Qantas Host objec 
        //QCC_First_Host__c qantasHostList = QCC_TestDataFactory.createFirstHostTestData(contactRecord, airport1.id);
        Qcc_First_Host__c qantasHost = QCC_TestDataFactory.createFirstHostTestData(contactRecord.id, airport1.Id);
        qantasHost.QCC_Arrival_Airport_Code__c = airport2.id;
        qantasHost.QCC_TECH_GetConnectingFlights__c = TRUE;
        qantasHost.QCC_Departure_Local_Date__c = Date.newInstance(2019, 9, 20); //20/09/2019
        qantasHost.QCC_Flight_Departure_Time__c = Time.newInstance(14, 20, 0, 0); //18:45:00
        qantasHost.QCC_Arrival_Local_Date__c = Date.newInstance(2019, 9, 20);
		qantasHost.QCC_Arrival_Local_Time__c =  Time.newInstance(18, 20, 0, 0);
        qantasHost.QCC_Frequent_Flyer_Number__c = '1234512345';	
        
        insert qantasHost;
    }
    
    public static testMethod void testQantasHostConnectingFlight()
    { 
        List<Qcc_First_Host__c> qantasHostList = new List<Qcc_First_Host__c>([SELECT Id, QCC_Arrival_Local_Date__c, QCC_Arrival_Local_Time__c, QCC_Frequent_Flyer_Number__c,QCC_Departure_Airport_Code__c,QCC_Departure_Local_Date__c, QCC_Flight_Departure_Time__c, QCC_Arrival_Airport_Code__r.Name 
            	FROM QCC_First_Host__C 
            	WHERE QCC_TECH_GetConnectingFlights__c = TRUE LIMIT 1]); 
        Set<Id> qantasHostIds = new Set<Id>(); 
        for(Qcc_First_Host__c qantasRecord : qantasHostList){
            qantasHostIds.add(qantasRecord.Id);
        }
        
        Test.startTest();
        Database.executeBatch(new QCC_QantasHostConnectingFlightBatch(qantasHostIds), 1);
        Test.stopTest();
        QCC_First_Host__c qantasRecord = [SELECT QCC_CONX_Departure_Airport_Name__c, QCC_CONX_Departure_Local_Date__c, QCC_CONX_Scheduled_Departure_Date_Time__c,
                                          QCC_CONX_Flight_No__c,QCC_CONX_Arrival_Airport_Name__c
                                         FROM QCC_First_Host__c LIMIT 1];
        System.assert(qantasRecord.QCC_CONX_Departure_Airport_Name__c == 'Perth', 'Arrival airport of qantas host record should be same as connecting flight departure airport' );
        System.assert(qantasRecord.QCC_CONX_Departure_Local_Date__c != '', 'QCC_CONX_Departure_Local_Date__c should be populated' );
        System.assert(qantasRecord.QCC_CONX_Scheduled_Departure_Date_Time__c != '', 'QCC_CONX_Scheduled_Departure_Date_Time__c should be populated' );
        System.assert(qantasRecord.QCC_CONX_Flight_No__c != '', 'QCC_CONX_Flight_No__c should be populated' );
        System.assert(qantasRecord.QCC_CONX_Arrival_Airport_Name__c != '', 'QCC_CONX_Arrival_Airport_Name__c should be populated' );
    }
}