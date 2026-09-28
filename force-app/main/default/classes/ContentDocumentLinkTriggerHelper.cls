/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 04-15-2024
 * @last modified by  : Praveen Sampath
**/
public with sharing class ContentDocumentLinkTriggerHelper {

	private static final String SYSTEM_ADMIN_UPDATES_USER = CustomSettingsUtilities.getConfigDataMap('System Admin Updates User');

	public static void avoidingUploadFileToEvent(List<ContentDocumentLink> lstCDL){
			Boolean isPreventUpload = false;
			Set<Id> setContDocID = new Set<Id>();
			//String prefix = Schema.getGlobalDescribe().get('Event__c').getDescribe().getKeyPrefix();
			String prefix = Event__c.sObjectType.getDescribe().getKeyPrefix();
			User curUser = null;
			Boolean isValid = false;
			for(ContentDocumentLink cdl : lstCDL){
				setContDocID.add(cdl.ContentDocumentId);
                //Notes can be edited by All CJM's and check if the content is liked to flight Event
                if(cdl.LinkedEntityId != Null && 
                   (cdl.LinkedEntityId).getSObjectType().getDescribe().getName()== 'Event__c')
                {
                    cdl.ShareType = 'I';
					isValid = True;
                }
			}
			
			//CRM-8246: Email with 101 Apex limit exceeded
			if (UserInfo.getName() != SYSTEM_ADMIN_UPDATES_USER && isValid == false) {
				curUser = [select id, profileId, profile.Name from user where id = :userInfo.getUserId() limit 1];
				Map<ID, ContentDocument> mapCD = new Map<ID, ContentDocument>([select id, OwnerId from ContentDocument where Id IN :setContDocID]);
                // CRM-11628 Adding the QCC Contact Center Agent profiles at all places where Qantas CC Consultant being used as part of RBAC
				//isPreventUpload = (curUser.profile.Name == 'Qantas CC Consultant' || curUser.profile.Name.contains('QCC Contact Center Agent'));
                                
                String profileName = curUser.Profile?.Name;
                isPreventUpload = (profileName == 'Qantas CC Consultant' || 
                                   (profileName != null && profileName.contains('QCC Contact Center Agent'))
                );
                
				if(isPreventUpload){
					for(ContentDocumentLink objContLink: lstCDL)
					{
						if(String.valueOf(objContLink.LinkedEntityId).startsWith(prefix)){
							objContLink.addError('Consultant can\'t upload file to Flight Event');
							mapCD.get(objContLink.ContentDocumentId).addError('Consultant can\'t upload file to Flight Event');
						}
					}
				}
			}
		
	}
}