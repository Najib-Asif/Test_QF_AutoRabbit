/**********************************************************************
Name:  QCCRecoveryCreationControllerTest
Copyright © 2024  Qantas Airways.
======================================================
Purpose:                                                            
Test class for QCCRecoveryCreationPickListController
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL
1.0 	Navya Gamidi       02/08/2024      Initial Development
========================================================
***********************************************************************/@isTest
public class QCCRecoveryCreationControllerTest {

    @isTest
    static void testGetPicklistValues() {
        // Call the method with test data
        List<QCCRecoveryCreationPickListController.PicklistValueWrapper> resultValues = QCCRecoveryCreationPickListController.getPicklistValues(
            'Recovery__c', // objectApiName
            'Type__c' // fieldApiName
        );

        // Retrieve schema information for validation
        Schema.DescribeFieldResult fieldResult = Recovery__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        // Assert results
         System.assertEquals(picklistEntries.size(), resultValues.size(), 'Number of picklist values should match');
        for (Integer i = 0; i < picklistEntries.size(); i++) {
            System.assertEquals(picklistEntries[i].getLabel(), resultValues[i].label, 'Label should match');
            System.assertEquals(picklistEntries[i].getValue(), resultValues[i].value, 'Value should match');
        }

        List<QCCRecoveryCreationPickListController.PicklistValueWrapper> resultValuesDependent = QCCRecoveryCreationPickListController.getDependentPicklistValues(
            'Recovery__c', // objectName
            'Type__c', // controllingField
            'Recovery_Reason__c', // dependentField
             resultValues[0].value // controllingValue
        );

        System.assertNotEquals(resultValuesDependent.size(), 0, 'Dependent picklist should not be empty');

    }
}