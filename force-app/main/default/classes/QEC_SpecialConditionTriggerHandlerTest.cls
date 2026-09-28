/**********************************************************************
Name        :   QEC_SpecialConditionTriggerHandlerTest
Trigger     :   QEC_SpecialConditionTrigger
Handler     :   QEC_SpecialConditionTriggerHandler
Copyright © 2019  Qantas Airways.
======================================================
Req: 
QEC - TestClass for QEC_SpecialConditionTriggerHandler
======================================================
Purpose:                                                            
100% code coverage
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR                 DATE              DETAIL
1.0     Yuvaraj                 14/08/2019      Initial Development   
2.0     Pushkar Purushothaman   07/09/2019      Changes incorporated to associate special conditions to contracts
========================================================
Methods
1. testInsertRecords() - Test method to cover Trigger Insert
2. testUpdateRecords() - Test method to cover Trigger Update
3. testDeleteRecords() - Test method to cover Trigger Delete
***********************************************************************/
@isTest
public class QEC_SpecialConditionTriggerHandlerTest 
{
    public static testMethod void testInsertRecords()
    {
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        List<Contract__c> contractList = TestUtilityDataClassQantas.getContracts(proposalList);
        
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'SpecialConditionsTrigger';
        ts.Active__c = true;
        insert ts;
        
        EnableValidationRule__c scvalidation = new EnableValidationRule__c();
        scvalidation.VR_Mandatory_Network_filed__c = true;
        insert scvalidation;
        
        QEC_Special_Condition__c specialCondition = new QEC_Special_Condition__c();
        List<Airport_Code__c> airport_codes = TestUtilityDataClassQantas.createAirportCode();
        specialCondition.QEC_Origin__c = airport_codes[0].Id;
        specialCondition.QEC_Destination__c = airport_codes[1].Id;
        specialCondition.Proposal__c = proposalList[0].Id;
        specialCondition.QEC_Type__c = 'Additional Baggage';
        
        QEC_Special_Condition__c specialCondition1 = new QEC_Special_Condition__c();
        specialCondition1.QEC_Origin__c = airport_codes[0].Id;
        specialCondition1.QEC_Destination__c = airport_codes[1].Id;
        specialCondition1.Proposal__c = proposalList[0].Id;
        specialCondition1.Contract__c = contractList[0].Id;
        specialCondition1.QEC_Type__c = 'Incentive Fare';
        
        QEC_Special_Condition__c specialCondition2 = new QEC_Special_Condition__c();
        specialCondition2.QEC_Origin__c = airport_codes[0].Id;
        specialCondition2.QEC_Destination__c = airport_codes[1].Id;
        specialCondition2.Proposal__c = proposalList[0].Id;
        specialCondition2.QEC_Type__c = 'Advance Res/Ticketing';
        
        QEC_Special_Condition__c specialCondition3 = new QEC_Special_Condition__c();
        specialCondition3.QEC_Origin__c = airport_codes[0].Id;
        specialCondition3.QEC_Destination__c = airport_codes[1].Id;
        specialCondition3.Proposal__c = proposalList[0].Id;
        specialCondition3.QEC_Type__c = 'Penalties';
        
        QEC_Special_Condition__c specialCondition4 = new QEC_Special_Condition__c();
        specialCondition4.QEC_Origin__c = airport_codes[0].Id;
        specialCondition4.QEC_Destination__c = airport_codes[1].Id;
        specialCondition4.Proposal__c = proposalList[0].Id;
        specialCondition4.QEC_Type__c = 'Fixed Fare';
        
        QEC_Special_Condition__c specialCondition5 = new QEC_Special_Condition__c();
        specialCondition5.QEC_Origin__c = airport_codes[0].Id;
        specialCondition5.QEC_Destination__c = airport_codes[1].Id;
        specialCondition5.Proposal__c = proposalList[0].Id;
        specialCondition5.QEC_Type__c = 'Block Fare';
        
        QEC_Special_Condition__c specialCondition6 = new QEC_Special_Condition__c();
        specialCondition6.QEC_Origin__c = airport_codes[0].Id;
        specialCondition6.QEC_Destination__c = airport_codes[1].Id;
        specialCondition6.Proposal__c = proposalList[0].Id;
        specialCondition6.QEC_Type__c = 'Incentive Fare';
        
        QEC_Special_Condition__c specialCondition7 = new QEC_Special_Condition__c();
        specialCondition7.QEC_Origin__c = airport_codes[0].Id;
        specialCondition7.QEC_Destination__c = airport_codes[1].Id;
        specialCondition7.Proposal__c = proposalList[0].Id;
        specialCondition7.QEC_Type__c = 'Route Deal';
        
        QEC_Special_Condition__c specialCondition8 = new QEC_Special_Condition__c();
        specialCondition8.QEC_Origin__c = airport_codes[0].Id;
        specialCondition8.QEC_Destination__c = airport_codes[1].Id;
        specialCondition8.Proposal__c = proposalList[0].Id;
        specialCondition8.QEC_Type__c = 'Incentive Fare';
        
        QEC_Special_Condition__c specialCondition9 = new QEC_Special_Condition__c();
        specialCondition9.QEC_Origin__c = airport_codes[0].Id;
        specialCondition9.QEC_Destination__c = airport_codes[1].Id;
        specialCondition9.Proposal__c = proposalList[0].Id;
        specialCondition9.QEC_Type__c = 'JQ Inclusion';
        specialCondition9.QEC_History__c = false;
        
        List<QEC_Special_Condition__c> specialConditionList = new List<QEC_Special_Condition__c>();
        specialConditionList.add(specialCondition);
        specialConditionList.add(specialCondition1);
        specialConditionList.add(specialCondition2);
        specialConditionList.add(specialCondition3);
        specialConditionList.add(specialCondition4);
        specialConditionList.add(specialCondition5);
        specialConditionList.add(specialCondition6);
        specialConditionList.add(specialCondition7);
        specialConditionList.add(specialCondition8);
        specialConditionList.add(specialCondition9);
       
        List<id> ids = new List<id>();
        for (Proposal__c prop : proposalList){
            ids.add(prop.id);
            break;
        }
        Test.startTest();
				//	 ProposalApprovalCheck.getProposalId(ids);
        insert specialConditionList;
        Test.stopTest();
    }
    
    public static testmethod void testUpdateRecords()
    {
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'SpecialConditionsTrigger';
        ts.Active__c = true;
        insert ts;
        
        EnableValidationRule__c scvalidation = new EnableValidationRule__c();
        scvalidation.VR_Mandatory_Network_filed__c = true;
        insert scvalidation;
        
        List<Airport_Code__c> airport_codes = TestUtilityDataClassQantas.createAirportCode();
        
        QEC_Special_Condition__c specialCondition1 = new QEC_Special_Condition__c();
        specialCondition1.QEC_Origin__c = airport_codes[0].Id;
        specialCondition1.QEC_Destination__c = airport_codes[1].Id;
        specialCondition1.Proposal__c = proposalList[1].Id;
        specialCondition1.QEC_Type__c = 'Incentive Fare';
        
        List<QEC_Special_Condition__c> specialConditionList = new List<QEC_Special_Condition__c>();
        specialConditionList.add(specialCondition1);
        insert specialConditionList;
        
        List<Airport_Code__c> codeList = new List<Airport_Code__c>();
        Airport_Code__c dest = new Airport_Code__c();
        dest.Name = 'QYD';
        Airport_Code__c dest1 = new Airport_Code__c();
        dest.Name = 'DOMESTIC';
        codeList.add(dest);
        codeList.add(dest1);
        insert codeList;
        
        List<QEC_Special_Condition__c> specialConditionList1 = new List<QEC_Special_Condition__c>();        
        specialCondition1.QEC_Destination__c = codeList[1].Id;
        specialConditionList1.add(specialCondition1);
        Test.startTest();
        update specialConditionList1;
        Test.stopTest();
    }
    
    public static testMethod void testDeleteRecords()
    {
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        
        Trigger_Status__c ts = new Trigger_Status__c();
        ts.Name = 'SpecialConditionsTrigger';
        ts.Active__c = true;
        insert ts;
        
        EnableValidationRule__c scvalidation = new EnableValidationRule__c();
        scvalidation.VR_Mandatory_Network_filed__c = true;
        insert scvalidation;
        
        QEC_Special_Condition__c specialCondition = new QEC_Special_Condition__c();
        List<Airport_Code__c> airport_codes = TestUtilityDataClassQantas.createAirportCode();
        specialCondition.QEC_Origin__c = airport_codes[0].Id;
        specialCondition.QEC_Destination__c = airport_codes[1].Id;
        specialCondition.Proposal__c = proposalList[0].Id;
        specialCondition.QEC_Type__c = 'Additional Baggage';
        
        QEC_Special_Condition__c specialCondition1 = new QEC_Special_Condition__c();
        specialCondition1.QEC_Origin__c = airport_codes[0].Id;
        specialCondition1.QEC_Destination__c = airport_codes[1].Id;
        specialCondition1.Proposal__c = proposalList[0].Id;
        specialCondition1.QEC_Type__c = 'Incentive Fare';
        
        QEC_Special_Condition__c specialCondition2 = new QEC_Special_Condition__c();
        specialCondition2.QEC_Origin__c = airport_codes[0].Id;
        specialCondition2.QEC_Destination__c = airport_codes[1].Id;
        specialCondition2.Proposal__c = proposalList[0].Id;
        specialCondition2.QEC_Type__c = 'Advance Res/Ticketing';
        
        QEC_Special_Condition__c specialCondition3 = new QEC_Special_Condition__c();
        specialCondition3.QEC_Origin__c = airport_codes[0].Id;
        specialCondition3.QEC_Destination__c = airport_codes[1].Id;
        specialCondition3.Proposal__c = proposalList[0].Id;
        specialCondition3.QEC_Type__c = 'Penalties';
        
        QEC_Special_Condition__c specialCondition4 = new QEC_Special_Condition__c();
        specialCondition4.QEC_Origin__c = airport_codes[0].Id;
        specialCondition4.QEC_Destination__c = airport_codes[1].Id;
        specialCondition4.Proposal__c = proposalList[0].Id;
        specialCondition4.QEC_Type__c = 'Fixed Fare';
        
        QEC_Special_Condition__c specialCondition5 = new QEC_Special_Condition__c();
        specialCondition5.QEC_Origin__c = airport_codes[0].Id;
        specialCondition5.QEC_Destination__c = airport_codes[1].Id;
        specialCondition5.Proposal__c = proposalList[0].Id;
        specialCondition5.QEC_Type__c = 'Block Fare';
        
        QEC_Special_Condition__c specialCondition6 = new QEC_Special_Condition__c();
        specialCondition6.QEC_Origin__c = airport_codes[0].Id;
        specialCondition6.QEC_Destination__c = airport_codes[1].Id;
        specialCondition6.Proposal__c = proposalList[0].Id;
        specialCondition6.QEC_Type__c = 'Incentive Fare';
        
        QEC_Special_Condition__c specialCondition7 = new QEC_Special_Condition__c();
        specialCondition7.QEC_Origin__c = airport_codes[0].Id;
        specialCondition7.QEC_Destination__c = airport_codes[1].Id;
        specialCondition7.Proposal__c = proposalList[0].Id;
        specialCondition7.QEC_Type__c = 'Route Deal';
        
        QEC_Special_Condition__c specialCondition8 = new QEC_Special_Condition__c();
        specialCondition8.QEC_Origin__c = airport_codes[0].Id;
        specialCondition8.QEC_Destination__c = airport_codes[1].Id;
        specialCondition8.Proposal__c = proposalList[0].Id;
        specialCondition8.QEC_Type__c = 'Incentive Fare';
        
        List<QEC_Special_Condition__c> specialConditionList = new List<QEC_Special_Condition__c>();
        specialConditionList.add(specialCondition);
        specialConditionList.add(specialCondition1);
        specialConditionList.add(specialCondition2);
        specialConditionList.add(specialCondition3);
        specialConditionList.add(specialCondition4);
        specialConditionList.add(specialCondition5);
        specialConditionList.add(specialCondition6);
        specialConditionList.add(specialCondition7);
        specialConditionList.add(specialCondition8);
        insert specialConditionList;
        
        Test.startTest();
        delete specialCondition;
        delete specialCondition1;
        delete specialCondition2;
        delete specialCondition3;
        delete specialCondition4;
        delete specialCondition5;
        delete specialCondition6;
        delete specialCondition7;
        delete specialCondition8;
        Test.stopTest();
    }
}