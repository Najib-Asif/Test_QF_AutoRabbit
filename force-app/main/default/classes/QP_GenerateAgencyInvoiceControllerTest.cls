/**********************************************************************************************************************

Description: Test Method-Lightning component handler for QC Generate Agency Invoice functionality.
Class Name      : QP_GenerateAgencyInvoiceController
Created Date    : 20/08/19 (DD/MM/YYYY)
Author          : Jay   TCS    Salesforce Developer  

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method. Updated generateInvoiceTest()
************************************************************************************************************************/
@isTest
public class QP_GenerateAgencyInvoiceControllerTest {
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest 
    public static void generateInvoiceTest() {
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Id caRTId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId();
        Id cpciRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Incentive').getRecordTypeId();
        Id cpctfRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Tech_Fund').getRecordTypeId();
        Id quotRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId();
        Id optyRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId();
        
        //String ContractPay_CounterQuarterly = System.Label.ContractPay_CounterQuarterly;
        
        //Create Account
        Account testacc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                      RecordTypeId = accRTId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', ABN_Tax_Reference__c ='12345678901');
        insert testacc;
        
        Opportunity validOpp = new Opportunity(Name = 'Opp2'+testacc.Name , AccountId = testacc.Id,Proposed_Market_Share__c = 70,Proposed_International_Market_Share__c = 50,
                                               Amount = 500000,  CloseDate = Date.Today(),Proposed_MCA_Routes_Market_Share__c = 90,
                                               StageName = 'Closed - Accepted', RecordTypeId = optyRTId, Category__c = 'Corporate Airfares',Forecast_MCA_Revenue__c=20000);
        insert validOpp;
        
        Quote quorec = new Quote(Name = 'testquot', OpportunityId =validOpp.Id,  Status = 'Draft', RecordTypeId = quotRTId);
        //AccountId = testacc.Id,
        // BillingAddress = 'AU'
        quorec.Rate_Valid_after_acceptance_until__c = Date.today();
        insert quorec;
        
        //Create Contract
        Contract__c contr = new Contract__c(Name = 'Sample Contract', Account__c = testacc.Id, Opportunity__c = validOpp.Id, 
                                            Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                            Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                            MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = system.today(), Contract_End_Date__c = system.today().addmonths(12),
                                            Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer'                                              
                                           );
        insert contr;   
        
        Contract_Payments__c cp = new Contract_Payments__c(Quote__c = quorec.Id, RecordTypeId = cpctfRTId, Contract_Agreement__c =contr.Id , Amount__c = 4000, Type__c = 'Tech fund', Payment_Frequency__c = 'Quarterly');
        
        insert cp;
        
        Test.StartTest();
        //Invoke the controller methods
        QP_GenerateAgencyInvoiceController.getGenerateInvoice(contr.Id);
        
        Contract__c contr1 = new Contract__c(Name = 'Sample Contract1', Account__c = testacc.Id, Opportunity__c = validOpp.Id, 
                                             Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                             Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                             MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = system.today(), Contract_End_Date__c = system.today().addmonths(12),
                                             Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer'                                              
                                            );
        insert contr1;   
        Contract_Payments__c cp1 = new Contract_Payments__c(Quote__c = quorec.Id, RecordTypeId = cpctfRTId, Contract_Agreement__c =contr1.Id , Amount__c = 4000, Type__c = 'Tech fund', Payment_Frequency__c = 'Half-Yearly');
        
        insert cp1;
        
        QP_GenerateAgencyInvoiceController.getGenerateInvoice(contr1.Id);
        QP_GenerateAgencyInvoiceController.getGenerateInvoice(contr1.Id);
        
        Contract__c contr2 = new Contract__c(Name = 'Sample Contract2', Account__c = testacc.Id, Opportunity__c = validOpp.Id, 
                                             Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                             Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                             MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = system.today(), Contract_End_Date__c = system.today().addmonths(12),
                                             Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer'                                              
                                            );
        insert contr2;   
        Contract_Payments__c cp2 = new Contract_Payments__c(Quote__c = quorec.Id, RecordTypeId = cpctfRTId, Contract_Agreement__c =contr2.Id , Amount__c = 4000, Type__c = 'Incentive', Payment_Frequency__c = 'Yearly');
        
        insert cp2;
        
        QP_GenerateAgencyInvoiceController.getGenerateInvoice(contr2.Id);
        QP_GenerateAgencyInvoiceController.getGenerateInvoice(contr2.Id);
        
        Test.StopTest(); 
    }
}