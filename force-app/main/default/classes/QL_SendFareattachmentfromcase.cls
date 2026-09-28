/*----------------------------------------------------------------------------------------------------------------------
Author:      gnanavelu
Jira:      CRM-3506
Description:  Send Fare attachment (excel) from Salesforce Case to external address
Test Class:     TestSendFareattachmentfromcase
************************************************************************************************************************
History
************************************************************************************************************************
12-Feb-2019      gnanavelu               Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
public class QL_SendFareattachmentfromcase 
{
    public static void SendEmail(List<Case> cases)
    {
        system.debug('cases list'+cases);
        Set<Id> caseIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<String> contentDocId = new List<String>();
        List<String> contentVerId = new List<String>();
        List<ContentDistribution> contentDistributiontoInsert = new List<ContentDistribution>();
        List<ContentDocumentLink> contentdoc = new List<ContentDocumentLink>();
        List<ContentVersion> contVersionv = new List<ContentVersion>();
        List<ContentDistribution> distributionURL= new List<ContentDistribution>();
        List<ContentDistribution> distributionURLNew = new List<ContentDistribution>();
        List<String> casenumbers = new List<String>();
        Map<Id,Id> docIdWithCaseId = new Map<Id,Id>();
        Map<Id,Case> caseIdWithCaseObj = new Map<Id,Case>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        List<Case> casestoUpdate = new List<Case>();
        String documentName = '%'+Label.Fare_Filing_Audit_Email_Document_Name+'%';
        List<ContentDocument> contDoc = new List<ContentDocument>();
        
        
        for(Case c :cases)
        {
            caseIds.add(c.Id);
            accIds.add(c.AccountId);
            caseIdWithCaseObj.put(c.Id, c);
        }
        
        accountMap = new Map<Id,Account>([Select Id, Name from Account where Id IN: accIds]);
        
        if(!caseIds.isEmpty())
        {
            contentdoc = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN : caseIds];
        }
        
        for(ContentDocumentLink c: contentdoc)
        {        
            contentDocId.add(c.ContentDocumentId);
            docIdWithCaseId.put(c.ContentDocumentId, c.LinkedEntityId);
        }
        
        if(!contentDocId.isEmpty())
        {
            contDoc = [Select Id, CreatedDate, Title, LastModifiedDate from ContentDocument where Id IN:contentDocId AND Title like :documentName order by LastModifiedDate desc LIMIT 1]; 
        }
        
        if(!contDoc.isEmpty())
        {
            contVersionv = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion 
                            WHERE isLatest = true AND Title like :documentName AND ContentDocumentId =: contDoc[0].Id];
        }
        
        if(!contVersionv.isEmpty())
        {
        distributionURL = [SELECT DistributionPublicUrl, ContentDocumentId,RelatedRecordId 
                                                     FROM ContentDistribution where ContentVersionId IN: contVersionv];
        }
        
        if(distributionURL.isEmpty())
        {
            for(ContentVersion cv : contVersionv)
            {
                ContentDistribution cd = new ContentDistribution();
                cd.ContentVersionId = cv.Id;
                cd.Name = cv.Title;
                cd.RelatedRecordId = docIdWithCaseId.get(cv.ContentDocumentId);
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesLinkLatestVersion = true;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                contentDistributiontoInsert.add(cd); 
            }
            insert contentDistributiontoInsert; 
        }
        
        if(!contVersionv.isEmpty())
        {
        distributionURLNew = [SELECT DistributionPublicUrl, ContentDocumentId,RelatedRecordId 
                                                        FROM ContentDistribution where ContentVersionId IN: contVersionv];
        }
        
        if(!caseIds.isEmpty() && !distributionURLNew.isEmpty())
        {
            //List<Case> CasetoUpdate = new List<Case>();
            for(ContentDistribution cdn : distributionURLNew)
            {
                if(cdn.RelatedRecordId == docIdWithCaseId.get(cdn.ContentDocumentId))
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    String[] toAddresses = new String[]{Label.Email_of_First_pass_auditor_ZO};
                        String[] ccAddresses = new String[]{Label.Email_of_Second_Pass_auditor_WNS};
                            String mailsub = 'Ticketing Instructions for '+ accountMap.get(caseIdWithCaseObj.get(cdn.RelatedRecordId).AccountId).Name;
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(ccAddresses);
                    mail.setSubject(mailsub); 
                    mail.setHtmlBody('Hi,<br/><br/>.'+
                                     '<b>**This is an automated email generated from Qantas Salesforce. Please do not reply to this email**</b> <br/><br/>'+
                                     'To access the Ticketing Instructions for '+accountMap.get(caseIdWithCaseObj.get(cdn.RelatedRecordId).AccountId).Name+'. Please <a href='+cdn.DistributionPublicUrl+'>click here.</a> <br/><br/>'+
                                     'Thanks<br/>'+
                                     'Qantas Salesforce Support');
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                    if(results[0].IsSuccess() == true){
                        Case updCase = new Case(id = caseIdWithCaseObj.get(cdn.RelatedRecordId).id);
                        updCase.Latest_Status__c = system.now();
                        casestoUpdate.add(updCase);
                    }
                }
            }
            update casestoUpdate;
        } 
    }
}