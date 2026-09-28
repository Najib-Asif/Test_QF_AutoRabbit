/***********************************************************************************************************************************

Description: Test for the apex class QL_AccountHealthIndicator

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Pushkar Purushothaman   CRM-3075    Test for the apex class QL_AccountHealthIndicator           T01
Pushkar Purushothaman   CRM-3336    Logic added for freight accounts           					T02    

Created Date    : 30/04/2018 (DD/MM/YYYY)

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated setUpData() method.
**********************************************************************************************************************************/
@isTest
public class QL_AccountHealthIndicatorTest {
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Strategic_Account_Plan__c> sapList = new List<Strategic_Account_Plan__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contract__c> crtList = new List<Contract__c>();
        
        Account testAcc = new Account();
        testAcc.Name = 'TestAccount';
        testAcc.Last_Completed_Account_Review__c = Date.today().addDays(-3);
        testAcc.Last_Activity_Created_Date__c = Date.today().addDays(-30);
        testAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        testAcc.BillingCountry = 'AU';
        testAcc.Contracted__c = true;
        insert testAcc;
       
        Account testAcc2 = new Account();
        testAcc2.Name = 'TestAccount2';
        testAcc2.Last_Completed_Account_Review__c = Date.today().addDays(-3);
        testAcc2.Last_Activity_Created_Date__c = Date.today().addDays(-30);
        testAcc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        testAcc2.BillingCountry = 'AU';
        testAcc2.Contracted__c = true;
        insert testAcc2;
        
        for(Integer i=0;i<3;i++){
            Strategic_Account_Plan__c sap = new Strategic_Account_Plan__c();
            sap.Name = 'TestSAP'+i;
            sap.Account__c = testAcc.id;
            sap.Status__c = 'Active';
            sap.Plan_End_Date__c = Date.today();
            sapList.add(sap);
        }
        insert sapList;
        
        for(Integer i=0;i<3;i++){
            Opportunity opp = new Opportunity();
            opp.AccountId = testAcc.id;
            opp.Name = 'TestOpp'+i;
            opp.StageName = 'Contract';
            opp.Type = 'Business and Government';
            opp.CloseDate = Date.today().addDays(-2);
            opp.Status_Last_Changed__c = Date.today().addDays(-10);
			opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Freight').getRecordTypeId();
            opp.Forecast_MCA_Revenue__c=20000;
            oppList.add(opp);
        }
        insert oppList;
        
        for(Opportunity opp : oppList){
            Contract__c crt = new Contract__c();
            crt.Opportunity__c = opp.Id;
            crt.Account__c = testAcc.id;
            crt.Name = 'TestContract'+opp.Id;
            crt.Contract_Start_Date__c = Date.today();
            crt.Status__c = 'Signed by Customer';
            crt.QL_Effective_Tier__c = 'Tier 1';
            crt.QL_Discount_Model__c ='Tiered';
            crtList.add(crt);
        }       
        insert crtList;
    }
    
    @isTest static void testAHI(){
        List<String> AccountIdList = new List<String>();
        for(Account acc : [select id from Account])
            AccountIdList.add(acc.id);
        Test.startTest();
        QL_AccountHealthIndicator.computePercentage(AccountIdList,'Account',true);     
        Test.stopTest();
    }
    
    @isTest static void testAHINoncontractedQBR(){
        List<Strategic_Account_Plan__c> sapList1 = new List<Strategic_Account_Plan__c>();
        List<Opportunity> oppList1 = new List<Opportunity>();
        List<Contract__c> crtList1 = new List<Contract__c>();
        List<Contact> allCont = new List<Contact>();
        List<AccountContactRelation> AccConRel = new List<AccountContactRelation>();
		Set<ID> ids = new Set<ID>();
        
        Account testAcc1 = new Account();
        testAcc1.Name = 'TestAccount';
        testAcc1.Last_Completed_Account_Review__c = Date.today().addDays(-3);
        testAcc1.Last_Activity_Created_Date__c = Date.today().addDays(-30);
        testAcc1.BillingCountry = 'AU';
        testAcc1.Contracted__c = false;
        testAcc1.Industry = 'Other Services';
        insert testAcc1;
       
        for(Integer i=0;i<3;i++){
            Strategic_Account_Plan__c sap = new Strategic_Account_Plan__c();
            sap.Name = 'TestSAP'+i;
            sap.Account__c = testAcc1.id;
            sap.Status__c = 'Active';
            sap.Plan_End_Date__c = Date.today();
            sapList1.add(sap);
        }
        insert sapList1;
        
        List<String> AccountIdList = new List<String>();
        for(Account acc : [select id from Account])
            AccountIdList.add(acc.id);
        Test.startTest();
        QL_AccountHealthIndicator.computePercentageNonContractedQBR(AccountIdList,'Account',true);     
        Test.stopTest();
    }
    
    @isTest static void testAHIFreight(){
        List<String> AccountIdList = new List<String>();
        for(Account acc : [select id from Account])
            AccountIdList.add(acc.id);
        Test.startTest();
        QL_AccountHealthIndicator.computePercentage_Freight(AccountIdList,'Account',true);     
        Test.stopTest();
    }
}