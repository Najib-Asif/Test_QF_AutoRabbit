/**
 * Created By  : Vinothkumar Balasubramanian
 * Main class Name: QC_GDSStatusBatch
 * 
 * Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
 * Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
 */

@isTest
private class QC_GDSStatusBatch_Test {
    
    @testsetup
    public static void setup() {        
        String accAgencyRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();        

        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = accAgencyRTId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020202');
        insert myAccount;
        Test.stopTest();        
    }
    
    static testMethod void testBatchGDSStatusupdate() {        
        
        Account myAccount = [Select Id from Account where Name = 'Sample'];
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        QC_TMC_GDS_Status__mdt tmcGDSStatus = [Select Days_from_Validating_GDS_Status__c from QC_TMC_GDS_Status__mdt where Days_from_Validating_GDS_Status__c != NULL AND DeveloperName = 'QC_GDS_Status'];
        Decimal gdsStatusdays =  tmcGDSStatus.Days_from_Validating_GDS_Status__c;
        Integer gdsValidatingdays = gdsStatusdays.intValue();        
        
        list<Agency_Info__c> toInsertTMC = new list<Agency_Info__c>();
        Agency_Info__c eachTMC = new Agency_Info__c();
        eachTMC.Account__c = myAccount.Id;
        eachTMC.RecordTypeId = tmcRTId;
        eachTMC.PCC__c = 'ABC123';
        eachTMC.Code__c = 'Amadeus';
        eachTMC.Active__c = true;
        eachTMC.GDS_Status__c = 'Validating';
        eachTMC.GDS_Status_Change_Date__c = system.today().addDays(-gdsValidatingdays);
        toInsertTMC.add(eachTMC);
        Test.startTest();
        insert toInsertTMC;        
        QC_GDSStatusBatch batchObj = new QC_GDSStatusBatch();
        Database.executeBatch(batchObj);
        Test.stopTest();
    }

}