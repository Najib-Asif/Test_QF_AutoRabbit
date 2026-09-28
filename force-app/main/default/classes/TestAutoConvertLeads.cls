/*******************************************************************************************************************************
Description: This is testclass for "AutoConvertLeads" Apex Class. which will convert lead into Account and Contact in 
case of no duplicates exist. Update account type accordingly.
Created Date: 10-04-2017
JIRA:          CRM-2545

Modified Date: 15-06-2017
Modified By : Freight Team as part of Freight release 2 changes.

JIRA: CRM-3040

Modified Date: 05-May-2018
Modified By : DPP Lead changes, auto opportunity creation

JIRA: CRM-10363

Modified Date: 19-Dec-2025
Modified By : Mark-Capgemini
Changes : Test method updated for PSV changes

******************************************************************************************************************************** */

@isTest(SeeAllData = false)
private class TestAutoConvertLeads {
    private static Id leadId;
    private static Integer LEAD_COUNT = 0;
    
@testsetup
static void createData(){
    // Custom setting creation
List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.add(new Trigger_Status__c(Name= 'FeedItemTrgPreventChatterDeletion', Active__c= true));
        lsttrgStatus.add(new Trigger_Status__c(Name= 'FeedItemTrgUpdateEscalationTickBox', Active__c= true));
        insert lsttrgStatus;
} 
    
    static testMethod void Test_LeadConvertForCustomerAcc() {
        LEAD_COUNT += 1;
        
        //if(!Test.isRunningTest()) {
            TestUtilityDataClassQantas.enableTriggers();
       TestUtilityDataClassQantas.insertQantasConfigData();
            String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', RecordTypeId = prospectRecordTypeId, Migrated__c = false, Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false, Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', Contract_End_Date__c = Date.Today());
            
            insert acc;
            Sales_Region__c sr = new Sales_Region__c(Name = 'AD - Agency Development Account', sales_h_eq_type__c = 'Industry', sales_h_type__c = 'Industry');
            insert sr;
            
            Lead testLead = new Lead();
            testLead.FirstName = 'Test First26' + LEAD_COUNT;
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Account_Tier__c = 'Industry - Platinum';
            testLead.Agency_TIDS__c = '4399101';
            testLead.Business_Type__c = 'Agency';
            testLead.City = 'Sydney';
            testLead.Company = 'Appshark';
            testLead.Company = 'Test Co';
            testLead.CountryCode = 'AU';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'mknjnm';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLead.Job_Role__c = 'Agency Owner';
            testLead.Job_Title__c = 'Mr';
            testLead.LastName = 'Test Last26' + LEAD_COUNT;
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Customer';
            testLead.Postalcode = '2060';
            testLead.State = 'VIC';
            testLead.Status = 'Qualified';
            testLead.Street = 'Test';
            
            // testLead.FirstName='Joihn1';
            // testLead.LastName='Smiith1';
            testLead.Salutation = 'Mr.';
            testLead.Agency_Sales_Region__c = sr.id;
            testLead.AnnualRevenue = 1000;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Email = 'abc45t32422@xhyz.com';
            testLEad.Industry = 'Manufacturing';
            testLead.LeadSource = 'Web';
            testLead.MobilePhone = '999979993';
            testLead.NumberOfEmployees = 100;
            testLead.Opportunity_Type__c = 'Sales Development';
            testLead.Parent_Account__c = acc.id;
            testLead.Phone = '123456';
            testLead.Website = 'www.test.com';
            
            
            Test.startTest();
            insert testLead;
            
            leadId = testLead.Id;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            //   Database.LeadConvertResult lcr = Database.convertLead(lc);
            //  System.assert(lc.isSuccess());
            Test.stopTest();
        //}
    }
    static testMethod void Test_LeadConvertForProspectAcc() {
        LEAD_COUNT += 1;
        //if(!Test.isRunningTest()) {
            TestUtilityDataClassQantas.enableTriggers();
         TestUtilityDataClassQantas.insertQantasConfigData();
            String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', RecordTypeId = prospectRecordTypeId, Migrated__c = false, Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false, Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', Contract_End_Date__c = Date.Today());
            
            insert acc;
            Sales_Region__c sr = new Sales_Region__c(Name = 'AD - Agency Development Account', sales_h_eq_type__c = 'Industry', sales_h_type__c = 'Industry');
            insert sr;
            
            Lead testLead = new Lead();
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Account_Tier__c = 'Industry - Platinum';
            testLead.Agency_TIDS__c = '4399101';
            testLead.Business_Type__c = 'Agency';
            testLead.City = 'Sydney';
            testLead.Company = 'Appshark';
            testLead.Company = 'Test Co';
            testLead.CountryCode = 'AU';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'asdsad';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLead.Job_Role__c = 'Agency Owner';
            testLead.Job_Title__c = 'Mr';
            testLead.LastName = 'Test Last3' + LEAD_COUNT;
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Prospect';
            testLead.Postalcode = '2060';
            testLead.State = 'VIC';
            testLead.Status = 'Qualified';
            testLead.Street = 'Test';
            testLead.FirstName = 'Test First13' + LEAD_COUNT;
            
            // testLead.FirstName='Joihn1';
            // testLead.LastName='Smiith1';
            testLead.Agency_Sales_Region__c = sr.id;
            testLead.AnnualRevenue = 1000;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Email = 'abc4531422@rxyz.com';
            testLead.Function__c = 'Finance';
            testLEad.Industry = 'Manufacturing';
            testLead.LeadSource = 'Web';
            testLead.MobilePhone = '990999994';
            testLead.NumberOfEmployees = 100;
            testLead.Opportunity_Type__c = 'SME Product';
            testLead.Parent_Account__c = acc.id;
            testLead.Phone = '123456';
            testLead.Website = 'www.test.com';
            testLead.Salutation = 'Mr.';
            
            
            Test.startTest();
            insert testLead;
            
            leadId = testLead.Id;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            // Database.LeadConvertResult lcr = Database.convertLead(lc);
            //     System.assert(lc.isSuccess());
            Test.stopTest();
        //}
        
    }
    static testMethod void Test_LeadConvertForNonAUAcc() {
        LEAD_COUNT += 1;
        
        
        //if(!Test.isRunningTest()) {
            TestUtilityDataClassQantas.enableTriggers();
         TestUtilityDataClassQantas.insertQantasConfigData();
            String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', RecordTypeId = prospectRecordTypeId, Migrated__c = false, Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false, Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', Contract_End_Date__c = Date.Today());
            
            insert acc;
            Sales_Region__c sr = new Sales_Region__c(Name = 'AD - Agency Development Account', sales_h_eq_type__c = 'Industry', sales_h_type__c = 'Industry');
            insert sr;
            
            Lead testLead = new Lead();
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Account_Tier__c = 'Industry - Gold';
            testLead.Agency_Sales_Region__c = sr.id;
            testLead.Agency_TIDS__c = '4137301';
            testLead.AnnualRevenue = 1000;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Business_Type__c = 'Agency';
            testLead.City = 'Dallas';
            testLead.Company = 'Appshark';
            testLead.CountryCode = 'US';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Email = 'abc453422yq@xyz.com';
            testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'aswdxc';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLEad.Industry = 'Manufacturing';
            testLead.Job_Role__c = 'Agency Manager';
            testLead.Job_Title__c = 'Mr';
            testLead.LastName = 'Test Lahst4' + LEAD_COUNT;
            testLead.LeadSource = 'Web';
            testLead.Legal_Name__c = 'Test ABC';
            testLead.MobilePhone = '999997995';
            testLead.New_Account_Type__c = 'Agency';
            testLead.NumberOfEmployees = 100;
            testLead.Opportunity_Type__c = 'GSA';
            testLead.Parent_Account__c = acc.id;
            testLead.Phone = '123456';
            testLead.Status = 'Qualified';
            testLead.Street = 'Test';
            testLead.Website = 'www.test.com';
            testLead.FirstName = 'Test Fihrst14' + LEAD_COUNT;
            testLead.Postalcode = '2060';
            testLead.Salutation = 'Mr.';
            
            
            
            Test.startTest();
            insert testLead;
            
            leadId = testLead.Id;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            //   Database.LeadConvertResult lcr = Database.convertLead(lc);
            //    System.assert(lc.isSuccess());
            Test.stopTest();
        //}
        
    }
    static testMethod void Test_LeadConvertForCharterAUAcc() {
        LEAD_COUNT += 1;
        
        //if(!Test.isRunningTest()) {
            TestUtilityDataClassQantas.enableTriggers();
         TestUtilityDataClassQantas.insertQantasConfigData();
            String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', RecordTypeId = prospectRecordTypeId, Migrated__c = false, Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false, Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', Contract_End_Date__c = Date.Today());
            
            insert acc;
            Sales_Region__c sr = new Sales_Region__c(Name = 'AD - Agency Development Account', sales_h_eq_type__c = 'Industry', sales_h_type__c = 'Industry');
            insert sr;
            
            Lead testLead = new Lead();
            testLead.FirstName = 'Test First125' + LEAD_COUNT;
            testLead.LastName = 'Test Last5' + LEAD_COUNT;
            testLead.Company = 'Test Co';
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Status = 'Qualified';
            testLead.Company = 'Appshark';
            testLead.Account_Tier__c = 'Industry - Platinum';
            testLead.Agency_TIDS__c = '4399101';
            testLead.Business_Type__c = 'Agency';
            testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'lkjhjk';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLead.Job_Role__c = 'Agency Owner';
            testLead.Job_Title__c = 'Mr';
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Charter';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Street = 'Test';
            testLead.CountryCode = 'US';
            testLead.City = 'Dallas';
            //testLead.State='VIC';
            testLead.Postalcode = '2060';
            // testLead.FirstName='Joihn1';
            // testLead.LastName='Smiith1';
            testLead.Salutation = 'Mr.';
            testLead.Email = 'abc2d453422@xyz.com';
            testLead.Phone = '123456';
            testLead.Function__c = 'Finance';
            testLead.NumberOfEmployees = 100;
            testLead.AnnualRevenue = 1000;
            testLead.LeadSource = 'Web';
            testLEad.Industry = 'Manufacturing';
            testLead.Website = 'www.test.com';
            testLead.MobilePhone = '999199996';
            testLead.Agency_Sales_Region__c = sr.id;
            testLead.Parent_Account__c = acc.id;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Opportunity_Type__c = 'Charters';
            
            Test.startTest();
            insert testLead;
            
            leadId = testLead.Id;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            //   Database.LeadConvertResult lcr = Database.convertLead(lc);
            //   System.assert(lc.isSuccess());
            Test.stopTest();
        //}
    }
    static testMethod void Test_LeadConvertForOtherAcc() {
        LEAD_COUNT += 1;
        
        //if(!Test.isRunningTest()) {
            TestUtilityDataClassQantas.enableTriggers();
         TestUtilityDataClassQantas.insertQantasConfigData();
            String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Prospect Account', RecordTypeId = prospectRecordTypeId, Migrated__c = false, Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false, Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N', Contract_End_Date__c = Date.Today());
            
            insert acc;
            Sales_Region__c sr = new Sales_Region__c(Name = 'AD - Agency Development Account', sales_h_eq_type__c = 'Industry', sales_h_type__c = 'Industry');
            insert sr;
            
            Lead testLead = new Lead();
            testLead.FirstName = 'Test First816' + LEAD_COUNT;
            testLead.LastName = 'Test Last86' + LEAD_COUNT;
            testLead.Company = 'Test Co';
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Status = 'Qualified';
            testLead.Company = 'Appshark';
            testLead.Account_Tier__c = 'Industry - Platinum';
            testLead.Agency_TIDS__c = '4399101';
            testLead.Business_Type__c = 'Agency';
            testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'yutrew';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLead.Job_Role__c = 'Agency Owner';
            testLead.Job_Title__c = 'Mr';
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Other';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Street = 'Test';
            testLead.CountryCode = 'US';
            testLead.City = 'Dallas';
            //testLead.State='VIC';
            testLead.Postalcode = '2060';
            // testLead.FirstName='Joihn1';
            // testLead.LastName='Smiith1';
            testLead.Salutation = 'Mr.';
            testLead.Email = 'abc453e7y422@xyz.com';
            testLead.Phone = '123456';
            testLead.NumberOfEmployees = 100;
            testLead.AnnualRevenue = 1000;
            testLead.LeadSource = 'Web';
            testLEad.Industry = 'Manufacturing';
            testLead.Website = 'www.test.com';
            testLead.MobilePhone = '999992996';
            testLead.Agency_Sales_Region__c = sr.id;
            testLead.Parent_Account__c = acc.id;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Opportunity_Type__c = 'Business and Government';
            
            Test.startTest();
            insert testLead;
            
            leadId = testLead.Id;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            //   Database.LeadConvertResult lcr = Database.convertLead(lc);
            //   System.assert(lc.isSuccess());
            Test.stopTest();
        //}
        
    }
    /*************************************************************************************************  
Method Name : Test_LeadConvertForFreightAcc
Description: This is the testmethod to cover the functionality related to Freight Auto convert lead.
Created Date: 15-06-2017
Created By  : Freight Team as part of Freight release 2 changes

**************************************************************************************************/
    
    static testMethod void Test_LeadConvertForFreightAcc() {
        LEAD_COUNT += 1;
        
        //if(!Test.isRunningTest()) {
            
            TestUtilityDataClassQantas.enableTriggers();
        	TestUtilityDataClassQantas.insertQantasConfigData();
            String freightRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            Account acc = new Account(Name = 'Sample', Active__c = true, Type = 'Freight-Country', RecordTypeId = freightRecordTypeId);
            
            insert acc;
            
            Airport_Code__c aircode = new Airport_Code__c(Name = 'SYD' , Freight_Station_Name__c ='SYDNEY');
            
            insert aircode;
            
            Lead testLead = new Lead();
            testLead.FirstName = 'Test Firyst17' + LEAD_COUNT;
            testLead.LastName = 'Test Lasty7' + LEAD_COUNT;
            testLead.Company = 'Company created for test';
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Status = 'Qualified';
            testLead.Business_Type__c = 'Freight';
            //testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'abcxyz';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLead.Job_Role__c = 'Board Member';
            testLead.Job_Title__c = 'Mr';
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Freight-Branch';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Street = 'Street';
            testLead.CountryCode = 'AU';
            testLead.City = 'Sydney';            
            testLead.Postalcode = '2005';
            testLead.Salutation = 'Mr.';
            testLead.Email = 'abcd45y3422@xyz.com';
            testLead.Phone = '123456';
            testLead.LeadSource = 'Web';
            testLEad.Industry = 'Manufacturing';
            testLead.Website = 'www.test.com';
            testLead.MobilePhone = '999994991';
            testLead.Freight_eQ_Customer__c = '9999999991';                                  
            testLead.Freight_Corporate_Identifier__c = '99999999999999999991';                                                       
            testLead.Freight_Customer_Code__c = '1234567899';                                                  
            testLead.Freight_Revenue_Stream__c = 'DOM';
            testLead.Parent_Account__c = acc.id;
            testLead.Freight_Account_Business_Type__c ='Branch';
            testLead.Freight_Station_Code__c = aircode.id;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Opportunity_Type__c = 'Agency Partnerships';       
            testLead.Auto_Lead_Convert__c = True;

            
            Test.startTest();
         try{
           insert testLead; 
        }
        catch(exception ex){
            system.debug('execption for freight acc'+ex);
        }        
           
            
            leadId = testLead.Id;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
              // Database.LeadConvertResult lcr = Database.convertLead(lc);
            //     System.assert(lc.isSuccess());
            Test.stopTest();
        //}
    }
    /*************************************************************************************************  
Method Name : Test_LeadConvertForDPP
Description: This is the testmethod to cover the functionality related to DPP
Created Date: 15-06-2017

**************************************************************************************************/
    
    static testMethod void Test_LeadConvertForDPP() {
        LEAD_COUNT += 1;
        //if(!Test.isRunningTest()) {
            
            
            TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
            String freightRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
            Account acc = new Account(Name = 'Sample', Active__c = true, Type = 'Freight-Country', RecordTypeId = freightRecordTypeId);
            
            insert acc;
            
            Airport_Code__c aircode = new Airport_Code__c(Name = 'SYD' , Freight_Station_Name__c ='SYDNEY');
            
            insert aircode;
            
            Lead testLead = new Lead();
            testLead.FirstName = 'Test Firyst17' + LEAD_COUNT;
            testLead.LastName = 'Test Lasty7Name' + LEAD_COUNT;
            testLead.Company = 'TestCompany Name';
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Status = 'Qualified';
            testLead.Business_Type__c = 'Freight';
            //testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'abcxyz';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764007';
            testLead.Job_Role__c = 'Board Member';
            testLead.Job_Title__c = 'Mr';
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Freight-Branch';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Street = 'TestStreet';
            testLead.CountryCode = 'AU';
            testLead.City = 'Mascot';            
            testLead.Postalcode = '2121';
            testLead.Salutation = 'Mr.';
            testLead.Email = 'abcd45y3422@xyz.com';
            testLead.Phone = '123456';
            testLead.LeadSource = 'Web';
            testLEad.Industry = 'Manufacturing';
            testLead.Website = 'www.test.com';
            testLead.MobilePhone = '999994991';
            testLead.Freight_eQ_Customer__c = '9999999991';                                  
            testLead.Freight_Corporate_Identifier__c = '99999999999999999991';                                                       
            testLead.Freight_Customer_Code__c = '1234567899';                                                  
            testLead.Freight_Revenue_Stream__c = 'DOM';
            testLead.Parent_Account__c = acc.id;
            testLead.Freight_Account_Business_Type__c ='Branch';
            testLead.Freight_Station_Code__c = aircode.id;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Opportunity_Type__c = 'DPP Onboarding';
       		testLead.Auto_Lead_Convert__c = True;
            
            Test.startTest();
         try{
           insert testLead; 
        }
        catch(exception ex){
            system.debug('execption for DPP'+ex);
        }        
          
            
            leadId = testLead.Id;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            
            
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            //   Database.LeadConvertResult lcr = Database.convertLead(lc);
            //     System.assert(lc.isSuccess());
            Test.stopTest();
        //}
    }

     static testMethod void Test_LeadConvertForFreightAccNoParent() {
        LEAD_COUNT += 1;
        
        //if(!Test.isRunningTest()) {
            
            TestUtilityDataClassQantas.enableTriggers();
            TestUtilityDataClassQantas.insertQantasConfigData();
            Airport_Code__c aircode = new Airport_Code__c(Name = 'SYD' , Freight_Station_Name__c ='SYDNEY');
            insert aircode;
            
            Lead testLead = new Lead();
            testLead.FirstName = 'Test Firyst17' + LEAD_COUNT;
            testLead.LastName = 'Test Lasty7' + LEAD_COUNT;
            testLead.Company = 'Company created for test';
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Status = 'Qualified';
            testLead.Business_Type__c = 'Freight';
            //testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'abcxyz';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLead.Job_Role__c = 'Board Member';
            testLead.Job_Title__c = 'Mr';
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Freight-Branch';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Street = 'Street';
            testLead.CountryCode = 'AU';
            testLead.City = 'Sydney';            
            testLead.Postalcode = '2005';
            testLead.Salutation = 'Mr.';
            testLead.Email = 'abcd45y3422@xyz.com';
            testLead.Phone = '123456';
            testLead.LeadSource = 'Web';
            testLEad.Industry = 'Manufacturing';
            testLead.Website = 'www.test.com';
            testLead.MobilePhone = '999994991';
            testLead.Freight_eQ_Customer__c = '9999999991';                                  
            testLead.Freight_Corporate_Identifier__c = '99999999999999999991';                                                       
            testLead.Freight_Customer_Code__c = '1234567899';                                                  
            testLead.Freight_Revenue_Stream__c = 'DOM';
            testLead.Freight_Account_Business_Type__c ='Shipper';
            testLead.Freight_Station_Code__c = aircode.id;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Opportunity_Type__c = 'Agency Partnerships';
           testLead.Auto_Lead_Convert__c = True;
            Test.startTest();
        try{
           insert testLead; 
        }
        catch(exception ex){
            system.debug('execption '+ex);
        }            
            
            AutoConvertLeads.LeadAssign(new List<Id>{testLead.Id});
            
            //   Database.LeadConvertResult lcr = Database.convertLead(lc);
            //     System.assert(lc.isSuccess());
            Test.stopTest();
        //}
    }

	//CRM-10363: Method added to support Code Security Remediation changes
     static testMethod void Test_LeadConvertForFreightAccNoParentException() {
        LEAD_COUNT += 1;
            TestUtilityDataClassQantas.enableTriggers();
            TestUtilityDataClassQantas.insertQantasConfigData();
            Airport_Code__c aircode = new Airport_Code__c(Name = 'SYD' , Freight_Station_Name__c ='SYDNEY');
            insert aircode;
            
            Lead testLead = new Lead();
            testLead.FirstName = 'Test Firyst17' + LEAD_COUNT;
            testLead.LastName = 'Test Lasty7' + LEAD_COUNT;
            testLead.Company = 'Company created for test';
            testLead.ABN_Tax_Reference__c = '23232323231';
            testLead.Status = 'Qualified';
            testLead.Business_Type__c = 'Freight';
            //testLead.Estimated_Total_Air_Travel_Spend__c = 100;
            testLead.Frequent_Flyer_Number__c = 'abcxyz';
            testLead.Function__c = 'Finance';
            testLead.IATA__c = '8764001';
            testLead.Job_Role__c = 'Board Member';
            testLead.Job_Title__c = 'Mr';
            testLead.Legal_Name__c = 'Test ABC';
            testLead.New_Account_Type__c = 'Freight-Branch';
            testLead.Data_Quality_Score_for_All__c = 100;
            testLead.Street = 'Street';
            testLead.CountryCode = 'AU';
            testLead.City = 'Sydney';            
            testLead.Postalcode = '2005';
            testLead.Salutation = 'Mr.';
            testLead.Email = 'abcd45y3422@xyz.com';
            testLead.Phone = '123456';
            testLead.LeadSource = 'Web';
            testLEad.Industry = 'Manufacturing';
            testLead.Website = 'www.test.com';
            testLead.MobilePhone = '999994991';
            testLead.Freight_eQ_Customer__c = '9999999991';                                  
            testLead.Freight_Corporate_Identifier__c = '99999999999999999991';                                                       
            testLead.Freight_Customer_Code__c = '1234567899';                                                  
            testLead.Freight_Revenue_Stream__c = 'DOM';
            testLead.Freight_Account_Business_Type__c ='Shipper';
            testLead.Freight_Station_Code__c = aircode.id;
            testLead.Auto_Create_Opportunity__c=true;
            testLead.Opportunity_Type__c = 'Agency Partnerships';
           testLead.Auto_Lead_Convert__c = True;
            Test.startTest();
        try{
           insert testLead; 
        }
        catch(exception ex){
            system.debug('execption '+ex);
        }            
            
        try{
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User'];
        User u1 = new User(
            Username = 'testu045600ser@example.com',
            Email = 'testus11145611er@example.com',
            LastName = 'Test',
            FirstName = 'User',
            Alias = 'testu',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u1;
            
            
            System.runAs(u1) {
                AutoConvertLeads.LeadAssign(new List<Id>{testLead.Id});
            }            
        } catch (Exception ex) {
            System.debug(ex);
        }

            Test.stopTest();
        
    }    
    
}