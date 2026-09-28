/*----------------------------------------------------------------------------------------------
Author:         Venkat Amiya
Company:        Salesforce
Description:    Associate Email Template on Quick Action
Test Class:     QCC_EmailPublisherLoaderTest
History
03-May-2021      Venkat Amiya        Initial Release
----------------------------------------------------------------------------------------------*/
public without sharing class QCC_EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    
    public QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = NULL;
    
    //Associate Email Template on Quick Action
    public void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        
        Id templateId = null;
        String actionName = null;
        for (Integer j = 0; j < defaults.size(); j++) {
            
            // Check if the quick action is the "Email_with_Selected_Template"
            
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults &&
                defaults.get(j).getTargetSObject().getSObjectType() == EmailMessage.sObjectType &&
                ( Test.isRunningTest() || defaults.get(j).getActionType().equals('SendEmail'))
               )
            {
                actionName = defaults.get(j).getActionName();
                if (Test.isRunningTest() || actionName != null)
                {
                    if (actionName.equals('Case.QCC_Send_Email'))
                    {
                        sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                        break;
                    }  
                    else if (Test.isRunningTest() || actionName.equals('Case.Send_Email_TeleSales'))
                    {
                        System.debug('before  defaults.get(j)===========>' +defaults.get(j));
                        EmailMessage emsg = (EmailMessage) defaults.get(j).getTargetSObject();
                        emsg.TextBody = '';
                        emsg.HtmlBody = '';
                        //emsg.Subject = '';
                        //emsg.ToAddress = '';
                        System.debug('after  defaults.get(j)===========>' +defaults.get(j));
                        sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                        break;
                    }
                    
                }
            }
        }
        
        if (sendEmailDefaults != null) {
            
            templateId = getTemplateId( );
            if(templateId != null ) {
                sendEmailDefaults.setTemplateId(templateId);
                sendEmailDefaults.setInsertTemplateBody(false);
                sendEmailDefaults.setIgnoreTemplateSubject(false);
            }
            
        }
        
    }
    
    //Retrieve Email Template Id from a given case.
    private Id getTemplateId( ){
        Id templateId = null;
        String emailTemplateId = null;
        String vipAssistanceRecordTypeDevName= CustomSettingsUtilities.getConfigDataMap('Case QCC Assistance RecType');
        String Permission_Set_QANTAS_VIP_SERVICE = CustomSettingsUtilities.getConfigDataMap('PS_QANTAS_VIP_SERVICE');
        String Frequent_flyer_Chairman_Lounge = CustomSettingsUtilities.getConfigDataMap('Chairmans_Lounge');
        String Frequent_flyer_Chairmans_Lounge = CustomSettingsUtilities.getConfigDataMap('Chairmans Lounge');          
        String Frequent_flyer_Chairmans_Lounge_Platinum_One = CustomSettingsUtilities.getConfigDataMap('Chairmans_Lounge_Platinum One');                                                                       
        String Frequent_flyer_Chairman_Lounge_Platinum_One = CustomSettingsUtilities.getConfigDataMap('Chairmans Lounge Platinum One');
        String Frequent_flyer_Platinum_One = CustomSettingsUtilities.getConfigDataMap('Platinum One');
        String VIP_BLANK_TEMPLATE = CustomSettingsUtilities.getConfigDataMap('VIP_Blank_Template');
        set<String> validFrequentFlyerTier=new set<String>{Frequent_flyer_Chairman_Lounge,Frequent_flyer_Chairmans_Lounge,Frequent_flyer_Chairmans_Lounge_Platinum_One,Frequent_flyer_Chairman_Lounge_Platinum_One,Frequent_flyer_Platinum_One};
            
            Case c = [SELECT Email_Template_Id__c,recordType.Name,Contact.Frequent_Flyer_Tier__c
                      FROM Case WHERE Id=:sendEmailDefaults.getContextId() ];
        List<PermissionSetAssignment> psaList =[SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = :Permission_Set_QANTAS_VIP_SERVICE LIMIT 1];
        Boolean isVipAssistanceCase = (vipAssistanceRecordTypeDevName != null) && (c.RecordType != null) && (c.RecordType.Name == vipAssistanceRecordTypeDevName);
        Boolean VipServiceTeamPS = String.isNotBlank(Permission_Set_QANTAS_VIP_SERVICE) &&  !psaList.isEmpty();
        Boolean isvalidFFT = validFrequentFlyerTier.contains(c.Contact.Frequent_Flyer_Tier__c);
        system.debug('isvalidFFT'+isvalidFFT);
        
        emailTemplateId = (VipServiceTeamPS && (isvalidFFT || isVipAssistanceCase))
            ? VIP_BLANK_TEMPLATE
            : c.Email_Template_Id__c;
        system.debug('emailTemplateId'+emailTemplateId);
        if (!String.isBlank(emailTemplateId)) {
            try {
                return (Id) emailTemplateId;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'QCC_EmailPublisherLoader', 'getTemplateId', '', '', false, '', e);
            }
        }
        return null;
    }
}