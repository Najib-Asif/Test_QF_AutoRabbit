/*----------------------------------------------------------------------------------------------------------------------
Author: Bharathkumar Narayanan 
Purpose: Test class for TaskTriggerHandler 
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2707    Test class for TaskTriggerHandler                           T01

Created Date    : 23/09/17 (DD/MM/YYYY) 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
private class Test_TaskTriggerHandler{
    //Added by Suresh
    @testSetup static void setupTestData(){
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();        
        Test.stopTest();
    }
    
    public static testMethod void TaskTriggerhandler(){
        Test.startTest();
        String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                  RecordTypeId = prospectRecordTypeId, Migrated__c = false, 
                                  Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                  Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,Contract_End_Date__c = Date.Today()
                                 );
        
        
        insert acc;
        Contact con = new Contact(FirstName = 'Sample', LastName = acc.Name, AccountId = acc.Id);
        
        insert con;
        
        campaign c=new campaign();
        c.Name='Email';
        c.IsActive=True;
        insert c;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Testing';
        t.Status='Not Started';
        t.Priority='Normal';
        insert t;   
        
        campaignmember cm=new campaignmember();
        cm.Related_Account__c=acc.Id;
        cm.ContactId=con.Id;
        cm.CampaignId=c.Id;
        cm.Status='Responded';
        cm.Log_call_url__c  ='test';
        insert cm;
        
        cm.Log_call_url__c  =t.Id;
        update cm;
        Test.stopTest();
    }    
}