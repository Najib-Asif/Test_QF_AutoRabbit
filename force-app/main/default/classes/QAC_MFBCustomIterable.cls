/*
* Created By  : Jay | TCS | Cloud Developer,
* Purpose : To Delete Files for closed service request cases that was closed 90 days ago,
  Test Class Name : QAC_ManageFilesBatch_Test.
*/
global class QAC_MFBCustomIterable implements Iterator<ContentDocumentLink>{ 
    
    List<ContentDocumentLink> cdls {get; set;} 
    Integer i {get; set;} 
    
    global final String caseRTId;
    global final Integer daysFromClosedDate;
    global final Boolean isCaseClosed;
    
    public QAC_MFBCustomIterable(String rtId, Decimal numOfDays, Boolean closed){ 
        caseRTId = rtId; 
        daysFromClosedDate = (numOfDays == null) ? 0 : Integer.valueOf(numOfDays); 
        isCaseClosed = closed;
        cdls =  [SELECT Id,ContentDocumentId,ContentDocument.Title,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN(SELECT Id FROM Case WHERE RecordTypeId = :caseRTId AND isClosed = :isCaseClosed AND Closed_Case_Age__c >=:daysFromClosedDate)]; 
        i = 0; 
    }   
    
    global boolean hasNext(){ 
        if(i >= cdls.size()) {
            return false; 
        } else {
            return true; 
        }
    }    
    
    global ContentDocumentLink next(){ 
        i++; 
        return cdls[i-1]; 
    } 
}