/*----------------------------------------------------------------------------------------------------------------------
Author:      gnanavelu
Jira:      CRM-3586
Description:  Loyalty Account Manager should ensure to downloading the Contract Execution Certificate from Salesforce when closing an opportunity.
Test Class:     QL_CheckRecordhasFilesTest
************************************************************************************************************************
History
************************************************************************************************************************
08-April-2019      gnanavelu               Initial Design

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Added setUpData() method.
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QL_CheckRecordhasFilesTest 
{
    @testSetup static void setUpData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
    }
    
    @isTest
    static void CheckRecordhasFilesTest()
    {
        Trigger_Status__c Contentdocumentlinkstatus = new Trigger_Status__c();
        Contentdocumentlinkstatus.Name = 'ContentDocLinkTriggerCheck';
        Contentdocumentlinkstatus.Active__c = true;
        
        insert Contentdocumentlinkstatus;
        
        Account acc = new Account(Name = 'Sample Account', Active__c = true, Aquire__c = true, Type = 'Customer Account', 
                                  Migrated__c = false, Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                  Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,ABN_Tax_Reference__c = '12345678901');
        
        insert acc;
        
        Id LoyaltyCommercial = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Loyalty_Commercial').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = 'Opp'+acc.Name , AccountId = acc.Id,
                                          Amount = 500000, Category__c = 'Corporate Airfares', CloseDate = Date.Today(),
                                          StageName = 'Prospect', RecordTypeId = LoyaltyCommercial,Forecast_MCA_Revenue__c=20000);
        insert opp;
        
        Test.startTest();
        opp.StageName = 'Closed Won';
        try{
            update opp;
            
        }catch (Exception E)
        {
            system.debug('Error occured'+E);
        }
        
        //insert Content Document for the Opportunity
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;  
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=opp.Id;
        contentlink.ShareType= 'V';
        contentlink.Visibility = 'AllUsers'; 
        contentlink.ContentDocumentId=documents[0].Id;
        insert contentlink;
        
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
    }
}