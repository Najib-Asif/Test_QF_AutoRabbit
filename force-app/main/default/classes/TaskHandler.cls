/*
Created Date   : 21/10/19 (DD/MM/YYYY)
Created By     : Vinothkumar Balasubramanian
JIRA           : CRM-3945
Description    : Adding Validation not to create/update Task against Inactive Accounts

*/

public with sharing class TaskHandler {
    
    public static void checkInactiveAgencyAccounts(list<Task> newTasks){
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        Set<Id> accountIdsSet = new Set<Id>();
        
        for(Task t : newTasks){
            if(t.WhatId <> null){
                Schema.sObjectType entityType = t.WhatId.getSObjectType();
                If(entityType == Account.sObjectType){
                    accountIdsSet.add(t.WhatId);
                }
            }
        }
        // Query Account and Store into a Map 
        Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, Name, Active__c 
                                                            From Account Where Id IN : accountIdsSet AND RecordTypeId =: accRTId]);
        
        
        for(Task t : newTasks){
            if(t.WhatId <> null){
                if(accountMap.containsKey(t.WhatId)){
                    Account acc = accountMap.get(t.WhatId);
                    if(acc.Active__c == FALSE){
                        t.addError(Label.Activities_for_Inactive_Agency_Accounts);
                    }
                }
            }
        }
    }
    
    public static void createTaskReminders(List<Task> taskRecords) {
        Set<Id> userIds = new Set<Id>();
        Set<String> userNames = new Set<String>(Label.Pop_up_Notification_Users.split(';'));
        for (User record : [ SELECT Id, Name FROM User WHERE Name IN :userNames ]) {
            userIds.add(record.Id);
        }
        Id cNotificationId = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='CreateForTaskReminders' LIMIT 1 ].Id;
        for (Task record : taskRecords) {
            if (record.OwnerId != null && record.ActivityDate != null && userIds.contains(record.OwnerId)) {
                Flow.Interview.Task_Reminder_Flow trf = new Flow.Interview.Task_Reminder_Flow(
                    new Map<String, Object>{ 'TaskRecord' => record, 'NotificationId' => cNotificationId, 'DueDate' => record.ActivityDate, 'PopupUserIds' => userIds }
                );
                trf.start();
            }
        }
    }
    
    public static void createTaskReminders(List<Task> taskRecords, Map<Id, Task> oldTaskRecords) {
        Set<Id> userIds = new Set<Id>();
        Task oldTask;
        System.debug('Success1');
        Set<String> userNames = new Set<String>(Label.Pop_up_Notification_Users.split(';'));
        for (User record : [ SELECT Id, Name FROM User WHERE Name IN :userNames ]) {
            userIds.add(record.Id);
        }
        System.debug('Success2');
        Id cNotificationId = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='CreateForTaskReminders' LIMIT 1 ].Id;
        for (Task record : taskRecords) {
            oldTask = oldTaskRecords.get(record.Id);
            System.debug('Success3');
            if (record.OwnerId != null && record.ActivityDate != oldTask.ActivityDate && userIds.contains(record.OwnerId)) {
                Flow.Interview.Task_Reminder_Flow trf = new Flow.Interview.Task_Reminder_Flow(
                    new Map<String, Object>{ 'TaskRecord' => record, 'NotificationId' => cNotificationId, 'DueDate' => record.ActivityDate, 'PopupUserIds' => userIds }
                );
                trf.start();
            }
            System.debug('Success');
        }
    }
}