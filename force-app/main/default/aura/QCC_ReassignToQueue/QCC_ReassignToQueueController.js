({
    doInit :function (component, event, helper) {
        var action = component.get('c.getlistQueues');
        component.set("v.Spinner", true);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var opts = response.getReturnValue();
                component.set("v.options", opts);
            }
            component.set("v.Spinner", false);
        })
        $A.enqueueAction(action); 
        
    },
    doAssign :function (component, event, helper) {
        var btn = event.getSource();
        //deactivate the Button
		btn.set("v.disabled",true);
        component.set("v.Spinner", true);
        
        var action = component.get('c.reassignToQueue');
        action.setParams({ caseId : component.get("v.recordId"),
                          queueName : component.get('v.selectedQueue') });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS' && response.getReturnValue() != '') {
                var rs = response.getReturnValue();
                if(rs != null && rs != ''){
                    helper.displayToastMessage('success',"Case Saved", "The Case assigned to "+rs+".", 10);
                    component.set('v.selectedQueue'," ");
                    $A.get("e.force:refreshView").fire();
                }else{
                    helper.displayToastMessage('error',"Case not Saved", "Can not assign Case to other Queue", 10);
                }
            }else{
                helper.displayToastMessage('error',"Case not Saved", "Can not assign Case to other Queue", 10);
            }
            
            //reactivate the Button
            btn.set("v.disabled",false);
            component.set("v.Spinner", false);
        })
        $A.enqueueAction(action);    
    }
})