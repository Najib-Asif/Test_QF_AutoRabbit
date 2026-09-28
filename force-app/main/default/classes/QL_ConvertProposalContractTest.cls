/*----------------------------------------------------------------------------------------------------------------------
Author:        Gnanavelu
Description:   Test class for QL_ConvertProposalContract & QL_ConvertToOpportunity
************************************************************************************************
History
************************************************************************************************
19-July-2018      Gnanavelu               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QL_ConvertProposalContractTest 
{
    @testSetup
    static void createData() {
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic','Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic','Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode International','International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational','   Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible','Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed','Closed'));
        
        insert lstConfigData;
    }
    
    @isTest
    static void createProposalContractTest()
    {
        Account acc = new Account(Name = 'Test Customer Account', Estimated_Total_Annual_Revenue__c = 123456, QF_Revenue__c = 456789, Estimated_MCA_Revenue__c = 2034, Type = 'Customer Account', 
                                  Estimated_QF_Dom_Market_Share__c = 54, Domestic_Air_Travel_Spend__c = 56321,
                                  QF_Domestic_Revenue__c = 85744, Estimated_Int_Market_Share__c = 10, International_Air_Travel_Spend__c = 112,
                                  QF_International_Revenue__c = 2351, Estimated_Int_MCA_Market_Share__c = 12, ABN_Tax_Reference__c = '1234567890');                                                                                                   
        
        insert acc;
        
        Opportunity Opp = new Opportunity(Name='Opportunity Test',StageName='Qualify', Category__c='Corporate Airfares', CloseDate = Date.Today(),
                                          Amount = 500000, Forecast_Charter_Spend__c = 326123, Contact_Information__c = 'Contact information',
                                          Description = 'Test description', AccountId=acc.Id);
        
        Case caserecord = new Case(AccountId = acc.Id, Type = 'Adhoc',
                                   Subject = 'Adhoc chatter', Description='Adhoc description', Status= 'Open',
                                   Frequent_Flyer_Number__c = '7799339937', RecordTypeId = '012900000016QKv');        
        
        Test.startTest();
        try {
        insert Opp;
        insert caserecord;
        QL_ConvertToOpportunity.createOpportunity(caserecord.Id);
        QL_ConvertProposalContract.createProposalContract(Opp.Id);   
        }
        catch(Exception ex){

        }
        Test.stopTest();
        
    }
}