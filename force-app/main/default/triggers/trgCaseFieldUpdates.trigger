/***********************************************************************************************************************************

Description: Based on the IATA or TIDS on Group waivers case record the respective account id should get auto populated on case. 

Change History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  2645       Populating Account Id on Case for Group Waiver               T01
                                   based on IATA or TIDS in case

**********************************************************************************************************************************/

trigger trgCaseFieldUpdates on Case (before update) {
    try{
        Trigger_Status__c ts = Trigger_Status__c.getValues('trgCaseFieldUpdates');
        if(ts.Active__c){   
            clsCaseFieldUpdatesHelper.generateAuthorityNumber(trigger.new);
            
            /* Code logic for Account id population on case begins*/
               if(trigger.isBefore && trigger.isInsert){
               AccountpopulatingonCase casehandler = new AccountpopulatingonCase();
               casehandler.accountoncase(trigger.new);
               }
               
               if(trigger.isBefore && trigger.isUpdate){
                AccountpopulatingonCase casehandler = new AccountpopulatingonCase();
               casehandler.accountoncase(trigger.new);
               }
               
               
        }   
    }catch(Exception e){
        System.debug('Error Occured : '+e.getMessage());
    }
}