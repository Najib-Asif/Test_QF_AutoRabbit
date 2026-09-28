({
	getUrl : function(component) {
		var action = component.get("c.getURLAddress");
        var pnr = component.get("v.pnr");
        action.setCallback(this, function (response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var resp = response.getReturnValue();
                var url = resp[0].ARD_Url__c;
                url = url.replace('{pnrnum}',pnr);
                component.set("v.ardURL", url);
                component.set("v.isEnabled",resp[0].ARD_Enabled__c );
                
            }
        });
        $A.enqueueAction(action);
	},
    
    gotoURL : function (url) {
    	var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url,
            "target": "_blank"
        });
        urlEvent.fire();
    },
    
    
    

    
})