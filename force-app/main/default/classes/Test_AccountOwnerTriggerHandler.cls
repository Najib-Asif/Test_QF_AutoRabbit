/*
 * Modified By : Venkata Suresh Kumar Yalla (TCS Team), 29-May-2026
Desc : Rmediated test class failures. Updated myTest() method.Updated 'Qantas Sales' profile ref with 'QL_Sales' 
********************************************************************
History
21-Jul-2026		Jonathan-Capgemini		RBAC SND
*/

@isTest
public class Test_AccountOwnerTriggerHandler{

    public static testMethod void myTest(){
        List<User> twoUsers = new List<User>();
        
        // Custom setting creation
        TestUtilityDataClassQantas.enableTriggers();
        
        // Users
        twoUsers = TestUtilityDataClassQantas.getUsers('Sales and Distribution-Sales', 'MAS Team', ''); // CRM-11408 Test class fix //RBAC SND
        
        // Account Owner object data creation    
        Account_Owner__c ao = new Account_Owner__c(Name = 'S', Account_Manager__c = UserInfo.getUserId(), Business_Development_Rep__c = twoUsers[0].Id);
        
        try{
            Database.Insert(ao);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        
        ao.Account_Manager__c = twoUsers[0].Id;
        ao.Business_Development_Rep__c = UserInfo.getUserId();
        
        try{
            Database.Update(ao);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
        
    }
}