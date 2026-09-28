/*----------------------------------------------------------------------------------------------------------------------
    Author:        Bharath
    Company:       TCS
    Description:   For Bell notification feed on case on waiting for customer case status
    Test Class:     Casetriggertest
    ************************************************************************************************
    History
    ************************************************************************************************
-----------------------------------------------------------------------------------------------------------------------*/
global with sharing class QCC_FeedMentionforcasestatus {  

    public static void mentionTextPost(Id csId) { 
    String postText = ' Case ';//,' has been assigned to you!\n Case id: '+caseToUpdate[0].id
    Case c = [select id,Previous_Case_Owner__c,Type,Priority,Status,Contact_Fullname__c,CaseNumber from case where id =:csId limit 1];
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
    postText = postText+c.CaseNumber+' Reply Received \n';
    postText = postText+' Case Type: '+c.Type+'\n'; 
    postText = postText+' Priority: '+c.Priority+'\n'; 
    postText = postText+' Status: '+c.Status+'\n'; 
    postText = postText+' Customer Name: '+c.Contact_Fullname__c+'\n'; 
    postText = postText+' Date Received: '+System.today()+'\n';
        
    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();   
    mentionSegmentInput.id = c.Previous_Case_Owner__c;
    messageBodyInput.messageSegments.add(mentionSegmentInput);    
    textSegmentInput.text = postText;
    messageBodyInput.messageSegments.add(textSegmentInput);
    
    feedItemInput.body = messageBodyInput;
    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
    feedItemInput.subjectId = csId;
     if(c.Previous_Case_Owner__c != null && string.valueOf(c.Previous_Case_Owner__c).startsWith('005')){
    	ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
     }
    
  }    
}