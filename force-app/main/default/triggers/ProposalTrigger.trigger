trigger ProposalTrigger on Proposal__c (Before Update, After Update,After Insert,Before Insert) {
public boolean recursiveStopper = true;
    try{ 
        Trigger_Status__c ts = Trigger_Status__c.getValues('ProposalTrigger');
        
        if(ts.Active__c){
            ProposalTriggerHandler ProposalTriggerHandler = new ProposalTriggerHandler(Trigger.New);
                if(Trigger.isAfter && Trigger.isUpdate)
                {
                    //if(IsRecursive.runOnce())
                    //{
                        ProposalTriggerHandler.approvedByInternalTeam(Trigger.New, Trigger.OldMap);
                        ProposalTriggerHandler.revenueChanges(Trigger.New, Trigger.OldMap); 
                        ProposalTriggerHandler.ApprovalRecall(Trigger.New, Trigger.OldMap);
                        ProposalTriggerHandler.changeDiscountListRecordType(Trigger.New);
                    //}
                }
            	
                if(Trigger.isBefore && Trigger.isUpdate){   
                    //if(IsRecursive.runOnce())
                    //{
                        
                        ProposalTriggerHandler.statusChange(Trigger.New, Trigger.OldMap);
                        ProposalTriggerHandler.propSystemfields(Trigger.New, Trigger.OldMap);
                    //}     
                    
                }  
             
        }  
        // createcontract Old Trigger Code was merged here -CRM-2995
        if(IsRecursive.runOnce()){
            if(Trigger.isAfter && Trigger.isInsert) {
                Proposalcreatecontract.ProposalcreatecontractMethod(Trigger.New);
            }  
        }
        //deactivate other proposals deactiavteOtherProposals Trigger merged -CRM-2995
        if((Trigger.isBefore && Trigger.isInsert || Trigger.isBefore && Trigger.isUpdate) && recursiveStopper ==true) {
         
        for (Proposal__c prop : Trigger.new) {
        if((Trigger.isinsert && prop.Active__c == true) || (Trigger.isUpdate && prop.Active__c == true && Trigger.oldMap.get(prop.id).Active__c == false)){
            Map<String, Object> params = new Map<String, Object>();
            params.put('currentProposalId', prop.id);
            params.put('opportunityId', prop.Opportunity__c);
            Flow.Interview.deactivateOtherProposals proposalFlow = new Flow.Interview.deactivateOtherProposals(params);
            proposalFlow.start();
            recursiveStopper = false;
    }
    }
    }    
    }catch(Exception e){
        System.debug('Error Occured From Proposal Trigger: '+e.getMessage());
    }
}