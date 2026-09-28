public class CloneCaseAndReparentRecoveries {
    
    @InvocableMethod(label='Clone Parent Case and Reassign Recoveries' description='Clones the parent Case related to each Recovery by Case_Number__c and reassigns the Recoveries to the new Case')
    public static void cloneAndReparent(List<String> recoveryIds) {
        // Step 1: Query the Recovery records with the parent Case
        Map<String, List<Recovery__c>> caseNumberToRecoveries = new Map<String, List<Recovery__c>>();
       // Map<String, Case> caseNumberToOriginalCase = new Map<String, Case>();

        List<Recovery__c> recoveries = [
            SELECT Id, Name,Case_Number__c,Case_Number__r.ParentId,Recovery_System_log__c,casenumber__c,Case_Number__r.Casenumber
            FROM Recovery__c
            WHERE Id IN :recoveryIds
            
        ];

        for (Recovery__c rec : recoveries) {
            String caseNumber = rec.Case_Number__r.ParentId != null ? rec.Case_Number__r.ParentId : rec.Case_Number__c;
            if (!caseNumberToRecoveries.containsKey(caseNumber)) {
                caseNumberToRecoveries.put(caseNumber, new List<Recovery__c>());
            }
            caseNumberToRecoveries.get(caseNumber).add(rec);
        }
         system.debug('caseNumberToRecoveries '+caseNumberToRecoveries);

        // Step 2: Get the unique Cases by Case_Number__c
        Set<String> caseNumbers = caseNumberToRecoveries.keySet();
        List<String> fieldNames = new List<String>();
        for (String fieldName : Schema.SObjectType.Case.fields.getMap().keySet()) {
            fieldNames.add(fieldName);
        }

        // Join the fields into a comma-separated string for the SOQL query
        String soql = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM Case WHERE Id = :caseNumbers';

        List<Case> originalCases = Database.query(soql);
        
        list<id> parentCaseIds = new list<id>();
        for (Case oldCase : originalCases) {
            if(oldCase.ParentId != null){
                parentCaseIds.add(oldCase.ParentId);                
            }
            parentCaseIds.add(oldCase.Id);
        }
        system.debug('parentCaseIds '+parentCaseIds);
        map<id, case> siblingCaseIds = new map<id,case>();
        for(case cs : [select id, parentid, recordtypeid,casenumber from case where parentId in : parentCaseIds and isclosed = false]){
            siblingCaseIds.put(cs.parentid,cs);
        }

        // Step 3: Clone Cases
        List<Case> newCases = new List<Case>();
        Map<id, case> caseNumberToNewCaseId = new Map<id, case>();
        list<case> newlistCase = new list<case>();
        for (Case oldCase : originalCases) {
            if(oldCase.parentId != null && siblingCaseIds.get(oldCase.parentId) != null && oldCase.recordtypeid == siblingCaseIds.get(oldCase.parentId).recordtypeid ){
                newlistCase.add(siblingCaseIds.get(oldCase.parentId));
                caseNumberToNewCaseId.put(oldCase.parentId, siblingCaseIds.get(oldCase.parentId));
            }
            else if(siblingCaseIds.get(oldCase.id) != null && oldCase.recordtypeid == siblingCaseIds.get(oldCase.id).recordtypeid){
                newlistCase.add(siblingCaseIds.get(oldCase.Id));
                caseNumberToNewCaseId.put(oldCase.id, siblingCaseIds.get(oldCase.Id));
            }
            else{
                Case newCase = oldCase.clone(false, true, false, false);
                newCase.parentId = oldCase.ParentId != null ? oldcase.parentId : oldCase.Id;
                newCase.Status = 'Pending Recovery';
                newCase.Resolution_Method__c = '';
                newCases.add(newCase);
                newlistCase.add(newCase);
            }
        }
        boolean isexception = false;
        string expectionmsg = '';
        try{
            insert newCases;
            for (Integer i = 0; i < newCases.size(); i++) {
                caseNumberToNewCaseId.put(newCases[i].parentId, newCases[i]);
            }            
        }
        catch(exception e){
            isexception = true;
            expectionmsg = e.getmessage();
        }

        

        // Step 4: Reparent Recoveries
        List<Recovery__c> updates = new List<Recovery__c>();
        
        list<string> fromcase = new list<string>();
        list<string> tocase = new list<string>();
        list<string> recoveryName = new list<string>();
        for (String caseNumber : caseNumberToRecoveries.keySet()) {
            case newCaseId = caseNumberToNewCaseId.get(caseNumber);
            for (Recovery__c rec : caseNumberToRecoveries.get(caseNumber)) {
                if(isexception){
                    rec.process_status__c = 'Exception';
                    rec.status__c = 'Further Action Required';
                    rec.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' Rejected Recovery -  Manually Clone Case and Run Rejection on Recovery. </li></ul>' + rec.Recovery_System_log__c;
                }
                else{
                    
                   
                    fromcase.add(rec.Case_Number__c);
                    tocase.add(newCaseId.Id);
                    recoveryName.add(rec.name);
                    rec.Case_Number__c = newCaseId.id;
                    rec.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds( UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' Recovery relinked From Case ['+rec.casenumber__c+'] after failed Payment </li></ul>' + rec.Recovery_System_log__c;
                   
                    
                }                 
                updates.add(rec);
            }
        }

        update updates;
        postRecoveryChatterMessages(fromcase,tocase,recoveryName);
    }    

    @future
    public static void postRecoveryChatterMessages(list<string> fromcase ,list<string> tocase,list<string> recoveyNames) {
        
        map<id,case> casemap = new map<id,case>([select id,casenumber from case where id in : fromcase or id in : tocase]);
        List<FeedItem> feedPosts = new List<FeedItem>();

        for (integer i =0 ; i< fromcase.size() ; i++) {
            if (true) {
                FeedItem post = new FeedItem();
                post.ParentId = fromcase[i];
                post.Body = recoveyNames[i] + ' moved to Case ' +
                            casemap.get(tocase[i]).CaseNumber +
                            ' due to Failed payment (from Case ' + casemap.get(fromcase [i]).CaseNumber+ ').';
                post.Type = 'TextPost';
                feedPosts.add(post);
            }
        }

        if (!feedPosts.isEmpty()) {
            insert feedPosts;
        }
    }
}