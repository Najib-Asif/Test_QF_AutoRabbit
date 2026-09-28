/*********************************************************************************
Name         : QCC_SendCaseStatusEmailReminderInvocable
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 07 October 2019
Usages       : This class is used initiate Case Email Reminder to Customer/Internal
*********************************************************************************/
public class QCC_SendCaseStatusEmailReminderInvocable {
    public class classVariable{
        @InvocableVariable(label='caseRecord' required=true)
        public Case caseRecord;
        
        @InvocableVariable(label='emailTemplateName' required=true)
        public String emailTemplateName;
    }
    
    @InvocableMethod
    public static void sendCaseEmailReminder(List<classVariable> classVar){
        try{
            System.debug('>>>classVar: '+classVar);
            // List of Messages to Send
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            
            // GET SENDER
            Map<String,Id> OrgWideEmailMap = new Map<String,Id>();
            for(OrgWideEmailAddress orgWideEmail : [SELECT Id, Address FROM OrgWideEmailAddress]){
                OrgWideEmailMap.put(orgWideEmail.Address,orgWideEmail.Id);
            }
            
            // Get Map of Email template
            Set<String> allEmailTemplate = new Set<String>();
            for(classVariable currentData : classVar){
                allEmailTemplate.add(currentData.emailTemplateName);
            }
            Map<String,EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
            for(EmailTemplate emailTemp : [SELECT Id,Developername,HtmlValue,Subject FROM EmailTemplate WHERE Developername IN: allEmailTemplate]){
                emailTemplateMap.put(emailTemp.Developername,emailTemp);
            }
            Set<String> frequentFlyerTierSet = new Set<String>();
            frequentFlyerTierSet.addAll(Label.QCC_Frequent_Flyer_Tier_with_Assignment_Rule.split(';'));
            
            
            // Loop Case and build Email Message to be send in bulk
            for(classVariable currentData : classVar){
                system.debug('caseRecord:'+ currentData.caseRecord);
                Messaging.SingleEmailMessage theMessage = new Messaging.SingleEmailMessage();
                
                String emailSender = Label.QCC_EmailCustomer_ValidatedFrom_CC; // Default
                if(currentData.caseRecord.RecordType.DeveloperName == 'QCC_Specific_Needs'){
                   emailSender = Label.QCC_EmailCustomer_ValidatedFrom_SN;
                }else if(currentData.caseRecord.Contact.SSU__c){
                    emailSender = Label.QCC_EmailCustomer_ValidatedFrom_SSU;
                }else if(frequentFlyerTierSet.contains(currentData.caseRecord.Contact.Frequent_Flyer_Tier__c)){
                    emailSender = Label.QCC_EmailCustomer_ValidatedFrom_VIP;
                }
                
                theMessage.setReplyTo(emailSender); // make sure it is setup as Email to case
                theMessage.setOrgWideEmailAddressId(OrgWideEmailMap.get(emailSender)); // Sender Orgwide Default Email Address        
                //System.debug('>>>currentData.caseRecord.Status: '+currentData.caseRecord.Status);
                if(currentData.caseRecord.Status == 'Waiting for Internal') {
                    List<String> listToAddresses = new list<String>();
                    System.debug('>>>QCC_Internal_Followup_Emails__c: '+ currentData.caseRecord.QCC_Internal_Followup_Emails__c);
                    if(currentData.caseRecord.QCC_Internal_Followup_Emails__c != null || currentData.caseRecord.QCC_Internal_Followup_Emails__c != ''){
                        listToAddresses.addAll(currentData.caseRecord.QCC_Internal_Followup_Emails__c.split(';'));
                        System.debug('>>>listToAddresses: '+ listToAddresses);
                        theMessage.setToAddresses(listToAddresses); // this will determine who is the recipient
                        theMessage.setSubject(findAndReplaceCaseFieldValue(currentData.caseRecord,emailTemplateMap.get(currentData.emailTemplateName).Subject)); // Email Subject  
                        theMessage.setHtmlBody(findAndReplaceCaseFieldValue(currentData.caseRecord,emailTemplateMap.get(currentData.emailTemplateName).HtmlValue)); // Email Body
                    }
                    
                    List<String> toAddress = new List<String>();
                    theMessage.setWhatId(currentData.caseRecord.id); // Case record to attach the email
                    theMessage.setSaveAsActivity(true); 
                    messages.add(theMessage);
                } else if(currentData.caseRecord.Status == 'Waiting for Customer') {
                    if(currentData.caseRecord.Contact_Email__c != null){
                        list<String> listToAddresses = new list<String>();
                        listToAddresses.add(currentData.caseRecord.Contact_Email__c);
                        theMessage.setToAddresses(listToAddresses);
                        theMessage.setSubject(findAndReplaceCaseFieldValue(currentData.caseRecord,emailTemplateMap.get(currentData.emailTemplateName).Subject)); // Email Subject  
                        theMessage.setHtmlBody(findAndReplaceCaseFieldValue(currentData.caseRecord,emailTemplateMap.get(currentData.emailTemplateName).HtmlValue)); // Email Body
                       
                    }else{
                        theMessage.setTemplateId(emailTemplateMap.get(currentData.emailTemplateName).Id); // Email Template ID
                        theMessage.setTargetObjectId(currentData.caseRecord.ContactId); // Case Contact Record Id. this will determine who is the recipient
                    }
                        
                    List<String> toAddress = new List<String>();
                    theMessage.setWhatId(currentData.caseRecord.id); // Case record to attach the email
                    theMessage.setSaveAsActivity(true); 
                    messages.add(theMessage);
                }
                
            }
            // SEND THE EMAIL
            if (!messages.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            	System.debug('>>>results: '+results);
            }
        } catch (Exception ex) {
            //TO-DO: Error Handling
            system.debug('ERROR : ' + ex);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('Sending Case Email Reminder', 'QCC_SendCaseStatusEmailReminderInvocable', 'sendCaseEmailReminder', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }    
    }
    
    public static String findAndReplaceCaseFieldValue(Case recordInfo, String stringContent){
        // Get All Case Fields
        Set<String> allFields = new Set<String>();
        for(string fieldName : Case.getSObjectType().getDescribe().fields.getMap().keyset()){
            if(recordInfo.get(fieldName) != null){
                stringContent = stringContent.replaceAll('(?i)\\{!Case.' + fieldName + '\\}',  recordInfo.get(fieldName)+'' );
            }else{
                stringContent = stringContent.replaceAll('(?i)\\{!Case.' + fieldName + '\\}',  '' );
            }
        }
        
        // Special Logic to replace merge field from Contact
        stringContent = recordInfo.First_Name__c != null ? stringContent.replaceAll('(?i)\\{!Contact.FirstName\\}',  recordInfo.First_Name__c) : stringContent;
        System.debug('>>>recordInfo.First_Name__c: '+ recordInfo.First_Name__c);
        
        //Logic to ensure that thread token value is sent along with email templates CRM-7258
        Id caseId=Id.valueof(recordInfo.id);
        String tokenValue= EmailMessages.getFormattedThreadingToken(caseId);
        stringContent = stringContent.replace('{!Case.Thread_Token}',tokenValue);
        System.debug('>>>recordInfo token value: '+ tokenValue);
        System.debug('>>>HTML value with token : '+ stringContent);
        
        return stringContent;
    }
}