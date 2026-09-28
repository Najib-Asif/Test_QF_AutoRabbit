/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated setUpData() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class PortfolioControllerTest {
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Opportunity> oppList = new List<Opportunity>();
        User admUsr = TestUtilityDataClassQantas.getUsers('System Administrator','B&G','')[0];
        User mgrUsr = TestUtilityDataClassQantas.getUsers('Sales and Distribution-Sales','SME','QF-DOM-Sales-SME-QIS-R&G-Account Manager2')[0];//RBAC SND - Profile Update
        User subUsr = TestUtilityDataClassQantas.getUsers('Sales and Distribution-Sales','SME','QF-DOM-Sales-SME-QIS-R&G-Account Manager2')[0];//RBAC SND - Profile Update
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        Trigger_Status__c ts1 = new Trigger_Status__c();
            ts1.Name = 'FeedItemTrgPreventChatterDeletion';
            ts1.Active__c = true;
            lsttrgStatus.add(ts1);
        Trigger_Status__c ts2 = new Trigger_Status__c();
            ts2.Name = 'FeedItemTrgUpdateEscalationTickBox';
            ts2.Active__c = true;
            lsttrgStatus.add(ts2);

        insert lsttrgStatus;
        
        System.runAs(admUsr) {
            
            Account testAcc = new Account();
            testAcc.Name = 'TestAccount';
            testAcc.Last_Completed_Account_Review__c = Date.today().addDays(-3);
            testAcc.Last_Activity_Created_Date__c = Date.today().addDays(-30);
            testAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            testAcc.BillingCountry = 'AU';
            testAcc.Contracted__c = true;
            insert testAcc;
            
            for(Integer i=0;i<3;i++){
                Opportunity opp = new Opportunity();
                opp.AccountId = testAcc.id;
                opp.Name = 'TestOpp'+i;
                opp.StageName = 'Contract';
                opp.Type = 'Business and Government';
                opp.Forecast_MCA_Revenue__c=20000;
                opp.CloseDate = Date.today().addDays(2);
                opp.Status_Last_Changed__c = Date.today().addDays(-10);
                opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business and Government').getRecordTypeId();
                oppList.add(opp);
            }
            insert oppList;
        }
    }
    
    @isTest static void fetchOpps(){
        
        String[] roleIds = new List<String>();
        User mgr = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts'][0];
        roleIds.add(mgr.id);
        User sub = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts-Manager'][0];
        roleIds.add(sub.id);
        List<User> usrSubList = PortfolioController.fetchRoleUsers(mgr.id);
        
        System.runAs(mgr) {
            Test.startTest();
            PortfolioController.fetchOpps(mgr.id, 'myPf', roleIds );
            PortfolioController.fetchOpps(mgr.id, 'myTeamPf', roleIds );
            Test.stopTest();
        }
    }
    
    @isTest static void fetchShareDecliningAccounts(){
        
        List<Snapshot__c> snpList = new List<Snapshot__c>();
        String[] roleIds = new List<String>();
        User mgr = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts'][0];
        roleIds.add(mgr.id);
        User sub = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts-Manager'][0];
        roleIds.add(sub.id);
        
        Account testAcc2 = new Account();
        testAcc2.Name = 'TestAccount2';
        testAcc2.Last_Completed_Account_Review__c = Date.today().addDays(-3);
        testAcc2.Last_Activity_Created_Date__c = Date.today().addDays(-30);
        testAcc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        testAcc2.BillingCountry = 'AU';
        testAcc2.Contracted__c = true;
        testAcc2.OwnerId = mgr.Id;
        insert testAcc2;  
        
        Risk__c rskRec = new Risk__c();
        rskRec.Account__c = testAcc2.id;
        rskRec.At_Risk_Since__c = Date.today().addDays(-3);
        rskRec.Active__c = true;
        insert rskRec;
        
        Snapshot__c thismonth = new Snapshot__c();
        thismonth.Name = 'Account Share Decline Snapshot';
        thismonth.Account__c = testAcc2.id;
        thismonth.Snapshot_Date__c = Date.today();
        thismonth.Total_Market_Share_YTD__c = 50.6;
        snpList.add(thismonth);
        Snapshot__c lastmonth = new Snapshot__c();
        lastmonth.Name = 'Account Share Decline Snapshot';
        lastmonth.Account__c = testAcc2.id;
        lastmonth.Snapshot_Date__c = Date.today().addDays(-30);
        lastmonth.Total_Market_Share_YTD__c = 60.6;
        snpList.add(lastmonth);
        
        insert snpList;
        
        System.runAs(mgr) {
            Test.startTest();
            PortfolioController.fetchShareDecliningAccounts(mgr.id, 'myPf', roleIds);
            PortfolioController.fetchShareDecliningAccounts(mgr.id, 'myTeamPf', roleIds);
            Test.stopTest();
        }
    }
    
    @isTest static void fetchAccountWOKeyContacts(){
        
        String[] roleIds = new List<String>();
        User mgr = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts'][0];
        roleIds.add(mgr.id);
        User sub = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts-Manager'][0];
        roleIds.add(sub.id);
        
        Account testAcc3 = new Account();
        testAcc3.Name = 'TestAccount2';
        testAcc3.Last_Completed_Account_Review__c = Date.today().addDays(-3);
        testAcc3.Last_Activity_Created_Date__c = Date.today().addDays(-30);
        testAcc3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        testAcc3.BillingCountry = 'AU';
        testAcc3.Contracted__c = true;
        testAcc3.OwnerId = mgr.Id;
        insert testAcc3;  
        
        Contact testCont = new Contact();
        testCont.lastname= 'Contact';
        testCont.firstname='Test';
        testCont.Active__c = true;
        testCont.Accountid = testAcc3.id;
        testCont.Function__c = 'IT';
        testCont.Business_Types__c= 'B&G';
        testCont.Job_Role__c ='BDM';
        testCont.Job_Title__c ='Chief of the organisation';
        testCont.Phone='8907654321';
        testCont.Email='abc@gmail.com';
        testCont.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        insert testCont;
        
        System.runAs(mgr) {
            Test.startTest();
            PortfolioController.fetchAccountWOKeyContacts(mgr.id, 'myPf', roleIds);
            PortfolioController.fetchAccountWOKeyContacts(mgr.id, 'myTeamPf', roleIds);
            Test.stopTest();
        }
    }
    
    @isTest static void fetchOverdueOpps(){
        
        Account testAcc = [Select id from Account where Name='TestAccount'][0];
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAcc.id;
        testOpp.Name = 'TestOpp';
        testOpp.StageName = 'Contract';
        testOpp.Type = 'Business and Government';
        testOpp.Forecast_MCA_Revenue__c=20000;
        testOpp.CloseDate = Date.today().addDays(-2);
        testOpp.Status_Last_Changed__c = Date.today().addDays(-10);
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business and Government').getRecordTypeId();
        insert testOpp;
        
        String[] roleIds = new List<String>();
        User mgr = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts'][0];
        roleIds.add(mgr.id);
        User sub = [SELECT id from User where UserRole.Name='QF-DOM-Sales-B&G-Strategic Accounts-Manager'][0];
        roleIds.add(sub.id);
        
        System.runAs(mgr) {
            Test.startTest();
            PortfolioController.fetchOverdueOpps(mgr.id, 'myPf', roleIds );
            PortfolioController.fetchOverdueOpps(mgr.id, 'myTeamPf', roleIds );
            Test.stopTest();
        }
    }
}