/*********************************************************************************

Name              : FreightGenericAcccreation_Batch

Created By        : Vinothkumar Balasubramanian

Company Name      : TCS

Project           : Freight Track & Trace

Created Date      : 19 February 2019

Usage             : This Class creates the Freight Generic Account once the Case count under 
                    Account reaches the value on the Count field on Freight Exceptions Generic 
                    Account Custom Settings           

Schedular Class   : FreightAcccreation_Batch_Schedular    

*********************************************************************************/


global with sharing class FreightGenericAcccreation_Batch implements Database.Batchable<sObject> {
    
  global Database.QueryLocator start(Database.BatchableContext BC){
      
      Freight_Exceptions_Track_and_Trace__c freightGenericAccount = [Select Value__c from Freight_Exceptions_Track_and_Trace__c where Value__c != NULL];

        return Database.getQueryLocator([SELECT Id, AccountId
                   FROM Case where AccountId =: freightGenericAccount.Value__c]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Case> Cases){
      
      Freight_Exceptions_Track_and_Trace__c freightGenericAccount = [Select Counter__c, Value__c, Count__c from Freight_Exceptions_Track_and_Trace__c];
      
      List<Freight_Exceptions_Track_and_Trace__c> genericAccountCounter = new List<Freight_Exceptions_Track_and_Trace__c>();
      List<Account> freightAccount = new List<Account>();
      List<Freight_Exceptions_Track_and_Trace__c> genericAccountValue = new List<Freight_Exceptions_Track_and_Trace__c>();
      
      AggregateResult ar = [SELECT Count(Id)Total, AccountId FROM Case where AccountId =: freightGenericAccount.Value__c Group By AccountId];
      
      for(Case exceptionCase : Cases){
          if(exceptionCase.AccountId != null && exceptionCase.AccountId == freightGenericAccount.Value__c){
      
          Integer count = (Integer) ar.get('Total');
      
          if (count > freightGenericAccount.Count__c){
              freightGenericAccount.Counter__c++;
              genericAccountCounter.add(freightGenericAccount);
              
              Account acc = new Account();
              acc.Name = 'Freight Track & Trace [FREIGHT-EXCEPTION-AU] - 000'+freightGenericAccount.Counter__c;
              acc.Type = 'Freight-Country';
              acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
              acc.Active__c = TRUE;
         
              freightAccount.add(acc);

              freightGenericAccount.Value__c = acc.Id;
              genericAccountValue.add(freightGenericAccount);
          }
          }
      }
        
         Database.update(genericAccountCounter, false);
         Database.insert(freightAccount, false);
         Database.update(genericAccountValue, false);
    }
    
    global void finish(Database.BatchableContext ctx){
      
    }
}