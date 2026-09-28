({
    doInit :function (component, event, helper) {
        console.log('inside owner_Util doInit');
        var action = component.get('c.getQACCaseQueues');
        component.set("v.showSpinner", true);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var opts = response.getReturnValue();
                console.log('output**'+JSON.stringify(opts));
                component.set("v.ApexController", opts);				                
                component.set("v.options", opts.allOptions);
            }
            component.set("v.showSpinner", false);
        })
        $A.enqueueAction(action); 
    },
    doAssign :function (component, event, helper) {
        var btn = event.getSource();
        btn.set("v.disabled",true); // de-activate the button after clicked
        component.set("v.showSpinner", true);
        
        var action = component.get('c.assignCaseQueue');
        action.setParams({
            queueName : component.get('v.selectedQueue')
        });
        action.setCallback(this, function (response) {
            var output = response.getReturnValue();
            console.log('output**'+JSON.stringify(output));
            component.set("v.ApexController", output);				                
            btn.set("v.disabled",false);
            
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS' && output) {
                if(output.isSuccess)
                {
                    $A.get("e.force:refreshView").fire();
                    helper.displayToast('success', 'Updated', output.msg, 1000);
                    component.set('v.selectedQueue'," ");
                    if(output.logoutInitiated == 'yes'){
                        setTimeout($A.getCallback(
                            // function(){} is replaced by () in ECMAscript 6
                            () => helper.openCaseOwnerUtility(component,'Logout')
                        ), 5000);                        
                        helper.changeCacheSession(component);
                    }
                }else{
                    helper.displayToast('error','Owner did not change', output.msg, 2000);
                    component.set("v.message", output.msg);
                    component.set("v.messageError", true);
                }
            }else{
                helper.displayToast('error','Case not Saved', output.msg, 2000);
                component.set("v.message", output.msg);
                component.set("v.messageError", true);
            }
            component.set("v.showSpinner", false);
            helper.toggleCurrentUtility(component);
        })
        $A.enqueueAction(action);    
    }
})