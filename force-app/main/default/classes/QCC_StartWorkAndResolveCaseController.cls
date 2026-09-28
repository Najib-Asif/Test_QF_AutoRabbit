/*********************************************************************************
Name         : QCC_StartWorkAndResolveCaseController
Created By   : Lora Mae Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 12 March 2020
Usages       : Apex controller class for QCC_StartWorkAndResolveCase Aura component
*********************************************************************************/
public  class QCC_StartWorkAndResolveCaseController {    
    
    //13-Feb-2020    Lora Mae Dapulang             GRAPHITE-1748 | Switch for "Start Work" and "Resolve Case" buttons
    @AuraEnabled
    public static RelatedCaseWrapper changeCaseRecordStatus(Id recId) {
        List<String> caseStatusForStartWorkList = Label.QCC_CaseStatusConditionForStartWork.split(';');
        List<String> caseStatusForResolveCaseList = Label.QCC_CaseStatusConditionForResolveCase.split(';');
        User u = [Select id, Name, City,location__c, profileId, profile.Name from User Where id=:UserInfo.getUserId()];
        Case cs = [SELECT Id, Status, OwnerId, ClosedDate, Closed_By__c FROM Case WHERE Id = :recId];
        String rid = recId;
        RelatedCaseWrapper myWrapper = new  RelatedCaseWrapper();
        myWrapper.hasError = false;
        myWrapper.errorMessage = '';
        myWrapper.caseStatus = cs.Status;
        
        system.debug('###u.Id: ' + u.Id);
        system.debug('###recId: ' + recId);
        system.debug('###cs.Status: ' + cs.Status);
        
        try {
            if (caseStatusForStartWorkList.contains(cs.Status)){
                cs.OwnerId = u.Id;
                cs.Status = 'In Progress';
            } //353 Added owner Id check
            else if (caseStatusForResolveCaseList.contains(cs.Status) && cs.OwnerId == u.Id){
                cs.OwnerId = u.Id;
                cs.Status = 'Closed'; //CRM-4960
                cs.Closed_By__c =  u.Id;
            } //353 story changes
            else  if(caseStatusForResolveCaseList.contains(cs.Status) && cs.OwnerId != u.Id) {
                //Update Case to Closed and trigger VR which exists on CaseStatusUpdateHandler
                cs.Status = 'Closed';
            }

            update cs;
            myWrapper.caseStatus  = cs.Status;

            system.debug('###cs: ' + cs);
            system.debug('###myWrapper.caseStatus: ' +  myWrapper.caseStatus);
        }
        catch(Exception ex){
            myWrapper.hasError = true;
            String errorMsg = ex.getMessage();
            system.debug('###catch myWrapper.hasError: ' + myWrapper.hasError);
            
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ') != null ? errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ') : errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION: ', '. ');
            }
            else if(errorMsg.contains('INSUFFICIENT_ACCESS_OR_READONLY')){
                errorMsg = errorMsg.substringBetween('INSUFFICIENT_ACCESS_OR_READONLY, ', ': ');
            }
            
            myWrapper.errorMessage = errorMsg;
            System.debug('>>>errorMsg:'+errorMsg);
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC Start Work And Resolve Button', 'QCC_StartWorkAndResolveCaseController', 'changeCaseRecordStatus', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        system.debug('###catch myWrapper.hasError: ' + myWrapper.hasError);
        system.debug('###catch myWrapper.errorMessage: ' + myWrapper.errorMessage);
        system.debug('###catch myWrapper.caseStatus: ' + myWrapper.caseStatus);
        
        return myWrapper;
    }
    
    public class RelatedCaseWrapper {
        @AuraEnabled public Boolean hasError        {get;set;}
        @AuraEnabled public String errorMessage     {get;set;}
        @AuraEnabled public String caseStatus       {get;set;}
    }
}