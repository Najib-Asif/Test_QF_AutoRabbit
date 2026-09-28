({
    myAction : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = $A.get("$Label.c.KM_Customer_community_Base_URL");
        var lastSlash = urlString.lastIndexOf("/")
        var topicName = urlString.substring(lastSlash + 1);
        var initcaptpc = topicName.charAt(0).toUpperCase() + topicName.slice(1).split('?')[0]; //CRM-8809
        component.set("v.cbaseURL", baseURL);
        component.set("v.ctopic", initcaptpc);
    }
})