@isTest
public class TaskEventTriggerTest{
    
    @testSetup
    public static void setup() {
        
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        List<Trigger_Status__c> trgStatusList = new List<Trigger_Status__c>();
        Trigger_Status__c eventTrigger = new Trigger_Status__c(Name = 'EventTrigger',Active__c = true);
        Trigger_Status__c taskTrigger = new Trigger_Status__c(Name = 'TaskTrigger',Active__c = true);
        trgStatusList.add(eventTrigger);
        trgStatusList.add(taskTrigger);
        
        //trgStatusList.addAll(TestUtilityDataClassQantas.createAccountTriggerSetting());
        insert trgStatusList;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added by Suresh
        
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020202');
        insert myAccount;
    }
    
    public static testMethod void taskInsertTest(){
        Test.startTest();
        Account myAccount = [Select Id, Active__c from Account where Name = 'Sample'];
        
        myAccount.Active__c = FALSE;
        update myAccount;
        
        Task t = new Task(
            Subject = 'Call',
            Status = 'Not Started',
            Priority = 'Normal',
            WhatId = myAccount.Id
        );
        Try{
            insert t;
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    public static testMethod void eventInsertTest(){
        Test.startTest();
        Account myAccount = [Select Id, Active__c from Account where Name = 'Sample'];
        
        myAccount.Active__c = FALSE;
        update myAccount;
        
        
        Event eve = new Event(
            StartDateTime = System.Today(),
            EndDateTime = System.Today(),
            WhatId = myAccount.Id
        );
        Try{
            insert eve;
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}