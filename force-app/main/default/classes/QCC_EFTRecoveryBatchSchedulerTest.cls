@isTest
public class QCC_EFTRecoveryBatchSchedulerTest {
    @isTest
    static void test() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        String CRON_EXP = '0 0 0 25 3 ? 2030';
       
        Test.startTest();
        String jobId = System.schedule('QCC_EFTRecoveryBatchSchedulerTest',CRON_EXP, new QCC_EFTRecoveryBatchScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2030-03-25 00:00:00', String.valueOf(ct.NextFireTime));
    }
}