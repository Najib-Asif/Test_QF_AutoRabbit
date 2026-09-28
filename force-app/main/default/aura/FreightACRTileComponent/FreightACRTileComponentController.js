({
    doInit : function(component, event, helper) {
        
        // Get a reference to the getACRRecords() function defined in the Apex controller
        var action = component.get("c.getACRRecord");
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));
        
        // Register the callback function
        action.setCallback(this, function(data) {
            component.set("v.accCR", data.getReturnValue());
        });
        
        // Invoke the service
        $A.enqueueAction(action);
    },
    
    toggleMenu : function(component, event, helper) {
        component.set("v.menuSwitch", !component.get("v.menuSwitch"));
        console.log("Menu switch :" + component.get("v.menuSwitch"));
    }
})