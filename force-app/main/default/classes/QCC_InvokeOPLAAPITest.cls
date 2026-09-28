@isTest(seeAllData = false)
private class QCC_InvokeOPLAAPITest {

    @testSetup
    static void createTestData(){
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
    }

    static TestMethod void invokeOPLAAPITest() {
        String Body = '{ "success": true, "referenceNo": "R-0213412", "errorMessage": ""}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));

        QCC_OPLALoungePassWrapper.Request oplaReq = new QCC_OPLALoungePassWrapper.Request();
        
        oplaReq.reference_no = 'Hello';
        oplaReq.frequent_flyer_no = '120303';
        oplaReq.expiry_period = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Expiry Period');
        oplaReq.title = 'Mr';
        oplaReq.first_name = 'Test';
        oplaReq.last_name = 'Again';
        oplaReq.email = 'test@test.com';
        oplaReq.issuer_code = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Issuer Code');
        oplaReq.pass_type = 'DOM';
        oplaReq.no_of_pass = '2';


        QCC_OPLALoungePassWrapper.Response wrap = QCC_InvokeOPLAAPI.invokeLoungePassPostAPI(oplaReq);
        system.assert(wrap.isSuccess == true, 'invokeLoungePassPostAPI success');
        Test.stopTest();
    }

    static TestMethod void invokeOPLAAPIMissingRequiredFieldTest() {
        String Body = '{ "success": false, "referenceNo": "R-0213412", "errorMessage": "Missing required field(s): email"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(400, 'Invalid Input', Body, mapHeader));

        QCC_OPLALoungePassWrapper.Request oplaReq = new QCC_OPLALoungePassWrapper.Request();
        
        oplaReq.reference_no = 'Hello';
        oplaReq.frequent_flyer_no = '120303';
        oplaReq.expiry_period = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Expiry Period');
        oplaReq.title = 'Mr';
        oplaReq.first_name = 'Test';
        oplaReq.last_name = 'Again';
        oplaReq.email = '';
        oplaReq.issuer_code = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Issuer Code');
        oplaReq.pass_type = 'DOM';
        oplaReq.no_of_pass = '2';


        QCC_OPLALoungePassWrapper.Response wrap = QCC_InvokeOPLAAPI.invokeLoungePassPostAPI(oplaReq);
        system.assert(wrap.isSuccess == false, 'invokeLoungePassPostAPI false. Missing required field(s): email');
        Test.stopTest();
    }

    static TestMethod void invokeOPLAAPITimeoutTest() {
        String Body = '{ "success": false, "referenceNo": "R-0213412", "errorMessage": "Call timeout"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(500, 'Internal Server Error', Body, mapHeader));

        QCC_OPLALoungePassWrapper.Request oplaReq = new QCC_OPLALoungePassWrapper.Request();
        
        oplaReq.reference_no = 'Hello';
        oplaReq.frequent_flyer_no = '120303';
        oplaReq.expiry_period = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Expiry Period');
        oplaReq.title = 'Mr';
        oplaReq.first_name = 'Test';
        oplaReq.last_name = 'Again';
        oplaReq.email = 'test@test.com';
        oplaReq.issuer_code = CustomSettingsUtilities.getConfigDataMap('QCC OPLA API Issuer Code');
        oplaReq.pass_type = 'DOM';
        oplaReq.no_of_pass = '2';


        QCC_OPLALoungePassWrapper.Response wrap = QCC_InvokeOPLAAPI.invokeLoungePassPostAPI(oplaReq);
        system.assert(wrap.isSuccess == false, 'invokeLoungePassPostAPI false. Call timeout');
        Test.stopTest();
    }
}