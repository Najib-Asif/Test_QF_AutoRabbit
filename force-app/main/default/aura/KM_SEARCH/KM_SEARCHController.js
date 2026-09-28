({
    myAction : function(component, event, helper) {
        var baseURL = $A.get("$Label.c.KM_Customer_community_Base_URL");
        component.set("v.cbaseURL", baseURL);                     
    }
})