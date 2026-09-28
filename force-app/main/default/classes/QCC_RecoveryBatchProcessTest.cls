@isTest
private class QCC_RecoveryBatchProcessTest {
    @testSetup
    static void createTestData(){ 
        Test.startTest();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubmitForFinalisation','Submit for Finalisation'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalised','Finalised'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalisation Declined','Finalisation Declined'));
        insert lstConfigData;
        
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        //Create Account
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');

        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        objContact.CAP_ID__c='710000000017';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');

        //Create Case
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        String recordType = 'CCC Complaints';
        String type = 'Complaint';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Flight Disruptions','Downgrade','QF Booking Throughfare','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');

        //Create Recovery
        List<Recovery__c> recoveriesList = new List<Recovery__c>();
        for(Integer i = 0; i < lstCase.size(); i++) {
            Recovery__c rec = new Recovery__c();
            rec.Case_Number__c = lstCase[i].Id;
            rec.Contact__c = lstCase[i].ContactId;
           // rec.Status__c = 'Processing';
            rec.Process_Status__c = 'Submitted for Finalisation';
            rec.Investigated_By__c = UserInfo.getUserId();
            recoveriesList.add(rec);
        }
        insert recoveriesList;
        system.assert(recoveriesList.size()>0, 'Recovery List is Zero');
        system.assert(recoveriesList[0].Id != Null, 'Recovery is not inserted');
        Test.stopTest();
    }
    
    // Test without FF#
    static testMethod void test1() {
        String status = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined');
        Recovery__c rec = [select Id, Type__c, Status__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        rec.Type__c = CustomSettingsUtilities.getConfigDataMap('Qantas Points Type');
        rec.Status__c = status;
        update rec;
        
        String Body = '{ "success": false, "message": "Invalid request", "details": { "reason": "Duplicate Request - entry already exists", "reasoncode": 8025 }}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(400, 'Bad Request', Body, mapHeader));
        
        Test.startTest();
        Database.executeBatch(new QCC_RecoveryBatchProcess());
        Test.stopTest();
        Recovery__c updatedRec = [select Id, Type__c, Status__c, API_Attempts__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        //System.assertEquals(1, updatedRec.API_Attempts__c);
        //System.assertEquals(status, updatedRec.Status__c);
    }
    
    // Test with FF#
    static testMethod void test2() {
        Contact con = [SELECT Id, Frequent_Flyer_Number__c FROM Contact LIMIT 1];
        con.Frequent_Flyer_Number__c = '0006142207';
        update con;
        Recovery__c rec = [select Id, Type__c, Status__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        rec.Type__c = CustomSettingsUtilities.getConfigDataMap('Qantas Points Type');
        rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined');
        update rec;
        
        String Body = '{ "success": true, "message": "Point Accrual information successfully updated", "member": {'+
                      '"memberid": 1900007871, "pointsbalance": 2 }, "othermemberdetails": { "emailid": "kevinliu@qantas.com.au"'+
                      '}, "reference": { "identifier": 787987122 }, "outcome": { "status": "SUCCESS", "reason": 0, "reasoncode": 0'+
                      '}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        
        Test.startTest();
        Database.executeBatch(new QCC_RecoveryBatchProcess());
        Test.stopTest();
        Recovery__c updatedRec = [select Id, Type__c, Status__c, API_Attempts__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        System.assertEquals(0, updatedRec.API_Attempts__c);
        //System.assertEquals(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised'), updatedRec.Status__c);
    }
    
    // Test without FF# more than 2 attempts
    static testMethod void test3() {
        Recovery__c rec = [select Id, Type__c, Status__c, API_Attempts__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        rec.Type__c = CustomSettingsUtilities.getConfigDataMap('Qantas Points Type');
        rec.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusDeclined');
        rec.API_Attempts__c = 2;
        update rec;
        
        String Body = '{ "success": false, "message": "Invalid request", "details": { "reason": "Duplicate Request - entry already exists", "reasoncode": 8025 }}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(400, 'Bad Request', Body, mapHeader));
        
        Test.startTest();
        Database.executeBatch(new QCC_RecoveryBatchProcess());
        Test.stopTest();
        Recovery__c updatedRec = [select Id, Type__c, Status__c, API_Attempts__c, Case_Number__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
       // System.assertEquals(3, updatedRec.API_Attempts__c);
        //System.assertEquals(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalisation Declined'), updatedRec.Status__c);
        Case cs = [SELECT Id, Status FROM Case WHERE Id = :updatedRec.Case_Number__c];
        //System.assertEquals(CustomSettingsUtilities.getConfigDataMap('RecoveryError'),cs.Status);
    }
}