@isTest
private class CustomSettingsUtilitiesTest {
    
    @testSetup static void createTestData() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<QCC_BookingCodeMappings__c> qBCMRecords = new List<QCC_BookingCodeMappings__c>{ 
            TestUtilityDataClassQantas.createQantasBookingData('PE', 'WAITLISTED') 
        };
        insert qBCMRecords;
        List<AirlineCarrierCodes__c> aCCRecords = new List<AirlineCarrierCodes__c>{ 
            TestUtilityDataClassQantas.createAirlineCarrierData('FQ', 'Brindabella Airlines')
        };
        insert aCCRecords;
    }
    
    @isTest static void testAllMethods() {
        CustomSettingsUtilities.getConfigDataMap('CaseStatusOpen');
        CustomSettingsUtilities.getBookingCodeMapping('PE');
        CustomSettingsUtilities.getAirlineCarrierCodes('FQ');
        CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPToken');
        CustomSettingsUtilities.getAllAmexResponseCode();
        CustomSettingsUtilities.getCongaEmailTemplateId();
    }
}