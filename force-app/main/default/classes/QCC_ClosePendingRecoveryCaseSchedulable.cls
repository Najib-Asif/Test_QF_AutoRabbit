/*----------------------------------------------------------------------------------------------------------------------
     Description:   Schedulable class to execute QCC_ClosePendingRecoveryCaseBatchable batch class
    Inputs:
    Test Class:     
    ************************************************************************************************
    History
    ************************************************************************************************
    05-May-2025      Navya Gamidi               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
global class QCC_ClosePendingRecoveryCaseSchedulable implements System.Schedulable {
    global void execute(System.SchedulableContext sc) {
      
        Database.executeBatch(new QCC_ClosePendingRecoveryCaseBatchable(), 50);

    }
}