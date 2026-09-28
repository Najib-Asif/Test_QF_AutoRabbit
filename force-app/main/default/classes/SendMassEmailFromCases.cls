public class SendMassEmailFromCases implements Database.Batchable<sObject>, Database.Stateful{
    private String templateId;
    private String staticResourceName;
    private String queryStr;
    private String orgWideEmail;
    private Map<String,Id> orgWideEmailMap;
    private String runningUserEmail;
    private Integer totalEmailsSent = 0;
    private Integer recordFailed = 0;
    
    public SendMassEmailFromCases(String templateId, String staticResourceName, String orgWideEmail, String runningUserEmail)
    {
        this.orgWideEmail = orgWideEmail;
        this.templateId = templateId;
        this.runningUserEmail = runningUserEmail;
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
        String caseNumbers = sr.Body.toString();
        
        String fieldNames = '';
        Schema.DescribeSobjectResult[] objectDescribe = Schema.describeSObjects(new List<String>{'Case'});
        for(Schema.DescribeSobjectResult res : objectDescribe) {
            for (String fieldName : res.fields.getMap().keySet()) {
                if (fieldNames == '') {
                    fieldNames = fieldName;
                } else {
                    fieldNames = fieldNames + ',' + fieldName;
                }
            }
        }
        
        queryStr = 'SELECT ' + fieldNames + ', Contact.FirstName FROM Case WHERE CaseNumber IN (' + caseNumbers + ')';
        orgWideEmailMap = new Map<String,Id>();
        for(OrgWideEmailAddress orgWideEmailRecord : [SELECT Id,DisplayName, Address FROM OrgWideEmailAddress]){
            system.debug('orgWideEmailRecordfl '+orgWideEmailRecord.Address+' '+orgWideEmailRecord.Id);
            orgWideEmailMap.put(orgWideEmailRecord.Address,orgWideEmailRecord.Id);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope){
        List<Messaging.SingleEmailMessage> messagesToBeSent = new List<Messaging.SingleEmailMessage>();
        for(Case caseRecord : scope){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            List<String> listToAddresses = new List<String>();
            listToAddresses.add(caseRecord.Contact_Email__c);
            message.setOrgWideEmailAddressId(orgWideEmailMap.get(orgWideEmail)); //TO-DO: Change the email address to production
            message.setToAddresses(listToAddresses);
            message.setTemplateId(templateId); 
            message.setTargetObjectId(caseRecord.ContactId);
            message.setSaveAsActivity(true);
            message.treattargetobjectasrecipient = false;
            message.setWhatId(caseRecord.Id);
            messagesToBeSent.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messagesToBeSent);
        
        for(Messaging.SendEmailResult result : results)
        {
            if(result.success)
            {
                totalEmailsSent += 1;
            }else if(!result.success)
            {
                recordFailed += 1;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, 
                          CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
        List<Messaging.SingleEmailMessage> messagesToBeSent = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        List<String> listToAddresses = new List<String>();
        listToAddresses.add(runningUserEmail);
        message.setToAddresses(listToAddresses);
        String body = 'Hi,<br/><br/>';
        body += 'Please find the status of the Job:Send Mass Emails from Case<br/><br/>';
        body += 'Job Id: <b>'+a.Id+'</b><br/>';
        body += 'Status: <b>'+a.Status+'</b><br/>';
        body += 'Number of Records Processed: <b>'+totalEmailsSent+'</b><br/>';
        body += 'Number Of Records Failed: <b>'+recordFailed+'</b><br/><br/>';
        body += 'Thanks';
        message.setHtmlBody(body);
        message.treattargetobjectasrecipient = false;
        messagesToBeSent.add(message);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messagesToBeSent);
    }
}