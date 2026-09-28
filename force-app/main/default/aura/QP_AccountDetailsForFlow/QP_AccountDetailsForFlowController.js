({
	doInit : function(component, event, helper){
        var action = component.get("c.getAccountRecord");
        
        action.setParams({
            "accId" : component.get("v.recordId")
        });
        console.log("accId :" + component.get("v.recordId"));  
        
        action.setCallback(this, function(response) {
            var output = response.getReturnValue();
            console.log("output** :" + JSON.stringify(output));

            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.existingAccount",output.existingAccount);
                component.set("v.accBillingCountry",output.existingAccount.BillingCountry);
                component.set("v.activeContract",output.activeChannelContract);
                component.set("v.contractRTId",output.ctrtRTId);
                component.set("v.accAddress",output.accountAddress);
                component.set("v.authorizedUser", output.authorizedUser);
                component.set("v.authorizedAccount", output.authorizedAccount);
            } 
        });
        $A.enqueueAction(action);
    }
})