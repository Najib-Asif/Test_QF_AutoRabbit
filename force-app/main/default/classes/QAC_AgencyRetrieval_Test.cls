/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to validate PNR using Agency Retrieval and its child records
* REST API : QAC_AgencyRetrievalAPI
* Main Class : QAC_AgencyRetrieval

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated setup() method.
*/
@isTest
public class QAC_AgencyRetrieval_Test{
    
    public static String[] getJSONStrings()
    {
        String[] myJson = new String[]{};
            
        String nullJson = '{  '+
            '    \"agencyRetrieval\":'+
            '    {'+
            '       \"bookingIATA\" : \"3000003\",'+
            '       \"pcc\" : \"xyz56\"'+
            '    }'+
            '}';     

        String nullAcctJson = '{  '+
            '    \"agencyRetrieval\":'+
            '    {'+
            '       \"loginIATA\" : \"1000000\",'+
            '       \"bookingIATA\" : \"3000003\",'+
            '       \"pcc\" : \"xyz56\"'+
            '    }'+
            '}';     

        String sameIATAJson = '{  '+
            '    \"agencyRetrieval\":'+
            '    {'+
            '       \"loginIATA\" : \"1010101\",'+
            '       \"bookingIATA\" : \"1010101\",'+
            '       \"pcc\" : \"xyz56\"'+
            '    }'+
            '}';
        
        String pccJson = '{  '+
            '    \"agencyRetrieval\":'+
            '    {'+
            '       \"loginIATA\" : \"1010101\",'+
            '       \"bookingIATA\" : \"3000003\",'+
            '       \"pcc\" : \"AS2P\"'+
            '    }'+
            '}';         
        
        myJson.add(nullJson);    //0th
        myJson.add(nullAcctJson);   //1st
        myJson.add(sameIATAJson);   //2nd
        myJson.add(pccJson);    //3rd

        return myJson;
    }    
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String tmcRTID = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;

        /*        
        Sales_Region__c mySR = new Sales_Region__c();
        mySR.Brand_Code__c = 'AU';
        mySR.sales_h_eq_type__c = 'Industry';
        mySR.sales_h_end_date__c = Date.today().addDays(1);
        mySR.Name = 'Australian Region';
        insert mySR;
        */
        
        //Inserting Account
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1010101');
        
        insert acc;
        
        Account relatedAcc = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '3000003');
        
        insert relatedAcc;
        
        Account relatedAcc2 = new Account(Name = 'Sample3', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2000002');
        insert relatedAcc2;

        //Inserting Ticketing Authority
        Account_Relation__c newTA = new Account_Relation__c();
        newTA.Primary_Account__c = acc.Id;
        newTA.Active__c = true;
        newTA.Start_Date__c = system.today();
        newTA.Relationship__c = 'Travel Manager Of';
        newTA.Related_Account__c = relatedAcc.Id;
        insert newTA;
        
        Account_Relation__c newTA2 = new Account_Relation__c();
        newTA2.Primary_Account__c = acc.Id;
        newTA2.Active__c = true;
        newTA2.Start_Date__c = system.today();
        newTA2.Relationship__c = 'Travel Manager Of';
        newTA2.Related_Account__c = relatedAcc2.Id;
        insert newTA2;

        //Inserting TMC Info
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = acc.Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        insert Agencyinfo;

        Agency_Info__c Agencyinfo2 = new Agency_Info__c();
        Agencyinfo2.Account__c = acc.Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo2.Active__c=true;
        Agencyinfo2.Email_Id__c='test@test.com';
        Agencyinfo2.Code__c ='Sabre';
        Agencyinfo2.PCC__c   ='2yMT';
        insert Agencyinfo2;
    }
    
    @isTest
    public static void AgRetrieval()
    {
        QAC_AgencyRetrievalAPI myApi = QAC_AgencyRetrievalAPI_Test.testParse();
        QAC_AgencyRetrieval_Test.restLogic(myApi,null);
        
        runTest();
    }
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            String myExcepJson = '';
            QAC_AgencyRetrieval_Test.restLogic(null,myExcepJson);
            runTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    
    @isTest
    public static void testwithNULLJSON()
    {
        String nullJson = QAC_AgencyRetrieval_Test.getJSONStrings()[0];
        QAC_AgencyRetrievalAPI myApi = QAC_AgencyRetrievalAPI.parse(nullJson);
        QAC_AgencyRetrieval_Test.restLogic(myApi,null);
        runTest();
    }    

    @isTest
    public static void testwithNULLAcctJSON()
    {
        String nullAcctJson = QAC_AgencyRetrieval_Test.getJSONStrings()[1];
        QAC_AgencyRetrievalAPI myApi = QAC_AgencyRetrievalAPI.parse(nullAcctJson);
        QAC_AgencyRetrieval_Test.restLogic(myApi,null);
        runTest();
    }
    
    @isTest
    public static void testwithSameIATAJSON()
    {
        String sameIATAJson = QAC_AgencyRetrieval_Test.getJSONStrings()[2];
        QAC_AgencyRetrievalAPI myApi = QAC_AgencyRetrievalAPI.parse(sameIATAJson);
        QAC_AgencyRetrieval_Test.restLogic(myApi,null);
        runTest();
    }
    
    @isTest
    public static void testwithpccJSON()
    {
        String pccJson = QAC_AgencyRetrieval_Test.getJSONStrings()[3];
        QAC_AgencyRetrievalAPI myApi = QAC_AgencyRetrievalAPI.parse(pccJson);
        QAC_AgencyRetrieval_Test.restLogic(myApi,null);
        runTest();
    }        
        
    public static void restLogic(QAC_AgencyRetrievalAPI theApi, String theExcepJson){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAgencyRetrieval/';  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    public static void runTest(){
        Test.startTest();
        QAC_AgencyRetrieval.doRetrieval();
        Test.stopTest();
    }
}