({
	doInit : function(component, event, helper) {
		helper.getRecordType(component);
	},
    
    createRecord : function(component, event, helper) {
        //var selectedVal = component.find("mygroup").get("v.value");
        var selectedVal = event.getParam("value");
        //alert("You have chosen "+selectedVal);
        var createRecordEvent = $A.get("e.c:QCC_CreateRecordEvent");
        createRecordEvent.setParams({
            "recordTypeId": selectedVal
        });
        createRecordEvent.fire();
        //component.find("overlayLib").notifyClose();
        component.destroy();
    },
    closeMe : function(component, event, helper)  { 
        component.destroy();
    }
})