global class AcquireEligibilityDealingFlagUpdate implements Database.Batchable<account>{

   global Account[] start(Database.BatchableContext BC){
      String prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
      System.debug('MyRecordTypeId: '+prospectRecordTypeId);
       return [select id,Contract_Commencement_Date__c, Contract_Expiry_Date__c, Dealing_Flag__c,Agency__c, Sic, Aquire_Override__c from account where recordtypeId=:prospectRecordTypeId];
   }

   global void execute(Database.BatchableContext BC, List<account> acc){
   
    for( account a:acc)
       {
        System.debug('*****'+a.Id+'  '+a.Id);
        if((a.Contract_Commencement_Date__c < System.today()) && (a.Contract_Expiry_Date__c > System.today())){
            a.Dealing_Flag__c='Y';    
           }else{
            a.Dealing_Flag__c='N';
       }
    } 
    update acc;
}
    global void finish(Database.BatchableContext BC){
   }

}