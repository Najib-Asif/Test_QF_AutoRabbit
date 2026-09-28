@isTest
private class ContractAgrCountHandlerTest{ 
    
    @testsetup
    static void createConAgrTestData(){
        
        Trigger_Status__c contrigger= new Trigger_Status__c();
        contrigger.Name = 'ConAgrCount';
        contrigger.Active__c = true;
        insert contrigger;
    }
    static testMethod void CountNumofContractAgr() {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Proposal__c> propList = new List<Proposal__c>();
        List<Discount_List__c> discList = new List<Discount_List__c>();
        List<Contract__c> caList = new  List<Contract__c>();
        
        
        // Load Accounts
        accList = TestUtilityDataClassQantas.getAccounts();
        
        // Load Opportunities
        oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        
        // Load Proposals
        propList = TestUtilityDataClassQantas.getProposal(oppList);
        
        //Load CP
        caList = TestUtilityDataClassQantas.getContracts(propList);
        Test.startTest();               
        //Update CP
        For (Contract__c c:caList )
        {
            c.Qantas_Annual_Expenditure__c=800000;                
        }
        try{
            Database.Update(caList );
            Database.delete(caList );
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        Test.stopTest(); 
    }
}