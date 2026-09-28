/* 
* Created By : Yuvaraj | TCS | Cloud Developer 
* Modified By : Ajay | Purpose to include additional coverage
* Main Class : QAC_SiteAdministrator_Controller, QAC_LDAPDetailsWrapper (API Class)

    Modified Date   : 26/06/19 (DD/MM/YYYY)
    Modified By     : Vinothkumar Balasubramanian
    Version         : V2.0 - Tradesite flag is not required for LDAP Account creation 
                      and Remove the Reset Flag on Main Class QAC_SiteAdministrator_Controller
                      so commented the Reset method on this class
*/

@isTest
public class QAC_SiteAdministrator_Controller_Test 
{
    @testSetup
    public static void setup()
    {
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting User and Profile
        Profile myProfile = [SELECT Id FROM Profile where Name = 'System Administrator'];
        User u = new User(LastName = 'TestUser', Alias = 'testu', Email = 'testuser@sample.com', Username = 'testusername@sample.com', 
                          CommunityNickname = 'testu',ProfileId = myProfile.Id, EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_AU',FederationIdentifier='199999',Qantas_Staff_ID__c='199999',TimeZoneSidKey = 'Australia/Sydney');
        
        //Inserting Account
        list<Account> myAccounts = new list<Account>();
        Account acc1 = new Account(Name = 'ValidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                   RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565365',Email__c='supernova.qac@qantas.com.au',
                                   IATA_Number__c = '0239205');
        myAccounts.add(acc1);
        Account acc2 = new Account(Name = 'invalidAcc', Active__c = true, rcti__c = true, Type = 'Agency Account',Billingcountry='AU', 
                                   RecordTypeId = agencyRecordTypeId, ABN_Tax_Reference__c  ='44563565365',Email__c='testuser@gmail.com',
                                   IATA_Number__c = '4590481');
        myAccounts.add(acc2);
        insert myAccounts;
        
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        
        Qantas_API__c qantasAPICreateLDAP = new Qantas_API__c();
        qantasAPICreateLDAP.Name = 'QAC_LDAPCreateAPI';
        qantasAPICreateLDAP.EndPoint__c = 'https://api-stage.qantas.com/qac/ims/1.0/userRegistration/sendVerificationLink';
        qantasAPICreateLDAP.Method__c = 'POST';
        lstQantas.add(qantasAPICreateLDAP);
        
        Qantas_API__c qantasAPIValidateLDAP = new Qantas_API__c();
        qantasAPIValidateLDAP.Name = 'QAC_LDAPValidateAPI';
        qantasAPIValidateLDAP.EndPoint__c = 'https://api-stage.qantas.com/qac/ims/1.0/userRegistration/validateUser';
        qantasAPIValidateLDAP.Method__c = 'GET';
        lstQantas.add(qantasAPIValidateLDAP);
        
        /*Qantas_API__c qantasAPIResetLDAP = new Qantas_API__c();
        qantasAPIResetLDAP.Name = 'QAC_LDAPResetAPI';
        qantasAPIResetLDAP.EndPoint__c = 'https://api-stage.qantas.com/qac/ims/1.0/userRegistration/generateSetPasswordLinkForSalesforceAdmin';
        qantasAPIResetLDAP.Method__c = 'POST';
        lstQantas.add(qantasAPIResetLDAP);*/
        
        Qantas_API__c qantasAPIAdmToken = new Qantas_API__c();
        qantasAPIAdmToken.Name = 'QAC_AdminSiteToken';
        qantasAPIAdmToken.ClientId__c = 'Hsy9vxL_Gue_X8WA6vgg5p6rZwka';
        qantasAPIAdmToken.ClientSecret__c = 'mfAjQFFUrFPq995mfxfhiFore5Ua';
        qantasAPIAdmToken.GrantType__c = 'client_credentials';
        qantasAPIAdmToken.EndPoint__c = 'https://api-stage.qantas.com/api/token';
        qantasAPIAdmToken.Method__c = 'POST';
        qantasAPIAdmToken.Token__c = 'Bearer 0361f7c3-c478-3764-ab32-f2dc28149066';
        lstQantas.add(qantasAPIAdmToken);
        
        insert lstQantas;
    }
    
    public static testmethod void validAccountTest()
    {
        string strIATA = '0239205';
        Test.startTest();
        QAC_SiteAdministrator_Controller.sfAccDetails(strIATA);
        Test.stopTest();
    }
    
    public static testmethod void nullAccountTest()
    {
        string strIATA = '8888888';
        Test.startTest();
        QAC_SiteAdministrator_Controller.sfAccDetails(strIATA);
        Test.stopTest();
    }
    
    public static testmethod void validateLDAP()
    {
        String strIATA = '0239205';
        String responseBody = '{"username": "0239205","managerAccountExists": true,"agencyPasswordLastModifiedTimeStamp": "20190111011924.522","managerPasswordLastModifiedTimeStamp": "20190111003425.949"}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        mapHeader.put('Accept', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(200, 'Success', responseBody, mapHeader));
        QAC_SiteAdministrator_Controller.validateLDAP(strIATA);
        Test.stopTest();
    }
    
    public static testmethod void exceptionLDAP(){
        String strIATA = '0239205';        
    	string responseBody = '{"fault":{"code":900901,"message":"Invalid Credentials","description":"Access failure for API: /qac/ims/1.0, version: 1.0 status: (900901) - Invalid Credentials. Make sure you have given the correct access token"}}';

        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        mapHeader.put('Accept', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(401, 'Unauthorized', responseBody, mapHeader));
        QAC_SiteAdministrator_Controller.validateLDAP(strIATA);
        Test.stopTest();
    }
    
    public static testmethod void validateLDAPInactive()
    {
        String strIATA = '0239200';
        String responseBody = '{"username": "0239200","managerAccountExists": false,"agencyPasswordLastModifiedTimeStamp": "20190111011924.522","managerPasswordLastModifiedTimeStamp": "20190111003425.949"}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        mapHeader.put('Accept', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(200, 'Success', responseBody, mapHeader));
        QAC_SiteAdministrator_Controller.validateLDAP(strIATA);
        Test.stopTest();
    }
    
    public static testmethod void createLDAP()
    {
        String strIATA = '4590481';
        String Body = '{"message": "user password set up link generated successfully","maskedEmailAddress": "te******@gmail.com"}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(200, 'Success', Body, mapHeader));
        QAC_SiteAdministrator_Controller.createLDAP(strIATA);
        Test.stopTest();
    }
    
    /*public static testmethod void resetLDAP()
    {
        String strIATA = '4590481';
        String Body = '{"message": "user password set up link generated successfully","passwordSetUpLink": "https://www.qantas.com/agencyconnect/au/en/password-setup.html?token=eyJhZ2VuY3lDb2RlIjoiMDIzOTIwNSIsInVzZXJSZWdpc3RyYXRpb25WZXJpZmljYXRpb25Ub2tlblVVSUQiOiJhNmMyYTdhOC01MzQzLTQ1MjYtYTdiZi00YjE2NGZmMDNlODAifQ=="}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(200, 'Success', Body, mapHeader));
        QAC_SiteAdministrator_Controller.resetLDAP(strIATA);
        Test.stopTest();
    }*/
    
    public static testmethod void LDAP404()
    {
        string strIATA = '4590481';
        String Body = '{"errorCode": "AGENCY_NOT_FOUND","message": "AGENCY ACCOUNT DOESNT EXIST"}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(404, 'Not Found', Body, mapHeader));
        QAC_SiteAdministrator_Controller.validateLDAP(strIATA);
        Test.stopTest();
    }
    
    public static testmethod void LDAP500(){
        String strIATA = '2439011';
        String Body = '{"message":"Internal Server Exception"}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(500, 'Internal Server Issue', Body, mapHeader));
        QAC_SiteAdministrator_Controller.createLDAP(strIATA);
        Test.stopTest();
        
    }
    
    public static testmethod void LDAP400()
    {
        string strIATA = '4590481';
        String Body = '{"message": "Bad Request"}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QAC_SiteAdministrator_Controller_Mock(400, 'Bad Request', Body, mapHeader));
        QAC_SiteAdministrator_Controller.validateLDAP(strIATA);
        Test.stopTest();
    }
}