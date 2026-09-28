({
	doInit : function(component, event, helper) {
        //get list Passenger
		var action = component.get("c.initialize");
        action.setParams({ recordId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var result = JSON.parse(response.getReturnValue());
            	console.log(result);
            	component.set("v.mycolumns", result.displayColumn);
            	component.set("v.passengerList", result.displayPassenger);
                var selectedRows = [];
                for(var i = 0; i < result.displayPassenger.length; i++){
                    var pass = result.displayPassenger[i];
                    if(pass.isAdded){
                        selectedRows.push(pass.passengerId);
                    }
                }
                component.set("v.selectedRows", selectedRows);
            }
            else if (state === "INCOMPLETE") {
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
        });

        $A.enqueueAction(action);
        
        
	},
	addRemovePassenger : function(component, event, helper) {
		var spinner = component.get("v.spinner");
        if(spinner)
            return;
		var selectedRows = event.getParam('selectedRows');
        var passengerList = component.get("v.passengerList");
        if(passengerList == null)
            return;
        // Display that fieldName of the selected rows
        var curSelectRows = [];
        var insertRows = [];
        var removeRows = [];
		
        console.log(selectedRows);
        
        for(var i = 0; i < selectedRows.length; i++){
            curSelectRows.push(selectedRows[i].passengerId);
        }
        console.log(curSelectRows);
        for(var i = 0; i < passengerList.length; i++){
            var passengerId = passengerList[i].passengerId;
            if(curSelectRows.indexOf(passengerId) > -1){
                insertRows.push(passengerList[i]);
                console.log(insertRows);
            }else{
                removeRows.push(passengerId);
            }
        }

        if(insertRows.length > 0){
            
            console.log(insertRows);
            if(!spinner){
                component.set("v.spinner", true);
                helper.insertAffectedPassenger(component, insertRows);
            }
        }
        if(removeRows.length > 0){
    		if(!spinner){
            	console.log(removeRows);
            	helper.removeAffectedPassenger(component, removeRows);
			}
        }

	}
})