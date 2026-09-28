/**
* This class contains unit tests for validating the behavior of QuickContractController class.
* Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
* Desc : Remediated test class failures. Added setUpData() method. Updated test() method. Formatted code
*/
@isTest
public class QuickContractControllerTest {
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    public static testMethod void test() {
        Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Quote', 'Loyalty Commercial');
        Id oppRecordTypeId= GenericUtils.getObjectRecordTypeId('Opportunity', 'Loyalty Commercial');
        List<Account> accList = new List<Account>{};
            List<Contact> conList = new List<Contact>{};
                List<Opportunity> oppList = new List<Opportunity>{};
                    List<Quote> quoteList = new List<Quote>{};
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
            if(Math.mod(i,2) == 0) {
                opp.Type = 'Qantas Business Rewards';
            } else {
                opp.Type = 'Qantas Frequent Flyer';
            }
            
            oppList.add(opp);
        }
        insert oppList;
        
        for(integer i = 0; i < 5; i++) {
            Quote q = new Quote(RecordTypeId=LoyaltyRecordTypeId,Name='Opp Quote'+i, OpportunityId = oppList[i].Id, Active__c = true,
                                Price_Per_Point__c = oppList[i].Price_Per_Point__c);
            q.Rate_Valid_after_acceptance_until__c=Date.today();
            q.ContactId = conList[0].Id;
            quoteList.add(q);
        }
        insert quoteList;
        
        Quote qt = QuickContractController.getQuote(quoteList[0].Id);
        System.assertEquals('Opp Quote0', qt.Name);
        System.assertEquals(0.0180, qt.Price_Per_Point__c);
        
        Contract__c con = new Contract__c(Name='Con');
        con = QuickContractController.saveContractWithQuote(con, qt);
        
        System.assertEquals(qt.Id, con.Quote__c);
        System.assertEquals(0.0180, con.Price_Per_Point__c);
        System.assertEquals(qt.AccountId, con.Account__c);
        System.assertEquals(qt.OwnerId, con.Contract_Owner__c);
        
        Quote qt2 = QuickContractController.getQuote(quoteList[1].Id);
        System.assertEquals('Opp Quote1', qt2.Name);
        System.assertEquals(0.0180, qt2.Price_Per_Point__c);
        
        Contract__c con2 = new Contract__c(Name='Con');
        con2 = QuickContractController.saveContractWithQuote(con2, qt2);
        
        System.assertEquals(qt2.Id, con2.Quote__c);
        System.assertEquals(0.0180, con2.Price_Per_Point__c);
        System.assertEquals(qt2.AccountId, con2.Account__c);
        System.assertEquals(qt2.OwnerId, con2.Contract_Owner__c);
    }
}