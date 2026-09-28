/**********************************************************************
Name:  QEC_SpecialConditionsTriggerHandler
Copyright © 2019  Qantas Airways.
======================================================
Purpose: 
QEC - Summarize the special condition type and JQ routes to help with the approval process
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0     Yuvaraj       05/06/2019      Initial Development
========================================================
***********************************************************************/
trigger QEC_SpecialConditionsTrigger on QEC_Special_Condition__c (after insert, after update, after delete) {
    try{
    Trigger_Status__c ts = Trigger_Status__c.getValues('SpecialConditionsTrigger');
    if(ts.Active__c){
            if(Trigger.isInsert)
            {
                if(Trigger.isAfter)
                    QEC_SpecialConditionsTriggerHandler.updateSC_ODPair_onProposal(Trigger.New);
            }
            if(Trigger.isUpdate)
            {
                if(Trigger.isAfter) 
                    QEC_SpecialConditionsTriggerHandler.updateSC_ODPair_onProposal(Trigger.New);
            }
            if(Trigger.isDelete)
            {
                if(Trigger.isAfter)
                    QEC_SpecialConditionsTriggerHandler.updateSC_ODPair_onProposal(Trigger.Old);
            }
    }
    }catch(Exception e){
        System.debug('Error Occured From Special Conditions Trigger: '+e.getMessage());
    }

}