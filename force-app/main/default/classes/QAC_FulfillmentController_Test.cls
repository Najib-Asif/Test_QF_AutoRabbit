/* 
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Main Class : QAC_FulfillmentController
*/
@isTest
private class QAC_FulfillmentController_Test {

    @isTest
    static void QACFulfillmentRecordTest()
    {
        system.debug('inside ff rec test**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();

        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557');
        insert myAccount;
        
        Case parentCase = new Case(External_System_Reference_Id__c = 'C-002002002002',Origin = 'QAC Website',RecordTypeId = caseRTId,
                                Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Credit',Status = 'Open',
                                Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                AccountId = myAccount.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                PNR_number__c = '454545',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Travel_Type__c = 'International'); 
        insert parentCase;
        
        Case_Fulfilment__c cf1 = new Case_Fulfilment__c();
        cf1.Category__c = 'Remark';
        cf1.Message__c = 'Created successfully';
        cf1.Case__c = parentCase.Id;
        cf1.Status__c = 'Started';
        insert cf1;
        
        Case_Fulfilment__c cf2 = new Case_Fulfilment__c();
        cf2.Category__c = 'EMD Creation';
        cf2.Message__c = 'Created successfully';
        cf2.Case__c = parentCase.Id;
        cf2.Status__c = 'Pending';
        insert cf2;

        Test.startTest();
            QAC_FulfillmentController.getAllFFRecords(parentCase.Id);
        
            // to test update
            cf2.Status__c = 'Success';
            QAC_FulfillmentController.updateFulfillment(cf2);
        Test.stopTest();
    }
}