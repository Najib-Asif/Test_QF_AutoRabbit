/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated testSetup() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QEC_ContractVariationControllerTest {
    @testSetup 
    static void testSetup()
    {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Account> accountList = AccountContractUpdaterTestUtil.createAccounts();
        List<Opportunity> opportunityList = AccountContractUpdaterTestUtil.createOpportunity(accountList);
        List<Proposal__c> proposalList = AccountContractUpdaterTestUtil.createProposals(opportunityList);
        List<Contract__c> contractList = AccountContractUpdaterTestUtil.createContracts(proposalList, opportunityList);
        List<Airport_Code__c> airportList = TestUtilityDataClassQantas.createAirportCode();
        List<Agency_Info__c> tmcInfoList = TestUtilityDataClassQantas.getTMC();
        List<Contract_Discount_List__c> cdlList = new List<Contract_Discount_List__c>();
        List<QEC_Special_Condition__c> splList = new List<QEC_Special_Condition__c>();
        List<Contract_Payments__c> cpList = new List<Contract_Payments__c>();
        List<QEC_ContractTMCInfo__c> contractTmcList = new List<QEC_ContractTMCInfo__c>();
        
        Trigger_Status__c SpecialCondition = new Trigger_Status__c();
        SpecialCondition.Name = 'SpecialConditionsTrigger';
        SpecialCondition.Active__c = true;
        insert SpecialCondition;
        
        EnableValidationRule__c scvalidation = new EnableValidationRule__c();
        scvalidation.VR_Mandatory_Network_filed__c = true;
        insert scvalidation;
        
        Fare_Structure__c fs = new Fare_Structure__c(Name = 'J', Active__c = true, Cabin__c = 'Business', 
                                                     Category__c = 'Mainline', Market__c = 'Australia', 
                                                     ProductCode__c = 'DOM-0001', Qantas_Published_Airfare__c = 'JBUS',
                                                     Segment__c = 'Domestic'
                                                    );
        insert fs;
        
        Id cpRTId = Schema.SObjectType.Contract_Payments__c.getRecordTypeInfosByDeveloperName().get('Corporate_Contract_Payments').getRecordTypeId();
        
        for(Contract__c cont : contractList){
            Contract_Discount_List__c cdl = new Contract_Discount_List__c();
            cdl.Contract__c = cont.id;
            cdl.Discount__c = 5;
            cdl.FareStructure__c = fs.id;
            cdl.QL_Tier_1_Offering__c = 6;
            cdlList.add(cdl);
            
            QEC_Special_Condition__c spl = new QEC_Special_Condition__c();
            spl.Contract__c = cont.id;
            spl.Proposal__c = proposalList[0].id;
            spl.QEC_Type__c = 'Additional Baggage';
            spl.QEC_Origin__c = airportList[0].id;
            spl.QEC_Destination__c = airportList[1].id;
            splList.add(spl);
            
            QEC_ContractTMCInfo__c tmc = new QEC_ContractTMCInfo__c();
            tmc.Contract__c = cont.id;
            tmc.TMC_Info__c = tmcInfoList[0].id;
            contractTmcList.add(tmc);
            
            Contract_Payments__c cp = new Contract_Payments__c();
            cp.Contract_Agreement__c = cont.Id;
            cp.RecordTypeId = cpRTId;
            cp.Amount__c = 100.50;
            cp.Type__c = 'Performance Bonus';
            cp.Payment_Frequency__c = 'Yearly';
            cp.Payment_Criteria__c = 'Test';
            cpList.add(cp);
            
        }
        
        if(!cdlList.isEmpty())
            insert cdlList;
        
        if(!splList.isEmpty())
            insert splList;
        
        if(!contractTmcList.isEmpty())
            insert contractTmcList;
        
        if(!cpList.isEmpty())
            insert cpList;
        
    }
    
    @isTest
    static void testDiscountVariation(){
        Id testContractId = [SELECT id FROM Contract__c][0].Id;
        QEC_ContractVariationController.variationProposal(testContractId,false);
    }
    
    @isTest
    static void testSplConditionVariation(){
        Id testContractId = [SELECT id FROM Contract__c][0].Id;
        QEC_ContractVariationController.childContractClone(testContractId);
    }
    
    @isTest
    static void testContractRenewal(){
        Id testContractId = [SELECT id FROM Contract__c][0].Id;
        QEC_ContractVariationController.variationProposal(testContractId,true);
    }
}