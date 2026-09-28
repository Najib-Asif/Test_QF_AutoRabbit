/*----------------------------------------------------------------------------------------------------------------------
    Author:        Purushotham
    Company:       Capgemini
    Description:   To send Conga emails automatically
    Inputs:
    Test Class:     
    ************************************************************************************************
    History
    ************************************************************************************************
    07-Nov-2017      Purushotham               Initial Design
    28-Feb-2018      Praveen Sampath           Added Constructor and Dynmically scheduling for every 10 Minutes
    04-Jul-2018      Purushotham               Changed the logic to use standard email functionality instead of Conga
-----------------------------------------------------------------------------------------------------------------------*/
public class CongaMailSchedulerV2 implements Queueable, Database.AllowsCallouts {
    private String sessionId;
    private List<Case> caseRecords;
    
    private static Set<Id> caseIds;

    public CongaMailSchedulerV2(String sessionInfo, List<Case> caseRecords) {
        this.sessionId = sessionInfo;
        this.caseRecords = caseRecords;
        //this.objContactId = QCC_GenericUtils.fetchGenericContact();
    }
    
    public void execute(QueueableContext qc) {
        try {
            caseIds = new Set<Id>();
            //final String CONGAQUERYNAME = CustomSettingsUtilities.getConfigDataMap('QCC Affected Passenger Query');
            String orgWideEmailId = [ SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Qantas Customer Care' LIMIT 1 ].Id;
            String serverUrl = Url.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/29.0/' + UserInfo.getOrganizationId();
            String affectedPassCongaQueryId = QCC_EmailButtonController.getCongaQueryAffectedPassenger(); //[ SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c =: CONGAQUERYNAME LIMIT 1 ].Id;
            Id attachmentId;
            
            system.debug('session id - ' + sessionId);
            EmailMessage objEmailMessage;
            Messaging.SingleEmailMessage objSingleEmailMessage;
            List<Messaging.SingleEmailMessage> singleMessageList = new List<Messaging.SingleEmailMessage>();
            List<EmailMessage> emailMessageList = new List<EmailMessage>();
            Map<Id, Id> attachmentCaseIdMap = new Map<Id, Id>();
            for (Case objCase : caseRecords) {
                caseIds.add(objCase.Id);
                if (String.isNotBlank(sessionId) && String.isNotBlank(objCase.Conga_Template_ID__c)) {
                    attachmentId = getCalloutResponseFromConga(objCase,sessionId,serverUrl,orgWideEmailId,affectedPassCongaQueryId);
                    objSingleEmailMessage = new Messaging.SingleEmailMessage();
                    objSingleEmailMessage.setOrgWideEmailAddressId(orgWideEmailId);
                    objSingleEmailMessage.setToAddresses(new String[] { objCase.Contact_Email__c });
                    objSingleEmailMessage.setTreatTargetObjectAsRecipient(false);
                    objSingleEmailMessage.setTemplateId(objCase.Conga_Email_Template_ID__c);
                    if (Test.isRunningTest()) {
                        objSingleEmailMessage.setHtmlBody('This is a test email. Please ignore...');
                    }
                    objSingleEmailMessage.setWhatId(objCase.Id);
                    objSingleEmailMessage.setTargetObjectId(objCase.ContactId);
                    if (attachmentId != null) {
                        objSingleEmailMessage.setEntityAttachments(new String[] { attachmentId });
                        attachmentCaseIdMap.put(attachmentId, objCase.Id);
                    }
                    singleMessageList.add(objSingleEmailMessage);
                    // Create an email message record and attach it to the case for reference
                    emailMessageList.add(createEmailMessageRecord(objCase, objSingleEmailMessage.getSubject(), objSingleEmailMessage.getHtmlBody()));
                }
            }
            if (!singleMessageList.isEmpty()) {
                Messaging.sendEmail(singleMessageList);
            }
            if (!emailMessageList.isEmpty()) {
                insert emailMessageList;
            }
            createNewAttachments(attachmentCaseIdMap, emailMessageList);
        } catch(Exception ex) { 
            CreateLogs.insertLogRec( 
                'Log Exception Logs Rec Type', 'QCC - Automated Conga Mail', 'CongaMailSchedulerV2',
                'sendEmails', '', '', false, String.valueOf(caseIds), ex);
            for (Case objCase : caseRecords) {
                objCase.QCC_enableAssignmentRules__c = false;
                objCase.Assign_using_active_assignment_rules__c = true;
            }
            update caseRecords;
        }
    }

    private static String prepareCongaUrl(Case objCase, String sessionId, String serverUrl, String orgWideEmailId, String congaAfQueryId) {
        return  (
            'https://composer.congamerge.com/composer8/index.html'
            +'?sessionId='+sessionId
            +'&serverUrl='+EncodingUtil.urlEncode(serverUrl, 'UTF-8')
            +'&id='+objCase.Id
            //+'&EmailRelatedToId='+objCase.Id
            //+'&EmailFromId='+orgWideEmailId
            //+'&CongaEmailTemplateId='+objCase.Conga_Email_Template_ID__c
            +'&TemplateId='+objCase.Conga_Template_ID__c
            //+'&EmailToID='+objContactId
            //+'&EmailAdditionalTo='+objCase.Contact_Email__c
            //+'&EmailTemplateAttachments=1'
            +'&DefaultPDF=1'
            //+'&UF0=1'
            +'&QueryId=[AffectedPassengers]'+congaAfQueryId
            +'?pv0='+objCase.Id
            //+'&MFTS0=objCase.Auto_Close_on_Email_Sent__c'
            //+'&MFTSValue0=true'
            +'&APIMode=1'
            +'&DS7=11'
        );
    }

    private static String getCalloutResponseFromConga(Case objCase, String sessionId, String serverUrl, String orgWideEmailId, String congaAfQueryId) {
        try {
            String calloutUrl = prepareCongaUrl(objCase, sessionId, serverUrl, orgWideEmailId, congaAfQueryId);
            Http objHttp = new Http();
            HttpRequest objHttpRequest = new HttpRequest();
            objHttpRequest.setEndpoint(calloutUrl);
            objHttpRequest.setMethod('GET');
            objHttpRequest.setTimeout(60000); 
            HttpResponse objHttpResponse = objHttp.send(objHttpRequest);
            system.debug('response - ' + objHttpResponse);
            return Id.valueOf(objHttpResponse.getBody());
        } catch (Exception ex) {
            CreateLogs.insertLogRec(
                'Log Exception Logs Rec Type', 'QCC - Automated Conga Mail', 'CongaMailSchedulerV2', 
                'getCalloutResponseFromConga', '', '', false, String.valueOf(objCase.Id), ex
            );
        }
        return null;
    }

    private static EmailMessage createEmailMessageRecord(Case objCase, String subject, String body) {
        EmailMessage objEmailMessage = new EmailMessage();
        objEmailMessage.FromAddress = Label.Org_Wide_Email_Address;
        objEmailMessage.FromName = 'Qantas Customer Care';
        objEmailMessage.ToAddress = objCase.Contact_Email__c;
        objEmailMessage.Status = '3';
        objEmailMessage.Subject = subject;
        objEmailMessage.HtmlBody = body;
        objEmailMessage.RelatedToId = objCase.Id;
        objEmailMessage.ParentId = objCase.Id;
        return objEmailMessage;
    }

    private static void createNewAttachments(Map<Id, Id> attachmentCaseIdsMap, List<EmailMessage> emailMessageRecords) {
        Attachment objAttachment;
        List<Attachment> attachmentsToBeInserted = new List<Attachment>();
        List<Attachment> attachmentsToBeDeleted = new List<Attachment>();
        Id caseId;
        if (attachmentCaseIdsMap == null || attachmentCaseIdsMap.keySet().isEmpty()) {
            return;
        }
        
        for (Attachment attachmentRec : [ SELECT Id, Name, Body, BodyLength, ContentType, Description, ParentId 
                                            FROM Attachment WHERE Id IN :attachmentCaseIdsMap.keySet() ])
        {
            objAttachment = attachmentRec.clone();
            caseId = attachmentCaseIdsMap.get(attachmentRec.Id);
            for (EmailMessage emRecord : emailMessageRecords) {
                if (emRecord.ParentId == caseId) {
                    objAttachment.ParentId = emRecord.Id;
                    break;
                }
            }
            attachmentsToBeInserted.add(objAttachment);
            attachmentsToBeDeleted.add(objAttachment);
        }
        if (!attachmentsToBeInserted.isEmpty()) {
            insert attachmentsToBeInserted;
        }
        if (!attachmentsToBeDeleted.isEmpty()) {
            delete attachmentsToBeDeleted;
        }
    }
}