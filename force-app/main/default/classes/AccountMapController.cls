public without sharing class AccountMapController {

    @AuraEnabled
    public static List<Account> findAll() {     
        
        return [SELECT Id, recordType.Name, Name, Phone, Email__c, BillingCity, OwnerId, BillingAddress, Billing_Latitude__c,Billing_Longitude__c
           FROM Account
           WHERE (Billing_Latitude__c != 0 AND Billing_Longitude__c != 0) AND OwnerId = :UserInfo.getUserId()
           // WHERE (Billing_Latitude__c != 0 AND Billing_Longitude__c != 0)
           LIMIT 500];                
      
        
    }
     @AuraEnabled
    public static List<Account> findAllOrMy(String allOrMy) { 
        String UserOwnerId = UserInfo.getUserId();
        String queryAcc = 'SELECT Id, recordType.Name, Name, OwnerId, BillingAddress, Billing_Latitude__c,Billing_Longitude__c FROM Account WHERE (Billing_Latitude__c != 0 AND Billing_Longitude__c != 0) ';
        if(allOrMy == 'MyAccounts'){
            queryAcc = queryAcc + ' and OwnerId = :UserOwnerId ';
        }
        
        String LimitStr = ' LIMIT 500 ';
        queryAcc = queryAcc + LimitStr;
        List<Account> accList = Database.query(queryAcc);
        System.debug('accList***'+accList);
        System.debug('queryAcc'+queryAcc);
        return Database.query(queryAcc);                
      
        
    }
    
    @AuraEnabled
    public static List<String> recordTypesInfoAccount(){
        Map<String,Schema.RecordTypeInfo> mapSchem = Schema.SObjectType.Account.getRecordTypeInfosByName();
        List<String> recordTypesNameAccount = new List<String>();
        for(Schema.RecordTypeInfo tempInfo : mapSchem.Values()){
            recordTypesNameAccount.add(tempInfo.getName());
            System.debug(tempInfo.getName());
            
        }
        return recordTypesNameAccount;
        
    }
    
     @AuraEnabled
    public static List<Account> searchFilters(String citySearch, String countrySearch, String stateSearch, String zipcodeSearch, String allOrMy) {     
        
        String UserOwnerId = UserInfo.getUserId();
        String queryAcc = 'SELECT Id, recordType.Name, Name, Email__c, Phone, OwnerId, BillingCountry, BillingPostalCode, BillingCity, BillingState, BillingAddress, Billing_Latitude__c,Billing_Longitude__c FROM Account WHERE (Billing_Latitude__c != 0 AND Billing_Longitude__c != 0) ';
        if(allOrMy == 'MyAccounts'){
            queryAcc = queryAcc + ' and OwnerId = :UserOwnerId ';
        }
        if(citySearch != null){
            queryAcc = queryAcc + ' and BillingCity = :citySearch ';
        }    
         if(countrySearch != null){
            queryAcc = queryAcc + ' and BillingCountry = :countrySearch ';
        }  
         if(stateSearch != null){
            queryAcc = queryAcc + ' and BillingState = :stateSearch ';
        }  
         if(zipcodeSearch != null){
            queryAcc = queryAcc + ' and BillingPostalCode = :zipcodeSearch ';
        }  
       // String LimitStr = ' LIMIT 500 ';
      //  queryAcc = queryAcc + LimitStr;
        List<Account> accList = Database.query(queryAcc);
        System.debug('UserOwnerId****'+UserOwnerId);
        System.debug('citySearch****'+citySearch);
        System.debug('countrySearch****'+countrySearch);
        System.debug('stateSearch****'+stateSearch);
        System.debug('zipcodeSearch****'+zipcodeSearch);
        System.debug('accList***'+accList);
        System.debug('queryAcc'+queryAcc);
        return Database.query(queryAcc);                 
      
        
    }

}