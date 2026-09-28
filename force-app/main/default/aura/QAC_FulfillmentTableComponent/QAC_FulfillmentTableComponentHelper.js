({
    recordUpdate : function(component, eachFulfillment){
		console.log("inside update");
        
        var action = component.get("c.updateFulfillment");
        
        action.setParams({
            "fulfillment" : eachFulfillment
        });

		action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS"){
                console.log('Updated Successfully');
            }
		});
		$A.enqueueAction(action);        
        $A.get('e.force:refreshView').fire();
    }
})