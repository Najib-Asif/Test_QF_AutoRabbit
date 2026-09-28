/*----------------------------------------------------------------------------------------------------------------------
Author:        Jay
Company:       TCS
Description:   To restrict sales performance manager action on future invoice (Channel Payment)
Inputs:
Test Class:     PaymentTriggerHandler
************************************************************************************************
History
************************************************************************************************
09-Oct-2019      Jay                        invoiceRestrictionTest

Modified By : Venkata Suresh Kumar (TCS Team), 2-Apr-2026
Desc : Remediated test class failures. Added insertTestData() method. Updated invoiceRestrictionTest()
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class PaymentTriggerHandlerTest {
    @TestSetup
    public static void insertTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest 
    public static void invoiceRestrictionTest() {
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        Id caRTId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Agency_Signed_by_Customer').getRecordTypeId();
        Id cpciRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Incentive').getRecordTypeId();
        Id cpctfRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Channel_Tech_Fund').getRecordTypeId();
        Id quotRTId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId();
        Id optyRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Agency_Partnerships').getRecordTypeId();
        Id inapRTId = Schema.SObjectType.Invoices__c.getRecordTypeInfosByDeveloperName().get('Agency_Payments').getRecordTypeId();
        List < Invoices__c > newList = new List < Invoices__c >();
        Map < Id, Invoices__c > oldMap = new Map < Id, Invoices__c >();
        
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
        
        Invoices__c Inv = new Invoices__c(Contract_Payments__c = cp.Id, RecordTypeId =inapRTId ,Amount__c = 0, Start_Date__c=system.today() , End_Date__c =system.today().addmonths(3), Payment_Due_Date_System__c=system.today().addmonths(4), Status__c = 'Draft' );
        
        Test.StartTest();
        insert Inv; 
        newList.add(Inv);
        oldMap.put(Inv.Id, Inv);
        
        PaymentTriggerHandler.futureInvoiceRestrictionMethod(newList,oldMap);
        Invoices__c Inv2 = new Invoices__c(Contract_Payments__c = cp.Id, RecordTypeId =inapRTId ,Amount__c = 0, Start_Date__c=system.today().addmonths(4) , End_Date__c =system.today().addmonths(6), Payment_Due_Date_System__c=system.today().addmonths(7), Status__c = 'Draft' );
        insert Inv2; 
        newList.add(Inv2);
        try{
            Inv2.Invoice_Reason__c ='testreason'; 
            update Inv2;
            oldMap.put(Inv2.Id, Inv2);
        }
        catch(Exception ex){}
        Test.StopTest(); 
    }
}