({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get('c.submitUpdateforEvent');
        action.setParams({ eventId : component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.showSpinner", false);
            console.log(state);
            if (component.isValid() && state === 'SUCCESS' && response.getReturnValue() != '') {
                var rs = response.getReturnValue();
                if(rs != null && rs != '' && !rs.startsWith("Error: " )){
                    $A.get("e.force:refreshView").fire();
                }else if(rs.startsWith("Error: " ) ){
                    console.log('error');
                }
            }else{
            }
            //close the QuickAction panel
            //$A.get("e.force:closeQuickAction").fire();
        })
        $A.enqueueAction(action); 
    },
    
    doClosePanel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})