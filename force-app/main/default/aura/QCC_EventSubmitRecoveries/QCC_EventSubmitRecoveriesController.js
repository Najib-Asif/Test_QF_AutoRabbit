({
	doInit : function(component, event, helper) {
		var action = component.get("c.createRecoveries");
       	action.setParams({
            "eventId" : component.get("v.recordId")
        });
        var messageResult = '';
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                messageResult = response.getReturnValue();
                
                if(messageResult.includes("Error")){
                    component.set("v.variantMsg", 'error');
                }else{
                    component.set("v.variantMsg", 'confirm');
                }
                
            }else{
                messageResult = 'Error: Submit Failed';
                component.set("v.variantMsg", 'error');
            }
           component.set("v.messageResult", messageResult);
           component.set("v.isProcessed", true);
           $A.get('e.force:refreshView').fire();
        });
       $A.enqueueAction(action);
	}
})