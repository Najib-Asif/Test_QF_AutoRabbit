/**********************************************************************************************************************************

Created Date    : 13/12/2019 (DD/MM/YYYY)
Added By        : Karpagam Swaminathan
Description     : Schedular Calss for Chatter Notification for renewal opportunity
JIRA            : CRM - 4101
Version         : V1.0 -  Initial version


**********************************************************************************************************************************/

global class QL_OpptyRenewalChatterPost_Schedular implements Schedulable {
    
    global void execute(SchedulableContext schedulableContext) {
        QL_OpportunityRenewalChatterPost opb = new QL_OpportunityRenewalChatterPost();
        Database.executeBatch(opb,1);
    }
}