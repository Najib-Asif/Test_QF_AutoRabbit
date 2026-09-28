/*===================================================================================
Modified By : Priyanka (TCS Team), 03-July-2026
Desc : CRM-13332 Added new variables. Added updateEscalationTickBoxInCase() method.
=====================================================================================*/
public class FeedItemTriggerHelper {
    //CRM-13332
    private static final Id RTID_QANTASFREIGHT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CustomSettingsUtilities.getConfigDataMap('RT_QCCQANTASFreight')).getRecordTypeId();
    private static final String FREIGHT_CSU = 'freight csu';
    private static final String CSU_MANAGEMENT = 'csu management';
    //CRM-13332
    public static void preventChatterDeletion(List<FeedItem> lstFeedItem){
        //try{
            Boolean isPreventDelete = false;
            
            
            if(EnableValidationRule__c.getInstance(userInfo.getUserId()) != Null ){
                isPreventDelete = EnableValidationRule__c.getInstance(userInfo.getUserId()).PreventChatterDeletion__c;
            }
            
            if(isPreventDelete){
                for(FeedItem objFeed: lstFeedItem){
                    objFeed.addError(CustomSettingsUtilities.getConfigDataMap('QCC_PreventChatterDelete'));
                }
            }
        //}
        /*catch(Exception ex){
            system.debug('ex###############'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - FeedItem Trigger', 'FeedItemTriggerHelper', 'preventChatterDeletion', String.valueOf(''), String.valueOf(''),false,'', ex);
        }*/
    }
    
     
	// This Method created for CRM - 13332.
    //Escalation tick box in case need to be checked when Freight CSU and CSU Management.
    //Called from FeedItemTrigger trigger.
    public static void updateEscalationTickBoxInCase(List<FeedItem> lstFeedItem){ 
        Set<Id> caseIds = new Set<Id>();        
        for(FeedItem fItem : lstFeedItem ){   
            if (fItem.ParentId != null && fItem.ParentId.getSObjectType() == Case.SObjectType && fItem.Body != null)
            {
                String body = fItem.Body.toLowerCase();                
                if(body.contains(FREIGHT_CSU) || body.contains(CSU_MANAGEMENT)){
                    caseIds.add(fItem.ParentId);
                }                
            }			
        }   
        System.debug('caseIds >> ' + caseIds);
        if(caseIds.isEmpty()){
            return;
        }
        List<Case> casesToUpdate = [Select Id, IsEscalated from Case where Id In :caseIds And
                                    RecordTypeId =: RTID_QANTASFREIGHT AND IsEscalated = false ];
        if(!casesToUpdate.isEmpty()){
            try{
                for(Case caseToUp : casesToUpdate ){
                    caseToUp.IsEscalated = true;
                }
                update casesToUpdate;           
            
        	}catch(Exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            	System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FeedItemTrigger', 'FeedItemTriggerHelper', 
                'updateEscalationTickBoxInCase', String.valueOf(''), String.valueOf(''), false, '', ex);
            }
        } 
        
       
    }
}