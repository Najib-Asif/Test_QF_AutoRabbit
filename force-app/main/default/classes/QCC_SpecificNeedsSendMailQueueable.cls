/*********************************************************************************
Name         : QCC_SpecificNeedsSendMailQueueable
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 13 Mar 2020
Usages       : Send Email acknowledgement as queueable method to lessen number of SOQL queries 
*********************************************************************************/
public without sharing class QCC_SpecificNeedsSendMailQueueable implements Queueable{
    public  List<QCC_SpecificNeedsAcknowledgementEmail.inputWrapper> data;
    
	public void execute(QueueableContext context){
        System.debug('>>>data>>>'+data);
        
        //collect EmailTemplate and OrgWideEmailAddress in Set
        Set<String> templateNameSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(QCC_SpecificNeedsAcknowledgementEmail.inputWrapper var : data){
            templateNameSet.add(var.emailTemplateName);
            emailSet.add(var.fromAddress);
            caseMap.put(var.caseRecord.Id, var.caseRecord);
        }
        
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE developerName IN :templateNameSet]);
        //create email template map
        Map<String,EmailTemplate> templateMap = new Map<String,EmailTemplate>();
        for(EmailTemplate template: emailTemplateList){
            templateMap.put(template.DeveloperName, template);
        }
        System.debug('>>>emailTemplateList'+emailTemplateList);
        
        List<OrgWideEmailAddress> emailAddressList = new List<OrgWideEmailAddress>([SELECT id, DisplayName, Address  FROM OrgWideEmailAddress WHERE Address IN :emailSet]);
        //create orgwide email address map
        Map<String,OrgWideEmailAddress> emailAddressMap = new Map<String,OrgWideEmailAddress>();
        for(OrgWideEmailAddress email: emailAddressList){
            emailAddressMap.put(email.Address, email);
        }
        
        System.debug('>>>emailAddressList'+emailAddressList);
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for(QCC_SpecificNeedsAcknowledgementEmail.inputWrapper var : data){
            if(var.caseRecord.contact_email__c == ''){
                continue;
            }
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            message.setReplyTo(emailAddressMap.get(var.fromAddress).Address);
            message.toAddresses = new String[] {var.caseRecord.contact_email__c};
            message.setWhatId(var.caseRecord.Id); //This is important for the merge fields in template to work
            message.setSaveAsActivity(true);
            message.setOrgWideEmailAddressId(emailAddressMap.get(var.fromAddress).Id);
            //*
            message.setTemplateID(templateMap.get(var.emailTemplateName).Id); 
            message.setTargetObjectId(var.caseRecord.contactId); 
           	message.treattargetobjectasrecipient = false;
            messages.add(message);
        }
        System.debug('>>>messages: '+ messages);
        if(!messages.isEmpty()){
            Messaging.sendEmail(messages);
        }
 
    }
    
}