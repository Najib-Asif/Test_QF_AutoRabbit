/*
* Created By  : Jay | TCS | Cloud Developer,
* Purpose : To Delete Files for closed service request cases that was closed 90 days ago,
  Test Class Name : QAC_ManageFilesBatch_Test.
*/
global class QAC_MFBCustomIterableExample implements iterable<ContentDocumentLink>{ 
    
    global final String caseRTId;
    global final Integer daysFromClosedDate;
    global final Boolean isCaseClosed;
    
    global QAC_MFBCustomIterableExample(String rtId, Decimal numOfDays, Boolean closed)
    {
        caseRTId = rtId; 
        daysFromClosedDate = (numOfDays == null) ? 0 : Integer.valueOf(numOfDays); 
        isCaseClosed = closed;
    } 
    global Iterator<ContentDocumentLink> Iterator(){
        return new QAC_MFBCustomIterable(caseRTId,daysFromClosedDate,isCaseClosed);   
    }
}