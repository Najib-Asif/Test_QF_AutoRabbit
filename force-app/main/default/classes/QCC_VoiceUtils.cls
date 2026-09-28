/*----------------------------------------------------------------------------------------------------------------------
Author:        Darwin Herbert Lubas
Company:       Accenture
Description:   QCC Voice Utility Class 
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
02-Apr-2023      Darwin Herbert Lubas              Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_VoiceUtils {
    /*--------------------------------------------------------------------------------------      
    Method Name:        getEnvSetting
    Description:        reusable apex method that will query environment settings and retrieve a specific setting.
    Parameter:          String settingName
    Return:             String settingValue
    Author:             Darwin Herbert Lubas
    --------------------------------------------------------------------------------------*/     
    @AuraEnabled(cacheAble=true)
    public static Environment_Setting__mdt getEnvSetting(){
        Id orgId = UserInfo.getOrganizationId();
        String orgIdto15 = orgId.to15();
        Environment_Setting__mdt result = new Environment_Setting__mdt();
        List<Environment_Setting__mdt> envMDT = Environment_Setting__mdt.getAll().values();
        for(Environment_Setting__mdt env: envMDT){
            if(env.Org_Id__c == orgIdto15){
                String DevName = env.get('DeveloperName').toString();
                System.debug('DevName: ' + DevName);
                //Environment_Setting__mdt evnSetting = Environment_Setting__mdt.getInstance(DevName);
                result = Environment_Setting__mdt.getInstance(DevName);
                break;
            }
        }
        System.debug('@@@@ result ' + result);
        return result;
    }
    
    public static void insertLogRec(String recTypeName, String businessName, String clsName, String methodName, 
                                   String inboundMSG, String outboundMSG, Boolean isIntegration, String objectId,  String ex){
        
        String recType = CustomSettingsUtilities.getConfigDataMap(recTypeName);
                                       
        Log__c objLog = new Log__c();
        objLog.FailedRecordID__c = objectId;
        objLog.Business_Function_Name__c = businessName;
        objLog.Class_Name__c = clsName;
        objLog.Method_Name__c = methodName;
        objLog.LoggedIn_User__c = UserInfo.getUserName();
        objLog.Inbound_Payload__c = inboundMSG;
        objLog.Outbound_Payload__c = outboundMSG;
        objLog.Is_Integration_Error__c = isIntegration;
        objLog.RecordTypeId = GenericUtils.getObjectRecordTypeId('Log__c', recType);
        objLog.Sent_Received_Date_Time__c = isIntegration == true?system.now(): Null;
        
        if(ex != Null){
            objLog.Error_Message__c = ex;
            insert objLog;
        }else{
            insert objLog;
        }
    }
    
    public static Boolean checkIfValidEmail (String emailInput) {
        String inputString = emailInput;
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern emailPattern = Pattern.compile(emailRegex);
        
        Matcher emailMatcher = emailPattern.matcher(inputString);
        
        if (!emailMatcher.matches()) {
            return FALSE;
        }
        else {
            return TRUE;
        }
    } 
    //Method to validate the phone format
    public static String checkIfValidPhone (String phoneInput)
    {
        String outputPhone; 
        if(phoneInput!='' && phoneInput!=null)
        {
               
        String inputPhone=phoneInput.replaceAll('[^0-9.+]', '');
        system.debug('>>>The value of inputPhone'+inputPhone);
        inputPhone=inputPhone.trim();
        inputPhone=inputPhone.deleteWhitespace();
        system.debug('>>>The value of inputPhone after trim and whitespace removal'+inputPhone);
        
        Integer strLength=inputPhone.length();
        system.debug('>>>The value of strLength'+strLength);
        
        String[] inputPhoneSplt=inputPhone.split('');
        String charAtZero=inputPhoneSplt[0];
        system.debug('>>>The value of charAtZero'+charAtZero);
        
        String chatAtTwo=inputPhoneSplt[2];
        system.debug('>>>The value of chatAtTwo'+chatAtTwo);
        
        String chatAtThree=inputPhoneSplt[3];
        system.debug('>>>The value of chatAtThree'+chatAtThree);
        
        if(inputPhone!=null && inputPhone!='')
        {
            if(charAtZero=='+' && strLength==12)
            {
                 outputPhone=inputPhone;
                 system.debug('>>>The value of outputPhone after first If check'+outputPhone);
            }
            else if(charAtZero=='+' && strLength==13 && chatAtThree=='0')
            {
                 outputPhone=removeChar(inputPhone,3);
                 system.debug('>>>The value of outputPhone after second If check'+outputPhone);
            }
            else if(charAtZero!='+' && charAtZero=='0' && strLength==10)
            {
                 outputPhone=removeChar(inputPhone,0);
                 system.debug('>>>The value of outputPhone after third If check'+outputPhone);
            }
            else if(charAtZero!='+' && strLength==11)
            {
                 outputPhone=addChar(inputPhone,0);
                 system.debug('>>>The value of outputPhone after fourth If check'+outputPhone);
            }
            else if(charAtZero!='+' && chatAtTwo=='0' && strLength==12)
            {
                 outputPhone=removeChar(inputPhone,2);
                 outputPhone=addChar(outputPhone,0);
                 system.debug('>>>The value of outputPhone after fifth If check'+outputPhone);
            }
            else 
            {
                outputPhone=inputPhone;
                system.debug('>>>The value of outputPhone after last Else check'+outputPhone);
            }
        }
        }
        
        return outputPhone;
    } 
    
    //Method added to remove a character from the given index
    private static string removeChar(String source, Integer index) 
    {
        return source.left(index)+source.right(source.length()-index-1);
    } 
    //Method added to add a character at the given index
    private static string addChar(String source, Integer index) 
    {
        return source.left(index)+'+'+source.right(source.length()+index);
    } 
}