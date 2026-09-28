({
	doInit : function(component, event, helper) {
		var action = component.get("c.getAccOwner");
        
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));

		action.setCallback(this, function(data) {
			component.set("v.AccOwner", data.getReturnValue());
		});
		$A.enqueueAction(action);	
	}
})