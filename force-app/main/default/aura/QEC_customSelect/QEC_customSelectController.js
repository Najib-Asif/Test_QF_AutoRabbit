({
	doInit : function(component, event, helper) {
		var pickListName = component.get("v.pickListName");
        var optionValues = component.get("v.pickListMap")[pickListName];
        component.set("v.pickListValues",optionValues);
    },
    handleChange : function(component, event, helper){
        var fieldValue = component.get("v.selectedOption");
        var fieldName = component.get("v.pickListName")
        var selectEvent = component.getEvent("selectEvent");
        selectEvent.setParams({
            "field":fieldName,
            "value":fieldValue
        });
        selectEvent.fire();
    }
})