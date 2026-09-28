({
    doInit : function(component, event, helper) {

        // Prepare the action to load quote record
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
        var action = component.get("c.getQuote");
        action.setParams({"quoteId": component.get("v.recordId")});

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.quote", response.getReturnValue());
            } else {
                console.log('Problem getting quote, response state: ' + state);
            }
            $A.util.addClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
        
    },

    handleSaveContract: function(component, event, helper) {
        //component.set("v.showSpinner", true);
        var spinner = component.find('spinner');
        
        
        if(helper.validateContractForm(component)) {
            component.set("v.isDisabled", true);
            $A.util.removeClass(spinner, "slds-hide");
            // Prepare the action to create the new contract
            var saveContractAction = component.get("c.saveContractWithQuote");
            saveContractAction.setParams({
                "con": component.get("v.newContract"),
                "quote": component.get("v.quote")
            });

            // Configure the response handler for the action
            saveContractAction.setCallback(this, function(response) {
                var state = response.getState();
                
                if(state === "SUCCESS") {

                    // Prepare a toast UI message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Contract Saved",
                        "message": "The new Contract was created."
                    });
                    //component.set("v.showSpinner", false);

                    // Update the UI: close panel, show toast, refresh quote page
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    $A.get("e.force:refreshView").fire();
                }
                else if (state === "ERROR") {
                    console.log('Problem saving Contract, response state: ' + state);
                    
                    //Display if there is any Validation Error. Used alert instead of showToast as showToast was diplayed behind component.
                    if (JSON.stringify(response.getError()[0]).includes('VALIDATION_EXCEPTION, ')){
                        var validationMsg=JSON.stringify(response.getError()[0]).substring(JSON.stringify(response.getError()[0]).indexOf('VALIDATION_EXCEPTION, ')+21, JSON.stringify(response.getError()[0]).indexOf(': []') );
                        alert('An error occured while creating Contract: ' + validationMsg);
                    } else {
                        alert('An error occured while creating Contract.\n'+
                              'Technical Details:\n'+
                              JSON.stringify(response.getError()));
                    }
                }
                else {
                    console.log('Unknown problem, response state: ' + state + ' - ' + JSON.stringify(response));
                    alert('Unknown error occured');
                }
                $A.util.addClass(spinner, "slds-hide");
            });

            // Send the request to create the new contract
            $A.enqueueAction(saveContractAction);
        }
        
    },

	handleCancel: function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
    }
})