({
	handleRecordUpdate: function(component, event, helper) {
        var eventParams = event.getParams();

        var currencyLeft3 = '';
        if(component.get("v.simpleRecord.Original_Currency__c")){
            currencyLeft3 = component.get("v.simpleRecord.Original_Currency__c").substring(0, 3);
        }

        var monetaryValue = '';
        if(component.get("v.simpleRecord.Monetary_Value__c") != null){
            monetaryValue = component.get("v.simpleRecord.Monetary_Value__c").toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
        }

        if(eventParams.changeType === "LOADED") {
            component.set("v.currencyLeft3", currencyLeft3);
            component.set("v.monetaryValue", monetaryValue);
            component.find("recordHandler").reloadRecord();
        }
        if(eventParams.changeType === "CHANGED") {
            component.set("v.currencyLeft3", currencyLeft3);
            component.set("v.monetaryValue", monetaryValue);
            component.find("recordHandler").reloadRecord();
            if(!component.get("v.submitted") && component.get("v.simpleRecord.Status__c") == "Open" && (component.get("v.simpleRecord.Type__c") != null || (eventParams.changedFields.Type__c && eventParams.changedFields.Type__c.value != null))){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Please Submit this Recovery!",
                    message: "This recovery has not yet been submitted! Please scroll up to Submit",
                    type: "warning"
                });
                toastEvent.fire();
            }
        }

    },
	submitRecord : function(component, event, helper) {

        // show loading spinner
        component.set("v.Spinner", true); 
        component.set("v.submitted", true);

        var recoveryUpdate = component.get("v.simpleRecord");
        recoveryUpdate.Status__c = 'Submitted';
        recoveryUpdate.Process_Status__c = 'Pending Approval';
        component.set("v.simpleRecord", recoveryUpdate);
        component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
           
            if (saveResult.state === "SUCCESS") {
                // handle component related logic in event handler
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "success",
                    "title": "Recovery Updated",
                    "message": "The Recovery record has been submitted successfully.",
                    duration : 10
                });
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();               
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Canot Submit Recovery",
                    "message": saveResult.error[0].message,
                    "mode": "sticky"
                });
                resultsToast.fire();
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }

            // hideSpinner loading spinner
            component.set("v.Spinner", false);

        }));
    },
})