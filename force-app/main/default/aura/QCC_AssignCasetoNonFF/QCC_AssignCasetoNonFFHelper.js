({
	assigntoGenericCon: function(component) {
        var recId = component.get("v.recId");
        var action = component.get("c.assigntoGenericContact");
        action.setParams({
            "caseId": recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var response = response.getReturnValue();
                if(response === 'success') {
                    $A.get('e.force:refreshView').fire();
                    //component.set("v.showModal", true);
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        "type"		: "success",
                        "message"	: $A.get("$Label.c.ContactAssignToastMsg"),
                        "duration"	: 10
                    });
                    showToast.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recId,
                        "slideDevName": "detail" //related , detail, chatter
                    });
                    navEvt.fire();
                }
                else if(response === 'Pending_Recoveries') {
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        "type"		: "error",
                        "message"	: $A.get("$Label.c.QCC_PendingRecoveryMsg"),
                        "duration"	: 10
                    });
                    showToast.fire();
                }
                
            } else if (state === "ERROR") {
                console.log('Error##',response.getError());
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log('1111',errors[0].message);
                    message = errors[0].message;
                }
                component.set("v.errMSG", message);
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    "type"		: "error",
                    "message"	: message,
                    "duration"	: 10
                });
                showToast.fire();
                var toggleText = component.find("compId");
                $A.util.addClass(toggleText, "toggle");
                // Display the message
                console.error(message);
            }
        });
        $A.enqueueAction(action);
    },
    
    validateContact : function(component) {
        var placeholderRecTypeId = $A.get("$Label.c.QCC_ContactPlaceholderRecTypeId");
        var recTypeId = component.get("v.simpleCase.Contact.RecordTypeId");
        console.log('Rec Type ID = '+recTypeId);
        if(recTypeId == placeholderRecTypeId) {
            component.set("v.disabled", true);
        } else {
            component.set("v.disabled", false);
        }
    },
})