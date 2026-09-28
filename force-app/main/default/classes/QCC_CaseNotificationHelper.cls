public class QCC_CaseNotificationHelper{

	/*--------------------------------------------------------------------------------------       
    Method Name:        getAccountContactRelations
    Description:        get list of ACR from list of Contact and Account
    Parameter:          List of ContactId, AccocuntId
    --------------------------------------------------------------------------------------*/
	public static List<AccountContactRelation> getAccountContactRelations(List<String> lstConId, String accountId){
		
		//create list of Role and Tier needed
		List<String> lstRole = new List<String>();
		List<String> lstTier = new List<String>();
		for(QCC_Case_Notification_Setting__mdt mdt : [select id,Active__c, Type__c, MasterLabel 
													from QCC_Case_Notification_Setting__mdt
													where Active__c = true]){
			if(mdt.Type__c == 'Frequent Flyer Tier'){
				lstTier.add(mdt.MasterLabel);
			}
			if(mdt.Type__c == 'Role'){
				lstRole.add(mdt.MasterLabel);
			}
		}

		// SQL string build for query AccountContactRelation
		String sqlSelectACR = '';
		// SQL condition
		String sqlWhere = '';

		sqlSelectACR += 'SELECT id,' 
		    + 'contactid,'
		    + 'contact.Name,'
		    + 'contact.Frequent_Flyer_Tier__c,'
		    + 'accountId,'
		    + 'account.ownerId,'
		    + 'account.Name,'
		    + 'Job_Role__c '
		    + 'FROM AccountContactRelation ';

		// Contact condition
		if(!lstConId.isEmpty()){
			sqlWhere += ' AND contactId IN:lstConId ';
		}

	 	// Account condition
	 	if(String.isNotBlank(accountId)){
			sqlWhere += ' AND AccountId = :accountId ';
		}

		// Condition active = true
		sqlWhere += ' AND IsActive = true ';
		// Job Role condition
		String sqlRoleCondition = '';
		for(String myRole : lstRole){
		    sqlRoleCondition += ' OR ( Job_Role__c LIKE \'%' + myRole + '%\') ';
		}
		sqlRoleCondition += ' OR Contact.Frequent_Flyer_Tier__c IN :lstTier ';
		
		if(String.isNotBlank(sqlRoleCondition)){
			sqlRoleCondition = sqlRoleCondition.replaceFirst('OR', '');
			sqlWhere += ' AND (' + sqlRoleCondition + ')';
		}

		// filter RecordType != Persion Account
		try{
			String recordTypeId = GenericUtils.getObjectRecordTypeId('Account', 'Person Account');
			if(String.isNotBlank(recordTypeId)){
				sqlWhere += ' AND account.RecordTypeId != \'' + recordTypeId + '\' ';
			}
		} catch(Exception ex){
			System.debug(LoggingLevel.ERROR, ex.getMessage());
        	System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        	CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CaseNofiticationHelper', 'QCC_CaseNofiticationHelper', 'postCaseNotification', String.valueOf(''), String.valueOf(''),false,'', ex);
		}
		

		if(String.isNotBlank(sqlWhere)){
		    sqlWhere = sqlWhere.replaceFirst('AND', 'WHERE');
		    sqlSelectACR += sqlWhere;
		}

		System.debug('==sqlSelectACR==' + sqlSelectACR);
		return Database.query(sqlSelectACR);
	}

	/*--------------------------------------------------------------------------------------       
    Method Name:        postCaseNotification
    Description:        Prepare list of Account to put Chatter
    Parameter:          
    --------------------------------------------------------------------------------------*/
	public static void postCaseNotification(List<Case> lstCaseId){
		try{
			//get list of Contact
			List<String> lstConId = new List<String>();
			Map<String, String> mapCase_Con = new Map<String, String>();
			for(Case cs : lstCaseId){
				if(!String.isBlank(cs.contactId)){
					lstConId.add(cs.contactId);
					mapCase_Con.put(cs.id, cs.contactId);
				}
			}

			
			if(lstConId.size() > 0 ){

				// List AccountContactRelation return
				List<AccountContactRelation> lstACR = getAccountContactRelations(lstConId,'');

				Map<String, List<String>> lstCon_Acc = new Map<String, List<String>>();
				Map<String, String> lstCon_AccName = new Map<String, String>();
				Map<String, String> mapAcc_User = new Map<String, String>();
				Map<String, String> mapConName = new Map<String, String>();

				System.debug('lstACR size: '+lstACR.size());
				for(AccountContactRelation acr : lstACR){
					if(lstCon_Acc.containsKey(acr.contactId)){
						lstCon_Acc.get(acr.contactId).add(acr.accountId);
						System.debug(lstCon_AccName.get(acr.contactId));
						System.debug(acr.account.Name);
						lstCon_AccName.put(acr.contactId, lstCon_AccName.get(acr.contactId) + ', '+acr.account.Name  );
					}else{
						List<String> lstAcc = new List<String>();
						lstAcc.add(acr.accountId);
						lstCon_Acc.put(acr.contactId, lstAcc);
						lstCon_AccName.put(acr.contactId, acr.account.Name  );
					}
					mapConName.put(acr.contactid, acr.contact.Name);
					mapAcc_User.put(acr.accountId, acr.account.ownerId);
				}
				System.debug('mapConName: '+mapConName);
				System.debug('mapAcc_User: '+mapAcc_User);

				//loop through Case to post Chatter
				for(Case cs : lstCaseId){
					if(lstCon_Acc.containsKey(cs.contactId)){
						List<String> lstAccId = lstCon_Acc.get(cs.contactId);
						String accName = lstCon_AccName.get(cs.contactId);
						String contactId = mapCase_Con.get(cs.Id);
						String contactName = mapConName.get(cs.contactId);
						String caseNumber = cs.caseNumber;
						String contactGroup = GenericUtils.getCaseContactGroup(cs.recordtypeId);
						Boolean isSensitive = cs.Sensitive__c;
						postToChatterSensitiveCase( lstAccId, accName, caseNumber, contactName, contactGroup, isSensitive, mapAcc_User);
					}
				}

			}

			}catch(exception ex){
				System.debug(LoggingLevel.ERROR, ex.getMessage());
	            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
	            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CaseNofiticationHelper', 'QCC_CaseNofiticationHelper', 'postCaseNotification', String.valueOf(''), String.valueOf(''),false,'', ex);
			}
		
	}

	/*--------------------------------------------------------------------------------------       
    Method Name:        postCaseNotification
    Description:        Prepare list of Account to put Chatter
    Parameter:          
    --------------------------------------------------------------------------------------*/
	public static void postCaseNotification(Set<String> lstCaseId){
		//select call Sensitive Case
		postCaseNotification([select id, contactId, CaseNumber, contact.Name, Sensitive__c, recordTypeId 
								from Case 
								where id IN :lstCaseId AND contactId != null]);
	}

	/*--------------------------------------------------------------------------------------       
    Method Name:        postToChatterSensitiveCase
    Description:        Post to Account Chatter with Mention
    Parameter:          
    --------------------------------------------------------------------------------------*/
	public static void postToChatterSensitiveCase(List<String> lstAccId, String accName, String caseNumber, String contactName, String contactGroup, Boolean isSensitive, Map<String, String> mapAccount_User){
		try{
			String sample = Label.QCC_Sensitive_Case_Notification;
			if(!isSensitive){
				sample = Label.QCC_Case_Notification;
			}
			sample = sample.replace('[CASE_NUMBER]', caseNumber);
			sample = sample.replace('[CONTACT_NAME]', contactName);
			sample = sample.replace('[ACCOUNT_NAME]', accName);
			sample = sample.replace('[CASE_GROUP]', contactGroup);
            sample = sample.removeEndIgnoreCase('Contact ');
			ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
			
			ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
			ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

			messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
			textSegmentInput.text = ' '+sample;
			messageBodyInput.messageSegments.add(textSegmentInput);

			feedItemInput.body = messageBodyInput;
			feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

			for(String accountId : lstAccId){

				// add the mention
				if(mapAccount_User.containsKey(accountId)){
					ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
					mentionSegmentInput.id = mapAccount_User.get(accountId);
					if(messageBodyInput.messageSegments.size() > 1){
						messageBodyInput.messageSegments[0] = mentionSegmentInput;
					} else {
						messageBodyInput.messageSegments.add(0,mentionSegmentInput);
					}
				}

				// Use a record ID for the subject ID.
				feedItemInput.subjectId = accountId;
				if(Test.isRunningTest()){
					System.debug(sample);
				}else{
					ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
				}
				
			}
		}catch(exception ex){
			System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_CaseNofiticationHelper', 'QCC_CaseNofiticationHelper', 'postToChatterSensitiveCase', String.valueOf(''), String.valueOf(''),false,'', ex);
		}
		
	}

}