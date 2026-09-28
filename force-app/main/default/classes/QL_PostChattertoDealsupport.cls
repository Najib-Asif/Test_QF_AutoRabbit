public class QL_PostChattertoDealsupport 
{
    /*@InvocableMethod
    public static void ChatterPosttoDealsupportCase(List<Case> CaseList)
    {
        system.debug('case Id***'+CaseList);
        String convertMsg;
        //List<Case> caselist = [Select Id, Type, Date_Effective_DAT__c, End_Date__c, OwnerId, Sub_Type__c, End_Date__c from Case where Id IN:CaseId];
        for(Case cobj : CaseList)
        {
            convertMsg = '\\nHi Team,';
            convertMsg+= '\\n';
            convertMsg+= 'This is to notify that this case has been raised to change TMC for a corporate account with the below details: ';
            convertMsg+= '\\nType: '+cobj.Type;
            convertMsg+= '\\n';
            if(cobj.Type == 'Deal Amendment' && cobj.Sub_Type__c == 'Change of TMC')
                convertMsg+= 'Date Effective: '+cobj.Date_Effective_DAT__c;
            if(cobj.Type == 'Deal Termination')
                convertMsg+= 'Termination Date: '+cobj.End_Date__c;
            convertMsg+= '\\n';
            convertMsg+= 'Thanks';
            
        }
        //String convertMsg = 'Account:' + ' <' + caselist[0].Date_Effective_DAT__c + '>' + 'created.';
        
        //convertMsgs.add(convertMsg);
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
        
        mentionSegmentInput.id = '00590000004hki1';
        mentionSegmentInput1.id = '00590000004hki7';
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        messageBodyInput.messageSegments.add(mentionSegmentInput1);
        
        textSegmentInput.text = ' ' + convertMsg;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = CaseList[0].Id;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        
    }*/
}