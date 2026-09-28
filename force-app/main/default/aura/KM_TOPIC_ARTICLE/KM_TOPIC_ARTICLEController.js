({
    myAction : function(component, event, helper) {
        var urlString = window.location.href;
        /*var baseURL = urlString.substring(0, urlString.indexOf("/s"));*/
        var baseURL = $A.get("$Label.c.KM_Customer_community_Base_URL");
        var lastSlash = urlString.lastIndexOf("/")
        var urlname = urlString.substring(lastSlash + 1);
        component.set("v.cbaseURL", baseURL);
        var topicName = component.get("c.getTopic");
        topicName.setParams({artUrl : urlname});       
        topicName.setCallback(this, function(response){
            var records = response.getReturnValue();
            if(records != null && response.getState() === 'SUCCESS'){
                component.set("v.ctopic", records.Name);
                component.set("v.ctopicid", records.Id);
                component.set("v.showtopic", true);
                var topicurl = baseURL+'/s/topic/'+ records.Id + '/'+ records.Name;
                component.set("v.ctopicurl",topicurl)
            }else{
                component.set("v.showtopic", false);
            }
        });
        $A.enqueueAction(topicName);
    }
})