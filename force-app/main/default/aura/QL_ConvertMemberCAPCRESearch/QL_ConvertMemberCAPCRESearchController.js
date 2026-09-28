({
    doInit : function(component, event, helper) {
        var action = component.get("c.invokeWebServiceCAPSearch");
        action.setParams({
            "memID" : component.get("v.recordId")
        });
        console.log("memID :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            
            var output = response.getReturnValue();
            var state = response.getState();
            console.log('####1'+response.getReturnValue());
            console.log('$$$$'+response.getReturnValue().recID);
            var recordID = response.getReturnValue().recID;
           
            var resultsToast = $A.get("e.force:showToast");
            
            if(component.isValid() && state == "SUCCESS" && output.isSuccess){
                
                // Prepare a toast UI message
                resultsToast.setParams({
                    "title": "Member has been converted to Contact successfully!",
                    "type": "success",
                    "message": output.msg
                    
                });

                var editRecordEvent = $A.get("e.force:editRecord");
                console.log('####'+recordID);
                editRecordEvent.setParams({"recordId": recordID});
                editRecordEvent.fire();                
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
            
            //var editRecordEvent = $A.get("e.force:editRecord");
            //console.log('####'+recordID);
            //editRecordEvent.setParams({"recordId": recordID});
            //editRecordEvent.fire();
            
            $A.get("e.force:closeQuickAction").fire();
            resultsToast.fire();
            
        });
        
        $A.enqueueAction(action);
        
    }
})