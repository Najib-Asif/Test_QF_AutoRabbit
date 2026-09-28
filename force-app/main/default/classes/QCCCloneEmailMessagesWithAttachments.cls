/*----------------------------------------------------------------------------------------------------------------------
Author:        Gandla Mallikarjuna
Company:       TCS
Description:   Cloning Parent Case Email Messages with attachments to sensitive case records.--Jira CRM-5051
-----------------------------------------------------------------------------------------------------------------------*/
public class QCCCloneEmailMessagesWithAttachments {

    public class inputWrapper{
        @InvocableVariable(label='parentCaseId' required=true)
        public Id parentCaseId;
        
        @InvocableVariable(label='childCaseId' required=true)
        public String childCaseId;
        
        @InvocableVariable(label='parentCaseEmailMsgs' required=true)
        public List<EmailMessage> parentCaseEmailMsgs;
        
        @InvocableVariable(label='isFromEmailReplyReceived' required=true)
        public Boolean isFromEmailReplyReceived;
        
    }
    
    /*----------------------------------------------------------------------------------------------------------------------
    Method Name:        createEmailMessagesWithAttachments
    Description:        Cloning Parent Case Email Messages with attachments to sensitive case records.--Jira CRM-5051
    Parameter:          List<inputWrapper>
    -----------------------------------------------------------------------------------------------------------------------*/
    @InvocableMethod(label='create Email Messages With Attachments' description='')
    public static void createEmailMessagesWithAttachments(List<inputWrapper> inputs)
    {
        List<EmailMessage> emailMsgs = new List<EmailMessage>();
        List<EmailMessage> childEmailMsgs = new List<EmailMessage>();
        List<ContentDocumentLink> childCdls = new List<ContentDocumentLink>();
        Map<Id, Id> childParentCaseEmailMsgMap = new Map<Id, Id>();
        for (inputWrapper input : inputs)
        {
            System.debug('input.parentCaseEmailMsgs===? ' +input.parentCaseEmailMsgs);
            System.debug('input.childCaseId========> ' + input.childCaseId);
            System.debug('input.parentCaseId========> ' + input.parentCaseId);
            for (EmailMessage emilMsg : input.parentCaseEmailMsgs)
            {
                EmailMessage childEmailMsg = emilMsg.clone(false, true, false, true);
                //EmailMessage childEmailMsg = emilMsg.clone(false, false, false, false);
                System.debug('childEmailMsg.ValidatedFromAddress====== > ' + childEmailMsg.ValidatedFromAddress);
                childEmailMsg.ParentId = input.childCaseId;
                childEmailMsg.QCC_Parent_Email_Message_Id__c = emilMsg.Id;
                childEmailMsg.ValidatedFromAddress = '';
                childEmailMsg.IsAsyncLogic__c = true;
                childEmailMsg.QCC_Has_Attachment__c = (emilMsg.HasAttachment || emilMsg.QCC_Has_Attachment__c);
                if (childEmailMsg.QCC_Has_Attachment__c && !inputs[0].isFromEmailReplyReceived)
                {
                    System.debug('Sensitive Case clone email attachments');
                    //For sensitive cases, cloning the content document links
                    childCdls.addAll(QCCCloneEmailMessagesWithAttachments.cloneContentDocumentLinks(emilMsg.id, null));
                }
                childEmailMsgs.add(childEmailMsg);
                system.debug('emilMsg isvalidatedfrom address'+emilMsg.ValidatedFromAddress);
                system.debug('childEmailMsg isvalidatedfrom address'+childEmailMsg.ValidatedFromAddress);
                emilMsg.QCC_Is_Delete_From_Flow__c = true;
                emilMsg.ValidatedFromAddress='';
            }
            
            emailMsgs.addAll(input.parentCaseEmailMsgs);
        }
        try
        {
            if (!inputs[0].isFromEmailReplyReceived)
            {
                //For sensitive cases, creating child email messages with content document links and removing parent sensitive case emails.
                insert childEmailMsgs;
                for (EmailMessage msg : childEmailMsgs)
                {
                    System.debug('msg.ValidatedFromAddress=====> ' + msg.ValidatedFromAddress);
                    childParentCaseEmailMsgMap.put(msg.QCC_Parent_Email_Message_Id__c, msg.Id);
                }
                for (ContentDocumentLink contentDocLink : childCdls)
                {
                    contentDocLink.LinkedEntityId = childParentCaseEmailMsgMap.get(contentDocLink.LinkedEntityId);
                }
                insert childCdls;
                updateSensitiveCaseEmailMsgs(JSON.serialize(emailMsgs));
            }
            else if (inputs[0].isFromEmailReplyReceived && emailMsgs[0].HasAttachment)
            {
                //For reply received, closed case, creating the email messages with attachments, in a seperate transaction.
                 childEmailMsgs[0].QCC_Has_Attachment__c = true;
                System.debug('has attachment');
                createChildContentDocumentLinks(emailMsgs[0].Id, JSON.serialize(childEmailMsgs), true);
            }
            else
            {
                //For reply received closed case, creating email message record with out attachments.
                System.debug('has no attachment');
                createChildContentDocumentLinks(emailMsgs[0].Id, JSON.serialize(childEmailMsgs), false);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception=============> ' + e.getMessage());
        }   
    }       
    
    /*----------------------------------------------------------------------------------------------------------------------
    Method Name:        updateSensitiveCaseEmailMsgs
    Description:        Update the Sensitive case email messages.--Jira CRM-5156 
    Parameter:          String
    -----------------------------------------------------------------------------------------------------------------------*/
    public static void updateSensitiveCaseEmailMsgs(String emailMsgsJson)
    {
        try
        {
            System.debug('inside updateSensitiveCaseEmailMsgs');
            List<EmailMessage> emailMsgs = (List<EmailMessage>)JSON.deserialize(emailMsgsJson, List<EmailMessage>.class);
            System.debug('inside updateSensitiveCaseEmailMsgs after list assignment');
            update emailMsgs;
            System.debug('print updated records'+emailMsgs);
            delete emailMsgs;
            System.debug('print deleted records');
        }
        Catch(Exception ex)
        {
            System.debug('Exception=============> ' + ex.getMessage());
        }
    }
    
    /*----------------------------------------------------------------------------------------------------------------------
    Method Name:        createChildContentDocumentLinks
    Description:        Creating Email messages with attachments for child cases from reply received closed case.--Jira CRM-5156 
    Parameter:          Id, String
    -----------------------------------------------------------------------------------------------------------------------*/
    public static void createChildContentDocumentLinks(Id parentEmailMsgId, String childEmailMsg, Boolean hasAttachments)
    {
        try
        {
            List<EmailMessage> childEmailMsgs = (List<EmailMessage>)JSON.deserialize(childEmailMsg, List<EmailMessage>.class);
            List<EmailMessage> emailMsgs = [SELECT Id , QCC_Is_Delete_From_Flow__c FROM EmailMessage where Id =: parentEmailMsgId];
            system.debug('print the emailmessage recs'+emailMsgs );
            if (hasAttachments)
            {
                childEmailMsgs[0].QCC_Has_Attachment__c = true;
                insert childEmailMsgs[0];
                List<ContentDocumentLink> childCdls = new List<ContentDocumentLink>();
                childCdls.addAll(QCCCloneEmailMessagesWithAttachments.cloneContentDocumentLinks(parentEmailMsgId, childEmailMsgs[0].Id));
                insert childCdls;
                
            }
            else
            {
                System.debug('childEmailMsgs ==='+childEmailMsgs[0].parentId);
                childEmailMsgs[0].QCC_Has_Attachment__c = false;
                insert childEmailMsgs[0];  
            }
            emailMsgs[0].QCC_Is_Delete_From_Flow__c = true;
            update emailMsgs; 
            delete emailMsgs;
        }
        catch(Exception ex)
        {
            System.debug('Exception=============> ' + ex.getMessage());
        }
    }
    
    /*----------------------------------------------------------------------------------------------------------------------
    Method Name:        cloneContentDocumentLinks
    Description:        Clone the content document links
    Parameter:          Id, Id
    -----------------------------------------------------------------------------------------------------------------------*/
    public static List<ContentDocumentLink> cloneContentDocumentLinks(Id parentEmailMsgId, Id childEmailMsgId)
    {
        System.debug('cloneContentDocumentLinks*************');
        System.debug('parentEmailMsgId====> ' + parentEmailMsgId);
        System.debug('childEmailMsgId====> ' + childEmailMsgId);
        List<ContentDocumentLink> childCdls = new List<ContentDocumentLink>();
        List<ContentDocumentLink> parentCaseFiles = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted,
                                                             SystemModstamp, Visibility, ShareType FROM ContentDocumentLink where LinkedEntityId =: parentEmailMsgId];
        for (ContentDocumentLink cdl : parentCaseFiles)
        {
            ContentDocumentLink childCdl = cdl.clone(false, true, false, true);
            if (childEmailMsgId != null)
            {
                childCdl.LinkedEntityId = childEmailMsgId;
            }
            childCdls.add(childCdl);
        }
        return childCdls;
    }
    
}