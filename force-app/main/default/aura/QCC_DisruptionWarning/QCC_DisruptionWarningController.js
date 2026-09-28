({
	doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        console.log('disrup recId' , recId);
        helper.getRelatedPassenger(component, event, helper);
    }
})