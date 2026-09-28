/* 
* Created By : Ajay | TCS | Cloud Developer 
* Purpose : Test the main class 
* Main Class : QAC_AgencySecondaryDetailsUpdate
*/

@IsTest
public class QAC_AgencySecondaryDetailsUpdate_Test {

    public static String[] getURLIATAs(){
        String[] myJson = new String[]{'1000001','10101',''};
        return myJson;
    }    

    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1000001');
        insert acc;
    }
    
    // success scenario
    @isTest
    public static void validIATA()
    {
        //System.debug('API values'+myApi);
        QAC_AgencySecondaryParsing myApi = QAC_AgencySecondaryParsing_Test.testParse();
        QAC_AgencySecondaryDetailsUpdate_Test.restLogic(myApi,null,QAC_AgencySecondaryDetailsUpdate_Test.getURLIATAs()[0]);
        
        Test.startTest();
        QAC_AgencySecondaryDetailsUpdate.doSecondaryUpdate();
        Test.stopTest();
    }
    
    // failure scenario
    @isTest
    public static void invalidIATA()
    {
        //System.debug('API values'+myApi);
        QAC_AgencySecondaryParsing myApi = QAC_AgencySecondaryParsing_Test.testParse();
        QAC_AgencySecondaryDetailsUpdate_Test.restLogic(myApi,null,QAC_AgencySecondaryDetailsUpdate_Test.getURLIATAs()[1]);
        
        Test.startTest();
        QAC_AgencySecondaryDetailsUpdate.doSecondaryUpdate();
        Test.stopTest();
    }
    
    // null scenario
    @isTest
    public static void blankIATA()
    {
        //System.debug('API values'+myApi);
        QAC_AgencySecondaryParsing myApi = QAC_AgencySecondaryParsing_Test.testParse();
        QAC_AgencySecondaryDetailsUpdate_Test.restLogic(myApi,null,QAC_AgencySecondaryDetailsUpdate_Test.getURLIATAs()[2]);
        
        Test.startTest();
        QAC_AgencySecondaryDetailsUpdate.doSecondaryUpdate();
        Test.stopTest();
    }
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            String myExcepJson = '';
            QAC_AgencySecondaryDetailsUpdate_Test.restLogic(null,myExcepJson,QAC_AgencySecondaryDetailsUpdate_Test.getURLIATAs()[0]);
            
            Test.startTest();
            QAC_AgencySecondaryDetailsUpdate.doSecondaryUpdate();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
        
    }
    
    public static void restLogic(QAC_AgencySecondaryParsing theApi, String theExcepJson, String myURL){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAgencySecondaryInfo/'+myURL;  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    }  
}