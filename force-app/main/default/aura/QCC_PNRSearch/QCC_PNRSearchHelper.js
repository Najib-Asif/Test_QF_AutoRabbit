({
    invokeCAPSearch : function(component) {
        var action = component.get("c.invokePNRSearch");
        action.setParams({
            "pnr": component.get("v.pnr"),
            "lastName": component.get("v.lastName")
        });
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('Success###',response.getReturnValue());
                component.set("v.errMSG", '');
                var passenger = JSON.parse(response.getReturnValue());
                this.showPassenger(component, passenger);
            }
            else if (state === "ERROR") {
                console.log('Error##',response.getError());
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log('1111',errors[0].message);
                    message = errors[0].message;
                }
                component.set("v.errMSG", message);
                component.set("v.showModal", true);
                // Display the message
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    },
    
    showPassenger: function(component, passenger) {
        var modalBody;
        $A.createComponent("c:QCC_PNRSearchResult", {"data": passenger,
                                                     "pnr": component.get("v.pnr"),
                                                     "caseId": component.get("v.recId")
                                                    },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var targetCmp = component.find('overlayLib');
                                   var body = targetCmp.get("v.body");
                                   body.push(content);
                                   targetCmp.set("v.body", body); 
                                   modalBody = content;
                                   /*component.find('overlayLib').showCustomModal({
                                       header: "Select Passenger",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "mymodal"
                                   })*/
                               }                               
                           });
    }
})