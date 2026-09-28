@isTest(seeAllData = false)
private class QCC_QantasPointsSuggestedValuesTest {
    
    @isTest static void testGetSuggestedValues() {
        Test.startTest();
        Contact contact1 = new Contact(FirstName='Gold', LastName='Member', Frequent_Flyer_Tier__c='Gold');
        insert contact1;
        Case goldCase = TestUtilityDataClassQantas.createCaseWithCodingValues(
            'CCC Complaints', 'Complaint', 'Contact Centre', 
            'Ticket Changes', 'No notification of ticket changes', 'Same Day Rebooking'
        );
        goldCase.Origin = 'Qantas.com';
        goldCase.ContactId = contact1.Id;
        insert goldCase;

        // Create and insert Case_Category__c
        Case_Category__c caseCategory = new Case_Category__c(
            Type__c = goldCase.Type,
            Group__c = goldCase.Group__c,
            Category__c = goldCase.Category__c,
            Sub_Category__c = goldCase.Sub_Category__c,
            Classification__c = goldCase.Classification__c,
            Case__c = goldCase.Id
        );
        insert caseCategory;

        // Call the method under test
        Map<String, Decimal> goldResult = QCC_QantasPointsSuggestedValues.getSuggestedValues(goldCase.Id, contact1.Id);
        
        // Verify the results for Gold tier
        System.assertNotEquals(null, goldResult, 'The result map for Gold tier should not be null');
        System.assertEquals(0, goldResult.get('Suggested_Maximum__c'), 'The maximum suggested value for Gold tier should be as expected.');

        // Create and insert a Silver Frequent Flyer Contact
        Contact silverContact = new Contact(FirstName='Silver', LastName='Member', Frequent_Flyer_Tier__c='Silver');
        insert silverContact;

        // Create and insert a Case for the Silver Contact
        Case silverCase = TestUtilityDataClassQantas.createCaseWithCodingValues(
            'CCC Complaints', 'Complaint', 'Contact Centre', 
            'Ticket Changes', 'No notification of ticket changes', 'Same Day Rebooking'
        );
        silverCase.Origin = 'Qantas.com';
        silverCase.ContactId = silverContact.Id;
        insert silverCase;

        // Create and insert Case_Category__c
        Case_Category__c silverCaseCategory = new Case_Category__c(
            Type__c = silverCase.Type,
            Group__c = silverCase.Group__c,
            Category__c = silverCase.Category__c,
            Sub_Category__c = silverCase.Sub_Category__c,
            Classification__c = silverCase.Classification__c,
            Case__c = silverCase.Id
        );
        insert silverCaseCategory;

        // Call the method under test for Silver tier
        Map<String, Decimal> silverResult = QCC_QantasPointsSuggestedValues.getSuggestedValues(silverCase.Id, silverContact.Id);
        
        // Verify the results for Silver tier
        System.assertNotEquals(null, silverResult, 'The result map for Silver tier should not be null');
        System.assertEquals(0, silverResult.get('Suggested_Maximum__c'), 'The maximum suggested value for Silver tier should be as expected.');

        // Create and insert a non-tier Frequent Flyer Contact
        Contact nonTierContact = new Contact(FirstName='Non', LastName='Member', Frequent_Flyer_Tier__c=null);
        insert nonTierContact;

        // Create and insert a Case for the non-tier Contact
        Case nonTierCase = TestUtilityDataClassQantas.createCaseWithCodingValues(
            'CCC Complaints', 'Complaint', 'Contact Centre', 
            'Ticket Changes', 'No notification of ticket changes', 'Same Day Rebooking'
        );
        nonTierCase.Origin = 'Qantas.com';
        nonTierCase.ContactId = nonTierContact.Id;
        nonTierCase.Arrival_UTC_Date_Time__c = System.Today().addDays(1);
        nonTierCase.Departure_UTC_Date_Time__c = System.Today();
         nonTierCase.Status = 'Reopened';
        insert nonTierCase;

        // Create and insert Case_Category__c
        Case_Category__c nonTierCaseCategory = new Case_Category__c(
            Type__c = nonTierCase.Type,
            /*Group__c = nonTierCase.Group__c,
            Category__c = nonTierCase.Category__c,
            Sub_Category__c = nonTierCase.Sub_Category__c,
            Classification__c = nonTierCase.Classification__c,*/
            Case__c = nonTierCase.Id
			
        );
        insert nonTierCaseCategory;

        // Call the method under test for non-tier
        Map<String, Decimal> nonTierResult = QCC_QantasPointsSuggestedValues.getSuggestedValues(nonTierCase.Id, nonTierContact.Id);
        
        // Verify the results for non-tier
        System.assertNotEquals(null, nonTierResult, 'The result map for non-tier should not be null');
        System.assertEquals(10000.0, nonTierResult.get('Suggested_Maximum__c'), 'The maximum suggested value for non-tier should be as expected.');

        Test.stopTest();
    }
}