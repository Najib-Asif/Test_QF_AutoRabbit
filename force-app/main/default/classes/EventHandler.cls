/*
Created Date   : 21/10/19 (DD/MM/YYYY)
Created By     : Vinothkumar Balasubramanian
JIRA           : CRM-3945
Description    : Adding Validation not to create/update Event against Inactive Accounts

*/

public with sharing class EventHandler {
    
    public static void checkInactiveAgencyAccounts(list<Event> newEvents){
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        Set<Id> accountIdsSet = new Set<Id>();
        
        For(Event eve : newEvents){
            if(eve.WhatId <> null){
                Schema.sObjectType entityType = eve.WhatId.getSObjectType();
                If(entityType == Account.sObjectType){
                    accountIdsSet.add(eve.WhatId);
                }
            }
        }
        // Query Account and Store into a Map 
        Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, Name, Active__c 
                                                            From Account Where Id IN : accountIdsSet AND RecordTypeId =: accRTId]);
        
        
        For(Event eve : newEvents){
            if(eve.WhatId <> null){
                if(accountMap.containsKey(eve.WhatId)){
                    Account acc = accountMap.get(eve.WhatId);
                    if(acc.Active__c == FALSE){
                        eve.addError(Label.Activities_for_Inactive_Agency_Accounts);
                    }
                }
            }
        }
    }
}