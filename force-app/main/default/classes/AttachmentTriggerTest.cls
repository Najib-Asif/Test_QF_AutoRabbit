@isTest(seeAllData = False)
private class AttachmentTriggerTest
{
	@testSetup
    static void createTestData(){
    	//Enable Account, Contact,Case Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAttachmentTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEmailMessageTriggerSetting());
        insert lsttrgStatus;

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        TestUtilityDataClassQantas.insertQantasConfigData();

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Compliment RecType','CCC Compliment'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case Baggage RecType','CCC Baggage'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Complaint RecType','CCC Complaints'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Insurance Letter RecType','CCC Insurance Letter Case'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Medical RecType','CCC Medical'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Query RecType','CCC Query'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case QCC Further Action RecType','CCC Further Action Required'));
        insert lstConfigData;

    	//Create Account
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');

        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        objContact.CAP_ID__c='710000000017';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');

        //Create Case
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        String recordType = 'CCC Complaints';
        String type = 'Complaint';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Flight Disruptions','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');

        EmailMessage objEMsg = new EmailMessage(FromAddress = CustomSettingsUtilities.getConfigDataMap('Qantas Customer Care Email'), 
        	                                     Incoming = True, 
        	                                     ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
        	                                     Subject = 'Test email', 
        	                                     TextBody = '23456 ', 
        	                                     ParentId = lstCase[0].Id); 

 

		insert objEMsg; 
        system.assert(objEMsg.Id != Null, 'Attachment is not inserted');


        Attachment objAtt = new Attachment();
        objAtt.Name = 'Unit Test Attachment';
    	Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    	objAtt.body = bodyBlob;
        objAtt.parentId = objEMsg.Id;
        insert objAtt;
        system.assert(objAtt.Id != Null, 'Attachment is not inserted');

    }
	
	static TestMethod void eligiblityCheckOnAttachmentDelIPositive(){

		//Enable Validation 
        List<EnableValidationRule__c> lstEnableValidation = new List<EnableValidationRule__c>();
        lstEnableValidation.add(TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getprofileID()));
        insert lstEnableValidation;

        EmailMessage objEMsg = [select Id from EmailMessage limit 1];
		List<Attachment> lstAtt = [select Id, ParentId from Attachment Where parentId =: objEMsg.Id ];
		system.assert(lstAtt.size() == 1, 'Email has not Attachment');
		Test.startTest();
		try{
			delete lstAtt;
		}catch(Exception ex){}
		List<Attachment> lstAttAftDel = [select Id, ParentId from Attachment Where parentId =: objEMsg.Id ];
		system.assert(lstAttAftDel.size() == 1, 'Attachment is deleted');
		Test.stopTest();
	}

	

	static TestMethod void eligiblityCheckOnAttachmentDelNegative(){
		//Enable Validation 
        EnableValidationRule__c enableVal = TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getUserID());
        enableVal.PreventAttachmentDelete__c = false;
        insert enableVal;

        EmailMessage objEMsg = [select Id from EmailMessage limit 1];
		List<Attachment> lstAtt = [select Id, ParentId from Attachment Where parentId =: objEMsg.Id ];
		system.assert(lstAtt.size() == 1, 'Case has not Attachment');
		Test.startTest();
		delete lstAtt;
	
		List<Attachment> lstAttAftDel = [select Id, ParentId from Attachment Where parentId =: objEMsg.Id ];
		system.assert(lstAttAftDel.size() == 0, 'Attachment is not deleted');
		Test.stopTest();
	}

	static TestMethod void eligiblityCheckOnAttachmentDelException(){
		//Enable Validation 
        EnableValidationRule__c enableVal = TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getUserID());
        enableVal.PreventAttachmentDelete__c = true;
        insert enableVal;

        Attachment objAtt = new Attachment();
        objAtt.Name = 'Unit Test Attachment';
    	Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    	objAtt.body = bodyBlob;
        //objAtt.parentId = objCase.Id;
		List<Attachment> lstAtt = new List<Attachment>();		
		lstAtt.add(objAtt);

		Test.startTest();
			AttachmentTriggerHelper.eligiblityCheckOnAttachmentDel(lstAtt);
			List<Log__c> lstLogs = [select Id from Log__c];
			system.assert(lstLogs.size() != 0, ' Log Record is not inserted');
		Test.stopTest();
	}


}