/*----------------------------------------------------------------------------------------------------------------------
Description:   Test Class SalesApprovalProcessReminder 
CRM - CRM-3144
*********************************************************************************************************************************
*********************************************************************************************************************************
History
CRM-3144                      v1.0           27-may-18

**********************************************************************************************************************************/
@isTest(seeAllData = false)
public class SalesApprovalProcessReminderTest {
    
  @testsetup 
    public static void createTestData(){

       List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg QBD Registration Rec Type','QBD Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type', 'Aquire Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Public Scheme Rec Type','Public Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Corporate Scheme Rec Type','Corporate Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Status','Active'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate NZD','15'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate AUD','10'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SchemesPointRoundOffNumber','500'));
        insert lstConfigData;

       

        //Enable Validation
        TestUtilityDataClassQantas.createEnableValidationRuleSetting();
        
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
        u.Level__c='SO3';
        u.ManagerID='00590000005Sly3';
        insert u;
        
         User user1 = [SELECT Id FROM User WHERE Alias='kswam'];
        system.runAs(u){ 
        //Create Account 
        Account objAcc = TestUtilityDataClassQantas.createAccount(); 
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc.Id != Null, 'Account is not inserted');

        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');

        Case c = new Case();
        c.AccountId = objAcc.Id;
        c.Type='Campaign';
        c.Status='New';
        c.Campaign_Start_Date__c =date.today().addmonths(1);
        c.RecordTypeId='01290000001UPURAA4';
        //c.Approved__c=true;
        c.Sub_Type__c='Gold Accelerate';
       // c.Number_of_Frequent_Flyer_Request__c=2;
        c.Justification_p__c    = 'Other';
        c.Justification__c  ='test';
        c.Incremental_Revenue__c =1000;
        c.Bulk_Frequent_Flyer_Request__c =true;
        c.Number_of_Frequent_Flyer_Request__c =50;
        insert c;
        system.debug('Ready_for_Approval__c*********'+c.Ready_for_Approval__c);
        Frequent_Flyer_Information__c f = new Frequent_Flyer_Information__c();
        f.name='test';
        f.Frequent_Flyer_Number__c='2333';   
        f.Current_Tier__c='Gold';
        f.Case__c=c.Id;
        f.Account__c=objAcc.Id;
        f.Freq_Flyer_Expiry_Date__c=date.today();
        f.Frequent_Flyer_Email__c='test@abc.com';
        insert f;
       
      try{
           Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            
            req.setObjectId(c.Id);
            Approval.ProcessResult resu = Approval.process(req);
            System.assert(resu.isSuccess());  
            System.assertEquals('Pending', resu.getInstanceStatus(),'Instance Status'+resu.getInstanceStatus());
            system.debug('status for approval::'+resu.getInstanceStatus());
    
    
     Test.startTest();
         SalesApprovalProcessReminder exBatch = new  SalesApprovalProcessReminder();
         integer batchSize = 10;
         Database.executeBatch(exBatch,batchSize);
         Test.stopTest();
        
            
            }
            catch (DMLException e) {
    system.debug('>>>> NO APPROVAL PROCESS FOR Cases!');
   }
            }
    }


     public static TestMethod void SalesApprovalProcessReminder_TestScheduler(){
    Test.startTest();
    SalesApprovalReminder_Batch_Schedular sfSchedule = new SalesApprovalReminder_Batch_Schedular();
    String sfScheduleTime = '0 0 23 * * ?'; 
    String jobId = system.schedule('My Sales Offer Test Schedule', sfScheduleTime, sfSchedule); 

     // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger
                          WHERE id = :jobId];

        System.assert(ct.CronExpression == sfScheduleTime, 'CronExpression is not matching' );
        
        // Verify the job has not run
        System.assert(0 == ct.TimesTriggered, 'Job is scheduled already' );

    Test.stopTest();
  }
    }