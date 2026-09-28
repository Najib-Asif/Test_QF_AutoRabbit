/***********************************************************************************************************************************        

Description: Based on the IATA or TIDS on Group waivers case record the respective account id should get auto populated on case.        

Change History:     
======================================================================================================================      
Name                    Jira        Description                                                 Tag     
======================================================================================================================      
Bharathkumar Narayanan  2645       Populating Account Id on Case for Group Waiver               T01     
based on IATA or TIDS in case        
Karpagam Swaminathan               Merged two case Triggers     
Ajay Bharathan                     Case Fulfillment Record Creation Based on Custom Metadata    
**********************************************************************************************************************************/
trigger trgTradeSiteResponses on Case (before Insert, after Insert, before update, after update) {
    
    try{
        Trigger_Status__c ts = Trigger_Status__c.getValues('trgTradeSiteResponses');
        if(ts.Active__c){
            
            // Freight Changes
            Freight_CaseTriggerHandler triggerHandler = new Freight_CaseTriggerHandler();
            if((Trigger.IsBefore && Trigger.IsUpdate) || (Trigger.IsBefore && Trigger.IsInsert)){
                triggerHandler.assignEntitlement(Trigger.New, Trigger.OldMap);
                if(Trigger.isInsert)
                    triggerHandler.assignEntitlement1(Trigger.New, null);
                if(Trigger.isUpdate)
                    triggerHandler.assignEntitlement1(Trigger.New, Trigger.oldMap);
                
            }
            if((Trigger.IsAfter && Trigger.IsUpdate)){
                triggerHandler.autoMilestonCompletion(Trigger.New, Trigger.OldMap);
                triggerHandler.autoMilestonCompletionforservicerequest(Trigger.New, Trigger.OldMap);
                
            }
            if(Trigger.IsBefore && Trigger.IsUpdate ){
                triggerHandler.autoChangeStatus(Trigger.New, Trigger.OldMap);
                triggerHandler.autoChangeStatus1(Trigger.New, Trigger.OldMap);
                
            }
            
            if(trigger.isBefore && trigger.isInsert){
                /* QAC Release 2 Authority Number Generation logic removed from Status field */
                //clsTradesiteHandler.processTradesiteAuthorityNumber(trigger.new);
                //Depricated old name change request coming from old tradeite via QSOA
                //clsTradesiteHandler.processTradesiteAuthorityNumberNew(trigger.new);
                
                // Assign Freight Recordtypes
                triggerHandler.assignRecordTypeWebToCase(Trigger.New);
            }
            if(trigger.isAfter && trigger.isInsert){
                //Depricated old name change classes
                //clsTradesiteHandler.processNameChangeRequest(trigger.new);
                
                // to Create Fulfillment record from Custom Meta Data types
                // For Tradesite - Service Request Case Creation by Digital Team
                QAC_caseFulfilmentHandler.autoCreateFulfillmentRecords(trigger.new);
            }
            if(Trigger.isAfter && Trigger.isUpdate)
            {
                clsCaseFieldUpdatesHelper.updateAccountRequestPending(Trigger.New, Trigger.oldMap);
            }
            
        }  
        //Merged two case Triggers (trgCaseFieldUpdates)        
        Trigger_Status__c tgs = Trigger_Status__c.getValues('trgCaseFieldUpdates');     
        if(tgs.Active__c){         
        
            /* QAC Release 2 Authority Number Generation logic removed from Status field */
            
            //clsCaseFieldUpdatesHelper.generateAuthorityNumber(trigger.new); 
            clsCaseFieldUpdatesHelper.generateAuthorityNumberNew(trigger.new);          
        }  

    }
    catch(Exception e){
        System.debug('Error Occured : '+e.getMessage());
    }
}