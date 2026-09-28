/* Created By : Ajay Bharathan | TCS | Cloud Developer */
public with sharing class QAC_CaseQueueAssignment {
    
    @AuraEnabled
    public Boolean isSuccess { get; set; }

    @AuraEnabled
    public String logoutInitiated { get; set; }
    
    @AuraEnabled
    public String msg { get; set; }
    
    @AuraEnabled
    public Integer casesOwned { get; set; }
    
    @AuraEnabled
    public list<String> allOptions { get; set; }
    
    public static list<Case> getUserCases(){
        //String[] closedStatus = new String[]{'Closed - Approved','Closed - Rejected'};
        String rtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        list<Case> existingCase = new list<Case>();
        existingCase = [SELECT Id,CaseNumber,OwnerId FROM Case WHERE OwnerId =: UserInfo.getUserId() AND RecordTypeId =: rtypeId AND IsClosed = False];
        return existingCase;            
    }
    
    public static map<String,Group> fetchQueueMap(){
        map<String,Group> queueMap = new map<String,Group>();
        list<Group> queues = [Select id, Name, DeveloperName from Group where Type='Queue' AND Name like 'QAC%' Order By Name ASC];
        for(Group eachG : queues){
            if(eachG != null){
                queueMap.put(eachG.Name,eachG);
            }    
        }
        return queueMap;
    }
    
    @AuraEnabled
    public static QAC_CaseQueueAssignment getQACCaseQueues()
    {
        QAC_CaseQueueAssignment obj = new QAC_CaseQueueAssignment();  
        list<String> options = new list<String>();
        for(Group g : fetchQueueMap().values())
        {
            options.add(g.Name);
        }
        obj.allOptions = options;
        obj.casesOwned = getUserCases().size();
        system.debug('obj**'+obj);
        system.debug('cases**'+getUserCases());
        return obj;
    }
    
    @AuraEnabled
    public static QAC_CaseQueueAssignment assignCaseQueue(String queueName)
    {
        QAC_CaseQueueAssignment obj = new QAC_CaseQueueAssignment();    
        obj.logoutInitiated = (String)Cache.Session.get('output');
        
        try
        {
            String queueId;
            list<Case> updateCase = new list<Case>();
            
            for(Case eachCase : getUserCases()){
                if(String.isNotBlank(queueName) && eachCase != null && !fetchQueueMap().isEmpty()){
                    queueId = fetchQueueMap().get(queueName).Id;
                    //queueId = queueMap.get(queueName);
                    eachCase.OwnerId = queueId;
                    updateCase.add(eachCase);
                }                
            }
            system.debug('updated cases**'+updateCase);
            
            if(!updateCase.isEmpty())
            {
                update updateCase;
                obj.isSuccess = true;
                obj.msg = (obj.logoutInitiated == 'yes') ? 'OWNERSHIP TRANSFERRED, PROCEED WITH LOGOUT' : 'CASE OWNER RE-ASSIGNED SUCCESSFULLY';
                obj.casesOwned = updateCase.size();
            }
            return obj;
        }
        catch(Exception ex){
            obj.isSuccess = false;
            obj.msg = ex.getMessage();
            obj.msg += ':FAILED';
            return obj;
        }
    }
    
    @AuraEnabled
    public static void modifyCacheSettings(){
        if(Cache.Session.contains('output')) {
            Cache.Session.put('output', 'no');
        } 
    }    
}