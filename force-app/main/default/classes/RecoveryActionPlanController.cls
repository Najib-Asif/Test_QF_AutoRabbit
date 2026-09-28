public with sharing class RecoveryActionPlanController {
    @AuraEnabled(cacheable=false)
    public static List<EventActionPlan__c> getReimbursementData(Id recordId, String name) {
        
        return [
            SELECT Id, Name, Eligibility_Comments__c, Arrangement_Comments__c, Expense_Claim_Guide_Comments__c, 
                   Eligibility_Indicator__c, Arrangements_Indicator__c, Expense_Claim_Guide__c
            FROM EventActionPlan__c
            WHERE FlightEvent__c = :recordId 
              AND Name = :name AND ActionCompleted__c = true
        ];
    }
}