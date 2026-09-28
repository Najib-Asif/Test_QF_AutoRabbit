/**
 * This class contains unit tests for validating the behavior of QuickQuoteController class.
 * Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
 * Desc : Remediated test class failures. Added setUpData() method. Updated test() method
 */
@isTest
public class QuickQuoteControllerTest {
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    public static testMethod void test() {
        Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Quote', 'Loyalty Commercial');
        Id oppRecordTypeId= GenericUtils.getObjectRecordTypeId('Opportunity', 'Loyalty Commercial');
        Account acc = new Account(Name = 'Test1');
        insert acc;
        
        Contact objcontact = new Contact();
        objcontact.FirstName = 'TestContact-Loyalty';
        objcontact.LastName = acc.Name;
        objcontact.Business_Types__c = 'Loyalty';
        objcontact.Email = 'test923@abc.com';
        insert objcontact;
        
        Opportunity opp = new Opportunity();        
        opp.RecordTypeId = oppRecordTypeId;
        opp.AccountId = acc.Id;
        opp.Name = 'Oppty';
        opp.Customer_Base__c = 1000;
        opp.Points_Per__c = 10;
        opp.Price_Per_Point__c = 0.0180;
        opp.Assumed_Tag_Rate_at_Maturity__c = 1.45;
        opp.Average_Spend_Per_Customer__c = 1000;
        opp.StageName = 'Prospect';
        opp.CloseDate = System.today();
        opp.Type = 'Qantas Business Rewards';
        opp.Forecast_MCA_Revenue__c=20000;
        insert opp;
        
        Opportunity opp2 = QuickQuoteController.getOpp(opp.Id);
        System.assertEquals(opp.Name, opp2.Name);
        System.assertEquals(opp.Price_Per_Point__c, opp2.Price_Per_Point__c);
        
        Quote qt = new Quote(Name='Test Quote', ContactId = objcontact.Id, Rate_Valid_after_acceptance_until__c=Date.today());
        qt = QuickQuoteController.saveQuoteWithOpp(qt, opp2);
        System.assertEquals('Test Quote', qt.Name);
        System.assertEquals(opp2.Price_Per_Point__c, qt.Price_Per_Point__c);
    }
}