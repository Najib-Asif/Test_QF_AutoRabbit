/***********************************************************************************************************************************

Description: Apex Test class for QAC_TMCOperations Class 

*****************************************************************************************************************************/
@IsTest
public class QAC_TMCOperations_Test {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        List<QantasConfigData__c> qcdList = new List<QantasConfigData__c>();
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        qcdList.add(qcd);
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        qcdList.add(qcd2);
        
        QantasConfigData__c qcd3 = new QantasConfigData__c(Name='Account RecType1',Config_Value__c='Agency Account');
        qcdList.add(qcd3);
        insert qcdList;
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
             
        insert lsttrgStatus;

        //Inserting Account
        List<Account> accList = new List<Account>();
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557');
        
        accList.add(acc);
        
        Account relatedAcc = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1000000', Qantas_Industry_Centre_ID__c = '1000000');
        
        accList.add(relatedAcc);
        
        insert accList;

        String tmcRTID = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();

        //Inserting TMC Info
        List<Agency_Info__c> listAgencyinfo = new List<Agency_Info__c>();
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = accList[0].Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.GDS_Status__c ='New';
        
        listAgencyinfo.add(Agencyinfo);

        Agency_Info__c Agencyinfo2 = new Agency_Info__c();
        Agencyinfo2.Account__c = accList[0].Id;
        Agencyinfo2.RecordTypeId = tmcRTID;        
        Agencyinfo2.Active__c=true;
        Agencyinfo2.Email_Id__c='test@test.com';
        Agencyinfo2.Code__c  ='Sabre';
        Agencyinfo2.PCC__c   ='2yMT';
        Agencyinfo2.GDS_Status__c='Accepted';
        Agencyinfo2.ATPCO_Status__c='Accepted';
        Agencyinfo2.Surcharge_Exemption_Status__c='Accepted';
        Agencyinfo2.QDP_Status__c='Accepted';
        Agencyinfo2.Channel_Effective_Date__c = System.today().addDays(+2);
        
        listAgencyinfo.add(Agencyinfo2);
        
        Agency_Info__c Agencyinfo3 = new Agency_Info__c();
        Agencyinfo3.Account__c = accList[0].Id;
        Agencyinfo3.RecordTypeId = tmcRTID;        
        Agencyinfo3.Active__c=true;
        Agencyinfo3.Email_Id__c='test@test.com';
        Agencyinfo3.Code__c  ='Sabre';
        Agencyinfo3.PCC__c   ='2yMC';
        Agencyinfo3.GDS_Status__c='Accepted';
        Agencyinfo3.ATPCO_Status__c='';
        Agencyinfo3.Surcharge_Exemption_Status__c='';
        Agencyinfo3.QDP_Status__c='';
        
        listAgencyinfo.add(Agencyinfo3);
        
        Agency_Info__c Agencyinfo4 = new Agency_Info__c();
        Agencyinfo4.Account__c = accList[0].Id;
        Agencyinfo4.RecordTypeId = tmcRTID;        
        Agencyinfo4.Active__c=true;
        Agencyinfo4.Email_Id__c='test@test.com';
        Agencyinfo4.Code__c  ='Sabre';
        Agencyinfo4.PCC__c   ='2yMD';
        Agencyinfo4.GDS_Status__c='Accepted';
        Agencyinfo4.ATPCO_Status__c='Accepted';
        Agencyinfo4.Surcharge_Exemption_Status__c='Accepted';
        Agencyinfo4.QDP_Status__c='Accepted';
        Agencyinfo4.Channel_Effective_Date__c = System.today().addDays(-2);
        
        listAgencyinfo.add(Agencyinfo4);
        
        Agency_Info__c Agencyinfo5 = new Agency_Info__c();
        Agencyinfo5.Account__c = accList[0].Id;
        Agencyinfo5.RecordTypeId = tmcRTID;        
        Agencyinfo5.Active__c=true;
        Agencyinfo5.Email_Id__c='test@test.com';
        Agencyinfo5.Code__c  ='Galileo';
        Agencyinfo5.PCC__c   ='2yMK';
        Agencyinfo5.GDS_Status__c='Rejected';
        
        listAgencyinfo.add(Agencyinfo5);
        
        Agency_Info__c Agencyinfo6 = new Agency_Info__c();
        Agencyinfo6.Account__c = accList[0].Id;
        Agencyinfo6.RecordTypeId = tmcRTID;        
        Agencyinfo6.Active__c=true;
        Agencyinfo6.Email_Id__c='test@test.com';
        Agencyinfo6.Code__c  ='Galileo';
        Agencyinfo6.PCC__c   ='2yMH';
        Agencyinfo6.GDS_Status__c='Deregistered';
        Agencyinfo6.ATPCO_Status__c='Deregistered';
        Agencyinfo6.Surcharge_Exemption_Status__c='Deregistered';
        Agencyinfo6.QDP_Status__c='Pending deregistration';
        
        listAgencyinfo.add(Agencyinfo6);
        
        Agency_Info__c Agencyinfo7 = new Agency_Info__c();
        Agencyinfo7.Account__c = accList[0].Id;
        Agencyinfo7.RecordTypeId = tmcRTID;        
        Agencyinfo7.Active__c=true;
        Agencyinfo7.Email_Id__c='test@test.com';
        Agencyinfo7.Code__c  ='Apollo';
        Agencyinfo7.PCC__c   ='2yMI';
        Agencyinfo7.GDS_Status__c='Deregistered';
        Agencyinfo7.ATPCO_Status__c='Deregistered';
        Agencyinfo7.Surcharge_Exemption_Status__c='Deregistered';
        Agencyinfo7.QDP_Status__c='Deregistered';
        
        listAgencyinfo.add(Agencyinfo7);
        
        Agency_Info__c Agencyinfo8 = new Agency_Info__c();
        Agencyinfo8.Account__c = accList[0].Id;
        Agencyinfo8.RecordTypeId = tmcRTID;        
        Agencyinfo8.Active__c=true;
        Agencyinfo8.Email_Id__c='test@test.com';
        Agencyinfo8.Code__c  ='Sabre';
        Agencyinfo8.PCC__c   ='2yML';
        Agencyinfo8.GDS_Status__c='';
        
        listAgencyinfo.add(Agencyinfo8);
        
        /*Agency_Info__c Agencyinfo3 = new Agency_Info__c();
        Agencyinfo3.Account__c = accList[1].Id;
        Agencyinfo3.Active__c=true;
        Agencyinfo3.Email_Id__c='test@test.com';
        Agencyinfo3.Code__c  ='Galileo';
        Agencyinfo3.PCC__c   ='AS2P';
        Agencyinfo3.Market_Segment__c ='Corporate';
        listAgencyinfo.add(Agencyinfo3);
        */
        insert listAgencyinfo;
        
        List<Trigger_Status__c> st = new List<Trigger_Status__c>();
        Trigger_Status__c tr = new Trigger_Status__c(name='AssetCalculateFeesandDiscounts');
        st.add(tr);
        Trigger_Status__c tr1 = new Trigger_Status__c(name='AssetConvertingAssetType');
        st.add(tr1);
        Trigger_Status__c tr2 = new Trigger_Status__c(name='AssetChannel');
        st.add(tr2);
        insert st;
        Asset asstObj = new Asset();
        asstObj.accountId=accList[1].Id;
        asstObj.Name='Test';
        asstObj.Status='New';
        asstObj.RecordTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Channel').getRecordTypeId();
        insert asstObj;
    }
    
    
    // Testing positive scenario
    @isTest
    public static void testParse() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        
        system.debug(' @@ agencyAccount @@ ' + agencyAccount);
        
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = agencyAccount.Id;
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        
        list<QAC_TMCInformationParsing> requestBody = new list<QAC_TMCInformationParsing>();
        requestBody.add(new QAC_TMCInformationParsing(Agencyinfo));

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations/1000000';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(requestBody));
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_TMCOperations.doTMCInsertion();
        test.stopTest();
    }
    @isTest
    public static void testParse1() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '4364557' LIMIT 1];
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = agencyAccount.Id;
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        
        list<QAC_TMCInformationParsing> requestBody = new list<QAC_TMCInformationParsing>();
        requestBody.add(new QAC_TMCInformationParsing(Agencyinfo));
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations/1000000';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(requestBody));
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_TMCOperations.doTMCInsertion();
        test.stopTest();
    
    }    
    @isTest
    public static void testPatch1() {
        
        Agency_Info__c tmc= [SELECT Id,Email_Id__c FROM Agency_Info__c limit 1]; 
        System.debug('tmcList'+tmc);
        Agency_Info__c agencyinfo = new Agency_Info__c();
        agencyinfo.id = tmc.Id;
        agencyinfo.Active__c=true;
        QAC_TMCInformationParsing requestBody = new QAC_TMCInformationParsing(Agencyinfo);
        reqMethodBody('1000000','PATCH',requestBody);
        test.startTest();
        QAC_TMCOperations.doTMCupdate();
        test.stopTest();
    
    }
    @isTest
    public static void testPatch2() {
        
       Agency_Info__c tmc= [SELECT Id,Account__r.Qantas_Industry_Centre_ID__c FROM Agency_Info__c limit 1];    
       
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.id = tmc.Id;
        Agencyinfo.Active__c=false;
        
        QAC_TMCInformationParsing requestBody = new QAC_TMCInformationParsing(Agencyinfo);
        reqMethodBody('1000000','PATCH',requestBody);
        test.startTest();
        QAC_TMCOperations.doTMCupdate();
        test.stopTest();
    
    }
    @isTest
    public static void testPatch3() {
        
       Agency_Info__c tmc= [SELECT Id,Account__r.Qantas_Industry_Centre_ID__c FROM Agency_Info__c limit 1];    
       
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.id = tmc.Id;
        Agencyinfo.Active__c=false;
        
        QAC_TMCInformationParsing requestBody = new QAC_TMCInformationParsing(Agencyinfo);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serializePretty(requestBody));
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_TMCOperations.doTMCupdate();
        test.stopTest();
    
    }
    @isTest
    public static void testPatch4() {
        
       Agency_Info__c tmc= [SELECT Id,Account__r.Qantas_Industry_Centre_ID__c FROM Agency_Info__c limit 1];    
       
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.id = tmc.Id;
        Agencyinfo.Active__c=false;
        
        QAC_TMCInformationParsing requestBody = new QAC_TMCInformationParsing(Agencyinfo);
        reqMethodBody('','PATCH',requestBody);
        test.startTest();
        QAC_TMCOperations.doTMCupdate();
        test.stopTest();
    
    }
    @isTest
    public static void testPatch5() {
        
       Agency_Info__c tmc= [SELECT Id,Account__r.Qantas_Industry_Centre_ID__c FROM Agency_Info__c limit 1];    
       
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        
        Agencyinfo.Active__c=false;
        
        QAC_TMCInformationParsing requestBody = new QAC_TMCInformationParsing(Agencyinfo);
        reqMethodBody('1000000','PATCH',requestBody);
        test.startTest();
        QAC_TMCOperations.doTMCupdate();
        test.stopTest();
    
    }
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            
            Test.startTest();
            QAC_TMCOperations.doTMCRetrieval();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    @isTest
    public static void testwithExptJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            
            Test.startTest();
            QAC_TMCOperations.doTMCupdate();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    // Testing positive Exceptions
    @isTest
    public static void testException_1() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount);
        
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = agencyAccount.Id;
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        
        list<QAC_TMCInformationParsing> requestBody = new list<QAC_TMCInformationParsing>();
        requestBody.add(new QAC_TMCInformationParsing(Agencyinfo));

        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(requestBody));
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_TMCOperations.doTMCInsertion();
        test.stopTest();
    
    }
    
    // Testing Exceptions
    @isTest
    public static void testException_2() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount);
        
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = agencyAccount.Id;
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        
        list<QAC_TMCInformationParsing> requestBody = new list<QAC_TMCInformationParsing>();
        requestBody.add(new QAC_TMCInformationParsing(Agencyinfo));

        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(requestBody));
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_TMCOperations.doTMCInsertion();
        test.stopTest();
    
    }
    
    // Testing Exceptions
    @isTest
    public static void testException_3() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount);
        
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = agencyAccount.Id;
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        
        list<QAC_TMCInformationParsing> requestBody = new list<QAC_TMCInformationParsing>();
        requestBody.add(new QAC_TMCInformationParsing(Agencyinfo));

        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations/1000001';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(requestBody));
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_TMCOperations.doTMCInsertion();
        test.stopTest();
    
    }
    
    // Testing Exceptions
    @isTest
    public static void testException_4() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        system.debug(' @@ agencyAccount @@ ' + agencyAccount);
        
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = agencyAccount.Id;
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Galileo';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        
        QAC_TMCInformationParsing requestBody = new QAC_TMCInformationParsing(Agencyinfo);

        reqMethodBody('1000000','POST',requestBody);
        test.startTest();
        QAC_TMCOperations.doTMCInsertion();
        test.stopTest();
    
    }
       
    // Testing positive scenario
    @isTest
    public static void testParse_Retrieval() {
        requestMethod('4364557','GET');
        
        test.startTest();
        QAC_TMCOperations.doTMCRetrieval();
        test.stopTest();
    }
    @isTest
    public static void testRetrieval() {
        requestMethod('1000000','GET');
        test.startTest();
        QAC_TMCOperations.doTMCRetrieval();
        test.stopTest();
    }
    
    // Testing Exceptions
    @isTest
    public static void testException_3_Retrieval() {
        requestMethod('1000001','GET');
        test.startTest();
        QAC_TMCOperations.doTMCRetrieval();
        test.stopTest();
    }
    
    // Testing Exceptions
    @isTest
    public static void testException_4_Retrieval() {
        
        requestMethod('','GET');
        
        test.startTest();
        QAC_TMCOperations.doTMCRetrieval();
        test.stopTest();
    }
    
    public static void requestMethod(String agencyCode,String method)
    {
        system.debug('@@@@insideRequest method');
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations/'+agencyCode;
        req.httpMethod = method;
        RestContext.request = req;
        RestContext.response = res;
    }
    public static void reqMethodBody(String agencyCode,String method,QAC_TMCInformationParsing requestBody)
    {
        system.debug('@@@@insideRequest method');
        RestRequest req = new RestRequest();
        RestResponse res =  new RestResponse();
        
        req.requestURI = '/services/apexrest/QACTMCOperations/'+agencyCode;
        req.httpMethod = method;
        req.requestBody = Blob.valueOf(JSON.serializePretty(requestBody));
        RestContext.request = req;
        RestContext.response = res;
    }
}