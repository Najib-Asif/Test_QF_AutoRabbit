/*
Description-> This Apex helper reactivates the custom settings that were deactivated for the trigger bypass
Developer-> Navpreet Kaur
Creation Date-> AUG 2023
EPIC CRM-5831
*/
global with sharing class QL_RestoreTheTriggerStatus Implements Schedulable 
{
    global void execute(SchedulableContext sc)
        {
            QL_RestoreTheTriggerStatus();
        }

        public void QL_RestoreTheTriggerStatus()
        {
           //Update custom settings to bypass triggers
          List<Trigger_Status__c> lisTriggerStatus=new List<Trigger_Status__c>();
          
          //To Bypass AccountIneligibilty Trigger Logs 
          Trigger_Status__c statusAccountEligibility=Trigger_Status__c.getValues('AccountEligibilityLogTrigger');          
          statusAccountEligibility.Active__c=true;
          lisTriggerStatus.add(statusAccountEligibility);
          
          
          Trigger_Status__c statusUpdateAcctDetails=Trigger_Status__c.getValues('AccountUpdateAccountDetail');          
          statusUpdateAcctDetails.Active__c=true;
          lisTriggerStatus.add(statusUpdateAcctDetails);
          
          
          Trigger_Status__c statusAccountTeam=Trigger_Status__c.getValues('AccountTeam');          
          statusAccountTeam.Active__c=true;
          lisTriggerStatus.add(statusAccountTeam);
          
          
          Trigger_Status__c statusACRPrimaryContact=Trigger_Status__c.getValues('ACRPrimaryContact');          
          statusACRPrimaryContact.Active__c=true;
          lisTriggerStatus.add(statusACRPrimaryContact);
          
          
          Trigger_Status__c statusContDocLink=Trigger_Status__c.getValues('ContentDocLinkTriggerCheck');          
          statusContDocLink.Active__c=true;
          lisTriggerStatus.add(statusContDocLink);
          
          if(lisTriggerStatus.size()>0)
          {
              update lisTriggerStatus;
          }
        }
}