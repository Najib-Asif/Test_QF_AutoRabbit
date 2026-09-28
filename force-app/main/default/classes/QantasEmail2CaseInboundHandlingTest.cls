/*----------------------------------------------------------------------------------------------------------------------
Author:        Navpreet Kaur
Company:       TCS
Date Implemented:  7 November 2022
Description:  FCRM - 889 Test Class for QantasEmail2CaseInboundHandling 
Modified By : Hari B, 27-Mar-2026
              Remediated test class failures and added setupTestData().
-------------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class QantasEmail2CaseInboundHandlingTest {
	@testSetup static void setupTestData() {
		Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();		
		Test.startTest();		
		List<Trigger_Status__c> listCustSett=new List<Trigger_Status__c>();
		listCustSett.addAll(freightUtilToBypassTrgCustSett.createCaseTriggerSettingFalse());
		insert listCustSett;
		TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
		Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
		accountRecord.RecordTypeId = accountRecordTypeId;
		accountRecord.billingcountry='AU';
		accountRecord.Email__c='greenavenue@auspost.com.au';
		insert accountRecord;
		Test.stopTest();
	}

    static testMethod void TestInBoundEmails() {
	Account accountRecord = [SELECT RecordTypeId, billingcountry, Email__c FROM Account LIMIT 1];
	Airport_Code__c  mdtRec=new Airport_Code__c (Name='NONE',QF_Freight_Presence__c=true);
	insert mdtRec;
	Id qantas_Freight=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId();
	Case newCase=new Case(recordtypeid=qantas_Freight,origin='FRT Cust Service',status='new',subject='Test Case', description='test Case',accountid=accountRecord.id);
	insert newCase;

	Case insertedCase=[select id,casenumber from case where id=: newCase.id];
	// create a new email and envelope object
	Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

	// setup the data for the email
	email.subject = 'Qantas Customer Care - '+insertedCase.casenumber;
	email.fromAddress = 'TestQantas@qantas.com.au';
	email.plainTextBody = 'email body\n2225256325\nTitle';

	// add an Binary attachment
	Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
	attachment.body = blob.valueOf('my attachment text');
	attachment.fileName = 'textfileone.txt';
	attachment.mimeTypeSubType = 'text/plain';
	email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };     

	// add an Text atatchment  
	Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
	attachmenttext.body = 'my attachment text';
	attachmenttext.fileName = 'textfiletwo3.txt';
	attachmenttext.mimeTypeSubType = 'texttwo/plain';
	email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

	// call the email service class and test it with the data in the testMethod
	Test.startTest();
	QantasEmail2CaseInboundHandling callObj = new QantasEmail2CaseInboundHandling();
	callObj.handleInboundEmail(email,env);
	Test.stopTest();    
    }
}