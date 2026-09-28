/*
* Created By  : Jay | TCS | Cloud Developer,
* Purpose : To Delete Files for closed service request cases that was closed 90 days ago,
  Test Class Name : QAC_ManageFilesBatch_Test.
*/
global class QAC_ManageFilesBatch implements Database.Batchable<ContentDocumentLink> {
    
    global final String caseRTId;
    global final Integer daysFromClosedDate;
    global final Boolean isCaseClosed;
    
    global QAC_ManageFilesBatch(String rtId, Decimal numOfDays, Boolean closed)
    {
        caseRTId = rtId; 
        daysFromClosedDate = (numOfDays == null) ? 0 : Integer.valueOf(numOfDays); 
        isCaseClosed = closed;
    }
    
    global Iterable<ContentDocumentLink> start(Database.BatchableContext info){
        return new QAC_MFBCustomIterableExample(caseRTId,daysFromClosedDate,isCaseClosed);
        
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        String Query;
        
        List<Id> cdlList = new List<Id>();      
        List<ContentDocument> toDeleteCD = new List<ContentDocument>();
        Map<Id,ContentDocumentLink> cdlMap = new Map<Id,ContentDocumentLink>();
        List<FeedItem> feedList = new List<FeedItem>();
        
        for(sObject s : scope){
            if(s != null){
                ContentDocumentLink eachDoc = (ContentDocumentLink)s;
                cdlMap.put(eachDoc.ContentDocumentId,eachDoc);
                cdlList.add(eachDoc.ContentDocumentId);
            }
        }
        system.debug('Content Document**'+cdlMap);  
        
        if(!cdlMap.isEmpty())
        {                 
            for(Id eachCDId : cdlMap.keySet()){
                if(eachCDId != null){
                    ContentDocument myDoc = new ContentDocument(Id = eachCDId);
                    toDeleteCD.add(myDoc);
                    //system.debug('insidedelete:'+toDeleteCD);
                    FeedItem post = new FeedItem (Type = 'TextPost' , Body = cdlMap.get(eachCDId).ContentDocument.Title , ParentId = cdlMap.get(eachCDId).LinkedEntityId , Title ='Deleted File Chatter');
                    feedList.add(post);                 
                }               
            }
            
            if(!toDeleteCD.isEmpty()&& !feedList.isEmpty()){
                //system.debug('Content Document**'+toDeleteCD);
                //insert feedList;
                //delete toDeleteCD;
                list<Database.SaveResult> fiResults = Database.insert(feedList, false);
                Database.delete(toDeleteCD, false);
            }        
        }
    }
    global void finish(Database.BatchableContext BC){}
}