/**********************************************************************************************************************************

Created Date    : 18/10/19 (DD/MM/YYYY)
Added By        : Vinothkumar Balasubramanian
Description     : Schedular Class for running the Batch Class QC_AssetderegistrationBatch
JIRA            : TS-4816
Version         : V1.0 - 18/10/19 - Initial version

**********************************************************************************************************************************/

global class QC_AssetderegBatch_Schedular implements Schedulable {
    
    global void execute(SchedulableContext schedulableContext) 
    {
        QC_AssetderegistrationBatch assetStatusUpdate = new QC_AssetderegistrationBatch();
        Database.executeBatch(assetStatusUpdate,200);
    }
}