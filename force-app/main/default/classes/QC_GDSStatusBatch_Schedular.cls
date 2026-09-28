/**********************************************************************************************************************************

Created Date    : 10/09/19 (DD/MM/YYYY)
Added By        : Vinothkumar Balasubramanian
Description     : Schedular Class for running the Batch Class QC_GDSStatusBatch .
JIRA            : CRM - 3908
Version         : V1.0 - 10/09/19 - Initial version

**********************************************************************************************************************************/

global class QC_GDSStatusBatch_Schedular implements Schedulable {
    
    global void execute(SchedulableContext schedulableContext) 
    {
        QC_GDSStatusBatch tmcGDSStatusUpdate = new QC_GDSStatusBatch();
        Database.executeBatch(tmcGDSStatusUpdate,200);
    }
}