/*
Purpose : To display case owner values thoroughout the case
Developed By : 
Yuvraj :        For My Agency profile response
Test Class :    QAC_CaseOwnerHistoryController_Test
*/

public class QAC_CaseOwnerHistoryController {
    
    @AuraEnabled
    public static list<OwnerHistoryData> returnCaseHistory(Id caseId){
        list<OwnerHistoryData> returnHistoryData = new list<OwnerHistoryData>();
        
        for(CaseHistory eachRec : [SELECT Id, Field, OldValue, NewValue, CreatedDate FROM CaseHistory WHERE Field = 'Owner' AND CaseId =: caseId]){
            if (!(String.ValueOf(eachRec.NewValue).startsWith('005') ||  String.ValueOf(eachRec.NewValue).startsWith('00G'))){
                returnHistoryData.add(new OwnerHistoryData(eachRec.NewValue, eachRec.CreatedDate));    
            }
        }
        
        for(CaseHistory eachRec : [SELECT Id, Field, OldValue, NewValue, CreatedDate FROM CaseHistory WHERE Field = 'Owner' AND CaseId =: caseId ORDER BY CreatedDate ASC LIMIT 2]){
            if (!(String.ValueOf(eachRec.OldValue).startsWith('005') || String.ValueOf(eachRec.OldValue).startsWith('00G'))){
                returnHistoryData.add(new OwnerHistoryData(eachRec.OldValue, eachRec.CreatedDate));    
            }
        }
        
        
        if(returnHistoryData.size() == 0){
            Case currentCaseRef = [SELECT Id, CreatedDate, Owner.Name, OwnerId FROM Case WHERE Id =: caseId];
            if(currentCaseRef != NULL){
                string varOwnerid = currentCaseRef.OwnerId;
                if(!varOwnerid.startsWith('00G')){
                    returnHistoryData.add(new OwnerHistoryData(currentCaseRef.Owner.Name, currentCaseRef.CreatedDate));  
                    
                }
                else{
                    list<Group> groupList = [SELECT Id, Name FROM Group WHERE Id =: currentCaseRef.OwnerId];
                    returnHistoryData.add(new OwnerHistoryData(groupList[0].Name, currentCaseRef.CreatedDate));
                }    
            }
        }
            
        return returnHistoryData;
    }
    
    public Class OwnerHistoryData{
        @AuraEnabled public Object ownerName;
        @AuraEnabled public DateTime historyTime;
        public OwnerHistoryData(Object ownName, DateTime hisTime){
            this.ownerName = ownName;
            this.historyTime = hisTime;
        }
    }

}