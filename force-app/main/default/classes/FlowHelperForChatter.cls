/*----------------------------------------------------------------------------------------------------------------------
Author:        Pankaj Sharma
Description:   Posting chatter for the public/private chatter group - Method called from flow
Inputs:        sObject,Static message and Group Id 
Test Class:    FlowHelperForChatterTest 
************************************************************************************************
History
************************************************************************************************
13-Mrch-2026             Pankaj Sharma          Initial Design*/

public with sharing class FlowHelperForChatter {
    public static final String NOTIFICATION_TYPE = 'Created_Notification_for_Offer_Catalogue';
    
    @InvocableMethod(label='Post to Chatter'description ='Posting chatter for the public/private chatter group')
    public static void postToChatter(List<Request> requests){  
        if (requests == null || requests.isEmpty()) {
            return;
        }
        if (requests == null || requests.isEmpty()) return;
        
        // 1) Validate & collect groupIds
        Set<Id> groupIds = new Set<Id>();
        List<Request> valid = new List<Request>();
        for (Request r : requests) {
            if (r == null)
                continue;
            if(r.groupId == null)
            {
                continue;
            }
            if(r.inputCollection == null)
            {
                 continue;
            }
            groupIds.add(r.groupId);
            valid.add(r);
        }
        if (valid.isEmpty()) return;
        // --- Resolve Custom Notification Type
        Id notifTypeId = null;
        try {
            // Remove WITH SECURITY_ENFORCED if not supported in your org for this object.
            CustomNotificationType cnt = [
                SELECT Id
                FROM CustomNotificationType
                WHERE DeveloperName = :NOTIFICATION_TYPE
                LIMIT 1
            ];
            notifTypeId = (cnt != null) ? cnt.Id : null;
        } 
        catch(Exception ex){
                          CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Notification to chatter post', 
                           'FlowHelperForChatter','postToChatter', String.valueOf(''), String.valueOf(''),false,'',ex);
        }  
        Map<Id, Set<string>> groupIdToMemberIds = new Map<Id, Set<string>>();
        if (!groupIds.isEmpty()) {
            // Add WITH SECURITY_ENFORCED 
            for (CollaborationGroupMember gm : [
                SELECT CollaborationGroupId, MemberId
                FROM CollaborationGroupMember
                WHERE CollaborationGroupId IN :groupIds WITH SECURITY_ENFORCED
            ]) {
                Set<string> members = groupIdToMemberIds.get(gm.CollaborationGroupId);
                if (members == null) {
                    members = new Set<String>();
                    groupIdToMemberIds.put(gm.CollaborationGroupId, members);
                }
                members.add(string.valueof(gm.MemberId));
            }
        }
        Id networkId = Network.getNetworkId();
        for(Request req :Valid ){
            try{
                Id recordId = (Id) req.inputCollection.get('Id');
                String recordName = (String) req.inputCollection.get('Name');
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                feedItemInput.body = new ConnectApi.MessageBodyInput();
                feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                //Mention Group
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = req.groupId;
                feedItemInput.body.messageSegments.add(mentionSegment);
                // text before
                // Parse JSON into a Map
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(req.messageTemplateJSON);
                string textBefore=(String) jsonMap.get('Para1');
                if (String.isNotBlank(textBefore)) {
                    ConnectApi.TextSegmentInput text1 = new ConnectApi.TextSegmentInput();
                    text1.text = textBefore;
                    feedItemInput.body.messageSegments.add(text1);
                }
                //Case Link
                ConnectApi.EntityLinkSegmentInput Link = new ConnectApi.EntityLinkSegmentInput();
                Link.entityId = recordId;
                feedItemInput.body.messageSegments.add(Link);
                // text After 
                string textAfter=(String) jsonMap.get('Para2');
                if (String.isNotBlank(textAfter)) {
                    ConnectApi.TextSegmentInput text1 = new ConnectApi.TextSegmentInput();
                    text1.text = textAfter;
                    feedItemInput.body.messageSegments.add(text1);
                }
                feedItemInput.subjectId = recordId;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                //Map Notification Details
                Map<String,Object> notificationDetails = new Map<String,Object>();
                notificationDetails.put('jsonMap', jsonMap);
                notificationDetails.put('notifTypeId', notifTypeId);
                notificationDetails.put('recordId', recordId);
                notificationDetails.put('recordName', recordName);
                //Post to case Feed
                ConnectApi.FeedElement result = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(),feedItemInput);
                //  Use groupMembersid to send notifications here 
                if(result.Id != null && result.Id != ''&& notifTypeId != null){    
                    Set<string> recipientsSet = groupIdToMemberIds.get(req.groupId);            
                    if(recipientsSet != null && !recipientsSet.isEmpty()) {                        
                        notificationDetails.put('recipientsSet' , recipientsSet);                        
                        sendNotificationToGroup(notificationDetails);
                    }
                }
            } 
            catch(Exception ex){
                
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Notification to chatter post', 
                                        'FlowHelperForChatter','postToChatter', String.valueOf(''), String.valueOf(''),false,'',ex);
            } 
        }
        
    }
    
    public static void sendNotificationToGroup(Map<String,Object> notificationDetails){
        Map<String,Object> jsonMap = (Map<String,Object>) notificationDetails.get('jsonMap');
        String objName = (String) jsonMap.get('Para3');
        String notificationMessage = (String) jsonMap.get('Para4');
        Messaging.CustomNotification custNotify= new Messaging.CustomNotification();
        String recordName = (String) notificationDetails.get('recordName');
        String displayName = String.isNotBlank(recordName) ? '"' + recordName + '"' : 'the record';
        custNotify.setTitle(objName + displayName + notificationMessage);
        custNotify.setBody('Click to view the record.');
        custNotify.setNotificationTypeId((String) notificationDetails.get('notifTypeId'));
        custNotify.setTargetId((String) notificationDetails.get('recordId')); 
        custNotify.send((Set<String>) notificationDetails.get('recipientsSet'));
    }
    public class Request{
        @InvocableVariable(required=true)
        public SObject inputCollection;        
        @InvocableVariable(required=true)
        public string messageTemplateJSON; 
        @InvocableVariable(required=true)
        public id groupId;
        
    }
}