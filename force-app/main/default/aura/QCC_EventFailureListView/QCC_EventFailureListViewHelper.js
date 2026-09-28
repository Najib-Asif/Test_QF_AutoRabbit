({
    fetchEventFailures : function(component) {
        var recID = component.get("v.recordId");
        var action = component.get("c.fetchEventFailuresValues");
        action.setParams({
            "recId": recID,
        });
        
        action.setCallback(this, function(response) {
            console.log('return Value###', response.getReturnValue());
            component.set("v.options", JSON.parse(response.getReturnValue()));
            console.log("Response:", component.get("v.options"));    
        });
        
        $A.enqueueAction(action);
    }
})