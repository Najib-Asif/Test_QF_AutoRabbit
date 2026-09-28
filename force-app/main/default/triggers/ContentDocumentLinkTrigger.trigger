/* 
* Created By : Bharath
* Modified By : Ajay Bharathan | TCS | Cloud Developer
* Purpose : To cover Files insertion / updation and update Case 
* Related Class : ContentDocumentLinkTriggerHelper, QAC_ChildTriggerHandler
*/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, after update) 
{
    if(Trigger_Status__c.getValues('ContentDocLinkTriggerCheck').Active__c){
        if(trigger.isBefore && trigger.isInsert)
            ContentDocumentLinkTriggerHelper.avoidingUploadFileToEvent(trigger.new);
        
        // added by AJAY for QAC Add Attachment
        if(trigger.isAfter){
            if(trigger.isInsert){
                QAC_ChildTriggerHandler.doCaseUpdateonFileInsUpd(Trigger.New,null);
                QAC_ChildTriggerHandler.contentDocumentToCase(Trigger.New);

            }
            /*
            if(trigger.isUpdate){
            QAC_ChildTriggerHandler.doCaseUpdateonFileInsUpd(Trigger.New,Trigger.oldMap); 
            }
            */
        }    
        // code change ended        
    }
}