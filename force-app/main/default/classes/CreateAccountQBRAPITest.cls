/*==================================================================================================================================
Author:         Benazir Amir
Company:        Capgemini
Purpose:        Test Class for CreateAccountQBRAPI Class
Date:           12/12/2017        
History:

==================================================================================================================================
12-Dec-2017    Praveen Sampath               Initial Design
==================================================================================================================================*/

@isTest(SeeAllData = false)
private class CreateAccountQBRAPITest{ 
    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        createTestData
    Description:        Method for Test Data Creation  
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/
    @testSetup
    static void createTestData(){
        
            List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSetting();
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting());
            insert lsttrgStatus;


            List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type', 'Aquire Registration'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('createIntegrationLogAccountQBRAPI','Yes'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Status','Active'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IflyRealTimeSyncGSTRegisteredN','N'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IflyRealTimeSyncGSTRegisteredY','Y'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IflyRealTimeSyncGSTRegisteredU','U'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IflyRealTimeSyncAirlineLevelL3','3'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IflyRealTimeSyncAirlineLevelL2','2'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IflyRealTimeSyncAirlineLevelL1','1'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IflyRealTimeSyncStatusA','Active'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryH','Media, telecommunications, arts and recreation'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryK','Health and social services'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryM','Education and training'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryO','Retail trade'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryJ','Business, real estate and consulting services'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryF','Hospitality, food and beverage'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryP','Travel agencies'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryB','Energy, resources, water and waste disposal'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryE','Architecture, construction and building maintenance'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryC','Manufacturing and machinery'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryD','Wholesale trade'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryG','Transport, postal and storage'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryL','Personal and other services'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryQ','Not Provided'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryN','Government, defence and not for profit'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryA','Agriculture, forestry and fishing'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('IndustryR','Campaign'));
           
            insert lstConfigData;
            Account objAcc = TestUtilityDataClassQantas.createAccount();
            objAcc.ABN_Tax_Reference__c = '99999999999';
            insert objAcc;
            system.assert(objAcc.Id != Null, 'Account is not inserted');
    
    }
    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        CreateAccountQBRProductTest
    Description:        Test Method for Creation of Account/QBR Product
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/
    static TestMethod void CreateAccountQBRProductTest(){
           
         Account objAcc = [select Id from Account Limit 1];
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c     = system.today();
        lstObjProdReg.add(objAcqProdReg);
        insert lstObjProdReg;
        system.assert(lstObjProdReg!=Null,'QBR Product Registration is not Inserted');
        

        Test.startTest();

        
       String reqBody = '{ "Company":{ "abn": "55455559555", "name": "ABAirlineSMETestAccountQBR", "industry": "Manufacture", "entityType": "Other", "gstRegistered": "Y" },"membershipNumber": "19955","status" : "A","membershipStartDate" : "2017-11-23","airlineLevel" : "L1"}';
       reqBody += ' ]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // pass the req and resp objects to the method     
        req.requestURI = '/services/apexrest/StoreQBRRegistration';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        CreateAccountQBRAPI.create();
        system.assert(res.statusCode == 200, 'Post Postive Status Code is not Matching');
        Test.stopTest();


    }


    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        UpdateAccountQBRProductTest
    Description:        Test Method for Update of Account/Create QBR Product
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/
    static TestMethod void UpdateAccountQBRProductTest(){
           
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.ABN_Tax_Reference__c = '55455559555';
        insert objAcc;
        system.assert(objAcc!=Null,'Prospect Account is not Inserted');

        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c     = system.today();
        lstObjProdReg.add(objAcqProdReg);
        insert lstObjProdReg;
        system.assert(lstObjProdReg!=Null,'QBR Product Registration is not Inserted');
        

        Test.startTest();

        
           String reqBody = '{ "Company":{ "abn": "55455559555", "name": "ABAirlineSMETestAccountQBR", "industry": "Manufacture", "entityType": "Other", "gstRegistered": "Y" },"membershipNumber": "19955","status" : "A","membershipStartDate" : "2017-11-23","airlineLevel" : "L1"}';
           reqBody += ' ]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // pass the req and resp objects to the method     
        req.requestURI = '/services/apexrest/StoreQBRRegistration';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        CreateAccountQBRAPI.create();
        Test.stopTest();


    }
/*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        UpdateAccountQBRProductDeactivatedTest
    Description:        Test Method for Update of Account/Create QBR Product
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/
    static TestMethod void UpdateAccountQBRProductDeactivatedTest(){
           
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.ABN_Tax_Reference__c = '55455559555';
        insert objAcc;
        system.assert(objAcc!=Null,'Prospect Account is not Inserted');

        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c     = system.today();
        objAcqProdReg.Stage_Status__c = 'Deactivated';
        lstObjProdReg.add(objAcqProdReg);
        insert lstObjProdReg;
        system.assert(lstObjProdReg!=Null,'QBR Product Registration is not Inserted');
        

        Test.startTest();

        
           String reqBody = '{ "Company":{ "abn": "55455559555", "name": "ABAirlineSMETestAccountQBR", "industry": "Manufacture", "entityType": "Other", "gstRegistered": "Y" },"membershipNumber": "19955","status" : "A","membershipStartDate" : "2017-11-23","airlineLevel" : "L1"}';
           reqBody += ' ]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // pass the req and resp objects to the method     
        req.requestURI = '/services/apexrest/StoreQBRRegistration';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        CreateAccountQBRAPI.create();
        Test.stopTest();


    }

    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        AccountQBRProductExceptionTest
    Description:        Test Method for Exception Handling Scenarios(Multiple ABN)
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/
    static TestMethod void AccountQBRProductExceptionTest(){
        
        List<Account> lstObjAcc = new List<Account>();   
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.ABN_Tax_Reference__c = '55455559555';
        lstObjAcc.add(objAcc);

        Account objProsAcc = TestUtilityDataClassQantas.createAccount();
        objProsAcc.ABN_Tax_Reference__c = '55455559555';
        lstObjAcc.add(objProsAcc);

        insert lstObjAcc;
        system.assert(lstObjAcc!=Null,'Prospect Account is not Inserted');

        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c     = system.today();
        objAcqProdReg.Stage_Status__c = 'Deactivated';
        lstObjProdReg.add(objAcqProdReg);
        insert lstObjProdReg;
        system.assert(lstObjProdReg!=Null,'QBR Product Registration is not Inserted');
        

        Test.startTest();

        
           String reqBody = '{ "Company":{ "abn": "55455559555", "name": "ABAirlineSMETestAccountQBR", "industry": "Manufacture", "entityType": "Other", "gstRegistered": "Y" },"membershipNumber": "19955","status" : "A","membershipStartDate" : "2017-11-23","airlineLevel" : "L1"}';
           reqBody += ' ]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // pass the req and resp objects to the method     
        req.requestURI = '/services/apexrest/StoreQBRRegistration';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        CreateAccountQBRAPI.create();
        Test.stopTest();


    }

    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        AccountQBRProductExceptionTest1
    Description:        Test Method for Exception Handling Scenarios(ABN Validation)
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/
     static TestMethod void AccountQBRProductExceptionTest1(){
           
         Account objAcc = [select Id from Account Limit 1];
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c     = system.today();
        lstObjProdReg.add(objAcqProdReg);
        insert lstObjProdReg;
        system.assert(lstObjProdReg!=Null,'QBR Product Registration is not Inserted');
        

        Test.startTest();

        
       String reqBody = '{ "Company":{ "abn": "abcdefghi", "name": "ABAirlineSMETestAccountQBR", "industry": "Manufacture", "entityType": "Other", "gstRegistered": "Y" },"membershipNumber": "19955","status" : "A","membershipStartDate" : "2017-11-23","airlineLevel" : "L1"}';
       reqBody += ' ]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // pass the req and resp objects to the method     
        req.requestURI = '/services/apexrest/StoreQBRRegistration';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        CreateAccountQBRAPI.create();
        system.assert(res.statusCode == 400, 'Post Negative Status Code is not Matching');
        Test.stopTest();


    }
    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        AccountQBRProductExceptionTest2
    Description:        Test Method for Exception Handling Scenarios(Airline Eligilibiity Related Field Calc)
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/
    static TestMethod void AccountQBRProductExceptionTest2(){
           
         Account objAcc = [select Id from Account Limit 1];
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c     = system.today();
        lstObjProdReg.add(objAcqProdReg);
        insert lstObjProdReg;
        system.assert(lstObjProdReg!=Null,'QBR Product Registration is not Inserted');
        

        Test.startTest();

        
       String reqBody = '{ "Company":{ "abn": "12345678901", "name": "ABAirlineSMETestAccountQBR", "industry": "Manufacture", "entityType": "", "gstRegistered": "" },"membershipNumber": "","status" : "A","membershipStartDate" : "2017-11-23","airlineLevel" : ""}';
       reqBody += ' ]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // pass the req and resp objects to the method     
        req.requestURI = '/services/apexrest/StoreQBRRegistration';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        CreateAccountQBRAPI.create();
        system.assert(res.statusCode == 400, 'Post Negative Status Code is not Matching');
        Test.stopTest();


    }
    /*-----------------------------------------------------------------------------------------------------------------      
    Method Name:        CreateExceptionTest
    Description:        Test Method for Exception Handling Scenarios
    Parameter:          NA
    ------------------------------------------------------------------------------------------------------------------*/

    static TestMethod void CreateExceptionTest(){
        Test.startTest();
        
        String reqBody = '{ "Company":{ "abn": "", "name": "", "industry": "", "entityType": "", "gstRegistered": "" },"membershipNumber": "","status" : "","membershipStartDate" : "","airlineLevel" : ""}';
       reqBody += ' ]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // pass the req and resp objects to the method     
        req.requestURI = '/services/apexrest/StoreQBRRegistration';  
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response = res;
        CreateAccountQBRAPI.create();
        system.assert(res.statusCode == 400, 'Post Negative Status Code is not Matching');
        Test.stopTest();

        List<Log__c> lstLog = [select Id from Log__c];
        system.assert(lstLog.size() != 0, 'Log record is not Inserted');
    }


}