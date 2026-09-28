({
    getFlightInfo : function(component) {
        var action = component.get("c.fetchEmailContent");
        var recID = component.get("v.recordId");
        action.setParams({
            "recId": recID
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var flights = JSON.parse(response.getReturnValue());
                component.set("v.lstFlights", flights);
                console.log('cols###',component.get("v.lstFlights"));
            }
        });
        $A.enqueueAction(action);
    }
})