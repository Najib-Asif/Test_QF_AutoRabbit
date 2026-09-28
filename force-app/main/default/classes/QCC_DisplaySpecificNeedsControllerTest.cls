/*----------------------------------------------------------------------------------------------------------------------
Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_DisplaySpecificNeedsControllerTest {
    
    @testSetup
    static void testSetup(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        
        List<User> testUsers = new List<User>();
        User spnUser = new User(LastName = 'Specific Needs User', Alias = 'User', Email = 'sampleuser1@sample.com', 
                                Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Customer Specific Needs').Id,
                                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                                TimeZoneSidKey = 'Australia/Sydney'
                               );
        testUsers.add(spnUser); 
        
        System.runAs(spnUser)
        {
            Id spnQueue = [SELECT SobjectType, Id, QueueId, Queue.DeveloperName FROM QueueSobject 
                           WHERE SobjectType ='Case' 
                           AND Queue.DeveloperName = 'QCC_Specific_Needs_Bounce_Back_Queue'].Id;
            
            //Create test data for Flight Event object
            List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
            insert customSettingList1;
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('QCC_Specific_Needs').getRecordTypeId();
            
            //Account Record
            Account accRecord = QCC_TestDataFactory.createAccountTestData(88);
            insert accRecord;
            
            //Contact Record
            Contact conRecord = QCC_TestDataFactory.createContactTestData(88, accRecord.Id);
            insert conRecord;
            
            //Case Record 2
            Case caseRec2 = QCC_TestDataFactory.createCaseTestData(accRecord.Id, conRecord.Id);
            caseRec2.RecordTypeId = caseRecordTypeId;
            insert caseRec2;
            
            //Account Record
            Account accRecord2 = QCC_TestDataFactory.createAccountTestData(89);
            insert accRecord2;
            
            //Contact Record
            Contact conRecord2 = QCC_TestDataFactory.createContactTestData(89, accRecord2.Id);
            insert conRecord2;
            
            //Case Record 1
            Case caseRec = QCC_TestDataFactory.createCaseTestData(accRecord2.Id, conRecord2.Id);
            //caseRec.RecordTypeId = caseRecordTypeId;
            caseRec.Status = 'Waiting for Internal';
            
            QCC_Specific_Needs__c spnRecord2 = QCC_TestDataFactory.createSpecificNeedsRecord(caseRec2.Id);
            spnRecord2.QCC_Request_Type__c = 'Mobility Aid';
            spnRecord2.QCC_Request_Type_SD__c = 'Service Dog';
            spnRecord2.QCC_Request_Type_MC__c = 'Medical Clearance';
            spnRecord2.QCC_Request_Type_CBBG__c = 'Baggage';
            spnRecord2.QCC_Compliance_Outcome_Received_SD__c = true;
            spnRecord2.QCC_Notify_Cabin_Crew_CJMs_SD__c = true;
            spnRecord2.QCC_Outcome_Confirmation_Sent_to_Cst_SD__c = true;
            spnRecord2.QCC_Compliance_Approval_Request_Sent_SD__c = true;
            spnRecord2.QCC_Confirmation_Sent_to_Customer_MC__c = true;
            spnRecord2.QCC_Notify_Departure_Airport_3_Days_PAP__c = true;
            spnRecord2.QCC_Update_PNR_MCST__c = true;
            spnRecord2.QCC_Update_Intelex__c = true;
            spnRecord2.QCC_Booking_Created__c = true;
            spnRecord2.QCC_Payment_Received__c = true;
            spnRecord2.QCC_MEDA_Clearance_Confirmed__c = true;
            spnRecord2.QCC_Final_Confirmation_Sent_to_Requester__c = true;
            spnRecord2.QCC_Quote_Provided_to_Requester_MCST__c = true;
            spnRecord2.QCC_Notify_Departure_Airport_3_Days_ST__c = true;
            spnRecord2.QCC_PNR_Updated_SD__c = true;
            spnRecord2.QCC_PNR_Updated_MCOQS__c = true;
            spnRecord2.QCC_PNR_Updated_MCOD__c = true;
            spnRecord2.QCC_PNR_Updated_MCIT__c = true;
            spnRecord2.QCC_Update_PNR_MC__c = true;
            spnRecord2.QCC_Update_PNR_MCST__c = true;
            spnRecord2.QCC_Update_PNR_CBBG__c = true;
            spnRecord2.QCC_Update_PNR_MBW__c = true;
            spnRecord2.Update_PNR_WC__c = true;
            spnRecord2.QCC_MEDA_Completed_Approved__c = true;
            spnRecord2.QCC_Quote_Provided_to_Customer_MCOD__c = true;
            spnRecord2.Confirm_Outcome_to_Customer__c = true;
            spnRecord2.QCC_Customer_has_accepted_Quote_MCOD__c = true;
            spnRecord2.QCC_Confirmation_sent_to_Customer_MCOD__c = true;
            spnRecord2.QCC_Notify_Eng_Airport_Crew_2_days_OD__c = true;
            spnRecord2.QCC_MEDA_Completed_Approved_MCQS__c = true;
            spnRecord2.QCC_Quote_Provided_to_Customer_MCOQS__c = true;
            spnRecord2.QCC_Customer_has_accepted_Quote_MCOQS__c = true;
            spnRecord2.QCC_Confirmation_sent_to_Customer_MCOQS__c = true;
            spnRecord2.QCC_Notify_Eng_Airport_Crew_2_days_QS__c = true;
            spnRecord2.QCC_Oxygen_Ordered__c = true;
            spnRecord2.QCC_MEDA_Completed_Approved_MCIT__c = true;
            spnRecord2.QCC_Confirmation_sent_to_Customer_MCIT__c = true;
            spnRecord2.QCC_Notify_Eng_Airport_Crew_2_days_IT__c = true;
            spnRecord2.QCC_Seating_Allocated_for_Customer_CBBG__c = true;
            spnRecord2.QCC_Notify_Airport_and_Crew_1_Day__c = true;
            spnRecord2.QCC_Confirmation_Sent_to_Requestor_MBW__c = true;
            spnRecord2.QCC_Case__c = caseRec2.Id;
            insert spnRecord2;
            
            caseRec2.QCC_Specific_Needs__c = spnRecord2.Id;
            update caseRec2;
        }
    }
    
    static testMethod void testretrieveCheckboxValues(){
        Case caseRecord2 = [SELECT Id, RecordType.Name, Status, QCC_Specific_Needs__c FROM Case WHERE RecordType.DeveloperName = 'QCC_Specific_Needs' LIMIT 1];
        QCC_Specific_Needs__c spnRecord2 = [SELECT Id, QCC_Case__c, QCC_Request_Type_SD__c FROM QCC_Specific_Needs__c WHERE QCC_Case__c =: caseRecord2.Id ];
        String str = JSON.serialize(spnRecord2);
        
        test.startTest();
        QCC_DisplaySpecificNeedsController.retrieveCheckboxValues(caseRecord2.Id);
        QCC_DisplaySpecificNeedsController.updateSpecificNeedRecord(caseRecord2.Id, str, true );
        QCC_DisplaySpecificNeedsController.getMetadataFields();
        test.stopTest();
    }
}