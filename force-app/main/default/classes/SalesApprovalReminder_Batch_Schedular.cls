/*----------------------------------------------------------------------------------------------------------------------
Description:   Schedular Class to post a Chatter Notification has been sent to the Approver on the 23rd of the month 
if a Sales Offer Case hasn't been approved.
CRM - CRM-3144
*********************************************************************************************************************************
*********************************************************************************************************************************
History
CRM-3144                      v1.0           27-may-18

**********************************************************************************************************************************/
global class SalesApprovalReminder_Batch_Schedular implements Schedulable {
    
    global void execute(SchedulableContext schedulableContext) {
        salesApprovalProcessReminder opb = new  salesApprovalProcessReminder();
        Database.executeBatch(opb,1);
    }
}