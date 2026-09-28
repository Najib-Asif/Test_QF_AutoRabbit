({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchRelationshipfields");
        action.setParams({
            "ConId" : component.get("v.recordId")
        });
      //  console.log("ConId :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            
            var output = response.getReturnValue();
            var state = response.getState();
           // console.log('####returnvalue'+response.getReturnValue());
            //console.log('$$$$'+response.getReturnValue().recID);
           
            var resultsToast = $A.get("e.force:showToast");
            var parentId = component.get('v.recordId');
            //console.log('####parentId'+response.getReturnValue());
			//var val1  = response.getReturnValue();
			
          //  console.log('####returnvalueval1'+response.getReturnValue());
            
            if(component.isValid() && state == "SUCCESS" && output.isSuccess){
                
                // Prepare a toast UI message
                resultsToast.setParams({
                    "title": "Frequent Flyer Information has been converted to Contact successfully!",
                    "type": "success",
                    "message": output.msg
                    
                });
                
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
            
            var createRecordEvent = $A.get("e.force:createRecord");         
            //console.log('####'+recordID);
            createRecordEvent.setParams(
			{
			   "entityApiName": 'AccountContactRelation',
               'defaultFieldValues': 
                    {
                		'ContactId':parentId,
                       
          			}
			}
			);
				createRecordEvent.fire();
        });
        
        $A.enqueueAction(action);
        
    }
})