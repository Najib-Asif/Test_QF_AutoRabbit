({
       accountSelected : function(component) {
        var event = $A.get("e.c:AccountSelected");
        event.setParams({"account": component.get("v.account")});
        event.fire();
       // var selected = component.get("v.account");
       // var deselected = component.get("v.deSelected");
       // helper.accountDeSelectedfunction(component, event, helper,selected,deselected);
    },
    
})