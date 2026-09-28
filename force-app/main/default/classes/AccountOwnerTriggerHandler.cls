public class AccountOwnerTriggerHandler{
    
    public static void SaveOldUsers(List<Account_Owner__c> newList, Map<Id, Account_Owner__c> oldMap){
        for(Account_Owner__c ao : newList){
           
           if(ao.Account_Manager__c != oldMap.get(ao.Id).Account_Manager__c){
               ao.Old_Account_Manager__c = oldMap.get(ao.Id).Account_Manager__c;
               ao.Update_Required_AM__c = true;
           }

           if(ao.Business_Development_Rep__c != oldMap.get(ao.Id).Business_Development_Rep__c){
               ao.Old_BDR__c = oldMap.get(ao.Id).Business_Development_Rep__c;
               ao.Update_Required_BDR__c = true;
           }
            
        }
    }
}