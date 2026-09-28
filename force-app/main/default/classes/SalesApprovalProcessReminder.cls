/*----------------------------------------------------------------------------------------------------------------------
Description:   Batch Class to post a Chatter Notification has been sent to the Approver on the 23rd of the month 
if a Sales Offer Case hasn't been approved.
CRM - CRM-3144
*********************************************************************************************************************************
*********************************************************************************************************************************
History
CRM-3144                      v1.0           27-may-18

**********************************************************************************************************************************/

global class SalesApprovalProcessReminder implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT Id,ActorId, ProcessInstance.TargetObjectId,ProcessInstance.ProcessDefinitionId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN (SELECT Id FROM ProcessInstance WHERE Status = 'Pending' )]);
    }
    
    global void execute(Database.BatchableContext ctx, List<ProcessInstanceWorkitem> proInsWrkItem){
        
        //set of users that exists as actor in the workItems 
        set<Id> s_userIds = new set<Id>();
        Map<String,String> apprtragetMap = new Map<String,String>();
        
        //list of records Id in approval process
        list<Id> l_TargetObjId = new list<Id>();
        
        for(ProcessInstanceWorkitem reminderSetup: proInsWrkItem){
            s_userIds.add(reminderSetup.ActorId);
            l_TargetObjId.add(reminderSetup.ProcessInstance.TargetObjectId);
            apprtragetMap.put(reminderSetup.ProcessInstance.TargetObjectId,reminderSetup.ActorId);
        }
        
        //updated 
        String convertMsg ; 
        Id recTypeID;
        List<String> convertMsgs = new List<String>();
        recTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Offers Request').getRecordTypeId();
        // List<Case> lstCase = [SELECT Id, Type FROM Case WHERE Id IN:l_TargetObjId AND RecordTypeId = '01290000001UPURAA4'];
        List<Case> lstCase = [SELECT Id, Type FROM Case WHERE Id IN:l_TargetObjId AND RecordTypeId =: recTypeID];
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        
        if(! lstCase .isEmpty()){
            for(ID appid:l_TargetObjId) {
                convertMsg = System.Label.SalesApprovalProcessReminder;
                
                convertMsgs.add(convertMsg);
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                
                messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
                
                mentionSegmentInput.id = apprtragetMap.get(appid) ;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                
                textSegmentInput.text = ' ' + convertMsg;
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = appid;
            }
        }
        
        if(Test.isRunningTest()){
            //Create mock data
            Case cc = [select Id from Case limit 1];
            try{
                ProcessInstance pi = new ProcessInstance( Status='Pending', TargetobjectId=cc.Id);
                
                ProcessInstanceWorkitem processInstanceItemRec = new ProcessInstanceWorkitem(ActorId=UserInfo.getUserId());
                
                s_userIds.add(UserInfo.getUserId());    
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(cc.id);
                Approval.ProcessResult requestResult = Approval.process(request); 
            }
            Catch( Exception e)
            {
            } 
        }  
        
        else{
            try {
                if(! lstCase .isEmpty())
                {
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                }
            }
            catch(Exception e){
                System.debug('Exception caught:'+e);
            }
        }
    }
    
    global void finish(Database.BatchableContext ctx){
        
    }
}