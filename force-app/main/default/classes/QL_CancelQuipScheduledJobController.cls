/*
Author: Ranjana Tiwari
Class Description:Apex controller invokes from the Vf Page which will cancel the Scheduled Job.
Date: 16 June 2023
Jira: CRM-6441
=========================================
VERSION  AUTHOR            DATE              DETAIL
1.0   Tanya Kumari    15/05/2026      CRM-10522 RBAC for System Admin

*/
public with sharing class QL_CancelQuipScheduledJobController{

  public QL_CancelQuipScheduledJobController(){

  }
  @RemoteAction
    public static void suspendScheduledJob() {
      String batchName='Batch to Send Emails Comms';
      
      System.debug('Aborted!!!');
      for ( AsyncApexJob aJob : [ Select id ,Status, ApexClass.Name, CronTriggerId 
      from AsyncApexJob where Status!='Aborted' 
       and Status!='Completed' and (ApexClass.Name = 'QL_BatchToSendQUIPEmailComms' or ApexClass.Name = 'QL_batchClassToInvokeQuipFlow' or ApexClass.Name = 'QL_batchClassToInvokeREFRESHQUIPFlow' or ApexClass.Name = 'QL_batchClassToRemoveQuipDocs' or ApexClass.Name = 'QL_batchClassToInvokeQuipFlowPDF' or ApexClass.Name= 'QL_RestoreTheTriggerStatus') and CronTriggerId <> NULL] ){
     System.AbortJob(aJob.CronTriggerId);
     }
     
     //Restoring the custom setting's trigger status values
     new QL_RestoreTheTriggerStatus().execute(null); 
     
     //This code performs the delete operation on QUIP Scheduled jobs each time cancel button is clicked.
     //List<QL_QuipScheduledJob__c> getQuipJobs=[select id from QL_QuipScheduledJob__c where QL_Next_Job_Name__c=:batchName];
     List<QL_QuipScheduledJob__c> getQuipJobs=[select id from QL_QuipScheduledJob__c limit 50000];
     if(getQuipJobs!=null && getQuipJobs.size()>0)
     {
         database.DeleteResult[] results =database.delete(getQuipJobs,false);
         system.debug('>>> Delete operation results'+results);
     }
     
     
}

@RemoteAction
public static boolean checkPermission(){
  List<PermissionSetAssignment> lstPS = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() 
  AND PermissionSet.Name ='Access_to_Cancel_Scheduled_Job_Button_for_Quip_Email_Comms'];
  Id profileId = UserInfo.getProfileId();
  String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
  //Included four new System Admin profiles which has been created as part of RBAC System
  return lstPS.size()>0 || profileName=='System Administrator' || profileName=='Qantas System Administrator' || profileName=='Qantas System Admin - Freight' || profileName=='Qantas System Admin - QCC' || profileName=='Qantas System Admin - SND';

 }

}