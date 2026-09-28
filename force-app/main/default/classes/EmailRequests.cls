public class EmailRequests {
   
   
    @InvocableVariable
    public EmailTemplate templateRecord; // Record to merge into the template (e.g., Contact Id)

    @InvocableVariable
    public Id templateId;

    @InvocableVariable
    public String contactEmail;

    @InvocableVariable
    public Id caseId;

    @InvocableVariable
    public Id contactId;

    @InvocableVariable
    public Id recoveryId;

    @InvocableVariable
    public Recovery__c recoveryRec; 

    @InvocableVariable
    public String orgWideEmailAddress;      //For GW Change Request - CRM-9736
 
}