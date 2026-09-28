/***********************************************************************************************************************************
Description: Test Class for QL_RecordTypeSelectionController 

History:
======================================================================================================================
Name                    Jira        Description                                               Tag
======================================================================================================================
Gnanavelu T             CRM-3172    Test Class for QL_RecordTypeSelectionController           T01

Created Date    : 28/06/2018 (DD/MM/YYYY)

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
**********************************************************************************************************************************/
@isTest
public class QL_RecordTypeSelectionControllerTest {
    
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest static void findRecordTypesTest()
    {
        Account acc = new Account(Name = 'Test Customer Account', Estimated_Total_Annual_Revenue__c = 123456, QF_Revenue__c = 456789, Estimated_MCA_Revenue__c = 2034, Type = 'Customer Account', 
                                  Estimated_QF_Dom_Market_Share__c = 54, Domestic_Air_Travel_Spend__c = 56321,
                                  QF_Domestic_Revenue__c = 85744, Estimated_Int_Market_Share__c = 10, International_Air_Travel_Spend__c = 112,
                                  QF_International_Revenue__c = 2351, Estimated_Int_MCA_Market_Share__c = 12, ABN_Tax_Reference__c = '1234567890');                                                                                                   
        // insert acc;
        
        Account acc1 = new Account(Name = 'Test Customer Account1', Estimated_Total_Annual_Revenue__c = 0, QF_Revenue__c = 456789, Estimated_MCA_Revenue__c = 0, Type = 'Customer Account', 
                                   Estimated_QF_Dom_Market_Share__c = 0, Domestic_Air_Travel_Spend__c = 56321,
                                   QF_Domestic_Revenue__c = 85744, Estimated_Int_Market_Share__c = 0, International_Air_Travel_Spend__c = 112,
                                   QF_International_Revenue__c = 2351, Estimated_Int_MCA_Market_Share__c = 0, ABN_Tax_Reference__c = '1234567860');
        // insert acc1;
        
        List<Account> Acclist = new List<Account>();
        Acclist.add(acc);
        Acclist.add(acc1);
        
        Test.startTest();
        insert Acclist;
        QL_RecordTypeSelectionController.findRecordTypes('Case');   
        QL_RecordTypeSelectionController.findRecordTypes('Opportunity'); 
        QL_RecordTypeSelectionController.fetchOpportunityfields(acc.Id);
        QL_RecordTypeSelectionController.getRecTypeId('012900000016QKx','Case');
        QL_RecordTypeSelectionController.fetchOpportunityfields(acc1.Id);
        Test.stopTest();
    }
    
    @isTest static void fetchSAPfieldsTest()
    {
        Account acc = new Account(Name = 'Test Customer Account', Estimated_Total_Annual_Revenue__c = 123456, QF_Revenue__c = 456789, Estimated_MCA_Revenue__c = 2034, Type = 'Customer Account', 
                                  Estimated_QF_Dom_Market_Share__c = 54, Domestic_Air_Travel_Spend__c = 56321,
                                  QF_Domestic_Revenue__c = 85744, Estimated_Int_Market_Share__c = 10, International_Air_Travel_Spend__c = 112,
                                  QF_International_Revenue__c = 2351, Estimated_Int_MCA_Market_Share__c = 12, ABN_Tax_Reference__c = '1238567890',
                                 Ownerid='00590000004hked', Description='Test description');
        Test.startTest();
        insert acc;
        QL_RecordTypeSelectionController.fetchSAPfields(acc.Id);
        Test.stopTest();
    }
    
    @isTest static void fetchRelationshipfieldsTest()
    {        
        List<Account> Acclist = TestUtilityDataClassQantas.getAccounts();        
        List<Contact> ConList = TestUtilityDataClassQantas.getContacts(Acclist);
        Test.startTest();
        QL_RecordTypeSelectionController.fetchRelationshipfields(ConList[0].Id);
        Test.stopTest();
    }
    
    @isTest static void fetchDSCasefieldsTest()
    {
        List<Account> Acclist = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> Opplist = TestUtilityDataClassQantas.getOpportunities(Acclist);
        List<Proposal__c> PropList = TestUtilityDataClassQantas.getProposal(Opplist);
        List<Contract__c> contrList = TestUtilityDataClassQantas.getContracts(PropList);
        
        Test.startTest();
        QL_RecordTypeSelectionController.fetchDSCasefields(contrList[0].Id);
        Test.stopTest();
    }
    
    @isTest static void fetchFFCasefieldsTest()
    {
       // List<Account> Acclist = TestUtilityDataClassQantas.getAccounts();
       // List<Case> caseList = TestUtilityDataClassQantas.getCases(Acclist);
       // system.debug('casel ise'+caseList[0].Id);
    }
}