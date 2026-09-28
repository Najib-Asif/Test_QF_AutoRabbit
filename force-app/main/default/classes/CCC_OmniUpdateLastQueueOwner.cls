/*------------------------------------------------------------
   Company:        Salesforce
   Description:    Action on WorkItem Acceptance in Omnichannel
   Test Class:     CCC_OmniUpdateLastQueueOwner_Test

   History
   Date            Author                  Comments
   -------------------------------------------------------------
   06-04-2021      Salesforce              Initial Version
   -------------------------------------------------------------*/
public with sharing class CCC_OmniUpdateLastQueueOwner {
	@InvocableMethod(label='Action on CCC Case Acceptance' description='Update Case:Last Queue Owner when it is accepted via Omnichannel')
	public static void updateLastQueueOwner(List<Input> inputs) {
       
		try{
			List<Case> casesToBeUpdated = new List<Case>();
			Map<Id,Id> workItemIdToGroupId = new Map<Id,Id>();
			Set<Id> workItemIdSet = new Set<Id> ();
			Set<Id> groupIdSet = new Set<Id> ();
			Map<Id,Group> groupIdToObjectMap;
			String invalidQueuesForLastQueueOwner= Label.CCC_R1_InvalidQueuesForLastQueueOwner;

			//Jira:CRM-8706
			//Set<Id> setQCCRectypeIds = CaseTriggerHelper.qccCaseRecordTypeIds();
			Set<Id> setQCCRectypeIds = CaseUtility.qccCaseRecordTypeIds();

			for(Input eachInput: inputs) {
				workItemIdToGroupId.put(eachInput.workItemId,eachInput.originalGroupId);
				workItemIdSet.add(eachInput.workItemId);
				groupIdSet.add(eachInput.originalGroupId);
			}

			groupIdToObjectMap = new Map<Id,Group> ([SELECT Id, Name, DeveloperName from Group WHERE Id in: groupIdSet]);

			if(!workItemIdSet.isEmpty()) {
				for(Case c: [SELECT Id, recordtypeId, Last_Queue_Owner__c, Last_Queue_Owner_Name__c,status from Case WHERE Id in :workItemIdSet]) {
					if(setQCCRectypeIds.contains(c.recordtypeId) &&
					   !invalidQueuesForLastQueueOwner.Contains(groupIdToObjectMap.get(workItemIdToGroupId.get(c.Id)).DeveloperName)
					   ) {
						c.Last_Queue_Owner__c = workItemIdToGroupId.get(c.Id);
						c.Last_Queue_Owner_Name__c = groupIdToObjectMap.get(workItemIdToGroupId.get(c.Id)).Name;
                        c.Status = Label.QCC_CaseStatusConditionForResolveCase;

						casesToBeUpdated.add(c);
					}
				}
			}

			if(!casesToBeUpdated.isEmpty()) {
				update casesToBeUpdated;
			}

		}
		catch(Exception e) {
			//Debug Log (In Case of Exception No update to the case)
			System.debug(e.getMessage());
		}

	}

	//input details that comes to apex from flow
	public class Input {

		@InvocableVariable
		public Id originalGroupId;

		@InvocableVariable
		public Id workItemId;

	}
}