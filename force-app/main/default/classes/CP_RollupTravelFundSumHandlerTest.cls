@isTest
private class CP_RollupTravelFundSumHandlerTest { 
    
    @testsetup
    static void createCPTestData(){
        // Custom setting creation
        TestUtilityDataClassContractPayment.enableCPTriggers();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();

    }
    static testMethod void validateCPTestData() {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Discount_List__c> discList = new List<Discount_List__c>();
        List<Contract_Payments__c> cpList = new  List<Contract_Payments__c>();
        
        // Load Accounts
        accList = TestUtilityDataClassContractPayment.getAccounts();
        
        // Load Opportunities
        oppList = TestUtilityDataClassContractPayment.getOpportunities(accList);
        
        // Load Proposals
        propList = TestUtilityDataClassContractPayment.getProposal(oppList);
        
        //Load CP
        List<Id> ids = new List<Id>();
        cpList = TestUtilityDataClassContractPayment.getCP(propList);
        Test.startTest();  
        for (Proposal__c pr : propList){
                 ids.add(pr.id);
        }
        //Update CP
        For (Contract_Payments__c c:cpList )
        {
            c.Amount__c=2000;
           ids.add(c.Id);
        }
        try{
          // Database.Update(cpList);
           CP_RollupTravelFundSumHandler.SumofCPs(cpList);
            Database.delete(cpList);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        Test.stopTest(); 
    }
}