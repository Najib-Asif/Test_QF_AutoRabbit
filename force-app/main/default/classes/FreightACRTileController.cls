/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay 
Company:       TCS
Description:   Class used for Account Contact Relation tile for lightning component
Test Class:    FreightAllTileControllerTest     
*********************************************************************************************************************************
History
1-Aug-2017    Ajay               Initial Design
2-June-2026   Jesus Suarez       CRM-12984: Added code security best practices and exception handling as part of code remediation        
       
********************************************************************************************************************************/
public with sharing class FreightACRTileController {//CRM-12984 added Catch for Code Security Remediation
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getACRRecord
    Description:        Method for retrieving Account Contact Relation
    Parameter:          Case Id 
    --------------------------------------------------------------------------------------*/
    
    @AuraEnabled
    public static AccountContactRelation getACRRecord(Id caseId) {
    try{
        system.debug('Case ID ***'+caseId);
        Case currentCase = [Select Id,AccountId,ContactId,CaseNumber from Case where Id =: caseId WITH USER_MODE]; //jira : CRM-12984: Added code security best practices and exception handling as part of code remediation
        Id aId = currentCase.AccountId;
        Id cId = currentCase.ContactId;
        AccountContactRelation currentACR = [Select Id,IsDirect,Freight_City__c,Related_Phone__c,Related_Email__c,Freight_Persona__c,AccountId,Account.Name,Contact.FirstName,Contact.LastName,Job_Title__c,ContactId 
                                             from AccountContactRelation where AccountId =: aId and ContactId =: cId WITH SYSTEM_MODE];//jira : CRM-12984: Added code security best practices and exception handling as part of code remediation
        if(currentACR == null)
            return null;
        else
            return currentACR;

    } catch (QueryException ex) { //CRM-12984 added Catch for Code Security Remediation
 
       Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
          CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightACRTileController', 'FreightACRTileController','getACRRecord', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
            String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
           throw new AuraHandledException(msg);}
    
}
}