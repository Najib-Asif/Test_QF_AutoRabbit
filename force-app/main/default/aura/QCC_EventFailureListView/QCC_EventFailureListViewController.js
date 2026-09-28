({
    doInit : function(component, event, helper) {
        var recID = component.get("v.recordId");
        //alert(recID);
        helper.fetchEventFailures(component);
    },
    
    handleClick : function (component, event, helper) {
        console.log(component.get("v.value"));
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire()
    }
    
 })