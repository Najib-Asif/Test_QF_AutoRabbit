({
	doInit : function(component, event, helper) {
		helper.retrieveFlights(component, event, helper);
	},

    closeModal: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	}
})