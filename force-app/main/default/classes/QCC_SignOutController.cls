/*----------------------------------------------------------------------------------------------------------------------
 ************************************************************************************************
    History
 ************************************************************************************************
    13-Mar-2021	     Venkat A				   Consolidation of Queues (User Story: QSFR-23)
	07-Jul-2021		 Gnanavelu T			   CRM-4804 - Updated the class to make it work for CCC Refund Recordtype

   -----------------------------------------------------------------------------------------------------------------------*/
public class QCC_SignOutController {
    private static final Id RTIDVOICE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('CCC_Voice_RecordTypeDevName')).getRecordTypeId();
    
	@AuraEnabled
	public static String getBasicInfo(){
		string urler = URL.getOrgDomainURL().toExternalForm();
		User u = [Select id, Name, City,location__c, profileId, profile.Name from User Where id=:UserInfo.getUserId()];

		infoWrapper iw = new infoWrapper();
		iw.baseURL = urler;
		iw.currentUser = u;

		return (JSON.serialize(iw));
	}

	@AuraEnabled
	public static void caseAssignedBack(){
		Try {
			caseQueueInfo();
			caseHotWords();
			User u = [Select id, Name, City, location__c, profileId, profile.Name from User Where id=:UserInfo.getUserId()];
			Set<Id> setOfCCATUser = QCC_UtilityHelper.getListOfCCATUser(new List<Id> {u.Id});

			//if((u.location__c == null || (u.location__c != null && !u.location__c.equalsIgnoreCase('Sydney')))
			//   &&  u.profile.Name.equalsIgnoreCase('Qantas CC Consultant'))
			if(!setOfCCATUser.contains(U.id))
			{
				List<Case> listCase = [Select id, OwnerId, Last_Queue_Owner__c,Priority,
				                       Returned_to_Queue__c,Assign_using_active_assignment_rules__c,
				                       QCC_enableAssignmentRules__c, RecordTypeId, Description, QCC_Combined_Case_Description__c,
				                       Origin, Override_Hotword__c, Status, Category__c, Sub_Category__c, Type, Group__c, Is_Response_Requested__c
				                       FROM Case
				                       WHERE OwnerId=:UserInfo.getUserId() AND Status!='Closed' AND IsClosed = false AND RecordTypeId != :RTIDVOICE ]; //(User Story: QSFR-23) Added Priority // Jira 4960 Updated Status to Closed
				if(listCase.size() == 0) {
					return;
				}

				List<Case> blankLastQueue = new List<Case>();

				List<String> deprecatedQueueList = new List<String> ();
				for (CCC_R1_OldtoNewQueueMap__mdt eachMapItem : [SELECT CCC_R1_Old_Queue_Id__c
				                                                 FROM CCC_R1_OldtoNewQueueMap__mdt]) {
					deprecatedQueueList.add(eachMapItem.CCC_R1_Old_Queue_Id__c);
				}


				for(integer i= 0; i < listCase.size(); i++) {
					Case c = listCase[i];
					if(!String.isBlank(c.Last_Queue_Owner__c)) {

						/* (User Story: QSFR-23) START
						                        String queueName = mapQueueName.get(c.Last_Queue_Owner__c);

						                                                if(queueName.endsWithIgnoreCase('SLA') || queueName.endsWithIgnoreCase('Low')
						 || queueName.endsWithIgnoreCase('Medium')) {
						                                                        queueName = queueName.removeEndIgnoreCase('SLA').removeEndIgnoreCase('Low').removeEndIgnoreCase('Medium') + 'High';
						                                                }

						                        c.OwnerId = mapQueue.get(queueName);

						   (User Story: QSFR-23) END */

						//(User Story: QSFR-23) START
						Id queueId;

						if (deprecatedQueueList.contains(c.Last_Queue_Owner__c)) {
							queueId = CCC_QueueConsolidationMap.getNewQueueId(c.Last_Queue_Owner__c);
						}
						else
							queueId = Id.valueOf(c.Last_Queue_Owner__c);

						c.Priority = 'High';
						c.OwnerId = queueId;
						//(User Story: QSFR-23) END

						//the flag only turn on if the Case is assigned back to the Last Queue
						c.Returned_to_Queue__c = true;
					}else{
						c.QCC_enableAssignmentRules__c = false;
						c.Assign_using_active_assignment_rules__c = true;

						blankLastQueue.add(c);
						listCase.remove(i);
						i--;
					}
				}

				listCase.addAll(assignCaseOwner(blankLastQueue));

				Database.SaveResult[] srList = Database.update(listCase, false);

				for(Database.SaveResult sr : srList) {

					if(sr.isSuccess()) {
						//
					}else{

					}
				}
			}
		} Catch(exception ex){
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());
		}

	}

	public static List<Case> assignCaseOwner(List<Case> lstCase){
		try{
			Map<String, QCCRoutingTable__mdt> mapQCCRouting = new Map<String, QCCRoutingTable__mdt>();

			for(QCCRoutingTable__mdt qccRouting: [Select Id, CaseType__c, Category__c, Group__c, Order__c,
			                                      QUEUE_Name__c, Sub_Category__c from QCCRoutingTable__mdt])
			{
				string category = qccRouting.Category__c == 'none' ? '' : qccRouting.Category__c;
				string subCategory = qccRouting.Sub_Category__c == 'none' ? '' : qccRouting.Sub_Category__c;
				String key = qccRouting.CaseType__c+''+qccRouting.Group__c+''+category+''+subCategory;
				mapQCCRouting.put(key, qccRouting);

			}

			Set<Id> setQCCRectype = qccCaseRecordTypeIds();


			system.debug('mapQueue###########'+mapQueue);
			system.debug('ZZZ mapQCCRouting: '+mapQCCRouting);

			for(Case objCase: lstCase) {
				if(setQCCRectype.contains(objCase.RecordTypeId)) {

					string description = objCase.Description;
					if(!String.isBlank(objCase.QCC_Combined_Case_Description__c)) {
						description = objCase.QCC_Combined_Case_Description__c;

					}
					Id recTypeCCCRefund = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Refund RecType'));
					
					if(objCase.RecordTypeId != recTypeCCCRefund)
					caseDescriptionCheck(description);
					Boolean isHotWord = isDesHasHotword;
					String queueName = hotWordQueueName;

					Case oldCase = Null;
					system.debug('objCase############'+objCase);

					if(objCase.Assign_using_active_assignment_rules__c && objCase.Override_Hotword__c != true )
					{
						String queueSuffix = 'High';


						String category = (objCase.Category__c == Null || objCase.Category__c == '') ? '' : objCase.Category__c;
						String subCategory = (objCase.Sub_Category__c == Null || objCase.Sub_Category__c == '') ? '' : objCase.Sub_Category__c;
						String Prioritykey = objCase.Type+''+objCase.Group__c+''+category+''+subCategory;
						String key = objCase.Type+''+objCase.Group__c;
						system.debug('Prioritykey###########'+Prioritykey);
						system.debug('key###########'+key);
						QCCRoutingTable__mdt routingInfo;

						if(mapQCCRouting.containsKey(Prioritykey)) {
							routingInfo = mapQCCRouting.get(Prioritykey);
						}else if(mapQCCRouting.containsKey(key)) {
							routingInfo = mapQCCRouting.get(key);
						}
						system.debug('routingInfo###########'+routingInfo);
						if(routingInfo != Null) {

							if(!isHotWord) {
								if(objCase.Type.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('Case Type Complaint')) && String.isNotBlank(objCase.Type)
								   && objCase.Group__c.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('Case Group Lounges')) && String.isNotBlank(objCase.Group__c))
								{
									queueName = CustomSettingsUtilities.getConfigDataMap('QCC Lounges Queue');
								}else if(objCase.Type.equalsIgnoreCase(CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type')) && String.isNotBlank(objCase.Type)) {
									queueName =CustomSettingsUtilities.getConfigDataMap('QCC Insurance Queue');
								}else {
									queueName = routingInfo.QUEUE_Name__c;
								}
							}

							if(isHotWord) {
								if(oldCase == Null && objCase.Status == CustomSettingsUtilities.getConfigDataMap('CaseStatusClosed') &&
								   objCase.Is_Response_Requested__c == CustomSettingsUtilities.getConfigDataMap('QCC_ResponseRequired'))
								{
									objCase.Status = CustomSettingsUtilities.getConfigDataMap('QCC_CaseStatusReceived');
								}
							}


							//queueName = queueName+'_'+queueSuffix;(User Story: QSFR-23) Commented adding Suffix to Queue.
							objCase.Priority = queueSuffix;// (User Story: QSFR-23)
							String slaQueueName = queueName+'_SLA';
							system.debug('ZZZqueueName###########'+queueName);
							if(mapQueue.containsKey(queueName)) {
								objCase.OwnerId = mapQueue.get(queueName);
							}
						}
						objCase.Assign_using_active_assignment_rules__c = false;
						objCase.QCC_enableAssignmentRules__c = true;
					}else if(objCase.Assign_using_active_assignment_rules__c && objCase.Override_Hotword__c ) {
						objCase.Override_Hotword__c = false;
						//objCase.addError(CustomSettingsUtilities.getConfigDataMap('QCC_RoutingConflictMSG'));
					}

					String ownerVal = objCase.OwnerId;
					if(ownerVal.startsWith('00G') && objCase.RecordTypeId != recTypeCCCRefund) {
						objCase.QCC_Routing_Invoked__c = true;
						String slaQueueName = mapQueueName.get(objCase.OwnerId);
						slaQueueName = slaQueueName.substring(0, slaQueueName.lastIndexOf('_'))+'_SLA';
						objCase.SLA_Queue__c = mapQueue.get(slaQueueName);
					}
				}

			}

		}catch(Exception ex) {
			system.debug('ex###############'+ex);
		}

		return lstCase;
	}

	//Lora Mae Dapulang || GRAPHITE-1152: Case Status -Enhancement
	@AuraEnabled
	public static List<Case> checkForInProgressCases(){
		List<Case> caseLists = new List<Case>();
		User u = [Select id, Name, City, location__c, profileId, profile.Name from User Where id=:UserInfo.getUserId()];
		Set<Id> setOfCCATUser = QCC_UtilityHelper.getListOfCCATUser(new List<Id> {u.Id});
		if(!setOfCCATUser.contains(U.id)) { // ONLY FOR NON CCAT USER
			system.debug('###checkForInProgressCases');
			caseLists = [SELECT Id, OwnerId, CaseNumber, Subject, Status FROM Case WHERE OwnerId =: UserInfo.getUserId() AND Status = 'In Progress'];
			system.debug('###caseLists: ' + caseLists);
		}
		return caseLists;
	}

	public static Map<String, Id> mapQueue;// = new Map<String, Id>();
	public static Map<Id, String> mapQueueName;// = new Map<Id, String>();
	public static Map<String, String> mapHotWordQueue;// = new Map<Id, String>();
	public static String hotWordQueueName;
	public static Boolean isDesHasHotword = false;

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

	/*--------------------------------------------------------------------------------------
	   Method Name:        caseHotWords
	   Description:        Method to Create a map of Queue to avoid SOQL
	   Parameter:
	   --------------------------------------------------------------------------------------*/
	public static void caseHotWords(){
		if(mapHotWordQueue == Null ) {
			mapHotWordQueue = new Map<String, String>();
			for(QCC_HotWord__mdt qccHotWord: [Select DeveloperName, Hot_Word__c, Order__c from QCC_HotWord__mdt order by Order__c]) {
				mapHotWordQueue.put(qccHotWord.DeveloperName, qccHotWord.Hot_Word__c);
				String allHotWord = mapHotWordQueue != Null && mapHotWordQueue.containsKey('All') ? mapHotWordQueue.get('All')+','+qccHotWord.Hot_Word__c : qccHotWord.Hot_Word__c;
				mapHotWordQueue.put('All', allHotWord);
			}
		}
	}

	/*--------------------------------------------------------------------------------------
	   Method Name:        caseDescriptionCheck
	   Description:        Method to get the hot word queue name
	   Parameter:
	   --------------------------------------------------------------------------------------*/
	public static void caseDescriptionCheck(String caseDescription){
		Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
		Matcher matcher = nonAlphanumeric.matcher(caseDescription);
		String description = ' '+matcher.replaceAll(' ')+' ';
		isDesHasHotword = false;
		hotWordQueueName = '';
		for(String hotWordQueue: mapHotWordQueue.keyset()) {
			if(hotWordQueue != 'All') {
				List<String> lstHotword = mapHotWordQueue.get(hotWordQueue).split(',');
				for(String hotWord: lstHotword) {
					String spaceHot = ' '+hotWord.trim()+' ';
					system.debug('description###########'+description);
					system.debug('(spaceHot).replace()###########'+(spaceHot).replace('"',''));
					if(description.containsIgnoreCase((spaceHot).replace('"',''))) {
						isDesHasHotword = true;
						hotWordQueueName = hotWordQueue;
						break;
					}
				}
				if(isDesHasHotword) {
					break;
				}
			}
		}
	}

	/*--------------------------------------------------------------------------------------
	   Method Name:        qccCaseRecordTypeIds
	   Description:        Fetch QCC Case RecordTypes
	   Parameter:
	   --------------------------------------------------------------------------------------*/
	public static Set<Id> qccCaseRecordTypeIds(){
		Set<Id> setQCCRectype = new Set<Id>();
		Id recTypeQCCCompliment = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Compliment RecType'));
		setQCCRectype.add(recTypeQCCCompliment);
		Id recTypeCCCBaggage = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case Baggage RecType'));
		setQCCRectype.add(recTypeCCCBaggage);
		Id recTypeCCCComplaint = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType'));
		setQCCRectype.add(recTypeCCCComplaint);
		Id recTypeCCCInsurance = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Insurance Letter RecType'));
		setQCCRectype.add(recTypeCCCInsurance);
		Id recTypeCCCMedical = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Medical RecType'));
		setQCCRectype.add(recTypeCCCMedical);
		Id recTypeCCCQuery = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Query RecType'));
		setQCCRectype.add(recTypeCCCQuery);
		Id recTypeCCCFAR = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Further Action RecType'));
		setQCCRectype.add(recTypeCCCFAR);
		Id recTypeCCCEvent = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Event RecType'));
		setQCCRectype.add(recTypeCCCEvent);
		Id recTypeCCOTSR = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC On The Spot Recovery RecType'));
		setQCCRectype.add(recTypeCCOTSR);
		//Added as part of th Jira CRM-4804
		Id recTypeCCCRefund = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Refund RecType'));
        setQCCRectype.add(recTypeCCCRefund);

		//Lora Mae Dapulang || GRAPHITE-1152: Case Status -Enhancement
		Id recTypeEliteProcess = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Elite Process RecType'));
		setQCCRectype.add(recTypeEliteProcess);
		Id recTypeAssistance = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Assistance RecType'));
		setQCCRectype.add(recTypeAssistance);
		Id recTypeDisruption = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Disruption RecType'));
		setQCCRectype.add(recTypeDisruption);
		Id recTypeSpecificNeeds = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Specific Needs RecType'));
		setQCCRectype.add(recTypeSpecificNeeds);
		return setQCCRectype;
	}

	public class infoWrapper {
		public String baseURL {get; set;}
		public User currentUser {get; set;}
	}
}