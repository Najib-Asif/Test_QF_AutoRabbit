/*********************************************************************************
Name         : QCC_SpecificNeedsAcknowledgementEmail
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 11 March 2020
Usages       : Send acknowledgement email if specific needs case is created
*********************************************************************************/
public class QCC_SpecificNeedsAcknowledgementEmail {
    public class inputWrapper{
        @InvocableVariable(label='caseRecord' required=true)
        public Case caseRecord;
        
        @InvocableVariable(label='emailTemplateName' required=true)
        public String emailTemplateName;
        
        @InvocableVariable(label='fromAddress' required=true)
        public String fromAddress;
    }
    
    @InvocableMethod
    public static void sendEmail(List<inputWrapper> inputs){
        try{
            QCC_SpecificNeedsSendMailQueueable queueableJob =  new QCC_SpecificNeedsSendMailQueueable();
            queueableJob.data = inputs;
            System.enqueueJob(queueableJob);
        }catch(exception ex){
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Specific Needs', 'QCC_SpecificNeedsAcknowledgementEmail', 'sendEmail', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
    }
    
}