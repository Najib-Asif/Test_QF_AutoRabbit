({
	callInit : function(component, event, helper) {
		helper.getRecordType(component);
	},
    onSelectVal : function(component, event, helper) {
		helper.createCase(component,event);
	}
})