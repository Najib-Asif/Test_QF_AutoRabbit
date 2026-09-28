({
    doInit : function(component, event, helper) {
        var action = component.get("c.getClonedProposal");
        
        action.setParams({
            "propId" : component.get("v.recordId")
        });
        console.log("propId :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            
            var output = response.getReturnValue();
            var state = response.getState();
            var recID = response.getReturnValue().recID;

            var resultsToast = $A.get("e.force:showToast");
          //  component.find("edit").get("e.recordSave").fire();
            if(component.isValid() && state == "SUCCESS" && output.isSuccess){
                
                // Prepare a toast UI message
                resultsToast.setParams({
                    "title": "Proposal has been Cloned",
                    "type": "success",
                    "message": output.msg
                    
                });
                // Navigate back to the record view
            var navigateEvent = $A.get("e.force:navigateToSObject");
          navigateEvent.setParams({ "recordId": recID});
          navigateEvent.fire(); 
                $A.get("e.force:refreshView").fire();
                //window.sfdcPage.makeRLAjaxRequest(null,window.sfdcPage.relatedLists[4].listId);
                
            } 
            else if (state == "ERROR" || !output.isSuccess) {
                var errors = response.getError();
                console.log("inside error");
                
                if (errors[0] && errors[0].message) {
                    // Did not catch on the Server Side
                    
                    var msgText = errors[0].message;
                    var errorText = "first error:";
                    if(msgText.includes(errorText))
                        msgText = msgText.split(errorText)[1];
                    
                    resultsToast.setParams({
                        "title": "Error Occured:",
                        "type": "error",
                        "mode": "sticky",
                        "message": msgText
                    });
                } 
                else if ( !output.isSuccess ) {
                    // Did catch on the Server Side
                    resultsToast.setParams({
                        "title": "Error Occured:",
                        "type": "error",
                        "mode": "sticky",
                        "message": output.msg
                    });
                }
            }
            $A.get("e.force:closeQuickAction").fire();
            resultsToast.fire();
            // Navigate back to the record view
          //  var navigateEvent = $A.get("e.force:navigateToSObject");
          //  navigateEvent.setParams({ "recordId": "0010l00000800GIAAY"});
          //  navigateEvent.fire();
        });
        $A.enqueueAction(action);
        
        
    },
    closeeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
        $A.get("e.force:closeQuickAction").fire() ;

        
   }
})