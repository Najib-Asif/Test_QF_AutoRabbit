/*********************************************************************************
   Name         : QCC_EscalateCaseToQueue
   Created By   : Nicole Abesamis
   Company Name : Accenture
   Project      : Pre-Travel, GRAPHITE
   Created Date : 10 February 2020
   Usages       : This will reassign the escalated cases to its designated queue.
                  This is called by PB QCC_ScheduleCaseEmailReminder.
************************************************************************************************
    History
************************************************************************************************
    13-Mar-2021	     Venkat A				   Consolidation of Queues (User Story: QSFR-23)
*********************************************************************************/
public class QCC_EscalateCaseToQueue {

	public static Map<String, Id> mapQueue;// = new Map<String, Id>();
	public static Map<Id, String> mapQueueName;// = new Map<Id, String>();

	@InvocableMethod
	public static void EscalateCaseWithWaitingStatus(List<Case> caseList){
		try{
			System.debug('caseList >>>>> ' + caseList);
			Set<String> vipFFTierSet = new Set<String>();
			vipFFTierSet.addAll(Label.QCC_CaseVIP.split(';'));
			caseQueueInfo();

			List<Id> caseIds = new List<Id>();
			for(Case cse : caseList) {
				caseIds.add(cse.id);
			}

			Map<String, Id> mapQueue = new Map<String, Id>();
			for(QueueSobject queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where SobjectType ='Case']) {
				mapQueue.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
			}

			// Get Case Contact Information
			Map<Id,Case> caseContactMap = new Map<Id,Case>();
			for(Case objCase: [SELECT Id,FF_Tier__c,Contact.Frequent_Flyer_Tier__c,Contact.SSU__c,RecordType.DeveloperName, Status,Last_Queue_Owner__c FROM Case WHERE Id =: caseIds]) {
				caseContactMap.put(objCase.id,objCase);
			}


			//Get List of owner Ids
			List<Id> ownerIds = new List<Id>();
			for(Case objCase: caseList) {
				ownerIds.add(objCase.OwnerId);
			}
			Set<Id> setOfCCATUser = QCC_UtilityHelper.getListOfCCATUser(ownerIds);

			//Get user list where Id IN ownerIds
			/*List<User> userList = [SELECT Id, Location__c, UserRole.Name FROM User WHERE Id IN: ownerIds];
			   Map<Id, User> userMap = new Map<Id, User>();
			   for(User userRecord : userList) {
			    userMap.put(userRecord.Id, userRecord);
			   }*/

			List<String> deprecatedQueueList = new List<String> ();
			for (CCC_R1_OldtoNewQueueMap__mdt eachMapItem : [SELECT CCC_R1_Old_Queue_Id__c
			                                                 FROM CCC_R1_OldtoNewQueueMap__mdt]) {
				deprecatedQueueList.add(eachMapItem.CCC_R1_Old_Queue_Id__c);
			}

			List<Case> caseToUpdateList = new List<Case>();
			for(Case objCase: caseList) {
				//To check if user is CCAT Agent
				Boolean isCCAT = false;

				//GRAHITE-GRAPHITE-1980 : New way of checking if user is CCAT.
				if(setOfCCATUser.contains(objCase.OwnerId)) {
					isCCAT = true;
				}
				/*if(userMap.containsKey(objCase.OwnerId)){
				    isCCAT = QCC_UtilityHelper.isCCATAgent(userMap.get(objCase.OwnerId));
				   }*/

				if(!isCCAT) {
					/* Deep Clone current Case record because it prevents us from updating it due to the record is on After insert stage.
					   Newly cloned Case will remain the same record because we Deepclone(preserved Record Id) but allow us to update it.*/
					Case cloneCase = objCase.clone(true,true,true,true);
					String currentFFTier = ( objCase.FF_Tier__c != NULL ? objCase.FF_Tier__c : caseContactMap.get(objCase.id).Contact.Frequent_Flyer_Tier__c );
					if(caseContactMap.get(objCase.id).RecordType.DeveloperName == 'QCC_Specific_Needs') {
						cloneCase.OwnerId = mapQueue.get('QCC_Specific_Needs_Internal_Follow_Up');
					}
                    
                    else if( caseContactMap.get(objCase.id).Contact.SSU__c == true) {
						cloneCase.Priority = 'Internal Escalation';
						cloneCase.OwnerId = mapQueue.get('QCC_VIP_Internal_Followup_Escalation');
                    }
                    //CRM-10272
                    else if(vipFFTierSet.contains(currentFFTier)){
                            cloneCase.OwnerId = caseContactMap.get(objCase.id).Last_Queue_Owner__c;
                          cloneCase.Priority = 'Internal Escalation';
                    }
                
                    else{

						//(User Story: QSFR-23) START
						Id queueId;

						cloneCase.Priority = 'Internal Escalation';
						if(  String.isBlank(objCase.Last_Queue_Owner__c) ) {
							queueId = CCC_QueueConsolidationMap.getNewQueueId('NULL');
							System.debug('queueId >>>' + queueId);
						}
						else if (deprecatedQueueList.contains(objCase.Last_Queue_Owner__c)) {
							queueId = CCC_QueueConsolidationMap.getNewQueueId(objCase.Last_Queue_Owner__c);
						}
						else
							queueId = Id.valueOf(objCase.Last_Queue_Owner__c);
						cloneCase.OwnerId = queueId;
					}
					caseToUpdateList.add(cloneCase);
				}
				else {
					objCase.Priority = 'Internal Escalation';//(User Story: QSFR-23)
				}

				if(caseToUpdateList.size() > 0) {
					update caseToUpdateList;
				}
			}
		}
		catch(Exception ex) {
			Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Reassigning Case Owner', 'QCC_EscalateCaseToQueue', 'EscalateCaseWithWaitingStatus', '', '', false, '', ex, '');
			QCC_LogUtilityHelper.createLogRecord(logRecord);

		}
	}

	/*--------------------------------------------------------------------------------------
	   Method Name:        caseQueueInfo
	   Description:        Method to Create a map of Queue to avoid SOQL
	   Parameter:
	   --------------------------------------------------------------------------------------*/
	public static void caseQueueInfo(){
		if(mapQueue == Null || mapQueueName == Null) {
			mapQueue = new Map<String, Id>();
			mapQueueName = new Map<Id, String>();
			for(QueueSobject queueObj: [Select SobjectType, Id, QueueId, Queue.DeveloperName from QueueSobject where
			                            SobjectType ='Case']) {
				mapQueue.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
				mapQueueName.put(queueObj.QueueId, queueObj.Queue.DeveloperName);
			}
		}
	}
}