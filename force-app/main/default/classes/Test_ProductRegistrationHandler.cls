@isTest
public class Test_ProductRegistrationHandler{
    
    //Added By Praveen For test class failure fix
    @testsetup
    static void createData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        insert lstConfigData;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createProductRegTriggerSetting();
        insert lsttrgStatus;
    }
    
    public static testMethod void testProductRegistrationInsert(){
        
        TestUtilityDataClassQantas.enableTriggers();
        insert new Account_Travel_Frequency__c(Name = 'Travel Frequency', Travel_Frequency__c = '300');
        Test.startTest();
        // Insert Accounts
        List<Account> accList = new List<Account>(); 
        accList.add(new Account(Name = 'Sample1', Active__c = true,
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' 
                               ));
        accList.add(new Account(Name = 'Sample2', Active__c = true, 
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' 
                               ));
        accList.add(new Account(Name = 'Sample3', Active__c = true, 
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' 
                               ));
        accList.add(new Account(Name = 'Sample4', Active__c = true,
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'Y', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' 
                               ));
        accList.add(new Account(Name = 'Sample5', Active__c = true, Manual_Revenue_Update__c = true,
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'N', Dealing_Flag__c = 'Y', Aquire_Override__c = 'N' 
                               ));
        accList.add(new Account(Name = 'Sample6', Active__c = true, 
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'Y', Aquire_Override_Reason__c ='test' 
                               ));
        accList.add(new Account(Name = 'Sample7', Active__c = true, 
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'Y', Aquire_Override_Reason__c ='test'
                               ));
        accList.add(new Account(Name = 'Sample8', Active__c = true,
                                RecordTypeId = TestUtilityDataClassQantas.prospectRecordTypeId, 
                                Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' 
                               ));  
        insert accList;
        
        // Insert trigger 
        
        List<Product_Registration__c> prAqList = new List<Product_Registration__c>();          
        prAqList.add(new Product_Registration__c(Name = 'prAQ', Account__c = accList[0].id, RecordTypeId = TestUtilityDataClassQantas.aquireRecordTypeId, Active__c = true, 
                                                 Stage_Status__c = 'Active', Annual_International_Flights__c = '200-500', Aquire_Membership_End_Date__c = Date.today()));
        prAqList.add(new Product_Registration__c(Name = 'prAQ', Account__c = accList[3].id, RecordTypeId = TestUtilityDataClassQantas.aquireRecordTypeId, Active__c = true, 
                                                 Stage_Status__c = 'Active', Aq_Business_Domestic_annual_spend__c = 100, Aq_Business_international_annual_spend__c = 300));
        prAqList.add(new Product_Registration__c(Name = 'prAQ', Account__c = accList[4].id, RecordTypeId = TestUtilityDataClassQantas.aquireRecordTypeId, Active__c = true, Stage_Status__c = 'Active'));                         
        insert prAqList;
        
        List<Product_Registration__c> prList = new List<Product_Registration__c>(); 
        prList.add(new Product_Registration__c(Name = 'pr1', Account__c = accList[0].id, Customer_s_Requested_Choice__c = 'A', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        prList.add(new Product_Registration__c(Name = 'pr2', Account__c = accList[1].id, Customer_s_Requested_Choice__c = 'A', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        prList.add(new Product_Registration__c(Name = 'pr3', Account__c = accList[2].id, Customer_s_Requested_Choice__c = 'R', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        prList.add(new Product_Registration__c(Name = 'pr4', Account__c = accList[3].id, Customer_s_Requested_Choice__c = 'R', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        prList.add(new Product_Registration__c(Name = 'pr5', Account__c = accList[4].id, Customer_s_Requested_Choice__c = 'R', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        prList.add(new Product_Registration__c(Name = 'pr6', Account__c = accList[5].id, Customer_s_Requested_Choice__c = 'A', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        prList.add(new Product_Registration__c(Name = 'pr7', Account__c = accList[6].id, Customer_s_Requested_Choice__c = 'R', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        prList.add(new Product_Registration__c(Name = 'pr8', Account__c = accList[7].id, Customer_s_Requested_Choice__c = 'R', RecordTypeId = TestUtilityDataClassQantas.amexRecordTypeId, Active__c = true));
        insert prList; 
        
        delete prAqList;
        Test.stopTest();
        //Test.startTest();
        // Update trigger      
        
        List<Product_Registration__c>prAqList2 = new List<Product_Registration__c>();
        prAqList2.add(new Product_Registration__c(Name = 'prAQ2', Account__c = accList[0].id, RecordTypeId = TestUtilityDataClassQantas.aquireRecordTypeId, Active__c = true, 
                                                  Stage_Status__c = 'Active', Annual_International_Flights__c = '200-500', Aquire_Membership_End_Date__c = Date.today()));
        prAqList2.add(new Product_Registration__c(Name = 'prAQ3', Account__c = accList[2].id, RecordTypeId = TestUtilityDataClassQantas.aquireRecordTypeId, Active__c = true, 
                                                  Stage_Status__c = 'Active', Annual_International_Flights__c = '200-500', Aquire_Membership_End_Date__c = Date.today()));                         
        insert prAqList2;
        
        ProductRegistrationHandler.hasRunProcessAMEXEligibilityUpdate = false;   
        
        //Test.stopTest();        
    }
}