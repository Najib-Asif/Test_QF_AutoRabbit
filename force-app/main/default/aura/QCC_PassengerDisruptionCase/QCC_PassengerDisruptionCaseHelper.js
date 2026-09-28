({
	init: function(component){
        var action = component.get('c.getPassengerRecords');
        action.setParams({ 
            caseId : component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult){
            var state = actionResult.getState();
            if (state === "SUCCESS")
            {
                var result = actionResult.getReturnValue();
                
                var activeSection = [];
                for(var x=0; x < result.length; x++){
                    activeSection[activeSection.length] = result[x].sectionName;
                }
                component.set("v.activeSections", activeSection);
                
                component.set("v.listFieldInFieldSet", result);
                console.log('QCC_PassengerDisruptionCaseHelper: result' + actionResult.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})