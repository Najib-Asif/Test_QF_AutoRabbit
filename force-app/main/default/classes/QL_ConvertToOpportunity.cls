/***********************************************************************************************************************************

Description: Lightning component handler for the create Adhoc Opportunity
History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam                 create Adhoc Opportunity                 T01
                                    
Created Date    : 19/07/18 (DD/MM/YYYY)

**********************************************************************************************************************************/
public with sharing class QL_ConvertToOpportunity 
{
    @AuraEnabled public Boolean isSuccess {get;set;}
    @AuraEnabled public String msg {get;set;}
    @AuraEnabled public String recID {get;set;}
    
    @AuraEnabled
    public static QL_ConvertToOpportunity createOpportunity(Id caseId)
    {
        QL_ConvertToOpportunity Obj = new QL_ConvertToOpportunity();
        
        try
        {
            Case thisCase = [Select Id, AccountId, Subject,Description from Case where Id = :caseId and AccountId!=null];
            
            If(thisCase != null)
            {
                Opportunity opp = new Opportunity();
                opp.AccountId = thisCase.AccountId;
                opp.Name = thisCase.Subject;
                opp.StageName = 'Prospecting';
                opp.CloseDate = Date.Today();
                opp.Description = thisCase.Description;
                
                
                
                Id NewRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Adhoc Charter').getRecordTypeId();
                opp.RecordTypeId = NewRecordTypeId;
            
                insert opp;
                
                thisCase.Status= 'Closed - Approved';
                update thisCase;
                obj.recID =opp.Id;
                Obj.isSuccess = true;
                Obj.msg = 'Opportunity has been Created Successfully: '+ opp.Name;
            }
            else
            {
                Obj.isSuccess = false;
                Obj.msg = 'Error occured: Please select an Account!'; 
            }
            return Obj;            
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());    
        }
    }

}