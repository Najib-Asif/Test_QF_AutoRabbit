/*********************************************************************************
Name         : QCC_LoyaltyStatusSendSMSSchedulable
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 04 October 2019
Usages       : This class is used to schedule and get all records that will be process by the batch
*********************************************************************************/
global class QCC_FlightEventCloseHeadsUpSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.debug('QCC_FlightEventCloseHeadsUpSchedulable.execute');
        
        Database.executeBatch(new QCC_FlightEventCloseHeadsUpBatch(), 200);
    }
}