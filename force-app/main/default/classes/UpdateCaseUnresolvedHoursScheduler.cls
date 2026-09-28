/**********************************************************************************************************************************

Created Date    : 31/05/23 (DD/MM/YYYY)
Author          : Raghavendra Chakali
Description     : Schedular Class for running the Batch Class UpdateCaseUnresolvedHoursBatch . Added Bipass check for schedule issue
JIRA            : CRM - 6089
Test Class		: UpdateCaseUnresolvedHoursSchedulerTest
***************************************************************************************
History:
***************************************************************************************
22-June-2026		Lerry Cabanding			CRM-13443 Added without sharing for Code Security Remediation             
**********************************************************************************************************************************/

global without sharing class UpdateCaseUnresolvedHoursScheduler implements Schedulable {
  
    global void execute(SchedulableContext ctx) {
        UpdateCaseUnresolvedHoursBatch caseUnresolveHrsBatch = new UpdateCaseUnresolvedHoursBatch();
        Id batchId = Database.executeBatch(caseUnresolveHrsBatch,10);
        //String everyHourExp = '0 0 * * * ?';
        //System.schedule('Update Case Unresolved Hours Batch', everyHourExp, new UpdateCaseUnresolvedHoursScheduler());
    }
    
}