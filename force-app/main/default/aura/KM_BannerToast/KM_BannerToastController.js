({	
    doInit : function(component, event, helper) {
        var action = component.get('c.fetchBannerText');
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Push success : '+JSON.stringify(response.getReturnValue()));
                component.set('v.myVal', response.getReturnValue()[0]);
            }
        });
        $A.enqueueAction(action);
	},
	closeMsg : function(component, event, helper) {
        var bannerElement = component.find("banner");
        $A.util.addClass(bannerElement, "slds-hide");
	}
})