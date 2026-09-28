/*
* Modified By : Venkata Suresh Kumar Yalla (TCS Team), 29-May-2026
Desc : Rmediated test class failures. Updated myTest() method.Updated 'Qantas Sales' profile ref with 'QL_Sales' 
******************************************************************
History
21-Jul-2026		Jonathan-Capgemini		RBAC SND
*/
@isTest
public class Test_OpportunityTeam {

    public static testMethod void myTest(){
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<User> twoUsers = new List<User>();
         
         // Custom setting creation
         TestUtilityDataClassQantas.enableTriggers();
         
         // Load Accounts
         accList = TestUtilityDataClassQantas.getAccounts();
         
         // Users
        twoUsers = TestUtilityDataClassQantas.getUsers('Sales and Distribution-Sales', 'Marketing Acquisition & Sales Team', ''); // CRM-11408 Test class fix //RBAC SND
         
         Opportunity opp = new Opportunity(Name = 'Opp'+accList[0].Name , AccountId = accList[0].Id,
                                           Amount = 500000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),
                                           StageName = 'Identified'
                                           );
          try{
              Database.Insert(opp);
          }catch(Exception e){
              System.debug('Exception Occured: '+e.getMessage());
          }
    }
}