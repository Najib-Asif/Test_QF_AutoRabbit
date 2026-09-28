/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay Sadhanand B
Company:       TCS
Description:   Class used for Open All Cases tile for lightning component
Test Class:    FreightAllTileControllerTest     
*********************************************************************************************************************************
History
04-Aug-2017    Ajay               Initial Design
09-Jun-2026    Sruthi Anil        CRM 12986-Code Security Remediation      
********************************************************************************************************************************/
public with sharing class FreightOpenCasesController { //CRM 12986- added with sharing for Code Security Remediation

    @AuraEnabled
    public static list<Case> getAllOpenCases(String caseId) {
        try{
        
        String[] caseStatusval = new String[]{'Open','On Hold','Assigned','Acknowledged'};
        
        list<Case> openCaseList = new list<Case>();
        system.debug('Case ID ***'+caseId);

        if(String.isNotBlank(caseId)){
            Case currentCase = [Select Id,AccountId,Account.Name from Case where Id =: caseId with USER_MODE];//12986- Code Security Remediation
            for(Case c : [Select CaseNumber,Subject,Type,Sub_Type_1__c,Sub_Type_2__c,Status,Freight_Case_Status_Flag__c from Case where AccountId =: currentCase.AccountId AND Status in: caseStatusval with USER_MODE]){ //CRM 12986- Code Security Remediation
                c.Subject = c.Subject.length() > 120 ? c.Subject.subString(0,120) + '...' : c.Subject;
                openCaseList.add(c);
            }
        }
        
        if(!openCaseList.isEmpty())        
            return openCaseList;
        else
            return null;
    } catch (QueryException ex) { //CRM-12986 added Catch for Code Security Remediation
	
	        Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
	            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightOpenCasesController', 'FreightOpenCasesController','getAllOpenCases', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
	             String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
            throw new AuraHandledException(msg);}
}

}