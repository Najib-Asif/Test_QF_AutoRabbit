@isTest
public class QCC_InvokeEQAPITest {
    static User u1;
    static Account objAcc; 
    
    @testSetup
	static void createTestData() {
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        Map<String, UserRole> rolesMap = TestUtilityDataClassQantas.getRoles();
        u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                      Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
                      EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                      TimeZoneSidKey = 'Australia/Sydney', Location__c='Sydney', UserRoleId = rolesMap.get('QF-QDC-OM-MNL-TL').Id
                     );
        insert u1;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        system.runAs(thisUser) {
            List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
            lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
            insert lsttrgStatus;
            TestUtilityDataClassQantas.insertQantasConfigData();
        }

        System.runAs(u1) {
            Id recvyEFTRecTypeId = GenericUtils.getObjectRecordTypeId('Recovery__c', CustomSettingsUtilities.getConfigDataMap('QCC Recovery EFT RecType'));
            //Create Account
            Account objAcc = TestUtilityDataClassQantas.createPersonAccount();
            objAcc.Airline_Level__c = '1';
            objAcc.Active__c = true;
            insert objAcc;
            system.assert(objAcc != Null, 'Account is not inserted');
        	
            //Create Contact
            Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
            objContact.LastName='ContTesttwo';
            objContact.CAP_ID__c='710000000017';
            objContact.RecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
            system.debug('>>>Before Contact is inserted');
            insert objContact;
            System.assert(objContact.Id != Null, 'Contact is not inserted');
            
            //Create Case
            List<Contact> lstContact = new List<Contact>();
            lstContact.add(objContact);
            String recordType = 'CCC Complaints';
            String type = 'Complaint';
            List<Case> caseRecs = new List<Case>();
            List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Qantas.com','','','');
            for(Case c : [Select Id, Status from Case where Id =: lstCase[0].Id]){
                c.Status = 'In Progress';
                caseRecs.add(c);
            }
            update caseRecs;

            system.assert(lstCase.size()>0, 'Case List is Zero');
            system.assert(lstCase[0].Id != Null, 'Case is not inserted');

            //Create Recovery
            system.debug('recvy rec type...'+recvyEFTRecTypeId);
            system.debug('RecoveryPStatusQuedForPaymentPrcsng...'+CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng'));
            List<Recovery__c> recvyRecs = new List<Recovery__c>();
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoverieswithRecType(lstCase, recvyEFTRecTypeId, 
                                            CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng'),
                                            'Ticket Refund EFT');

            for(Recovery__c r : [Select Id, Invoice_Claim_Description__c, Value__c, Monetary_Value__c, Country_Code__c,
                                 Bank_Name__c, Branch_Name__c, Branch_Number_BSB_Sort_Code__c,Branch_Swift_BIC_Code__c,
                                 Branch_Party_Id__c, Bank_Account_Name__c, Bank_Account_Number__c, IBAN__c, TAX_Id_VAT_Reg_No__c, Account_Type__c
                                 from Recovery__c where Id IN: lstRecovery]){
                r.Invoice_Claim_Description__c = 'Test Claim';
                r.Value__c = 100;
                r.Monetary_Value__c = 100; //this value should be same as Value__c
                r.Bank_Name__c = 'BANK OF QUEENSLAND LIMITED';
                r.Branch_Name__c = 'BRISBANE (124327)';
                r.Branch_Number_BSB_Sort_Code__c = '124327';
                r.Branch_Swift_BIC_Code__c = '';
                r.Branch_Party_Id__c = '31062229';
                r.Bank_Account_Name__c = 'dfdf';
                r.Bank_Account_Number__c = '12345678';
                r.IBAN__c = '';
                r.TAX_Id_VAT_Reg_No__c = '';
                r.Account_Type__c = 'Savings';
                recvyRecs.add(r);                
            }
            update recvyRecs;
        }	
	}
    
    @isTest   
    static void testEQAPISuccess() {
        QCC_EQResponseWrapper resParams = new QCC_EQResponseWrapper();
        Test.startTest();
        /* Due to real time existing code issue - Too many SOQL queries: 101 the below code is added inside Test.start/stop methods */
        Id recvyEFTRecTypeId = GenericUtils.getObjectRecordTypeId('Recovery__c', CustomSettingsUtilities.getConfigDataMap('QCC Recovery EFT RecType'));
        List<Recovery__c> recvyList = [Select Id, Name, type__c, Original_Currency__c, Invoice_Claim_Description__c, payment_Details_added_manually__c, Original_Currency_Acronym__c, Value__c,Recovery_Reason__c,
                                Monetary_Value__c, Refund_Cost_Centre_Number__c, Refund_Account_Number__c, Case_Number__r.Contact.Salutation, Country_Code__c,
                                Case_Number__r.First_Name__c,  Case_Number__r.Last_Name__c, Case_Number__r.Contact.FirstName, Case_Number__r.Contact.LastName, Bank_Name__c, Branch_Name__c, Branch_Number_BSB_Sort_Code__c,
                                Branch_Swift_BIC_Code__c, Branch_Party_Id__c, Bank_Account_Name__c, Bank_Account_Number__c, IBAN__c, TAX_Id_VAT_Reg_No__c,
                                Account_Type__c from Recovery__c where  Process_Status__c =: CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng') and 
                                RecordTypeId =: recvyEFTRecTypeId order by Value__c, Name asc];
 
        //prepare json
        QCC_EQRequestWrapper requestEQ = QCC_EQCalloutsQueuable.preparePayload(recvyList);
        String resBody = '{\"P_CC_CLAIM_HEADER\":{\"UNIQUE_SOURCE_CALL_SEQ\":20240827122054,\"EMAIL\":\"shr_ccreq@qantas.com.au\",\"PHONE_EXT\":913234,\"PREPARED_BY\":171323},\"P_CC_CLAIM_LINES\":{\"P_CC_CLAIM_LINES_ITEM\":[{\"TITLE\":null,\"FIRST_NAME\":\"Test\",\"LAST_NAME\":\"Contactq\",\"CLAIM_NO\":\"RXXXXXX\",\"STATUS\":\"SUCCESS\",\"ERROR_CODE\":null,\"STATUS_MESSAGES\":null}]},\"OUT_RESULT\":{\"CC_BATCH_NAME\":\"CC:20240827122054:2024-08-27:12:16:16\",\"EXCEPTIONTYPE\":\"SUCCESS\",\"ERRORMESSAGE\":null}}';
        resParams = QCC_EQResponseWrapper.parse(resBody);
        resParams.P_CC_CLAIM_LINES.P_CC_CLAIM_LINES_ITEM[0].CLAIM_NO = recvyList[0].Name;
        Test.setMock(HttpCalloutMock.class, new QCC_InvokeEQAPIMock(200, JSON.serialize(resParams)));
        QCC_InvokeEQAPI.invokeProcessRecoveries(requestEQ);
        Test.stopTest();
    }
    
    @isTest   
    static void testEQAPIEFTFail() {
        QCC_EQResponseWrapper resParams = new QCC_EQResponseWrapper();
        Test.startTest();
        /* Due to real time existing code issue - Too many SOQL queries: 101 the below code is added inside Test.start/stop methods */
        Id recvyEFTRecTypeId = GenericUtils.getObjectRecordTypeId('Recovery__c', CustomSettingsUtilities.getConfigDataMap('QCC Recovery EFT RecType'));
        List<Recovery__c> recvyList = [Select Id, Name, type__c, Original_Currency__c, Invoice_Claim_Description__c, payment_Details_added_manually__c, Original_Currency_Acronym__c, Value__c,Recovery_Reason__c,
                                Monetary_Value__c, Refund_Cost_Centre_Number__c, Refund_Account_Number__c, Case_Number__r.Contact.Salutation, Country_Code__c,
                                Case_Number__r.First_Name__c,  Case_Number__r.Last_Name__c, Case_Number__r.Contact.FirstName, Case_Number__r.Contact.LastName, Bank_Name__c, Branch_Name__c, Branch_Number_BSB_Sort_Code__c,
                                Branch_Swift_BIC_Code__c, Branch_Party_Id__c, Bank_Account_Name__c, Bank_Account_Number__c, IBAN__c, TAX_Id_VAT_Reg_No__c,
                                Account_Type__c from Recovery__c where  Process_Status__c =: CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng') and 
                                RecordTypeId =: recvyEFTRecTypeId order by Value__c, Name asc];

        //prepare json
        QCC_EQRequestWrapper requestEQ = QCC_EQCalloutsQueuable.preparePayload(recvyList);
        String resBody = '{\"P_CC_CLAIM_HEADER\":{\"UNIQUE_SOURCE_CALL_SEQ\":20240703164605,\"EMAIL\":\"shr_ccreq@qantas.com.au\",\"PHONE_EXT\":913234,\"PREPARED_BY\":171323},\"P_CC_CLAIM_LINES\":{\"P_CC_CLAIM_LINES_ITEM\":[{\"TITLE\":null,\"FIRST_NAME\":\"test\",\"LAST_NAME\":\"EFTEmailtemplate\",\"CLAIM_NO\":\"R01030985\",\"STATUS\":\"FAIL\",\"ERROR_CODE\":null,\"STATUS_MESSAGES\":\"InvalidBankBranchselected.PleaseselecttheBankBranchinfofromtheLOV\"}]},\"OUT_RESULT\":{\"CC_BATCH_NAME\":null,\"EXCEPTIONTYPE\":\"ERROR\",\"ERRORMESSAGE\":\"Noclaimlinescouldbeprocessed,Pleasereviewtheindvidualerrormessages\"}}';
        resParams = QCC_EQResponseWrapper.parse(resBody);
        resParams.P_CC_CLAIM_LINES.P_CC_CLAIM_LINES_ITEM[0].CLAIM_NO = recvyList[0].Name;
        Test.setMock(HttpCalloutMock.class, new QCC_InvokeEQAPIMock(200, JSON.serialize(resParams)));
        QCC_InvokeEQAPI.invokeProcessRecoveries(requestEQ);
        Test.stopTest();
    }
    
    @isTest   
    static void testEQAPIFail() {
        QCC_EQResponseWrapper resParams = new QCC_EQResponseWrapper();
        Test.startTest();
        /* Due to real time existing code issue - Too many SOQL queries: 101 the below code is added inside Test.start/stop methods */
        Id recvyEFTRecTypeId = GenericUtils.getObjectRecordTypeId('Recovery__c', CustomSettingsUtilities.getConfigDataMap('QCC Recovery EFT RecType'));
        List<Recovery__c> recvyList = [Select Id, Name, type__c, Original_Currency__c, Invoice_Claim_Description__c, payment_Details_added_manually__c, Original_Currency_Acronym__c, Value__c,Recovery_Reason__c,
                                Monetary_Value__c, Refund_Cost_Centre_Number__c, Refund_Account_Number__c, Case_Number__r.Contact.Salutation, Country_Code__c,
                                Case_Number__r.First_Name__c,  Case_Number__r.Last_Name__c, Case_Number__r.Contact.FirstName, Case_Number__r.Contact.LastName, Bank_Name__c, Branch_Name__c, Branch_Number_BSB_Sort_Code__c,
                                Branch_Swift_BIC_Code__c, Branch_Party_Id__c, Bank_Account_Name__c, Bank_Account_Number__c, IBAN__c, TAX_Id_VAT_Reg_No__c,
                                Account_Type__c from Recovery__c where  Process_Status__c =: CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng') and 
                                RecordTypeId =: recvyEFTRecTypeId order by Value__c, Name asc];

        //prepare json
        QCC_EQRequestWrapper requestEQ = QCC_EQCalloutsQueuable.preparePayload(recvyList);
        String resBody = '{\"P_CC_CLAIM_HEADER\":{\"UNIQUE_SOURCE_CALL_SEQ\":20240827122054,\"EMAIL\":\"shr_ccreq@qantas.com.au\",\"PHONE_EXT\":913234,\"PREPARED_BY\":171323},\"P_CC_CLAIM_LINES\":{\"P_CC_CLAIM_LINES_ITEM\":[{\"TITLE\":null,\"FIRST_NAME\":\"Test\",\"LAST_NAME\":\"Contactq\",\"CLAIM_NO\":\"RXXXXXX\",\"STATUS\":\"SUCCESS\",\"ERROR_CODE\":null,\"STATUS_MESSAGES\":null}]},\"OUT_RESULT\":{\"CC_BATCH_NAME\":\"CC:20240827122054:2024-08-27:12:16:16\",\"EXCEPTIONTYPE\":\"SUCCESS\",\"ERRORMESSAGE\":null}}';
        resParams = QCC_EQResponseWrapper.parse(resBody);
        resParams.P_CC_CLAIM_LINES.P_CC_CLAIM_LINES_ITEM[0].CLAIM_NO = recvyList[0].Name;
        Test.setMock(HttpCalloutMock.class, new QCC_InvokeEQAPIMock(500, JSON.serialize(resParams)));
        QCC_InvokeEQAPI.invokeProcessRecoveries(requestEQ);
        Test.stopTest();
    }
}