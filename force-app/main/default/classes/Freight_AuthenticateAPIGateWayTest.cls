@isTest
public class Freight_AuthenticateAPIGateWayTest {
    
    @testSetup
    static void setup() {
        //Integration_User_Tradesite__c ss = new Integration_User_Tradesite__c(
         //   Name = 'Freight_iCargo_Integration',
          //  Username__c = 'SALESICARGOS',
          //  Password__c = 'CU329VR3',
         //   Endpoint__c = 'https://api-stage.qantas.com/customer/freightservice/v1/trackFreight/shipment',
          //  NameChangeStartNumber__c = 1, 
          //  NameChangeEndNumber__c = 1,
         //   Client_Id__c = '08c64f80',
          //  Client_Secret__c = 'f272c21fcea5a9d661f9fe8890510622',
          //  Authentication_Endpoint_URL__c = 'https://api-stage.qantas.com/customer/oauth/token');
        //insert ss;        
    }
    
    @isTest 
    static void APIGateWayTest() {
        
        Test.setMock(HttpCalloutMock.class, new Freight_APIGateWayMock());
        
        Test.startTest();
        String acstoken;
        //acstoken = Freight_AuthenticateAPIGateWay.authenticateAPIGateway();
        acstoken = Freight_AuthenticateAPIGateWay.returnAccessToken();
        system.debug('accessTok**'+acstoken);
        Test.stopTest();
    }
    
}