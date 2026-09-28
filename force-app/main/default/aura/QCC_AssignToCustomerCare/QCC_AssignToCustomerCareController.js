({
	doInit : function (component, event, helper) {
  
    },
    
    doAssign : function(component, event, helper) {
        //call to Apex back end to do the Assignment
        var action = component.get('c.doAssignToCustomerCare');
        action.setParams({ eventId : component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS' && response.getReturnValue() != '') {
                var rs = response.getReturnValue();
                if(rs != null && rs != '' && !rs.startsWith("Error: " )){
                    helper.displayToastMessage('success',"Event Saved", "The Event assigned to Customer Care Queue", 10);
                    $A.get("e.force:refreshView").fire();
                }else if(rs.startsWith("Error: " ) ){
                    helper.displayToastMessage('error', rs.substr(7), 10);
                }
            }else{
                helper.displayToastMessage('error',"Can not assign Event to Customer Care Queue", 10);
            }
            
            //close the QuickAction panel
            $A.get("e.force:closeQuickAction").fire();
        })
        $A.enqueueAction(action); 
    }
})