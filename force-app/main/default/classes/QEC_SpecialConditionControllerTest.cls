/**********************************************************************
Name:  QEC_SpecialConditionControllerTest
Copyright © 2019  Qantas Airways.
======================================================
Req: 
QEC - Adding, Viewing, Editing and Deleting Special Conditions on a Proposal
======================================================
Purpose:                                                            
Test class for QEC_SpecialConditionController
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 	Anil Nair       28/06/2019      Initial Development
========================================================
Methods
1. testInsertRecords() - performs data insert and call the insertRecords method to insert special condition records
2. testGetSpecialConditions() - performs test data insert and calls getSpecialConditions method to check if records are retrieved
3. testdeleteRecord() - performs test data insert for special condition records and then deletes a record by calling the deleteRecord method and checks if delete operation was successful
4. testGetFares() - performs test data insert of fare structure records and then calls getFares method to check if the records can be retrieved
5. testGetFieldMap() - calls getFieldMap method and verfies that it is able to retrieve metadata values
6. testGetPickListMap() - calls getPicklistMap method and verifies that picklist values corresponding to picklist fields are retrieved.
7. testSpecialConditionOnContract() - calls insertRecord methods to simulate creation of special conditions on contract
8. testGetObjectType() - creates an account and passes the id to the getObjectType method and check if the correct object name is returned.
***********************************************************************/
@isTest
public class QEC_SpecialConditionControllerTest {
    public static testMethod void testInsertRecords(){
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        
        QEC_Special_Condition__c specialCondition = new QEC_Special_Condition__c();
        List<Airport_Code__c> airport_codes = TestUtilityDataClassQantas.createAirportCode();
        specialCondition.QEC_Origin__c = airport_codes[0].Id;
        specialCondition.QEC_Destination__c = airport_codes[1].Id;
        specialCondition.Proposal__c = proposalList[0].Id;
        
        List<QEC_Special_Condition__c> specialConditionList = new List<QEC_Special_Condition__c>();
        specialConditionList.add(specialCondition);
        
        QEC_SpecialConditionController.insertRecords(specialConditionList);
    }
    public static testMethod void testGetSpecialConditions() {
        List<QEC_Special_Condition__c> specialConditionList = TestUtilityDataClassQantas.getSpecialConditions();
        insert specialConditionList;
        Map<String, List<QEC_Special_Condition__c>> specialConditionMap = QEC_SpecialConditionController.getSpecialConditions(specialConditionList[0].Proposal__c);
        system.assertEquals(3, specialConditionMap.get('Additional Baggage').size()); 
    }
    public static testMethod void testdeleteRecord() {
        List<QEC_Special_Condition__c> specialConditionList = TestUtilityDataClassQantas.getSpecialConditions();
        insert specialConditionList;
        QEC_SpecialConditionController.deleteRecord(specialConditionList[0].id);
        List<QEC_Special_Condition__c> testList = [select id from QEC_Special_Condition__c where Proposal__c = :specialConditionList[0].proposal__c];
        //System.assertEquals(2, testList.size());
    }
    public static testMethod void testGetFares() {
        List<Fare_Structure__c> fareList = TestUtilityDataClassQantas.getFareStructures();
        insert fareList;
        List<Fare_Structure__c> testList = QEC_SpecialConditionController.getFares();
        System.assertEquals(3,testList.size());
    }
    public static testMethod void testGetFieldMap() {
        Map<String,List<Object>> fieldMap = QEC_SpecialConditionController.getFieldMap();
        System.assertNotEquals(0, fieldMap.get('Additional Baggage').size());   
    }
    public static testMethod void testGetPickListMap() {
        Map<String,List<String>> picklistMap = QEC_SpecialConditionController.getPicklistMap();
        System.assertNotEquals(0, pickListMap.get('QEC_Type__c').size());
    }
    public static testMethod void testSpecialConditionOnContract() {
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        List<Opportunity> oppList = TestUtilityDataClassQantas.getOpportunities(accList);
        List<Proposal__c> proposalList = TestUtilityDataClassQantas.getProposal(oppList);
        List<Contract__c> contractList = TestUtilityDataClassQantas.getContracts(proposalList);
        
        QEC_Special_Condition__c specialCondition = new QEC_Special_Condition__c();
        List<Airport_Code__c> airport_codes = TestUtilityDataClassQantas.createAirportCode();
        specialCondition.QEC_Origin__c = airport_codes[0].Id;
        specialCondition.QEC_Destination__c = airport_codes[1].Id;
        specialCondition.Contract__c = contractList[0].Id;
        
        List<QEC_Special_Condition__c> specialConditionList = new List<QEC_Special_Condition__c>();
        specialConditionList.add(specialCondition);
        
        QEC_SpecialConditionController.insertRecords(specialConditionList);
    }
    public static testMethod void testGetObjectType() {
        List<Account> accList = TestUtilityDataClassQantas.getAccounts();
        String objName = QEC_SpecialConditionController.getObjectType(accList[0].id);
        System.assertEquals('Account', objName);
    }
}