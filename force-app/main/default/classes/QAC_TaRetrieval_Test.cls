/***********************************************************************************************************************************
Description: Test Class for Apex class for retrieving the account Information using IATA Code. 

History:
======================================================================================================================
Name                          Description                                       	Tag
======================================================================================================================
Yuvaraj MV         			Account record retrieval class                     		T01

Created Date    : 			23/06/18 (DD/MM/YYYY)

TestClass		:			QAC_TaRetrieval_Test
Main Class Name	: 			QAC_TaRetrieval

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated dataSetup() method.
**********************************************************************************************************************************/
@isTest
public class QAC_TaRetrieval_Test 
{   
    @testsetup
    public static void dataSetup()
    {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        String agencyAcctRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd;
        
        // sales region
        Sales_Region__c salesregion = new Sales_Region__c(Name = 'Test sr1', Hide_TMCTA__c = false, sales_h_eq_type__c = 'Industry');
        insert salesregion;
        
        // Primary Account
        Account agencyAccount1 = new Account(Name = 'Test Account1', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyAcctRtId, Migrated__c = true, ABN_Tax_Reference__c  ='98987566453',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9999999', 
                                             Agency_Sales_Region__c = salesregion.id);
        insert agencyAccount1;
        
        // Related Account
        Account agencyAccount2 = new Account(Name = 'Test Account2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyAcctRtId, Migrated__c = true, ABN_Tax_Reference__c  ='98987588888',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '8888888');
        insert agencyAccount2;
        
        //Inserting TA Record
        Account_Relation__c TaRecord = new Account_Relation__c(Primary_Account__c = agencyAccount1.Id, Related_Account__c = agencyAccount2.Id, Relationship__c ='Travel Manager Of', 
                                                               Active__c = true   );
        
        insert TaRecord;
    }
    
    public static testMethod void validIATA()
    {
        String agencyCode ='9999999';
        
        /**Account_Relation__c acrObj =  [select Id, Active__c, Related_Account_f__c, 
                                related_account__r.Qantas_Industry_Centre_ID__c 
                                from 	Account_Relation__c 
                                where 	primary_account__r.Qantas_Industry_Centre_ID__c = '9999999'];**/
        //Valid IATA
       /**if(acrObj!=null)
       {**/
       	
        QAC_TaRetrieval_Test.requestMethod(agencyCode);
        Test.startTest();
        QAC_TaRetrieval.doTARetrieval();
        Test.stopTest();
       /**}**/
    }
    
    public static testMethod void emptyIATA()
     {
        //IATA is empty
        string agencyCode1='';
       QAC_TaRetrieval_Test.requestMethod(agencyCode1);
        Test.startTest();
        QAC_TaRetrieval.doTARetrieval();
        Test.stopTest();
     }
    
    public static testMethod void invalidIATA()
    {
        //IATA doesn't exists
        string agencyCode2='99999';
        QAC_TaRetrieval_Test.requestMethod(agencyCode2);
        Test.startTest();
        QAC_TaRetrieval.doTARetrieval();
        Test.stopTest();
    }
    
    public static testMethod void error401()
    {
        //Unauthorized Request
        String agencyAcctRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Sales_Region__c salesregion1 = new Sales_Region__c(Name = 'Test sr2', Hide_TMCTA__c = true, sales_h_eq_type__c = 'Industry');
         insert salesregion1;
        
        // Primary Account
        Account agencyAccount3 = new Account(Name = 'Test Account1', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyAcctRtId, Migrated__c = true, ABN_Tax_Reference__c  ='98987566453',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9999998', 
                                             Agency_Sales_Region__c = salesregion1.id);
        insert agencyAccount3;
        
        // Related Account
        Account agencyAccount4 = new Account(Name = 'Test Account2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyAcctRtId, Migrated__c = true, ABN_Tax_Reference__c  ='98987588888',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '8888889');
        insert agencyAccount4;
        
        //Inserting TA Record
        Account_Relation__c TaRecord1 = new Account_Relation__c(Primary_Account__c = agencyAccount3.Id, Related_Account__c = agencyAccount4.Id, Relationship__c ='Travel Manager Of', 
                                                               Active__c = true   );
        
        insert TaRecord1;
        
        string agencyCode4='9999998';
        QAC_TaRetrieval_Test.requestMethod(agencyCode4);
        Test.startTest();
        QAC_TaRetrieval.doTARetrieval();
        Test.stopTest();
    }
    
    public static testMethod void Exception()
    {
        try
        {
        /**IATA doesn't exists
        string agencyCode3='99/999';
        //QAC_TaRetrieval_Test.requestMethod(agencyCode2);
        RestRequest req1 = new RestRequest();
        RestResponse res1 =  new RestResponse();
        
        req1.requestURI = '/services/apexrest/QACTAInformationRetrieva/'+agencyCode3;
        req1.httpMethod = 'GET';
        
        
        RestContext.request = req1;
        RestContext.response = res1;**/
        Test.startTest();
        QAC_TaRetrieval.doTARetrieval();
        Test.stopTest();
       }
        catch(Exception ex)
        {
            
        }
    }
    
    public static void requestMethod(String agencyCode)
    {
        system.debug('@@@@insideRequest method');
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTAInformationRetrieval/'+agencyCode;
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
    }
}