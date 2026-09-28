/*==============================================================================================================================
Author:         Praveen Sampath
Company:        Capgemini
Purpose:        Test class for QCC_GenericUtils
Date:           05/12/2017          
History:
==============================================================================================================================*/
@isTest
private class QCC_GenericUtilsTest {
  	@testSetup
	static void createData() {

		List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        for(Trigger_Status__c ts : lsttrgStatus){
        	ts.Active__c = false;
        }
        insert lsttrgStatus;

        TestUtilityDataClassQantas.insertQantasConfigData();

        List<Qantas_API__c> lstQantasASPI = TestUtilityDataClassQantas.createQantasAPI();
		insert lstQantasASPI;

		List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_ContactEmail', 'test@mailinator.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_NoReplyContactLastName', 'QCC_NoReplyContactLastName'));
        insert lstConfigData;



        Contact con = new Contact(LastName='QCC_NoReplyContactLastName', FirstName='User', Email='test@mailinator.com', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services');
        insert con;
        
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(con);
        String recordType = 'CCC Complaints';
        String type = 'Compliment';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Qantas.com','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');

	}

	static TestMethod void getCAPValidNewTokenTest(){
		Qantas_API__c qAPI = [select Id from Qantas_API__c where Name = 'QCC_CAPToken'];
		qAPI.Token__c = '';
		update qAPI;
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
		String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
		system.assert(String.isNotBlank(token), 'Token is not returned from CAP');
		String token1 = QCC_GenericUtils.getAPIGatewayValidToken('QCC_CAPToken');
		system.assert(String.isNotBlank(token1), 'Token1 is not returned from CAP');

		Test.stopTest();
	}

	static TestMethod void getCAPValidExistingTokenTest(){
		Test.startTest();
		String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
		system.assert(String.isNotBlank(token), 'Token is not returned from CAP');
		String token1 = QCC_GenericUtils.getAPIGatewayValidToken('QCC_CAPToken');
		system.assert(String.isNotBlank(token1), 'Token1 is not returned from CAP');
		Test.stopTest();
	}

	static TestMethod void fetchGenericContactTest(){
		Test.startTest();
		String conId = QCC_GenericUtils.fetchGenericContact();
		system.assert(String.isNotBlank(conId), 'No Contact is returned');
		Test.stopTest();
	}

	static TestMethod void updateTokenTest(){
		Test.startTest();
		QCC_GenericUtils.updateToken('12344', 'QCC_CAPToken');
		Test.stopTest();
	}

	static TestMethod void mogrifyJSONTest(){
		Test.startTest();
	    Map<String, String> mapStr = new Map<String, String>();
		mapStr.put('123','1111');
		String resp = QCC_GenericUtils.mogrifyJSON('12344', mapStr);
		system.assert(String.isNotBlank(resp), 'Json mocking returns balnk response');
		Test.stopTest();
	}

	static TestMethod void postToCaseWithMentionTest(){
		Test.startTest();
        Map<String, String> mapStr = new Map<String, String>();
		mapStr.put('123','1111');
		Case objCase = [select Id, OwnerId from Case limit 1];
		QCC_GenericUtils.postToCaseWithMention(objCase, 'Past this');
		Test.stopTest();
	}

	static TestMethod void convertStringtoDateTimeTest(){
		Test.startTest();
        Datetime dt = QCC_GenericUtils.convertStringtoDateTime('20/06/2018', '14:37:00');
        system.assert(dt != Null, 'Date time is not returned as expected');
        Test.stopTest();
	}

	static TestMethod void fetchSalesforceEmailTemplateTest(){
		Test.startTest();
        String emailTemplate = QCC_GenericUtils.fetchSalesforceEmailTemplate('hello');
        system.assert(String.isBlank(emailTemplate), 'Email Tempalte is not Blank');
        Test.stopTest();
	}

    //Added by Purushotham on 25 SEP 2018 -- START
    static testMethod void testFetchContactForNonFFCases() {
        Test.startTest();
        QCC_GenericUtils.ContactWrap cw = QCC_GenericUtils.fetchContactForNonFFCases();
        Contact con = QCC_GenericUtils.fetchContactForNonFFCase();
        Test.stopTest();
        System.assertEquals(0, cw.count);
        System.assertEquals('Null1',cw.objCon.LastName);
        System.assert(con != null, 'Contact not found');
    }
    
    /*static testMethod void testFetchContactForNonFFCase() {
        Test.startTest();
        Contact con = QCC_GenericUtils.fetchContactForNonFFCase();
        QCC_GenericUtils.ContactWrap cw = QCC_GenericUtils.fetchContactForNonFFCases();
        Test.stopTest();
        System.assertEquals(0, cw.count);
        System.assertEquals('Null1',cw.objCon.LastName);
        System.assert(con != null, 'Contact not found');
    }*/

    static testMethod void testFormatFlightNumber(){
    	Test.startTest();
    	QCC_GenericUtils.formatFlightNumber('1');
    	QCC_GenericUtils.stringtoInteger('1');
    	QCC_GenericUtils.stringtoInteger('');
    	QCC_GenericUtils.doTrim(' ');
    	QCC_GenericUtils.getIntegerFromString('9');
    	Test.stopTest();
    }
    //Added by Purushotham on 25 SEP 2018 -- END
}