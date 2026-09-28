/***********************************************************************************************************************************

Description: Trigger which calls the handler class Task trigger handler  

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2707    Log a call id capture on campaign member                T01
                                    
Created Date    : 23/09/17 (DD/MM/YYYY)

 Modified Date   : 11/07/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : CRM-3945
  Version         : V2.0 - Adding Validation not to create/update Task against Inactive Agency Accounts

**********************************************************************************************************************************/




trigger updatetaskfromsalesforceforoutlook on Task (before insert,after insert,before update, after update)
{

try{
     if(Trigger.isBefore){
     if(Trigger.isInsert){


map<Id, UserRole> roleIdVsUserRoleMap = new map<id, UserRole>([SELECT Id, Name FROM UserRole]) ;
map<Id, String> roleIdVsRoleNameMap = new map<Id, String>();

for(UserRole eachRole : [SELECT Id, Name FROM UserRole]){
    roleIdVsRoleNameMap.put(eachRole.Id, eachRole.Name);
}

set<Id> ownerIdsSet = new set<Id>();
set<Id> freightOwnerIdsSet = new set<Id>();
string freightRoleName = 'Freight';

for(Task eachTask : Trigger.New){
    ownerIdsSet.add(eachTask.OwnerId);
}

system.debug('@@ map @@ ' +  roleIdVsRoleNameMap);

for(User eachUser : [SELECT Id, UserRoleId FROM User WHERE Id IN: ownerIdsSet]){
    if(roleIdVsRoleNameMap.containsKey(eachUser.UserRoleId)){
        if(roleIdVsRoleNameMap.get(eachUser.UserRoleId).contains(freightRoleName)){
            freightOwnerIdsSet.add(eachUser.Id);
        }
    }
}


for(Task t:trigger.new)

{

    //checking if subject contains email:

    if (t.Subject.contains('Email:'))

    {
        if(freightOwnerIdsSet.contains(t.OwnerId)){
            t.Task_type__c = 'Freight'; 
            t.Subtype__c = 'Email/Phone';
        }

        else{
            t.Task_type__c = 'Strategic Account Management'; 
            t.Subtype__c = 'Email/Phone';
        }
        
    }
    
    
    }
    }
    }
        //Changes added by Vinoth for CRM-3945
        if(Trigger_Status__c.getValues('TaskTrigger') != null && Trigger_Status__c.getValues('TaskTrigger').Active__c){
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            { 
                TaskHandler.checkInactiveAgencyAccounts(trigger.new);
            }
        
        }
        //Changes ends for CRM-3945 
    
    //Logic begins for Task log a call id populate on campaign member//
    /* if(Trigger.isAfter){
     if(Trigger.isInsert){
     
    TaskTriggerHandler.ValidateTasks(Trigger.new);
           
           }
           }*/
        if (Trigger.isAfter && Trigger.isInsert) {
            TaskHandler.createTaskReminders(Trigger.new);
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            TaskHandler.createTaskReminders(Trigger.new, Trigger.oldMap);
            System.debug('Trigger Success');
        }
    }catch(Exception e){
        System.debug('Error Occured From Task Trigger: '+e.getMessage());
        }
}