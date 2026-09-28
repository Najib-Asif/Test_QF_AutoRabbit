({
    doInit : function(component, event, helper)
    {
        console.log('inside signout doInit');
        //component.set("v.showSpinner", true);
    },
    logOut : function(component, event, helper)
    {
        component.set("v.showSpinner", true);
        
        var action = component.get('c.getSignOutURL');
        action.setCallback(this, function (response) {
            var output = response.getReturnValue();
	        console.log('signout response**'+output);
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                if(output){
                    console.log('Successfully reassigned Cases!');
                    component.set("v.baseUrl", output);
                    helper.displayToast(component,'valid','info', 'Logging Out...', 'Cases has been re-assigned. Thank you for using Salesforce.',1000);
                }
                else{
                    component.set("v.showSpinner", false);
                    helper.displayToast(component,'invalid','info', 'Processing...', 'Please Re-assign the cases that you own',1000);
                }
            }
        })
        $A.enqueueAction(action); 
        
    },
    closeModal : function(component, event, helper) {
        //$A.get('e.force:refreshView').fire();
        helper.toggleCurrentUtility(component);
    }
})