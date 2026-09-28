/*********************************************************************************
Name         : QCC_QantasHostSpaBookingQueueable
Created By   : Nicole Abesamis
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 27 December 2019
Usages       : This will send the SMS for Spa Booking Status
*********************************************************************************/
public class QCC_QantasHostSpaBookingQueueable implements Queueable, Database.AllowsCallOuts{
    public String sendSMSWrapperString;
    
	public void execute(QueueableContext context){
        System.debug('QCC_QantasHostSpaBookingQueueable.execute');
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
                
                QCC_First_Host__c firstHostRecord = sendSMSWrapper.qantasHostRecord;
                
                QCC_UtilityHelper.SMSWrapper smsWrapper = sendSMSWrapper.smsWrapper;
                //String mobileNumber = smsWrapper.mobileNumber;
                System.debug('Mobile number: ' + smsWrapper.mobileNumber);
                //Check first if mobile Number is blank
                if(smsWrapper.mobileNumber != null){

                //Send the SMS
                Boolean isSMSSent = QCC_InvokeCAPAPI.invokeLivePersonSendSMSAPI(qantasAPI, JSON.serialize(sendSMSWrapper.smsWrapper), token);
                System.debug('isSMSSent: ' + isSMSSent);
                System.debug('sendSMSWrapper.smsWrapper' + sendSMSWrapper.smsWrapper);
                //Create task and case record once the SMS sent successfully, update the contact record and set the flag to true
                    if (isSMSSent) {
                        //Update Spa Request Outcome to Sent
                        firstHostRecord.QCC_Spa_Request_Outcome__c = 'Sent';
                        taskRecordsToBeCreated.add(sendSMSWrapper.taskRecord);
                    } else{
                        //Update Spa Request Outcome to Failed to Send
                        firstHostRecord.QCC_Spa_Request_Outcome__c = 'Failed to Send';
                    }
                } else{ // if mobile is blank
                    firstHostRecord.QCC_Spa_Request_Outcome__c = 'Failed to Send';
                }

                qantasHostRecords.add(firstHostRecord);
            }
            
            System.debug('taskRecordsToBeCreated: ' + taskRecordsToBeCreated);
            System.debug('qantasHostRecords: ' + qantasHostRecords);
            
            if(!qantasHostRecords.isEmpty()){
                update qantasHostRecords;
            }
            
            if (!taskRecordsToBeCreated.isEmpty()) {
                insert taskRecordsToBeCreated;
            }
        
            QCC_GenericUtils.updateToken(token, 'QCC_SMSAPIToken');
        }
    }
}