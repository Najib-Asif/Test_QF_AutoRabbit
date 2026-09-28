/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Class to create Application Error Logs and Integration Logs
Inputs:
Test Class:    Functional testing will cover this class. 
************************************************************************************************
History
************************************************************************************************
27-Oct-2016    Praveen Sampath          Initial Design
07-Mar-2016    Praveen Sampath          Added createDeleteLog Method and DeleteLogWrapper
-----------------------------------------------------------------------------------------------------------------------*/
public class CreateLogs {

    public static void insertLogRec(String recTypeName, String businessName, String clsName, String methodName,
                                    String inboundMSG, String outboundMSG, Boolean isIntegration, String objectId,  Exception ex)
    {
        String recType = CustomSettingsUtilities.getConfigDataMap(recTypeName);    
        CreateLogs.LogWrapper logWrap = new CreateLogs.LogWrapper( businessName, clsName, methodName, UserInfo.getUserName(), inboundMSG, 
                                                                   outboundMSG, isIntegration, recType );

        Log__c objLogs = CreateLogs.createLogRec(logWrap, objectId);
        if(ex != Null){
            CreateLogs.createApplicationLog(objLogs, ex);
        }else{
            insert objLogs;
        }
    }

    public static Log__c insertLogBatchRec(String recTypeName, String businessName, String clsName, String methodName,
                                           Id objectId,  List<String> lstErrorMsg)
    {
        String recType = CustomSettingsUtilities.getConfigDataMap(recTypeName);  

        CreateLogs.LogWrapper logWrap = new CreateLogs.LogWrapper( businessName, clsName, methodName, UserInfo.getUserName(), '', 
                                                                   '', false, recType );

        Log__c objLogs = CreateLogs.createLogRec(logWrap, objectId);
        // objLogs.Exception_Type__c = errorMsg.getStatusCode();
        for(String err : lstErrorMsg) {
            objLogs.Error_Message__c = objLogs.Error_Message__c != Null && objLogs.Error_Message__c != ''?objLogs.Error_Message__c: ''+'  '+err;
        }
        return objLogs;
        
    }

   /*--------------------------------------------------------------------------------------      
    Method Name:        createApplicationLog
    Description:        Method to Create Application Error Logs
    Parameters :        objLog --> Record
                        mainExc --> Exception occured during the execution
    --------------------------------------------------------------------------------------*/    
    public static void createApplicationLog(Log__c objLog, Exception mainExc ){
       try{
            objLog.Exception_Type__c = mainExc.getTypeName();
            objLog.Error_Message__c = mainExc.getMessage();
            objLog.Error_Message__c += ' ' + mainExc.getStackTraceString();
            insert objLog;
        }
        catch(Exception ex){
            system.debug('Error while creating Error Logs'+ex);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        createLogRec
    Description:        Method to Create  Logs
    --------------------------------------------------------------------------------------*/    
    public static Log__c createLogRec(LogWrapper logWrap, String objectId){
        Log__c objLog = new Log__c();
        objLog.FailedRecordID__c = objectId;
        objLog.Business_Function_Name__c = logWrap.module;
        objLog.Class_Name__c = logWrap.clsName;
        objLog.Method_Name__c = logWrap.methodName;
        objLog.LoggedIn_User__c = logWrap.userInfo;
        objLog.Inbound_Payload__c = logWrap.inboundMSG;
        objLog.Outbound_Payload__c = logWrap.outboundMSG;
        objLog.Is_Integration_Error__c = logWrap.isIntegration;
        objLog.RecordTypeId = GenericUtils.getObjectRecordTypeId('Log__c', logWrap.rectypeName);
        objLog.Sent_Received_Date_Time__c = logWrap.isIntegration == true?system.now(): Null;
        return objLog;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        createDeleteLog
    Description:        Method to Create Delete tracker Logs
    --------------------------------------------------------------------------------------*/    
    public static List<Delete_Tracker_Log__c>  createDeleteLog(List<DeleteLogWrapper> lstDelLogWrapper){
        List<Delete_Tracker_Log__c> lstDelLog = new List<Delete_Tracker_Log__c>();
        for(DeleteLogWrapper delLogWrapper: lstDelLogWrapper){
            Delete_Tracker_Log__c  objDelLog = new Delete_Tracker_Log__c();
            objDelLog.ABN__c = delLogWrapper.abnNumber;
            objDelLog.RecordTypeId = GenericUtils.getObjectRecordTypeId('Delete_Tracker_Log__c', delLogWrapper.recType);
            objDelLog.SObjectId__c  = delLogWrapper.sobjectId;
            objDelLog.SObjectName__c = delLogWrapper.sobjectName;
            objDelLog.RecordName__c = delLogWrapper.recName;
            lstDelLog.add(objDelLog);
        }
        return lstDelLog;
    } 
    
    
    /*--------------------------------------------------------------------------------------      
    Wrapper Name:       DeleteLogWrapper
    Description:        Wrapper to Create Delete Logs
    --------------------------------------------------------------------------------------*/    
    public class DeleteLogWrapper{
        public String sobjectName;
        public String sobjectId;
        public String recType;
        public String recName;
        public String abnNumber;
    }
    
  

    /*--------------------------------------------------------------------------------------      
    Wrapper Name:       LogWrapper
    Description:        Wrapper to Create Logs
    Constructor :       module --> Function Module 
                        clsName --> Class Name
                        methodName --> Method Name
                        userInfo --> Logged in User Info
                        inboundMSG --> Will Contain the request received in Salesforce can be blank for non API cls
                        outboundMSG --> Will Contain the response sent from Salesforce can be blank for non API cls
                        isIntegration --> If API class True, else false
                        recType --> Log Object record type Name
    --------------------------------------------------------------------------------------*/ 
    public class LogWrapper{
        public String module;
        public String clsName;
        public String methodName;
        public String userInfo;
        public String inboundMSG;
        public String outboundMSG;
        public Boolean isIntegration;
        public String rectypeName;
        public LogWrapper( String module, String clsName, String methodName, String userInfo,
                            String inboundMSG, String outboundMSG, Boolean isIntegration, String recType){
            this.module = module;
            this.clsName = clsName;
            this.methodName = methodName;
            this.userInfo = userInfo;
            this.inboundMSG = inboundMSG;
            this.outboundMSG = outboundMSG;
            this.isIntegration = isIntegration;
            this.rectypeName = recType;
        }
    }
}