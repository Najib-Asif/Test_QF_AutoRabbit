@isTest(SeeAllData = true)
public class QL_PostChattertoDealsupportTest 
{
    /*@IsTest
    static void PostChattertoDealsupport()
    {
        
        Account acc = new Account(Name = 'Sample Account', Active__c = true, Aquire__c = true, Type = 'Prospect Account', 
                                  Migrated__c = false, 
                                  Estimated_Total_Air_Travel_Spend__c = 0, Manual_Revenue_Update__c = false,
                                  Agency__c = 'N', Dealing_Flag__c = 'N', Aquire_Override__c = 'N' ,ABN_Tax_Reference__c = '12345678901'
                                 );
        insert acc;   
        
        Account_Relation__c AccRel = new Account_Relation__c(Related_Account__c = acc.Id, Relationship__c = 'Travel Manager Of');
        insert AccRel;
                
        Case Testcase = new Case(AccountId = acc.Id, Type = 'Deal Amendment', Status= 'Assigned to Pricing for Fare Filing',
                                 Due_Date__c = date.Today(), PCC_DI__c = 'PCC', GDS_DI__c = 'Amadeus', Domestic_Spend__c = 12,
                                 International_Spend__c = 12, Total_Spend__c = 24, RecordTypeId='01290000001IINIAA4',
                                Sub_Type__c = 'Change of TMC', New_TMC_Name__c = AccRel.Id, Date_Effective_DAT__c = Date.today(),
                                IATA_DAT__c = '4532675', PCC_Codes_DAT__c = 'HGF', GDS_DAT__c = 'Amadeus', Extension_to_Date__c = Date.today(),
                                Eligible_for_SME_Campaigns__c = 'Yes', Handover_to_QBR__c = 'Yes', Assign_to_QBR_Level__c = 'Yes',
                                Reasons_for_Termination__c = 'Reason for termination', End_Date__c = Date.today());
        insert Testcase;
        
        Test.startTest();
        List<Case> caselist = new List<Case>();
        caselist.add(Testcase);
        QL_PostChattertoDealsupport.ChatterPosttoDealsupportCase(caselist);
        Testcase.Type = 'Deal Termination';
        update Testcase;
        caselist.add(Testcase);
        QL_PostChattertoDealsupport.ChatterPosttoDealsupportCase(caselist);
        Test.stopTest();
    }*/
}