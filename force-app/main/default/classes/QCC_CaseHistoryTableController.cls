public class QCC_CaseHistoryTableController {
    /*--------------------------------------------------------------------------------------      
    Method Name:        getCaseData
    Description:        To get the value of Booking_PNR__c and ContactId from active case record
    Parameter:          String caseId 
    Return:             List <Case>
    Test class:         QCC_CaseHistoryTableControllerTest (85% code coverage)
    --------------------------------------------------------------------------------------*/ 
     @AuraEnabled(cacheAble = false)//Contact.RecordType.name,
     public static List <Case> getCaseData(String caseId){
        List <Case> result = [SELECT Contact.RecordType.name,Id, Booking_PNR__c, ContactId,Contact.Name, Frequent_Flyer_Number__c FROM Case Where Id =: caseId];
        System.debug('getCaseData>>'+ result);
        return result;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getCaseCommentFromPNR
    Description:        Get all related CaseComment based on pnr
    Parameter:          String pnr 
    Return:             List<CaseComment>
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled(cacheAble = false)
    public static List<CaseComment> getCaseCommentFromPNR(String pnr){
        System.debug('getCaseCommentFromPNR');
        pnr = QCC_GenericUtils.doTrim(pnr); 
        Set<Id> caseIds = new Map<Id, SObject>([SELECT Id, CaseNumber FROM Case Where Booking_PNR__c =: pnr]).keySet();
        
        List<CaseComment> result = [SELECT Id,Parent.Type, CommentBody, ParentId, Parent.Id, Parent.CaseNumber, CreatedDate, Parent.Contact.Name,Parent.Status 
                                    FROM CaseComment WHERE ParentId IN: caseIds and CreatedDate >= LAST_N_MONTHS:3  
                                    ORDER BY Parent.CaseNumber,CreatedDate DESC ]; // AND CreatedDate = LAST_N_MONTHS:3
                                    return result;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        getCaseCommentFromCase
    Description:        Get all related CaseComment on Case
    Parameter:          Id caseId 
    Return:             List<CaseComment>
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled(cacheAble = false)
    public static List<CaseComment> getCaseCommentFromCase(Id CaseID ){
        System.debug('getCaseCommentFromCase');
        return [SELECT Id, CommentBody, Parent.Id, Parent.CaseNumber, CreatedDate, Parent.Contact.Name, Parent.Contact.Frequent_Flyer_Number__c, Parent.Status 
                FROM CaseComment 
                WHERE ParentId =: CaseID 
                ORDER BY CreatedDate DESC];
        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getCaseCommentFromContact
    Description:        Get all related CaseComment based on contact
    Parameter:          String contactId 
    Return:             List<CaseComment>
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled(cacheAble = false)
    public static List<CaseComment> getCaseCommentFromContact(String contactId){
        System.debug('getCaseCommentFromContact');
        return [SELECT Id, CommentBody, Parent.Id,Parent.Booking_PNR__c, Parent.CaseNumber, CreatedDate, Parent.Contact.Name, Parent.Status 
                FROM CaseComment 
                WHERE Parent.Contact.RecordType.DeveloperName <> 'Placeholder' AND Parent.ContactId <> null AND Parent.ContactId =: contactId ORDER BY CreatedDate DESC];
        
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        getCaseCommentFromFFNumber
    Description:        Get all related CaseComment based on Frequent Flyer Number
    Parameter:          String ffNumber 
    Return:             List<CaseComment>
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled(cacheAble = false)
    public static List<CaseComment> getCaseCommentFromFFNumber(String ffNumber){
        System.debug('getCaseCommentFromFFNumber');
        return [SELECT Id, CommentBody, Parent.Id, Parent.CaseNumber, CreatedDate, Parent.Contact.Name, Parent.Contact.Frequent_Flyer_Number__c, Parent.Status 
                FROM CaseComment 
                WHERE Parent.Contact.RecordType.DeveloperName <> 'Placeholder' AND Parent.ContactId <> null AND Parent.Contact.Frequent_Flyer_Number__c <> null AND Parent.Contact.Frequent_Flyer_Number__c =: ffNumber ORDER BY CreatedDate DESC];
        
    }
    
    // Raghav Starts  

    /*--------------------------------------------------------------------------------------      
    Method Name:        retrieveCaseComments
    Description:        Get CaseComment and Task records of the case.
    Parameter:          String caseId 
    Return:             List<CaseCommentHistory> (A wrapper object)
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled(cacheAble=false)
    public static List<PNRHistoryWrapper> retrieveCaseComments(String pnr, String caseId, Integer limitSize, Integer offset) {
        List<PNRHistoryWrapper> pnrHistoryList = new List<PNRHistoryWrapper>();
        Map<ID,DateTime> createdDateMap = new Map<ID,DateTime>();
        if(offset == 2000){
            limitSize = 10000; // If offset is 2000, set a larger limit size (e.g., 10000)
        }
        // Check if offset is greater than 2000, in which case, return an empty list
        if(offset > 2000){
            return pnrHistoryList; // Return an empty caseCommentHistoryList
        }
        try {
            Map<Id, Task> taskMap = new Map<Id, Task>();
            Set<String> listPNR = new Set<String>();

            // Retrieve all related PNRS for the provided caseId
            List<PNR__c> relatedPNRs = [SELECT PNR__c FROM PNR__c WHERE Case__c = :caseId];
            for (PNR__c relatedPNR : relatedPNRs) {
                listPNR.add(relatedPNR.PNR__c);
            }
             //Add primary PNR to the list of additional PNRs
            listPNR.add(pnr);

            List<PNR__c> relatedPNRsCases = [SELECT Case__c,PNR__c FROM PNR__c WHERE PNR__c IN  :listPNR];
            Set<Id> caseIds = new Set<Id>();
            for (PNR__c relatedPNRCase : relatedPNRsCases) {
                caseIds.add(relatedPNRCase.Case__c);
            }
            caseIds.add(caseId);
            List<CaseComment> caseComments = new List<CaseComment>([
                                            SELECT Id, CommentBody, ParentId, CreatedDate,
                                                Parent.Type, Parent.Booking_PNR__c, Parent.PNR_Number__c, Parent.Status, Parent.CaseNumber,
                                                CreatedBy.Name, Parent.Contact.Name
                                            FROM CaseComment
                                            WHERE ParentId IN :caseIds 
                                            AND CreatedDate >= LAST_N_MONTHS:3
                                            ORDER BY CreatedDate DESC
                                            LIMIT :limitSize OFFSET :offset
                                        ]);

            //Clone casecomments of primary PNR to all related PNRs of the case
            List<CaseComment> clonedBookingPNRComments = new List<CaseComment>();
            for (CaseComment comment : caseComments) {
                if(comment.parentID == caseId ){
                    clonedBookingPNRComments.add(comment);
                    for (PNR__c relatedPNR : relatedPNRs) {
                        CaseComment clonedComment = comment.clone(true, true, false, false);
                        clonedComment.Parent.Booking_PNR__c = relatedPNR.PNR__c;
                        createdDateMap.put(comment.id,comment.createdDate);
                        clonedBookingPNRComments.add(clonedComment);
                    }
                }
            }
            //Select all other cases from PNR object having additional PNR
            // Query case comments for the collected Case Ids
            List<CaseComment> clonedCaseComments = new List<CaseComment>();
                for (PNR__c relatedPNRCase : relatedPNRsCases) {
                    if(relatedPNRCase.case__c!=caseId){
                        for (CaseComment comment : caseComments) {
                            if (comment.ParentId == relatedPNRCase.Case__c) {
                                CaseComment clonedComment = comment.clone(true, true, false, false);
                                // Update the Parent.Booking_PNR__c field with the current PNR value
                                clonedComment.Parent.Booking_PNR__c = relatedPNRCase.PNR__c;
                                // Add the cloned comment to the list
                                createdDateMap.put(comment.id,comment.createdDate);
                                clonedCaseComments.add(clonedComment);
                            }
                        }
                    }
                }
            // Query case comments for related PNRS where related PNR is booking_pnr__c of any other case
            List< CaseComment> bookingPNRRelatedCommentsList = new List< CaseComment>([
                SELECT Id, CommentBody, ParentId, CreatedDate,
                    Parent.Type, Parent.Booking_PNR__c, Parent.PNR_Number__c, Parent.Status, Parent.CaseNumber,
                    CreatedBy.Name, Parent.Contact.Name
                FROM CaseComment
                WHERE Parent.Booking_Pnr__c IN :listPNR AND ParentId != :caseId AND CreatedDate >= LAST_N_MONTHS:3
                ORDER BY CreatedDate DESC
                LIMIT :limitSize OFFSET :offset
            ]);
            
            
            // Combine all case comments
            List<CaseComment> allCaseCommentsMap = new List<CaseComment>();
            //allCaseCommentsMap.addAll(bookingPNRCommentsList);
            allCaseCommentsMap.addAll(bookingPNRRelatedCommentsList);
            allCaseCommentsMap.addAll(clonedBookingPNRComments);
            allCaseCommentsMap.addAll(clonedCaseComments);
            
            List<id> listIds = new List<Id>();
            for (CaseComment caseCommentsList : allCaseCommentsMap) {
                listIds.add(caseCommentsList.Id);
            }

            // Query tasks related to the case comments
            for (Task task : [SELECT Id, TECH_Case_Comment_Id__c, WhatId, CallDurationInSeconds, CreatedBy.Name,
                              Case_Status__c, QCC_Caller_Full_Name__c, Who.Name  
                              FROM Task 
                              WHERE  TECH_Case_Comment_Id__c = :listIds]) {
                taskMap.put(task.TECH_Case_Comment_Id__c, task);           
            }
            
            // Create PNR history wrapper objects
            Map<String, PNRHistoryWrapper> pnrHistoryMap = new Map<String, PNRHistoryWrapper>();
            for (CaseComment cc : allCaseCommentsMap) {
                String pnrNumber = cc.Parent.Booking_Pnr__c.toUpperCase();
                if (!pnrHistoryMap.containsKey(pnrNumber)) {
                    PNRHistoryWrapper pnrHistory = new PNRHistoryWrapper();
                    pnrHistory.PNRNumber = pnrNumber;
                    pnrHistory.caseCommentHistoryList = new List<CaseCommentHistory>();
                    pnrHistoryMap.put(pnrNumber, pnrHistory);
                }
                
                CaseCommentHistory cch = new CaseCommentHistory();
                cch.CaseCommentId = cc.Id;
                cch.CommentBody = cc.CommentBody;
                cch.UniqueNum = generateRandomString(10);
                cch.CaseNumber = cc.Parent.CaseNumber;
                if(cc.createdDate != null){
                    cch.CommentDate = cc.createdDate;
                }
                else{
                    cch.CommentDate = createdDateMap.get(cc.id);
                }
                cch.CaseType = cc.Parent.Type;
                cch.CaseStatus = cc.Parent.Status;
                cch.CaseId = cc.ParentId;
                cch.ContactName = cc.Parent.Contact.Name;
                cch.Consultant = cc.CreatedBy.Name;
                
                // Set task-related fields if available
                if (taskMap.containsKey(cc.Id)) {                                          
                    cch.Caller = String.isNotBlank(taskMap.get(cc.Id).QCC_Caller_Full_Name__c) ? taskMap.get(cc.Id).QCC_Caller_Full_Name__c : taskMap.get(cc.Id).Who.Name;
                    cch.Consultant = taskMap.get(cc.Id).CreatedBy.Name;
                    if (taskMap.get(cc.Id).CallDurationInSeconds != null) {
                        Integer seconds = taskMap.get(cc.Id).CallDurationInSeconds;
                        Integer hours = seconds / 3600;
                        Integer minutes = Math.mod(seconds, 3600) / 60;
                        String duration = hours + 'h ' + minutes + 'm';
                        cch.Duration = duration;                  
                    }
                }
                
                cch.PnrNo = pnrNumber;
                
                pnrHistoryMap.get(pnrNumber).caseCommentHistoryList.add(cch);
            }
            pnrHistoryList.addAll(pnrHistoryMap.values());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return pnrHistoryList;
    }
    


 /*--------------------------------------------------------------------------------------      
    Method Name:        retrieveCaseCommentsContact
    Description:        Get CaseComment and Task records of the case for contact
    Parameter:          String caseId 
    Return:             List<CaseCommentHistory> (A wrapper object)
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled(cacheAble = false)
    public static List<CaseCommentHistory> retrieveCaseCommentsContact(String ContactId, String caseId, Integer limitSize, Integer offset){
       
        List<CaseCommentHistory> caseCommentHistoryList = new List<CaseCommentHistory>();
        
        Map<ID,DateTime> createdDateMap = new Map<ID,DateTime>();
        
        // Check for special handling of offset
        if (offset == 2000) {
            limitSize = 10000; // If offset is 2000, set a larger limit size (e.g., 10000)
        }
        
        // Check if offset is greater than 2000, in which case, return an empty list
        if (offset > 2000) {
            return caseCommentHistoryList; // Return an empty caseCommentHistoryList
        }
        
        
        Map<Id,Task> TaskMap = new  Map<Id,Task>();
        if(String.isNotBlank(ContactId)){
           
            List<CaseComment> clonedCaseComments = new List<CaseComment>();

            // Step 1: Query for relevant Case records
            Set<Id> relevantCaseIds = new Set<Id>();
            for (Case relevantCase : [SELECT Id FROM Case WHERE ContactId = :contactId AND CreatedDate >= LAST_N_MONTHS:3]) {
                relevantCaseIds.add(relevantCase.Id);
            }

            // Step 2: Query for CaseComment records related to relevant Case records
            List<CaseComment> caseComments = [SELECT Id, CommentBody, ParentId, CreatedDate,
                                            Parent.Type, Parent.Status, Parent.CaseNumber,
                                            CreatedBy.Name, Parent.Contact.Name, Parent.Booking_PNR__c
                                            FROM CaseComment
                                            WHERE ParentId IN :relevantCaseIds
                                            AND CreatedDate >= LAST_N_MONTHS:3
                                            ORDER BY CreatedDate DESC
                                            LIMIT :limitSize OFFSET :offset
                                            ];

            Set<Id> caseIds = new Set<Id>();
            Map<Id, List<CaseComment>> caseIdToCommentsMap = new Map<Id, List<CaseComment>>();
            for (CaseComment comment : caseComments) {
                caseIds.add(comment.ParentId);
                 if (!caseIdToCommentsMap.containsKey(comment.ParentId)) {
                    caseIdToCommentsMap.put(comment.ParentId,new List<CaseComment>() );
                }
                caseIdToCommentsMap.get(comment.ParentId).add(comment);
            }
            
            Map<Id, Set<String>> caseIdToPNRsMap = new Map<Id, Set<String>>();

            // Retrieve PNRs related to the Cases
           
            for (PNR__c pnr : [SELECT PNR__c, Case__c
                               FROM PNR__c
                               WHERE Case__c IN :caseIds
                              ]) {
                if (!caseIdToPNRsMap.containsKey(pnr.Case__c)) {
                    caseIdToPNRsMap.put(pnr.Case__c, new Set<String>());
                }
                caseIdToPNRsMap.get(pnr.Case__c).add(pnr.PNR__c);
            }
           //clonedCaseComments.addAll(caseIdToCommentsMap.values());
           for (List<CaseComment> commentsMap : caseIdToCommentsMap.values()) {
                clonedCaseComments.addAll(commentsMap);
            }
          
            for (Id casesListId : caseIdToPNRsMap.keySet()) {
                Set<String> pnrList = caseIdToPNRsMap.get(casesListId);
                List<CaseComment> parentComment = caseIdToCommentsMap.get(casesListId);
                //clonedCaseComments.addAll(parentComment);
                    if(pnrList!=null){
                        for (String pnr : pnrList) {
                            for(CaseComment pcc : parentComment){
                            CaseComment clonedComment = pcc.clone(true, true, false, false);
                            clonedComment.Parent.Booking_PNR__c = pnr;
                            createdDateMap.put(pcc.id,pcc.createdDate);
                            clonedCaseComments.add(clonedComment);
                        }
                    }
                }
            }
            List<id> listIds = new List<Id>();
            for (CaseComment caseCommentsList : clonedCaseComments) {
                listIds.add(caseCommentsList.Id);
            }
            for (Task tk: [SELECT Id,TECH_Case_Comment_Id__c,WhatId,CallDurationInSeconds,CreatedBy.Name,
                           Case_Status__c,QCC_Caller_Full_Name__c,Who.Name  
                           FROM Task 
                           WHERE  TECH_Case_Comment_Id__c =: listIds ]){
                               
                               TaskMap.put(tk.TECH_Case_Comment_Id__c ,tk);           
                           }
           // System.debug('***count+  : '+listIds);
            
            for(CaseComment cc : clonedCaseComments){
                CaseCommentHistory cch = new CaseCommentHistory();
                cch.CaseCommentId = cc.Id;
                cch.CommentBody = cc.CommentBody;
                cch.CaseNumber = cc.Parent.CaseNumber;
                if(cc.createdDate != null){
                    cch.CommentDate = cc.CreatedDate;
                }
                else {
                    cch.CommentDate = createdDateMap.get(cc.id);
                }
                cch.CaseType = cc.Parent.Type;
                cch.UniqueNum = generateRandomString(10);
                cch.CaseStatus = cc.Parent.Status;
                cch.CaseId = cc.ParentId;
                cch.ContactName = cc.Parent.Contact.Name;
                //cch.Duration = ccd.CallDurationInSeconds;
                //cch.Caller = ccd.QCC_Caller_Full_Name__c;
                if(cc.parent.Booking_PNR__c!=null){
                    cch.PnrNo =cc.parent.Booking_PNR__c.toUpperCase()  ;
                }
                cch.Consultant = cc.CreatedBy.Name;
                if(TaskMap.get(cc.Id)!=Null){                                          
                    cch.Caller = String.isNotBlank(TaskMap.get(cc.Id).QCC_Caller_Full_Name__c) ? TaskMap.get(cc.Id).QCC_Caller_Full_Name__c : TaskMap.get(cc.Id).Who.Name;
                    cch.Consultant = TaskMap.get(cc.Id).CreatedBy.Name;
                    if(TaskMap.get(cc.Id).CallDurationInSeconds!=Null){
                        Integer seconds = TaskMap.get(cc.Id).CallDurationInSeconds;
                        Integer hours = seconds/ 3600;
                        Integer minutes = Math.mod(seconds, 3600) / 60;
                        string duration =hours + 'h ' + minutes + 'm';
                        cch.Duration =duration;//DateTime.valueOf(TaskMap.get(ccId).CallDurationInSeconds*1000).formatGMT('HH:mm');                       
                    }
                }
                caseCommentHistoryList.add(cch);
                
                
                
            }
        }
        try {
            return caseCommentHistoryList;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    


    public class PNRHistoryWrapper {
        @AuraEnabled public String PNRNumber { get; set; }
        @AuraEnabled public List<CaseCommentHistory> caseCommentHistoryList { get; set; }
    }
    /*--------------------------------------------------------------------------------------      
    Inner Class Name:        CaseCommentHistory
    Description:        To store the data received from the casecomment and task object for the case.
    --------------------------------------------------------------------------------------*/
    
    public Class CaseCommentHistory{
        @AuraEnabled
        public String CaseCommentId {get;set;}
        
        @AuraEnabled
        public String CaseId {get;set;}
        
        @AuraEnabled
        public DateTime CommentDate {get;set;}
        
        @AuraEnabled
        public String CaseType {get;set;}
        
        @AuraEnabled
        public String Duration {get;set;}
        
        @AuraEnabled
        public String Consultant {get;set;}
        
        @AuraEnabled
        public String Caller {get;set;}

       @AuraEnabled
        public String PnrNo {get;set;}
        
        @AuraEnabled
        public String CommentBody {get;set;}
        
        @AuraEnabled
        public String CaseNumber {get;set;}
        
        @AuraEnabled
        public String CaseStatus {get;set;}
        
        @AuraEnabled
        public String ContactName {get;set;}

         @AuraEnabled
        public String UniqueNum {get;set;}
    }
    // Raghav Ends


    public static String generateRandomString(Integer length) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        
        return randStr;
    }
}