@isTest
public class QEC_GenerateProposalControllerTest 
{
    public static contract__c newCont;
    
    @testsetup
    public static void createTestData()
    {
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String OppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business and Government').getRecordTypeId();
        string casRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Deal Support Request').getRecordTypeId();
        
        //Enable Trigger pre-requisites     
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
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
        
        //Enable triggers for Account creation
        Trigger_Status__c ts = new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true);
        insert ts;    
        Trigger_Status__c tsSplCon = new Trigger_Status__c(Name = 'SpecialConditionsTrigger', Active__c = true);
        insert tsSplCon;  
        
        //Create Account
        Account testacc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                      RecordTypeId = accRTId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N');
        insert testacc;
        
        //Create Contact
        Contact testcon = new Contact(FirstName='Bob',LastName='Test',AccountId=testacc.id,Function__c = 'IT',Business_Types__c = 'Agency',Email = 'abc@test.com');
        insert testcon;
        
        //Create Opportunity
        Opportunity validOpp1 = new Opportunity(Name = 'Opp3'+testacc.Name , AccountId = testacc.Id,Proposed_Market_Share__c = 70,Proposed_International_Market_Share__c = 50,
                                                Amount = 500000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),Proposed_MCA_Routes_Market_Share__c = 90,
                                                StageName = 'Qualify',Forecast_MCA_Revenue__c=20000);
        insert validOpp1; 
        
        //Create Proposal
        Proposal__c validProp = new Proposal__c(Name = 'Proposal1', Account__c = validOpp1.AccountId, Opportunity__c = validOpp1.Id,Contact__c=testcon.Id,
                                                Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                                Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No',TMC_Code__c=null,
                                                MCA_Routes_Annual_Share__c = 70, Valid_From_Date__c = Date.Today(),Approval_Required_Others__c = false,
                                                Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Accepted by Customer',
                                                NAM_Approved__c = false, NAM_Rejected__c = false, Pricing_Approved__c = false, Pricing_Rejected__c = false,
                                                DO_Approved__c = false, DO_Rejected__c = false, TeamLead_Approved__c = false, TeamLead_Rejected__c = false,
                                                Agent_Email__c='abc@test.com',Agent_Address__c='testaddr',Agent_Name__c='test',Travel_Fund__c='No',
                                                Legal_TC__c='sample test2',Deal_Type__c='Share',Proposal_Start_Date__c=Date.Today(), Proposal_End_Date__c=Date.Today().addDays(20),
                                                Agent_Fax__c='123456789',Commercial_TC__c = 'sample test1',Frequent_Flyer_Status_Upgrade_Offer__c='',Qantas_Club_Join_Discount_Offer__c='',Qantas_Club_Discount_Offer__c='',
                                                Travel_Fund_Amount__c=null,Standard__c='No',Additional_Change_Details__c='',QL_Discount_Model__c='Tiered',Forecast_MCA_Revenue__c=20000

                                               );
        insert validProp;
        
        //Create Contract
        Contract__c contr1 = new Contract__c(Name = 'Sample Contract1', Account__c = validProp.Account__c, Opportunity__c = validProp.Opportunity__c, Proposal__c = validProp.Id,
                                             Active__c = true, Type__c = 'Corporate Airfares', International_Annual_Share__c = 70,
                                             Domestic_Annual_Share__c = 90, Frequent_Flyer_Status_Upgrade__c = 'No', Contracted__c = false,
                                             MCA_Routes_Annual_Share__c = 70, Contract_Start_Date__c = Date.Today(), Contract_End_Date__c = Date.Today(),
                                             Qantas_Annual_Expenditure__c = 500000, Qantas_Club_Discount__c = 'No', Status__c = 'Signature Required by Customer'                                              
                                            );
        insert contr1;
        
        //Create Custom Metadata
        Domestic_Dealsheet__mdt objMdt = new Domestic_Dealsheet__mdt(Domain__c='',BTL_URL__c='',PDF__c='',URL__c='',Word__c='');
        
        //Create Case
        Case c = new case(RecordTypeId = casRTID, Sub_Type__c = 'Channel Agency Payment Contract', AccountId = testacc.Id, Related_Contract__c = contr1.Id,
                          Type = 'Deal Termination', Due_Date__c = system.today().addmonths(1), ReasonsForTermination__c='Market Share', Reasons_for_Termination__c = 'Test termination', End_Date__c = system.today().addmonths(3),
                          Status = 'Not yet assigned - with Account Manager',Distribution_Email__c='test123@email.com');
        insert c;
    }
    
    @isTest
    public static void TestDomesticTrue()
    {
        contract__c con = [select id from contract__c where name ='Sample Contract1' limit 1];
        Test.startTest();
        QEC_GenerateProposalController.getContractInfo(con.Id, 'Domestic', True);
        Test.stopTest();
    }
    @isTest
    public static void TestDomesticFalse()
    {
        contract__c con = [select id from contract__c where name ='Sample Contract1' limit 1];
        Test.startTest();
        QEC_GenerateProposalController.getContractInfo(con.Id, 'Domestic', False);
        Test.stopTest();
    }
    @isTest
    public static void TestInernationalTrue()
    {
        contract__c con = [select id from contract__c where name ='Sample Contract1' limit 1];
        Test.startTest();
        QEC_GenerateProposalController.getContractInfo(con.Id, 'International', True);
        Test.stopTest();
    }
    @isTest
    public static void TestInernationalFalse()
    {
        contract__c con = [select id from contract__c where name ='Sample Contract1' limit 1];
        Test.startTest();
        QEC_GenerateProposalController.getContractInfo(con.Id, 'International', False);
        Test.stopTest();
    }
}