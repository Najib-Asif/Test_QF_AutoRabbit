({
	handleEvent : function(component, event, helper) {
		var field  = event.getParam("field");
        var value = event.getParam("value");
        var specialCondition = component.get("v.specialCondition");
        specialCondition[field] = value;
        component.set("v.specialCondition",specialCondition);
        //console.log("special condition : " + JSON.stringify(component.get("v.specialCondition")));
	},
    handleChange : function(component, event, helper) {
        var element = event.getSource();
        var value = element.get("v.value");
        var field = element.get("v.name");
        var specialCondition = component.get("v.specialCondition");
        specialCondition[field] = value;
        component.set("v.specialCondition",specialCondition);
        //console.log("special condition : " + JSON.stringify(component.get("v.specialCondition")));
    },
    handleCheck : function(component, event, helper) {
        var element = event.getSource();
        var value = element.get("v.checked");
        var field = element.get("v.name");
        var specialCondition = component.get("v.specialCondition");
        specialCondition[field] = value;
        component.set("v.specialCondition",specialCondition);
        //console.log("special condition : " + JSON.stringify(component.get("v.specialCondition")));
    },
    removeRow : function(component, event, helper) {
        var event = component.getEvent("rowDeleteEvent");
        event.setParams({
            "rowIndex": component.get("v.rowIndex")
        });
        event.fire();
    },
    addNewRow : function(component, event, helper) {
        var event = component.getEvent("rowCloneEvent");
        event.setParams({
            "rowIndex": component.get("v.rowIndex"),
            "specialCondition": component.get("v.specialCondition")
        });
        event.fire();
    }
})