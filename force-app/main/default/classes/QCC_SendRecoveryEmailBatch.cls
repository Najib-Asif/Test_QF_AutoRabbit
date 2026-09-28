/**
 * Batch Apex class to send recovery emails using SingleEmailMessage and OrgWideEmailAddress.
 * Implements Database.Batchable and allows callouts.
 *
 * Usage: Instantiate with a list of EmailRequests and execute as a batch job.
 */
public class QCC_SendRecoveryEmailBatch implements Database.Batchable<EmailRequests>, Database.AllowsCallouts {


    // List of email requests to process in the batch
    private List<EmailRequests> emailRequests;
    // Map of OrgWideEmailAddress by email address for quick lookup
    private Map<String, OrgWideEmailAddress> orgWideEmailMap;
    // Default org-wide email address to use if none specified
    private final String DefaultOrgWideEmail = 'qantas_customer_care@qantas.com.au';

    /**
     * Constructor initializes the batch with a list of EmailRequests and loads OrgWideEmailAddress records.
     * @param emailRequests List of EmailRequests to process
     */
    public QCC_SendRecoveryEmailBatch(List<EmailRequests> emailRequests) {
        this.emailRequests = emailRequests;
        this.orgWideEmailMap = new Map<String, OrgWideEmailAddress>();
        for (OrgWideEmailAddress o : [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address in ('qantas_customer_care@qantas.com.au','noresponse@qantas.com.au')]) {
            orgWideEmailMap.put(o.Address, o);
        }
    }


    /**
     * Start method returns the list of EmailRequests as an Iterable.
     * @param bc Batchable context
     * @return Iterable of EmailRequests
     */
    public Iterable<EmailRequests> start(Database.BatchableContext bc) {
        return emailRequests;
    }


    /**
     * Execute method sends emails for each EmailRequest in the scope using SingleEmailMessage.
     * Sets the org-wide email address, template, and other fields.
     * Handles errors and logs failures.
     *
     * @param bc Batchable context
     * @param scope List of EmailRequests to process in this batch chunk
     */
    public void execute(Database.BatchableContext bc, List<EmailRequests> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (EmailRequests req : scope) {
            // Create and configure the email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(req.contactId);
            mail.setTemplateId(req.templateId);
            // Set the org-wide email address if specified, otherwise use default
            if (String.isNotBlank(req.orgWideEmailAddress) && orgWideEmailMap.containsKey(req.orgWideEmailAddress)) {
                mail.setOrgWideEmailAddressId(orgWideEmailMap.get(req.orgWideEmailAddress).Id);
            } else {
                mail.setOrgWideEmailAddressId(orgWideEmailMap.get(DefaultOrgWideEmail).Id);
            }
            mail.setToAddresses(new List<String>{req.contactEmail});
            mail.setWhatId(req.recoveryId);
            mail.setSaveAsActivity(true);
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            try {
                // Send all emails in bulk
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails, false);
                for (Messaging.SendEmailResult res : results) {
                    if (!res.isSuccess()) {
                        System.debug('Email error: ' + res.getErrors()[0].getMessage());
                    }
                }
            } catch (Exception e) {
                System.debug('Exception while sending emails: ' + e.getMessage());
            }
        }
    }

    /**
     * Finish method called after all batch chunks are processed.
     * Logs completion of the batch job.
     * @param bc Batchable context
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch email sending completed.');
    }
}