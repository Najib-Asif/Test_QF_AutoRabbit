// Creates a Quote when Opportunity stage is changed to 'Negotiate' for 'Loyalty Commercial' record type

trigger OpportunityTrigger on Opportunity (after update,before update) {
    System.debug('Reached Trigger');    
    //Check the trigger executing first time:
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            System.debug('TriggerInst**'+Trigger.New);
            OpportunityTriggerHandler.oppPusher(Trigger.New,Trigger.oldMap);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            if(IsRecursive.runOnce()) {
                OpportunityTriggerHandler.getNewQuoteOppotunities(Trigger.New,Trigger.oldMap);
            }
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            System.debug('TriggerUpdate**'+Trigger.New);
            QL_CheckRecordhasFiles.CheckAttachment(Trigger.New);
        }
    }
}