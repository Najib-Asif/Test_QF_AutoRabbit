({	
    escalateCase: function(component, event, helper) {
        var action = component.get("c.escalatingCase");
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        action.setParams({
            "recId": component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var caseVal = response.getReturnValue();
                console.log("Case ID and is Escalated" + caseVal);
                $A.util.toggleClass(spinner, "slds-hide");
                $A.get('e.force:refreshView').fire();
                
            }else if (state === "ERROR") {
                var errorMsg = response.getError();;
                console.log(errorMsg);                
            } else if (state === "INCOMPLETE") {
                var errorMsg = "No resonse from server";
                console.log(errorMsg);                
            }
        });
        $A.enqueueAction(action);
    }
})