/*-----------------------------------------------------------------------
   File name:      QCC_ReassignToQueueController.cls
   Author:         Son Vu
   Company:        Capgemini
   Description:    This class is created as Controller for QCC_ReassignToQueue Component.
   Test Class:
   Created Date :  06/03/2018
   <Date>      <Authors Name>     <Brief Description of Change>
 ************************************************************************************************
   History
 ************************************************************************************************
   06-Mar-2018    Son Vu               Initial version
   31-Mar-2020    Venkat Amiya         Consolidation of Queues (User Story: QSFR-23)
   ----------------------*/
public class QCC_ReassignToQueueController {
	/*---------------------------------------------------------------------------------------------------------------
	   Method Name:        getlistQueues
	   Description:        Retrieves list of Queue that have trimmed Priority
	   Return:             List<String>
	   ---------------------------------------------------------------------------------------------------------------*/
	@AuraEnabled
	public static List<String> getlistQueues(){
		List<String> listOption = new list<String>();
		try{
			//List<Group> listQueue = [Select id, name, DeveloperName from Group where Type='Queue' AND Name like 'CCC%' AND Name != 'CCC Events Assigned' Order By Name ASC];
			List<Group> listQueue = [Select id, name, DeveloperName from Group where Type='Queue' AND Name like 'CCC%' AND ID IN (SELECT QueueId FROM QueueSobject where SobjectType='Case') Order By Name ASC];

			//GRAPHITE-1954
			List<String> listQueueLabel = Label.QCC_AssignToQueue.split(';');
			List<Group> listQueueLabelQuery = [Select id, name, DeveloperName from Group where Type='Queue' AND Name =: listQueueLabel Order By Name ASC];

			listQueue.addAll(listQueueLabelQuery);

			//(User Story: QSFR-23)
			Set<Id> deprecatedQueueIDSet = new Set<Id> ();
			for (CCC_R1_OldtoNewQueueMap__mdt eachMapItem : [SELECT CCC_R1_Old_Queue_Id__c
			                                                 FROM CCC_R1_OldtoNewQueueMap__mdt]) {
				if(eachMapItem.CCC_R1_Old_Queue_Id__c != 'NULL') {
					deprecatedQueueIDSet.add(eachMapItem.CCC_R1_Old_Queue_Id__c);
				}
			}

			Set<String> setName = new Set<String>();
			for(Group g : listQueue) {
				//filter out Recovery Approval Queue Or Pending Queue
				if(!String.valueOf(g.Name).endsWith('Recovery Approval Queue') && !String.valueOf(g.Name).endsWith('Pending Queue') && !deprecatedQueueIDSet.contains(g.Id)) { //(User Story: QSFR-23)
					//remove all the trailing Priority
					String trimmedName = g.Name.removeEndIgnoreCase('SLA').removeEndIgnoreCase('Low').removeEndIgnoreCase('Medium').removeEndIgnoreCase('High');
					trimmedName = trimmedName.removeEndIgnoreCase(' - ').removeEndIgnoreCase('-').removeEndIgnoreCase(' ');

					if(!setName.contains(trimmedName)) {
						listOption.add(trimmedName);
					}
					setName.add(trimmedName);
				}

			}
		}catch(exception ex) {
			//TO-DO
		}
		return listOption;
	}

	/*----------------------------------------------------------------------------------------------
	   Method Name:        reassignToQueue
	   Description:        Reassign Case to the Correct Queue
	   Parameter:          caseId, queueName
	   Return:             String
	   ----------------------------------------------------------------------------------------------*/
	@AuraEnabled
	public static String reassignToQueue(String caseId, String queueName){
		try{
			Boolean valueChanged = false;
			Case objCase = [Select id, ownerId,Assign_using_active_assignment_rules__c,IsClosed,Due_Date__c,
			                Cabin_Class__c,Frequent_Flyer_Tier__c,SLA_Queue__c,QCC_Routing_Invoked__c
			                FROM Case where Id=:caseId limit 1];

			//exclude Priority - start
			Map<String, QantasConfigData__c> mapExcludePriority = new Map<String, QantasConfigData__c>();
			for(QantasConfigData__c qcd : [Select ID, Name, Config_Value__c
			                               from QantasConfigData__c
			                               WHERE Name Like 'Exclude Priority%']) {
				mapExcludePriority.put(qcd.Name, qcd);
			}
			//exclude Priority - end

			List<String> listCaseId = new List<String>();
			listCaseId.add(objCase.Id);

			Map<String, String> mapCasePriority = QCC_ReassignToQueueController.calculateCasesPriority(listCaseId);

			String queueSuffix = mapCasePriority.get(objCase.id);
			if(queueSuffix == null)
				return '';

			queueName += '%';

			//loop through posible Queue to get the matched Priority Queue
			//the Order of Group in itenary: High->Low->Medium->SLA
			for(Group g :  [SELECT DeveloperName,Id,Name,Type FROM Group WHERE Type = 'Queue' AND Name LIKE :queueName Order By Name]) {
				//exclude Priority - start
				String queueDevName = g.DeveloperName.removeEndIgnoreCase('SLA').removeEndIgnoreCase('Low').removeEndIgnoreCase('Medium').removeEndIgnoreCase('High').removeEndIgnoreCase('_');
				if(mapExcludePriority.containsKey('Exclude Priority '+queueDevName)) {
					queueSuffix = mapExcludePriority.get('Exclude Priority '+queueDevName).Config_Value__c;
				}
				//exclude Priority - End
				if(String.isNotBlank(queueSuffix) && String.ValueOf(g.DeveloperName).endsWithIgnoreCase(queueSuffix) && mapExcludePriority.containsKey('Exclude Priority '+queueDevName) ) { //(User Story: QSFR-23)
					objCase.OwnerId = g.Id;
					queueName = g.Name;
					valueChanged = true;
				}

				//Set up SLA_Queue gone last after the New OwnerId was Updated
				//assign SLA queue to Case, in case the Due day will be passed.
				String ownerVal = objCase.OwnerId;
				if(ownerVal.startsWith('00G') && String.ValueOf(g.DeveloperName).endsWithIgnoreCase('SLA')) {
					objCase.QCC_Routing_Invoked__c = true;
					objCase.SLA_Queue__c = g.Id;
				}
			}

			// Can't find Queue with priority, start again without priority. No need to assign to SLA Queue
			if (queueName.endsWithIgnoreCase('%')) {
				queueName = queueName.substringBefore('%');
				for(Group g :  [SELECT DeveloperName,Id,Name,Type FROM Group WHERE Type = 'Queue' AND Name = :queueName Order By Name]) { //(User Story: QSFR-23)
					//if (String.ValueOf(g.Name) == queueName) { (User Story: QSFR-23)
					objCase.OwnerId = g.Id;
					queueName = g.Name;
					valueChanged = true;
					//} (User Story: QSFR-23)
				}
			}
			

			//check this field needed?
			objCase.Assign_using_active_assignment_rules__c = false;

			update objCase;


			if(valueChanged) {
				return queueName;
			}

		}catch(Exception ex) {
			system.debug('ex###############'+ex);
		}
		return '';
	}

	/*----------------------------------------------------------------------------------------------
	   Method Name:        calculateCasesPriority
	   Description:        Calculate the Priority of Case bases on Cabin Class and Frequent Flyer Tier
	   Parameter:          listCaseId
	   Return:             Map<String, String> key: CaseID - Value: Priority
	   ----------------------------------------------------------------------------------------------*/
	public static Map<String, String> calculateCasesPriority(List<String> listCaseId){
		Map<String, String> mapCasePriority = new Map<String,String>();
		try{
			List<Case> listCase = [Select id, ownerId,Assign_using_active_assignment_rules__c,Due_Date__c,IsClosed,
			                       Cabin_Class__c,Frequent_Flyer_Tier__c,SLA_Queue__c,QCC_Routing_Invoked__c
			                       FROM Case where Id IN :listCaseId];

			Map<String, QCCRoutingPriority__mdt> mapQCCPriority = new Map<String, QCCRoutingPriority__mdt>();
			for(QCCRoutingPriority__mdt qccPriority: [Select Id, Cabin__c, Priority__c,  Tier__c from QCCRoutingPriority__mdt])
			{
				String key = qccPriority.Cabin__c+''+qccPriority.Tier__c;
				mapQCCPriority.put(key, qccPriority);
			}

			for(Case objCase : [Select id, ownerId,Assign_using_active_assignment_rules__c,Due_Date__c,IsClosed,
			                    Cabin_Class__c,Frequent_Flyer_Tier__c,SLA_Queue__c,QCC_Routing_Invoked__c
			                    FROM Case where Id IN :listCaseId]) {
				String queueSuffix = '';
				//process straight to SLA priority if the Case due day has passed.
				if(!objCase.isClosed && objCase.Due_Date__c!=null && objCase.Due_Date__c < System.today()) {
					queueSuffix = 'SLA';
				}else{
					if(objCase.Cabin_Class__c != Null  && objCase.Frequent_Flyer_Tier__c != Null )
					{
						string key = objCase.Cabin_Class__c+''+objCase.Frequent_Flyer_Tier__c;
						queueSuffix = mapQCCPriority.get(key).Priority__c;
					}else{
						queueSuffix = 'Low';
					}
				}

				mapCasePriority.put(objCase.Id, queueSuffix);
			}


		}catch(Exception ex) {
			system.debug('ex###############'+ex);

		}
		return mapCasePriority;
	}
}