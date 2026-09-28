global class QCC_DeleteOffloadPassengersSchedulable implements System.Schedulable {
	global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new QCC_DeleteOffloadPassengerBatchProcess(), 200);
    }
}