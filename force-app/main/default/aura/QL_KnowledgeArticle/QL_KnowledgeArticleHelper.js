({
    SearchHelper: function(component, event,helper) {
        // show spinner message
        //component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.getArticles");
        action.setParams({
            'searchVar': component.get("v.searchVar")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            //  component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set searchResult list with return value from server.
                component.set("v.articles", storeResponse); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    getrecentPublishedarticle: function(component, event,helper) {
        // show spinner message
        //component.find("Id_spinner").set("v.class" , 'slds-show');
        console.log('insidehelpermethod');
        var action = component.get("c.getrecentpublishedarticles");
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            //  component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set searchResult list with return value from server.
                component.set("v.articles", storeResponse); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})