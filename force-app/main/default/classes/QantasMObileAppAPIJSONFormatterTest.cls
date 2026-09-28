/*----------------------------------------------------------------------------------------------------------------------
Author:        Gandla Mallikarjuna
Company:       TCS
Description:   Test class for QantasMObileAppAPIJSONFormatter CRM-8421
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class QantasMObileAppAPIJSONFormatterTest {
    
    @testSetup
    static void setup() {

    }

    static testMethod void testparseCasePayload(){

        Test.startTest();
            List<QantasMObileAppAPIJSONFormatter.QansMobileAppPayload> payloads = new List<QantasMObileAppAPIJSONFormatter.QansMobileAppPayload>();
            QantasMObileAppAPIJSONFormatter.QansMobileAppPayload payload = new QantasMObileAppAPIJSONFormatter.QansMobileAppPayload();

            payload.status = 'In Progress';
            payload.originalCaseNumber = '11809614';
            payload.contactId = 'Test Gold';
            payload.caseNumber = '11809616';
            payload.caseReceiveddDate = System.now();
            payload.isresponseRequired = 'No';
            payload.caseType = 'Complaint';
            payload.methodName = 'parseCasePayload';
            payloads.add(payload);

            QantasMObileAppAPIJSONFormatter.parsePayload(payloads);
        Test.stopTest();

    }
    
    
    static testMethod void testparseRecoveryPayload(){

        Test.startTest();
            List<QantasMObileAppAPIJSONFormatter.QansMobileAppPayload> payloads = new List<QantasMObileAppAPIJSONFormatter.QansMobileAppPayload>();
            QantasMObileAppAPIJSONFormatter.QansMobileAppPayload payload = new QantasMObileAppAPIJSONFormatter.QansMobileAppPayload();

            payload.originalCaseNumber = '11809614';
            payload.contactId = 'Test Gold';
            payload.isresponseRequired = 'No';
            payload.recoveryNumber = 'R01030408';
            payload.recProcessStatus = 'New';
            payload.recType = '';
            payload.recCreatedDate = System.now();
            payload.methodName = 'parseRecoveryPayload';
            payloads.add(payload);
            QantasMObileAppAPIJSONFormatter.parsePayload(payloads);
        Test.stopTest();

    }
}