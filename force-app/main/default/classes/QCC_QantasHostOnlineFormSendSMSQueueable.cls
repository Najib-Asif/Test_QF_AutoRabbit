/*********************************************************************************
Name         : QCC_QantasHostOnlineFormSendSMSQueueable
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 21 October 2019
Usages       : This will send the Qantas Host SMS.
*********************************************************************************/
public class QCC_QantasHostOnlineFormSendSMSQueueable implements Queueable, Database.AllowsCallOuts{
    public String sendSMSWrapperString;
    
	public void execute(QueueableContext context){
        System.debug('QCC_QantasHostOnlineFormSendSMSQueueable.execute');
        String token;
        
        List<QCC_UtilityHelper.QantasHostSendSMSWrapper> sendSMSWrapperList = (List<QCC_UtilityHelper.QantasHostSendSMSWrapper>)JSON.deserialize(sendSMSWrapperString, List<QCC_UtilityHelper.QantasHostSendSMSWrapper>.class);
        System.debug('sendSMSWrapperList: ' + sendSMSWrapperList);
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_SMSAPI');
        System.debug('qantasAPI: ' + qantasAPI);
        List<QCC_First_Host__c> qantasHostRecords = new List<QCC_First_Host__c>();
        List<Task> taskRecordsToBeCreated = new List<Task>();
        if (qantasAPI != null) {
            for(QCC_UtilityHelper.QantasHostSendSMSWrapper sendSMSWrapper : sendSMSWrapperList) {
                //Get the token
                token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_SMSAPIToken');
                
                //Send the SMS
                Boolean isSMSSent = QCC_InvokeCAPAPI.invokeLivePersonSendSMSAPI(qantasAPI, JSON.serialize(sendSMSWrapper.smsWrapper), token);
                System.debug('isSMSSent: ' + isSMSSent);
                
                //Create task and case record once the SMS sent successfully, update the contact record and set the flag to true
                if (isSMSSent) {
                    taskRecordsToBeCreated.add(sendSMSWrapper.taskRecord);
                }
            }
            
            System.debug('taskRecordsToBeCreated: ' + taskRecordsToBeCreated);
            
            if (!taskRecordsToBeCreated.isEmpty()) {
                insert taskRecordsToBeCreated;
            }
        
            QCC_GenericUtils.updateToken(token, 'QCC_SMSAPIToken');
        }
    }
}