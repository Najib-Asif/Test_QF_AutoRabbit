//Test class for DualDependentPicklistController

@IsTest
public class DualDependentPicklistControllerTest {

    private static final String OBJ_NAME = 'Case';
    private static final String L1_FIELD = 'Business_Type__c';
    private static final String L1_VALUE = 'Clerical';
    private static final String L2_FIELD = 'Resolved_Reasons_Sub_Type__c';
    private static final String L2_VALUE = 'Process';
    private static final String L3_FIELD = 'Freight_Resolve_Reason__c';

    @TestSetUp
    public static void TestSetUp(){
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                               Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas Freight Service').Id,
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        insert u1;
    }
	
    //Test method for fetching Level2Values for the dualDependentPicklistController
    @IsTest
    static void test_getLevel2Values() {
        
        List<String> actual;
        Test.startTest();
        User u = [Select id from User where LastName = 'User1'];
        System.runAs(u){
            actual = DualDependentPicklistController.getLevel2Values(OBJ_NAME, L1_FIELD, L1_VALUE, L2_FIELD);
        }
        Test.stopTest();
        system.assertEquals(true, actual.size() > 0, 'List should not be empty');
        System.assert(
            actual.contains('Process'),
            'Expected value "process" was not found in the returned list: ' + String.valueOf(actual)
        );

    }

    //Test method for fetching Level3Values for the dualDependentPicklistController
    @IsTest
    static void test_getLevel3Values() {
        
        List<String> actual;
        Test.startTest();
        User u = [Select id from User where LastName = 'User1'];
        System.runAs(u){
            actual = DualDependentPicklistController.getLevel3Values(OBJ_NAME, L1_FIELD, L1_VALUE, L2_FIELD, L2_VALUE, L3_FIELD);
        }
        Test.stopTest(); 
        system.assertEquals(true, actual.size() > 0, 'List should not be empty');
        System.assert(
            actual.contains('Documentation'),
            'Expected value "Documentation" was not found in the returned list: ' + String.valueOf(actual)
        );
        
    }
    
    //Test method for fetching Level3Values for a blank input for Level1Value
    @IsTest
    static void test_getLevel3Values_blank() {
        
        List<String> actual;
        Test.startTest();
        User u = [Select id from User where LastName = 'User1'];
        System.runAs(u){
        	actual = DualDependentPicklistController.getLevel3Values(OBJ_NAME, L1_FIELD, '', L2_FIELD, L2_VALUE, L3_FIELD);
        }
        Test.stopTest();
        System.assertEquals(0, actual.size(), 'Should be null');
    }

}