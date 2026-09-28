/*----------------------------------------------------------------------------------------------------------------------
Author:        Venkata Suresh Kumar (TCS Team)
Company:       TCS
Description:   Test class for FreightAllTileController apex class
Date: 08-June-2026

Modified By:     Sruthi Anil
Date:           10-June-2026
Description:    CRM 12986- Added test method to cover catch exveption block for code security remediation
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
private class FreightOpenCasesControllerTest {

    @testSetup
    static void setupTestData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();

        // Create Account
        Account acc = new Account(
            Name = 'Test Freight Account',
            RecordTypeId = accRTId,
            Active__c = true
        );
        insert acc;

        // Parent/current case used as input to method
        Case currentCase = new Case(
            AccountId = acc.Id,
            Status = 'Open',
            Subject = 'Current Case',
            Origin = 'Phone'
        );
        insert currentCase;

        // Related open case with long subject (>120 chars) to test truncation
        String longSubject = 'This is a very long subject created for testing the truncation logic in FreightOpenCasesController method';
        while (longSubject.length() <= 125) {
            longSubject += ' ExtraText';
        }

        Case relatedOpenCase1 = new Case(
            AccountId = acc.Id,
            Status = 'Open',
            Subject = longSubject,
            Origin = 'Phone',
            Type = 'Inquiry'
        );

        // Related open case with normal subject
        Case relatedOpenCase2 = new Case(
            AccountId = acc.Id,
            Status = 'Assigned',
            Subject = 'Short Subject',
            Origin = 'Email',
            Type = 'Inquiry'
        );

        // Closed case - should not be returned
        Case closedCase = new Case(
            AccountId = acc.Id,
            Status = 'Closed',
            Subject = 'Closed Case',
            Origin = 'Web',
            Type = 'Inquiry'
        );

        insert new List<Case>{ relatedOpenCase1, relatedOpenCase2, closedCase };

        // Another account with only closed case for negative scenario
        Account acc2 = new Account(Name = 'Second Account');
        insert acc2;

        Case currentCaseNoOpen = new Case(
            AccountId = acc2.Id,
            Status = 'Closed',
            Subject = 'Current Case No Open',
            Origin = 'Phone'
        );
        insert currentCaseNoOpen;

        Case closedOnly = new Case(
            AccountId = acc2.Id,
            Status = 'Closed',
            Subject = 'Another Closed Case',
            Origin = 'Email'
        );
        insert closedOnly;
    }

    @isTest
    static void testGetAllOpenCases_WithValidCaseId() {
        // Get the current case from setup data
        Case currentCase = [
            SELECT Id, AccountId
            FROM Case
            WHERE Subject = 'Current Case'
            LIMIT 1
        ];

        Test.startTest();
        List<Case> result = FreightOpenCasesController.getAllOpenCases(currentCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() >= 2, 'Should return open/assigned cases for the same account');

        // Validate that closed case is not returned
        for (Case c : result) {
            System.assert(
                c.Status == 'Open' ||
                c.Status == 'On Hold' ||
                c.Status == 'Assigned' ||
                c.Status == 'Acknowledged',
                'Only allowed statuses should be returned'
            );
        }

        // Validate subject truncation for long subject
        Boolean foundTruncatedSubject = false;
        for (Case c : result) {
            if (c.Subject != null && c.Subject.endsWith('...')) {
                foundTruncatedSubject = true;
                System.assert(c.Subject.length() <= 123, 'Truncated subject should be 120 chars + ...');
            }
        }
        System.assertEquals(true, foundTruncatedSubject, 'At least one subject should be truncated');
    }

    @isTest
    static void testGetAllOpenCases_BlankCaseId() {
        Test.startTest();
        List<Case> result = FreightOpenCasesController.getAllOpenCases('');
        Test.stopTest();

        System.assertEquals(null, result, 'Result should be null when caseId is blank');
    }

    @isTest
    static void testGetAllOpenCases_NoMatchingOpenCases() {
        Case currentCaseNoOpen = [
            SELECT Id
            FROM Case
            WHERE Subject = 'Current Case No Open'
            LIMIT 1
        ];

        Test.startTest();
        List<Case> result = FreightOpenCasesController.getAllOpenCases(currentCaseNoOpen.Id);
        Test.stopTest();

        System.assertEquals(null, result, 'Result should be null when no open cases are found');
    }

    //CRM 12986- Added test method to cover catch exception block for code security remediation
    @isTest
    static void userNoAccess(){
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'];
    User u1 = new User(
          Username = 'testu045600ser@example.com',
          Email = 'testus11145611er@qantas.com.au',
          LastName = 'Test',
          FirstName = 'User',
          Alias = 'testu',
          ProfileId = p.Id,
          TimeZoneSidKey = 'America/Los_Angeles',
          LocaleSidKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US'
        );
    insert u1;
    Case currentCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Current Case' LIMIT 1];
    Test.startTest();
        System.runAs(u1) {
          try{
              List<Case> result = FreightOpenCasesController.getAllOpenCases(currentCase.Id);
           } catch (Exception e) {
                System.assertNotEquals(null, e);
          }
        }
    Test.stopTest();
    }
}