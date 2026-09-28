({
    onConfirm : function(component, event, helper) {
        //CRM-7179
        debugger;
        var contactInfo = {"lastName": component.get("v.lastName"), 
                           "firstName": component.get("v.firstName"),
                           "ffNumber": component.get("v.ffNumber"),
                           "ffTier": component.get("v.ffTier"),
                           "capId": component.get("v.capId"),
                           "phone": component.get("v.phone"),
                           "email": component.get("v.email")
                          };
        //CRM-8903 duplicate contact resolution
        component.set("v.disableAssignment", true);
        
        var action = component.get("c.invokeAssignContacttoCase");
        
        action.setParams({
            "contactInfo": JSON.stringify(contactInfo, null, 2),
            "recId": component.get("v.caseId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var response = response.getReturnValue();
                if(response === 'Pending_Recoveries') {
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        "type"		: "error",
                        "message"	: $A.get("$Label.c.QCC_PendingRecoveryMsg"),
                        "duration"	: 10
                    });
                    showToast.fire();
                 $A.get('e.force:refreshView').fire();//Added by raghav
                   // location.reload();
                } else {
                    $A.get('e.force:refreshView').fire();
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        "type"		: "success",
                        "message"	: $A.get("$Label.c.ContactAssignToastMsg"),
                        "duration"	: 10
                    });
                    showToast.fire();
                }
                
                 $A.get('e.force:refreshView').fire();//Added by raghav
                component.find("overlayLib").notifyClose();
                //location.reload();
            }
            // Added by Purushotham for Remediation hotfix -- START
			else if (state === "ERROR") {
                //$A.get('e.force:refreshView').fire();
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log('1111',errors[0].message);
                    message = errors[0].message;
                }
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    "type"		: "error",
                    "message"	: message,
                    "duration"	: 10
                });
                showToast.fire();
                 $A.get('e.force:refreshView').fire();//Added by raghav
                component.find("overlayLib").notifyClose();
                //location.reload();
                
            }
            // Added by Purushotham for Remediation hotfix -- END
        });
        $A.enqueueAction(action);
    }
})