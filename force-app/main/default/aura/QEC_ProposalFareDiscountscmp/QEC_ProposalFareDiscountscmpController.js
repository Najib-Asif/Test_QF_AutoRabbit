({
    getProposalList : function(component, event, helper) {
        helper.fetchProposal(component, event, helper);
    },
    
    saveFareDiscounts: function(component, event, helper) {
        helper.saveDiscounts(component, event, helper);
    },
    addToList : function(component, event, helper){
        helper.addModifiedRecords(component, event, helper);
    },
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})