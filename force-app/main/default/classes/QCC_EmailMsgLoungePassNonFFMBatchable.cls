//This process is not needed because there is no Contact for Non FF as part of Remediation
//As mentioned by Graziella Simonetti this logic is no longer needed so commenting the code logic as per the JIRA CRM - 4993 
/*----------------------------------------------------------------------------------------------------------------------
Author:        Cuong Ly
Company:       Capgemini
Description:   This Batchable will be invoked by Email message trigger to call customer search API to get FF number.
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
19-Jun-2018      Cuong Ly               Build execute function

-----------------------------------------------------------------------------------------------------------------------*/
	global class QCC_EmailMsgLoungePassNonFFMBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts {
    Set<Id> setCaseId;
    Set<Id> setCaseRecType;
    Map<String, Id> mapQueue;

   global QCC_EmailMsgLoungePassNonFFMBatchable(Set<Id> caseIds, Set<Id> caseRecTypes) {
   /*     this.setCaseId = caseIds;
        this.setCaseRecType = caseRecTypes;
        mapQueue = new Map<String, Id>();
        for(QueueSobject  queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName 
                from QueueSobject where SobjectType ='Case']){
            mapQueue.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
        } */
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // build Query String get all the case need to handle for Non frequent flight member
      return Database.getQueryLocator([SELECT Id, OwnerId, Status, Contact.Frequent_Flyer_Number__c, Contact.CAP_ID__c,
                        ClosedBylocation__c, Closed_By__c,
                        (SELECT id, Status__c , Type__c FROM Recoveries_Case__r 
                        WHERE Type__c IN (:CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes'), :CustomSettingsUtilities.getConfigDataMap('Recovery IB Lounge Passes')) 
                        AND Status__c = 'Awaiting Customer Response') 
                    from case where Id IN: setCaseId AND RecordTypeId IN: setCaseRecType]); 
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
    /*    List<Case> lstCase = new List<Case>();
        List<Recovery__c> lstRecovery = new List<Recovery__c>();
        Contact contactSearch = new Contact();
        for(Case objCase : scope){
            if(objCase.Recoveries_Case__r.Size() > 0){
                //system.debug('UpdateRecoveryStatusForNonFrequentFlyerMember$$$$$$$$4');
                if(GenericUtils.checkBlankorNull(objCase.Contact.CAP_ID__c)){
                    contactSearch.CAP_ID__c = objCase.Contact.CAP_ID__c;
                    //system.debug('UpdateRecoveryStatusForNonFrequentFlyerMember$$$$$$$$5');
                    QCC_CustomerSearchHandler.ContactWrapper contactResult = QCC_CustomerSearchHandler.searchCustomer(contactSearch, '');
                    //system.debug('UpdateRecoveryStatusForNonFrequentFlyerMember$$$$$$$$6');
                    if(contactResult != null && GenericUtils.checkBlankorNull(contactResult.contacts[0].Frequent_Flyer_Number__c)){
                        //system.debug('UpdateRecoveryStatusForNonFrequentFlyerMember$$$$$$$$7=' + GenericUtils.checkBlankorNull(contactResult.contacts[0].Frequent_Flyer_Number__c));
                        for(Recovery__c rec : objCase.Recoveries_Case__r){
                            //system.debug('UpdateRecoveryStatusForNonFrequentFlyerMember$$$$$$$$8');
                            rec.Status__c = CustomSettingsUtilities.getConfigDataMap('SubmitForFinalisation');
                            lstRecovery.add(rec);
                        }
                    }else{
                        //system.debug('UpdateRecoveryStatusForNonFrequentFlyerMember$$$$$$$$9');
                        //objCase.Status = 'Recovery Error'; //Commented by Puru as requested by Rekha
                        if(objCase.ClosedBylocation__c == 'Sydney'){
                            objCase.OwnerId = objCase.Closed_By__c; 
                        }else{
                            objCase.OwnerId = mapQueue.get('Bounce_Back_Queue_High'); 
                        }
                        lstCase.add(objCase);
                    }
                }else{
                    objCase.Status = 'Reopened'; 
                    lstCase.add(objCase);
                }                          
            } 
        }
        if(lstRecovery.size() > 0){
            update lstRecovery;
        }
        if(lstCase.size() > 0){
            update lstCase;
        }  */ 
    } 

    global void finish(Database.BatchableContext BC) {
  } 
}