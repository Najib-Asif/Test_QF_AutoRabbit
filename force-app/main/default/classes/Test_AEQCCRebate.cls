@isTest 
public with sharing class Test_AEQCCRebate {
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
        
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();

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
        //lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;

        List<Account_Logs_Tracker__c> lstAccLog = new List<Account_Logs_Tracker__c>();
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','QBR Override', 'Y', 'acc-001'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Qantas Business Rewards (QBR)', 'false', 'acc-002'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Travel Agent', 'Y', 'acc-003'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','Valid Entity Type', 'N', 'acc-004'));
        lstAccLog.add(TestUtilityDataClassQantas.createAccountLogsTracker('Account','GST Registered', 'N', 'acc-005'));
        insert lstAccLog;

        //Create Account 
       /* Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');*/
    }
    @isTest      
    public static void Test_AEQCCRebate() {
    TestUtilityDataClassQantas.enableTriggers();
        
        String orgId = UserInfo.getOrganizationId();
        String sandboxName = UserInfo.getUserName().substringAfterLast('.au');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + randomInt;
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = uniqueName + '@test' + sandboxName + '.com'; 
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = uniqueName + '@test' + sandboxName + '.com'; 
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'Australia/Sydney';
        u.LocaleSidKey = 'en_AU';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
     system.runAs(u){ 
       String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
       Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true,Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
       insert acc;
        AEQCCRebate controller = new AEQCCRebate(new ApexPages.StandardController(new Product_Registration__c()));

        List<Product_Registration__c> Prodreglist = new List<Product_Registration__c>();
        List<AEQCC_Rebates__c> Reblist = New List<AEQCC_Rebates__c>();
        Product_Registration__c Pr = new Product_Registration__c(name = 'Test AEQCC REBATE',Account__c=acc.id);
        AEQCC_Rebates__c Aeqreb = new AEQCC_Rebates__c (Rebate_Year__c = '2015',Rebate_Tier__c ='2 %',Rebate_term__c='Jul-Dec',Rebate_Payment__c=753,Cheque_Amount__c=826.61,Rebate_Sent_to__c='Adam Simon Po Box 103 Port Melbourne Vic 3207',Prod_Reg_Link__c='a2cO00000013Djs');
        
        //Custom Setting
        TestUtilityDataClassQantas.getrelatedCustObjRecs1();
        
     try{
            Database.Insert(Pr);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }

    try{
            Database.Insert(Aeqreb);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }  
 
        AEQCCRebate controllerTest = new AEQCCRebate(new ApexPages.StandardController(pr));     
        controllerTest.getrelatedCustObjRecs1();
        Reblist.add(Aeqreb);
   }     
 }    
}