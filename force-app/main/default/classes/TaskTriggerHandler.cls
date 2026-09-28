/*----------------------------------------------------------------------------------------------------------------------
Author: Bharathkumar Narayanan 
Purpose: Task Trigger Handler for capturing the log a call URL on campaign member 
 ======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2707    Log a call id capture on campaign member                    T01
                                    
Created Date    : 23/09/17 (DD/MM/YYYY) 
-----------------------------------------------------------------------------------------------------------------------*/
public class TaskTriggerHandler{
public static void ValidateTasks(LIST<Task> TaskRecords){
List<String>TaskWhoids = new List<String>();
        Map<String,String>ContactidAndTask = new map<String,String>();
    for(Task t:TaskRecords){
        
        TaskWhoids.add(t.whoId);
        ContactidAndTask.put(t.whoId,t.id);
    }
    list<CampaignMember> updatedCampaignMember = new list<CampaignMember>();
        for(CampaignMember each: [SELECT Id,ContactId,Log_call_url__c FROM CampaignMember where ContactId in : TaskWhoids]){
            each.Log_call_url__c = ContactidAndTask.get(each.ContactId);
            updatedCampaignMember.add(each);
            
        }
    
        if(updatedCampaignMember.size()>0){
            
            update updatedCampaignMember;
        }
        
        }
    }