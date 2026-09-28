/*==================================================================================================================================
Author:         Praveen Sampath
Company:        Capgemini
Purpose:        Test Class for QBDOfficeId_Batch_Schedular Class
Date:           19/12/2016          
History:

==================================================================================================================================

==================================================================================================================================*/

@isTest(SeeAllData = false)
private class QBDOfficeId_Batch_SchedularTest {
	@testSetup
	static void createTestData(){
		List<QBD_Online_Office_ID__c> lstQBDOff = TestUtilityDataClassQantas.createQBDOnlineOfficeId();
		system.assert(lstQBDOff.size() != 0, 'QBD_Online_Office_ID__c List is empty');
		insert lstQBDOff;
	}

	private static TestMethod void invokeScheduler(){
		Test.startTest();
		QBDOfficeId_Batch_Schedular qbdSchedule = new QBDOfficeId_Batch_Schedular();
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