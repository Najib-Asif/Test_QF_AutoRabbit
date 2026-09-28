({
	renderPage: function(component) {
        var records = component.get("v.cases");
        if(records != null) {            
            var pageNumber = component.get("v.pageNumber");
            var pageRecords = records.slice((pageNumber-1)*5, pageNumber*5);
            component.set("v.currentList", pageRecords);
        }
    },
    checkProfiles: function(component, event, helper){      
        var action = component.get("c.getProfileToHide");        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state === "SUCCESS") {               
                var pflResult = response.getReturnValue();                
                if(pflResult == true){                   
                    component.set("v.showToProfiles", false);                     
                }

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