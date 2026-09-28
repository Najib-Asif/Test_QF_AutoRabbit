/**********************************************************************************************************************
History
----------------------------------------------
VERSION  AUTHOR            DATE              DETAIL
1.0   Tanya Kumari    15/05/2026      CRM-10522 RBAC for System Admin
/**********************************************************************************************************************/ 

public class ContentDocumentTriggerHelper {

	public static void eligiblityCheckOnContentDocDel(Map<Id, ContentDocument> mapContentDocument){
		try{
			Boolean isPreventDelete = false;
			Set<Id> setContDocID = new Set<Id>();
			//avoid consultant to delete
			//String prefix = Schema.getGlobalDescribe().get('Event__c').getDescribe().getKeyPrefix();
			String prefix = Event__c.sObjectType.getDescribe().getKeyPrefix();
			User curUser = [select id, profileId, profile.Name from user where id = :userInfo.getUserId() limit 1];
			
            Boolean isPreventConsultantDelete = (curUser.profile.Name == 'Qantas CC Consultant');
			Boolean isPreventConsultantDeleteforpretravel = (curUser.profile.Name == 'Qantas Pre Journey CC Consultant');

			
           if(EnableValidationRule__c.getInstance(userInfo.getUserId()) != Null ){
				isPreventDelete = EnableValidationRule__c.getInstance(userInfo.getUserId()).PreventAttachmentDelete__c;
			}


            //Jira CRM-6162
			//Included four new System Admin profiles which has been created as part of RBAC System
            Boolean isNotSystemAdminProfileUser = ((curUser.profile.Name != 'System Administrator') && (curUser.profile.Name != 'Qantas System Administrator') && (curUser.profile.Name != 'Qantas System Admin - Freight') && (curUser.profile.Name != 'Qantas System Admin - QCC') && (curUser.profile.Name != 'Qantas System Admin - SND'));

			if(isPreventDelete || isNotSystemAdminProfileUser || isPreventConsultantDelete || isPreventConsultantDeleteforpretravel){
				for(Id contDocID: mapContentDocument.keySet()){
					setContDocID.add(mapContentDocument.get(contDocID).Id);
				}

				Id congaTriggerIntegrationUserId = CongaTriggerUtility.getIntegrationUserId();

				for(ContentDocumentLink objContLink: [Select Id, LinkedEntityId, ContentDocumentId, ContentDocument.CreatedById from ContentDocumentLink where
													  ContentDocumentId IN: setContDocID])
				{
					//Jira CRM-6162 avoid deleting Case/Email Message attachments from non system admin profile users.
					if( (congaTriggerIntegrationUserId != objContLink.ContentDocument.CreatedById) &&  isNotSystemAdminProfileUser && (String.valueOf(objContLink.LinkedEntityId).startsWith('500') || String.valueOf(objContLink.LinkedEntityId).startsWith('02s'))){
						mapContentDocument.get(objContLink.ContentDocumentId).addError(CustomSettingsUtilities.getConfigDataMap('QCC_PreventAttDelete'));
					}

					if(((congaTriggerIntegrationUserId != objContLink.ContentDocument.CreatedById) && isPreventConsultantDelete ||isPreventConsultantDeleteforpretravel) && String.valueOf(objContLink.LinkedEntityId).startsWith(prefix)){
						mapContentDocument.get(objContLink.ContentDocumentId).addError('Consultant can\'t delete file from Flight Event');
					}
				}
			
			}
		}
		catch(Exception ex){
			System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
	        CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Content Doc Trigger', 'ContentDocumentTriggerHelper', 
	                                'eligiblityCheckOnContentDocDel', String.valueOf(''), String.valueOf(''),false,'', ex);
	    }
	}
}