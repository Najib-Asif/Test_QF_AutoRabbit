/***********************************************************************************************************************************

Description: Apex class for TA Insertion. 

History:
======================================================================================================================
Name                          Description                                               Tag
======================================================================================================================
Yuvaraj MV                  TA record insertion Test Class                                 	T01

Created Date    : 			03/07/18 (DD/MM/YYYY)

TestClass		:			QAC_TAInsertion_Test

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated setup() method. Formatted code
**********************************************************************************************************************************/
@isTest
public class QAC_TAInsertion_Test 
{
@testSetup
    public static void setup() 
    {
        system.debug('inside test setup**');
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        Account acc1 = new Account(Name = 'Sample1', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557');
        
        insert acc1;
        
        Account relatedAcc1 = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565366',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1000000', Qantas_Industry_Centre_ID__c = '1000000');
        
        insert relatedAcc1;
        
        Account acc2 = new Account(Name = 'Sample3', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565367',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364558');
        
        insert acc2;
        
        Account relatedAcc2 = new Account(Name = 'Sample4', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565368',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1000001', Qantas_Industry_Centre_ID__c = '1000001');
        
        insert relatedAcc2;
    }
     public static testMethod void validTaInsertion()
     {
         /**Account agencyAccount1 = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '4364557' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount1);
        Account agencyAccount2 = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount2);**/
         
         list<QAC_TAInforWrapper> requestBody = new list<QAC_TAInforWrapper>();
         requestBody.add(new QAC_TAInforWrapper('1000000',''));
         RestRequest req = new RestRequest();
         RestResponse res =  new RestResponse();
         req.requestURI = '/services/apexrest/QACTAInformationInsertion/'+'4364557';
         
         req.requestBody=Blob.valueOf(JSON.serializePretty(requestBody));
         req.httpMethod = 'POST';
         
         RestContext.request = req;
         RestContext.response = res;
         
         Test.startTest();
         QAC_TAInsertion.doTAInsertion();
         Test.stopTest();
     }
    
    public static testMethod void duplicateTaInsertion()
    {
        Account agencyAccount3 = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '4364557' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount3);
        Account agencyAccount4 = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount4);
        
        Account_Relation__c newTa= new Account_Relation__c();
        newTa.Primary_Account__c= agencyAccount3.Id;
        newTa.Related_Account__c= agencyAccount4.Id;
        newTa.Relationship__c = 'Travel Manager Of';
        insert newTa;
        
        list<QAC_TAInforWrapper> requestBody = new list<QAC_TAInforWrapper>();
        requestBody.add(new QAC_TAInforWrapper(agencyAccount4.IATA_Number__c,''));
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        req.requestURI = '/services/apexrest/QACTAInformationInsertion/'+agencyAccount3.IATA_Number__c;
        
        req.requestBody=Blob.valueOf(JSON.serializePretty(requestBody));
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        QAC_TAInsertion.doTAInsertion();
        Test.stopTest();
    }
    
    public static testMethod void forNullPrimaryIATATaInsertion()
    {
        /**Account agencyAccount6 = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount6);**/
        
        list<QAC_TAInforWrapper> requestBody = new list<QAC_TAInforWrapper>();
        requestBody.add(new QAC_TAInforWrapper('1000000',''));
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        req.requestURI = '/services/apexrest/QACTAInformationInsertion';
        
        //req.requestBody=Blob.valueOf(JSON.serializePretty(requestBody));
        req.requestBody=Blob.valueOf(JSON.serializePretty(''));
        req.httpMethod = 'POST';
        
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        QAC_TAInsertion.doTAInsertion();
        Test.stopTest();
    }
    
    public static testMethod void forInvalidPrimaryIATATaInsertion()
    {
        //Account agencyAccount6=new Account();
        //Account agencyAccount7 = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        //system.debug(' @@ agencyAccount @@ ' + agencyAccount7);
        
        list<QAC_TAInforWrapper> requestBody = new list<QAC_TAInforWrapper>();
        requestBody.add(new QAC_TAInforWrapper('10000',''));
        //String myExcepJson = '';
        //QAC_TAInsertion_Test.restLogic(requestBody[0],myExcepJson,'9999999');
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        //req.requestURI = '/services/apexrest/QACTAInformationInsertion/'+agencyAccount6.Id;
        req.requestURI = '/services/apexrest/QACTAInformationInsertion/9999999';
        req.requestBody=Blob.valueOf(JSON.serializePretty(requestBody));
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        QAC_TAInsertion.doTAInsertion();
        Test.stopTest();
    }
    
    public static testMethod void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            String myExcepJson = '';
	        QAC_TAInsertion_Test.restLogic(null,myExcepJson,'9999999');
            
            Test.startTest();
            QAC_TAInsertion.doTAInsertion();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    
    public static void restLogic(QAC_TAInforWrapper theApi, String theExcepJson, String myURL){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTAInformationInsertion/'+myURL;  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    }  
}