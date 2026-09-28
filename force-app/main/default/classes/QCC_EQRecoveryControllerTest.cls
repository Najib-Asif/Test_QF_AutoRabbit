@isTest
public class QCC_EQRecoveryControllerTest {
    static User u1;
    static Account objAcc;    

    @testSetup
	static void createTestData() {
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        Map<String, UserRole> rolesMap = TestUtilityDataClassQantas.getRoles();
        u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                      Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Team Lead').Id,
                      EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                      TimeZoneSidKey = 'Australia/Sydney', Location__c='Sydney', UserRoleId = rolesMap.get('QF-QDC-OM-MNL-TL').Id
                     );
        insert u1;
        
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

            system.debug('Recovery List is Zero'+lstRecovery.size());
            system.debug('Recovery is not inserted'+lstRecovery[0].Id );
        }	
	}
    
    @isTest   
    static void processEFTBatchRecordsTest1() {
        try {
			Test.startTest();
            /* Due to real time existing code issue - Too many SOQL queries: 101 the below code is added inside Test.start/stop methods */
            Id recvyEFTRecTypeId = GenericUtils.getObjectRecordTypeId('Recovery__c', CustomSettingsUtilities.getConfigDataMap('QCC Recovery EFT RecType'));
            List<Case> caseLst = [Select Id,ContactId from Case where Status = 'In Progress'];
            Recovery__c recvy = new Recovery__c();
            List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoverieswithRecType(caseLst, recvyEFTRecTypeId, 
                                            CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusQuedForPaymentPrcsng'),
                                            'Ticket Refund EFT');
            recvy.Id = lstRecovery[0].Id;
            recvy.Value__c = 9950;
            recvy.Monetary_Value__c = 9950;
            update recvy;
            QCC_EQRecoveryController.processEFTBatchRecords();
            Test.stopTest();
        } catch(Exception ex) {
            System.debug('Error occured: '+ex.getMessage());
        }        
    }
    
    @isTest
    static void processEFTBatchRecordsTest2() {
        try {
			Test.startTest();
            /* Due to real time existing code issue - Too many SOQL queries: 101 the below code is added inside Test.start/stop methods */
            Recovery__c rec = [Select Id, Value__c, Monetary_Value__c from Recovery__c Limit 1];
            rec.Value__c = 11000;
            rec.Monetary_Value__c = 11000;
            update rec;
            QCC_EQRecoveryController.processEFTBatchRecords();
            Test.stopTest();
        } catch(Exception ex) {
            System.debug('Error occured: '+ex.getMessage());
        }        
    }



}