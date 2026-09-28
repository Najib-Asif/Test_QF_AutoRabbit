/***********************************************************************************************************************************

Description: Test class for the class QAC_AccountRetrieval. 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan       Test class for the apex class QAC_AccountRetrieval           T01
Ajay Bharathan               Included null check logics & Not in salesforce logic         T02

Created Date    : 11/12/17 (DD/MM/YYYY)

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated setup() method.

**********************************************************************************************************************************/
@isTest
public class QAC_AccountRetrieval_Test{
    
    @testSetup
    public static void setup() {
        
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
		TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        Sales_Region__c mySR = new Sales_Region__c();
        mySR.Brand_Code__c = 'AU';
        mySR.sales_h_eq_type__c = 'Industry';
        mySR.sales_h_end_date__c = Date.today().addDays(1);
        mySR.Name = 'Australian Region';
        insert mySR;
        
        //Inserting Account
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557',Agency_Sales_Region__c = mySR.Id);
        
        insert acc;
        
        Account relatedAcc = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1000000');
        
        insert relatedAcc;
        
        Account relatedAcc2 = new Account(Name = 'Sample3', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2000000');
        insert relatedAcc2;

        //Inserting Ticketing Authority
        Account_Relation__c newTA = new Account_Relation__c();
        newTA.Primary_Account__c = acc.Id;
        newTA.Active__c = true;
        newTA.Start_Date__c = system.today();
        newTA.Relationship__c = 'Consolidator/Ticketing Agent Of';
        newTA.Related_Account__c = relatedAcc.Id;
        insert newTA;
        
     /*   Account_Relation__c newTA2 = new Account_Relation__c();
        newTA2.Primary_Account__c = acc.Id;
        newTA2.Active__c = true;
        newTA2.Start_Date__c = system.today();
        newTA2.Relationship__c = 'Export Partner of';
        newTA2.Related_Account__c = relatedAcc2.Id;
        insert newTA2;*/

        String tmcRTID = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();

        //Inserting TMC Info
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = acc.Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        insert Agencyinfo;

        Agency_Info__c Agencyinfo2 = new Agency_Info__c();
        Agencyinfo2.Account__c = acc.Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo2.Active__c=true;
        Agencyinfo2.Email_Id__c='test@test.com';
        Agencyinfo2.Code__c  ='Sabre';
        Agencyinfo2.PCC__c   ='2yMT';
        insert Agencyinfo2;
    }
    
    @isTest
    public static void AccountRetrieval()
    {
        QAC_AccountRetrievalAPI myApi = QAC_AccountRetrievalAPI_Test.testParse();
        QAC_AccountRetrieval_Test.restLogic(myApi,null);
        
        Test.startTest();
        QAC_AccountRetrieval.doAccountRetrieval();
        Test.stopTest();
    }
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            String myExcepJson = '';
            QAC_AccountRetrieval_Test.restLogic(null,myExcepJson);
            
            Test.startTest();
            QAC_AccountRetrieval.doAccountRetrieval();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    
    public static void restLogic(QAC_AccountRetrievalAPI theApi, String theExcepJson){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAccountRetrieval/';  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    }
}