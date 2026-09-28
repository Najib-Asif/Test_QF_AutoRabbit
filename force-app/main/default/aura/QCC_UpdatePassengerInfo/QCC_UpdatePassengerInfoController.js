({
    doInit : function(component, event, helper) {
        var action = component.get('c.updatePassengerforEvent');
        action.setParams({ eventId : component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS' && response.getReturnValue() != '') {
                $A.get("e.force:refreshView").fire(); 
                 var msgval = '$label.c.QCC_PassengerAPIInvokeMSG';
                 var msg = $A.get(msgval);
                //var msg1 = $A.get('$label.c.QCC_PassengerAPIinProgressMSG');
                console.log('1111111111111',msg);
                var resp = response.getReturnValue();
                component.set('v.msg',resp);
                
                component.set('v.isVisible',true);
            }else{
                let errors = response.getError();
                let message = 'Issue in invoking Passenger API'; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set('v.msg',message);
                component.set('v.isVisible',false);
            }
        })
        $A.enqueueAction(action); 
    },
    
    doClosePanel : function(component, event, helper) {
        $A.get("e.force:refreshView").fire(); 
        $A.get("e.force:closeQuickAction").fire();
        
    }
})