/**********************************************************************************************************************************

Created Date    : 13/12/2019 (DD/MM/YYYY)
Added By        : Karpagam Swaminathan
Description     : TestClass QL_OpptyRenewalChatterPost_Schedular
JIRA            : CRM - 4101
Version         : V1.0 -  Initial version


**********************************************************************************************************************************/

@isTest
private class QL_OpptyRenewalChatterPost_SchedularTest {
    
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2030';
    
    static testmethod void testScheduler() {
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new QL_OpptyRenewalChatterPost_Schedular());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2030-03-15 00:00:00', 
                            String.valueOf(ct.NextFireTime));
        
        Test.stopTest(); 
    }
}