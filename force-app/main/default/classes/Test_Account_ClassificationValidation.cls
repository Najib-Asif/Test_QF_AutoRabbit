/*
 * This class contains unit tests for validating the behavior of Account_ClassificationValidationHelper class.
*/
@isTest
public class Test_Account_ClassificationValidation  {

        @testsetup
    static void createData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
    }
    
    static testMethod void myTestclass() {
    TestUtilityDataClassQantas.enableTriggers();
    Set<ID> ids = new Set<ID>();
    List<Contact> allCont = new List<Contact>();
    List<AccountContactRelation> AccConRel = new List<AccountContactRelation>();
    
    /* 15 Mar 2017 BAU Issue Fix */
    
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
         List<Trigger_Status__c> tsList = new List<Trigger_Status__c>();
        Trigger_Status__c Account_ClassificationValidation = new Trigger_Status__c();
        Account_ClassificationValidation.Name = 'Account_ClassificationValidation';
        Account_ClassificationValidation.Active__c = true;
        tsList.add(Account_ClassificationValidation);
        List<Account_Classification_Type__c> customSetting = new List<Account_Classification_Type__c>();
        
        customSetting.add(new Account_Classification_Type__c(Name = 'Preferred Carrier', Classification_Type__c = 'Preferred Carrier'));
         customSetting.add(new Account_Classification_Type__c(Name = 'Travel Policy', Classification_Type__c = 'Travel Policy'));
         customSetting.add(new Account_Classification_Type__c(Name = 'OBT', Classification_Type__c = 'OBT'));
         try{
            Database.Insert(tsList);
            Database.Insert(customSetting); 
        
          String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
          Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc;
                  Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id);
                
                insert con;
                          Account acc1 = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc1;
                  Contact con1 = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id);
                
                insert con1;
          Account_Classifications__c ac=new Account_Classifications__c(Account__c=acc1.id,Classification__c='Preferred Carrier',Comments__c='Test',Reviewed_Date__c=date.today()) ;
          insert ac;
          Account_Classifications__c ac1=new Account_Classifications__c(Account__c=acc1.id,Classification__c='Preferred Carrier',Comments__c='Test',Reviewed_Date__c=date.today()) ;
          insert ac1;
          }
          Catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
            System.assert(e.getMessage().contains(System.Label.Account_Classification_Validation_Error));
        }
      }
    }
    static testMethod void myTestclass1() {
    TestUtilityDataClassQantas.enableTriggers();
    Set<ID> ids = new Set<ID>();
    List<Contact> allCont = new List<Contact>();
    List<AccountContactRelation> AccConRel = new List<AccountContactRelation>();
    
    /* 15 Mar 2017 BAU Issue Fix */
    
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
         List<Trigger_Status__c> tsList = new List<Trigger_Status__c>();
        Trigger_Status__c Account_ClassificationValidation = new Trigger_Status__c();
        Account_ClassificationValidation.Name = 'Account_ClassificationValidation';
        Account_ClassificationValidation.Active__c = true;
        tsList.add(Account_ClassificationValidation);
        List<Account_Classification_Type__c> customSetting = new List<Account_Classification_Type__c>();
        
        customSetting.add(new Account_Classification_Type__c(Name = 'Preferred Carrier', Classification_Type__c = 'Preferred Carrier'));
         customSetting.add(new Account_Classification_Type__c(Name = 'Travel Policy', Classification_Type__c = 'Travel Policy'));
         customSetting.add(new Account_Classification_Type__c(Name = 'OBT', Classification_Type__c = 'OBT'));
         try{
            Database.Insert(tsList);
          //  Database.Insert(customSetting); 
        }Catch(Exception e){
            System.debug('Error Occured: '+e.getMessage());
        }
          String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
          Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc;
                  Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id);
                
                insert con;
                          Account acc1 = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc1;
                  Contact con1 = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id);
                
                insert con1;
          Account_Classifications__c ac=new Account_Classifications__c(Account__c=acc1.id,Classification__c='Preferred Carrier',Comments__c='Test',Reviewed_Date__c=date.today()) ;
          insert ac;
          Account_Classifications__c ac1=new Account_Classifications__c(Account__c=acc1.id,Classification__c='Travel Policy',Comments__c='Test',Reviewed_Date__c=date.today()) ;
          insert ac1;
      }
    }
}