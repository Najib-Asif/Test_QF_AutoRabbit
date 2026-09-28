//Test class : DualDependentPicklistControllerTest
//Controller class for DualControlledDependentPicklist LWC component
public with sharing class DualDependentPicklistController {
    
    @AuraEnabled(cacheable=true)
        public static List<String> getLevel2Values(String objectApiName, String level1FieldApiName, 
                                               String level1Value, String level2FieldApiName){
        if (String.isBlank(objectApiName) || String.isBlank(level1FieldApiName) || 
            String.isBlank(level1Value) || String.isBlank(level2FieldApiName)) {
            return new List<String>();
        }
        else{
            List<Field_Dependency_Config__mdt> configs;
            configs = [
                SELECT Level_2_Value__c FROM Field_Dependency_Config__mdt WHERE Active__c = true 
                AND Object_API__c = :objectApiName AND Level_1_Field__c = :level1FieldApiName
                AND Level_1_Value__c = :level1Value AND Level_2_Field__c = :level2FieldApiName
                AND Level_2_Value__c != '' order by MasterLabel
            ];
            if(configs.isEmpty()){
                return new List<String>();
            }
            List<String> values = new List<String>();
            for(Field_Dependency_Config__mdt config : configs){
				values.add(config.Level_2_Value__c);
            }
            values.sort();
            if(values.indexOf('Other')!=-1){  
                values.remove(values.indexOf('Other'));
                values.add('Other');

            }
            return values;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getLevel3Values(String objectApiName, String level1FieldApiName,String level1Value, 
                                               String level2FieldApiName, String level2Value, String level3FieldApiName){
                                                   
		if (String.isBlank(objectApiName) || String.isBlank(level1FieldApiName) || String.isBlank(level1Value) || 
            String.isBlank(level2FieldApiName) || String.isBlank(level2Value) || String.isBlank(level3FieldApiName)) {
            return new List<String>();
        }
		else{
            List<Field_Dependency_Config__mdt> configs;
            
			configs = [
                SELECT Level_3_Value__c FROM Field_Dependency_Config__mdt WHERE Active__c = true 
                AND Object_API__c = :objectApiName AND Level_1_Field__c = :level1FieldApiName
                AND Level_1_Value__c = :level1Value AND Level_2_Field__c = :level2FieldApiName
                AND Level_2_Value__c = :level2Value AND Level_3_Field__c = :level3FieldApiName
                LIMIT 1
            ];  

            if (configs.isEmpty() || String.isBlank(configs[0].Level_3_Value__c)) {
            	return new List<String>();
        	}
            // Split by newline (handles Windows & Unix)
        	List<String> values = new List<String>();
            
            for (String line : configs[0].Level_3_Value__c.split('\\r?\\n')) {
                if (String.isNotBlank(line)) {
                    values.add(line.trim());
                }
            }
     		values.sort();
            return values;
            }
        
	}
}