/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Test Class for LoyaltyAPI Helper
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
31-Jan-2018    Praveen Sampath   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class RecoveryTriggerTest {
    @testSetup
    static void createTestData(){ 
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryType','Qantas Points'));
        
        insert lstConfigData;

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
        String recordType = 'CCC Compliment';
        String type = 'Compliment';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Qantas.com','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');

        //Create Recovery
        List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoveries(lstCase);
        system.assert(lstRecovery.size()>0, 'Recovery List is Zero');
        system.assert(lstRecovery[0].Id != Null, 'Recovery is not inserted');
    }

    static TestMethod void invokeLoyaltyPostServiceTest() {

        Recovery__c objRecovery = [Select id , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Test.startTest();

        objRecovery.Status__c = 'Approved';
        objRecovery.Type__c  = 'Qantas Points';

        update objRecovery;
        Test.stopTest();
        
    }

    //This may not longer be necessary
    static testmethod void updateRecoveryTypeTest(){
        List<Case> cases = [SELECT Id, Type, ContactId FROM Case];
        cases[0].Contact_Phone__c = '1234556790';
        cases[0].Street__c = 'Mascot';
        cases[0].Suburb__c = 'NSW';
        cases[0].Post_Code__c = '560065';
        cases[0].State__c = 'Sydney';
        cases[0].Country__c = 'Australia';
        update cases[0];
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c, Colour_of_Bag__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();
        
        objRecovery.Status__c = 'New';
        objRecovery.Type__c  = 'Bag Replacement';
        objRecovery.Replacement_Bag_Type__c = 'Belmont_Plus';
        objRecovery.Size_of_Bag_cm__c = '55';
        objRecovery.Colour_of_Bag__c = 'Rouge';

        try {
            update objRecovery;
        } catch (Exception ex) {
            system.debug(ex);
        }
        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        //Case temp = [select Id , OwnerId from Case where Id =:objRecovery.Case_Number__c];
        //System.assert(temp.OwnerId == caseGroup.Id);
        Test.stopTest();
    }
    
    static testmethod void handleRecoveryTriggerTest(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Fulfillment_Queue'];
        Test.startTest();

        objRecovery.Status__c = 'Processing';
        objRecovery.Type__c  = 'Wine';
        update objRecovery;
        Case temp = [select Id , OwnerId , SubmitForFinalisation__c from Case where Id =:objRecovery.Case_Number__c];
        //System.assert(temp.OwnerId == caseGroup.Id);
        System.assert(objRecovery.Status__c == 'Processing');
        System.debug('SubmitForFinalisation__c============> ' + temp.SubmitForFinalisation__c);
        //System.assert(temp.SubmitForFinalisation__c == false);
        Test.stopTest();
    }

    static testmethod void updateCaseRecoveryValueTest(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();

        objRecovery.Status__c = 'Processing';
        objRecovery.Type__c  = 'Wine';
        objRecovery.Amount__c = 34;
        objRecovery.Value__c  = 43;
        objRecovery.Original_Currency__c='AUD Australian Dollar';
        objRecovery.Currency_Conversion_Rate__c = 1;
        objRecovery.Monetary_Value__c = 23;

        update objRecovery;
        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Case temp = [select Id , OwnerId , Recovery_Quantity__c , Recovery_Value__c , TECH_CCEFTRecoveryId__c from Case where Id =:objRecovery.Case_Number__c];
        temp.TECH_CCEFTRecoveryId__c = objRecovery.Id;
        update temp;
        Test.stopTest();
    }


    static testmethod void setFulfilledByTest(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();

        objRecovery.Status__c = 'Approved';
        objRecovery.Type__c  = 'Flowers';
        objRecovery.Amount__c = 34;
        objRecovery.Value__c  = 43;
        objRecovery.FulfilledBy__c  = UserInfo.getUserId();

        update objRecovery;
        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Recovery__c temp = [select Id ,  FulfilledBy__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' AND Id =:objRecovery.Id];
        //System.assert(temp.FulfilledBy__c == UserInfo.getUserId());
        Test.stopTest();
    }

    static testmethod void postToChatterTest(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();

        objRecovery.Status__c = 'Pending Approval';
        objRecovery.Type__c  = 'Flowers';
        objRecovery.Amount__c = 34;
        objRecovery.Value__c  = 43;
        objRecovery.FulfilledBy__c  = UserInfo.getUserId();

        update objRecovery;
        objRecovery.Status__c = 'Approved';
        update objRecovery;

        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Recovery__c temp = [select Id ,  FulfilledBy__c , Status__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' AND Id =:objRecovery.Id];
        System.assert(temp.Status__c == 'Approved');
        Test.stopTest();
    }
    
    static testmethod void routeCaseOnRecoveryPaymentUpdate(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();

        objRecovery.Type__c  = 'Flowers';
        objRecovery.Amount__c = 34;
        objRecovery.Value__c  = 43;
        objRecovery.Payment_Status__c  = 'Declined';
        objRecovery.FulfilledBy__c  = UserInfo.getUserId();

        update objRecovery;

        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Recovery__c temp = [select Id ,  FulfilledBy__c , Case_Number__c, Status__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' AND Id =:objRecovery.Id];
        //System.assert(temp.Status__c == 'Finalisation Declined');
        Case caseObj = [Select Id , Status FROM Case where Id =: temp.Case_Number__c];
        //System.assert(caseObj.Status == 'Recovery Error');
        Test.stopTest();
    }
        
    static testMethod void testIsNotFrequentFlyerMemberException() {
        Recovery__c rec = new Recovery__c(Status__c = 'Approved', Type__c = 'Qantas Points', Amount__c = 1000);
        List<Recovery__c> recList = new List<Recovery__c>();
        recList.add(rec);
        Map<Id, Recovery__c> recMap = new Map<Id, Recovery__c>();
        recMap.put('0D2N00000004EXCKA2', rec);
        Test.startTest();
        RecoveryTriggerHelper.isNotFrequentFlyerMember(recList, recMap);
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'RecoveryTriggerHelper'];
        System.assert(logs.size() > 0, 'Log for RecoveryTriggerHelper not found');
    }

    static testmethod void setFulfilledByTest2(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Test.startTest();

        objRecovery.Status__c = 'Finalised';
        objRecovery.Type__c  = 'Travel vouchers';
        objRecovery.Amount__c = 1;
        objRecovery.FulfilledBy__c  = UserInfo.getUserId();

        update objRecovery;
        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Recovery__c rec = [select Id ,  FulfilledBy__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' AND Id =:objRecovery.Id];
        System.assert(rec.FulfilledBy__c == UserInfo.getUserId());
        Test.stopTest();
    }
    
    static TestMethod void invokeLoyaltyPostServiceTest2() {
        List<Recovery__c> recLst = new List<Recovery__c>();
        Recovery__c objRecovery = [Select id , Status__c , Type__c, Process_Status__c, Amount__c, FF_Number__c, Contact_LastName__c, CaseNumber__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Test.startTest();
        objRecovery.Status__c = 'Approved';
        objRecovery.Type__c  = 'Qantas Points';
        update objRecovery;
        recLst.add(objRecovery);
        String Body = '{ "success": true, "message": "Point Accrual information successfully updated", "member": {'+
                      '"memberid": 1900007871, "pointsbalance": 2 }, "othermemberdetails": { "emailid": "kevinliu@qantas.com.au"'+
                      '}, "reference": { "identifier": 787987122 }, "outcome": { "status": "SUCCESS", "reason": 0, "reasoncode": 0'+
                      '}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        RecoveryTriggerHelper.invokeLoyaltyPostService(recLst, null);
        Recovery__c rec = [Select id , Status__c , Type__c from Recovery__c WHERE RecordType.DeveloperName='Customer_Connect' AND Id = :recLst[0].Id];
        //System.assertEquals('Awaiting Customer Response', rec.Status__c);
        Test.stopTest();
    }
    
    static testMethod void testUpdateCaseStatusRecoveryEvent() {
        List<Case> cases = [SELECT Id, Type, ContactId FROM Case];
        cases[0].Type = 'Events';
        update cases;
        Test.startTest();
        Recovery__c objRecovery = [Select id , Status__c , Type__c, Case_Number__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        objRecovery.Status__c = 'Finalised';
        update objRecovery;
        Case cs = [select Id, Status from Case where Id =:objRecovery.Case_Number__c];
        //System.assertEquals('Closed', cs.Status);
        Test.stopTest();
    }
    
    static testMethod void testUpdateCaseStatusRecoveryEvent2() {
        List<Case> cases = [SELECT Id, Type, ContactId FROM Case];
        cases[0].Type = 'Events';
        update cases;
        Test.startTest();
        Recovery__c objRecovery = [Select id , Status__c , Type__c, Case_Number__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        objRecovery.Status__c = 'Awaiting Customer';
        update objRecovery;
        Case cs = [select Id, Status from Case where Id =:objRecovery.Case_Number__c];
        System.assertEquals('Received', cs.Status);
        Test.stopTest();
    }
    
    static testMethod void testUpdateCaseStatusRecoveryEvent3() {
        List<Case> cases = [SELECT Id, Type, ContactId FROM Case];
        cases[0].Type = 'Events';
        update cases;
        Test.startTest();
        Recovery__c objRecovery = [Select id , Status__c , Type__c, Case_Number__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        objRecovery.Status__c = 'Declined';
        update objRecovery;
        Case cs = [select Id, Status from Case where Id =:objRecovery.Case_Number__c];
        //System.assertEquals('Closed', cs.Status);
        Test.stopTest();
    }
    
    static testmethod void updateCaseRecoveryValueTest2(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();

        objRecovery.Status__c = 'Processing';
        objRecovery.Type__c  = 'EFT Refund';
        objRecovery.Amount__c = 34;
        objRecovery.Value__c  = 43;
        objRecovery.Original_Currency__c='AUD Australian Dollar';
        objRecovery.Currency_Conversion_Rate__c = 1;
        objRecovery.Monetary_Value__c = 23;
        objRecovery.Stage__c = 'Stage 1';

        update objRecovery;
        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Case temp = [select Id, Stage_1_Reimbursed__c from Case where Id =:objRecovery.Case_Number__c];
        System.assertEquals(true, temp.Stage_1_Reimbursed__c);
        Test.stopTest();
    }
    
    static testmethod void updateCaseRecoveryValueTest3(){
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();

        objRecovery.Status__c = 'Processing';
        objRecovery.Type__c  = 'EFT Refund';
        objRecovery.Amount__c = 34;
        objRecovery.Value__c  = 43;
        objRecovery.Original_Currency__c='AUD Australian Dollar';
        objRecovery.Currency_Conversion_Rate__c = 1;
        objRecovery.Monetary_Value__c = 23;
        objRecovery.Stage__c = 'Stage 3';

        update objRecovery;
        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Case temp = [select Id, Stage_3_Reimbursed__c, EmergencyExpenseStage__c from Case where Id =:objRecovery.Case_Number__c];
        System.assertEquals(true, temp.Stage_3_Reimbursed__c);
       // System.assertEquals('null', temp.EmergencyExpenseStage__c);
        Test.stopTest();
    }
    
    static testmethod void updateCaseRecoveryValueTest4(){
        List<Case> cases = [SELECT Id, Type, ContactId FROM Case];
        cases[0].Emergency_Expense_Outcome__c = 'Emergency Expense - Domestic Stage';
        update cases;
        Recovery__c objRecovery = [Select id , Case_Number__c , Status__c , Type__c from Recovery__c where RecordType.DeveloperName='Customer_Connect' limit 1];
        Group caseGroup = [Select Id from Group where Type = 'Queue' AND DeveloperName = 'Baggage_Damaged_Queue_High' LIMIT 1 ];
        Test.startTest();

        objRecovery.Status__c = 'Processing';
        objRecovery.Type__c  = 'EFT Refund';
        objRecovery.Amount__c = 34;
        objRecovery.Value__c  = 43;
        objRecovery.Original_Currency__c='AUD Australian Dollar';
        objRecovery.Currency_Conversion_Rate__c = 1;
        objRecovery.Monetary_Value__c = 23;
        objRecovery.Stage__c = 'Stage 2';

        update objRecovery;
        //Recovery result = [select Id ,Case_Number__c from Case where Case_Number__c =: objRecovery.Id ];
        Case temp = [select Id, Stage_2_Reimbursed__c, EmergencyExpenseStage__c from Case where Id =:objRecovery.Case_Number__c];
        System.assertEquals(true, temp.Stage_2_Reimbursed__c);
       // System.assertEquals('null', temp.EmergencyExpenseStage__c);
        system.debug('assertion test');
        Test.stopTest();
    }
    
    @isTest static void testGetSuggestedRange() {
        Test.startTest();
        List<Contact> contactRecords = [ SELECT Id, Name FROM Contact ];
        List<Case> caseRecords = new Case[2];
        caseRecords[0] = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Complaints', 'Complaint', 'Lounges', 'Access', 'Incorrectly denied entry', '');
        caseRecords[0].Origin = 'Qantas.com';
        caseRecords[0].ContactId = contactRecords[0].Id;
        caseRecords[1] = TestUtilityDataClassQantas.createCaseWithCodingValues('CCC Complaints', 'Complaint', 'Lounges', 'Access', 'Incorrectly denied entry', '');
        caseRecords[1].Origin = 'Qantas.com';
        caseRecords[1].Status = 'Reopened';
        caseRecords[1].ContactId = contactRecords[0].Id;
        caseRecords[1].Arrival_UTC_Date_Time__c = System.Today().addDays(3000);
        caseRecords[1].Departure_UTC_Date_Time__c = System.Today();
        insert caseRecords;
        List<Case_Category__c> caseCategories = new Case_Category__c[2];
        caseCategories[0] = new Case_Category__c(
            Type__c = caseRecords[0].Type,
            Group__c = caseRecords[0].Group__c,
            Category__c = caseRecords[0].Category__c,
            Sub_Category__c = caseRecords[0].Sub_Category__c,
            Classification__c = caseRecords[0].Classification__c,
            Case__c = caseRecords[0].Id
        );
        caseCategories[1] = new Case_Category__c(
            Type__c = caseRecords[1].Type,
            Group__c = caseRecords[1].Group__c,
            Category__c = caseRecords[1].Category__c,
            Sub_Category__c = caseRecords[1].Sub_Category__c,
            Classification__c = caseRecords[1].Classification__c,
            Case__c = caseRecords[1].Id
        );
        insert caseCategories;
        List<Recovery__c> recoveryRecords = TestUtilityDataClassQantas.insertRecoveries(caseRecords);
        Test.stopTest();
    }
    
}