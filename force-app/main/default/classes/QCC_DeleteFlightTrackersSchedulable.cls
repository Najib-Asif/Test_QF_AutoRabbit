/*----------------------------------------------------------------------------------------------------------------------
    Author:        Purushotham
    Company:       Capgemini
    Description:   Schedulable class to execute QCC_DeleteFlightTrackersBatchProcess batch class
    Inputs:
    Test Class:     
    ************************************************************************************************
    History
    ************************************************************************************************
    02-Jul-2018      Purushotham               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
global class QCC_DeleteFlightTrackersSchedulable implements System.Schedulable {
	global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new QCC_DeleteFlightTrackersBatchProcess(), 200);
    }
}