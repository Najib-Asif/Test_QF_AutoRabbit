({
    doInit :function (component, event, helper) {
        var action = component.get('c.getlistrecType');
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
        
        var action = component.get('c.reassignToRecordType');
        var recID = component.get("v.recordId");
        action.setParams({ caseId : component.get("v.recordId"),
                          recTypeName : component.get('v.selectedrecType') });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var output = response.getReturnValue();
             var resultsToast = $A.get("e.force:showToast");
            if (component.isValid() && state === 'SUCCESS' && response.getReturnValue() != '') {
                var rs = response.getReturnValue();
                if(rs != null && rs != ''){
                  //  helper.displayToastMessage('success',"Case Saved", "The Case has been assigned to record type "+rs+".", 10);
                    component.set('v.selectedrecType'," ");
                                // Prepare a toast UI message
                resultsToast.setParams({
                    "title": "Case Recordtype has been updated!",
                    "type": "success",
                    "message": output.msg
                    
                });    
                    // Navigate back to the record view
            var navigateEvent = $A.get("e.force:navigateToSObject");
          navigateEvent.setParams({ "recordId":recID });
          navigateEvent.fire(); 
               // $A.get("e.force:refreshView").fire();
                    $A.get("e.force:refreshView").fire();
                }else{
                   // helper.displayToastMessage('error',"Case not Saved", "Can not assign Case to the metioned record type", 10);
                }
            }else{
               // helper.displayToastMessage('error',"Case not Saved", "Can not assign Case to the metioned record type", 10);
            }
            
            //reactivate the Button
            btn.set("v.disabled",false);
            component.set("v.Spinner", false);
            $A.get("e.force:closeQuickAction").fire();
            resultsToast.fire();
        })
        $A.enqueueAction(action);    
    }
})