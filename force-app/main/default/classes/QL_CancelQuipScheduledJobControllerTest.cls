@isTest

public with sharing class QL_CancelQuipScheduledJobControllerTest{
 
    @isTest
    private static void testsuspendScheduledJob(){
    String jobId = System.schedule('Test Batch Job', '0 3 0 15 3 ? 2099', new QL_BatchToSendQUIPEmailComms());
    String batchName='Batch to Send Emails Comms';
     List<Trigger_Status__c> lisTriggerStatus=new List<Trigger_Status__c>();
        
         Trigger_Status__c statusAccountEligibility=new Trigger_Status__c(name='AccountEligibilityLogTrigger',Active__c=true);          
          lisTriggerStatus.add(statusAccountEligibility);
         Trigger_Status__c AccountUpdateAccountDetail=new Trigger_Status__c(name='AccountUpdateAccountDetail',Active__c=true);
         lisTriggerStatus.add(AccountUpdateAccountDetail);
            Trigger_Status__c AccountTeam=new Trigger_Status__c(name='AccountTeam',Active__c=true);
         lisTriggerStatus.add(AccountTeam);
            Trigger_Status__c ACRPrimaryContact=new Trigger_Status__c(name='ACRPrimaryContact',Active__c=true);
         lisTriggerStatus.add(ACRPrimaryContact);
            Trigger_Status__c ContentDocLinkTriggerCheck=new Trigger_Status__c(name='ContentDocLinkTriggerCheck',Active__c=true);
        lisTriggerStatus.add(ContentDocLinkTriggerCheck);
        
        
    
    System.assertEquals(1, [SELECT count() FROM CronTrigger WHERE id = :jobId]);
    Test.startTest();
      if(lisTriggerStatus.size()>0)
          {
              insert lisTriggerStatus;
         }
    QL_CancelQuipScheduledJobController.suspendScheduledJob();  
         QL_QuipScheduledJob__c statusRec=new QL_QuipScheduledJob__c(QL_Next_Job_Name__c=batchName);
         insert statusRec;
         
       
         
    Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM CronTrigger WHERE id = :jobId]);

   }
    
    @isTest
    private static void testCheckPermission(){
    Test.startTest();
    USer u = [SELECT Id FROM User WHERE isActive= true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(u){
    System.assertEquals(true,QL_CancelQuipScheduledJobController.checkPermission()) ;  
        }
    Test.stopTest();

   }   
}