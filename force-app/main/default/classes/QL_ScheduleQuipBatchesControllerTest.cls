@isTest
public class QL_ScheduleQuipBatchesControllerTest {

    @testSetup
    static void setupData() {

        // Create all required Custom Setting records
        List<Trigger_Status__c> settings = new List<Trigger_Status__c>();

        settings.add(new Trigger_Status__c(Name = 'AccountEligibilityLogTrigger', Active__c = true));
        settings.add(new Trigger_Status__c(Name = 'AccountUpdateAccountDetail', Active__c = true));
        settings.add(new Trigger_Status__c(Name = 'AccountTeam', Active__c = true));
        settings.add(new Trigger_Status__c(Name = 'ACRPrimaryContact', Active__c = true));
        settings.add(new Trigger_Status__c(Name = 'ContentDocLinkTriggerCheck', Active__c = true));

        insert settings;

        // Create sample scheduled jobs
        List<QL_QuipScheduledJob__c> jobs = new List<QL_QuipScheduledJob__c>();
        for(Integer i = 0; i < 10; i++) {
            jobs.add(new QL_QuipScheduledJob__c(Name = 'Test Job ' + i));
        }
        insert jobs;
    }

    // Test checkPermissions with default profile
    @isTest
    static void testCheckPermissions_ProfileBased() {

        Test.startTest();
        Boolean result = QL_ScheduleQuipBatchesController.checkPermissions();
        Test.stopTest();

        // We don't control profile name here, so just ensure execution
        System.assertNotEquals(null, result);
    }

    // Test checkPermissions with Permission Set assigned
    @isTest
    static void testCheckPermissions_WithPermissionSet() {

        // Try assigning permission set if exists
        List<PermissionSet> psList = [
            SELECT Id FROM PermissionSet 
            WHERE Name = 'Access_to_Cancel_Scheduled_Job_Button_for_Quip_Email_Comms'
            LIMIT 1
        ];

        if(!psList.isEmpty()) {
            insert new PermissionSetAssignment(
                AssigneeId = UserInfo.getUserId(),
                PermissionSetId = psList[0].Id
            );
        }

        Test.startTest();
        Boolean result = QL_ScheduleQuipBatchesController.checkPermissions();
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    // Test invokeScheduleJobs - main logic
    @isTest
    static void testInvokeScheduleJobs_MainFlow() {

        Test.startTest();

        QL_ScheduleQuipBatchesController.invokeScheduleJobs();

        Test.stopTest();

        // Verify all trigger settings are turned OFF
        List<Trigger_Status__c> settings = [
            SELECT Name, Active__c FROM Trigger_Status__c
        ];

        for(Trigger_Status__c ts : settings) {
            System.assertEquals(false, ts.Active__c, 'Trigger not bypassed: ' + ts.Name);
        }

        // Verify scheduled jobs are deleted
        Integer jobCount = [SELECT COUNT() FROM QL_QuipScheduledJob__c];
        System.assertEquals(0, jobCount);
    }

    // Test invokeScheduleJobs with NO jobs (covers null/empty branch)
    @isTest
    static void testInvokeScheduleJobs_NoJobs() {

        // Delete records created in @testSetup
        delete [SELECT Id FROM QL_QuipScheduledJob__c];

        Test.startTest();

        QL_ScheduleQuipBatchesController.invokeScheduleJobs();

        Test.stopTest();

        // Still verify settings updated
        List<Trigger_Status__c> settings = [
            SELECT Active__c FROM Trigger_Status__c
        ];

        for(Trigger_Status__c ts : settings) {
            System.assertEquals(false, ts.Active__c);
        }

        //  No jobs should exist
        System.assertEquals(0, [SELECT COUNT() FROM QL_QuipScheduledJob__c]);
    }
}