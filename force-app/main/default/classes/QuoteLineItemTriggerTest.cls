/*==================================================================================================================================
Author:         Abhieet P
Company:        TCS
Purpose:        Test Class for Quote Line Item Trigger
Date:           15/06/2017         
History:
Modified By : Hari B (TCS Team), 27-Feb-2026
Desc : Fixed test class failures and added setupTestData() method.

==================================================================================================================================
CRM-4167 Raj Sharma 28-02-2020

Modified By : Venkata Suresh Kumar (TCS Team), 20-May-2026
Desc : Remediated test class failures. Updated createTestData() method.
==================================================================================================================================*/
@isTest
private class QuoteLineItemTriggerTest {
    @testSetup static void setupTestData() {
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        Test.stopTest();
    }


    static testMethod void  createTestData() {
      
      Test.startTest();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting());
        insert lsttrgStatus;
        
        List<Freight_RecordTypeSeggregation__c> lstfreCusSetting = Freight_TriggerRecordTypeUtility.createAccTrigTestCustomSetting();
        insert lstfreCusSetting;
        
        Account objaccount = new Account();
        objaccount.Name = 'TestAccount-Freight';
        objaccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        insert objaccount;
        
        Contact objcontact = new Contact();
        objcontact.FirstName = 'TestContact-Freight';
        objcontact.LastName = objaccount.Name;
        objcontact.Business_Types__c = 'Freight';
        objcontact.Email = 'test135@abc.com';
        insert objcontact;        
        
        Product2 objProduct2=new Product2();
        objProduct2.Name='Q-GO Priority Test';
        objProduct2.CurrencyIsoCode='AUD';
        objProduct2.isActive = TRUE;
        insert objProduct2;       
        
        Airport_Code__c objAirportCitySYD = new Airport_Code__c();
        objAirportCitySYD.Name = 'SYD';
        objAirportCitySYD.Freight_Station_Name__c ='Sydney';
        insert objAirportCitySYD;
        
        Airport_Code__c objAirportCityMEL = new Airport_Code__c();
        objAirportCityMEL.Name = 'MEL';
        objAirportCityMEL.Freight_Station_Name__c ='Melbourne';
        insert objAirportCityMEL;
        
        id stdPricebookId = Test.getStandardPricebookId();        
        Opportunity objopportunity = new Opportunity();
        objopportunity.AccountID = objaccount.id;
        objopportunity.Name = 'TestOpportunity';
        objopportunity.StageName = 'Identify';
        objopportunity.CloseDate = Date.today();
        objopportunity.Pricebook2ID = stdPricebookId;
        objopportunity.Forecast_MCA_Revenue__c=20000;
        insert objopportunity;        
        
        // system.debug('@@ stdPricebookId @@ ' + stdPricebookId);
        PricebookEntry objpricebookentry = new PricebookEntry();
        objpricebookentry.Product2ID = objProduct2.id;
        objpricebookentry.Pricebook2ID = stdPricebookId;
        objpricebookentry.UnitPrice = 0;
        objpricebookentry.isActive = true;
        insert objpricebookentry;    
        
        OpportunityLineItem objOpportunityProduct = new OpportunityLineItem();
        objOpportunityProduct.Quantity = 2;
        objOpportunityProduct.OpportunityId = objopportunity.Id;
        objOpportunityProduct.UnitPrice = 10;
        objOpportunityProduct.PriceBookEntryId = objpricebookentry.Id;
        objOpportunityProduct.Freight_Destination__c = objAirportCitySYD.Id;
        objOpportunityProduct.Freight_Origin__c = objAirportCityMEL.Id;
        objOpportunityProduct.Freight_Commodity__c = 'Abalone';
        objOpportunityProduct.Description = 'freightQLI';
        objOpportunityProduct.Flat_Rate__c = 2;
        objOpportunityProduct.Min_Charge__c = 3;   
        objOpportunityProduct.Pivot_Rate__c = 4;
        objOpportunityProduct.Pivot_Weight_Kgs__c = 5;    
        
               //objOpportunityProduct.Product2ID = objProduct2.id;
        insert objOpportunityProduct;

        Quote objquote=new Quote();
        objquote.Name='TestQuote';
        objquote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Freight_Quote').getRecordTypeId();
        objquote.OpportunityID=objopportunity.id;
        objquote.pricebook2id = stdPricebookId;
        objquote.ContactId = objcontact.Id;
        objquote.Rate_Valid_after_acceptance_until__c=Date.today()-30; // CRM-11408 added as part of Test class fix
        insert objquote;
        
        QuoteLineItem objQuoteLineItem = new QuoteLineItem();
        objQuoteLineItem.QuoteId = objquote.Id;
        objQuoteLineItem.Quantity = 2;
        objQuoteLineItem.UnitPrice = 10;
        objQuoteLineItem.Description = 'freightQLI';
        objQuoteLineItem.Product2ID = objProduct2.id;
        objQuoteLineItem.PricebookEntryId = objpricebookentry.Id;
        objQuoteLineItem.Flat_Rate__c = 2;
        objQuoteLineItem.Min_Charge__c = 3;   
        objQuoteLineItem.Pivot_Rate__c = 4;
        objQuoteLineItem.Pivot_Weight_Kgs__c = 5; 
        insert objQuoteLineItem;        
        Test.stopTest();
    }
}