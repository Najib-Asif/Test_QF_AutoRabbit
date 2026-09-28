/* Created By :TCS
* Purpose : To include business logic for GDS Status update TS-4468-Channel functionality
* Description : Trigger To update TMC Info records when an Asset is there for IATA 
* References : QAC_TMCHandler

Modified Date   : 13/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3884
Version         : V2.0 - Adding the Recursive check to make the trigger run only once

Modified Date   : 07/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3908
Version         : V3.0 - Changes to update the GDS Status based on PCC GDS Combination
*/

trigger TMCTrigger on Agency_Info__c (before insert, before update, after insert, after update) 
{
    // changes added by Ajay - For Updating GDS Status : TS-4468
    if(IsRecursive.run){
        // changes added by Ajay - For Updating GDS Status : TS-4468
        if(Trigger_Status__c.getValues('TMCInfoTrigger') != null && Trigger_Status__c.getValues('TMCInfoTrigger').Active__c){
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            { 
                // to update GDS Status on TMC Records based on Asset Status    
                QAC_TMCHandler.QCH_updateTMC(trigger.new, trigger.oldMap);
            }
        
        }
        // Changes ended
        
        // Changes added by Vinoth - For Updating GDS Status based on PCC GDS Combination : CRM-3908
        if(Trigger_Status__c.getValues('TMCInfoAfterTrigger') != null && Trigger_Status__c.getValues('TMCInfoAfterTrigger').Active__c){
                if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
                    QAC_TMCHandler.QCH_afterupdateTMC(trigger.new, trigger.oldMap);
                    IsRecursive.run = false;
                }
            }
            // Changes ended
        }
}