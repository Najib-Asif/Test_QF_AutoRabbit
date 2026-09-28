({
	doInit : function(component, event, helper) {
		var action = component.get("c.getAllOpenCases");
        
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));

		action.setCallback(this, function(data) {
			component.set("v.AllOpenCases", data.getReturnValue());
		});
		$A.enqueueAction(action);	
	}
})