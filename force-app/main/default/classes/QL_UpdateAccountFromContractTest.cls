/**
 * @desc: test class for QL_UpdateAccountFromContract
 * @author: Navpreet Kaur
 * @jira ticket: CRM-9795
 * @log
 * 		created date: 23/06/2025 Navpreet Kaur
 */
@isTest
public class QL_UpdateAccountFromContractTest {
    @isTest
    static void test1() {
		List<Account> insertAccounts=new List<Account>();
		List<Account> updateAccounts=new List<Account>();
		Id AccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Account').getRecordTypeId();
		//listUser = TestUtilityDataClassQantas.getUsers('Standard User', 'Department 1', 'QF');

		 TestUtilityDataClassQantas.insertQantasConfigData();
            List<Trigger_Status__c> listTriggerConfigs = new List<Trigger_Status__c>();
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
            listTriggerConfigs.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
            for(Trigger_Status__c triggerStatus : listTriggerConfigs){
                triggerStatus.Active__c = false;
            }
            insert listTriggerConfigs;
        //create an account
		Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Customer Account', 
                                          RecordTypeId = AccRecType, Migrated__c = false, 
                                          Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                          Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,ABN_Tax_Reference__c = '1234567890'  
                                         );	

		insertAccounts.add(acc);
        Test.startTest(); 
		insert insertAccounts; 
		 
        insertAccounts[0].Estimated_Total_Air_Travel_Spend__c=150;
		updateAccounts.add(insertAccounts[0]);
        System.enqueueJob(new QL_UpdateAccountFromContract(updateAccounts));
        insertAccounts[0].ownerid=UserInfo.getUserId();
		updateAccounts.add(insertAccounts[0]);
        System.enqueueJob(new QL_UpdateAccountFromContract(updateAccounts));
        Test.stopTest();
        

    }
}