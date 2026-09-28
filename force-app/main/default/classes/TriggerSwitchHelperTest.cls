@isTest
public class TriggerSwitchHelperTest {
	@isTest
    public static void allowCaseTriggerTest(){
        Test.startTest();
        TriggerSwitchHelper.allowCaseTrigger();
        System.assertEquals(true, TriggerSwitchHelper.canCaseTriggerExecute())	;
        Test.stopTest();
    }
    
    @isTest
    public static void stopCaseTriggerTest(){
        Test.startTest();
        TriggerSwitchHelper.stopCaseTrigger();
        System.assertEquals(false, TriggerSwitchHelper.canCaseTriggerExecute())	;
        Test.stopTest();
    }
}