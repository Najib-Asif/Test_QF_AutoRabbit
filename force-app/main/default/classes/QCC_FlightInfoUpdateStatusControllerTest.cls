@Istest
public class QCC_FlightInfoUpdateStatusControllerTest {
	@testSetup 
    static void setup() {
        List<Qantas_API__c> lstQAPI = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQAPI;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        insert lsttrgStatus;

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Journey Manager').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                           TimeZoneSidKey = 'Australia/Sydney'
                          );
        System.runAs(u1){
            Event__c newEvent1    = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active','Assigned', 'Diversion Due to Weather','Domestic');
            newEvent1.ScheduledDepDate__c = System.today();
            newEvent1.DeparturePort__c = 'SYD';
            newEvent1.FlightNumber__c = 'QF0516';
            newEvent1.ArrivalPort__c = 'LHR';
            newEvent1.OwnerId = u1.Id;
            newEvent1.Flight_Info_Update_Status__c = 'Updated';
            insert newEvent1;
        }
    }
    
    @IsTest
    public static void testGetStatus(){
        User u1 = [select id from user where Username = 'sampleuser1username@sample.com'];
        System.runAs(u1){
            List<event__c> lstEvent = [select id from event__c];
            String status = QCC_FlightInfoUpdateStatusController.getStatus(lstEvent[0].id);
            
            System.assertEquals('Updated', status);
        }
    }
    @IsTest
    public static void testGetStatus2(){
        User u1 = [select id from user where Username = 'sampleuser1username@sample.com'];
        System.runAs(u1){
            List<event__c> lstEvent = [select id from event__c];
            String idx = String.valueOf(lstEvent[0].id).Left(3)+'000000000000';
            String status = QCC_FlightInfoUpdateStatusController.getStatus(idx);
            
            System.assertEquals('', status);
        }
    }
}