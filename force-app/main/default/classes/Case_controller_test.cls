@isTest
public class Case_controller_test {
    
    @testSetup
    static void generateTestData() {
        final Id RTID_ACCOUNT_FREIGHT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Freight_Account').getRecordTypeId();
        final Id RTID_CONTACT_FREIGHT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        final Id RTID_CASE_QFREIGHT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();
        final Id RTID_CLAIMS = Schema.SObjectType.Case_Checklist_Info__c.getRecordTypeInfosByDeveloperName().get('Freight_Claims').getRecordTypeId();
        final Id RTID_SPLMoves = Schema.SObjectType.Case_Checklist_Info__c.getRecordTypeInfosByDeveloperName().get('Freight_Special_Moves').getRecordTypeId();
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        TestUtilityDataClassQantas.enableTriggers();
        
        Account accountRecord = new Account();
        accountRecord.RecordTypeId = RTID_ACCOUNT_FREIGHT;
        accountRecord.Name = 'Test Account 1';
        accountRecord.Type = 'Freight-Country';
        accountRecord.Active__c = true;
        insert accountRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.RecordTypeId = RTID_CONTACT_FREIGHT;
        contactRecord.FirstName = 'Test';
        contactRecord.LastName = 'User 1';
        contactRecord.AccountId = accountRecord.Id;
        contactRecord.Function__c = 'IT';
        contactRecord.Business_Types__c = 'Freight';
        contactRecord.Email = 'testuser1@qantas.com.au';
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = RTID_CASE_QFREIGHT;
        caseRecord.Status = 'Open';
        caseRecord.AccountId = accountRecord.Id;
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.Subject = 'Test Subject 01';
        caseRecord.Description = 'This is a test description for test subject 01';
        caseRecord.Type = 'Invalid Case';
        caseRecord.Freight_AWB_Number__c = '081-01231434';
        insert caseRecord;
        
        Case caseRecordClaims = new Case();
        caseRecordClaims.RecordTypeId = RTID_CASE_QFREIGHT;
        caseRecordClaims.Status = 'Open';
        caseRecordClaims.AccountId = accountRecord.Id;
        caseRecordClaims.ContactId = contactRecord.Id;
        caseRecordClaims.Subject = 'Test Subject 02';
        caseRecordClaims.Description = 'This is a test description for test subject 02';
        caseRecordClaims.Type = 'Claims';
        caseRecordClaims.Sub_Type_1__c = 'Delay';
        caseRecordClaims.Sub_Type_2__c ='Formal Claim';
        caseRecordClaims.Freight_AWB_Number__c = '081-01231435';
        caseRecordClaims.Freight_Shipment__c='International';
        insert caseRecordClaims;
        
        Case caseRecordSplMoves = new Case();
        caseRecordSplMoves.RecordTypeId = RTID_CASE_QFREIGHT;
        caseRecordSplMoves.Status = 'Open';
        caseRecordSplMoves.AccountId = accountRecord.Id;
        caseRecordSplMoves.ContactId = contactRecord.Id;
        caseRecordSplMoves.Subject = 'Test Subject 03';
        caseRecordSplMoves.Description = 'This is a test description for test subject 03';
        caseRecordSplMoves.Type = 'Special Moves';
        caseRecordSplMoves.Sub_Type_1__c = 'AVI';
        caseRecordSplMoves.Sub_Type_2__c ='Booked';
        caseRecordSplMoves.Freight_AWB_Number__c = '081-01231436';
        insert caseRecordSplMoves;
        
        Case_Checklist_Info__c checklistInfoSplMov = new Case_Checklist_Info__c();
        checklistInfoSplMov.RecordTypeId = RTID_SPLMoves;
        checklistInfoSplMov.OTT__c = true;
        checklistInfoSplMov.Case__c = caseRecordSplMoves.Id;
        insert checklistInfoSplMov;
        
        Case_Checklist_Info__c checklistInfoClaims = new Case_Checklist_Info__c();
        checklistInfoClaims.RecordTypeId = RTID_CLAIMS;
        checklistInfoClaims.Case__c = caseRecordClaims.Id;
        checklistInfoClaims.Copy_of_Airway_Bill__c = 'Requested';
        checklistInfoClaims.Reason_for_Lodgment__c = 'Provided by Customer';
        checklistInfoClaims.Copy_of_Airway_Bill__c = 'Provided by Customer';
        checklistInfoClaims.Copy_of_House_Airway_Bill__c = 'Provided by Customer'; 
        checklistInfoClaims.Intent_to_Claim_Acknowledgement_Receipt__c = 'Provided by Customer';
        checklistInfoClaims.Destruction_Certificate__c	= 'Provided by Customer';
        checklistInfoClaims.Invoice_and_or_Packing_List__c = 'Provided by Customer'; 
        checklistInfoClaims.Evidence_of_Attempts_on_Mitigate_losses__c = 'Provided by Customer';
        checklistInfoClaims.Repair_Quotation__c = 'Provided by Customer';
        checklistInfoClaims.Subrogation_Letter__c = 'Provided by Customer';
        checklistInfoClaims.Loss_Adjustor_Marine_Surveyor_s_Report__c = 'Provided by Customer';
        checklistInfoClaims.Subrogation_Letter__c = 'Provided by Customer';
        insert checklistInfoClaims;    
    }
    
    @istest 
    static void testGetProfileName() {
        Case_Controller.getProfileName();
    }
    
    @istest 
    static void testGetFFInfo() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        Case_Controller.getFFInfo(caseRecord.Id);
    }
    
    @isTest
    static void testUpdateCaseValidation() {
        Case caseRecord = [ SELECT CaseNumber, Status FROM Case LIMIT 1 ];
        caseRecord.Status = 'Closed';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation1() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation2() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        caseRecord.Type = 'Booking';
        caseRecord.Sub_Type_1__c = 'Existing';
        caseRecord.Sub_Type_2__c = 'Amendments';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation3() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        caseRecord.Type = 'Claims';
        caseRecord.Sub_Type_1__c = 'Damaged';
        caseRecord.Sub_Type_2__c = 'Intent to Claim';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation4() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        caseRecord.Type = 'Customer Query';
        caseRecord.Sub_Type_1__c = 'Damaged';
        caseRecord.Sub_Type_2__c = 'Intent to Claim';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation5() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        caseRecord.Type = 'Export Moves';
        caseRecord.Sub_Type_1__c = 'AVI';
        caseRecord.Sub_Type_2__c = 'Booked';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation6() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        caseRecord.Type = 'NCR';
        caseRecord.Sub_Type_1__c = 'Damaged';
        caseRecord.Sub_Type_2__c = 'Intent to Claim';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation7() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        caseRecord.Type = 'Disruption';
        caseRecord.Sub_Type_1__c = 'Damaged';
        caseRecord.Sub_Type_2__c = 'Intent to Claim';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation8() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c FROM Case LIMIT 1 ];
        caseRecord.Type = 'Special Moves';
        caseRecord.Sub_Type_1__c = 'AVI';
        caseRecord.Sub_Type_2__c = 'Booked';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation9() {
        Case caseRecord = [ SELECT CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c,Status FROM Case LIMIT 1 ];
        caseRecord.Type = '';
        update caseRecord;
        Case_Controller.updateCaseValidation(caseRecord.Id, 'Closed');
    }
    
    @isTest
    static void testUpdateCaseValidation10() {
        Case caseRecordClaims = [ SELECT Id, CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c,Status FROM Case where Type = 'Claims' LIMIT 1 ];
        system.debug('caseRecordClaims' +caseRecordClaims);
        Case_Checklist_Info__c checklistInfoClaims = [select Id ,Case__c,Copy_of_Airway_Bill__c,Number_and_Weight_of_Affected_Pieces__c,
                                                Reason_for_Lodgment__c,Copy_of_House_Airway_Bill__c,Intent_to_Claim_Acknowledgement_Receipt__c,
                                                Destruction_Certificate__c,Invoice_and_or_Packing_List__c,
                                                Evidence_of_Attempts_on_Mitigate_losses__c,Repair_Quotation__c,
                                                Subrogation_Letter__c,Loss_Adjustor_Marine_Surveyor_s_Report__c from Case_Checklist_Info__c 
                                                where Copy_of_Airway_Bill__c = 'Requested' limit 1];
        system.debug('checklistInfoClaims' +checklistInfoClaims);

        Test.startTest();
        system.debug('Calling main method----');
        Case_Controller.updateCaseValidation(caseRecordClaims.Id, 'Closed');
        Test.stopTest();
    }

    
    
    @isTest
    static void testUpdateCaseValidation11() {
        Case caseRecordClaims1 = [ SELECT Id, CaseNumber, Type, Sub_Type_1__c, Sub_Type_2__c,Claim_Stage__c,
                      Product__c,Freight_Resolve_Reason__c,RecordType.DeveloperName,Freight_Shipment__c FROM Case where Type = 'Claims' and Freight_Shipment__c = 'International'and 
        Sub_Type_2__c = 'Formal Claim' LIMIT 1 ];
        Case_Checklist_Info__c checklistInfoClaims1 = [select Id ,Ott__c, Case__c,Copy_of_Airway_Bill__c,Number_and_Weight_of_Affected_Pieces__c,
                                                Reason_for_Lodgment__c,Copy_of_House_Airway_Bill__c,Intent_to_Claim_Acknowledgement_Receipt__c,
                                                Destruction_Certificate__c,Invoice_and_or_Packing_List__c,
                                                Evidence_of_Attempts_on_Mitigate_losses__c,Repair_Quotation__c,
                                                Subrogation_Letter__c,Loss_Adjustor_Marine_Surveyor_s_Report__c from Case_Checklist_Info__c
                                                where Copy_of_Airway_Bill__c = 'Requested' limit 1];
        system.debug('checklistInfoClaims1' +checklistInfoClaims1);
        checklistInfoClaims1.Copy_of_Airway_Bill__c = 'Provided by Customer';
        checklistInfoClaims1.Reason_for_Lodgment__c = 'Provided by Customer';
        checklistInfoClaims1.Copy_of_Airway_Bill__c = 'Provided by Customer';
        checklistInfoClaims1.Copy_of_House_Airway_Bill__c = 'Provided by Customer'; 
        checklistInfoClaims1.Intent_to_Claim_Acknowledgement_Receipt__c = 'Provided by Customer';
        checklistInfoClaims1.Destruction_Certificate__c	 = 'Provided by Customer';
        checklistInfoClaims1.Invoice_and_or_Packing_List__c = 'Provided by Customer'; 
        checklistInfoClaims1.Evidence_of_Attempts_on_Mitigate_losses__c	 = 'Provided by Customer';
        checklistInfoClaims1.Repair_Quotation__c = 'Provided by Customer';
        checklistInfoClaims1.Subrogation_Letter__c = 'Provided by Customer';
        checklistInfoClaims1.Loss_Adjustor_Marine_Surveyor_s_Report__c = 'Provided by Customer';
        checklistInfoClaims1.Subrogation_Letter__c = 'Provided by Customer';
        update checklistInfoClaims1;
        
        caseRecordClaims1.Status = 'Closed';
        update caseRecordClaims1;
        test.startTest();
        Case_Controller.updateCaseValidation(caseRecordClaims1.Id, 'Closed');
         test.stopTest();
    }

    
}