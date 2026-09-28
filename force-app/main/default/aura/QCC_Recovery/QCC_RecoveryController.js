({	
    doInit: function(component) {
        //alert('fffff');
    },
    createRecovery: function(component, event, helper) {
        var action = component.get("c.saveRecovery");
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");

        action.setParams({
            "recId": component.get("v.recordId") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("Recovery Button State"+ state);
            if(state === "SUCCESS") {
                console.log("Response for Recovery Button "+ response.getReturnValue());
                var recoveryId = response.getReturnValue();

                if(recoveryId != null){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recoveryId
                    });
                    
                    $A.get('e.force:refreshView').fire();
                    navEvt.fire();
                }
            }else if (state === "ERROR") {
                var errorMsg = response.getError();;
                console.log(errorMsg);                
            } else if (state === "INCOMPLETE") {
                var errorMsg = "No resonse from server";
                console.log(errorMsg);                
            }
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(action);
    }
})