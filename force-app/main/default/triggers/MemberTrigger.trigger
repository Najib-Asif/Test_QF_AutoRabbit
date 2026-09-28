trigger MemberTrigger on Associated_Person__c (After Update)
{
    /*try{
        Trigger_Status__c ts = Trigger_Status__c.getValues('MemberTrigger');
        if(ts.Active__c){     
            if(Trigger.isAfter && Trigger.isUpdate){    
                MemberTriggerHandler.processCases(Trigger.New, Trigger.OldMap);
            }
        }        
     }catch(Exception e){
         System.debug('Exception Occured: '+e.getMessage());
     }*/    
}