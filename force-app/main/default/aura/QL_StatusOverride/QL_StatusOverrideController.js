({
    doInit : function(component, event, helper) {
        var action = component.get("c.getProposal");
        
        action.setParams({
            "propId" : component.get("v.recordId")
        });
        console.log("propId :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            
            var output = response.getReturnValue();
            var state = response.getState();

            var resultsToast = $A.get("e.force:showToast");
            
            if(component.isValid() && state == "SUCCESS" && output.isSuccess){
                
                // Prepare a toast UI message
                resultsToast.setParams({
                    "title": "Status Updated",
                    "type": "success",
                    "message": output.msg
                });
                
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
        });
        $A.enqueueAction(action);
        
    }
})