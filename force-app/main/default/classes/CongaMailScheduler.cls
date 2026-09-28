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
public class CongaMailScheduler implements Queueable, Database.AllowsCallouts {
    private String sessionId;
    private Case cs;
    //private String objConId;

    public CongaMailScheduler( String sessionInfo, Case cs ) {
        this.sessionId = sessionInfo;
        system.debug('sessionId ####--> '+sessionId);
        this.cs = cs;
        //this.objConId = QCC_GenericUtils.fetchGenericContact();
    }
    
    public void execute(QueueableContext sc) {
        try {
            //String orgWideId = CustomSettingsUtilities.getConfigDataMap('OrgWideAddress');
            String orgWideId = [select id, address from orgwideemailaddress where displayname='Qantas Customer Care'].id;
            String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
            String affectedPassCongaQueryId = QCC_EmailButtonController.getCongaQueryAffectedPassenger();
            
            system.debug('sessionId --> '+sessionId);
            if(sessionId != '' && sessionId != Null) {
                system.debug('sessionId --> '+sessionId);
                Id attachmentId;
                String url2;

                if(String.isNotBlank(cs.Conga_Template_ID__c)) {
                    url2 = 'https://composer.congamerge.com/composer8/index.html'+
                        '?sessionId='+sessionId+
                        '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
                        '&id='+cs.Id+
                        //'&EmailRelatedToId='+cs.Id+
                        //'&EmailFromId='+orgWideId+
                        //'&CongaEmailTemplateId='+cs.Conga_Email_Template_ID__c+
                        '&TemplateId='+cs.Conga_Template_ID__c+
                        //'&EmailToID='+objConId+
                        //'&EmailAdditionalTo='+cs.Contact_Email__c+
                        //'&EmailTemplateAttachments=1'+
                        '&DefaultPDF=1'+
                        //'&UF0=1'+
                        '&QueryId=[AffectedPassengers]'+affectedPassCongaQueryId+'?pv0='+cs.Id+
                        //'&MFTS0=Auto_Close_on_Email_Sent__c'+
                        //'&MFTSValue0=true'+
                        '&APIMode=1'+
                        '&DS7=11';
                System.debug(url2);
                
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(url2);
                req.setMethod('GET');
                req.setTimeout(60000);                  
                HttpResponse res = http.send(req);
                System.debug(res);
                System.debug('Res Body = '+res.getBody());
                    attachmentId = (Id)res.getBody();
                }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                string[] to = new string[] {cs.Contact_Email__c};
                email.setOrgWideEmailAddressId(orgWideId);
                email.setToAddresses(to);
                email.setTreatTargetObjectAsRecipient(false);
                email.setTemplateId(cs.Conga_Email_Template_ID__c);
                if(Test.isRunningTest()) {
                    //email.setTemplateId('00X5D000000MSBJ');
                    email.setHtmlBody('Test Mail');
                }
                email.setWhatId(cs.Id);
                email.setTargetObjectId(cs.ContactId);
                if(attachmentId != null) {
                    email.setEntityAttachments(new String[] { attachmentId });
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                EmailMessage log = new EmailMessage();
                log.FromAddress = Label.Org_Wide_Email_Address;
                log.FromName = 'Qantas Customer Care';
                log.ToAddress = cs.Contact_Email__c;
                log.Status = '3';
                log.Subject = email.getSubject();
                log.HtmlBody = email.getHtmlBody();
                log.RelatedToId = cs.Id;
                log.ParentId = cs.Id;
                insert log;
                
                if(attachmentId != null) {
                    Attachment att = [SELECT Id, Name, Body, BodyLength, ContentType, Description, ParentId FROM Attachment WHERE Id =: attachmentId];
                    Attachment copy = att.clone();
                    copy.ParentId = log.Id;
                    insert copy;
                    
                    // delete the previous attachment for sending email since we just need to store it under the EmailMessage
                    delete att;
                }
            }
        } catch(Exception ex){
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Automated Conga Mail', 'CongaMailScheduler', 
                                    'sendEmails', '', '', false,'', ex);
            cs.QCC_enableAssignmentRules__c = false;
            cs.Assign_using_active_assignment_rules__c = true;
            update cs;
        }
    }
}