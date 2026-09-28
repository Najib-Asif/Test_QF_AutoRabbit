/*------------------------------------------------------------------------------------------------------------------------
    Author:        Purushotham
    Company:       Capgemini
    Description:   Deletes Flight Tracker records that are older than the days defined in Qantas ConfigData custom setting
				   'DaysOlderToDeleteFlightTrackers' and Origin Date less than today's date
    Inputs:
    Test Class:     
    ************************************************************************************************
    History
    ************************************************************************************************
    01-Jul-2018      Purushotham               Initial Design
------------------------------------------------------------------------------------------------------------------------*/
global class QCC_DeleteFlightTrackersBatchProcess implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer days = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('DaysOlderToDeleteFlightTrackers'));
        //System.debug('days===== '+days);
        //System.debug([SELECT Id FROM Flight_Tracker__c WHERE Origin_Date__c < :System.today() AND CreatedDate < :System.today() - days]);
        return Database.getQueryLocator([SELECT Id FROM Flight_Tracker__c WHERE Origin_Date__c < :System.today() AND CreatedDate < :System.today() - days]);
    }
    
    global void execute(Database.BatchableContext bc, List<Flight_Tracker__c> flgTrackers) {
        delete flgTrackers;
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}