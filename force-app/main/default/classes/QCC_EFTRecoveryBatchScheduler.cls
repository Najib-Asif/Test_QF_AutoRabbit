global class QCC_EFTRecoveryBatchScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {
        QCC_EQRecoveryController.processEFTBatchRecords();
    }
}