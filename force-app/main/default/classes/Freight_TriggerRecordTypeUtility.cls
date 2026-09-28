/*-----------------------------------------------------------------------------------------------------------------------------
Author:        Jayaraman Jayaraj
Company:       TCS
Description:   This is utility class to seggregate the records based on the record types.
Test Class:    Test_TriggerRecordTypeUtility
*********************************************************************************************************************************
*********************************************************************************************************************************
History
Abhijeet P          Added Method for creation for Custom Setting data, for Test Class utility.        
********************************************************************************************************************************/

Public class Freight_TriggerRecordTypeUtility{
    
        
    /*--------------------------------------------------------------------------------------      
    Method Name:        returnAccountTriggerMap
    Description:        Method to return Trigger map, based on the category of Account data.
    Parameter:          Account Map, String (Category as in Sales/Freight), String(Object type)
    --------------------------------------------------------------------------------------*/    
    
    public  map<Id, Account> returnAccountTriggerMap(map<Id, Account> triggerMap, String category, String objectType){
        
        // Map to return in the form of newMap or oldMap
        map<Id,Account> returnMap = new map<Id,Account>();
        
        // Map to hold Key as RecordTypeid and Value as Category (Sales or Freight)
        map<String, String> mapRecordTypeVsCategory = returnRecordTypeSettingMap(category, objectType);
                
        // Populating Account New or Old Map based Category (Sales or Freight).
        if(triggerMap != null){
            for(Account eachAccount : triggerMap.values()){
                
                // Validating the recordtype for each Category and Object
                if(mapRecordTypeVsCategory.containsKey(eachAccount.RecordTypeId)){
                    returnMap.put(eachAccount.Id,eachAccount);
                }
            }   
        }
        return returnMap;
    }
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        returnRecordTypeSettingMap
    Description:        Method to record type setting data Based on Category and Object
    Parameter:          Strings, in the form of Category and Object
    --------------------------------------------------------------------------------------*/ 
    
    public map<String, String> returnRecordTypeSettingMap(string category, string objectType){
        
        // Getting all the recordtype values from custom setting
        list<Freight_RecordTypeSeggregation__c> recordTypeSettings = Freight_RecordTypeSeggregation__c.getall().values();
        
        // map to be returned based for recordTypeId and category
        map<String, String> returnMap = new map<String, String>();
        
        // Considering relevant recordTypes for Account and relevant category
        for(Freight_RecordTypeSeggregation__c eachSetting : recordTypeSettings){
            if(eachSetting.Category__c == category && eachSetting.ObjectType__c == objectType){
                returnMap.put(eachSetting.RecordTypeId__c,eachSetting.Category__c);   
            }
        }
        return returnMap;        
    }
      
    /*--------------------------------------------------------------------------------------      
    Method Name:        createAccTrigTestCustomSetting
    Description:        Method to create Custom Setting data for test classes
    Parameter:          NA
    --------------------------------------------------------------------------------------*/    
    public static List<Freight_RecordTypeSeggregation__c> createAccTrigTestCustomSetting(){
      
        List<Freight_RecordTypeSeggregation__c> listRecordTypeCustomSettingData = new List<Freight_RecordTypeSeggregation__c>();
      
        Freight_RecordTypeSeggregation__c customSettingRecord = new Freight_RecordTypeSeggregation__c();
      
        // Agency Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Agency_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);

        // Charter Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Charter_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Charter Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);

        // Customer Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Customer_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);       
        
        
        // Freight Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Account', Category__c = 'Freight', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        
        // Global Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Global_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        
        /*CRM-2943 Delete 'New Account' Recordtype
        // New Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'New_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('New Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);*/
        
        // Other Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Other_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Other Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
      
        // Prospect Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Prospect_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
      
        // Regional Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Regional_Account', Category__c = 'Sales', ObjectType__c = 'Account',
                                            RecordTypeId__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Regional Account').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        
        // Regional Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Business and Government', Category__c = 'Sales', ObjectType__c = 'Opportunity',
                                            RecordTypeId__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Business_and_Government').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        
         // Regional Account Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Global_opportunity', Category__c = 'Sales', ObjectType__c = 'Opportunity',
                                            RecordTypeId__c = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Global opportunity').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        
        // Regional Case Freight claims Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Claims', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Claims').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        // Regional Case Freight Email to Case Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Email_to_Case', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Email to Case').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        // Regional Case Freight Feedback Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Feedback', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Feedback').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        // Regional Case Freight Invoicing Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Invoicing', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Invoicing').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        // Regional Case Freight Query Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Query', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Query').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        // Regional Case Freight Shipment Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Shipment', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Shipment').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        // Regional Case Freight Track & Trace Exceptions Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Freight_Track_Trace_Exceptions', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Track & Trace Exceptions').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        // Regional Case Qantas Freight Custom Setting Record Added.
        customSettingRecord = new Freight_RecordTypeSeggregation__c(Name = 'Qantas_Freight', Category__c = 'Freight', ObjectType__c = 'Case',
                                            RecordTypeId__c = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Qantas Freight').getRecordTypeId());
        listRecordTypeCustomSettingData.add(customSettingRecord);
        
       
      
        return listRecordTypeCustomSettingData; 
    }
    
}