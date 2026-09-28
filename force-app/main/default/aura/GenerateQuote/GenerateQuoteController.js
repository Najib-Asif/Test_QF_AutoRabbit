({
    doInit : function(component, event, helper) {

        // Prepare the action to load opportunity record
        var action = component.get("c.getOpp");
        action.setParams({"oppId": component.get("v.recordId")});

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.opportunity", response.getReturnValue());
            } else {
                console.log('Problem getting opportunity, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },

    handleSaveQuote: function(component, event, helper) {
        var spinner = component.find('spinner');
        if(helper.validateQuoteForm(component)) {
            component.set("v.isDisabled", true);
            $A.util.removeClass(spinner, "slds-hide");
            
            // Prepare the action to create the new quote
            var saveQuoteAction = component.get("c.saveQuoteWithOpp");
            saveQuoteAction.setParams({
                "quote": component.get("v.newQuote"),
                "opp": component.get("v.opportunity")
            });

            // Configure the response handler for the action
            saveQuoteAction.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {

                    // Prepare a toast UI message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Quote Saved",
                        "message": "The new quote was created."
                    });

                    // Update the UI: close panel, show toast, refresh opp page
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    $A.get("e.force:refreshView").fire();
                }
                else if (state === "ERROR") {
                    console.log('Problem saving quote, response state: ' + state);
                }
                else {
                    console.log('Unknown problem, response state: ' + state);
                }
            });

            // Send the request to create the new quote
            $A.enqueueAction(saveQuoteAction);
        }
        
    },

	handleCancel: function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
    }
})