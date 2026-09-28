/*********************************************************************************
Name         : QCC_LoyaltyStatusSendSMSQueueable
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 26 September 2019
Usages       : This will send the Loyalty Status SMS every 9AM.
*********************************************************************************/
public class QCC_LoyaltyStatusSendSMSQueueable implements Queueable, Database.AllowsCallOuts{
    public String sendSMSWrapperString;
    
	public void execute(QueueableContext context){
        String token;

        List<QCC_LoyaltyStatusSendSMSInvocable.SendSMSWrapper> sendSMSWrapperList = (List<QCC_LoyaltyStatusSendSMSInvocable.SendSMSWrapper>)JSON.deserialize(sendSMSWrapperString, List<QCC_LoyaltyStatusSendSMSInvocable.SendSMSWrapper>.class);
        System.debug('sendSMSWrapperList: ' + sendSMSWrapperList);
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_SMSAPI');
        System.debug('qantasAPI: ' + qantasAPI);
        if (qantasAPI != null) {
            List<Case> caseRecordsToInsert = new List<Case>();
            List<Task> taskRecordsToInsert = new List<Task>();
            List<Contact> contactRecordsToInsert = new List<Contact>();
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            for(QCC_LoyaltyStatusSendSMSInvocable.SendSMSWrapper sendSMSWrapper : sendSMSWrapperList) {
                //Get the token
                token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_SMSAPIToken');
                //Generate the Request Body for the SMSAPI Callout
                QCC_LoyaltyStatusSendSMSInvocable.LoyaltyMessageWrapper messageWrapper = new QCC_LoyaltyStatusSendSMSInvocable.LoyaltyMessageWrapper();
                messageWrapper.countryCode = sendSMSWrapper.contactRecord.QCC_TECH_MobilePhoneCountryCode__c.replaceAll('[^a-zA-Z0-9\\s]', '');
                messageWrapper.mobileNumber = sendSMSWrapper.contactRecord.QCC_TECH_MobilePhoneNumber__c;
                messageWrapper.message = sendSMSWrapper.messageBody;
                messageWrapper.senderName = 'QF_PLAT_ONE';
                
                Boolean isSMSSent = QCC_InvokeCAPAPI.invokeLivePersonSendSMSAPI(qantasAPI, JSON.serialize(messageWrapper), token);
                System.debug('isSMSSent: ' + isSMSSent);
                
                //Create task and case record once the SMS sent successfully, update the contact record and set the flag to true
                if (isSMSSent) {
                    caseRecordsToInsert.add(sendSMSWrapper.caseRecord);
                    taskRecordsToInsert.add(sendSMSWrapper.taskRecord);
                    
                    //This will prevent the duplicate id in list
                    Contact contactRecord;
                    if(contactMap.containsKey(sendSMSWrapper.contactId)) {
                        contactRecord = contactMap.get(sendSMSWrapper.contactId);
                    } else {
                        contactRecord = sendSMSWrapper.contactRecord;
                    }
                    
                    //Clear the value of QCC_TECH_Loyalty_Point_Type__c in Contact record
                    contactRecord.QCC_TECH_Loyalty_Point_Type__c = null;
                    
                    contactMap.put(contactRecord.Id, contactRecord);
                }
            }
            
            QCC_GenericUtils.updateToken(token, 'QCC_SMSAPIToken');

            System.debug('caseRecordsToInsert: ' + caseRecordsToInsert);
            if (!caseRecordsToInsert.isEmpty()) {
                insert caseRecordsToInsert;
            }
            
            System.debug('taskRecordsToInsert: ' + taskRecordsToInsert);
            if (!taskRecordsToInsert.isEmpty()) {
                insert taskRecordsToInsert;
            }
            
            System.debug('contactMap.values(): ' + contactMap.values());
            if (!contactMap.values().isEmpty()) {
                update contactMap.values();
            }
        }
    }
}