/**********************************************************************************************************************************

Created Date    : 13/12/2019 (DD/MM/YYYY)
Added By        : Karpagam Swaminathan
Description     : TestClass QL_OpportunityRenewalChatterPost
JIRA            : CRM - 4101
Version         : V1.0 -  Initial version


**********************************************************************************************************************************/

@isTest
private class QL_OpportunityRenewalChatterPostTest
{
    
    //Added By Praveen For test class failure fix
    @testsetup
    static void createData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
    }
    
    static testMethod void testBatchProcess() {
        
        TestUtilityDataClassQantas.enableTriggers();
        
        List<Opportunity_main__c> Opptymaintenance = new List<Opportunity_main__c>();
        
        Map<String, Opportunity_main__c> opptymain = new Map<String, Opportunity_main__c>();
        
        opptymain = TestUtilityDataClassQantas.getOpportunityMaintenanceMap();
        
        List<Opportunity> oppListupdate = new List<Opportunity>();
        
        List<String> category = new List<String>();
        List<Date> dates = new List<Date>();
        
        if(opptymain.containsKey('Corporate Airfares')){
            category.add(opptymain.get('Corporate Airfares').Category__c);
        }
        if(opptymain.containsKey('Qantas Business Savings')){
            category.add(opptymain.get('Qantas Business Savings').Category__c);
        }
        
        List<Account> accList = new List<Account>();
        
        for(Integer i=0; i<4; i++){
            
            Account acc = (new Account(Name = 'Sample+i', Active__c = true, 
                                       RecordTypeId = TestUtilityDataClassQantas.customerRecordTypeId, QF_Revenue__c = 1000.00,
                                       Estimated_Total_Annual_Revenue__c = 2000.00, 
                                       Domestic_Air_Travel_Spend__c = 3000.00, QF_Domestic_Revenue__c = 6000.00, Estimated_QF_Dom_Market_Share__c = 10,
                                       International_Air_Travel_Spend__c = 3000.00, QF_International_Revenue__c = 6000.00, EK_International_Revenue__c = 3000.00,
                                       Estimated_Int_Market_Share__c = 10, BillingCountry = 'AU'
                                      ));                
            accList.add(acc);
        }
        
        insert accList;
        
        Date t = Date.today();
        
        Decimal caOpptybeforeinmonths =  opptymain.get('Corporate Airfares').Create_an_Opportunity_before_in_months__c;
        Integer integerValue1 = caOpptybeforeinmonths.intValue();
        
        Decimal qbsOpptybeforeinmonths =  opptymain.get('Qantas Business Savings').Create_an_Opportunity_before_in_months__c;
        Integer integerValue2 = qbsOpptybeforeinmonths.intValue();
        
        Date cadt = ((t.addMonths(integerValue1)) - 1);
        Date qbsdt = ((t.addMonths(integerValue2)) - 1);    
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> openoppList = new List<Opportunity>();
        
        oppList.add(new Opportunity(Name = 'Opp1', AccountId = accList[0].id, RecordTypeId = TestUtilityDataClassQantas.businessGovRTypeId,  Amount = 500000, Category__c = 'Corporate Airfares', StageName = 'Qualify',Sub_Type_Level_1__c = 'Currently In Contract', Sub_Type_Level_2__c = 'Non-Contractual Other', CloseDate = Date.Today(),Forecast_MCA_Revenue__c=20000));
        oppList.add(new Opportunity(Name = 'Opp2', AccountId = accList[1].id, RecordTypeId = TestUtilityDataClassQantas.businessGovRTypeId,  Amount = 500000, Category__c = 'Qantas Business Savings', StageName = 'Qualify',Sub_Type_Level_1__c = 'Currently In Contract', Sub_Type_Level_2__c = 'Non-Contractual Other', CloseDate = Date.Today(),Forecast_MCA_Revenue__c=20000));
        openoppList.add(new Opportunity(Name = 'Opp3', AccountId = accList[2].id, RecordTypeId = TestUtilityDataClassQantas.businessGovRTypeId,  Amount = 500000, Category__c = 'Corporate Airfares', StageName = 'Qualify',Sub_Type_Level_1__c = 'Currently In Contract', Sub_Type_Level_2__c = 'Non-Contractual Other', CloseDate = Date.Today(),Forecast_MCA_Revenue__c=20000));
        openoppList.add(new Opportunity(Name = 'Opp4', AccountId = accList[3].id, RecordTypeId = TestUtilityDataClassQantas.businessGovRTypeId,  Amount = 500000, Category__c = 'Qantas Business Savings', StageName = 'Qualify',Sub_Type_Level_1__c = 'Currently In Contract', Sub_Type_Level_2__c = 'Non-Contractual Other', CloseDate = Date.Today(),Forecast_MCA_Revenue__c=20000));
        
        insert oppList;
        insert openoppList;
        
        List<Proposal__c> propList = new List<Proposal__c>();
        
        propList.add(new Proposal__c(Name = 'Pro1', Account__c = oppList[0].AccountId, Opportunity__c = oppList[0].Id,
                                     Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                     Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                     MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                     Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Draft',
                                     NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                     DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                     Approval_Required_Others__c = false,QL_Discount_Model__c = 'Tiered',Forecast_MCA_Revenue__c=20000));
        propList.add(new Proposal__c(Name = 'Pro2', Account__c = oppList[1].AccountId, Opportunity__c = oppList[1].Id,
                                     Active__c = true, Type__c = 'Qantas Business Savings', International_Annual_Share__c = 70,
                                     Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                     MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                     Qantas_Annual_Expenditure__c = 600000, Qantas_Club_Discount__c = 'No', Status__c = 'Draft',
                                     NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                     DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                     Approval_Required_Others__c = false,QL_Discount_Model__c = 'Tiered',Forecast_MCA_Revenue__c=20000));
        propList.add(new Proposal__c(Name = 'Pro3', Account__c = openoppList[0].AccountId, Opportunity__c = openoppList[0].Id,
                                     Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                     Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                     MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                     Qantas_Annual_Expenditure__c = 700000, Qantas_Club_Discount__c = 'No', Status__c = 'Draft',
                                     NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                     DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                     Approval_Required_Others__c = false,QL_Discount_Model__c = 'Tiered',Forecast_MCA_Revenue__c=20000));
        propList.add(new Proposal__c(Name = 'Pro4', Account__c = openoppList[1].AccountId, Opportunity__c = openoppList[1].Id,
                                     Active__c = true, Type__c = 'Qantas Business Savings', International_Annual_Share__c = 70,
                                     Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',
                                     MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),
                                     Qantas_Annual_Expenditure__c = 800000, Qantas_Club_Discount__c = 'No', Status__c = 'Draft',
                                     NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                     DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                     Approval_Required_Others__c = false,QL_Discount_Model__c = 'Tiered',Forecast_MCA_Revenue__c=20000));
        insert propList;
        
        List<Contract__c> contrList = new List<Contract__c>();
        
        contrList.add(new Contract__c(Name = 'Con1' , Account__c = propList[0].Account__c, Opportunity__c = propList[0].Opportunity__c, Proposal__c = propList[0].Id,
                                      Active__c = true, Type__c = category[0], International_Annual_Share__c = 70,
                                      Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = TRUE,
                                      MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today().addMonths(-1), Contract_End_Date__c = cadt,
                                      Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signed by Customer' , QL_Effective_Tier__c = 'Tier 1', QL_Discount_Model__c ='Tiered'                                            
                                     ));
        
        contrList.add(new Contract__c(Name = 'Con2' , Account__c = propList[1].Account__c, Opportunity__c = propList[1].Opportunity__c, Proposal__c = propList[1].Id,
                                      Active__c = true, Type__c = category[1], International_Annual_Share__c = 70,
                                      Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = TRUE,
                                      MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = qbsdt,
                                      Qantas_Annual_Expenditure__c = 600000, Qantas_Club_Discount__c = 'No', Status__c = 'Signed by Customer', QL_Effective_Tier__c = 'Tier 1', QL_Discount_Model__c ='Tiered'                                               
                                     ));
        
        contrList.add(new Contract__c(Name = 'Con3' , Account__c = propList[2].Account__c, Opportunity__c = propList[2].Opportunity__c, Proposal__c = propList[2].Id,
                                      Active__c = true, Type__c = category[0], International_Annual_Share__c = 70,
                                      Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = TRUE,
                                      MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = cadt,
                                      Qantas_Annual_Expenditure__c = 700000, Qantas_Club_Discount__c = 'No', Status__c = 'Signed by Customer', QL_Effective_Tier__c = 'Tier 1', QL_Discount_Model__c ='Tiered'                                              
                                     ));
        
        contrList.add(new Contract__c(Name = 'Con4' , Account__c = propList[3].Account__c, Opportunity__c = propList[3].Opportunity__c, Proposal__c = propList[3].Id,
                                      Active__c = true, Type__c = category[1], International_Annual_Share__c = 70,
                                      Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = TRUE,
                                      MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = qbsdt,
                                      Qantas_Annual_Expenditure__c = 800000, Qantas_Club_Discount__c = 'No', Status__c = 'Signed by Customer', QL_Effective_Tier__c = 'Tier 1', QL_Discount_Model__c ='Tiered'                                               
                                     ));
        
        insert contrList;
        
        for (Opportunity oppty : oppList){
            oppty.StageName = 'Closed - Accepted';
            oppty.Closed_Reasons__c = 'Network';
            oppty.CloseDate = Date.Today().addDays(-5);
            oppty.Forecast_MCA_Revenue__c=20000;
            oppty.Other_reasons__c = 'Network';
            oppListupdate.add(oppty);
        }
        
        update oppListupdate;              
        
        Test.startTest();
        QL_OpportunityRenewalChatterPost  batchObj = new QL_OpportunityRenewalChatterPost();
        Database.executeBatch(batchObj);
        Test.stopTest(); 
    }         
}