@isTest
public class QLCalendarViewControllerTest {
    
    @testSetup
    static void setupTestData() {
        List<Offer_Catalogue__c> offerCatList = new List<Offer_Catalogue__c>();
        offerCatList.add(new Offer_Catalogue__c(Name = 'Test Offer Catalogue 1',OfferStatus__c ='Draft',
                                                Offer_Start_Date__c = Date.today(), Offer_End_Date__c = Date.today().addDays(5), Offer_Audience__c='Other',
                                                Offer_Type__c = 'Fare Offer',Offer_Customer_Selection__c='General Offer',
                                                Point_of_Sale_Country__c = 'Australia'));
        
        offerCatList.add(new Offer_Catalogue__c(Name = 'Test Offer Catalogue 2',OfferStatus__c ='Sales Review',
                                                Offer_Start_Date__c = Date.today(), Offer_End_Date__c = Date.today().addDays(5), Offer_Audience__c='Other',
                                                Offer_Type__c = 'Seating Offer',Offer_Customer_Selection__c='General Offer',
                                                Point_of_Sale_Country__c = 'India'));
        
        Insert offerCatList;
        
    }
    
    @isTest
    static void getCalendarRecords_noFilters(){
        List<String> fields = new List<String>{'Id',
            'Name',
            'OfferStatus__c',
            'Offer_Start_Date__c',
            'Offer_End_Date__c'};
                
        Test.startTest();
         List<Map<String, Object>> results =
            QLCalendarViewController.getCalendarRecords(
                'Offer_Catalogue__c',
                fields,
                'Offer_Start_Date__c',   // startDateField
                'Offer_End_Date__c',   // endDateField
                new Map<String,Object>(),
                Date.today(),
                Date.today().addDays(15)
            );
        Test.stopTest();	
        
 		System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Records should be returned');

        
    }
    
    @isTest
    static void getCalendarRecords_withFilters(){
         List<String> fields = new List<String>{'Id',
            'Name',
            'OfferStatus__c',
            'Offer_Start_Date__c',
            'Offer_End_Date__c'};
		
		Map<String, Object> filters = new Map<String, Object>{
            'Offer_Type__c' => 'Fare Offer'
        };
        
         Test.startTest();
         List<Map<String, Object>> results =
            QLCalendarViewController.getCalendarRecords(
                'Offer_Catalogue__c',
                fields,
                'Offer_Start_Date__c',   // startDateField
                'Offer_End_Date__c',   // endDateField
                filters,
                Date.today(),
                Date.today().addDays(15)
            );
        Test.stopTest();
        
        System.assert(results.size() == 1, 'Only one Record should be returned');

        
    }
    
}