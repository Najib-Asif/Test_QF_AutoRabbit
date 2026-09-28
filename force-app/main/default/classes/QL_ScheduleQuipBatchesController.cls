/*
Author: Navpreet Kaur
Class Description: Apex controller invoked from the Vf Page that schedules Quip batch jobs.
Date: 17 AUG 2023
Jira: CRM-6830
=========================================
VERSION  AUTHOR            DATE              DETAIL
1.0   Tanya Kumari    15/05/2026      CRM-10522 RBAC for System Admin

*/
public with sharing class QL_ScheduleQuipBatchesController 
{
    public QL_ScheduleQuipBatchesController()
    {
        
    }
    @RemoteAction
    public static boolean checkPermissions()
    {
      List<PermissionSetAssignment> lstPS;
      String profileName;
      try
      {
           lstPS = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() 
              AND PermissionSet.Name ='Access_to_Cancel_Scheduled_Job_Button_for_Quip_Email_Comms'];
              Id profileId = UserInfo.getProfileId();
              
           profileName =[Select Id, Name from Profile where Id=:profileId].Name;
      }
      catch(Exception e)
      {
          system.debug('Exception has ocurred'+e.getmessage());
      }
     //Included four new System Admin profiles which has been created as part of RBAC System
      return lstPS.size()>0 || profileName=='System Administrator' || profileName=='Qantas System Administrator' || profileName=='Qantas System Admin - Freight' || profileName=='Qantas System Admin - QCC' || profileName=='Qantas System Admin - SND';
    }
  
  @RemoteAction
    public static void invokeScheduleJobs() 
    {
      try
      {
          System.debug('Scheduled!!!');
          //Update custom settings to bypass triggers
          List<Trigger_Status__c> lisTriggerStatus=new List<Trigger_Status__c>();
          
          //To Bypass AccountIneligibilty Trigger Logs 
          Trigger_Status__c statusAccountEligibility=Trigger_Status__c.getValues('AccountEligibilityLogTrigger');          
          statusAccountEligibility.Active__c=false;
          lisTriggerStatus.add(statusAccountEligibility);
          
          
          Trigger_Status__c statusUpdateAcctDetails=Trigger_Status__c.getValues('AccountUpdateAccountDetail');          
          statusUpdateAcctDetails.Active__c=false;
          lisTriggerStatus.add(statusUpdateAcctDetails);
          
          
          Trigger_Status__c statusAccountTeam=Trigger_Status__c.getValues('AccountTeam');          
          statusAccountTeam.Active__c=false;
          lisTriggerStatus.add(statusAccountTeam);
          
          
          Trigger_Status__c statusACRPrimaryContact=Trigger_Status__c.getValues('ACRPrimaryContact');          
          statusACRPrimaryContact.Active__c=false;
          lisTriggerStatus.add(statusACRPrimaryContact);
          
          
          Trigger_Status__c statusContDocLink=Trigger_Status__c.getValues('ContentDocLinkTriggerCheck');          
          statusContDocLink.Active__c=false;
          lisTriggerStatus.add(statusContDocLink);
          
          List<QL_QuipScheduledJob__c> getAllQlJobs=[select id from QL_QuipScheduledJob__c limit 50000];
          if(lisTriggerStatus.size()>0)
          {
              update lisTriggerStatus;    
          }
          if(getAllQlJobs!=null && getAllQlJobs.size()>0)
          {
              delete getAllQlJobs;
          }
          QL_ApexClassToPassAccountOwnersList.invokeQuipFlow();
      }
      catch(Exception e)
      {
          system.debug('Exception has occurred'+e.getmessage());
      }  
      
        
    }   
}