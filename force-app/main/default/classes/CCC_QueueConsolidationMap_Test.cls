/*------------------------------------------------------------
   Author:         Venkat Amiya
   Company:        Salesforce
   Description:    Test Class for CCC_QueueConsolidationMap.

   History
   Date Author Comments
   -------------------------------------------------------------
   10-29-2019      Venkat Amiya Initial Release
   -------------------------------------------------------------*/
@isTest
private class CCC_QueueConsolidationMap_Test {

	Static Map<String, String> oldQueueIdToNewQueueDevName = new Map<String, String> ();
	Static Map<String, Id> queueDevNameToQueueId = new Map<String, Id>();
	Static Map<Id, String>  queueIdToQueueDevName  = new Map<Id, String>();

	//Get Metadata Settings by CCC_R1_OldtoNewQueueMap__mdt and Case Queue Ids.
	Static {
		for (CCC_R1_OldtoNewQueueMap__mdt eachMapItem : [SELECT CCC_R1_Old_Queue_Id__c, CCC_R1_New_Queue_DevName__c
		                                                 FROM CCC_R1_OldtoNewQueueMap__mdt]) {
			oldQueueIdToNewQueueDevName.put(eachMapItem.CCC_R1_Old_Queue_Id__c,eachMapItem.CCC_R1_New_Queue_DevName__c);
		}

		for(QueueSobject queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where
		                            SobjectType ='Case']) {
			queueDevNameToQueueId.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
			queueIdToQueueDevName.put(queueObj.QueueId,queueObj.Queue.DeveloperName);
		}
	}

	@isTest
	static void getNewQueueIdSuccess(){
		Id newQueueId;
		String oldQueueId;
		Test.startTest();
		if(!oldQueueIdToNewQueueDevName.isEmpty()) {

			oldQueueId = (new List<String> (oldQueueIdToNewQueueDevName.keySet()) ) [0];
			if (queueDevNameToQueueId.containsKey(oldQueueIdToNewQueueDevName.get(oldQueueId))) {
				newQueueId = CCC_QueueConsolidationMap.getNewQueueId (oldQueueId);
			}
		}
		Test.stopTest();

		System.assertEquals(newQueueId, queueDevNameToQueueId.get(oldQueueIdToNewQueueDevName.get(oldQueueId)), 'New Queue Id not found');

	}

}