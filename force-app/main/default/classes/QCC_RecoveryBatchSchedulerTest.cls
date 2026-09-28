@isTest
public class QCC_RecoveryBatchSchedulerTest {
    static testMethod void test() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        String CRON_EXP = '0 0 0 25 3 ? 2030';
        Test.startTest();
        String jobId = System.schedule('RecoveryBatchClassTest',CRON_EXP, new QCC_RecoveryBatchScheduler());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2030-03-25 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}