({
    getRelatedPassenger : function(component,event,helper) {
        var action = component.get("c.getRelatedPassengerRec");
        console.log('QCC_DisruptionWarningHelper getRelatedPassenger function');
        action.setParams({
            "contactId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                if(!result.hasError){
                    component.set("v.iconToDisplay", result.iconToDisplay);
                    //console.log('result.iconToDisplay == ',result.iconToDisplay);
                    //if(result.iconToDisplay === "greenIcon"){
                    //    component.set("v.descriptionToDisplay", "All Green");
                    //}
                    component.set("v.disruptionEvents", result.disruptionEvents);
                    component.set("v.isTableVisible", result.disruptionEvents.length > 0);
                }
            } else if (response.getState() === "ERROR") {
                var errorMsg = response.getError();;
                console.log(errorMsg);
                var error = "Error";
            }
        });
        $A.enqueueAction(action);
    }
})