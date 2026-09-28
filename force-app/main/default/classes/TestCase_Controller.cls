@isTest
public class TestCase_Controller {
    //Added by Suresh
    @testSetup static void setupTestData(){
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();        
        Test.stopTest();
    }
    
    @IsTest
    public static void testGetRecords() {
        // Create test data
        Account a = new Account();
        a.name = 'Test Account';
        Insert a;
        
        Case c = new Case();
        c.RecordTypeId = '01290000000A8I0AAK';
        c.AccountId = a.id;
        c.Justification__c = 'Test case';
        Insert c;
        
        List<Frequent_Flyer_Information__c> ffList = new List<Frequent_Flyer_Information__c>();
        for(Integer i=0;i<3;i++){
            Frequent_Flyer_Information__c ff1 = new Frequent_Flyer_Information__c();
            ff1.Name = 'Test FF'+i;
            ff1.Frequent_Flyer_Number__c = '123'+i;
            ff1.Freq_Flyer_Expiry_Date__c = Date.today()+30+i;
            ff1.Current_Tier__c = 'Bronze';
            ff1.Upgrade_Tier_Requested__c = 'Silver';
            ff1.Case__c = c.Id;
            ff1.Account__c = a.Id;
            ffList.add(ff1);
        }
        
        Insert ffList;
        
        // Call the Apex method
        Test.startTest();
        List<Frequent_Flyer_Information__c> result = Case_Controller.getFFInfo(c.Id);
        Test.stopTest();
        System.assertEquals(3, result.size(), 'Result size should be 3');
    }
}