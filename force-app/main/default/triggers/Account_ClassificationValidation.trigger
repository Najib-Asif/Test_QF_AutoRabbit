trigger Account_ClassificationValidation on Account_Classifications__c (before insert) {


    if(Trigger_Status__c.getValues('Account_ClassificationValidation').Active__c && Trigger.isbefore && (Trigger.isInsert)){
        system.debug('Trigger.new***********'+Trigger.new);               
        Account_ClassificationValidationHelper.accClassPCValidation(Trigger.new);
        system.debug('Trigger.new***********'+Trigger.new);
        
        }
           }