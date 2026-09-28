@isTest 
public with sharing class Test_prodregextensions {
    @testsetup
    static void createData(){

        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();


        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
    }
    @isTest      
    public static void Test_prodregextensions() {
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
        prodregextensions controller = new prodregextensions(new ApexPages.StandardController(new Product_Registration__c()));

        List<Product_Registration__c> Prodreglist = new List<Product_Registration__c>();
        List<AEQCC_Variance__c> conList = New List<AEQCC_Variance__c>();
        Product_Registration__c Pr = new Product_Registration__c(name = 'Test Product Registration',Account__c=acc.id);
        AEQCC_Variance__c Aeq = new AEQCC_Variance__c (Reporting_Period__c = 'Jan-Oct',Product_Link__c='a2cO00000013Djs',CurrencyIsoCode='AU');
      
        //Custom Setting
        TestUtilityDataClassQantas.getrelatedCustObjRecs();
        
     try{
            Database.Insert(Pr);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }

     try{
            Database.Insert(conlist);
        }catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        } 
        
        // conList.add(Aeq);
        prodregextensions controllerTest = new prodregextensions(new ApexPages.StandardController(pr));     
        controllerTest.getrelatedCustObjRecs();    
        conList.add(Aeq);          
    }  
  }  
}