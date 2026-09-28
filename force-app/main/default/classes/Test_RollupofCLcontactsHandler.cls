/**********************************************************************************************************************************
 
    Created Date: 23/05/17
 
    Description: This class contains unit tests for validating the behavior of RollupofCLcontactsHandler class.
  
    Versión:
    V1.0 - 23/05/17 - Initial version [FO]
 
**********************************************************************************************************************************/

@isTest
public class Test_RollupofCLcontactsHandler  {

        @testsetup
    static void createData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
    }
    
    static testMethod void RollupofCLcontactsHandlerclass() {
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
          String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
          Id ContRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
          Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc;
                  Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id,Profile_CL_Flag__c=TRUE,RecordTypeId = ContRecordTypeId);
                
                insert con;
                          Account acc1 = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc1;
                  Contact con1 = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id,Profile_CL_Flag__c=False,RecordTypeId = ContRecordTypeId);
                
         
      }
    }
}