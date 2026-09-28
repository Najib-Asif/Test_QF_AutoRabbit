public without sharing class QCC_FlowOwnership {

	/*----------------------------------------------------------------------------------------------
	   Method Name:        changeCaseOnwerToCurrentUser
	   Description:        Return List of Cases with updated owner details and with Status of WIP .
	   Parameter:          List of case IDs
	   ----------------------------------------------------------------------------------------------*/
	@InvocableMethod(label='Set Case Owner to Current user' description='Changes Case Owner to Current User')
	public static List <Case> changeCaseOnwerToCurrentUser(List<Id> caseId){

		List <Id> previousOwner = new List <Id>();
		List <Case> caseList = new List <Case>();

		if (caseId.size() > 0) {
			caseList = [Select Id, OwnerID, Status, Last_Queue_Owner__c from Case where Id in :caseId ];
			for(Case caseIdItem : caseList) {
				if(string.valueOf(caseIdItem.OwnerID).startsWith('00G')) {
					caseIdItem.Last_Queue_Owner__c = caseIdItem.OwnerID;
					caseIdItem.OwnerID = userInfo.getUserId();
				}

				caseIdItem.Status = 'In Progress';
			}
			update caseList;
		}

		System.debug('#### QCC_FlowOwnership.changeCaseOnwerToCurrentUser  case details : '+ caseList);

		return caseList;
	}

}