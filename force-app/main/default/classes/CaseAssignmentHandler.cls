/*----------------------------------------------------------------------------------------------------------------------
Author:        Debajyoti
Company:       Qantas
Description:   Call from EmailMessageQCCTriggerHandler to manage case status and send email and feed notification. 
                Invocable method to called from Recovery after save flow when EFT expired. CDP2-644
Inputs:
Updated: 10/10/24 - Sourabh:Bug fix:CDP2-644

-----------------------------------------------------------------------------------------------------------------------*/
public class CaseAssignmentHandler {
    @InvocableMethod (label = 'Manage Expired Recovery' description = 'Send Expired recoveries')    
    public static void  managerecoveries( List<recovery__c> recoverylist) {
        Set<id> recIdSet = new Set<id>();
        for(recovery__c reco : recoverylist)
        {  
            recIdSet.add(reco.id);
        }

        List<recovery__c> recList= [SELECT Id,name,CreatedById,CreatedBy.Email,createdby.Name,Case_Number__c,CaseNumber__c,Process_Status__c,recordtype.developername,CreatedDate 
                     FROM Recovery__c where id in:recIdSet];

        set<id> caseid = new set<id>();     
        map<id,id> caseIdToRecCreatorMap = new map<id,id>();  
         
        list<case> casesToUpdate = new list<case>();     
        list<FeedItem> feeditemlist =  new list<FeedItem >();
        list<Messaging.SingleEmailMessage> maillist = new list<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id,name FROM EmailTemplate WHERE Name = 'QCC Case Expiry Email' LIMIT 1];


        //go through the list of expired recoveries
        for(recovery__c rec : recList){
            caseid.add(rec.case_number__c);
            caseIdToRecCreatorMap.put(rec.case_number__c,rec.CreatedById);
            feeditemlist.add(postToChatter(rec)); 
            maillist.add(sendEmailUsingTemplate(rec,template, rec.CreatedBy.Email ));
            
        }
        for(case cs:[SELECT Id, Status, OwnerId FROM Case WHERE Id IN :caseid])
        {
           cs.ownerId = caseIdToRecCreatorMap.get(cs.Id);
           casesToUpdate.add(cs);
        }
   
        update casesToUpdate;
        insert feeditemlist;
        
        Messaging.sendEmail(maillist);    
      //  handleCaseAssignment(caseid); commented: CDP2-644
    }
    @future(callout = false)
    public static void handleCaseAssignment(Set<Id> caseIds) {
        List<Case> casesToUpdate = [SELECT Id, Status, OwnerId, CreatedById,Owner.Email, (SELECT Id, Name ,CreatedById,CaseNumber__c,case_number__c,CreatedBy.name,CreatedBy.Email, Process_Status__c,recordtype.developername FROM Recoveries_Case__r ORDER BY CreatedDate DESC LIMIT 1) 
                                     FROM Case 
                                     WHERE Id IN :caseIds ];

        List<Case> casesToNotify = new List<Case>();
        list<FeedItem> feeditemlist =  new list<FeedItem >();
        Map<Id, User> userToNotify = new Map<Id, User>();
        list<Messaging.SingleEmailMessage> maillist = new list<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE name = 'QCC Reply Received' LIMIT 1];
        for (Case c : casesToUpdate) {
            if (!c.Recoveries_Case__r.isEmpty()) {
                c.OwnerId = c.Recoveries_Case__r[0].CreatedById; // last recovery creator
                if(!c.Recoveries_Case__r[0].recordtype.developername.contains('EFT')){
                     c.Status = 'Reply Received';
                }
                casesToNotify.add(c);
                feeditemlist.add(postToChatter(c.Recoveries_Case__r[0]));
                maillist.add(sendEmailUsingTemplate(c.Recoveries_Case__r[0],template, c.Recoveries_Case__r[0].CreatedBy.Email ));
            }
        }
        update casesToNotify;
        insert feeditemlist;
        Messaging.sendEmail(maillist);    
          
    }
    
    // Utility method to send notifications to users
    public static Messaging.SingleEmailMessage sendEmailUsingTemplate(Recovery__c recovery, EmailTemplate template, String toAddress) {        
         Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id,null,recovery.Id);
         email.setToAddresses(toAddress.split(','));
        email.setSaveAsActivity(false);    
        return email;      
    }  
    
    public static FeedItem postToChatter(Recovery__c recovery) {        
        
        String message = 'Please note Case ' + recovery.CaseNumber__c + ' has been transferred to you for further action on recovery ' 
                    + recovery.Name + '. Please resolve and resubmit for recovery processing.';

        // Post to Chatter Feed on the Case
        FeedItem post = new FeedItem();
        post.ParentId = recovery.CreatedById; //updated CDP2-644 from createdBy.id to createdById
        post.Body = message ;
        //post.RelatedRecordId = recovery.id;
        return post;
    }
}