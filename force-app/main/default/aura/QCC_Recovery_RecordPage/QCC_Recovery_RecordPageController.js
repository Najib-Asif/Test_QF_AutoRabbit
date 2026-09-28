({
    doInit : function(component,event,helper){
       
    },
    getValueFromSlider: function(component, event, helper){
        var mySpinner = component.find("mySpinner");
        $A.util.removeClass(mySpinner, "slds-hide");
        var finalValue = component.get("v.myval");
        var type = component.get("v.type");
        console.log(type);
        console.log('finalVal '+finalValue);
        var action = component.get('c.updateRecovery');
        action.setParams({
            recId : component.get("v.recordId"),
            points: finalValue,
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

    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            console.log("Record is loaded successfully.");
            helper.disableButton(component, event);
        } else if(eventParams.changeType === "CHANGED") {
            helper.disableButton(component, event);
            $A.get('e.force:refreshView').fire();
        } else if(eventParams.changeType === "REMOVED") {
        } else if(eventParams.changeType === "ERROR") {
        }
    },
    openModal: function(component, event, helper) {
        var selectedVal = component.get("v.myval");
        if(selectedVal == null) {
            component.set("v.myval", 0);
        }
        component.set("v.isOpen", true);
    },
    /*openModal: function(component, evt, helper) {
        var modalBody;
        var modalFooter;
        $A.createComponents([["c:QCC_ConfirmModal", {"myval":component.get("v.myval")}],
                           ["c:QCC_ModalFooter", {}]],
                           function(components, status) {
                               if (status === "SUCCESS") {
                                   modalBody = components[0];
								   modalFooter = components[1];
                                   component.find('overlayLib').showCustomModal({
                                       header: "Confirm?",
                                       body: modalBody,
                                       footer: modalFooter,
                                       showCloseButton: true,
                                       cssClass: "mymodal,my-custom-class,my-other-class"
                                   })
                                   
                               }
                               
                           });
    },*/
    
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    handleStatusChange:function(component, event, helper) {

        if(event.getParam("status") === "FINISHED") {
            component.set("v.isOpenFlowModal", false);
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "isConfirmed") {
                    var isConfirmed = outputVar.value;
                     if(isConfirmed){
                        var pointRecovery = component.get("v.myval");
                        helper.getValueFromSlider(component, event, pointRecovery);
                        return;
                    }
                } 
             }   
        }
    },
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpenFlowModal", false);
    },
})