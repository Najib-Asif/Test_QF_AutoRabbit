trigger AccountOwnerTrigger on Account_Owner__c (before update) {
    try{
        Trigger_Status__c ts = Trigger_Status__c.getValues('AccountOwnerTrigger');
        if(ts.Active__c){   
            AccountOwnerTriggerHandler.SaveOldUsers(Trigger.New, Trigger.OldMap);
            
        }    
    }catch(Exception e){
        System.debug('Error Occured From Account Owner Trigger: '+e.getMessage());
    }
}