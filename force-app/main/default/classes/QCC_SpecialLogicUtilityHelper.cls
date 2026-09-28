/*********************************************************************************
Name         : QCC_SpecialLogicUtilityHelper
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 July 2019
Usages       : This class is used to generate values for those metadata record that is marked as Has_Special_Logic__c = true
*********************************************************************************/
public class QCC_SpecialLogicUtilityHelper {    
    //@Purpose: This method is used to generate values for those fields which is tagged as Has_Special_Logic__c = true
    //@input paremeters:
    //  1. moduleName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Module_Name__c).
    //  2. filterCondition - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Filter_Condition__c).
    //@return type: String value that will be typeCast later on different method
    public static String generateAdditionalFilterForDynamicSOQL(String moduleName, String filterCondition) {
        String queryFilter = '';
        Map<String, String> filterMap = new Map<String, String>();

        //Get all filter metadata records
        List<QCC_SOQL_Filter_Setting__mdt> filterMetadataRecords = [
            SELECT Id, DeveloperName, Field_Name__c, Condition__c,
            Field_Value__c, Has_Special_Logic__c, Special_Logic_Name__c
            FROM QCC_SOQL_Filter_Setting__mdt
            WHERE Module_Name__c =: moduleName
        ];

        if (!filterMetadataRecords.isEmpty()) {
            //Generate the filter value per metadata record
            for(QCC_SOQL_Filter_Setting__mdt filterMetadata : filterMetadataRecords) {
                String fieldValue = filterMetadata.Field_Value__c;
                if (filterMetadata.Has_Special_Logic__c) {
                    if (filterMetadata.Special_Logic_Name__c == 'addDaysToToday') {
                        fieldValue = addDaysToToday(fieldValue);
                    }
                }

                String filter = filterMetadata.Field_Name__c + ' ' + filterMetadata.Condition__c + ' ' + fieldValue;
                filterMap.put(filterMetadata.DeveloperName, filter);
            }
            System.debug('filterMap: ' + filterMap);

            //Replace the queryFilter string based on the Developername of the metadata records.
            queryFilter = filterCondition;
            for (String filterKey : filterMap.keySet()) {
                if (queryFilter.indexOf(filterKey) != -1) {
                    queryFilter = queryFilter.replace(filterKey, filterMap.get(filterKey));
                }
            }
        }

        System.debug('queryFilter: ' + queryFilter);

        return queryFilter;
    }

    //@Purpose: This method is used to generate values for those fields which is tagged as Has_Special_Logic__c = true
    //@input paremeters:
    //  1. moduleName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Module_Name__c).
    //  2. filterCondition - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Filter_Condition__c).
    //@return type: String value that will be typeCast later on different method
    public static String generateFilterForDynamicSOQL(String moduleName, String filterCondition) {
        String queryFilter = '';
        Map<String, String> filterMap = new Map<String, String>();
        
        //Get all filter metadata records
        List<QCC_SOQL_Filter_Setting__mdt> filterMetadataRecords = [
            SELECT Id, DeveloperName, Field_Name__c, Condition__c, Field_Value__c, Has_Special_Logic__c 
            FROM QCC_SOQL_Filter_Setting__mdt
            WHERE Module_Name__c =: moduleName
        ];
        
        if (!filterMetadataRecords.isEmpty()) {
            //Generate the filter value per metadata record
            for(QCC_SOQL_Filter_Setting__mdt filterMetadata : filterMetadataRecords) {
                String fieldValue = filterMetadata.Field_Value__c;
                if (filterMetadata.Has_Special_Logic__c) {
                    if(moduleName == Label.QCC_Qantas_Host_Report_Disruption){
                        fieldValue = generateFilterWhenModuleIsQantasHostReportDisruption(
                            filterMetadata.Field_Name__c, 
                            filterMetadata.Field_Value__c
                        );
                    }
                }
                
                String filter = filterMetadata.Field_Name__c + ' ' + filterMetadata.Condition__c + ' ' + fieldValue;
                filterMap.put(filterMetadata.DeveloperName, filter);
            }
            System.debug('filterMap: ' + filterMap);
            
            //Replace the queryFilter string based on the Developername of the metadata records.
            queryFilter = ' WHERE ' + filterCondition;
            for (String filterKey : filterMap.keySet()) {
                if (queryFilter.indexOf(filterKey) != -1) {
                    queryFilter = queryFilter.replace(filterKey, filterMap.get(filterKey));
                }
            }
        }
        
        System.debug('queryFilter: ' + queryFilter);
        
        return queryFilter;
    }
    
    //@Purpose: This method is used to generate values for those fields which is tagged as Has_Special_Logic__c = true
    //@input paremeters:
    //  1. moduleName - The module name of the batch job that is running (QCC_SOQL_Settings__mdt.Module_Name__c).
    //  2. fieldName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Target_Field__c).
    //  3. fieldValue - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Default_Value__c).
    //@return type: String value that will be typeCast later on different method
    public static String generateValueForFieldWithSpecialLogic(String moduleName, String fieldName, String fieldValue, Map<String, List<sObject>> otherRefDataMap) {
        if (moduleName == 'checkPortsWithCurfew') {
            fieldValue = checkPortsWithCurfew(fieldName, fieldValue, otherRefDataMap);
        } else if (moduleName == 'addDaysToToday'){
            fieldValue = addDaysToToday(fieldValue);
        } else if (moduleName == 'effectiveTierToFrequentFlyerTier'){
            fieldValue = effectiveTierToFrequentFlyerTier (fieldName, fieldValue, otherRefDataMap);
        } else if (moduleName == 'assignCaseToQueue'){
            fieldValue = assignCaseToQueue(fieldName, fieldValue, otherRefDataMap);
        } else if (moduleName == 'getReferenceSObjectId'){
            fieldValue = getReferenceSObjectId(fieldName, fieldValue, otherRefDataMap);
        } else if (moduleName == 'convertDateToDateTimeString'){
            fieldValue = convertDateToDateTimeString(fieldValue);
        } else if (moduleName == 'getCaseRecordTypeIDByDeveloperName'){
            fieldValue = getCaseRecordTypeIDByDeveloperName(fieldValue);
        } else if (moduleName == 'removeLeadingZero'){
            fieldValue = QCC_UtilityHelper.removeLeadingZero(fieldValue);
        }else if (moduleName == 'getQantasConfigValue'){
            fieldValue = getQantasConfigValue(fieldValue);
        }else if(moduleName == 'replaceCommaWithSemicolon'){
            fieldValue = replaceCommaWithSemicolon(fieldValue);
        }else if(moduleName == 'getContactByFrequentFlyerNumber'){
            //Remove the leading zero before reusing the logic to get the Contact Id from otherRefDataMap
            fieldValue = QCC_UtilityHelper.removeLeadingZero(fieldValue);
            fieldValue = getReferenceSObjectId(fieldName, fieldValue, otherRefDataMap);
        }
        
        System.debug('>>>fieldValue: ' + fieldValue);
        
        return fieldValue;
    }
    
    //@Purpose: This method is used to Replace comma to Semicolon
    //@input paremeters:
    //  1. fieldValue - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Default_Value__c).
    //@return type: String value that will be typeCast later on different method
    public static String replaceCommaWithSemicolon(String fieldValue) {
        fieldValue = fieldValue.replace(',', ';');
        System.debug('fieldValue: ' + fieldValue);
        return fieldValue;
    }
    
    //@Purpose: This method is used to get Qantas Config Value from custom settings by Name
    //@input paremeters:
    //  1. fieldName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Target_Field__c).
    //  2. fieldValue - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Default_Value__c).
    //@return type: String value that will be typeCast later on different method
    public static String getQantasConfigValue(String fieldValue) {
        fieldValue = CustomSettingsUtilities.getConfigDataMap(fieldValue);
        System.debug('fieldValue: ' + fieldValue);
        return fieldValue;
    }

    //@Purpose: This method is used to get Case Record Type id using developerName
    //@input paremeters:
    //  1. fieldName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Target_Field__c).
    //  2. fieldValue - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Default_Value__c).
    //  3. otherRefDataMap - Queue map Map<Queue DeveloperName, List<Queue info>>
    //@return type: String value that will be typeCast later on different method
    public static String getCaseRecordTypeIDByDeveloperName(String fieldValue) {
        fieldValue = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(fieldValue).getRecordTypeId();
        System.debug('fieldValue: ' + fieldValue);
        return fieldValue;
    }
    
    
    //@Purpose: This method is used to convert get corresponding Frequent Flyer Tier from Effective Tier
    //@input paremeters:
    //  1. fieldName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Target_Field__c).
    //  2. fieldValue - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Default_Value__c).
    //  3. otherRefDataMap - Queue map Map<Queue DeveloperName, List<Queue info>>
    //@return type: String value that will be typeCast later on different method
    public static String assignCaseToQueue(String fieldName, String fieldValue, Map<String, List<sObject>> otherRefDataMap) {
        for(String str : otherRefDataMap.keySet()){
            if(str == fieldValue){
                for(sObject sObectjREc : otherRefDataMap.get(fieldValue)){
                    fieldValue = sObectjREc.Id; // Queue Id
                }
            }
        }
        System.debug('fieldValue: ' + fieldValue);
        return fieldValue;
    }

    //@Purpose: This method is used to convert get corresponding Frequent Flyer Tier from Effective Tier
    //@input paremeters:
    //  1. fieldName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Target_Field__c).
    //  2. fieldValue - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Default_Value__c).
    //@return type: String value that will be typeCast later on different method
    public static String effectiveTierToFrequentFlyerTier(String fieldName, String fieldValue, Map<String, List<sObject>> otherRefDataMap) {
        fieldValue = CustomSettingsUtilities.getConfigDataMap(fieldValue); //Setting to get Tier code description.
        System.debug('fieldValue: ' + fieldValue);
        return fieldValue;
    }
    
    //@Purpose: This method is used to generate values for all the fields for Quarterly Health Check Call
    //@input paremeters:
    //  1. fieldName - The field name in the custom metadata (QCC_SOQL_Settings__mdt.Target_Field__c).
    //  2. fieldValue - The field value in the custom metadata (QCC_SOQL_Settings__mdt.Default_Value__c).
    //@return type: String value that will be typeCast later on different method
    public static String addDaysToToday(String fieldValue) {
        fieldValue = String.valueOf(System.today().addDays(Integer.valueOf(fieldValue)));
        System.debug('fieldValue: ' + fieldValue);
        return fieldValue;
    }

    //@Purpose: This method is used to generate values for all the fields for Qantas Host Report Disruption
    //@input paremeters:
    //  1. fieldName - The field name in the custom metadata (QCC_SOQL_Filter_Setting__mdt.Field_Name__c).
    //  2. fieldValue - The field value in the custom metadata (QCC_SOQL_Filter_Setting__mdt.Field_Value__c).
    //@return type: String value that will be typeCast later on different method
    public static String generateFilterWhenModuleIsQantasHostReportDisruption(String fieldName, String fieldValue) {
        if (fieldName == 'Event__r.ScheduledDepDate__c') {
            fieldValue = String.valueOf(System.today().addDays(Integer.valueOf(fieldValue)));
        }
        return fieldValue;
    }

    //@Purpose: This method is used to check curfew custom metadata type table to determin if a specific port has curfew times
    //@input paremeters:
    //  1. fieldName - The field name in the custom metadata (QCC_SOQL_Filter_Setting__mdt.Field_Name__c).
    //  2. fieldValue - The field value in the custom metadata (QCC_SOQL_Filter_Setting__mdt.Field_Value__c).
    //  3. otherRefDataMap - Any data that needs to be used for determining the fieldValue (optional)
    //@return type: String value that will be typeCast later on different method
    public static String checkPortsWithCurfew (String fieldName, String fieldValue, Map<String, List<sObject>> otherRefDataMap) {
        system.debug('>>>fieldName: ' + '=' + fieldValue);
        String portCode = fieldValue.substringBefore('-');
        String departureTime = fieldValue.substringAfter('-');
        //Integer hh = Integer.valueOf(departureTime.substringBefore(':'));
        //Integer mm = Integer.valueOf(departureTime.substringAfter(':'));
        //system.debug('>>>checkPortsWithCurfew - time:' + hh + ':' + mm);  
        Time covertedtDepartureTime = QCC_UtilityHelper.parseStringtoTime (departureTime);
        system.debug('>>>checkPortsWithCurfew - covertedtDepartureTime:' + covertedtDepartureTime);  
        
        for (String curefewId : otherRefDataMap.keySet()) {
            for (sObject curefewRec : otherRefDataMap.get(curefewId)) {
                String curefewPort = String.valueOf(curefewRec.get('QCC_Port__c'));
                //Time curfewStartTime = QCC_UtilityHelper.parseStringtoTime(String.valueOf(curefewRec.get('QCC_Start_Time__c')));
                Time curfewStartTime = (Time)curefewRec.get('QCC_Start_Time__c');
                //Time curfewEndTime = QCC_UtilityHelper.parseStringtoTime(String.valueOf(curefewRec.get('QCC_End_Time__c')));
                Time curfewEndTime = (Time)curefewRec.get('QCC_End_Time__c');
                system.debug('>>>checkPortsWithCurfew - curfewStartTime: ' + curfewStartTime);
                system.debug('>>>checkPortsWithCurfew - curfewEndTime: ' + curfewEndTime);
                
                //if (curefewPort == portCode && covertedtDepartureTime >= curfewStartTime && covertedtDepartureTime <= curfewEndTime) {
                if (curefewPort == portCode && !(covertedtDepartureTime >= curfewEndTime && covertedtDepartureTime <= curfewStartTime)) {
                    fieldValue = 'TRUE';
                    break;
                }
                
            }
            system.debug('>>>checkPortsWithCurfew - fieldValue: ' + fieldValue);
            if (fieldValue == 'TRUE') {
                break;
            }
        }
        
        return fieldValue;
    }

    //@purpose: Get ID reference from Map via mapKey
    //@params: String, String, Map<String,List<sObject>> 
    //@return: Id of targeted sObject
    public static String getReferenceSObjectId(String fieldName, String fieldValue, Map<String,List<sObject>> otherRefDataMap) {
        String sObjectId = null;
        for(String str : otherRefDataMap.keySet()){
            if(str == fieldValue){
                for(sObject sObectjREc : otherRefDataMap.get(fieldValue)){
                    sObjectId = sObectjREc.Id; // reference sObject ID
                }
            }
        }
        System.debug('>>>fieldValue: ' + sObjectId);
        return sObjectId;
    }

    //@purpose: Convert YYYY-MM-DD HH:MM:SS to DD/MM/YYYYY HH:MM:SS
    //@param: String
    //@return String DD/MM/YYYYY HH:MM:SS
    public static string convertDateToDateTimeString( String fieldValue){
        //survey response: fieldValue 2019-11-12 
        //String test= String.valueOf(surveyDepartureDate.day()) + '/'+ String.valueOf(surveyDepartureDate.month()) + '/'+ String.valueOf(surveyDepartureDate.Year()) + ' 00:00:00';
        //2019-11-13 00:00:00
        System.debug('>>>convertDateToDateTimeString');
        System.debug('>>>fieldValue'+fieldValue);
        String dateTimeStr = '';
        if(!String.isEmpty(fieldValue)){
            fieldValue = fieldValue.left(10);
            List<String> splitValue = fieldValue.split('-');
            datetimeStr = splitValue[2] + '/' + splitValue[1] + '/' + splitValue[0] + ' 00:00:00';
        }
        
        System.debug('>>>datetimeStr'+datetimeStr);
        return datetimeStr;
    }

}