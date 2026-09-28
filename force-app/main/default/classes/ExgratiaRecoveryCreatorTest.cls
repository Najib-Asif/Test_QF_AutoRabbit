/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 11-28-2023
 * @last modified by  : Praveen Sampath
**/
@IsTest
private class ExgratiaRecoveryCreatorTest {
    public static final Id RECOVERY_RECORDTYPE_ID = Schema.SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('Exgratia_Flight_Pass').getRecordTypeId();
    public static final Id ACCOUNT_PERSONACCOUNT_RECORDTYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account').getRecordTypeId();
    public static final Id CONTACT_INDIVIDUAL_RECORDTYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('QCC_Individual_Contact').getRecordTypeId();
    public static final Id CASE_VOICE_RECORDTYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_Voice').getRecordTypeId();

    @TestSetup
    static void makeData(){ 

        List<Trigger_Status__c> onScreenCase = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> statToUpdate = new List<Trigger_Status__c>();
        for(Trigger_Status__c triggerStat : onScreenCase){
            triggerStat.Active__c = false;
            statToUpdate.add(triggerStat);
        }
        update statToUpdate;

        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createRecoveryTriggerSetting();
        insert lsttrgStatus;

        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;

        Trigger_Status__c ts1 = new Trigger_Status__c();
        ts1.Name = 'QCC_SetNonFFContactOnCase';
        ts1.Active__c = false;
        insert ts1;

        
        //create account
        Account acc = new Account();
        acc.recordTypeId = ACCOUNT_PERSONACCOUNT_RECORDTYPE_ID;
        acc.Name = 'test platinum account';
        insert acc;

        Contact con = new Contact();
        con.recordTypeId = CONTACT_INDIVIDUAL_RECORDTYPE_ID;
        con.FirstName = 'Sample';
        con.LastName = 'Citizen';
        con.AccountId = acc.Id;
        con.Email = 'test@test.com';
        insert con;

        List<Case> caseRecordList = new List<Case>();

        //Create custom setting for case trigger
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;

        Case caseRecord = QCC_TestDataFactory.createCaseTestData(acc.Id, con.Id);
        caseRecord.RecordTypeId = CASE_VOICE_RECORDTYPE_ID;
        caseRecord.Subject = 'Test CCC Voice';
        caseRecord.Description = 'Test CCC Voice';
        caseRecord.Status = 'New';
        caseRecord.Booking_PNR__c = 'TEST12';
        caseRecordList.add(caseRecord);

       
        insert caseRecordList;

    }
    /**
     * desc: Test createRecoverRecord() method.
     */

     @IsTest
     static void testCreateRecovery() {
        List<case> caselist = [Select ID from case LIMIT 1];

        ExgratiaFlightPassSearchWrapper recRecord = new ExgratiaFlightPassSearchWrapper();
        recRecord.Pax_first_name = 'first name';
        recRecord.Pax_last_name = 'last name';
        ExgratiaRecoveryCreator.createRecovery(recRecord, caselist[0].Id);

        List<Recovery__c> rec = [Select ID, Pax_first_name__c, pax_last_name__c from Recovery__c];
        system.assertNotEquals(null, rec, 'Looks like recoveries are not created');

     }


     /**
     * desc: Test createRecoverRecord() method.
     */
     @IsTest
     static void testCreateIsDuplicateRecovery() {
        List<case> caselist = [Select ID from case LIMIT 1];

        ExgratiaFlightPassSearchWrapper recRecord = new ExgratiaFlightPassSearchWrapper();
        recRecord.Pax_first_name = 'first name';
        recRecord.Pax_last_name = 'last name';
        recRecord.Correlation_ID = '11111';
        
        //creating a recovery record
        Recovery__c rec = new Recovery__c();
        rec.RecordtypeId = RECOVERY_RECORDTYPE_ID;
        rec.Pax_first_name__c = 'first name';
        rec.pax_last_name__c = 'last name';
        rec.Case_Number__c = caselist[0].Id;
        rec.CorrelationID__c = '11111';
        insert rec;

        Test.startTest();

        Boolean isDuplicate = ExgratiaRecoveryCreator.isDuplicateRecovery(recRecord, caselist[0].Id);

        Test.stopTest();

        System.assert(isDuplicate, 'looks like duplicate check is not properly performed');
     }
     
     @IsTest
     static void testCreateRecoveryEndToEnd() {
        List<case> caselist = [Select ID from case LIMIT 1];

        ExgratiaFlightPassSearchWrapper recRecord = new ExgratiaFlightPassSearchWrapper();
        recRecord.Pax_first_name = 'first name';
        recRecord.Pax_last_name = 'last name';

        Test.startTest();

        ExgratiaRecoveryCreator.createRecoveryRecord(JSON.serialize(recRecord), caselist[0].Id);

        Test.stopTest();

        List<Recovery__c> rec = [Select ID, Pax_first_name__c, pax_last_name__c from Recovery__c];
        system.assertNotEquals(null, rec, 'Looks like recoveries are not created');
        

     }
}