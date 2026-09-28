/*********************************************************************************
Name         : QCC_QantasHostSendSMSQueueable
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 21 October 2019
Usages       : This will send the Qantas Host SMS.
*********************************************************************************/
public class QCC_QantasHostSendSMSQueueable implements Queueable, Database.AllowsCallOuts{
    public String sendSMSWrapperString;
    
	public void execute(QueueableContext context){
        System.debug('QCC_QantasHostSendSMSQueueable.execute');
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
                    QCC_First_Host__c qantasHostRecord = sendSMSWrapper.qantasHostRecord;
                    qantasHostRecord.QCC_TECH_SMS_Need_To_Send__c = false;
                    
                    //GRAPHITE-2185 Populate QCC_TECH_Comms_Sending_Date__c upon sending the comms.
                    qantasHostRecord.QCC_TECH_Comms_Sending_Date__c = System.now();
                    qantasHostRecords.add(qantasHostRecord);

                    taskRecordsToBeCreated.add(sendSMSWrapper.taskRecord);
                }
            }
            
            System.debug('qantasHostRecords: ' + qantasHostRecords);
            
            if (!qantasHostRecords.isEmpty()) {
                update qantasHostRecords;
            }
        
            System.debug('taskRecordsToBeCreated: ' + taskRecordsToBeCreated);

            if (!taskRecordsToBeCreated.isEmpty()) {
                insert taskRecordsToBeCreated;
            }

            QCC_GenericUtils.updateToken(token, 'QCC_SMSAPIToken');
        }
    }
}