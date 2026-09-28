/***********************************************************************************************************************************

Description: Test Method Lightning component handler for the customer contract approval 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-2797   Test method for LEx-Contract Approval                  T01
                                    
Created Date    : 25/09/17 (DD/MM/YYYY)

**********************************************************************************************************************************/

@isTest
private class QL_ContractCustApprovedTest { 
    
  @testsetup
   static void createTestData(){
     
         // Custom setting creation
         QL_TestUtilityData.enableCPTriggers();
         //Enable Asset Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAssetTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContractTriggerSetting());
        insert lsttrgStatus;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg QBD Registration Rec Type','QBD Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type', 'Aquire Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Public Scheme Rec Type','Public Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Corporate Scheme Rec Type','Corporate Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Status','Active'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate NZD','15'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate AUD','10'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SchemesPointRoundOffNumber','500'));
        insert lstConfigData;
        
         
   }
   static testMethod void validateTestData() {
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<Proposal__c> propList = new List<Proposal__c>();
         List<Discount_List__c> discList = new List<Discount_List__c>();
         List<Contract__c> conList = new  List<Contract__c>();
         
         
         // Load Accounts
         accList = QL_TestUtilityData.getAccounts();
         
         // Load Opportunities
         oppList = QL_TestUtilityData.getOpportunities(accList);
         
         // Load Proposals
         propList = QL_TestUtilityData.getProposal(oppList);
         
         //Load Contract
         conList = QL_TestUtilityData.getContracts(propList);
         
         //Create Account 
        Account objAcc = TestUtilityDataClassQantas.createAccount(); 
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;

        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        insert objContact;

        //Create Opportunity
        Opportunity objOppty = TestUtilityDataClassQantas.CreateOpportunity(objAcc.Id);
        objOppty.Name='OppTest2';   
        objOppty.Type='Business and Government';
        objOppty.Forecast_MCA_Revenue__c=20000;
        insert objOppty;
         
        //Create Contract
        Contract__c objContract = TestUtilityDataClassQantas.createContract(objAcc.Id,objOppty.Id);
        objContract.CurrencyIsoCode='AUD';
        objContract.Active__c = true;
        objContract.Type__c = 'Corporate Airfares';
        objContract.Name = 'TestContracts';
        objContract.Qantas_Club_Join_Discount_Offer__c = '7%';
        objContract.Qantas_Club_Join_Discount_Offer__c = '21%';
        objContract.QL_Effective_Tier__c = 'Tier 1';
        insert objContract;
         //Asset for Parent Contract
         Asset tstAsset = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id,objContract.id,'Corporate Scheme','Coordinator');
         tstAsset.Contract__c = objContract.id;
         tstAsset.Waiver_Start_Date__c = System.TODAY();
         tstAsset.Waiver_End_Date__c = System.TODAY().addDays(1);
         tstAsset.Qantas_Club_Join_Discount__c = 10;
         tstAsset.Member_Fee_Discount__c = 12;
         System.debug('TestPush***'+tstAsset);
         insert tstAsset;

         Test.startTest();               
        try{
             for(Contract__c con : conList){
                 con.PreviousContract__c = objContract.Id;
             }
             Database.Update(conList);
             QL_ContractCustApproved.getProposal(conList[0].Id);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
    }
    static testMethod void validateTestDataAppRegLegal() {
         List<Account> accList = new List<Account>();
         List<Opportunity> oppList = new List<Opportunity>();
         List<Proposal__c> propList = new List<Proposal__c>();
         List<Discount_List__c> discList = new List<Discount_List__c>();
         List<Contract__c> conList = new  List<Contract__c>();
         List<Contract__c> conToupd = new  List<Contract__c>();

         
         // Load Accounts
         accList = QL_TestUtilityData.getAccounts();
         
         // Load Opportunities
         oppList = QL_TestUtilityData.getOpportunities(accList);
         
         // Load Proposals
         propList = QL_TestUtilityData.getProposal(oppList);
         
         //Load Contract
         conList = QL_TestUtilityData.getContracts(propList);
         Test.startTest();               
         //Update Contract
        For (Contract__c c:conList)
                {
                c.Status__c='Approval Required – Legal';   
                conToupd .add(c);             
                }
       try{
             Database.Update(conToupd);
             //Call the Customer Approval method
             QL_ContractCustApproved.getProposal(conList[1].Id);
            
         }catch(Exception e){
             System.debug('Error Occured: '+e.getMessage());
         } 
          Test.stopTest(); 
    }
    }