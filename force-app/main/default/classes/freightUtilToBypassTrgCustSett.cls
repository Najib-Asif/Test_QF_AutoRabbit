/*----------------------------------------------------------------------------------------------------------------------
Author:        Navpreet Kaur
Company:       TCS
Description:   Generic Utility Class Created for Freight Cases to bypass the Case Trigger Custom Settings
Inputs:
Test Class:    Not Required
-----------------------------------------------------------------------------------------------------------------------*/
public class freightUtilToBypassTrgCustSett 
{
	 public static List<Trigger_Status__c>createCaseTriggerSettingFalse(){
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c populateBasicAutoCaseValues = new Trigger_Status__c();
        populateBasicAutoCaseValues.Name = 'CaseTriggerPopulateBasicAutoCaseValues';
        populateBasicAutoCaseValues.Active__c = False;
        lsttrgStatus.add(populateBasicAutoCaseValues);
        
        Trigger_Status__c CaseHotwordQueueRoutingTrigger = new Trigger_Status__c();
        CaseHotwordQueueRoutingTrigger.Name = 'CaseHotwordQueueRoutingTrigger';
        CaseHotwordQueueRoutingTrigger.Active__c = false;
        lsttrgStatus.add(CaseHotwordQueueRoutingTrigger);
        
        Trigger_Status__c updateCaseCompliment = new Trigger_Status__c();
        updateCaseCompliment.Name = 'updateCaseComplimentTemplateValue';
        updateCaseCompliment.Active__c = false;
        lsttrgStatus.add(updateCaseCompliment);
       
        Trigger_Status__c updateCaseFields = new Trigger_Status__c();
        updateCaseFields.Name = 'updateCaseFields';
        updateCaseFields.Active__c = false;
        lsttrgStatus.add(updateCaseFields);
        
        Trigger_Status__c fetchCongaEmail = new Trigger_Status__c();
        fetchCongaEmail.Name = 'fetchCongaEmailTemplateId';
        fetchCongaEmail.Active__c = false;
        lsttrgStatus.add(fetchCongaEmail);
        
        Trigger_Status__c autoCaseProcess = new Trigger_Status__c();
        autoCaseProcess.Name = 'autoCaseProcess';
        autoCaseProcess.Active__c = false;
        lsttrgStatus.add(autoCaseProcess);
        
        Trigger_Status__c caseStatusUpdated = new Trigger_Status__c();
        caseStatusUpdated.Name = 'caseStatusUpdated';
        caseStatusUpdated.Active__c = false;
        lsttrgStatus.add(caseStatusUpdated);
        
        Trigger_Status__c CaseTriggerCloseCase = new Trigger_Status__c();
        CaseTriggerCloseCase.Name = 'CaseTriggerCloseCase';
        CaseTriggerCloseCase.Active__c = false;
        lsttrgStatus.add(CaseTriggerCloseCase);
        
        Trigger_Status__c assignCaseOwner = new Trigger_Status__c();
        assignCaseOwner.Name = 'assignCaseOwner';
        assignCaseOwner.Active__c = false;
        lsttrgStatus.add(assignCaseOwner);
        
        Trigger_Status__c postToChatterFeed = new Trigger_Status__c();
        postToChatterFeed.Name = 'postToChatterFeed';
        postToChatterFeed.Active__c = false;
        lsttrgStatus.add(postToChatterFeed);
        
        Trigger_Status__c CaseTriggerUpdate = new Trigger_Status__c();
        CaseTriggerUpdate.Name = 'CaseTriggerUpdateCaseSLA';
        CaseTriggerUpdate.Active__c = false;
        lsttrgStatus.add(CaseTriggerUpdate);
        
        Trigger_Status__c CaseEscalatedTo = new Trigger_Status__c();
        CaseEscalatedTo.Name = 'CaseTriggerUpdateCaseEscalatedTo';
        CaseEscalatedTo.Active__c = false;
        lsttrgStatus.add(CaseEscalatedTo);
        
        Trigger_Status__c UpdateCaseOnClos = new Trigger_Status__c();
        UpdateCaseOnClos.Name = 'CaseTriggerUpdateCaseOnClose';
        UpdateCaseOnClos.Active__c = false;
        lsttrgStatus.add(UpdateCaseOnClos);

        Trigger_Status__c SubmitForFinalisation = new Trigger_Status__c();
        SubmitForFinalisation.Name = 'SubmitForFinalisation';
        SubmitForFinalisation.Active__c = false;
        lsttrgStatus.add(SubmitForFinalisation);

        Trigger_Status__c trgCaseFieldUpdates = new Trigger_Status__c();
        trgCaseFieldUpdates.Name = 'trgCaseFieldUpdates';
        trgCaseFieldUpdates.Active__c = false;
        lsttrgStatus.add(trgCaseFieldUpdates);

        Trigger_Status__c CaseTriggerCalculateEmergencyExpense = new Trigger_Status__c();
        CaseTriggerCalculateEmergencyExpense.Name = 'CaseTriggerCalculateEmergencyExpense';
        CaseTriggerCalculateEmergencyExpense.Active__c = false;
        lsttrgStatus.add(CaseTriggerCalculateEmergencyExpense);

        Trigger_Status__c CaseTriggerupdateContactBlankEmail = new Trigger_Status__c();
        CaseTriggerupdateContactBlankEmail.Name = 'CaseTriggerupdateContactBlankEmail';
        CaseTriggerupdateContactBlankEmail.Active__c = false;
        lsttrgStatus.add(CaseTriggerupdateContactBlankEmail);

        Trigger_Status__c CaseTriggerpopulateonCaseCreate = new Trigger_Status__c();
        CaseTriggerpopulateonCaseCreate.Name = 'CaseTriggerpopulateonCaseCreate';
        CaseTriggerpopulateonCaseCreate.Active__c = false;
        lsttrgStatus.add(CaseTriggerpopulateonCaseCreate);

        Trigger_Status__c SetAuditFieldsOnCase = new Trigger_Status__c();
        SetAuditFieldsOnCase.Name = 'SetAuditFieldsOnCase';
        SetAuditFieldsOnCase.Active__c = false;
        lsttrgStatus.add(SetAuditFieldsOnCase);

        Trigger_Status__c CaseTriggerDeleteAffectedPassengers = new Trigger_Status__c();
        CaseTriggerDeleteAffectedPassengers.Name = 'CaseTriggerDeleteAffectedPassengers';
        CaseTriggerDeleteAffectedPassengers.Active__c = false;
        lsttrgStatus.add(CaseTriggerDeleteAffectedPassengers);

        Trigger_Status__c CaseTriggerUpdateTECHFields = new Trigger_Status__c();
        CaseTriggerUpdateTECHFields.Name = 'CaseTriggerUpdateTECHFields';
        CaseTriggerUpdateTECHFields.Active__c = false;
        lsttrgStatus.add(CaseTriggerUpdateTECHFields);

        Trigger_Status__c CaseTriggerPostNotification = new Trigger_Status__c();
        CaseTriggerPostNotification.Name = 'CaseTriggerPostNotification';
        CaseTriggerPostNotification.Active__c = false;
        lsttrgStatus.add(CaseTriggerPostNotification);
        
        Trigger_Status__c CaseTriggerUpdateRecContact = new Trigger_Status__c();
        CaseTriggerUpdateRecContact.Name = 'CaseTriggerUpdateRecContact';
        CaseTriggerUpdateRecContact.Active__c = false;
        lsttrgStatus.add(CaseTriggerUpdateRecContact);

        Trigger_Status__c trgTradeSiteResponses = new Trigger_Status__c();
        trgTradeSiteResponses.Name = 'trgTradeSiteResponses';
        trgTradeSiteResponses.Active__c = false;
        lsttrgStatus.add(trgTradeSiteResponses);
        
        Trigger_Status__c CaseTriggeragencyCreditFulfilment = new Trigger_Status__c();
        CaseTriggeragencyCreditFulfilment.Name = 'CaseTriggeragencyCreditFulfilment';
        CaseTriggeragencyCreditFulfilment.Active__c = false;
        lsttrgStatus.add(CaseTriggeragencyCreditFulfilment);
       
        //GRAPHITE-1151
        Trigger_Status__c CaseStream = new Trigger_Status__c();
        CaseStream.Name = 'QCC_CaseStream';
        CaseStream.Active__c = false;
        lsttrgStatus.add(CaseStream);

        
        Trigger_Status__c assignVIPCaseUsingAssignmentRule = new Trigger_Status__c();
        assignVIPCaseUsingAssignmentRule.Name = 'assignVIPCaseUsingAssignmentRule';
        assignVIPCaseUsingAssignmentRule.Active__c = false;
        lsttrgStatus.add(assignVIPCaseUsingAssignmentRule);
        
       
        Trigger_Status__c assetCreationTrigger = new Trigger_Status__c();
        assetCreationTrigger.Name = 'AssetCreationTrigger';
        assetCreationTrigger.Active__c = false;
        lsttrgStatus.add(assetCreationTrigger);

        return lsttrgStatus;
    }
    public static List<Trigger_Status__c> createAccountTriggerSettingFalse()
    {
        List<Trigger_Status__c> lstAcctStatus = new List<Trigger_Status__c>();
        
        Trigger_Status__c AccconRshipUpdate = new Trigger_Status__c();
        AccconRshipUpdate.Name = 'AccconRshipUpdate';
        AccconRshipUpdate.Active__c = false;
        lstAcctStatus.add(AccconRshipUpdate);
        
        Trigger_Status__c ContactCeateAccount = new Trigger_Status__c();
        ContactCeateAccount.Name = 'ContactCeateAccount';
        ContactCeateAccount.Active__c = false;
        lstAcctStatus.add(ContactCeateAccount);
        
        Trigger_Status__c ContactUpdateContact = new Trigger_Status__c();
        ContactUpdateContact.Name = 'ContactUpdateContact';
        ContactUpdateContact.Active__c = false;
        lstAcctStatus.add(ContactUpdateContact);
        
        Trigger_Status__c ContactAttachCase = new Trigger_Status__c();
        ContactAttachCase.Name = 'ContactAttachCase';
        ContactAttachCase.Active__c = false;
        lstAcctStatus.add(ContactAttachCase);
        
        Trigger_Status__c createIndividualRecord = new Trigger_Status__c();
        createIndividualRecord.Name = 'createIndividualRecord';
        createIndividualRecord.Active__c = false;
        lstAcctStatus.add(createIndividualRecord);
        
        Trigger_Status__c QACManagerContactDupCheck = new Trigger_Status__c();
        QACManagerContactDupCheck.Name = 'QACManagerContactDupCheck';
        QACManagerContactDupCheck.Active__c = false;
        lstAcctStatus.add(QACManagerContactDupCheck);
        
        Trigger_Status__c QCC_WelcomeToSSU = new Trigger_Status__c();
        QCC_WelcomeToSSU.Name = 'QCC_WelcomeToSSU';
        QCC_WelcomeToSSU.Active__c = false;
        lstAcctStatus.add(QCC_WelcomeToSSU);
        
        Trigger_Status__c QCC_UpdateContactPhoneAndAddress = new Trigger_Status__c();
        QCC_UpdateContactPhoneAndAddress.Name = 'QCC_UpdateContactPhoneAndAddress';
        QCC_UpdateContactPhoneAndAddress.Active__c = false;
        lstAcctStatus.add(QCC_UpdateContactPhoneAndAddress);
        
        Trigger_Status__c ACRPrimaryContact = new Trigger_Status__c();
        ACRPrimaryContact.Name = 'ACRPrimaryContact';
        ACRPrimaryContact.Active__c = true;
        lstAcctStatus.add(ACRPrimaryContact);
        
        
       return lstAcctStatus; 
    }
 
}