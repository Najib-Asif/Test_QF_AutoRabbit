public with sharing class EventManagementEmailSender {

    private static String EVENT_MANAGEMENT_SITE_NAME = 'S_D_Event_Management1';
    private static final String EMAIL_TEMPLATE = 'Hey {0},\n\n Hope you are doing good. You are invited to attend {1} event. Please click on the link to confirm you registration.\n\n{2}\n\nThanks,\nEvent ManagementTeam';

    @InvocableMethod(label = 'Generate Token and Send Email To Members')
    public static void sendEmailToMembers(List<List<CampaignMember>> campaignMemberRecordsList) {
        List<CampaignMember> campaignMemberToUpdate = new List<CampaignMember>();
        List<CampaignMember> campaignMemberRecords = campaignMemberRecordsList[0];
        Campaign campaignRecord;
        String token;
        String url = getEventManagementUrl();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Set<Id> campaignIds = new Set<Id>();
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        for (CampaignMember cmRecord : campaignMemberRecords) {
            campaignIds.add(cmRecord.CampaignId);
        }
        if (campaignIds.isEmpty()) {
            return;
        }
        for (Campaign cRecord : [ SELECT Id, Name, Final_RSVP_Date__c FROM Campaign 
                                            WHERE Id IN :campaignIds ])
        {
            campaignMap.put(cRecord.Id, cRecord);
        }
        for (CampaignMember cmRecord : campaignMemberRecords) {
            campaignRecord = campaignMap.get(cmRecord.CampaignId);
            token = generateToken(campaignRecord, cmRecord);
            url += EncodingUtil.urlEncode((token), 'UTF-8');
            emailList.add(createEmailMessage(campaignRecord, cmRecord, url));
        }
        if (!emailList.isEmpty()) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList);
            for (Messaging.SendEmailResult emResult : results) {
                if (emResult.isSuccess()) {
                    for (CampaignMember cmRecord : campaignMemberRecords) {
                        cmRecord.Status = 'Sent';
                        campaignMemberToUpdate.add(cmRecord);
                    }
                }
            }
        }
        try {
            update campaignMemberToUpdate;
        } catch (Exception ex) {
            System.debug('Error: ' + ex);
        }
    }

    public static String generateToken(Campaign cRecord, CampaignMember cmRecord) {
        String tokenParameters = cRecord.Name;
        tokenParameters = tokenParameters + '_' + cmRecord.Name;
        tokenParameters = tokenParameters + '_' + cmRecord.Id;
        tokenParameters = tokenParameters + '_' + String.valueOf(cRecord.Final_RSVP_Date__c);
        return EncodingUtil.base64Encode(Blob.valueOf(tokenParameters));
    }

    public static Messaging.SingleEmailMessage createEmailMessage(Campaign cRecord, CampaignMember cmRecord, String url) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(cRecord.Name + ' Event Invitation');
        mail.setToAddresses(new String[] {cmRecord.Email});
        mail.setPlainTextBody(String.format(EMAIL_TEMPLATE, new String[] {cmRecord.Name, cRecord.Name, url}));
        mail.setWhatId(cRecord.Id);
        mail.setSaveAsActivity(true);
        
        return mail;
    }

    private static String getEventManagementUrl() {
        try {
            Site siteRecord = [ SELECT Id FROM SITE WHERE Name = :EVENT_MANAGEMENT_SITE_NAME LIMIT 1 ];
            SiteDetail sdRecord = [ SELECT SecureUrl FROM SiteDetail WHERE DurableId = :siteRecord.Id LIMIT 1 ];
            return sdRecord.SecureUrl + '?ekvp=';
        } catch (Exception ex) {
            throw new AuraHandledException(EVENT_MANAGEMENT_SITE_NAME+' site doesn\'t exists for the org. Error message ('+ ex.getMessage()+')');
        }
    }
    
}