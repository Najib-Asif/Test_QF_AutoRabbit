/**********************************************************************************************************************************

Created Date: 14/02/17

Description: Create and process the invoices based on the Contract Payment functionality. Test method for ContractPaymentHandler.

Versión:
V1.0 - 14/02/17 - Initial version [FO]

**********************************************************************************************************************************/
@isTest
public class ContractPaymentHandlerTest {
    
    @testsetup
    static void createCPTestData() {
        
        // Custom setting creation
        TestUtilityDataClassContractPayment.enableCPTriggers();
        Trigger_Status__c ts = new Trigger_Status__c(Name='ProposalTrigger', Active__c=false);
        insert ts;
    }
    public static testMethod void TestContractPayment() {
        
        List < Account > accList = new List < Account > ();
        List < Opportunity > oppList = new List < Opportunity > ();
        List < Proposal__c > propList = new List < Proposal__c > ();
        List < Contract_Payments__c > cpList = new List < Contract_Payments__c > ();
        List < Contract__c > contList = new List < Contract__c > ();
        // Load Accounts
        accList = TestUtilityDataClassContractPayment.getAccounts();
        System.debug('#####################################################################################');
        // Load Opportunities
        oppList = TestUtilityDataClassContractPayment.getOpportunities(accList);
        System.debug('-----------------------------------------------------------------------------------------');
        // Load Proposals
        propList = TestUtilityDataClassContractPayment.getProposal(oppList);
        System.debug('******************************************************************************************');
        //Load CP
        cpList = TestUtilityDataClassContractPayment.getCP(propList);
        Test.startTest();
        //Update CP
        For(Contract_Payments__c c: cpList) {
            c.Amount__c = 2000;
        }
        
        //Load contract
        contList = TestUtilityDataClassContractPayment.getContract(propList);
        system.debug('accList:'+accList);
        system.debug('oppList:'+oppList);
        system.debug('propList:'+propList);
        system.debug('contList:'+contList);
        system.debug('cpList:'+cpList);
        
        try {
             Database.Update(contList);
			Database.Update(cpList);
			Database.delete(cpList);
           
        } catch (Exception e) {
            
            //System.assert(e.getMessage().contains('Error'), e.getMessage());
            
        }
        Test.stopTest();
    }
    
    public static testMethod void TestContractPaymentSignOn() {
        
        List < Account > accList = new List < Account > ();
        List < Opportunity > oppList = new List < Opportunity > ();
        List < Proposal__c > propList = new List < Proposal__c > ();
        List < Contract_Payments__c > cpList = new List < Contract_Payments__c > ();
        List < Contract_Payments__c > cpListUpd = new List < Contract_Payments__c > ();
        List < Contract__c > contList = new List < Contract__c > ();
        List < Contract__c > contListUp = new List < Contract__c > ();
        // Load Accounts
        accList = TestUtilityDataClassContractPayment.getAccounts();
        
        // Load Opportunities
        oppList = TestUtilityDataClassContractPayment.getOpportunities(accList);
        
        // Load Proposals
        propList = TestUtilityDataClassContractPayment.getProposal(oppList);
        
        //Load CP
        cpList = TestUtilityDataClassContractPayment.getCP(propList);
        Test.startTest();
        //Update CP
        For(Contract_Payments__c c: cpList) {
            c.Type__c = 'Sign-On Bonus';
            cpListUpd.add(c);
        }
        
        //Load contract
        contList = TestUtilityDataClassContractPayment.getContract(propList);
        for (Contract__c cn: contList) {
            cn.Status__c = 'Signed by Customer';
            cn.General__c ='New Deal';
            cn.Domestic_Amendment__c ='Penalties';
            cn.International_Amendment__c='All Discounts';
            cn.Amendments__c='All Discounts';
            //cn.QL_Effective_Tier__c ='Tier 1';
            contListUp.add(cn);
        }
        
        try {
             Database.Update(cpListUpd);
            Database.Update(contListUp);
            
        } catch (Exception e) {
            
            //System.assert(e.getMessage().contains('Error'), e.getMessage());
            
        }
        Test.stopTest();
    }
    
    public static testMethod void TestOneoffPay() {
        
        List < Account > accList = new List < Account > ();
        List < Opportunity > oppList = new List < Opportunity > ();
        List < Proposal__c > propList = new List < Proposal__c > ();
        List < Contract_Payments__c > cpList = new List < Contract_Payments__c > ();
        List < Contract_Payments__c > cpListUpd = new List < Contract_Payments__c > ();
        List < Contract__c > contList = new List < Contract__c > ();
        List < Contract__c > contListUp = new List < Contract__c > ();
        // Load Accounts
        accList = TestUtilityDataClassContractPayment.getAccounts();
        
        // Load Opportunities
        oppList = TestUtilityDataClassContractPayment.getOpportunities(accList);
        
        // Load Proposals
        propList = TestUtilityDataClassContractPayment.getProposal(oppList);
        
        //Load CP
        cpList = TestUtilityDataClassContractPayment.getCP(propList);
        Test.startTest();
        //Update CP
        For(Contract_Payments__c c: cpList) {
            c.Type__c = 'One-Off Payment';
            cpListUpd.add(c);
        }
        
        //Load contract
        contList = TestUtilityDataClassContractPayment.getContract(propList);
        for (Contract__c cn: contList) {
            cn.Status__c = 'Signed by Customer';
            cn.General__c ='New Deal';
            cn.Domestic_Amendment__c ='Penalties';
            cn.International_Amendment__c='All Discounts';
            cn.Amendments__c='All Discounts';
            //  cn.QL_Effective_Tier__c ='Tier 1';
            contListUp.add(cn);
        }
        
        try {
            Database.Update(cpListUpd);
            Database.Update(contListUp);
           
            
        } catch (Exception e) {
            
           // System.assert(e.getMessage().contains('Error'), e.getMessage());
            
        }
        Test.stopTest();
    }
    
    public static testMethod void TestContractTermination() {
        List < Account > accList = new List < Account > ();
        List < Opportunity > oppList = new List < Opportunity > ();
        List < Proposal__c > propList = new List < Proposal__c > ();
        List < Contract_Payments__c > cpList = new List < Contract_Payments__c > ();
        List < Contract_Payments__c > cpListUpd = new List < Contract_Payments__c > ();
        List < Contract__c > contList = new List < Contract__c > ();
        List < Contract__c > contListUp = new List < Contract__c > ();
        // Load Accounts
        accList = TestUtilityDataClassContractPayment.getAccounts();
        
        // Load Opportunities
        oppList = TestUtilityDataClassContractPayment.getOpportunities(accList);
        
        // Load Proposals
        propList = TestUtilityDataClassContractPayment.getProposal(oppList);
        
        //Load CP
        cpList = TestUtilityDataClassContractPayment.getCP(propList);
        Test.startTest();
        
        
        //Load contract
        contList = TestUtilityDataClassContractPayment.getContract(propList);
        for (Contract__c cn: contList) {
            cn.Status__c = 'Signed by Customer';
            cn.Contract_End_Date__c = cn.Contract_End_Date__c.addmonths(1);
            cn.General__c ='New Deal';
            cn.Domestic_Amendment__c ='Penalties';
            cn.International_Amendment__c='All Discounts';
            cn.Amendments__c='All Discounts';
            // cn.QL_Effective_Tier__c ='Tier 1';
            contListUp.add(cn);
        }
        //Update CP
        For(Contract_Payments__c c: cpList) {
            c.Type__c = 'One-Off Payment';
            c.Contract_Agreement__c = contListUp[0].Id;
           
            cpListUpd.add(c);
        }
        try {
            Database.Update(cpListUpd);
             Database.Update(contListUp);
           
        } catch (Exception e) {
            
           // System.assert(e.getMessage().contains('Error'), e.getMessage());
            
        }
        Test.stopTest();
    }
}