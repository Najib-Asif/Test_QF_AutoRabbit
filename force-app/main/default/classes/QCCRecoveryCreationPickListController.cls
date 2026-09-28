/*----------------------------------------------------------------------------------------------------------------------
Author:        Navya Gamid
Company:       Qantas
Description:   Retrieve Recovery records and send to EQ system
Inputs:
Test Class:    QCCRecoveryCreationControllerTest.cls 
************************************************************************************************
History
************************************************************************************************
02-AUG-2024      Navya              Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class QCCRecoveryCreationPickListController {
    //Method to get Recovery Reasson picklist values based on Recovery Type field
    @AuraEnabled(cacheable=true)
    public static List<PicklistValueWrapper> getDependentPicklistValues(String objectName, String controllingField, String dependentField,String controllingValue)
    {
        Map<String, String> controllingInfo = new Map<String, String>();
    
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
    
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
    
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
    
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
    
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;
    
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
    
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
    
                if((val & 8) == 8)
                {
                   
                    if(controllingValues[baseCount + 0].getValue().equals(controllingValue) ){
                        controllingInfo.put(currDependentValue.getLabel(),currDependentValue.getLabel());
                    }
                }
                if((val & 4) == 4)
                {
                   
                    if(controllingValues[baseCount + 1].getValue().equals(controllingValue) ){
                        controllingInfo.put(currDependentValue.getLabel(),currDependentValue.getValue());     
                    }           
                }
                if((val & 2) == 2)
                {
                    
                    if(controllingValues[baseCount + 2].getValue().equals(controllingValue) ){
                        controllingInfo.put(currDependentValue.getLabel(),currDependentValue.getValue());
                    }
                    //controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    
                    if(controllingValues[baseCount + 3].getValue().equals(controllingValue) ){
                        controllingInfo.put(currDependentValue.getLabel(),currDependentValue.getValue());
                    }                   
                }
    
                baseCount += 4;
            }            
        } 
        List<PicklistValueWrapper> picklistValues = new List<PicklistValueWrapper>();
        Set<String> keys = controllingInfo.keySet();
        for (String key : keys) {
            String value = controllingInfo.get(key);
            picklistValues.add(new PicklistValueWrapper(key, value));
        }
    
        return picklistValues;
    }
    
    //Method to get recovery Type picklist values
    @AuraEnabled(cacheable=true)
    public static List<PicklistValueWrapper> getPicklistValues(String objectApiName, String fieldApiName) {
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        Schema.DescribeFieldResult fieldResult = sObjectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe();

        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        List<PicklistValueWrapper> picklistValues = new List<PicklistValueWrapper>();

        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(new PicklistValueWrapper(entry.getLabel(), entry.getValue()));
        }

        return picklistValues;
    }

    
    public class MyPickListInfo
   {
        public String validFor;
   }
   // Wrapper class for picklist values
   public class PicklistValueWrapper {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }

    public PicklistValueWrapper(String label, String value) {
        this.label = label;
        this.value = value;
    }
}
}