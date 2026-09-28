({
    doInit : function(component, event, helper) {
        var recID = component.get("v.recordId");
        if(recID.startsWith("003")){
            component.set("v.onContact", true);
            helper.getContact(component, true); 
        }
    }
})