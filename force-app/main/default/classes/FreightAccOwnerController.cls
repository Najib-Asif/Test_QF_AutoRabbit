/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay 
Company:       TCS
Description:   Class used for Account Owner tile for lightning component
Test Class:    FreightAllTileControllerTest     
*********************************************************************************************************************************
History
7-Aug-2017    Ajay               Initial Design
08-June-2026  Jesus Suarez       CRM-12983 - Added code security best practices and exception handling as part of code remediation    
       
********************************************************************************************************************************/
public with sharing class FreightAccOwnerController {

    /*--------------------------------------------------------------------------------------      
    Method Name:        getACRRecord
    Description:        Method for retrieving Account Owner
    Parameter:          Case Id 
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static User getAccOwner(String caseId) {
    try{

        system.debug('Case ID ***'+caseId);
        
        User CurrentOwner;

        if(String.isNotBlank(caseId)){
            Case currentCase = [Select Id,Account.OwnerId from Case where Id =: caseId WITH USER_MODE]; // Jira: CRM-12983 - Added code security best practices and exception handling as part of code remediation
            CurrentOwner = [Select Id,IsActive,Phone,Email,Name from User where Id =: currentCase.Account.OwnerId AND IsActive = true WITH SYSTEM_MODE]; // Jira: CRM-12983 - Added code security best practices and exception handling as part of code remediation
        }
        
        if(currentOwner <> null)        
            return CurrentOwner;
        else
            return null;
        }catch (QueryException ex) { //CRM-12983 added Catch for Code Security Remediation
                Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightAccOwnerController', 'FreightAccOwnerController','getAccOwner', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
                String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
                throw new AuraHandledException(msg);}
    } 
}