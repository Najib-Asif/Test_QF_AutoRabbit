({
    doInit : function(component, event, helper) {
        var action = component.get("c.getGenerateInvoice");
        
        action.setParams({
            "contId" : component.get("v.recordId")
        });
        console.log("contId :" + component.get("v.recordId"));
        action.setCallback(this, function(response) {
            
            var output = response.getReturnValue();
            var state = response.getState();
            var errors = response.getError();
            console.log("propId2"+state+" "+JSON.stringify(errors));
            //var recID = response.getReturnValue().recID;
            //console.log("Record Id"+recID);
            var resultsToast = $A.get("e.force:showToast");
            if( state == "SUCCESS" && output.isSuccess){
                
                // Prepare a toast UI message
                resultsToast.setParams({
                    "title": "Invoice Created",
                    "type": "success",
                    "message": output.msg
                    
                });
                $A.get("e.force:refreshView").fire(); 
            }
            else if (!output.isSuccess) {
                var errors = response.getError();
                console.log("inside error");
                //console.log(output);
                //console.log(output.msg);
                resultsToast.setParams({
                    "title": "Error in generating Invoices",
                    "type": "Error",
                    "mode": "sticky",
                    "message": output.msg
                });
                
            }
            
            $A.get("e.force:closeQuickAction").fire(); 
          /*  setTimeout(()=>{
                let quickActionClose = $A.get("e.force:closeQuickAction");
                quickActionClose.fire();
            },1000); */
            resultsToast.fire();
        });
        $A.enqueueAction(action);
        
    }
})