/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QL_AccountAgencyFaresCloneTest {
    @testSetup 
    static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest
    static void accountAgencyFaresCloneTest()
    {
        Id agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId(); 
        Id tmcRecordTypeId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId(); 
        Account agent = new Account(Name = 'Sample', Active__c = true, Type = 'Agency Account', 
                                      RecordTypeId = agencyRecordTypeId, Industry = 'Travel');
        Database.Insert(agent);
        Agency_Info__c tmc1 = new Agency_Info__c (Account__c = agent.Id ,PCC__c='ABCD', Code__c = 'Sabre', Agency_Product_Fares__c='Fly Cruise',RecordTypeId = tmcRecordTypeId);
        Database.Insert(tmc1);
        List<Id> idToUpdate = new List<Id>();
        idToUpdate.add(agent.Id);
        Test.startTest();
        QL_AccountAgencyFaresClone.ProductFareAccountUpdate (idToUpdate);
        tmc1.Agency_Product_Fares__c='';
        update(tmc1);
        QL_AccountAgencyFaresClone.ProductFareAccountUpdate (idToUpdate);
        Test.stopTest();
        
        //Cover exception
        agent.Name = '===================================================================================================Some string which is longer than 255 characters================================================================================================================';
        idToUpdate.add(agent.Id);
        //update agent;
        QL_AccountAgencyFaresClone.ProductFareAccountUpdate (idToUpdate);
    }
}