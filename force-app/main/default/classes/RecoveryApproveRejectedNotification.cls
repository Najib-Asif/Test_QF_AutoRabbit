public without sharing class  RecoveryApproveRejectedNotification {
    public static set<id> recoveryIdset = new set<id>();
    public static void recoveryToPost(list<recovery__c> newlist,map<id,recovery__c> oldmap){
        list<id> recoveryIds = new list<id>();
        
        for(recovery__c rec : newlist){
            system.debug('DJ==>'+rec.approvalCount__c + '  '+oldmap.get(rec.id).approvalCount__c );
            if(rec.approvalCount__c != 0 && oldmap.get(rec.id).approvalCount__c != rec.approvalCount__c && !recoveryIdset.contains(rec.id)) 
              {
                  recoveryIds.add(rec.id);  
                  recoveryIdset.add(rec.id);      
                   
              }            
            
        }
        if(!recoveryIds.isempty()){
            postToChatter(recoveryIds);
        }
    }
    @future
    public static void postToChatter(list<id> recoveryIds){
        map<id, string > statusmap = new map<id,string>();
        map<id, string > commentmap = new map<id,string>();
        map<id, string > nodemap = new map<id,string>();
        set<id> checkset = new set<id>();
        
        for (ProcessInstance instance :  [SELECT Id, Status, TargetObjectId,
                                          (SELECT StepStatus, OriginalActorId, ActorId, Comments, CreatedDate ,StepNodeId FROM Steps ORDER BY CreatedDate DESC LIMIT 1)
                                          FROM ProcessInstance  WHERE TargetObjectId IN :recoveryIds order by lastmodifieddate desc
                                         ]){
                                             
                                             if(!checkset.contains(instance.TargetObjectId)){
                                                 checkset.add(instance.TargetObjectId);
                                                 statusmap.put(instance.TargetObjectId , instance.Steps[0].StepStatus );
                                                 commentmap.put(instance.TargetObjectId , instance.Steps[0].Comments);
                                                 nodemap.put(instance.TargetObjectId , instance.Steps[0].StepNodeId);
                                             }
                                         }
        
        map<id,processnode> procesnode = new map<id, processnode>([select id,name from processnode where id in : nodemap.values()]);
        
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for(recovery__c rec : [select id,name,createdbyId,createdby.name , case_number__c,case_number__r.ownerId from recovery__c where id in : recoveryIds]){
            {
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();            
                input.subjectId = rec.id;
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
                ConnectApi.MarkupEndSegmentInput markupEndSegment;
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = 'Hi ';            
                body.messageSegments.add(textSegment);
                
                
                
                mentionSegmentInput.id = rec.createdbyId;
                body.messageSegments.add(mentionSegmentInput);
                
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = ' \n Recovery : '+rec.Name +' has been '+ (statusmap.get(rec.id) != null ? statusmap.get(rec.id) : '' ) +'.\n Step : '+(nodemap.get(rec.id) != null && procesnode.get(nodemap.get(rec.id)).Name != null ? procesnode.get(nodemap.get(rec.id)).Name  : '' ) +'\n Comments: '+(commentmap.get(rec.id) != null ? commentmap.get(rec.id) : '' );
                body.messageSegments.add(textSegment);
                
                input.body = body;
                
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
            }
            {
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();            
                input.subjectId = rec.case_number__c;
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
                ConnectApi.MarkupEndSegmentInput markupEndSegment;
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = 'Hi @'+rec.createdby.name;            
                body.messageSegments.add(textSegment);
                
                
                
              /*  mentionSegmentInput.id = rec.case_number__r.ownerId;
                body.messageSegments.add(mentionSegmentInput);
               */ 
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = ' \n Recovery : '+rec.Name +' has been '+(statusmap.get(rec.id) != null ? statusmap.get(rec.id) : '' )+'.\n Step : '+(nodemap.get(rec.id) != null && procesnode.get(nodemap.get(rec.id)).Name != null ? procesnode.get(nodemap.get(rec.id)).Name  : '' ) +'\n Comments: '+(commentmap.get(rec.id) != null ? commentmap.get(rec.id) : '' );
                body.messageSegments.add(textSegment);
                
                input.body = body;
                
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                batchInputs.add(batchInput);
                
            }
        }
        if(!Test.isrunningTest()){
          ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    }
    
}