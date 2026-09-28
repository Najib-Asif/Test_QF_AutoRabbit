/**********************************************************************************************************************************
 
    Created Date     : 20/03/19 (DD/MM/YYYY)
    Added By         : Vinothkumar Balasubramanian
    Description      : Schedular Class to run the Batch class "FreightGenericAcccreation_Batch " daily
    Version          :V1.0 - 20/03/19 - Initial version

History:
======================================================================================================================
Name                    Jira        			Description                                                 Tag
======================================================================================================================
Lerry Cabanding         CRM-13078   			Code Security Remediation - Added without sharing
 
**********************************************************************************************************************************/




global without sharing class FreightAcccreation_Batch_Schedular implements Schedulable { //CRM-13078 Added without sharing for Code Security Remediation

        global void execute(SchedulableContext schedulableContext) {
        FreightGenericAcccreation_Batch accCreate = new FreightGenericAcccreation_Batch();
        Database.executeBatch(accCreate,200);
        }
}