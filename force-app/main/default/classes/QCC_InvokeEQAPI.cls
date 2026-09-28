/*----------------------------------------------------------------------------------------------------------------------
Author:        Swetha
Company:       Qantas
Description:   Send Recovery for Payment Processing to EQ System - Queueable
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
17-Jun-2024      Swetha              Initial Design
-----------------------------------------------------------------------------------------------------------------------*/

public without sharing class QCC_InvokeEQAPI {
    private static List<Integer> validRespCodes = new List<Integer>{200};

    public static void invokeProcessRecoveries(QCC_EQRequestWrapper payload){
        try {
            //Call Integration utility
            system.debug('req payloadd....'+payload);
            String jsonPayload = JSON.serialize(payload); 
            jsonPayload = jsonPayload.replaceAll('"EQCURRENCY":','"CURRENCY":');
            system.debug('req json payloadd....'+jsonPayload);
            Http http = new Http();
            HTTPResponse res = QCC_RecoveryIntegrationUtility.actualHttpCall('callout:QCC_Recovery_EQ_NC', jsonPayload);
    
            QCC_EQResponseWrapper resParams = new QCC_EQResponseWrapper();
            resParams = QCC_EQResponseWrapper.parse(res.getbody()); 
            //string dummy = '{\"P_CC_CLAIM_HEADER\":{\"UNIQUE_SOURCE_CALL_SEQ\":20240701151803,\"EMAIL\":\"shr_ccreq@qantas.com.au\",\"PHONE_EXT\":913234,\"PREPARED_BY\":171323},\"P_CC_CLAIM_LINES\":{\"P_CC_CLAIM_LINES_ITEM\":[{\"TITLE\":null,\"FIRST_NAME\":\"Test\",\"LAST_NAME\":\"ContactQ\",\"CLAIM_NO\":"R01022503",\"STATUS\":\"FAIL\",\"ERROR_CODE\":null,\"STATUS_MESSAGES\":\"EntervalueforInvoice/ClaimNo\"},{\"TITLE\":null,\"FIRST_NAME\":\"Test\",\"LAST_NAME\":\"ContactQ\",\"CLAIM_NO\":"R01022500",\"STATUS\":\"FAIL\",\"ERROR_CODE\":null,\"STATUS_MESSAGES\":\"EntervalueforInvoice/ClaimNo\"}]},\"OUT_RESULT\":{\"CC_BATCH_NAME\":null,\"EXCEPTIONTYPE\":\"ERROR\",\"ERRORMESSAGE\":\"Noclaimlinescouldbeprocessed,Pleasereviewtheindvidualerrormessages\"}}';
            System.debug('resp code....'+res.getStatusCode());
            System.debug('actual eq resp..'+res.getbody());
            if(validRespCodes.contains(res.getStatusCode())){ //else no updates to Recoveries
            	processResponse(resParams, res.getStatusCode());
            }
        }
        catch (Exception ex) {
            //No change to Recovery status
			System.debug('Exception## '+ex.getMessage());
			CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - EFT Batch Callouts', 'QCC_InvokeEQAPI',
			                         'execute', String.valueOf(''), String.valueOf(''),false,'', ex);
		}
    }
    
    //Is future required here - already running in queuable context
    public static void processResponse(QCC_EQResponseWrapper resParams, Integer respCode){
		Map<String, calloutRespWrap> recvyCallOutRespLst =  new Map<String, calloutRespWrap>();
        QCC_RecoveryIntegrationUtility.SystemLog logParams = new QCC_RecoveryIntegrationUtility.SystemLog();
        logParams.systemName = 'EQ';
        //Update recoveries with respective statuses received from EQ system
		String eqBatchNumber = resParams.OUT_RESULT.CC_BATCH_NAME;
        String lineItemErrCode = resParams.OUT_RESULT.CC_BATCH_NAME;
        for(QCC_EQResponseWrapper.P_CC_CLAIM_LINES_ITEM resp : resParams.P_CC_CLAIM_LINES.P_CC_CLAIM_LINES_ITEM){
            system.debug('callout resp'+resp);
           	calloutRespWrap respInfo = new calloutRespWrap();
            respInfo.status = resp.STATUS;
            respInfo.errorCode = resp.ERROR_CODE;
            respInfo.errorMessage = resp.STATUS_MESSAGES;
            recvyCallOutRespLst.put(resp.CLAIM_NO, respInfo);
            system.debug('callout resp'+respInfo);
            system.debug('callout resp'+recvyCallOutRespLst);
        }

        List<Recovery__c> recvyListToUpdate = new List<Recovery__c>();
        for(Recovery__c recvy: [Select Id, Name, Process_Status__c, Batch_Number__c, Recovery_System_log__c from Recovery__c where Name IN: recvyCallOutRespLst.keySet()]) {
            if(recvyCallOutRespLst.get(recvy.Name).status == 'SUCCESS'){
                logParams.status = recvyCallOutRespLst.get(recvy.Name).status;
				logParams.batchNumber = eqBatchNumber;
                recvy.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusSubmitToFinance');
                recvy.Recovery_System_log__c = QCC_RecoveryIntegrationUtility.constructSysLog(logParams) + (recvy.Recovery_System_log__c != null ? recvy.Recovery_System_log__c : '');
                recvy.Batch_Number__c = eqBatchNumber;
                system.debug('callout rec success');
            } else {
                logParams.status = recvyCallOutRespLst.get(recvy.Name).status;
				logParams.errorCode = recvyCallOutRespLst.get(recvy.Name).errorCode;
                logParams.errorMessage = recvyCallOutRespLst.get(recvy.Name).errorMessage;
                recvy.Process_Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryPStatusException');
                recvy.Recovery_System_log__c = QCC_RecoveryIntegrationUtility.constructSysLog(logParams) + (recvy.Recovery_System_log__c != null ? +recvy.Recovery_System_log__c : '');
                system.debug('callout rec fail');
            }
            recvyListToUpdate.add(recvy);
            //call Recovery log to update
        }
        system.debug('update records...'+recvyListToUpdate);
        if(recvyListToUpdate.Size() > 0){
        	Database.Update(recvyListToUpdate, false);
        }
    }
    
    public class calloutRespWrap{
        public string status;
        public string errorCode;
        public string errorMessage;
    }
}