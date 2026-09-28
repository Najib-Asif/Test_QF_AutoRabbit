/**********************************************************************************************************************************

Created Date: 27/09/2016

Description: Process Contact trigger for:
1. Populate the details at the Account Relationship level automatically upon Contact creation/update

Versión:
V1.0 - 27/09/2016 - Initial version [FO]

Modified Date: 23/05/2017
Decription: Roll up of CL contacts of an account

Change History:
======================================================================================================================
Name                          Jira           Description                                             Tag
======================================================================================================================
Priyadharshini Vellingiri    2306    Populate the details at the Account Relationship level          T01
automatically upon Contact creation/update  
Karpagam Swaminathan         2563    Roll up of CL contacts of an account                            T01
Lora Mae Dapulang           G-932   Auto-creation of Individual record from Contact
Leslie May Padilla          G-934   Add a condition to check if the user session has permission to bypass trigger which is used for
                                    Data Migration and Transformation activities
Sobhan Patnam               TS-4863 Contact duplicate logic for Agency Contacts
**********************************************************************************************************************************/   
trigger AccconRshipUpdate on Contact (after insert, after Update,after delete,after undelete, before insert, before update){
    
    try{
        Trigger_Status__c ts = Trigger_Status__c.getValues('AccconRshipUpdate');
        //GRAPHIT-934: Check if the specific user session triggering this event has the permission to bypass triggers
        Boolean bypassTrigger = FeatureManagement.checkPermission('QCC_Bypass_Account_Contact_Case_Triggers');
        system.debug('>>>bypassTrigger: ' + bypassTrigger);
        if (!bypassTrigger) {
            system.debug('>>>Trigger executed');
            if(ts.Active__c) { 
                /*if ((trigger.isafter && trigger.isInsert) || (trigger.isafter && trigger.isUpdate)) {
                    accConRshipUpdateonContacts.AccContactInsUpdate(trigger.new);
                }*/
                if (trigger.isafter && trigger.isInsert) {
                    accConRshipUpdateonContacts.AccContactInsUpdate(trigger.new);
                }
                if (trigger.isafter && trigger.isUpdate) {
                    accConRshipUpdateonContacts.AccContactUpdate(trigger.new);
                }
                if ((trigger.isafter && trigger.isInsert) || (trigger.isafter && trigger.isUpdate) || (trigger.isafter && trigger.isdelete)|| (trigger.isafter && trigger.isUndelete))      
                {
                    Contact[] cons;
                    if (Trigger.isDelete)
                        cons = Trigger.old;
                    else
                        cons = Trigger.new;
                    RollupofCLcontactsHandler.CountNumofContacts(cons);    
                } 
            }
            
            if( Trigger_Status__c.getValues('ContactCeateAccount').Active__c && trigger.isBefore && Trigger.isInsert){
                accConRshipUpdateonContacts.createAccount(Trigger.New);  
            }
            
            
            if( Trigger_Status__c.getValues('ContactUpdateContact').Active__c && trigger.isBefore){
                accConRshipUpdateonContacts.updateContact(Trigger.New, Trigger.oldMap);            
            }
            
            
            /* if( Trigger_Status__c.getValues('ContactCeateAccount').Active__c && trigger.isAfter && trigger.isInsert){
accConRshipUpdateonContacts.createACRforPrimaryBusinessAcc(Trigger.New);            
} */
            if( Trigger_Status__c.getValues('ContactCeateAccount').Active__c && trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
                accConRshipUpdateonContacts.updateStandardEmailandPhone(Trigger.New);   
                accConRshipUpdateonContacts.UpdateFrequentFlyerNumber(Trigger.New, Trigger.oldMap);
            }
            if(Trigger_Status__c.getValues('ContactAttachCase').Active__c && Trigger.isBefore && Trigger.isUpdate ){
                accConRshipUpdateonContacts.linkCaseToContact(Trigger.New, Trigger.oldMap);
            }
            
            // GRAPHITE-932: Automated creation of Individual record
            if(Trigger_Status__c.getValues('createIndividualRecord').Active__c && Trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
                if(ContactTriggerHelper.isFirstTime){
                    System.debug('###AccconRshipUpdate');
                    System.debug(ContactTriggerHelper.isFirstTime);
                    ContactTriggerHelper.isFirstTime = false;                
                    ContactTriggerHelper.createIndividualRecord(Trigger.newMap);
                }
            }
            
            
        if(Trigger_Status__c.getValues('QACManagerContactDupCheck').Active__c && Trigger.isBefore && Trigger.isInsert){
        QAC_ManagerContactsDuplicateCheck.doContactDuplicateCheck(trigger.new);
        }
        if(Trigger_Status__c.getValues('QACManagerContactDupCheck').Active__c && Trigger.isBefore && Trigger.isUpdate){
        QAC_ManagerContactsDuplicateCheck.beforeUpdate(trigger.new,trigger.oldMap);
        }
        }
        
        //GRAPHITE-1373 : Changes to process builders for loyalty data
        if(Trigger_Status__c.getValues('QCC_WelcomeToSSU').Active__c && Trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            ContactTriggerHelper.createCaseForSsuContact(Trigger.New, Trigger.oldMap);
        }

        //GRAPHITE-2397 Transfer the logic from QCC Contact - Update Contact Phone and Address Details process builder to trigger
        if(Trigger_Status__c.getValues('QCC_UpdateContactPhoneAndAddress').Active__c && Trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
            ContactTriggerHelper.updateContactPhoneAndAddressDetails(Trigger.New, Trigger.oldMap);
        }
    }
    catch(Exception e){
        System.debug('Error Occured From AccconRshipUpdate  Trigger: ' + e.getLineNumber() +e.getMessage());
    }
    
    
}