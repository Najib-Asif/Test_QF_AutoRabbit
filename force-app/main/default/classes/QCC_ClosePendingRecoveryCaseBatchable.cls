global class QCC_ClosePendingRecoveryCaseBatchable implements Database.Batchable<SObject> {

    public static set<string> openRecoveryStatus = new set<string>{'New', 'Pending Approval', 'Approved', 'Awaiting Customer', 'Processing','Further Action Required','Expired'};
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, Status, OwnerId, Origin, Resolution_Method__c, Closed_By__c, ClosedByLocation__c, ClosedByManager__c, Closed_By_Profile__c, RecordTypeId,
                (SELECT Id, CreatedBy.Id, Name, CreatedBy.Location__c, CreatedBy.ManagerId, CreatedBy.Profile.Name, Case_Number__c, Status__c
                 FROM Recoveries_Case__r ORDER BY LastModifiedDate DESC)
            FROM Case
            WHERE Status = 'Pending Recovery'
            AND Id IN (
                SELECT Case_Number__c FROM Recovery__c WHERE Status__c = 'Finalised'
            )
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Case> casesToUpdate = new List<Case>();
        try {
            for (SObject sObj : scope) {
                Case caseRec = (Case)sObj;

                Boolean hasOpenRecoveries = false;
                String finalRecvyUserId;
                String finalRecvyUserManagerId;
                String finalRecvyUserLocation;
                String finalRecvyUserProfile;

                if (!caseRec.Recoveries_Case__r.isEmpty()) {
                    for (Recovery__c r : caseRec.Recoveries_Case__r) {
                        if (r.Status__c == 'Finalised') {
                            finalRecvyUserId = r.CreatedBy.Id;
                            finalRecvyUserManagerId = r.CreatedBy.ManagerId;
                            finalRecvyUserLocation = r.CreatedBy.Location__c;
                            finalRecvyUserProfile = r.CreatedBy.Profile.Name;
                        }
                        if (openRecoveryStatus.contains(r.Status__c)) {
                            hasOpenRecoveries = true;
                            break;
                        }
                    }
                }

                if (!hasOpenRecoveries && caseRec.Status != 'Closed') {
                    caseRec.OwnerId = finalRecvyUserId != null ? finalRecvyUserId : caseRec.OwnerId;
                    caseRec.Resolution_Method__c = 'Auto Closed - Recovery';
                    caseRec.Closed_By__c = caseRec.OwnerId;
                    caseRec.ClosedByLocation__c = finalRecvyUserLocation;
                    caseRec.ClosedByManager__c = finalRecvyUserManagerId;
                    caseRec.Closed_By_Profile__c = finalRecvyUserProfile;
                    caseRec.Status = 'Closed';

                    casesToUpdate.add(caseRec);
                }
            }

            if (!casesToUpdate.isEmpty()) {
                
                    Database.update(casesToUpdate, false); 
                } 
            }catch (Exception e) {
                CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'Recoveries - Auto close pending recovery case', 'QCC_ClosePendingRecoveryCaseBatchable', 
                'execute', String.valueOf(''), String.valueOf(''), false, '', e);
            }
        }
    

    global void finish(Database.BatchableContext bc) {
    }
}