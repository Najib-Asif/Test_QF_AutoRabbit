// This trigger has been merged with ProposalTrigger CRM-2995 and deactivated
trigger deactiavteOtherProposals on Proposal__c (after insert, after update) {

   for (Proposal__c prop : Trigger.new) {
        if((Trigger.isinsert && prop.Active__c == true) || (Trigger.isUpdate && prop.Active__c == true && Trigger.oldMap.get(prop.id).Active__c == false)){
            Map<String, Object> params = new Map<String, Object>();
            params.put('currentProposalId', prop.id);
            params.put('opportunityId', prop.Opportunity__c);
            Flow.Interview.deactivateOtherProposals proposalFlow = new Flow.Interview.deactivateOtherProposals(params);
            proposalFlow.start();
        }
    }

}