/*----------------------------------------------------------------------------------------------------------------------
Author:          Priyadharshini Vellingiri
Company:         TCS
Description:    
Inputs:
Test Class:      
************************************************************************************************
History
************************************************************************************************
 27-Apr-2018           Priyadharshini Vellingiri      Initial Design       
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QL_GenericUtils {
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getCAPValidToken
    Description:        get CAP ValidToken from CAP system while invoking the Service
    Parameter:          
    --------------------------------------------------------------------------------------*/  
    public static String getCAPValidToken(String tokenType){
        System.debug('getCAPValidToken ' + tokenType);
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI(tokenType);
        System.debug('ZZZin GenUtil token val in CS (old): '+qantasAPI.Token__c);        
        String tokenVal = '';
        if(qantasAPI.LastModifiedDate < System.now().addHours(-45) || qantasAPI.Token__c == Null ){
            QL_CAPCRETokenWrapper token;
            try {
                token = QL_InvokeCAPCREAPI.invokeTokenCapAPI(qantasAPI);  
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
            
            if(token == null) return null;
            
            system.debug('token#####'+token);
            tokenVal = token.token_type+' '+token.access_token;
            tokenVal = tokenVal.capitalize();
            //QCC_GenericUtils.updateToken(tokenVal, tokenType);
        }
        else{
            tokenVal = qantasAPI.Token__c;
        }
        return tokenVal;
    } 
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        updateToken
    Description:        Update token if not matching with the current value in custom setting
    Parameter:          
    --------------------------------------------------------------------------------------*/  
    public static void updateToken(String token, string settingName){
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI(settingName);
        
        if(qantasAPI.Token__c != token)
        {
            qantasAPI.Token__c = token;
            update qantasAPI;
        }
        
    } 
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchContact
    Description:        Fetch Contact Details
    Parameter:          CaseWrapper
    --------------------------------------------------------------------------------------*/ 
    // public static List<Contact> fetchContact(QCCCaseWrapper qccCaseWrap){
    //   List<Contact> lstCon = new List<Contact>();
    //   if(!String.isBlank(qccCaseWrap.capId)){
    //    lstCon = [Select Id, AccountId from Contact where CAP_ID__c  =: qccCaseWrap.capId];
    //    }else if(!String.isBlank(qccCaseWrap.ffNumber)){
    //        lstCon = [Select Id, AccountId from Contact where Frequent_Flyer_Number__c =: qccCaseWrap.ffNumber];
    //    }
    //    return lstCon;
    //}
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        mogrifyJSON
    Description:        Json for Invoke CAP system
    Parameter:          String,Map
    --------------------------------------------------------------------------------------*/ 
    public static String mogrifyJSON(String data, Map<String, String> replacements) {
        // Regex to match the start of the line and the key
        // surrounded by quotes and ending with a colon
        String regexFormat = '(?m)^\\s*"{0}"\\s*:';
        
        // Replacement format of the new key surrounded by
        // quotes and ending with a colon
        String replacementFormat = '"{0}" :';
        
        // Since our JSON can come in formatted however the
        // endpoint wants, we need to format it to a standard
        // we know and can handle
        String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
        
        // Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            // Generate our regex based on the key
            String regex = String.format(
                regexFormat,
                new List<String> {key}
            );
            
            // Generate our replacement
            String replacement = String.format(
                replacementFormat,
                new List<String> {replacements.get(key)}
            );
            
            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
        
        return formattedJSON;
    }
}