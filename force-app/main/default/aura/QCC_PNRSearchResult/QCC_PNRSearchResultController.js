({
    doInit: function (component, event, helper) {
        var action = component.get("c.fetchColumn");
        action.setParams({
            "componentName": "QCC_PNRSearch"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.columns", JSON.parse(response.getReturnValue()));
                console.log("Response:", component.get("v.columns"));
            }
        });
        $A.enqueueAction(action);
    },
    updateSelectedText: function (component, event) {
        var selectedRow = event.getParam('selectedRows');
        component.set("v.selectedRow", selectedRow);
        component.set("v.showButton", true);
        var row = component.get("v.selectedRow");
        var button = component.get("v.showButton");
    },
    onConfirm: function (component, event, helper){
        helper.invokeCAPContact(component);
    },
    closeMe : function(component, event, helper)  { 
        component.destroy();
    }
})