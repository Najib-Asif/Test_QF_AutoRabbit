/***********************************************************************************************************************************

Description: Test for the apex class QL_searchController

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam   CRM-3132    Test for the apex class QL_searchController           T01

Created Date    : 30/05/2018 (DD/MM/YYYY)

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated setUpAccsnapshotData() method.

**********************************************************************************************************************************/
@isTest
public class QL_searchControllerTest {
    @testSetup static void setUpAccsnapshotData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        
        //   List<Account> accList =TestUtilityDataClassQantas.getAccounts();
        
        Account testAcc = new Account();
        testAcc.Name = 'TestAccount';
        // testAcc.Last_Completed_Account_Review__c = Date.today().addDays(-3);
        // testAcc.Last_Activity_Created_Date__c = Date.today().addDays(-30);
        testAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        testAcc.BillingCountry = 'AU';
        insert testAcc;
    }
    
    @isTest static void testAccountSnapshot(){
        String field_API_text='Name';
        String field_API_val='Id';
        String field_API_val1='Total_Air_Spend__c';
        String field_API_val2='QF_Market_Share__c';
        String field_API_val3='QF_Contracted_QF_Actual__c';
        String field_API_val4='QF_International_Market_Share__c';
        String field_API_val5='Latest_Period_Date__c';
        String field_API_val6='Qantas_Corporate_Identifier__c';
        String field_API_val7='Sentiment__c';
        String field_API_val8='Type';
        String field_API_val9='Person Account';
        String field_API_val10='Domestic_Annual_Share__c';
        String field_API_val11='Contract_Start_Date__c';
        String field_API_val12='Contract_End_Date__c';
        String field_API_val13='QF_Revenue__c';
        String field_API_val14='QF_DOMESTIC_MARKET_SHARE__c';
        String field_API_val15='Qantas_Annual_Expenditure__c';
        String field_API_val16='International_Annual_Share__c';
        
        Test.startTest();
        
        //QL_searchController.searchDB('Account',String.valueof([SELECT Name FROM Account]),String.valueof([SELECT Id FROM Account]),String.valueof([Select Total_Air_Spend__c FROM Account]),String.valueof([SELECT QF_Market_Share__c FROm Account],String.valueof([SELECT QF_Contracted_QF_Actual__c FROm Account]),String.valueof([SELECT QF_International_Market_Share__c FROM Account]),String.valueof([SELECT Latest_Period_Date__c FROM account]),String.valueof([SELECT Qantas_Corporate_Identifier__c FROM Account]),String.valueof([SELECT Sentiment__c FROM Account]),String.valueof([SELECT Type From Account]),'Person Account',String.valueof([SELECT Domestic_Annual_Share__c FROM Account]),String.valueof([SELECT Domestic_Annual_Share__c FRom Account]),String.valueof([SELECT Contract_Start_Date__c FROM Account]),String.valueof([SELECT Contract_End_Date__c From Account]),String.valueof([SELECT QF_Revenue__c FROM Account]),String.valueof([SELECT QF_DOMESTIC_MARKET_SHARE__c FROM Account]),String.valueof([SELECT Qantas_Annual_Expenditure__c From Account]),20,String.valueof([SELECT Name FROM Account]),'test'));  
        QL_searchController.searchDB('Account',field_API_Text,  field_API_Val,  field_API_Val1, field_API_Val2, field_API_Val3, field_API_Val4, field_API_Val5, field_API_Val6, field_API_Val7, field_API_Val8, field_API_Val9, field_API_Val10, field_API_Val11, field_API_Val12, field_API_Val13, field_API_Val14, field_API_Val15, field_API_Val16,20,field_API_Text,'test'); 
        Test.stopTest();
    }
}