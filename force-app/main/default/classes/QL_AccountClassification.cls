public class QL_AccountClassification {
    @AuraEnabled
    Public static List<Account_Classifications__c> AccountClassificationTile(String Accid) {
        return [SELECT Account__c,Classification__c,Sub_Classification__c,Reviewed_Date__c,Change_on_Procurement_Spend__c 
                FROM Account_Classifications__c
                WHERE Account__c=:Accid
                ORDER BY Reviewed_Date__c DESC];    
    }
}