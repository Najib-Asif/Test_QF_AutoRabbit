({    
    // 11-Nov-2019	GRAPHITE-1151 | "Start Work" & "Resolve Case" Case Actions
    changeCaseStatus: function(component, event, helper){
        var recID = component.get("v.recordId");
        console.log('###recID child component' + recID);        
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        
        var action = component.get("c.changeCaseRecordStatus");
        action.setParams({"recId": recID});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.caseStatus", result.caseStatus);
                if (!result.hasError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success!',
                        message: 'The record has been updated successfully.',
                        duration: '5000',
                        type: 'success'
                    });
                    toastEvent.fire();                    
                }
                else {
                    var errorMsg = result.errorMessage;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error!',
                        message: errorMsg,
                        duration: '5000',
                        type: 'error'
                    });
                    toastEvent.fire();
                }
                $A.get('e.force:refreshView').fire();
                console.log("###result.hasError child component: " + result.hasError);
                console.log("###result.errorMessage child component: " + result.errorMessage);
                console.log("###result.caseStatus child component: " + result.caseStatus);
                $A.util.toggleClass(spinner, "slds-hide");
                $A.get('e.force:refreshView').fire();
            }
            else if (state == "ERROR") {
                var result = response.getReturnValue();
                var errors = response.getError();
                console.log("###result child component" + result);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error!',
                    message: 'Error!',
                    duration: '5000',
                    type: 'error'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
})