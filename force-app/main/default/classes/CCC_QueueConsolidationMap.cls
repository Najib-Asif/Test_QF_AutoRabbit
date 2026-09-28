/*------------------------------------------------------------
   Company:        Salesforce
   Description:    Given Id of oldQueue, return the Id of consolidated/new Queue.
   Test Class:     CCC_QueueConsolidationMap_Test

   History
   Date            Author                  Comments
   -------------------------------------------------------------
    11-03-2021      Salesforce              Initial Version
   -------------------------------------------------------------*/

public without sharing class CCC_QueueConsolidationMap {

	Static Map<String, String> oldQueueIdToNewQueueDevName = new Map<String, String> ();
	Static Map<String, Id> queueDevNameToQueueId = new Map<String, Id>();

	//Get Metadata Settings by CCC_R1_OldtoNewQueueMap__mdt and Case Queue Ids.
	Static {
		for (CCC_R1_OldtoNewQueueMap__mdt eachMapItem : [SELECT CCC_R1_Old_Queue_Id__c, CCC_R1_New_Queue_DevName__c
		                                                 FROM CCC_R1_OldtoNewQueueMap__mdt]) {
			oldQueueIdToNewQueueDevName.put(eachMapItem.CCC_R1_Old_Queue_Id__c,eachMapItem.CCC_R1_New_Queue_DevName__c);
		}

		for(QueueSobject queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where
		                            SobjectType ='Case']) {
			queueDevNameToQueueId.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
		}
	}

	/*--------------------------------------------------------------------------------------
	   Method Name:        getNewQueueId
	   Description:        Method to get Id of New Queue from Id of oldQueue
	   Parameter:          String  oldQueueId
	   --------------------------------------------------------------------------------------*/
	public static Id getNewQueueId(String oldQueueId) {

		if(oldQueueIdToNewQueueDevName.containsKey(oldQueueId)  && queueDevNameToQueueId.containsKey(oldQueueIdToNewQueueDevName.get(oldQueueId)) ) {
			return queueDevNameToQueueId.get(oldQueueIdToNewQueueDevName.get(oldQueueId));
		}
		return null;

	}

}