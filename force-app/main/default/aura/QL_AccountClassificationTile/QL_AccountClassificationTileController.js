({
	Initfunction : function(component, event, helper) {
        var action = component.get("c.AccountClassificationTile");
        action.setParams({
            "Accid" : component.get("v.recordId") });
            action.setCallback(this, function(response) {
            var Output = response.getReturnValue();
            var state = response.getState();
            console.log('Output'+JSON.stringify(Output));
            if(state)
            {
            component.set("v.value",Output);
            console.log('ReturnValue'+JSON.stringify(component.get("v.value")));
        }
                
        });
            $A.enqueueAction(action);
	}
})