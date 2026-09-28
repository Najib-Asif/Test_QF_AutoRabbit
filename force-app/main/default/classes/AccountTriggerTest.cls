/*==================================================================================================================================
Author:         Praveen Sampath
Company:        Capgemini
Purpose:        Test Class for Account Trigger
Date:           19/12/2016          
History:
Test
==================================================================================================================================

==================================================================================================================================*/

@isTest(SeeAllData = false)
private class AccountTriggerTest { 
    
    @testSetup
    static void createTestData(){

        List<QBD_Online_Office_ID__c> lstQBDOff = TestUtilityDataClassQantas.createQBDOnlineOfficeId();
        system.assert(lstQBDOff.size() != 0, 'QBD_Online_Office_ID__c List is empty');
        insert lstQBDOff;

        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting());
        Trigger_Status__c ownerUpdate = new Trigger_Status__c();
        ownerUpdate.Name = 'AgencyAccountOwnerUpdate';
        ownerUpdate.Active__c = true;
        lsttrgStatus.add(ownerUpdate);
       // lsttrgStatus.addAll(TestUtilityDataClassQantas.createAccountTriggerSettingasTrue());
        insert lsttrgStatus;

           /*Freight changes - Start*/      
                
        List<Freight_RecordTypeSeggregation__c> lstfreCusSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();       
        insert lstfreCusSetting;        
                
        /*Freight changes - End*/

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg QBD Registration Rec Type','QBD Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type','Aquire Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Del Log SME Account Rec Type','SME Account'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('AccListner Type Direct Stream','Direct Stream'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Case SystemAdmin RecordType','System Admin Request'));
        insert lstConfigData;

        List<Account_Logs_Tracker__c> lstAccLog = new List<Account_Logs_Tracker__c>();
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','QBR Override', 'Y', 'acc-001'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Qantas Business Rewards (QBR)', 'false', 'acc-002'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Travel Agent', 'Y', 'acc-003'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Valid Entity Type', 'N', 'acc-004'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','GST Registered', 'N', 'acc-005'));
        insert lstAccLog;

        List<Account> lstAcc = TestUtilityDataClassQantas.getAccounts();
        system.assert(lstAcc.size() != 0, 'Account List is zero');
        Account objAcc = lstAcc[0];
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        objAcc.Type = 'Customer Account';
        update objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');
        List<Log__c> lstLog = [select Id,Error_Message__c    from Log__c where Class_Name__c = 'AccountTriggerHelper'];
        system.debug('lstLog########'+lstLog);
        //system.assert(lstLog == null,'Error is '+lstLog[0].Error_Message__c);


        List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
        Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
        objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
        objAcqProdReg.Enrolment_Date__c  = system.today();
        lstObjProdReg.add(objAcqProdReg);
        
        Product_Registration__c objQBDProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'QBD Registration');
        objQBDProdReg.Key_Contact_Office_ID__c ='abc 1234';
        lstObjProdReg.add(objQBDProdReg);
        insert lstObjProdReg;
        system.assert(lstObjProdReg != Null , 'Product Registration is not Inserted');
        List<Log__c> lstLogs = [select Id,Error_Message__c from Log__c where Class_Name__c = 'AccountTriggerHelper'];
        system.debug('lstLog11111########'+lstLogs);
        
        Account_Eligibility_Log__c AEL = new Account_Eligibility_Log__c();
        AEL.Account__c = objAcc.Id;
        insert AEL;
   /* }
    Apex test class should not have multiple TestSetup method 
    @testSetup
    static void createTestUser(){*/
        List<user> lstUserUpdate = new List<User>();
        List<User> lstUser = TestUtilityDataClassQantas.getUsers('System Administrator', 'MAS Team', 'QF-DOM-Sales-SME-QIS-Operations');
        system.assert(lstUser[0].Id != Null, 'User list is not Inserted');
      	 system.assert(lstUser.size()==2, 'List size is small');

        User objUser = lstUser[0];
        objUser.Id = lstUser[0].Id;
        objUser.IsActive = true;
        objUser.Email = 'test@QIs.com';
        lstUserUpdate.add(objUser);
        
        User objUser1 = lstUser[1];
        objUser1.Id = lstUser[1].Id;
        objUser1.IsActive = true;
        objUser1.Email = 'test@nonQIs.com';
        objUser1.UserRoleId = Null;
        lstUserUpdate.add(objUser1);
		 system.runAs(new User (ID = userInfo.getUserId())){
             update lstUserUpdate;
         }
        
        User objActiveUser = [select Id, UserRoleId from User where Id =: objUser.Id ];
        system.assert(objActiveUser.UserRoleId != Null, 'User Role is Null');

        User objActiveUser1 = [select Id, UserRoleId from User where Id =: objUser1.Id ];
       system.assert(objActiveUser1.UserRoleId == Null, 'User Role is Null');
    }

    static TestMethod void insertAccount(){
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        Account acc = new Account();
        acc.BillingCountryCode='CN';
        acc.Name='Test';
        acc.recordtypeId=accRTId;
        insert acc;
    }
    static TestMethod void updateDiscountCodeOnProductsUpdateAirlineTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;


        Test.startTest();
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id from Account where Id =: objProdReg.Account__c];
        objAcc.Airline_Level__c = '2';
        update objAcc;

        objAcc.Airline_Level__c = '1';
        update objAcc;

        objAcc.Airline_Level__c = '3';
        update objAcc;
        Test.stopTest();
    }

    static TestMethod void updateDiscountCodeOnProductsOnAcquireDeletTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;

        Test.startTest();
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c where
                                               Recordtype.Name = 'Aquire Registration' limit 1];
        objProdReg.Active__c = false;
        objProdReg.Stage_Status__c ='';
        update objProdReg;
        Test.stopTest();
    }

    static TestMethod void updateDiscountCodeOnProductsInActiveAccTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;

        Test.startTest();
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id from Account where Id =: objProdReg.Account__c];
        objAcc.Active__c = false;
        update objAcc;
        Test.stopTest();
    }

    static TestMethod void updateDiscountCodeOnProductsBlankAirlineTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;


        Test.startTest();
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id from Account where Id =: objProdReg.Account__c];
        objAcc.Airline_Level__c = '';
        update objAcc;
        Test.stopTest();
    }

    static TestMethod void createAccountEligiblityLogsTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountEligibilityLogTrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;

        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id from Account where Id =: objProdReg.Account__c];
        
        Test.startTest();
        objAcc.Industry = 'Travel';
        update objAcc;

        Account_Eligibility_Log__c accLogs = [select Name from Account_Eligibility_Log__c where 
                                              Account__c =: objAcc.Id limit 1];
        system.assert(accLogs != Null, 'Account Eligiblity Logs are not created');


        objAcc.Aquire_Override__c = 'Y';
        objAcc.Aquire_Override_End_Date__c = system.today().addDays(2);
        update objAcc;
        
        Account_Eligibility_Log__c AEL = new Account_Eligibility_Log__c();
        AEL.Account__c = objAcc.Id;
        AEL.Reason__c = 'test';
        insert AEL;

        Account_Eligibility_Log__c accLogs2 = [select Name, Reason__c from Account_Eligibility_Log__c where 
                                              Account__c =: objAcc.Id and Reason__c != '' limit 1];
        system.assert(accLogs2 != Null, 'Account Eligiblity Logs are not created');

        objAcc.Aquire_Override__c = 'N';
        objAcc.Industry = '';
        update objAcc;
        Test.stopTest();

        List<Account_Eligibility_Log__c> lstAccLogs = [select Name, Reason__c from Account_Eligibility_Log__c where 
                                                       Account__c =: objAcc.Id limit 1];
        system.assert(lstAccLogs.size()== 1, 'Account Eligiblity Logs are not Deleted');

    }

    static TestMethod void createAccountEligiblityLogsOnValidEntityUpdateTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountEligibilityLogTrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;

        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id from Account where Id =: objProdReg.Account__c];
        objAcc.GST_Registered__c = 'N';
        objAcc.Aquire_Entity_Type__c = 'Australian Public Company';
        update objAcc;

        Test.startTest();
        objAcc.Aquire_Entity_Type__c = 'Indian pvt Ltd';
        update objAcc;
        Account accUpdated = [select Id, Aquire_Eligibility_f__c from Account where Id =: objAcc.Id];
        system.assert(accUpdated.Aquire_Eligibility_f__c == 'N', 'Account is Eligiblity');

        Account_Eligibility_Log__c accLogs = [select Name from Account_Eligibility_Log__c where 
                                              Account__c =: objAcc.Id limit 1];
        system.assert(accLogs != Null, 'Account Eligiblity Logs are not created');
        Test.stopTest();
        objAcc.Aquire_Entity_Type__c = '';
        update objAcc;
        Account acc = [select Id, Aquire_Eligibility_f__c from Account where Id =: objAcc.Id];
        system.assert(acc.Aquire_Eligibility_f__c == 'Y', 'Account is Eligiblity');
    }

    static TestMethod void createAccountEligiblityLogsOnGSTUpdateTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountEligibilityLogTrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;

        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id from Account where Id =: objProdReg.Account__c];
        objAcc.Aquire_Entity_Type__c = 'Indian pvt Ltd';
        update objAcc;

        Test.startTest();
        objAcc.GST_Registered__c = 'N';
        update objAcc;
        Account accUpdated = [select Id, Aquire_Eligibility_f__c from Account where Id =: objAcc.Id];
        
        system.assert(accUpdated.Aquire_Eligibility_f__c == 'N', 'Account is Eligiblity');

        Account_Eligibility_Log__c accLogs = [select Name from Account_Eligibility_Log__c where 
                                              Account__c =: objAcc.Id limit 1];
        system.assert(accLogs != Null, 'Account Eligiblity Logs are not created');
        Test.stopTest();
        objAcc.GST_Registered__c = 'Y';
        update objAcc;
        Account acc = [select Id, Aquire_Eligibility_f__c from Account where Id =: objAcc.Id];
        system.assert(acc.Aquire_Eligibility_f__c == 'Y', 'Account is Eligiblity');
    }

    static TestMethod void updateAccountEligiblityLogsTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountEligibilityLogTrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;

        
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id from Account where Id =: objProdReg.Account__c];
        
        Test.startTest();
        objAcc.Industry = 'Travel';
        update objAcc;

        for(Account_Eligibility_Log__c accLogs: [select Name from Account_Eligibility_Log__c where 
                                                 Account__c =: objAcc.Id])
        {
            accLogs.StartDate__c = system.today().addDays(-3);
            update accLogs;
        }

        objAcc.Aquire_Override__c = 'Y';
        objAcc.Aquire_Override_End_Date__c = system.today().addDays(2);
        update objAcc;

        for(Account_Eligibility_Log__c accLogs: [select Name from Account_Eligibility_Log__c where 
                                                 Account__c =: objAcc.Id])
        {
            accLogs.StartDate__c = system.today().addDays(-3);
            update accLogs;
        }

        objAcc.Aquire_Override__c = 'N';
        objAcc.Industry = '';
        update objAcc;

        List<Account_Eligibility_Log__c> lstAccLogs = [select Name, Reason__c from Account_Eligibility_Log__c where 
                                                       Account__c =: objAcc.Id limit 1];
        system.assert(lstAccLogs.size()!= 0, 'Account Eligiblity Logs are not Deleted');
        Test.stopTest();
    }

    static TestMethod void updateDiscountCodeOnProductsUpdateSMEDealTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;
        
        User objUser = [select Id, UserRoleId from user where Email = 'test@QIs.com' and IsActive =: true];
        system.assert(objUser.UserRoleId != Null, 'User created with no Role');
        
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        
        Test.startTest();
        Account objAcc = [select Id, Airline_Level__c from Account where Id =: objProdReg.Account__c];
        objAcc.Airline_Level__c = '4';
        objAcc.OwnerId = objUser.Id;
        objAcc.Contracted__c = true;
        update objAcc;
        Test.stopTest();
        Account objAccUpdate = [select Airline_Level__c, SME_Deal__c, Contracted__c, Owner.UserRoleId
                                from Account where Id =: objAcc.Id];
        system.assert(objAccUpdate.Owner.UserRoleId != Null, 'Role is Null');
        system.assert(objAccUpdate.Contracted__c == true, 'Contracted is not Set to true');
        system.assert(objAccUpdate.Airline_Level__c == '4', 'Airline Level is not set to 4');
        system.assert(objAccUpdate.SME_Deal__c == true, 'SME Deal is not Set to true');
        
    }

    static TestMethod void updateDiscountCodeOnProductsUpdateCorporateDealTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;

        User objUser = [select Id, UserRoleId from user where Email = 'test@nonQIs.com' and IsActive =: true];
        system.assert(objUser.UserRoleId == Null, 'User created with Role');
        
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        
        Test.startTest();
        Account objAcc = [select Id, Airline_Level__c from Account where Id =: objProdReg.Account__c];
        objAcc.Airline_Level__c = '4';
        objAcc.OwnerId = objUser.Id;
        objAcc.Contracted__c = true;
        objAcc.Dealing_Flag__c='Y';
        update objAcc;
        Test.stopTest();

        Account objAccUpdate = [select Airline_Level__c, Dealing_Flag__c, Contracted__c, Owner.UserRoleId
                                from Account where Id =: objAcc.Id];
        system.assert(objAccUpdate.Dealing_Flag__c == 'Y', 'Dealing Flag is not Set to true');
    }

    static TestMethod void updateDiscountCodeOnProductsUpdateAirlineEligiblityTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;
        
        User objUser = [select Id, UserRoleId from user where Email = 'test@QIs.com' and IsActive =: true];
        system.assert(objUser.UserRoleId != Null, 'User created with no Role');
        
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        
        Test.startTest();
        Account objAcc = [select Id, Airline_Level__c from Account where Id =: objProdReg.Account__c];
        objAcc.Airline_Level__c = '4';
        objAcc.OwnerId = objUser.Id;
        objAcc.Contracted__c = true;
        objAcc.Industry = 'Travel';
        objAcc.Contract_Expiry_Date__c = system.today();
        update objAcc;
        Test.stopTest();
        Account objAccUpdate = [select Airline_Level__c, SME_Deal__c, Contracted__c, Aquire_Eligibility_f__c
                                from Account where Id =: objAcc.Id];
        system.assert(objAccUpdate.Aquire_Eligibility_f__c == 'N', 'Airline is Eligible');
        system.assert(objAccUpdate.SME_Deal__c == true, 'SME Deal is not Set to true');
        
    }

    static TestMethod void updateDisCodeOnProductsUpdateAirlineEligiblityTest(){
        List<Trigger_Status__c> lstAccountEligibilityLogTrigger = new List<Trigger_Status__c>();
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountAirlineLeveltrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        lstAccountEligibilityLogTrigger.add(AccountEligibilityLogTrigger);
        update lstAccountEligibilityLogTrigger;
        
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        
        Test.startTest();
        Account objAcc = [select Id, Airline_Level__c from Account where Id =: objProdReg.Account__c];
        objAcc.Airline_Level__c = '4';
        objAcc.Industry = 'Travel';
        update objAcc;
        Test.stopTest();
        Account objAccUpdate = [select Airline_Level__c, SME_Deal__c, Contracted__c, Aquire_Eligibility_f__c
                                from Account where Id =: objAcc.Id];
        system.assert(objAccUpdate.Aquire_Eligibility_f__c == 'N', 'Airline is Eligible');      
    }

    static TestMethod void deleteAccountPostiveTest(){
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountDeleteTrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        update AccountEligibilityLogTrigger;
        
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id, Airline_Level__c from Account where Id =: objProdReg.Account__c];
        
        Test.startTest();
        Delete objAcc;
        
        Id rectypeId = GenericUtils.getObjectRecordTypeId('Delete_Tracker_Log__c', CustomSettingsUtilities.getConfigDataMap('Del Log SME Account Rec Type'));
        Delete_Tracker_Log__c dtl = new Delete_Tracker_Log__c();
        dtl.RecordTypeId = rectypeId;
        insert dtl;
        List<Delete_Tracker_Log__c> objDelLog = [Select Id from Delete_Tracker_Log__c where RecordtypeId =: rectypeId LIMIT 1];
        system.assert(objDelLog != Null,'Delete Log records are not inserted');
        Test.stopTest();
    }

    static TestMethod void deleteAccountExceptionTest(){
        Trigger_Status__c AccountEligibilityLogTrigger = Trigger_Status__c.getValues('AccountDeleteTrigger');
        AccountEligibilityLogTrigger.Active__c = true;
        update AccountEligibilityLogTrigger;
        
        QantasConfigData__c objCOnfig  = QantasConfigData__c.getValues('Del Log SME Account Rec Type');
        Delete objCOnfig;
        
        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id, Airline_Level__c from Account where Id =: objProdReg.Account__c];
        objAcc.Listner_Type__c = CustomSettingsUtilities.getConfigDataMap('AccListner Type Direct Stream');
        update objAcc;
        
        Test.startTest();
        Delete objAcc;
        
        Log__c log = new Log__c();
        log.Class_Name__c = 'createDelAccountLogTracker';
        log.Method_Name__c = 'createDelAccountLogTracker';
        insert log;
        List<Log__c> objLog = [select Id from Log__c where Method_Name__c = 'createDelAccountLogTracker' LIMIT 1];
        system.assert(objLog != Null, 'Error log is not inserted');
        Test.stopTest();
    }
    
    static TestMethod void updateAccountDetailPostiveTest(){
        Trigger_Status__c AccountUpdateAccountDetail = Trigger_Status__c.getValues('AccountUpdateAccountDetail');
        AccountUpdateAccountDetail.Active__c = true;
        update AccountUpdateAccountDetail;

        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id, Airline_Level__c, Aquire_Override__c, AMEX_response_Code__c from Account where Id =: objProdReg.Account__c];
        objAcc.Agency__c = 'N';
        update objAcc;
        system.assert(objAcc.Aquire_Override__c == 'N', 'QBR Override is True');
        
        Product_Registration__c objAmexProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
        objAmexProdReg.MCA_Number__c ='99999';
        objAmexProdReg.Enrolment_Date__c  = system.today();
        objAmexProdReg.Customer_s_Requested_Choice__c = 'A';
        insert objAmexProdReg;
        objAmexProdReg = [select Id, Name, Customer_s_Requested_Choice__c from Product_Registration__c where 
                          Id =: objAmexProdReg.Id];
        system.assert(objAmexProdReg.Customer_s_Requested_Choice__c == 'A', 'Amex is not inserted');
        objAcc = [select Id, Airline_Level__c, Aquire_Override__c, AMEX_response_Code__c from Account where Id =: objProdReg.Account__c];
       // system.assert(objAcc.AMEX_response_Code__c == 'D', 'AMEX Response doesn\'t Match');              
        
        Test.startTest();
        objAcc.AMEX_response_Code__c = '';
        objAcc.Aquire_Override__c = 'Y';
        objAcc.Aquire_Override_End_Date__c = system.today().addDays(1);
        update objAcc;
        
        Test.stopTest(); 
        objAcc = [select Id, Airline_Level__c, Aquire_Override__c, AMEX_response_Code__c from Account where Id =: objProdReg.Account__c];
       // system.assert(objAcc.AMEX_response_Code__c == 'D', 'AMEX Response doesn\'t Match');              
    }

    static TestMethod void updateAccountDetailExceptionTest(){

        
        Trigger_Status__c AccountUpdateAccountDetail = Trigger_Status__c.getValues('AccountUpdateAccountDetail');
        AccountUpdateAccountDetail.Active__c = true;
        update AccountUpdateAccountDetail;

        Product_Registration__c objProdReg = [Select Id, Account__c from Product_Registration__c limit 1];
        Account objAcc = [select Id, Airline_Level__c, Aquire_Override__c from Account where Id =: objProdReg.Account__c];
        objAcc.Agency__c = 'N';
        //objAcc.AMEX_response_Code__c
        system.assert(objAcc.Aquire_Override__c == 'N', 'QBR Override is True');
        Product_Registration__c objAmexProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
        objAmexProdReg.MCA_Number__c ='99999';
        objAmexProdReg.Enrolment_Date__c  = system.today();
        objAmexProdReg.Customer_s_Requested_Choice__c = 'A';
        insert objAmexProdReg;
        QantasConfigData__c objCOnfig  = QantasConfigData__c.getValues('Prd Reg AEQCC Registration Rec Type');
        Delete objCOnfig;
        
        Test.startTest();
        objAcc.AMEX_response_Code__c = '';
        objAcc.Aquire_Override__c = 'Y';
        objAcc.Aquire_Override_End_Date__c = system.today().addDays(1);
        update objAcc;
        //system.assert();
        Test.stopTest();   
        objAcc = [select Id, Airline_Level__c, Aquire_Override__c, AMEX_response_Code__c from Account where Id =: objProdReg.Account__c];
        system.assert(objAcc.Aquire_Override__c == 'Y', 'QBR Override is Set to True');                
    }

    static TestMethod void accountTriggerExceptionTest(){
        Test.startTest();
        AccountTriggerHelper.createAccountEligiblityLogs(Null, Null);
        AccountTriggerHelper.calculateDiscountCode(Null, Null);
        AccountTriggerHelper.updateAccountTeam(Null, Null);
        List<Log__c> lstLog = [select Id from Log__c where Class_Name__c = 'AccountTriggerHelper'];
        system.assert(lstLog.size() == 3, 'Error log is not inserted');
        Test.stopTest();
    }
    
    
}