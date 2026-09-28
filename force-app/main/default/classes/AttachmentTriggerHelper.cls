public class AttachmentTriggerHelper {

	public static void eligiblityCheckOnAttachmentDel(List<Attachment> lstAttachment){
		try{
			Boolean isPreventDelete = false;
		
			
           if(EnableValidationRule__c.getInstance(userInfo.getUserId()) != Null ){
				isPreventDelete = EnableValidationRule__c.getInstance(userInfo.getUserId()).PreventAttachmentDelete__c;
			}

			if(isPreventDelete){
				for(Attachment objAtt: lstAttachment){
					if(String.valueOf(objAtt.ParentId).startsWith('02s')){
						objAtt.addError(CustomSettingsUtilities.getConfigDataMap('QCC_PreventAttDelete'));
					}
				}
			}
		}
		catch(Exception ex){
			system.debug('ex###############'+ex);
	        CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Attachment Trigger', 'AttachmentTriggerHelper', 
	                                'eligiblityCheckOnAttachmentDel', String.valueOf(''), String.valueOf(''),false,'', ex);
	    }
	}
}