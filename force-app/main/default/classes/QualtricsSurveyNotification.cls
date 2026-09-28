/***********************************************************************************************************************************

Description: Apex class for Qualtrics Survey notification to the end customer. 

History:
======================================================================================================================
Name                          Description                                           Tag
======================================================================================================================
Yuvaraj MV                    Qualtrics Survey notification to the end customer     T01
Created Date    : 24/04/19 (DD/MM/YYYY)

TestClass       : QualtricsSurveyNotification_Test
**********************************************************************************************************************************/

public with sharing class QualtricsSurveyNotification 
{
 /*----------------------------------------------------------------------------------------------      
    Method Name:        updateCaseForQualtrics
    Description:        Make Qualtrics_Survey_Required__c to true if the picklist value on case is present in custom metadata 
    Parameter:          List,oldMap
    ----------------------------------------------------------------------------------------------*/
    
    public static void updateCaseForQualtrics(List<Case> lstCase, Map<Id, Case> oldMap) 
    {
        try{
            Map<string, QualtricsSurvey__mdt> qualtricsMap = new Map<string, QualtricsSurvey__mdt>();
            List<Case> updateCase = new List<Case>();
            system.debug('updateCaseForQualtrics:');  
            //Map<string,Schema.RecordTypeInfo> recordTypeInfo = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
            for(QualtricsSurvey__mdt eachQualtrics: [select Case_Record_Type__c, Type__c, Category__c, Group__c, Sub_Category__c
                                                     from QualtricsSurvey__mdt])
            {
                string tempConcat = eachQualtrics.Case_Record_Type__c+'-'+ eachQualtrics.Type__c +'-'+eachQualtrics.Category__c +'-' +eachQualtrics.Group__c +'-' +eachQualtrics.Sub_Category__c;
                qualtricsMap.put(tempConcat,eachQualtrics);
            }
            system.debug('qualtricsMap: '+qualtricsMap);  
            //system.debug('recordTypeInfo: '+recordTypeInfo);
            for(Case newCs: lstCase) 
            {
                //Schema.RecordTypeInfo = recordTypeInfo.get(newCs.RecordTypeId);
                string tempRecordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(newCs.RecordTypeId).getDeveloperName();
                string newConcat = tempRecordTypeName+'-'+ newCs.type+'-'+newCs.Category__c +'-'+newCs.Group__c +'-' +newCs.Sub_Category__c;
                system.debug('qualtricsMap: '+ qualtricsMap);  
                system.debug('newConcat: '+ newConcat);             
                QualtricsSurvey__mdt objQualtrics = qualtricsMap!= null ? qualtricsMap.get(newConcat): null;
                
                system.debug('objQualtrics: '+ objQualtrics);
                if(objQualtrics==null)
                {
                    newCs.Qualtrics_Survey_Required__c = true;
                }
                else
                {
                    newCs.Qualtrics_survey_required__c = false;
                }
            }
            
        } catch(Exception ex){
            system.debug('ex###############'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Case Trigger Handler', 'CaseTriggerHelper', 
                                    'updateCaseForQualtrics', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }
}