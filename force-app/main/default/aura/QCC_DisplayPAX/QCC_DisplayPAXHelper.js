({
	removeAffectedPassenger : function(component, removeRows) {
        var action = component.get("c.deleteAffectedPassenger");
        action.setParams({ caseId : component.get("v.recordId"),
                          lstPassengerId : removeRows});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var result = response.getReturnValue();
                console.log(result);
                var selectedRows = component.get("v.selectedRows");
                for(var i = 0; i < result.length; i++){
                    if(selectedRows.indexOf(result[i]) > -1){
                        var index = selectedRows.indexOf(result[i]);
                		selectedRows.splice(index, 1);
                    }
                }
                component.set("v.selectedRows", selectedRows);
                console.log(component.get('v.selectedRows'));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            //component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
	},
    insertAffectedPassenger : function(component, insertRows) {
        
        var insertList = [];
        
        for(var i = 0; i < insertRows.length; i++){
            insertList.push(JSON.stringify(insertRows[i]));
        }
        
		var action = component.get("c.createAffectedPassenger");
        action.setParams({ caseId : component.get("v.recordId"),
                          listPass : insertList,
                          mapPassIdToLegInfo: null,
                          isAutoCase: false});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var result = response.getReturnValue();
                console.log(result);
                var selectedRows = component.get("v.selectedRows");
                for(var i = 0; i < result.length; i++){
                    if(selectedRows.indexOf(result[i]) == -1){
                        selectedRows.push(result[i]);
                    }
                }
                console.log(selectedRows);
                component.set("v.selectedRows", selectedRows);
                console.log(component.get('v.selectedRows'));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
	}
})