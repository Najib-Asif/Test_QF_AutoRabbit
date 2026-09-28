/**
* This class contains unit tests for validating the behavior of QuoteTriggerHelper class.
Modified By : Venkata Suresh Kumar (TCS Team), 02-Mar-2026
Desc : Remediated test class failures. Added testSetUPMethod() and updated test() method.

Modified By : Venkata Suresh Kumar (TCS Team), 18-June-2026
Desc : Remediated test class failures. updated test(), errortest() method.
*/
@isTest
public class QuoteTriggerHelperTest {
    @testSetup static void setupTestData(){
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();        
        Test.stopTest();
    }
    
    public static testMethod void test() {
        Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Quote', 'Loyalty Commercial');
        Id oppRecordTypeId= GenericUtils.getObjectRecordTypeId('Opportunity', 'Loyalty Commercial');
        
        List<Account> accList = new List<Account>{};
            List<Opportunity> oppList = new List<Opportunity>{};
                List<Contact> conList = new List<Contact>{};
                    List<Quote> quoteList = new List<Quote>{};
                        Test.startTest();
        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
        insert customSettingTriggerStatusLists;
        for(integer i = 0; i < 5; i++)
        {
            Account acc = new Account(Name = 'Test1');
            accList.add(acc);
        }
        insert accList;
        
        for(integer i = 0; i < 5; i++)
        {
            Contact objcontact = new Contact();
            objcontact.FirstName = 'TestContact-Loyalty';
            objcontact.LastName = accList[i].Name;
            objcontact.AccountId = accList[i].Id;
            objcontact.Business_Types__c = 'Loyalty';
            objcontact.Email = 'test923@abc.com';
            conList.add(objcontact);
        }
        insert conList;
        
        for(integer i = 0; i < 5; i++)
        {
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = oppRecordTypeId;
            opp.AccountId = accList[i].Id;
            opp.Name = 'Opp'+i;
            opp.Customer_Base__c = 1000;
            opp.Points_Per__c = 10;
            opp.Price_Per_Point__c = 0.0180;
            opp.Assumed_Tag_Rate_at_Maturity__c = 1.45;
            opp.Average_Spend_Per_Customer__c = 1000;
            opp.StageName = 'Prospect';
            opp.CloseDate = System.today();
            opp.Contact__c = conList[0].Id;
            opp.Forecast_MCA_Revenue__c=20000;
            oppList.add(opp);
        }        
        insert oppList;
        
        for(integer i = 0; i < 5; i++) {
            Quote q = new Quote(RecordTypeId=LoyaltyRecordTypeId,Name='Opp Quote'+i, OpportunityId = oppList[i].Id, Active__c = true,  ContactId = conList[0].Id, Rate_Valid_after_acceptance_until__c=Date.today()); //Modified as part of test class fixes
            quoteList.add(q);
        }
        insert quoteList;
        
        Quote q = new Quote(RecordTypeId=LoyaltyRecordTypeId,Name='Opp Quote', OpportunityId = oppList[0].Id, Active__c = true,  ContactId = conList[0].Id, Rate_Valid_after_acceptance_until__c=Date.today()); //Modified as part of test class fixes
        insert q;
        
        Contract__c con;        
        try{
            con = [Select Id, Name FROM Contract__c WHERE Quote__c = :q.id];
        } catch(Exception e) {
            System.assertEquals(null, con);
        }
        List<Quote> qts = [SELECT Id, Active__c, Name, Price_Per_Point__c, OpportunityId FROM Quote WHERE OpportunityId = :oppList[0].Id order By Name Desc];
        System.assertEquals(2, qts.size());
        System.assertEquals(true, qts[1].Active__c);
        System.assertEquals(null, qts[1].Price_Per_Point__c);
        qts[0].Price_Per_Point__c = 0.0185;
        qts[1].Price_Per_Point__c = 0.0185;
        qts[1].Status = 'Accepted';
        update qts;
        Test.stopTest();
        
        Opportunity op = [SELECT Id, Price_Per_Point__c FROM Opportunity where Id = :qts[0].OpportunityId];
        System.assertEquals(0.0185, op.Price_Per_Point__c);
        
        Contract__c con1 = [Select Id, Name FROM Contract__c WHERE Quote__c = :qts[1].id];
        System.assertEquals('Opp Quote', con1.Name);               
    }
    
    public static testMethod void errortest() {
        Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Quote', 'Loyalty Commercial');
        Id oppRecordTypeId= GenericUtils.getObjectRecordTypeId('Opportunity', 'Loyalty Commercial');
        
        List<Account> accList = new List<Account>{};
            List<Opportunity> oppList = new List<Opportunity>{};
                List<Contact> conList = new List<Contact>{};
                    List<Quote> quoteList = new List<Quote>{};
                        for(integer i = 0; i < 5; i++)
                    {
                        Account acc = new Account(Name = 'Test1');
                        accList.add(acc);
                    }
        Test.startTest();
        insert accList;
        for(integer i = 0; i < 5; i++)
        {
            Contact objcontact = new Contact();
            objcontact.FirstName = 'TestContact-Loyalty';
            objcontact.LastName = accList[i].Name;
            objcontact.AccountId = accList[i].Id;
            objcontact.Business_Types__c = 'Loyalty';
            objcontact.Email = 'test923@abc.com';
            conList.add(objcontact);
        }
        
        insert conList;
        for(integer i = 0; i < 5; i++)
        {
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = oppRecordTypeId;
            opp.AccountId = accList[i].Id;
            opp.Name = 'Opp'+i;
            opp.Price_Per_Point__c = 0.0180;
            opp.StageName = 'Negotiate';
            opp.CloseDate = System.today();
            opp.Probability = 50;
            opp.Amount = 20.00;
            opp.Contact__c = conList[0].Id;
            opp.Forecast_MCA_Revenue__c=20000;
            oppList.add(opp);
        }
        
        insert oppList;
        
        for(integer i = 0; i < 5; i++) {
            Quote q = new Quote(RecordTypeId=LoyaltyRecordTypeId,Name='Opp Quote'+i, OpportunityId = oppList[i].Id, Active__c = true, ContactId = conList[0].Id, Rate_Valid_after_acceptance_until__c=Date.today()); // Modified as part of test class fixes
            quoteList.add(q);
        }
        insert quoteList;
        
        Quote q = new Quote(RecordTypeId=LoyaltyRecordTypeId,Name='Opp Quote', OpportunityId = oppList[0].Id, Active__c = true, Rate_Valid_after_acceptance_until__c=Date.today()); // Modified as part of test class fixes
        insert q;        
        
        List<Quote> qts = [SELECT Id, Active__c, Name, Price_Per_Point__c, OpportunityId FROM Quote WHERE OpportunityId = :oppList[0].Id order By Name Desc];
        System.assertEquals(2, qts.size());
        System.assertEquals(true, qts[1].Active__c);
        System.assertEquals(null, qts[1].Price_Per_Point__c);
        qts[0].Price_Per_Point__c = 0.0170;
        try {
            update qts[0];
        } catch (Exception e) {
            //Assert Error Message
            System.assert( e.getMessage().contains('Price Per Point is too low'), 
                          e.getMessage() );
            
        }
        Test.stopTest(); 
    }    
    
    public static testMethod void futureMethodsClass()
    {
        List<Account> Acclist = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> OppList = TestUtilityDataClassQantas.getOpportunities(Acclist);
        Test.StartTest();
        futureMethodsClass.closeOpp(OppList[0].id, OppList[0].CloseDate);
        Test.StopTest();
    }
    
}