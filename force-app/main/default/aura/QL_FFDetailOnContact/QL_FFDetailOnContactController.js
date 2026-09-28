({
    
    doInit : function(component, event, helper) {
        var recID = component.get("v.recordId");
        if(recID.startsWith("003")){
            component.set("v.onContact", true);
        }
        if(recID.startsWith("500")){
            component.set("v.onCase", true);
        } 
        helper.getContact(component, event, helper);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log(userId);
    }
})