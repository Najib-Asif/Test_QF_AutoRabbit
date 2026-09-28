public with sharing class QCC_EmailPreviewController {
    
    @AuraEnabled
    public static string fetchEmailContent(String recId){
        EventCommunication__c objEvtComms = [select Id, IsGlobalEventComms__c from EventCOmmunication__c where Id =: recId];
        String templateName = objEvtComms.IsGlobalEventComms__c?'QCC_GlobalTemplate': 'QCC_PassengerCommsWithOutRecovery';
        EmailTemplate  et = queryEmailTemplate(templateName);
        Affected_Passenger__c  objAffPass = queryPassenger(recId, '');
        Contact objCon = queryContact();
        system.debug('et#####'+et);
        if(objAffPass != Null){
            if(objAffPass.Passenger__c != Null){
                return formEmailConent(objAffPass.Id, et.Id, objCon.Id);
            }else{
                return formEmailConent(objAffPass.Id, et.Id, objCon.Id);
            }
        }else{
            AuraHandledException ltEX = new AuraHandledException('NO Passenger Record');
            throw ltEX;
        }
    }
    @AuraEnabled
    public static string fetchEmailContent(String recId, String emailtemplateType){
        EventCommunication__c objEvtComms = [select Id, IsGlobalEventComms__c from EventCOmmunication__c where Id =: recId];
        String templateName = objEvtComms.IsGlobalEventComms__c?'QCC_GlobalTemplate': 'QCC_PassengerCommsWithOutRecovery';
        String onlyFF = '';
        if(!objEvtComms.IsGlobalEventComms__c && emailtemplateType == 'FFRecovery'){
            templateName = 'QCC_PassengerCommsWithRecoveryFF';
            onlyFF = 'Yes';
        }else if(!objEvtComms.IsGlobalEventComms__c && emailtemplateType == 'NFFRecovery'){
            templateName = 'QCC_PassengerCommsWithRecoveryNFF';
            onlyFF = 'No';
        }

        EmailTemplate  et = queryEmailTemplate(templateName);
        Affected_Passenger__c  objAffPass = queryPassenger(recId, onlyFF);
        Contact objCon = queryContact();

        if(objAffPass != Null){
            if(objAffPass.Passenger__c != Null){
                return formEmailConent(objAffPass.Id, et.Id, objCon.Id);
            }else{
                return formEmailConent(objAffPass.Id, et.Id, objCon.Id);
            }
        }else{
            AuraHandledException ltEX = new AuraHandledException('NO Passenger Record');
            throw ltEX;
        }
    }

    public static Affected_Passenger__c queryPassenger(String evtCommsId, String onlyFF){
        Affected_Passenger__c objAffPass;
        if(onlyFF == 'Yes'){
            objAffPass = [select Id, Passenger__c from Affected_Passenger__c where 
                          EventCommunication__c =: evtCommsId AND FrequentFlyerNumber__c != '' limit 1];
        }else if(onlyFF == 'No'){
            objAffPass = [select Id, Passenger__c from Affected_Passenger__c where 
                          EventCommunication__c =: evtCommsId AND FrequentFlyerNumber__c = '' limit 1];
        }else{
            objAffPass = [select Id, Passenger__c from Affected_Passenger__c where 
                          EventCommunication__c =: evtCommsId  limit 1];
        }

        return objAffPass;
    }

    public static Contact queryContact(){
        Contact objCon = [select Id from Contact where Email != Null limit 1];
        return objCon;
    }

    public static EmailTemplate queryEmailTemplate(String templateName){
        EmailTemplate  et = [ select Id, Name, Body, Subject, HTMLValue  from EmailTemplate where 
                              Name = : templateName ];
        return et;
    }

    public static string formEmailConent(String whatId, String templateId, String conId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'praveen.sampath@capgemini.com'};
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setWhatId(whatId);
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(conId);

        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        Database.rollback(sp);

        String mailHtmlBody = mail.getHTMLBody();
        String mailSubject = mail.getSubject();
        String response = '<B>Subject : </B>'+ mailSubject+'<br/> <br/> <B>Email Body : </B>'+mailHtmlBody.trim();
        system.debug('response#####'+response);
        return response;
    }
}