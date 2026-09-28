@isTest
public class CaseAndEmailMessageTriggerV1Test {

    private static final Id RTID_CASE_QFREIGHT = Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get('Qantas_Freight').getRecordTypeId();

    @testSetup
    static void createData() {
        
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c CaseTriggerV1 = new Trigger_Status__c();
        CaseTriggerV1.Name = 'CaseTriggerV1';
        CaseTriggerV1.Active__c = true;
        lsttrgStatus.add(CaseTriggerV1);

        
        Trigger_Status__c CaseTriggerupdateContactBlankEmail = new Trigger_Status__c();
        CaseTriggerupdateContactBlankEmail.Name = 'CaseTriggerupdateContactBlankEmail';
        CaseTriggerupdateContactBlankEmail.Active__c = true;
        lsttrgStatus.add(CaseTriggerupdateContactBlankEmail);

        
        Trigger_Status__c CaseTriggerDeleteAffectedPassengers = new Trigger_Status__c();
        CaseTriggerDeleteAffectedPassengers.Name = 'CaseTriggerDeleteAffectedPassengers';
        CaseTriggerDeleteAffectedPassengers.Active__c = true;
        lsttrgStatus.add(CaseTriggerDeleteAffectedPassengers);
        
        Trigger_Status__c CaseTriggerPostNotification = new Trigger_Status__c();
        CaseTriggerPostNotification.Name = 'CaseTriggerPostNotification';
        CaseTriggerPostNotification.Active__c = true;
        lsttrgStatus.add(CaseTriggerPostNotification);

        
        Trigger_Status__c caseTriggerCaseStream = new Trigger_Status__c();
        caseTriggerCaseStream.Name = 'QCC_CaseStream';
        caseTriggerCaseStream.Active__c = true;
        lsttrgStatus.add(caseTriggerCaseStream);
        
        Trigger_Status__c postToChatterFeed = new Trigger_Status__c();
        postToChatterFeed.Name = 'postToChatterFeed';
        postToChatterFeed.Active__c = true;
        lsttrgStatus.add(postToChatterFeed);

        Trigger_Status__c SubmitForFinalisation = new Trigger_Status__c();
        SubmitForFinalisation.Name = 'SubmitForFinalisation';
        SubmitForFinalisation.Active__c = true;
        lsttrgStatus.add(SubmitForFinalisation);
        
        Trigger_Status__c trgCaseFieldUpdates = new Trigger_Status__c();
        trgCaseFieldUpdates.Name = 'trgCaseFieldUpdates';
        trgCaseFieldUpdates.Active__c = true;
        lsttrgStatus.add(trgCaseFieldUpdates);
        
        //GRAPHITE-409, GRAPHITE-927: Enforces running the assignment rule for VIP cases
        Trigger_Status__c assignVIPCaseUsingAssignmentRule = new Trigger_Status__c();
        assignVIPCaseUsingAssignmentRule.Name = 'assignVIPCaseUsingAssignmentRule';
        assignVIPCaseUsingAssignmentRule.Active__c = true;
        lsttrgStatus.add(assignVIPCaseUsingAssignmentRule);
        
        Trigger_Status__c autoCaseProcess = new Trigger_Status__c();
        autoCaseProcess.Name = 'autoCaseProcess';
        autoCaseProcess.Active__c = true;
        lsttrgStatus.add(autoCaseProcess);

        Trigger_Status__c fetchCongaEmailTemplateId = new Trigger_Status__c();
        fetchCongaEmailTemplateId.Name = 'fetchCongaEmailTemplateId';
        fetchCongaEmailTemplateId.Active__c = true;
        lsttrgStatus.add(fetchCongaEmailTemplateId);
        
        Trigger_Status__c populateBasicAutoCaseValues = new Trigger_Status__c();
        populateBasicAutoCaseValues.Name = 'CaseTriggerPopulateBasicAutoCaseValues';
        populateBasicAutoCaseValues.Active__c = true;
        lsttrgStatus.add(populateBasicAutoCaseValues);

        Trigger_Status__c SetAuditFieldsOnCase = new Trigger_Status__c();
        SetAuditFieldsOnCase.Name = 'SetAuditFieldsOnCase';
        SetAuditFieldsOnCase.Active__c = true;
        lsttrgStatus.add(SetAuditFieldsOnCase);

        Trigger_Status__c CaseTriggerUpdateTECHFields = new Trigger_Status__c();
        CaseTriggerUpdateTECHFields.Name = 'CaseTriggerUpdateTECHFields';
        CaseTriggerUpdateTECHFields.Active__c = true;
        lsttrgStatus.add(CaseTriggerUpdateTECHFields);

        
        Trigger_Status__c CaseHotwordQueueRoutingTrigger= new Trigger_Status__c();
        CaseHotwordQueueRoutingTrigger.Name = 'CaseHotwordQueueRoutingTrigger';
        CaseHotwordQueueRoutingTrigger.Active__c = true;
        lsttrgStatus.add(CaseHotwordQueueRoutingTrigger);
        
        Trigger_Status__c UpdateCaseOnClos = new Trigger_Status__c();
        UpdateCaseOnClos.Name = 'CaseTriggerUpdateCaseOnClose';
        UpdateCaseOnClos.Active__c = true;
        lsttrgStatus.add(UpdateCaseOnClos);

        
        Trigger_Status__c caseStatusUpdated = new Trigger_Status__c();
        caseStatusUpdated.Name = 'caseStatusUpdated';
        caseStatusUpdated.Active__c = true;
        lsttrgStatus.add(caseStatusUpdated);
        
        Trigger_Status__c CaseTriggerCalculateEmergencyExpense = new Trigger_Status__c();
        CaseTriggerCalculateEmergencyExpense.Name = 'CaseTriggerCalculateEmergencyExpense';
        CaseTriggerCalculateEmergencyExpense.Active__c = true;
        lsttrgStatus.add(CaseTriggerCalculateEmergencyExpense);
        
        Trigger_Status__c CaseTriggerpopulateonCaseCreate = new Trigger_Status__c();
        CaseTriggerpopulateonCaseCreate.Name = 'CaseTriggerpopulateonCaseCreate';
        CaseTriggerpopulateonCaseCreate.Active__c = true;
        lsttrgStatus.add(CaseTriggerpopulateonCaseCreate);

        Trigger_Status__c assignCaseOwner = new Trigger_Status__c();
        assignCaseOwner.Name = 'assignCaseOwner';
        assignCaseOwner.Active__c = true;
        lsttrgStatus.add(assignCaseOwner);
        
        
        Trigger_Status__c CaseTriggerUpdateCaseEscalatedTo = new Trigger_Status__c();
        CaseTriggerUpdateCaseEscalatedTo.Name = 'CaseTriggerUpdateCaseEscalatedTo';
        CaseTriggerUpdateCaseEscalatedTo.Active__c = true;
        lsttrgStatus.add(CaseTriggerUpdateCaseEscalatedTo);

        Trigger_Status__c CaseTriggerUpdateCaseSLA = new Trigger_Status__c();
        CaseTriggerUpdateCaseSLA.Name = 'CaseTriggerUpdateCaseSLA';
        CaseTriggerUpdateCaseSLA.Active__c = true;
        lsttrgStatus.add(CaseTriggerUpdateCaseSLA);

        
        Trigger_Status__c updateCaseFields = new Trigger_Status__c();
        updateCaseFields.Name = 'updateCaseFields';
        updateCaseFields.Active__c = true;
        lsttrgStatus.add(updateCaseFields);

        Trigger_Status__c updateCaseComplimentTemplateValue = new Trigger_Status__c();
        updateCaseComplimentTemplateValue.Name = 'updateCaseComplimentTemplateValue';
        updateCaseComplimentTemplateValue.Active__c = true;
        lsttrgStatus.add(updateCaseComplimentTemplateValue);
        
        Trigger_Status__c trgTradeSiteResponses = new Trigger_Status__c();
        trgTradeSiteResponses.Name = 'trgTradeSiteResponses';
        trgTradeSiteResponses.Active__c = true;
        lsttrgStatus.add(trgTradeSiteResponses);

        Trigger_Status__c EmailMessageTriggerV1 = new Trigger_Status__c();
        EmailMessageTriggerV1.Name = 'EmailMessageTriggerV1';
        EmailMessageTriggerV1.Active__c = true;
        lsttrgStatus.add(EmailMessageTriggerV1);
        
        Trigger_Status__c EmailMessageHelper = new Trigger_Status__c();
        EmailMessageHelper.Name = 'EmailMessageHelper';
        EmailMessageHelper.Active__c = true;
        lsttrgStatus.add(EmailMessageHelper);

        Trigger_Status__c EmailMessageTriggerLoungePassNonFFM = new Trigger_Status__c();
        EmailMessageTriggerLoungePassNonFFM.Name = 'EmailMessageTriggerLoungePassNonFFM';
        EmailMessageTriggerLoungePassNonFFM.Active__c = false;
        lsttrgStatus.add(EmailMessageTriggerLoungePassNonFFM);
        
        Trigger_Status__c processCaseEmailMessage = new Trigger_Status__c();
        processCaseEmailMessage.Name = 'processCaseEmailMessage';
        processCaseEmailMessage.Active__c = true;
        lsttrgStatus.add(processCaseEmailMessage);
        
        
        Trigger_Status__c captureFirstOutboundEmail = new Trigger_Status__c(Name='captureFirstOutboundEmail', Active__c=true);
        lsttrgStatus.add(captureFirstOutboundEmail);

        insert lsttrgStatus;

        TestUtilityDataClassQantas.insertQantasConfigData();
        
    }

    static testMethod void testCaseTrigger() {
        try {

            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            Test.startTest();
            //Contact con = [SELECT Id, Name FROM Contact Limit 1];
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            //cs.ContactId = con.id;
            insert cs;
            cs.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType'));
            cs.Type = 'Medical-Patient';
            cs.Group__c = 'Departure Airport';
            cs.Category__c = '';
            cs.Sub_Category__c = '';
            cs.Classification__c = '';
            cs.Assign_using_active_assignment_rules__c = true;
            update cs;
            Test.stopTest();
        } catch (Exception ex) {
            system.debug('exception in testCaseTrigger=======>  ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
    }

    
    static testMethod void testEmailMessageTrigger() {
        try {
            String type = 'Complaint';
            String recordType = 'CCC Complaints';
            Test.startTest();
            //Contact con = [SELECT Id, Name FROM Contact Limit 1];
            Case objCase = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'In-Flight', 'In-Flight Entertainment', 'Content', 'Content variety');
            insert objCase;

            EmailMessage em   = new EmailMessage();
            em.Incoming       = false;
            em.FromAddress    = 'qantas_customer_care@qantas.com.au';
            em.ToAddress      = 'test@test.com';
            em.Subject        = 'Qantas Customer Care';
            em.HtmlBody       = '<br/><h1>Hello!!</h1>';
            em.Status         = '3';
            em.ParentId       = objCase.Id;
            insert em;
    
            em.TECH_FromChatter__c = false;
            update em;

            delete em;

        } catch (Exception ex) {
            system.debug('exception in testEmailMessageTrigger=======>  ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }

    }


    static testMethod void testFreightEmailMessageTrigger() {
    try {

        Airport_Code__c arptCode = new Airport_Code__c (Name='NONE', Freight_Airport_State_Code__c='CA', QF_Freight_Presence__c=true);
        insert arptCode;
        
        Case cs = new Case( 
            RecordTypeId = RTID_CASE_QFREIGHT, 
            Origin = 'FRT Cust Service',
            Status = 'Open',
            Subject = 'Test Case 10',
            Description = 'This is for testing.',
            Freight_Port__c = arptCode.Id,
            SuppliedEmail = 'greenavenue@qantas.com.au',
            SuppliedCompany = 'Green Avenue Corp'
        );
        insert cs;
        
        EmailMessage em   = new EmailMessage();
        em.Incoming       = false;
        em.FromAddress    = 'qantas_customer_care@qantas.com.au';
        em.ToAddress      = 'test@test.com';
        em.Subject        = 'Qantas Customer Care';
        em.HtmlBody       = '<br/><h1>Hello!!</h1>';
        em.Status         = '3';
        em.ParentId       = cs.Id;
        insert em;
    
        em.TECH_FromChatter__c = false;
        update em;

    } catch (Exception ex) {
        system.debug('exception in testEmailMessageTrigger=======>  ' + ex.getMessage());
        System.debug(LoggingLevel.ERROR, ex.getMessage());
        System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
    }

 }

    

}