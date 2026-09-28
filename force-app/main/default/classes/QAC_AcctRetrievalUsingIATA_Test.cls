/*
Purpose : used by My Agency Profile for retrieving the account primary and secondary Information using IATA Code. 
Developed By : 
Yuvraj MV :     Account record retrieval class
Ajay :          Edited Class based on Channel changes
Main Class :    QAC_AcctRetrievalUsingIATA

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated dataSetup() method.
*/
@isTest
public class QAC_AcctRetrievalUsingIATA_Test 
{
    
    @testsetup
    public static void dataSetup()
    {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        String agencyAcctRtId   = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd;
        
        Sales_Region__c mySR = new Sales_Region__c();
        mySR.Brand_Code__c = 'AU';
        mySR.sales_h_eq_type__c = 'Industry';
        mySR.sales_h_end_date__c = Date.today().addDays(1);
        mySR.Name = 'Australian Region';
        insert mySR;
        
        Account agencyAccount1  = new Account(Name = 'Test Account111', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                              RecordTypeId = agencyAcctRtId, Migrated__c = true, ABN_Tax_Reference__c  ='98987566453',
                                              Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9999999',Phone_Country_Code__c = '+61',
                                              Phone_Area__c = '02', Phone_Number__c = '469017222', Agency_Sales_Region__c = mySR.Id, BillingCountry = 'AU');
        insert agencyAccount1;
        
        String tmcRTID = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();

        //Inserting TMC Info
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = agencyAccount1.Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        insert Agencyinfo;

        Agency_Info__c Agencyinfo2 = new Agency_Info__c();
        Agencyinfo2.Account__c = agencyAccount1.Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo2.Active__c=true;
        Agencyinfo2.Email_Id__c='test@test.com';
        Agencyinfo2.Code__c  ='Sabre';
        Agencyinfo2.PCC__c   ='2yMT';
        insert Agencyinfo2;
        
    }
    
    public static testMethod void validIATA()
    {
        //IATA is Valid
        QAC_AcctRetrievalUsingIATA_Test.requestMethod('9999999',null);
        Test.startTest();
        QAC_AcctRetrievalUsingIATA.doAcctRetrieval();
        Test.stopTest();
    }
    
    /* Valid IATA with Channel Filter */
    public static testMethod void validIATAwFilter()
    {
        //IATA is Valid
        //?filter=pccSummary
        QAC_AcctRetrievalUsingIATA_Test.requestMethod('9999999','pccSummary');
        Test.startTest();
        QAC_AcctRetrievalUsingIATA.doAcctRetrieval();
        Test.stopTest();
    }


    public static testMethod void emptyIATA()
    {
        //IATA is empty
        QAC_AcctRetrievalUsingIATA_Test.requestMethod('',null);
        Test.startTest();
        QAC_AcctRetrievalUsingIATA.doAcctRetrieval();
        Test.stopTest();
    }
    
    public static testMethod void invalidIATA()
    {
        //IATA doesn't exists
        QAC_AcctRetrievalUsingIATA_Test.requestMethod('99999',null);
        Test.startTest();
        QAC_AcctRetrievalUsingIATA.doAcctRetrieval();
        Test.stopTest();
    }
    
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            
            Test.startTest();
            QAC_AcctRetrievalUsingIATA.doAcctRetrieval();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    
    public static void requestMethod(String agencyCode, String myFilter)
    {
        system.debug('@@@@insideRequest method');
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAcctInformationRetrieval/'+agencyCode;
        req.addParameter('filter', myFilter);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
    }
}