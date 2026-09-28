/*==================================================================================================================================
Author:         Praveen Sampath
Company:        Capgemini
Purpose:        Test Class for QCC_CaseOwnerSLAScheduleTest Class
Date:           18/05/2018          
History:

==================================================================================================================================

==================================================================================================================================*/

@isTest(SeeAllData = false)
private class QCC_CaseOwnerSLAScheduleTest {
    @testSetup
    static void createTestData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_SLALimit','10'));
        insert lstConfigData;
        
    }

    private static TestMethod void invokeScheduler(){
        QCC_CaseOwnerSLASchedule qccSLASchedule = new QCC_CaseOwnerSLASchedule();
        String qccSLAScheduleTime = '0 0 23 * * ?'; 
        String jobId = system.schedule('My Test Schedule', qccSLAScheduleTime, qccSLASchedule); 

         // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger
                          WHERE id = :jobId];

        System.assert(ct.CronExpression == qccSLAScheduleTime, 'CronExpression is not matching' );
        
        // Verify the job has not run
        System.assert(0 == ct.TimesTriggered, 'Job is scheduled already' );
    }
    
}