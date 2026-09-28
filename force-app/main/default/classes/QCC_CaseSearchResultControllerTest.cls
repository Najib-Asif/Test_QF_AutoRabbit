/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Test class for QCC_CaseSearchResultController
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
03-Aug-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_CaseSearchResultControllerTest {
    static testMethod void test() {
        Test.startTest();
        String str = QCC_CaseSearchResultController.getColumns('QCC_CaseSearchResult');
        QCC_CaseSearchResultController.getProfileToHide();
        Test.stopTest();
        System.assert(str != null, 'No columns defined in "QCC Data Table" custom metadata for QCC_CaseSearchResult LC');
        List<QCC_CaseSearchResultController.displayColumn> columns = (List<QCC_CaseSearchResultController.displayColumn>)JSON.deserialize(str, List<QCC_CaseSearchResultController.displayColumn>.Class);
        System.assert(columns.size() != 0);
    }
}