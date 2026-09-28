/**
 * This class contains unit tests for validating the behavior of OpportunityTriggerHandler class.
 */
/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 20-May-2026
Desc : Remediated test class failures. Updated afterupdateData() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest

public class OpportunityTriggerHandlerTest {
    
  static TestMethod void beforeupdateData() {
                
        //String oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business_and_Government').getRecordTypeId();
        Id oppRecordTypeId= GenericUtils.getObjectRecordTypeId('Opportunity', 'Business and Government'); 
        Account objAcc = TestUtilityDataClassQantas.createAccount(); 
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        
         Freight_RecordTypeSeggregation__c customSettingRecord = new Freight_RecordTypeSeggregation__c();
         
         customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Sample', Category__c = 'Sales', ObjectType__c = 'Opportunity',
                                            RecordTypeId__c = oppRecordTypeId);
                                            
        insert customSettingRecord;
        
        

            Opportunity opp = new Opportunity();
            opp.RecordTypeId = customSettingRecord.RecordTypeId__c;
            opp.AccountId = objAcc.Id;
            opp.Name = 'Opp';
            opp.Start_Date__c = System.today().addDays(-30);
            opp.Proposed_Term_of_Agreement__c = 'text';
            opp.Customer_Base__c = 1000;
            opp.Points_Per__c = 1.45;
            opp.Price_Per_Point__c = 10;
            opp.Assumed_Tag_Rate_at_Maturity__c = 1.45;
            opp.Average_Spend_Per_Customer__c = 1000;
            opp.Amount = 2000;
            //opp.Ramp_up_factor__c = '75';
            opp.Minimum_Spend_Commitment__c = 100;
            opp.Total_Points__c = 20;
            opp.Program_Fee__c = 1000;
            opp.StageName = 'Prospect';
            opp.CloseDate = System.today();
            opp.Type = 'Business and Government';
            opp.CloseDate = Date.Today().addDays(5);
            opp.PushCount__c = NULL;
            opp.Forecast_MCA_Revenue__c=20000;
            
            insert opp;
            
            System.debug('Close Date:' +opp.CloseDate);
            
            system.assert(opp.Id != Null, 'Opportunity is not inserted');
            
            opp.CloseDate = Date.Today().addDays(60);
            
            System.debug('Updated Close Date:' +opp.CloseDate);
            
            update opp;
            
            System.debug('Updated Close Dates:' +opp.CloseDate);
            System.debug('Push Count' +opp.PushCount__c);
    }

    static TestMethod void afterupdateData() {
        
        Id LoyaltyRecordTypeId= GenericUtils.getObjectRecordTypeId('Quote', 'Loyalty Commercial');
        Id oppRecordTypeId= GenericUtils.getObjectRecordTypeId('Opportunity', 'Loyalty Commercial');       

        Account objAcc = TestUtilityDataClassQantas.createAccount(); 
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        
        Contact objcontact = new Contact();
        objcontact.FirstName = 'TestContact-Loyalty';
        objcontact.LastName = objAcc.Name;
        objcontact.Business_Types__c = 'Loyalty';
        objcontact.Email = 'test923@abc.com';
        insert objcontact;

            Opportunity opp = new Opportunity();
            opp.RecordTypeId = oppRecordTypeId;
            opp.AccountId = objAcc.Id;
            opp.Name = 'Opp';
            opp.Start_Date__c = System.today().addDays(-30);
            opp.Proposed_Term_of_Agreement__c = 'text';
            opp.Customer_Base__c = 1000;
            opp.Points_Per__c = 1.45;
            opp.Price_Per_Point__c = 10;
            opp.Contact__c = objcontact.Id;
            opp.Assumed_Tag_Rate_at_Maturity__c = 1.45;
            opp.Average_Spend_Per_Customer__c = 1000;
            opp.Amount = 2000;
            opp.Ramp_up_factor__c = '75';
            opp.Minimum_Spend_Commitment__c = 100;
            opp.Total_Points__c = 20;
            opp.Program_Fee__c = 1000;
            opp.StageName = 'Prospect';
            opp.CloseDate = System.today();
            opp.Type = 'Business and Government';
            opp.CloseDate = Date.Today().addDays(5);
            opp.Forecast_MCA_Revenue__c=20000;
            
            insert opp;
            
            Quote qt = new Quote();
            
            qt.RecordTypeId = LoyaltyRecordTypeId;
            qt.OpportunityId = opp.Id;
            qt.Name = opp.Name;
            qt.Start_Date__c = opp.Start_Date__c;
            qt.Proposed_Term_of_Agreement__c = opp.Proposed_Term_of_Agreement__c;
            qt.Price_Per_Point__c = opp.Price_Per_Point__c;
            qt.Points_Per__c = opp.Points_Per__c;
            qt.Average_Annual_Spend_Per_Customer__c = opp.Average_Spend_Per_Customer__c;
            qt.Turnover__c = opp.Turnover__c;
            qt.Assumed_Tag_Rate_at_Maturity__c = opp.Assumed_Tag_Rate_at_Maturity__c;
            qt.Amount__c = opp.Amount;
            qt.Ramp_up_factor__c = opp.Ramp_up_factor__c;
            qt.Minimum_Spend_Commitment__c = opp.Minimum_Spend_Commitment__c;
            qt.Total_Points__c = opp.Total_Points__c;
            qt.Total_Program_Amount__c = opp.Total_Program_Amount__c;
            qt.Program_Fee__c = opp.Program_Fee__c;
            qt.Active__c = true;
            qt.ContactId = objcontact.Id;
            qt.Rate_Valid_after_acceptance_until__c=Date.today(); //CRM-11408 test class fix
            
            insert qt;
          
            IsRecursive.run = true; 
            opp.StageName = 'Negotiate';
            update opp;
        }
}