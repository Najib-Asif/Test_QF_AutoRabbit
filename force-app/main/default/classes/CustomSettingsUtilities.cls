/*----------------------------------------------------------------------- 
File name:      CustomSettingsUtilities.cls
Author:         Praveen Sampath
Company:        Capgemini  
Description:    This class is created as Utill class for Custom Settings.
Test Class:     
Created Date :  28/10/2016
<Date>      <Authors Name>     <Brief Description of Change>
************************************************************************************************
History
************************************************************************************************
05-May-2017    Praveen S               Added  getAmexResponseCodeForAccount and getAllAmexResponseCode Methods
31-Oct-2017    Praveen S               Added  getToken Method
31-Oct-2017    Praveen S               Added  getQantasCAPAPI Method
------------------------------------------------------------------------------------------------*/
public without sharing class CustomSettingsUtilities{ // CRM 13075 added without sharing as this class is  retrieving Qantas_API__c records
    @TestVisible private static Boolean QueryExceptionforTest = false;
     
    //Returns an individual record value from QantasConfigData__c custom setting. If the record is not found for the input parameters, it returns null.
    public static String getConfigDataMap(String paramName){
            if (paramName != ''){
                if(QantasConfigData__c.getValues(paramName)!=null){
                    QantasConfigData__c configData = QantasConfigData__c.getValues(paramName);
                    string confVal = configData.Config_Value__c;
                    return confVal;
                }
            }           
        return ''; 
    }

    //Returns an individual record value from QCC_BookingCodeMappings__c custom setting. If the record is not found for the input parameters, it returns null.
    public static String getBookingCodeMapping(String paramName){
            if (paramName != ''){
                if(QCC_BookingCodeMappings__c.getValues(paramName)!=null){
                    QCC_BookingCodeMappings__c configData = QCC_BookingCodeMappings__c.getValues(paramName);
                    string confVal = configData.Value__c;
                    return confVal;
                }
            }           
        return ''; 
    }

    //Returns an individual record value from AirlineCarrierCodes__c custom setting. If the record is not found for the input parameters, it returns null.
    public static String getAirlineCarrierCodes(String paramName){
            if (paramName != ''){
                if(AirlineCarrierCodes__c.getValues(paramName)!=null){
                    AirlineCarrierCodes__c configData = AirlineCarrierCodes__c.getValues(paramName);
                    string confVal = configData.Value__c;
                    return confVal;
                }
            }           
        return ''; 
    }
    
   
    //Returns an individual record value from Qantas_API__c custom Object. If the record is not found for the input parameters, it returns null.
    public static Qantas_API__c getQantasCAPAPI(String paramName){
            if (paramName != ''){
                List<Qantas_API__c> qantasAPI =[ Select Name, ClientId__c, ClientSecret__c, EndPoint__c, GrantType__c,
                                           Method__c, Token__c, Scope__c, LastModifiedDate, QCC_Extended_Scope__c from Qantas_API__c where Name =: paramName];
                if(qantasAPI!=null && qantasAPI.size() > 0){
                    return qantasAPI[0];
                }
            }           
        return null; 
    }

    //Returns Map of AMEX_Response_Code_Setting__mdt Custom metadata.
    public static Map<String, String> getAllAmexResponseCode(){
        Map<String, String> mapAmexResCode = new Map<String, String>();
        for(AMEX_Response_Code_Setting__mdt amexCode: [ Select Id, Travel_Agent__c, Corporate_Deal__c, QBR_Override__c, 
                                                        Customer_Requested_Choice__c, AMEXResponseCode__c from 
                                                        AMEX_Response_Code_Setting__mdt ] )
        {
            String mapKey = 'ARC_'+''+amexCode.Travel_Agent__c+''+amexCode.Corporate_Deal__c+''+amexCode.QBR_Override__c+''+amexCode.Customer_Requested_Choice__c;
            mapAmexResCode.put(mapKey, amexCode.AMEXResponseCode__c);
        }
        return mapAmexResCode;
    }

    //Returns Map of AMEX_Response_Code_Setting__mdt Custom metadata.
    public static String getAmexResponseCodeForAccount( Map<String, String> mapAmexResCode, String agency, String corporateDeal, 
                                                        String qbrOverride, String customerChoise ){
        String  amexCode;
        String amexResCodeKey = 'ARC_'+''+agency+''+corporateDeal+''+qbrOverride+''+customerChoise;
        amexCode = mapAmexResCode.containsKey(amexResCodeKey)?mapAmexResCode.get(amexResCodeKey):'';        
        return amexCode;
    }

    //Returns Map of Conga_Email_Template_Config__mdt Custom metadata.
    public static Map<String, String> getCongaEmailTemplateId(){
        Map<String, String> mapCongaTemplateId = new Map<String, String>();
        for(Conga_Email_Template_Config__mdt template: [ SELECT Id, DeveloperName, MasterLabel, Label, Record_Type_Name__c, Case_Type__c, Email_Template__c, 
                                                            Email_Template_Id__c, Record_Type_Id__c 
                                                         FROM Conga_Email_Template_Config__mdt ] )
        {
            String mapKey = template.Record_Type_Id__c+':'+template.Case_Type__c+':'+template.Email_Template__c;
            mapCongaTemplateId.put(mapKey, template.Email_Template_Id__c);
        }
        return mapCongaTemplateId;
    }

}