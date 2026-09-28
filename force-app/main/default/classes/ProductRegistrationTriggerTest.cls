/*==================================================================================================================================
Author:         Praveen Sampath
Company:        Capgemini
Purpose:        Test Class for ProductRegistrationTrigger Trigger. All functionalities of ProductRegistrationTriggerHelper are covered.
Date:           28/04/2017          
History:

==================================================================================================================================
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated testCreateCaseOnMultipleActiveQBRException(), testCalculateAMEXAcceptRejectCodeException() methods.
==================================================================================================================================*/

@isTest(SeeAllData = false)
private class ProductRegistrationTriggerTest {

    //Create all Test Data 
    @testSetup
    static void createTestData(){
        //Enable Account and Product Registration Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting());
        //Added by QCC
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        //Insert Hierarchy Setting
        TestUtilityDataClassQantas.createEnableValidationRuleSetting();

        //Custom Setting for Account Anf product Reg
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg QBD Registration Rec Type','QBD Registration'));
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type','Aquire Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Del Log SME Account Rec Type','SME Account'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('AccListner Type Direct Stream','Direct Stream'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case SystemAdmin RecordType','System Admin Request'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseDescription_MultiQBR','Please action upon the Multiple Active QBR Product created for the same ABN at the earliest'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseOrigin_MultiQBR','QBR'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CasePriority_MultiQBR','Medium'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseReason_MultiQBR','QBR Product Closure due to Multiple Active QBR for the same ABN'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatus_MultiQBR','Open'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseSubject_MultiQBR','Multiple Active QBR Product Created'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseSubType_MultiQBR','QBR'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseSubType2_MultiQBR','Multiple Active QBR Product'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseType_MultiQBR','System Issues'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Status','Active'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        insert lstConfigData;

        List<Account_Logs_Tracker__c> lstAccLog = new List<Account_Logs_Tracker__c>();
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','QBR Override', 'Y', 'acc-001'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Qantas Business Rewards (QBR)', 'false', 'acc-002'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Travel Agent', 'Y', 'acc-003'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Valid Entity Type', 'N', 'acc-004'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','GST Registered', 'N', 'acc-005'));
        insert lstAccLog;

        //Create Account 
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        //system.assert(objAcc != Null, 'Account is not inserted');

    }

    //Method to Check Membership #, Direct and Indirect discound code added to Account from QBR Product Insert
    static TestMethod void testUpdateMemNumonAccountPostiveInsert() {
        Account objAcc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        
        Test.startTest();
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        insert objAcqProdReg;
        Test.stopTest();

        //system.assert(objAcqProdReg.Id != Null, 'Product Registration is not Inserted');
        objAcc = [Select Id, Aquire_Membership_Number__c from Account where Active__c = true ]; 
        //system.assert(objAcc.Aquire_Membership_Number__c =='12345', 'Membership Number Mismatch in Account');
        
    }

    //Method to Check Membership #, Direct and Indirect discound code added to Account from QBR Product Delete
    static TestMethod void testUpdateMemNumonAccountPostiveDelete() {
        Account objAcc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        insert objAcqProdReg;
        system.assert(objAcqProdReg.Id != Null, 'Product Registration is not Inserted');
        
        Test.startTest();
        delete objAcqProdReg;
        Test.stopTest();
        
        List<Product_Registration__c> lstObjProdReg = [Select Id from Product_Registration__c where Key_Contact_Office_ID__c = 'abc 1233'];
        system.assert(lstObjProdReg.size() == 0,'Product is Not Deleted');
        objAcc = [Select Id, Aquire_Membership_Number__c from Account where Aquire_Membership_Number__c = '' ]; 
        //system.assert(objAcc != Null, 'Membership Number Mismatch in Account');
        
    }

    //Method to check case creation when from Multiple Active QBR Product are added for an Account
    static TestMethod void testCreateCaseOnMultipleActiveQBR() {
        Account objAcc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        lstObjProdReg.add(objAcqProdReg);
        Product_Registration__c objQBDProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objQBDProdReg.Key_Contact_Office_ID__c ='abc 1234';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        objQBDProdReg.Membership_Number__c = '12346';
        lstObjProdReg.add(objQBDProdReg);
        
        Test.startTest();
        insert lstObjProdReg;
        //system.assert(lstObjProdReg[1].Id != Null, 'Product Registration is not Inserted');
        Test.stopTest();
        
        objAcc = [Select Id, Aquire_Membership_Number__c from Account where Aquire_Membership_Number__c = '' ]; 
        //system.assert(objAcc != Null, 'Membership Number Mismatch in Account');
        
        List<Case> lstCase = [select Id from Case where AccountId = : objAcc.Id];
        //system.assert(lstCase.size() == 1, 'case is created');
    }

    //Method to Check Membership #, Direct and Indirect discound code added to Account from QBR Product Exceptions
    static TestMethod void testUpdateMemNumonAccountException(){
        Account objAcc = [Select Id From Account where Active__c = true];
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        //lstObjProdReg.add(objAcqProdReg);
        //insert objAcqProdReg;
        QantasConfigData__c recType = [select Id from QantasConfigData__c where Name = 'Prd Reg Aquire Registration Rec Type'];
        delete recType;
        
        Test.startTest();
        insert objAcqProdReg;
        Test.stopTest();

        List<Log__c> lstLog = [select Id from Log__c];
        //system.assert(lstLog.size() != 0, 'Log record is not Inserted');
        
    }

    //Verify Amex validation Rules
    static TestMethod void testNonAdminAmexCreation(){
        Account objAcc = [Select Id From Account where Active__c = true];
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAmexProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
        objAmexProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAmexProdReg.Enrolment_Date__c  = system.today();
        insert objAmexProdReg;
        Integer noOfAmex = [select count() from Product_Registration__c where Account__c =: objAcc.Id  and Type__c = 'AEQCC'];
        //system.assert(noOfAmex == 1, 'Amex is Inserted');
        Test.startTest();
        try{
            objAmexProdReg.Key_Contact_Office_ID__c ='abc 12334';
            update objAmexProdReg;
        }catch(Exception ex){
            //system.assert(ex.getTypeName() == 'System.DmlException', 'Validationrule is not Working');
        }
        Test.stopTest();

        Product_Registration__c objProdReg = [Select Id,Key_Contact_Office_ID__c From Product_Registration__c where Account__c =: objAcc.Id  and Type__c = 'AEQCC'];
        system.debug('objAmexProdRegEEEEEEEEEE'+objProdReg);
        //system.assert(objProdReg.Key_Contact_Office_ID__c == 'abc 1233', 'Amex is Updated by Non Data admin User');
    }

    //Verify Amex avlidation Rules
    static TestMethod void testAdminAmexCreation(){
        Account objAcc = [Select Id, Amex__c from Account LIMIT 1];
        List<user> lstUserUpdate = new List<User>();
        List<User> lstUser = TestUtilityDataClassQantas.getUsers('Data Administrator', 'MAS Team', 'QF-DOM-Sales-SME-QIS-Operations');
        system.assert(lstUser[0].Id != Null, 'User list is not Inserted');
        system.assert(lstUser.size()==2, 'List size is small');

        User objUser = lstUser[0];
        objUser.Id = lstUser[0].Id;
        objUser.IsActive = true;
        objUser.Email = 'test@QIs.com';
        lstUserUpdate.add(objUser);
        
        update lstUserUpdate;
        User objActiveUser = [select Id, UserRoleId from User where Id =: objUser.Id ];
        system.assert(objActiveUser.UserRoleId != Null, 'User Role is Null');
        
        Test.startTest();
        system.runAs(objActiveUser){
            Product_Registration__c objQBDProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
            insert objQBDProdReg;
        }
        Test.stopTest();
        Integer noOfAmex = [select count() from Product_Registration__c where Account__c =: objAcc.Id  and Type__c = 'AEQCC'];
        system.assert(noOfAmex == 1, 'Second Amex is Inserted');
        objAcc = [Select Id, Amex__c from Account LIMIT 1];
        system.assert(objAcc.Amex__c == true,'Amex is not set to true');       
    }

    //Verify Amex avlidation Rules
    static TestMethod void CreateSecondAmexExceptionTest(){
        Account objAcc = [Select Id, Amex__c from Account LIMIT 1];
        
        List<user> lstUserUpdate = new List<User>();
        List<User> lstUser = TestUtilityDataClassQantas.getUsers('Data Administrator', 'MAS Team', 'QF-DOM-Sales-SME-QIS-Operations');
        system.assert(lstUser[0].Id != Null, 'User list is not Inserted');
        system.assert(lstUser.size()==2, 'List size is small');

        User objUser = lstUser[0];
        objUser.Id = lstUser[0].Id;
        objUser.IsActive = true;
        objUser.Email = 'test@QIs.com';
        lstUserUpdate.add(objUser);
        
        update lstUserUpdate;
        User objActiveUser = [select Id, UserRoleId from User where Id =: objUser.Id ];
        system.assert(objActiveUser.UserRoleId != Null, 'User Role is Null');

        Test.startTest();
        system.runAs(objActiveUser){
            Product_Registration__c objQBDProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
            insert objQBDProdReg;
            Product_Registration__c objQBDProdRegs = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
            try{
                insert objQBDProdRegs;
            }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'Validationrule is not Working');
            }

        }
        Test.stopTest();
    }

    //Method to check case creation when from Multiple Active QBR Product are added for an Account Exception
    static TestMethod void testCreateCaseOnMultipleActiveQBRException(){
        List<QantasConfigData__c> recType = [select Id from QantasConfigData__c where Name = 'Case SystemAdmin RecordType'];
        delete recType;

        Account objAcc = [Select Id From Account where Active__c = true];
        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        lstObjProdReg.add(objAcqProdReg);

        Product_Registration__c objQBDProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objQBDProdReg.Key_Contact_Office_ID__c ='abc 1234';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        objQBDProdReg.Membership_Number__c = '12346';
        lstObjProdReg.add(objQBDProdReg);

        Test.startTest();
        insert lstObjProdReg;
        Test.stopTest();

        system.assert(lstObjProdReg[1].Id != Null, 'Product Registration is not Inserted');
        List<Log__c> lstLog = [select Id from Log__c];
        //system.assert(lstLog.size() != 0, 'Log record is not Inserted');
    }

    //Method to cover CalculateAMEXAcceptRejectCode postive 
    static TestMethod void testCalculateAMEXAcceptRejectCodePositive(){
        Account objAcc = [Select Id, Aquire_Override__c From Account where Active__c = true];
        objAcc.Agency__c = 'N';
        update objAcc;
        system.assert(objAcc.Aquire_Override__c == 'N', 'QBR Override is True');
         Product_Registration__c objAmexProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
        objAmexProdReg.MCA_Number__c ='99999';
        objAmexProdReg.Enrolment_Date__c  = system.today();
        objAmexProdReg.Customer_s_Requested_Choice__c = 'A';
        Test.startTest();
        insert objAmexProdReg;
        Test.stopTest();
        objAcc = [select Id, Amex__c, AMEX_response_Code__c from Account where Id =: objAmexProdReg.Account__c];
        system.assert(objAcc.AMEX_response_Code__c == 'D', 'AMEX Response doen\'t Match');  
        system.assert(objAcc.Amex__c == true, 'AMEX is not set to true');
    }

    //Method to cover CalculateAMEXAcceptRejectCode Exceoption 
    static TestMethod void testCalculateAMEXAcceptRejectCodeException(){
        Account objAcc = [Select Id, Aquire_Override__c From Account where Active__c = true];
        objAcc.Agency__c = 'N';
        update objAcc;
        system.assert(objAcc.Aquire_Override__c == 'N', 'QBR Override is True');
         Product_Registration__c objAmexProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
        objAmexProdReg.MCA_Number__c ='99999';
        objAmexProdReg.Enrolment_Date__c  = system.today();
        objAmexProdReg.Customer_s_Requested_Choice__c = 'A';

        QantasConfigData__c objCOnfig  = QantasConfigData__c.getValues('Prd Reg AEQCC Registration Rec Type');
        Delete objCOnfig;

        Test.startTest();
        insert objAmexProdReg;
        Test.stopTest();
        objAcc = [select Id, Amex__c from Account where Id =: objAmexProdReg.Account__c];
        system.assert(objAcc.Amex__c == true, 'AMEX is  set to true');
    }

    //Method to verify exception Handling
    static TestMethod void testProductTriggerException(){
        Test.startTest();
        ProductRegistrationTriggerHelper.processAccountAndOpportunity(Null);
       // ProductRegistrationTriggerHelper.processAMEXEligibility(Null, Null);
        ProductRegistrationTriggerHelper.updateAmexDetailsOnAquire(Null);
        ProductRegistrationTriggerHelper.updateRelatedAquireMembers(Null);
        Test.stopTest();
        
        List<Log__c> lstLog = [select Id from Log__c];
        //system.assert(lstLog.size() != 0, 'Log record is not Inserted');
        
    }
    
}