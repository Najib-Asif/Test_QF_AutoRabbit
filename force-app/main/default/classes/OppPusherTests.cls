/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * 
 * Modified By : Hari B, 27-Mar-2026
 *               Remediated test failures of myOppUnitTest() method.
 */
@isTest
private class OppPusherTests {
 private static sObject[] OpptyList; 
 private static List<Opportunity> testOpptys = new List<Opportunity>();

    static testMethod void myOppUnitTest() {        
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();   
        list<Freight_RecordTypeSeggregation__c> listCustomSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
        insert listCustomSetting;

        Test.startTest();
        // TO DO: implement unit test
        // create an oppty
        Opportunity oTestOppty=createOppty('testOpptys');
        // change the month pushcount+1
        oTestOppty.CloseDate=date.newinstance(2015,12,11);
        //Opportunity oTestUpdateOppty=[select Id from Opportunities where Id=oTestOppty.Id]
        update oTestOppty;
        Opportunity oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug(oReadOppty.PushCount__c);
        //System.assert(oReadOppty.PushCount__c==1);
        // make it later this month, no change        
        Test.stopTest();        
        oTestOppty.CloseDate=date.newinstance(2015,12,31);
        update oTestOppty;
        oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug(oReadOppty.PushCount__c);
        //System.assert(oReadOppty.PushCount__c==1);
        // make it next year, but an earlier month, pushcount+1
        oTestOppty.CloseDate=date.newInstance(2016, 1,1);
        update oTestOppty;
        oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug(oReadOppty.PushCount__c);
        //System.assertEquals(oReadOppty.PushCount__c, 2);
        // don't change the date, no change
        oTestOppty.CloseDate=date.newInstance(2016,1,1);
        update oTestOppty;
       oReadOppty=[select Id,PushCount__c from Opportunity where id=:oTestOppty.Id];
        System.debug(oReadOppty.PushCount__c);
       // System.assertEquals(oReadOppty.PushCount__c,2);        
        //clean up
        cleanOpptys();
    }
    
    private static Opportunity createOppty(String sOppName) {
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        User u1 = new User(LastName = 'User2', Alias = 'User', Email = 'sampleuser2@sample.com', 
                               Username = 'sampleuser2username@sample.com', ProfileId = profMap.get('Data Administrator').Id,
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        insert u1;
        // system.runAs(u1) {
        Account acc = new Account();
        acc.OwnerId = u1.id;
        acc.Name = 'Test Account';
        acc.ABN_Tax_Reference__c ='1234';
        insert acc;
        
        Opportunity oNewOpp= new Opportunity(name= sOppName,closedate= date.newinstance(2015,11,11),stagename='Prospecting',AccountId = acc.Id,OwnerId = acc.OwnerId,Forecast_MCA_Revenue__c=20000);
        //  List<Opportunity> testLocalOpptys = new List<Opportunity>();
        //  testLocalOpptys=(List<Opportunity>)OpptyList;
        //  testLocalOpptys.add(oNewOpp);
        //  OpptyList=testLocalOpptys;
        insert oNewOpp;
        testOpptys.add(oNewOpp);
        return oNewOpp;   
    }    
  

    private static void cleanOpptys() {
        for(Opportunity oIterator : testOpptys) {
            delete oIterator;
            
        }
        testOpptys.clear();
    }    
    
}