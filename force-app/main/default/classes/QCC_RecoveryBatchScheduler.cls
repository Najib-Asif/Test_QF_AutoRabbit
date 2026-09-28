//This process is not needed because there is no Contact for Non FF as part of Remediation

/*----------------------------------------------------------------------------------------------------------------------
    Author:        Purushotham
    Company:       Capgemini
    Description:   Schedulable class to execute QCC_RecoveryBatchProcess batch class
    Inputs:
    Test Class:     
    ************************************************************************************************
    History
    ************************************************************************************************
    16-Mar-2018      Purushotham               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
global class QCC_RecoveryBatchScheduler implements System.Schedulable {
    global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new QCC_RecoveryBatchProcess(), 1);
    }
}