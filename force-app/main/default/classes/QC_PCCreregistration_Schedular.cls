/**********************************************************************************************************************************

Created Date    : 15/11/2019 (DD/MM/YYYY)
Added By        : Vinothkumar Balasubramanian
Description     : Schedular Class for running the Batch Class QC_PCCreregistrationBatch
JIRA            : TS-4823
Version         : V1.0 - 15/11/19 - Initial version

**********************************************************************************************************************************/

global class QC_PCCreregistration_Schedular implements Schedulable {
    
    global void execute(SchedulableContext schedulableContext) 
    {
        QC_PCCreregistrationBatch assetPCCStatusUpdate = new QC_PCCreregistrationBatch();
        Database.executeBatch(assetPCCStatusUpdate,20);
    }
}