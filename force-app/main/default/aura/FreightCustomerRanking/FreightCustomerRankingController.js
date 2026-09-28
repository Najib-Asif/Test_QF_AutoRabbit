({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getAccRecord");
        
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));
        
        // Register the callback function
        action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            component.set("v.recName", output.recTypeName);
            if(output && output.acc){
                component.set("v.acc", output.acc);
            }
        });
        
        $A.enqueueAction(action);
        
    }
})