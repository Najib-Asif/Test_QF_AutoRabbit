/***********************************************************************************************************************************
Author:          Jayaraman Jayaraj
Company:         TCS
Description:     Agency TA information Update.
Main Class Name: QAC_AgencyTADetailsUpdate

History: 
======================================================================================================================
Date               Name                          Description                                                 
======================================================================================================================
20-Jun-2018        Jay                         Initial Design

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated dataSetup() method.
**********************************************************************************************************************************/
@isTest
public class QAC_AgencyTADetailsUpdate_Test {
    
    /* Test data setup */
    @testSetup
    public static void dataSetup(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        String agencyAcctRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd;
        
        // Primary Account
        Account agencyAccount1 = new Account(Name = 'Test Account1', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyAcctRtId, Migrated__c = true, ABN_Tax_Reference__c  ='98987566453',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '7777777');
        insert agencyAccount1;
        
        // Related Account
        Account agencyAccount2 = new Account(Name = 'Test Account2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                             RecordTypeId = agencyAcctRtId, Migrated__c = true, ABN_Tax_Reference__c  ='98987588888',
                                             Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '8888888');
        insert agencyAccount2;
        
        //Inserting TA Record
        Account_Relation__c TaRecord = new Account_Relation__c(Primary_Account__c = agencyAccount1.Id, Related_Account__c = agencyAccount2.Id, Relationship__c ='Travel Manager Of', 
                                                               Active__c = true);
        insert TaRecord;
    }
    
    
    /* Updating TMC record with valid Agency code and TMC Record Id in sampleTMCJson Method*/
    public static testMethod void sampleTAJson(){
        
        Account_Relation__c taObj =  [SELECT Id, Primary_Account__c, Primary_Account__r.IATA_Number__c FROM Account_Relation__c WHERE Primary_Account__r.IATA_Number__c =: '7777777' ];
        String taRecordId = taObj.Id;
        String agencyCode =taObj.Primary_Account__r.IATA_Number__c;
        
        String json='{'+
            '\"isActive\":'+
            'false'+','+
            '\"id\":\"'+taRecordId+'\"'+ 
            '}';
        system.debug('@@@@Json-'+json);
        
        QAC_AgencyTADetailsUpdateParsing parObj = QAC_AgencyTADetailsUpdateParsing.parse(json); 
        QAC_AgencyTADetailsUpdate_Test.requestMethod(parObj, '7777777', '');
        
        Test.startTest();
        QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
        Test.stopTest();
    }
    
    /* All Exception handled in this excepTestJson Method */
    public static testMethod void excepTestJson(){
        
        //Invalid TA RecordId
        String json='{'+
            '\"isActive\":'+
            'false'+','+
            '\"id\":\"'+1+'\"'+ 
            '}'; 
        system.debug('@@@@Json-'+json);
        QAC_AgencyTADetailsUpdateParsing parObj1 = QAC_AgencyTADetailsUpdateParsing.parse(json); 
        QAC_AgencyTADetailsUpdate_Test.requestMethod(parObj1, '1234568','');
        
        QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
        
        //Blank TA RecordId
        String empRidJson='{'+
            '\"isActive\":'+
            'false'+','+
            '\"id\":\"'+''+'\"'+ 
            '}'; 
        system.debug('@@@@Json-'+json);
        QAC_AgencyTADetailsUpdateParsing parObj2 = QAC_AgencyTADetailsUpdateParsing.parse(empRidJson); 
        QAC_AgencyTADetailsUpdate_Test.requestMethod(parObj2, '1234568','');
        
        QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
        
        //Blank Agency Code
        Account_Relation__c taObj1 =  [SELECT Id, Primary_Account__c, Primary_Account__r.IATA_Number__c FROM Account_Relation__c WHERE Primary_Account__r.IATA_Number__c =: '7777777'];
        String taRecordId1 = taObj1.Id;
        
        String empAgencycodeJson='{'+
            '\"isActive\":'+
            'false'+','+
            '\"id\":\"'+taRecordId1+'\"'+ 
            '}'; 
        system.debug('@@@@Json-'+empAgencycodeJson);
        QAC_AgencyTADetailsUpdateParsing parObj3 = QAC_AgencyTADetailsUpdateParsing.parse(empAgencycodeJson); 
        QAC_AgencyTADetailsUpdate_Test.requestMethod(parObj3, 'Null','');
        
        QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
        
        //Blank Agency Code
        Account_Relation__c taObj2 =  [SELECT Id, Primary_Account__c, Primary_Account__r.IATA_Number__c FROM Account_Relation__c WHERE Primary_Account__r.IATA_Number__c =: '7777777'  ];
        String taRecordId2 = taObj2.Id;
        
        String empAgencycodeJson1='{'+
            '\"isActive\":'+
            'false'+','+
            '\"id\":\"'+taRecordId2+'\"'+ 
            '}'; 
        system.debug('@@@@Json-'+empAgencycodeJson1);
        QAC_AgencyTADetailsUpdateParsing parObj4 = QAC_AgencyTADetailsUpdateParsing.parse(empAgencycodeJson1); 
        QAC_AgencyTADetailsUpdate_Test.requestMethod(parObj4, '','');
        
        QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
        
        try{
            system.debug('Inside JSON Excep');
            String emptyJson = '';
            //QAC_AgencyTADetailsUpdateParsing parObj5 = QAC_AgencyTADetailsUpdateParsing.parse(emptyJson); 
            QAC_AgencyTADetailsUpdate_Test.requestMethod(null, '5654345', emptyJson );
            
            Test.startTest();
            QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
            Test.stopTest();
        }
        catch(Exception ex){
            system.debug('inside catch testclass'+ex.getTypeName());
            QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
        } 
        
    }
    
    public static testMethod void erro412Json()
    {
        
        Account_Relation__c taObj =  [SELECT Id,active__c, Primary_Account__c, Primary_Account__r.IATA_Number__c FROM Account_Relation__c WHERE Primary_Account__r.IATA_Number__c =: '7777777' ];
        
        String taRecordId = taObj.Id;
        String agencyCode =taObj.Primary_Account__r.IATA_Number__c;
        String json='{'+
            '\"isActive\":'+
            'true'+','+
            '\"id\":\"'+taRecordId+'\"'+ 
            '}';
        system.debug('@@@@Json-'+json);
        QAC_AgencyTADetailsUpdateParsing parObj = QAC_AgencyTADetailsUpdateParsing.parse(json); 
        QAC_AgencyTADetailsUpdate_Test.requestMethod(parObj, agencyCode, '');
        
        
        Test.startTest();
        QAC_AgencyTADetailsUpdate.doTADetailsUpdate();
        Test.stopTest();
        
    }
    
    /*  Invoking API from this requestMethod  */
    public static void requestMethod(QAC_AgencyTADetailsUpdateParsing parObj, String agencyCode, String empJson ){
        system.debug('@@@@insideRequest method');
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAgencyTADetailsUpdate/'+agencyCode;
        req.httpMethod = 'PATCH';
        req.requestBody = (parObj != null) ? Blob.valueOf(System.JSON.serializePretty(parObj)) : (empJson != null) ? Blob.valueOf(empJson) : null;
        
        RestContext.request = req;
        RestContext.response = res;
        
    }
}