/*-----------------------------------------------------------------------------------------------------------------------------
Author:        Jayaraman Jayaraj
Company:       TCS
Description:   This is FreightCustomerRankingController class to display customer Ranking flag in Account lightning page.
Test Class:    FreightAllTileControllerTest
*********************************************************************************************************************************
*********************************************************************************************************************************
History

08-Aug-2017    Jay         Initial Design
01-Nov-2017    Ajay        Modified - for multiple record types
10-Jun-2026   Truong-Capgemini      CRM-12985 Code Security Remediation, PSV changes for System and User Mode for SOQL   
********************************************************************************************************************************/
public class FreightCustomerRankingController{
    
    @AuraEnabled
    public String recTypeName {get;set;}
    
    @AuraEnabled
    public Account acc {get;set;}
        
    @AuraEnabled
    public static FreightCustomerRankingController getAccRecord(Id caseId) {
        try
        {
            system.debug('Case ID ***'+caseId);
            
            FreightCustomerRankingController fcr = new FreightCustomerRankingController();
            
            Case currentCase = [Select Id,AccountId,ContactId,CaseNumber,RecordType.DeveloperName from Case where Id =: caseId WITH USER_MODE]; // CRM-12985 added WITH USER_MODE for Code Security Remediation
            Id accId = currentCase.AccountId;
            
            fcr.recTypeName = (currentCase.RecordType.DeveloperName.contains('Freight')) ? 'Freight' : 'Others';
                
            system.debug('rec T Name**'+fcr.recTypeName);
            
            if(String.isNotBlank(accId)){
                // CRM-12985 added WITH USER_MODE for Code Security Remediation
                Account currentACC = [Select Id, Name, Qantas_Industry_Centre_ID__c, BillingCountry,BillingCountryCode, Customer_Rank__c, Customer_Account_Tier_f__c, Customer_Ranking__c, Sentiment__c, Sentiment_Colour__c, Sentiment2__c, Sentiment_Indicator_Reason__c from Account where Id =: accId WITH USER_MODE];
                fcr.acc = currentAcc;
            }
            return fcr;
        }
        catch (QueryException e) { 
            //CRM-12985 added Catch for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightCustomerRankingController', 'FreightCustomerRankingController', 
                                'getAccRecord', inaccessibleFields.toString(), String.valueOf(''),false,'', e);
            String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
            throw new AuraHandledException(msg);
        }
    }
}