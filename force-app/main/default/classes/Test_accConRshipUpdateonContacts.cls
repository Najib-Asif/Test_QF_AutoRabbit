/*
 * This class contains unit tests for validating the behavior of accConRshipUpdateonContacts class.
*/
@isTest
public class Test_accConRshipUpdateonContacts  {

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
          String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
          Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc;
                  Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id, QAC_Contact__c = 'No');
                
                insert con;
                          Account acc1 = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
                                    
                                    
                insert acc1;
                  Contact con1 = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id, QAC_Contact__c = 'No');
                
            //GRAPHITE-1930 Add Test.startTest
            Test.startTest();
                insert con1;
          // for(Integer i=0;i<=50;i++)
           allCont.add(new Contact(lastname= 'test',firstname='Contactrecord',Accountid =acc1.id,Function__c = 'IT',Business_Types__c = 'B&G',Job_Role__c ='BDM',Job_Title__c ='Developer',Phone='8907654321',Email='abc@gmail.com', QAC_Contact__c = 'No'));
           insert allCont;
               for (Contact Conid : allCont )
                ids.add(Conid.id);
        AccountContactRelation newAcc = new AccountContactRelation(Contactid =con1.id,Accountid =acc1.id,Function__c = 'IT',Business_Type__c = 'B&G',Job_Role__c ='BDM',Job_Title__c ='Developer',Related_Phone__c='8907654321',Related_Email__c='abc@gmail.com');                                                                
          
        insert newAcc ; 
            Test.stopTest();
      }
    }
    
    @isTest
    static void UpdateFrequentFlyerNumber()
    {   
        TestUtilityDataClassQantas.enableTriggers();        
        String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                      RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                      Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                      Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                      );
        
        Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, Frequent_Flyer_Number__c = '47564', AccountId = acc.Id, QAC_Contact__c = 'No');
        Test.startTest();
        insert acc;
        insert con;
        con.Frequent_Flyer_Number__c = '0074854';
        update con;
        Test.stopTest();
    }
    
    @isTest
    Static void Handleexception()
    {
        try{
            Contact con = new Contact(FirstName = 'Sample', LastName = 'Name', Frequent_Flyer_Number__c = '47564');
            insert con;
        }catch(Exception e){}
    }
}