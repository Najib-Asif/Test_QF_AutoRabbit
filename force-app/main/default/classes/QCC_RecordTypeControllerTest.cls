/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Test class for QCC_RecordTypeController
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
03-Aug-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_RecordTypeControllerTest {
    static testMethod void testFetchRecordTypes() {
        Test.startTest();
        String str = QCC_RecordTypeController.fetchRecordTypes('Case');
        Test.stopTest();
        System.assert(str != null);
        List<QCC_RecordTypeController.RecordTypeWrapper> recordTypes = (List<QCC_RecordTypeController.RecordTypeWrapper>)JSON.deserialize(str, List<QCC_RecordTypeController.RecordTypeWrapper>.Class);
        System.assert(recordTypes.size() != 0, 'Record Types not returned');
    }
}