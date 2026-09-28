({
	disableButton : function(component, event) {
		var x;
        var preDefStatus = ["Awaiting Approval","Finalised","Approved","Submit for Finalisation","Awaiting Customer Response", "Submitted"];
        var accept_button1 = component.find("button1");
        var accept_button2 = component.find("button2");
        var recoveryStatus = component.get("v.simpleRecord.Status__c");
        var suggestedMin = component.get("v.simpleRecord.Suggested_Minimum__c");
        var suggestedMax = component.get("v.simpleRecord.Suggested_Maximum__c");
        if(suggestedMin == null && suggestedMax == null) {
            var toggleText = component.find("case2");
            $A.util.removeClass(toggleText, "slds-hide");
        }
        else if(suggestedMax == 0) {
            var toggleText = component.find("case3");
            $A.util.removeClass(toggleText, "slds-hide");
            component.set("v.myval", 0);
            component.set("v.type", 'Apology');
        }
        else if(suggestedMax < 0) {
            var toggleText = component.find("case4");
            $A.util.removeClass(toggleText, "slds-hide");
        }
            else {
                var toggleText = component.find("case1");
                $A.util.removeClass(toggleText, "slds-hide");
                component.set("v.myval",component.get("v.simpleRecord.Amount__c"));
                var toggleSlider = component.find("slider");
                $A.util.removeClass(toggleSlider, "slds-hide");
            }
        for(x in preDefStatus){
            if(recoveryStatus == preDefStatus[x]){
                if(accept_button1){
                    accept_button1.set("v.disabled", true);
                }
                
                if(accept_button2){
                    accept_button2.set("v.disabled", true);
                }
                
                break;
            }else{
                if(accept_button1){
                    accept_button1.set("v.disabled", false);
                }
                
                if(accept_button2){
                    accept_button2.set("v.disabled", false);
                }
            }
        }
	},
    getValueFromSlider: function(component, event, pointRecovery){
        var mySpinner = component.find("mySpinner");
        $A.util.removeClass(mySpinner, "slds-hide");
        var finalValue = component.get("v.myval");
        var type = component.get("v.type");
        console.log(type);
        console.log('finalVal '+finalValue);
        var action = component.get('c.updateRecovery');
        action.setParams({
            recId : component.get("v.recordId"),
            points: pointRecovery,
            type: type
        });
        action.setCallback(component, function(response){
            var state = response.getState();
            if (state === 'SUCCESS'){
                var val = response.getReturnValue();
                var arr = val.split(",");
                var resultsToast = $A.get("e.force:showToast");
                if(arr[0] == "true") {
                    resultsToast.setParams({
                        "type": "success",
                        "title": "Recovery Updated",
                        "message": "The Recovery record was updated.",
                        duration : 10
                    });
                    resultsToast.fire();
                    /*2018-May-31 change request for QDCUSCON-2866-Confirmation before submitting a Recovery*/
                    // call the flow Confirm message before submit recovery

                }
                if(arr[0] == "false") {
                    resultsToast.setParams({
                        "type": "error",
                        "title": "Recovery Update failed",
                        "message": arr[1],
                        duration : 10
                    });
                    resultsToast.fire();
                }
                $A.get('e.force:refreshView').fire();
            }
            $A.util.addClass(mySpinner, "slds-hide");
        });
        $A.enqueueAction(action);
        //location.reload();
        component.set("v.isOpen", false);
    },
})