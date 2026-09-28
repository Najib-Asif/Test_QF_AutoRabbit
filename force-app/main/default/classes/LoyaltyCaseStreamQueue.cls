/*
 * Purpose: GRAPHITE-1372 This method is used to send the callout to update the Case record for the Case Stream. This will also send 2 callout if the status of the case inserted is Closed
 * input parameters:
  		caseList - The list containing all the new case records.
 * return type: None
 */
public class LoyaltyCaseStreamQueue implements Queueable {
    private List<Case> newCaseRecords;
    private Map<Id, Case> oldCasesMap;
    
    public LoyaltyCaseStreamQueue(List<Case> newCaseRecords, Map<Id, Case> oldCases) {
        this.oldCasesMap = oldCases;
        this.newCaseRecords = newCaseRecords;
    }
    
    public void execute(QueueableContext qContext) {
        System.debug('Update Case Record for the Case Stream');
        Map<String, List<String> > caseStreamSwitchPerTypeMap = QCC_UtilityHelper.getAllCaseStreamSwitch(false);
        System.debug('caseStreamSwitchPerTypeMap: ' + caseStreamSwitchPerTypeMap);
        List<Id> caseIds = new List<Id>();
        List<Id> autoClosedCaseIds = new List<Id>();
        Case oldRecord; 
        
        for (Case caseNewRecord : newCaseRecords) {
            //Check if the callout is need for the specific type and status of the case.
            Boolean canSendCaseStreamCallout = QCC_UtilityHelper.checkIfCanSendCaseStreamCallout(caseStreamSwitchPerTypeMap, caseNewRecord);
            System.debug('canSendCaseStreamCallout: ' + canSendCaseStreamCallout);
            if (canSendCaseStreamCallout) {
                if (oldCasesMap != NULL) { // On After Update
                    oldRecord = oldCasesMap.get(caseNewRecord.Id);
                    //Need to run the logic only when the status has been changed.
                    if (oldRecord != NULL && caseNewRecord.Status != oldRecord.Status) {
                        caseIds.add(caseNewRecord.Id);
                    }
                } else { // On After Insert
                    //This is used to know whether the status for the first Case Stream is 'Closed'.
                    if (caseNewRecord.Status == CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed')) {
                        autoClosedCaseIds.add(caseNewRecord.Id);
                    }
                    caseIds.add(caseNewRecord.Id);
                }
            }
        }
        if (!caseIds.isEmpty()) {
            QCC_SOQL_Setting__mdt caseStream001 = QCC_UtilityHelper.getSOQLSettingByDeveloperName('Case_Stream_001');
            if (caseStream001 != NULL) {
                Database.executeBatch(new QCC_CaseStreamBatch(caseStream001.Query_String__c, caseIds, autoClosedCaseIds), 1);
            }
        }
    }
}