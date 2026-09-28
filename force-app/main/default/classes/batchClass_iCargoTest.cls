@isTest
public class batchClass_iCargoTest {
    @isTest
    static void testBatchExecution() {
        // Create test AWB record
        AWB_Info__c awb = new AWB_Info__c(Name='081-56274540', Freight_Origin__c='SYD', Freight_Destination__c='Sydney');
        insert awb;
        
        // Create test Case
        Case testCase = new Case(Status='New');
        insert testCase;
        
        // Create AWB Relationship (Junction)
        AWB_Relationship__c rel = new AWB_Relationship__c(
            Case__c = testCase.Id,
            AWB__c = awb.Id
        );
        insert rel;
        
        // Call batch
        Test.startTest();
        batchClass_iCargo batch = new batchClass_iCargo();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
}