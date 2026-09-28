/*********************************************************************************
Name         : QCC_OtherWaiverTrigger
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 18 Feb 2020
=========================================
VERSION  AUTHOR            DATE              DETAIL
1.0   Tanya Kumari    15/05/2026      CRM-10522 RBAC for System Admin
*********************************************************************************/
public class QCC_OtherWaiverTriggerHelper implements TriggerHelper.Processor{
	public static String functionName = 'QCC - Other Waiver Trigger';
    
    public void processTrigger(List<QCC_Other_Waiver__c> newRecs, List<QCC_Other_Waiver__c> oldRecs, TriggerHelper.Action triggerAction){
        Map<String, Trigger_Status__c> apexSwitch = Trigger_Status__c.getAll();
        if (triggerAction == TriggerHelper.Action.BEFOREDELETE) { 
            if(apexSwitch.get('QCCOtherWaiverDelete') != null && apexSwitch.get('QCCOtherWaiverDelete').Active__c) { // Check if Custom Setting for QCCOtherWaiverDelete is True
                preventDelete(oldRecs);
            }
        }
    }
    
    //@Purpose: Prevent non Admin user to delete other waiver
    //@param: QCC_Other_Waiver__c trigger.old
    public static void preventDelete(List<QCC_Other_Waiver__c> oldRecs){
        try{
            Id profileId = userinfo.getProfileId();
            String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
            for(QCC_Other_Waiver__c OtherWaiverRecords : oldRecs){
                //Included four new System Admin profiles which has been created as part of RBAC System
                if( (profileName != 'System Administrator') && (profileName != 'Qantas System Administrator') && (profileName != 'Qantas System Admin - Freight') && (profileName != 'Qantas System Admin - QCC') && (profileName != 'Qantas System Admin - SND') ){
                    OtherWaiverRecords.addError('User does not have the right access to delete this record');
                }
            }
        }catch(exception ex){
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord(functionName, 'QCC_OtherWaiverTriggerHelper', 'preventDelete', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
    }
}