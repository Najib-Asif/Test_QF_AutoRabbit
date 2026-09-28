global class QCC_DeleteOffloadPassengerBatchProcess implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer days = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('DaysOlderToDeleteOffloadPassengers'));
        String offloadRT = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'QCC Offload Passenger');
        
        System.debug([SELECT Id FROM affected_Passenger__c WHERE (OffloadRequest__c = null OR OffloadRequest__c = '') AND recordtypeId = :offloadRT AND CreatedDate < :System.today() - days]);
        return Database.getQueryLocator([SELECT Id FROM affected_Passenger__c WHERE OffloadRequest__c = null  AND recordtypeId = :offloadRT AND CreatedDate < :System.today() - days]);
    }
    
    global void execute(Database.BatchableContext bc, List<affected_Passenger__c> offloadPassengers) {
        delete offloadPassengers;
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}