/*
*********************************************************************************************************************************
 
    Description: To handle the Opportunitymaintenance After insert & After Update trigger to update the fields "Expected Closure Date"
                 and "Create an Opportunity before (in months)" on the Custom settings "Opportunity maintenance" which is being 
                 used in Batch class "Opptycreation_Batch"
                     
 
**********************************************************************************************************************************

*/

trigger OpportunityMaintenanceTrigger on Opportunity_Maintenance__c (After insert, After Update) {
    try{ 
        Trigger_Status__c ts = Trigger_Status__c.getValues('OpportunityMaintenanceTrigger');
        if(ts.Active__c){
         
            if(Trigger.isAfter && Trigger.isUpdate){
                /*
                This method is to update the fields "Expected Closure Date"
                 and "Create an Opportunity before (in months)" on the Custom settings "Opportunity maintenance"
                */
                OpptyMaintenanceTriggerHandler.updateclosurecreationdate(Trigger.New, Trigger.OldMap);
               
              
            }
            
            if(Trigger.isAfter && Trigger.isInsert){        
                /*
                This method is to insert the values on the fields "Expected Closure Date"
                and "Create an Opportunity before (in months)" on the Custom settings "Opportunity maintenance"
                once the Active Opportunity maintenance record is created
                 
                */
                OpptyMaintenanceTriggerHandler.insertclosurecreationdate(Trigger.New);    
            }  
            
         
        }         
    }catch(Exception e){
        System.debug('Error Occured From OpportunityMaintenance Trigger: '+e.getMessage());
    }
}