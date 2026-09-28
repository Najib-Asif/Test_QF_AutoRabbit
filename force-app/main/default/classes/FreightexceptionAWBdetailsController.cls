/*********************************************************************************

Name         : FreightexceptionAWBdetailsController

Created By   : Vinothkumar Balasubramanian

Company Name : TCS

Project      : Freight Track & Trace

Created Date : 21 February 2019

Usage       : This Class shows the Freight Exception AWB Child case information on the Parent Case Record Page

History:
======================================================================================================================
Name                    Jira        			Description                                                 Tag
======================================================================================================================
Lerry Cabanding         CRM-12991   			Code Security Remediation

*********************************************************************************/


public with sharing class FreightexceptionAWBdetailsController {
    @AuraEnabled
    public static Case getChildCase(Id CaseId) {
        Case caseRec;
        try{
        for (Case caseRecord :  [select Id, Sub_Type_1__c, 
                                 (select Freight_AWB_Number__c, Freight_AWB_Handling_Code__c, 
                                  Freight_AWB_Pieces__c, Freight_Customer_Name__c from Cases)
                                 from Case where Id =: CaseId AND Origin = 'Elenium' WITH USER_MODE]){ //CRM-12991 Code Security Remediation
                                     if(caseRecord != null)  caseRec =  caseRecord;
                                 }
        return caseRec;
        } catch (QueryException e) { //CRM-12991 Added QueryException for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightexceptionAWBdetailsController', 'FreightexceptionAWBdetailsController', 
                        'getChildCase', inaccessibleFields.toString(), String.valueOf(CaseId),false,'', e);
            String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
            throw new AuraHandledException(msg);
        }
    }
}