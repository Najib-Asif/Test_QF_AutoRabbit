/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 05-15-2024
 * @last modified by  : Praveen Sampath
**/
public class CaseAfterUpdateQueue implements Queueable,Database.AllowsCallouts{
    private List<Case> newCaseRecords;
    private Map<Id, Case> oldCasesMap;
    private static final String CASEORIGIN_WEB_CASE = CustomSettingsUtilities.getConfigDataMap('CaseOrigin_Web');
    private static final String CASE_CLOSED_STATUS = CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed');
    private static final String Freight_US_Booking = CustomSettingsUtilities.getConfigDataMap('Freight_US_Booking_UserName');
    public CaseAfterUpdateQueue(List<Case> newCaseRecords, Map<Id, Case> oldCases) {
        this.oldCasesMap = oldCases;
        this.newCaseRecords = newCaseRecords;
    }
    
    public void execute(QueueableContext qContext) {
        Map<String, List<String> > caseStreamSwitchPerTypeMap = QCC_UtilityHelper.getAllCaseStreamSwitch(false);
        Boolean canSendCaseStreamCallout = false;
        List<Case> caseListForLCSQ = new List<Case>();
        Id insuranceLetterCaseRTId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT CCC Insurance Letter Case')).getRecordTypeId();
        Id dealSupportRequestRTId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_DealSupportRequest')).getRecordTypeId();
        Id accountMaintenanceRTId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_AccountMaintenance')).getRecordTypeId();
        //CRM-7348 101 SOQL limit Fix
        Map<String,QAC_Agency_Credit_Detail__mdt> agencyCreditDetail = new Map<String,QAC_Agency_Credit_Detail__mdt>();
       for(QAC_Agency_Credit_Detail__mdt mdtRecord : QAC_Agency_Credit_Detail__mdt.getAll().values()) {
            if(mdtRecord != NULL) {
                agencyCreditDetail.put(mdtRecord.DeveloperName, mdtRecord);
            }
        }
        Map<Id, String> pnrMap = new Map<Id, String>();
        Set<Id> contactChangedCaseIds = new Set<Id>();
        Map<Id, Id> caseContactChangedIdsMap = new Map<Id, Id>();
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Case> contractCaseMap = new Map<Id, Case>();
        Set<Id> caseIdsForCreditFullfillment = new Set<Id>();
        Map<Id, Case> accountIdCaseMap = new Map<Id, Case>();
        Map<Id, Case> awbCaseUpdateMap = new Map<Id, Case>();
        for (Case caseNewRecord : newCaseRecords) {
            if (caseNewRecord.Booking_PNR__c != oldCasesMap.get(caseNewRecord.Id).Booking_PNR__c) {
                pnrMap.put(caseNewRecord.Id, caseNewRecord.Booking_PNR__c);
                
            }
            if (caseNewRecord.ContactId != oldCasesMap.get(caseNewRecord.Id).ContactId) {
                contactChangedCaseIds.add(caseNewRecord.Id);
                caseContactChangedIdsMap.put(caseNewRecord.Id, caseNewRecord.ContactId);
            }
            canSendCaseStreamCallout = QCC_UtilityHelper.checkIfCanSendCaseStreamCallout(caseStreamSwitchPerTypeMap, caseNewRecord);
            if (canSendCaseStreamCallout) {
                caseListForLCSQ.add(caseNewRecord);
            }
            system.debug(caseNewRecord.RecordTypeId);
            system.debug(caseNewRecord.AccountId);
            system.debug(agencyCreditDetail.get('CaseValues').Case_Type__c);
            system.debug(caseNewRecord.Sub_Type_1__c == agencyCreditDetail.get('CaseValues').SubType1__c);
            system.debug(agencyCreditDetail.get('CaseValues').Approval_Status__c);
            system.debug(agencyCreditDetail.get('CaseValues').Fulfilled__c);
            if ( caseNewRecord.RecordTypeId == accountMaintenanceRTId && !String.isBlank(caseNewRecord.AccountId) && 
                 caseNewRecord.Type == agencyCreditDetail.get('CaseValues').Case_Type__c && 
                 caseNewRecord.Sub_Type_1__c == agencyCreditDetail.get('CaseValues').SubType1__c && 
                 caseNewRecord.Approval_Status__c == agencyCreditDetail.get('CaseValues').Approval_Status__c && 
                 caseNewRecord.Approve__c == agencyCreditDetail.get('CaseValues').Fulfilled__c
               ) 
            {
                caseIdsForCreditFullfillment.add(caseNewRecord.Id);
                accountIdCaseMap.put(caseNewRecord.AccountId, caseNewRecord);
            }
            System.debug('caseNewRecord.Related_Contract__c=======> ' + caseNewRecord.Related_Contract__c);
            System.debug('caseNewRecord.RecordTypeId=======> ' + caseNewRecord.RecordTypeId);
            System.debug('dealSupportRequestRTId=======> ' + dealSupportRequestRTId);
            System.debug('caseNewRecord.NAM_s_Approval__c=======> ' + caseNewRecord.NAM_s_Approval__c);
            System.debug('caseNewRecord.Approval_Status__c=======> ' + caseNewRecord.Approval_Status__c);
            System.debug('caseNewRecord.Sub_Type__c=======> ' + caseNewRecord.Sub_Type__c);
            System.debug('CaseApprovalStatusApproved=======> ' + CustomSettingsUtilities.getConfigDataMap('CaseApprovalStatusApproved'));
            System.debug('CaseSubTypeChannelAgencyPC=======> ' + CustomSettingsUtilities.getConfigDataMap('CaseSubTypeChannelAgencyPC'));

            if ( !String.isBlank(caseNewRecord.Related_Contract__c) && caseNewRecord.RecordTypeId == dealSupportRequestRTId && caseNewRecord.NAM_s_Approval__c && 
                 caseNewRecord.Approval_Status__c == CustomSettingsUtilities.getConfigDataMap('CaseApprovalStatusApproved') &&
                 caseNewRecord.Sub_Type__c == CustomSettingsUtilities.getConfigDataMap('CaseSubTypeChannelAgencyPC')
            	)
            {
                contractIds.add(caseNewRecord.Related_Contract__c);
                contractCaseMap.put(caseNewRecord.Related_Contract__c, caseNewRecord);
            }//added web logic check
            system.debug('Freight_US_Booking.equals(caseNewRecord.CreatedBy.Username)'+ caseNewRecord.Created_By_Name__c);
            if(String.isNotBlank(caseNewRecord.Freight_AWB_Number__c) && CASEORIGIN_WEB_CASE.equals(caseNewRecord.Origin)  && !CASE_CLOSED_STATUS.equals(caseNewRecord.Status) && Freight_US_Booking.equals(caseNewRecord.Created_By_Name__c) ) {
                System.debug('CaseAfterUpdatequeue');
                awbCaseUpdateMap.put(caseNewRecord.Id, caseNewRecord);
                System.debug('CaseAfterUpdatequeue**');
            }
        }
        if (!pnrMap.isEmpty()) {
            deleteAffectedPassengers(pnrMap);
        }
        if (!contactChangedCaseIds.isEmpty()) {
            updateRecoveryContact(contactChangedCaseIds, caseContactChangedIdsMap);
        }
        if (!caseIdsForCreditFullfillment.isEmpty()) {
            agencyCreditFulfilmentMethod(caseIdsForCreditFullfillment, accountIdCaseMap, agencyCreditDetail);
        }
        if (!contractIds.isEmpty()) {
            agencyContractUpdateMethod(contractIds, contractCaseMap);
        }
        if (!awbCaseUpdateMap.isEmpty()) {
            updateCaseOwner(awbCaseUpdateMap);
        }
       
        //GRAPHITE-1372 Send update to Loyalty once a case record has been created or the status has been updated.
        if (!Test.isRunningTest() && !caseListForLCSQ.isEmpty()) {
            System.enqueueJob(new LoyaltyCaseStreamQueue(caseListForLCSQ, oldCasesMap));
        }
    }
/*--------------------------------------------------------------------------------------
Method Name: deleteAffectedPassengers
Description: Delete all related Affected Passenger records when the PNR of the Case is changed.
Parameter:   Changed as part of CRM-7348: 
--------------------------------------------------------------------------------------*/
    public static void deleteAffectedPassengers(Map<Id, String> pnrMap) {
        List<Affected_Passenger__c> passengersToBeDeleted = new List<Affected_Passenger__c>();
        for(Affected_Passenger__c affectedPassenger : [ SELECT Id, PNR__c, Case__c FROM Affected_Passenger__c WHERE Case__c IN :pnrMap.keySet()]) 
        {
            if(affectedPassenger.PNR__c != pnrMap.get(affectedPassenger.Case__c)) {
                passengersToBeDeleted.add(affectedPassenger);
            }
        }
        try {
            if (!passengersToBeDeleted.isEmpty()) {
                delete passengersToBeDeleted;
            } 
        } catch (Exception ex) {
                System.debug('ex###############' + ex);
                CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QCC - Case Trigger Handler', 'CaseAfterUpdateQueue', 
                                        'deleteAffectedPassengers', '', '', false, '', ex);
        }
    }
/*--------------------------------------------------------------------------------------
Method Name: updateRecoveryContact
Description: Update the dependent Recovery contact if Contact on Case gets changed
Parameter:   Set<Id>, Map<Id,Id>, changed as part of CRM-7348: 
--------------------------------------------------------------------------------------*/
    public static void updateRecoveryContact(Set<Id> caseIds, Map<Id, Id> caseContactIdsMap) {
        List<Recovery__c> recoveries = [ SELECT Id, Contact__c, Case_Number__c FROM Recovery__c WHERE RecordType.DeveloperName = :CustomSettingsUtilities.getConfigDataMap('RT_OtherRecovery') AND Case_Number__c IN :caseIds ];
        for (Recovery__c recovery : recoveries) 
        {
            recovery.Contact__c = caseContactIdsMap.get(recovery.Case_Number__c);
        }
        try {
            if (!recoveries.isEmpty()) {
                update recoveries;
            } 
        } catch (Exception ex) {
                System.debug('ex###############' + ex);
                CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QCC - Case Trigger Handler', 'CaseAfterUpdateQueue', 
                                        'updateRecoveryContact', '', '', false, '', ex);
        }
    }
/*----------------------------------------------------------------------------------------------
Method Name: agencyCreditFulfilmentMethod
Description: QAC Agency Credits logic
Parameter:   Set<Case> Map<Id, Case>, changed as part of CRM-7348: Converted to Asyn method List<String>, List<String>
----------------------------------------------------------------------------------------------*/
    public static void agencyCreditFulfilmentMethod(Set<Id> caseIds, Map<Id, Case> accountIdCaseMap, Map<String, QAC_Agency_Credit_Detail__mdt> creditDetailMDT) {
        Asset assetToBeUpdated;
        Ledger__c ledgerToBeInserted;
        Case caseToBeUpdated, caseRecord;
        Map<String, Ledger__c> ledgerRecordMap = new Map<String, Ledger__c>();
        Id ledgerRecordTypeId = Schema.sObjectType.Ledger__c.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_AgencyCredit')).getRecordTypeId();
        Savepoint savePoint = Database.setSavepoint();
        for (Ledger__c ledgerRecord :[ SELECT Id, Case__c, Account__c, Asset__c, RecordTypeId FROM Ledger__c 
                                      WHERE Case__c IN :caseIds 
                                      AND RecordTypeId = :ledgerRecordTypeId ])
        {
            ledgerRecordMap.put(ledgerRecord.Case__c, ledgerRecord);
        }
        List<Asset> assetsAll = new List<Asset>([SELECT Id, Name, RecordTypeId, AccountId, Total_Acquired_credits__c, Total_Consumed_credits__c, Total_Outstanding_credits__c, Active__c FROM Asset ]);
        system.debug('assetsAll=======> ' + assetsAll);
        system.debug('accountIdCaseMap.keySet() =====> ' +accountIdCaseMap.keySet());
        Id rectypeid = Schema.sObjectType.Asset.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_Asset_AgencyCredit')).getRecordTypeId();
        system.debug('record typeid=======> ' + rectypeid);

        List<Asset> assets = new List<Asset>([SELECT Id, Name, RecordTypeId, AccountId, Total_Acquired_credits__c, Total_Consumed_credits__c, Total_Outstanding_credits__c, Active__c FROM Asset 
                                              WHERE AccountId IN :accountIdCaseMap.keySet() 
                                              AND RecordTypeId = : Schema.sObjectType.Asset.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_Asset_AgencyCredit')).getRecordTypeId()
                                              AND Active__c =: True 
                                              FOR UPDATE]);
        System.debug('assets=====> ' + assets);
        if(assets.size() == 1) {
            assetToBeUpdated = assets[0];
            assetToBeUpdated.Total_Acquired_credits__c += accountIdCaseMap.get(assetToBeUpdated.AccountId).Total_Credits__c;
            ledgerToBeInserted = new Ledger__c(
                Account__c = accountIdCaseMap.get(assetToBeUpdated.AccountId).AccountId,
                Asset__c = assetToBeUpdated.Id, 
                Case__c = accountIdCaseMap.get(assetToBeUpdated.AccountId).Id,
                RecordTypeId = ledgerRecordTypeId,
                Transaction_type__c = creditDetailMDT.get('CreditLedgerValues').Ledger_Transaction_Type__c,
                Transaction_frequency__c = creditDetailMDT.get('CreditLedgerValues').Ledger_Transaction_frequency__c, 
                Transaction_date__c = System.today(),
                Reason__c = creditDetailMDT.get('CreditLedgerValues').Ledger_Reason__c, 
                User__c = accountIdCaseMap.get(assetToBeUpdated.AccountId).OwnerId,
                Total_Credit_Value__c = accountIdCaseMap.get(assetToBeUpdated.AccountId).Total_Credits__c, 
                Total_Outstanding_Credits__c = assetToBeUpdated.Total_Acquired_credits__c - assetToBeUpdated.Total_Consumed_credits__c 
            );
            caseToBeUpdated = accountIdCaseMap.get(assetToBeUpdated.AccountId);
            caseToBeUpdated.Approve__c = creditDetailMDT.get('CaseFulfillmentValues').Fulfilled__c;
            caseToBeUpdated.Status = creditDetailMDT.get('CaseFulfillmentValues').Case_Status__c;
        } else { //Error message here
            if (assets.isEmpty()) {
                for (Id accountId : accountIdCaseMap.keySet()) {
                    caseRecord = accountIdCaseMap.get(accountId);
                    caseRecord.addError('Active asset is not available for the selected Agency Account, So Cannot allocate credits', false);
                }
            } else {
                    for (Asset asset : assets) {
                        caseRecord = accountIdCaseMap.get(asset.AccountId);
                        caseRecord.addError('Multiple active assets are available for the selected Agency Account, So cannot allocate credits', false);
                    }
                } 
            }
        try {
            if(assetToBeUpdated != NULL) {
                Database.SaveResult assetResults = Database.update(assetToBeUpdated, true);
                if (ledgerToBeInserted != NULL) {
                    if(ledgerRecordMap.isEmpty()) {
                        Database.SaveResult ledgerResults = Database.insert(ledgerToBeInserted, true);
                    } else {
                        caseRecord = accountIdCaseMap.get(ledgerToBeInserted.Account__c);
                        caseRecord.addError('Ledger Credit entry is already available against the Case', false);
                    }
                }
                if (caseToBeUpdated != NULL) {
                    Database.SaveResult caseResults = Database.update(caseToBeUpdated, true);
                }
            }
        } catch (Exception ex) {
                System.debug('ex###############' + ex);
                CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QCC - Case Trigger Handler', 'CaseAfterUpdateQueue', 
                                        'agencyCreditFulfilmentMethod', '', '', false, '', ex);
        }
    }
/*----------------------------------------------------------------------------------------------
Method Name: agencyContractUpdateMethod
Description: QC Payments Contract Termination
Parameter:   Set<Id>,Map<Id, Case>, changed as part of CRM-7348: Converted to Asyn method List<String>, List<String>
----------------------------------------------------------------------------------------------*/
    public static void agencyContractUpdateMethod(Set<Id> contractIds, Map<Id, Case> contractCaseMap) {
        //Id asbcContractRTId = Schema.sObjectType.Contract__c.getRecordTypeInfosByName().get('RT_AgencySignedByCustomer').getRecordTypeId();
        Id asbcContractRTId = Schema.sObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_AgencySignedByCustomer')).getRecordTypeId();

        List<Contract__c> contractsToBeUpdated = [ SELECT Id, Contract_End_Date__c, Termination_Reason__c, Status__c, RecordTypeId FROM Contract__c
                                                  WHERE Id IN :contractIds AND RecordTypeId = :asbcContractRTId ];
        for (Contract__c contract : contractsToBeUpdated) {
            contract.Contract_End_Date__c = contractCaseMap.get(contract.Id).End_Date__c;
            contract.Termination_Reason__c = contractCaseMap.get(contract.Id).Reasons_for_Termination__c;
        }
        try {
            if (!contractsToBeUpdated.isEmpty()) {
                update contractsToBeUpdated;
            }
        } catch (Exception ex) {
                System.debug('ex###############' + ex);
                CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QCC - Case Trigger Handler', 'CaseAfterUpdateQueue', 
                                        'agencyContractUpdateMethod', '', '', false, '', ex);
        }
    }
    
/*----------------------------------------------------------------------------------------------
Method Name: CaseQueueableUpdateOwner
Description: test the queable apex
Parameter:   
Jira Number:CRM-9699
----------------------------------------------------------------------------------------------*/
    public static void updateCaseOwner(Map<Id, Case> caseRecordMap) {
        Set<String> awbNumbers = new Set<String>();
        Map<Id, AWB_Info__c> awbInfoMap = new Map<Id, AWB_Info__c>();
        String key;
        Map<Id, Case> caseRecordsMap = new Map<Id, Case>();
        for (Case caseRec : [ SELECT Id, OwnerId, Freight_AWB_Number__c, Status FROM Case WHERE Id IN :caseRecordMap.keySet()]) 
        {
            caseRecordsMap.put(caseRec.Id, caseRec);
        }
        for (Case caseRecord : caseRecordsMap.values()) {
            awbNumbers.add(caseRecord.Freight_AWB_Number__c);
            System.debug('caseRecordsMap.values()'+caseRecordsMap.keySet());
            
        }
        for(Id caseId:caseRecordsMap.keySet()){
            AWB_Info__c awbRecords= FreightAWBPopUpController.getBeforeAWBDetails(caseId);
          //  id awbid = awbRecords.Id;
            system.debug('awbRecords**');
        }
        
        System.debug('updateCaseOwner - awbNumbers - '+awbNumbers);
        for (AWB_Info__c awbInfoRecord : [ SELECT Id, Name, Freight_Port__c, Freight_Port__r.Name,Freight_Port__r.Freight_Region__c FROM AWB_Info__c WHERE Name IN :awbNumbers]) 
        {
            if(String.isNotBlank(awbInfoRecord.Freight_Port__r.Freight_Region__c) && String.isNotBlank(awbInfoRecord.Freight_Port__r.Name)){
            // need to check if port region is blank
            awbInfoMap.put(awbInfoRecord.Id, awbInfoRecord);
                System.debug('awbInfoRecord****');
            }
        }
        Map<String, Id> queueMap = new Map<String, Id>();
        for (Group groupRecord : [ SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
            queueMap.put(groupRecord.DeveloperName, groupRecord.Id);
            system.debug('queueMap'+queueMap);
        }
        List<Case> caseUpdateList = new List<Case>();
        Case caseRecord;
        AWB_Info__c awbRecord;
        for (AWB_Relationship__c awbRelationRecord : [ SELECT Id, AWB__c, Case__c 
                                                        FROM AWB_Relationship__c 
                                                        WHERE Case__c IN :caseRecordsMap.keySet() ]) 
        {
            if (!awbInfoMap.containsKey(awbRelationRecord.AWB__c)) {
                continue;
            }
            caseRecord = caseRecordsMap.get(awbRelationRecord.Case__c);
            awbRecord = awbInfoMap.get(awbRelationRecord.AWB__c);
            System.debug('AWB Info in updateCaseOwner - '+awbRecord);
            System.debug('Case record in updateCaseOwner - '+caseRecord);
            key = CustomSettingsUtilities.getConfigDataMap('FREIGHT_US_BOOKING_'+awbRecord.Freight_Port__r.Freight_Region__c);
            System.debug('Key in updateCaseOwner - '+queueMap.get(key));
            // CRM-13421 - Skip owner update for specific case criteria
            Id targetQueueId = queueMap.get(key);
                if (
                    caseRecord.RecordType.Name == 'Qantas Freight' &&
                    caseRecord.Type == 'Booking' &&
                    caseRecord.Sub_Type_1__c == 'New' &&
                    caseRecord.Sub_Type_2__c == 'Spot Rate' &&
                    caseRecord.Country__c == 'Australia'
                ) {
                    continue;
                }
			
            caseRecord.OwnerId = targetQueueId;
            //caseRecord.OwnerId = queueMap.get(key);
            caseRecord.Status = 'Closed';
            caseUpdateList.add(caseRecord);
        }
        try {
        if (!caseUpdateList.isEmpty()) {
            update caseUpdateList;
        }
        }
        catch (Exception ex) {
                System.debug('ex###############' + ex);
                CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QCC - Case Trigger Handler', 'CaseAfterUpdateQueue', 
                                        'updateCaseOwner', '', '', false, '', ex);
            
        }
    }
  
}