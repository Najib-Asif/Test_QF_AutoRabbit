@isTest(seeAllData = false)
private class Scheme_Contract_Renewal_SchedulerTest {
    @testSetup
    static void createTestData(){
         List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Public Scheme Rec Type','Public Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Corporate Scheme Rec Type','Corporate Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate NZD','15'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate AUD','10'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SchemesPointRoundOffNumber','500'));
        insert lstConfigData;
    }
    private static TestMethod void invokeScheduler(){
        Test.startTest();
        Scheme_Contract_Renewal_Scheduler qbdSchedule = new Scheme_Contract_Renewal_Scheduler();
        String qbdScheduleTime = '0 0 23 * * ?'; 
        String jobId = system.schedule('My Test Schedule', qbdScheduleTime, qbdSchedule); 

         // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger
                          WHERE id = :jobId];

        System.assert(ct.CronExpression == qbdScheduleTime, 'CronExpression is not matching' );
        
        // Verify the job has not run
        System.assert(0 == ct.TimesTriggered, 'Job is scheduled already' );

        Test.stopTest();
    }
}