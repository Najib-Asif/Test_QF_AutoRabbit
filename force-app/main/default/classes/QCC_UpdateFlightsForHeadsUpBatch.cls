/*********************************************************************************
Name         : QCC_UpdateFlightsForHeadsUpBatch
Created By   : Leslie Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE-469
Created Date : 12 December 2019
Usages       : Calls the API to update the flight event and retrieve passenger for each event. The batch scope is set to 1 to prevent hitting API callout limits
*********************************************************************************/
global class QCC_UpdateFlightsForHeadsUpBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    List<Id> headsUpFlightEventIds = new List<Id>();
    
    
    global QCC_UpdateFlightsForHeadsUpBatch(List<Id> headsUpFlightEventIds) {
        this.headsUpFlightEventIds = headsUpFlightEventIds; 
    }
    
    //START METHOD: query all Flight Heads Up Event
    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'SELECT Id FROM Event__c WHERE Id IN: headsUpFlightEventIds';
        if (Test.isRunningTest()) {
            queryString = queryString + ' LIMIT 1';
        }
        System.debug('###queryString: ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    
    //EXECUTE METHOD: process queried records
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('###scope: ' + scope);
        
        List<Event__c> headsUpFlightEvents = (List<Event__c>)scope;
        
        for (Event__c eventRec : headsUpFlightEvents) {
            QCC_EventFlightInfoUpdateHelper.updateforEvent(new List<Id>{eventRec.Id});            
        }
    }
    
    //FINISH METHOD: pass updated QH Ids to another class
    global void finish(Database.BatchableContext BC){
    }

}