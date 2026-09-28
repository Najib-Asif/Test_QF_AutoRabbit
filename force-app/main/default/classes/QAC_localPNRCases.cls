/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : to search for the cases with Similar PNR
* Referred in Ltng Component : QAC_PNRCasesTile & QAC_LocalSearchResults
*/

public with sharing class QAC_localPNRCases {
    
    @AuraEnabled
    public static list<Case> getAllPNRCases(String pnrNum,String caseNum) 
    {
        system.debug('PNR Number ***'+pnrNum);
        system.debug('case Num***'+caseNum);
        Id caseRTId = QAC_PaymentsProcess.fetchRecordTypeId('Case','Service Request');
        
        String myQuery;
        list<Case> caseList = new list<Case>();
        if(String.isBlank(caseNum)){
            myQuery = 'Select Id,PNR_number__c,CaseNumber,Problem_Type__c,Waiver_Sub_Type__c,Status,CreatedDate,AccountId,Account.Name,Account.Qantas_Industry_Centre_ID__c from Case where RecordTypeId = :caseRTId AND PNR_number__c = :pnrNum';
        }
        else{
            myQuery = 'Select Id,PNR_number__c,CaseNumber,Problem_Type__c,Waiver_Sub_Type__c,Status,CreatedDate,AccountId,Account.Name,Account.Qantas_Industry_Centre_ID__c from Case where RecordTypeId = :caseRTId AND PNR_number__c = :pnrNum AND CaseNumber != :caseNum';
        }
        caseList = Database.query(myQuery);
        return caseList;
    }    
}