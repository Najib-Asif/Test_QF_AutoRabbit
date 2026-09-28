/* 
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Main Class : QAC_ServiceReqCaseCreationProcess
  History
  ************************************************************************************************
  01-Jul-2019      Jay               Agency Credits related Changes.
  ************************************************************************************************
*/
@isTest
public class QAC_ServiceReqCaseCreationProcess_Test {

    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Set<String> waiverTypes = new Set<String>();
        Set<String> waiverSubTypes = new Set<String>();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        
        Trigger_Status__c Account_ClassificationValidation = new Trigger_Status__c();
        Account_ClassificationValidation.Name = 'Account_ClassificationValidation';
        Account_ClassificationValidation.Active__c = true;
        lsttrgStatus.add(Account_ClassificationValidation);
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();

        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',BillingCountry='NZ',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '9797979');
        insert myAccount;

        waiverTypes.add('Name Correction');
        waiverSubTypes.add('Unticketed - Qantas Operated and Marketed');
        waiverSubTypes.add('Ticketed - Qantas Operated and Marketed');
        
        // insert Product
        Product2 NameChangeProd = new Product2(Name = 'Name Correction',ProductCode = 'Name_Corr_NZ',QuantityUnitOfMeasure = 'Ticket',
                                     IsActive = TRUE, RFIC_code__c='AFPT');
        insert NameChangeProd;

        // insert Pricebook
        Pricebook2 customPB1 = new Pricebook2(Name='QAC NZ Online', isActive=true, Description='Pricebook for NZ Agents that Register via Website');
        Pricebook2 customPB2 = new Pricebook2(Name='QAC EU Call', isActive=true, Description='Pricebook for AU Agents that Register via Calls');
        insert customPB1;        
        insert customPB2;        

        // Standard PB ID
        Id StdPricebookId = Test.getStandardPricebookId();
        
        // Insert PriceBookEntry - Std PB entry Mandatory for PB and Product
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = StdPricebookId, Product2Id = NameChangeProd.Id,UnitPrice = 100, IsActive = true);
        insert standardPrice;        
        PricebookEntry customPrice1 = new PricebookEntry(Pricebook2Id = customPB1.Id, Product2Id = NameChangeProd.Id,UnitPrice = 70, Product_Credit_Value__c = 100 ,IsActive = true);
        insert customPrice1;        
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB2.Id, Product2Id = NameChangeProd.Id,UnitPrice = 80, Product_Credit_Value__c = 100 ,IsActive = true);
        insert customPrice2;        
        
        list<QAC_Waiver_Default__mdt> WDmdt = [SELECT MasterLabel,DeveloperName,Approve__c,Condition_Met__c,
                                               Cost_of_Sale__c,Cost_of_Sale_NZD__c,Paid_Service__c,Waiver_Sub_Type__c,Waiver_Type__c
                                               from QAC_Waiver_Default__mdt 
                                               where Waiver_Type__c IN: waiverTypes AND Waiver_Sub_Type__c IN: waiverSubTypes];
        system.debug('WD mdt**'+WDmdt);
        
        list<QAC_Pricebook_Detail__mdt> PBDmdt = [Select MasterLabel,Pricebook_Country_Code__c,DeveloperName,Pricebook_Channel__c
                                                 from QAC_Pricebook_Detail__mdt];
        system.debug('PBD mdt**'+PBDmdt);
    }

    @isTest
    public static void CaseCreation()
    {
        //System.debug('API values'+myApi);
        QAC_ServiceReqCaseCreationAPI myApi = QAC_ServiceReqCaseCreationAPI_Test.testParse();
        QAC_ServiceReqCaseCreationProcess_Test.restLogic(myApi,null);
        
        Test.startTest();
            QAC_ServiceReqCaseCreationProcess.doServReqCaseCreation();
        Test.stopTest();
    } 
    
    @isTest
    public static void CaseCreationQDP()
    {
        //System.debug('API values'+myApi);
        QAC_ServiceReqCaseCreationAPI myApi = QAC_ServiceReqCaseCreationAPI_Test.testParse();
        myApi.serviceRequest.requestOrigin = 'QDP';
        myApi.serviceRequest.bookingDetails = null;
        myApi.serviceRequest.fareDetails = null;
        myApi.serviceRequest.flights = null;
        myApi.serviceRequest.passengers = null;
        myApi.serviceRequest.comments = null;
        QAC_ServiceReqCaseCreationProcess_Test.restLogic(myApi,null);
        Test.startTest();
            QAC_ServiceReqCaseCreationProcess.doServReqCaseCreation();
        Test.stopTest();
    }    
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            String myExcepJson = '';
            QAC_ServiceReqCaseCreationProcess_Test.restLogic(null,myExcepJson);
            
            Test.startTest();
                QAC_ServiceReqCaseCreationProcess.doServReqCaseCreation();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    
    public static void restLogic(QAC_ServiceReqCaseCreationAPI theApi, String theExcepJson){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QAC_ServReqCaseCreation/';  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    }  
}