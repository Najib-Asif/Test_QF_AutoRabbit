({
	getRecordType : function(component) {
        var action = component.get("c.fetchRecordTypes");
        action.setParams({
            "obj": component.get("v.objectName")
        });
               
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var data = JSON.parse(response.getReturnValue());
                console.log(data[0].label);
                component.set("v.lstOfRecordType", data);
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
        }); 
        $A.enqueueAction(action);
    },
})