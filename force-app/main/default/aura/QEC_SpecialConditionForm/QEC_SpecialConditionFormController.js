({
    doInit : function(component, event, helper) {
        var type = component.get("v.type");
        var fields = component.get("v.fieldMap")[type];
        component.set("v.fields",fields);
        //helper.getObjectType(component);
        helper.refreshDestinationList(component);
    },
    handleChange : function(component, event, helper) {
        helper.refreshDestinationList(component);
    },
    handleRowDelete : function(component, event, helper) {
        var rowIndex  = event.getParam("rowIndex");
        var allRows = component.get("v.specialConditionList");
        allRows.splice(rowIndex,1);
        component.set("v.specialConditionList",allRows);
    },
    handleRowClone : function(component, event, helper) {
        var specialCondition = event.getParam("specialCondition");
        var rowIndex = event.getParam("rowIndex");
        var allRows = component.get("v.specialConditionList");
        var fields = component.get("v.fields");
        var x;
        for (x of fields) {
            specialCondition[x.fieldName]='';
        }
        allRows.splice(rowIndex+1, 0, specialCondition);
        component.set("v.specialConditionList",allRows);
    },
    handleSave : function(component, event, helper) {
        var button = event.getSource();
        button.set('v.disabled',true);
        var action = component.get("c.insertRecords");
        action.setParams({
            specialConditionList : component.get("v.specialConditionList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type":"success",
                    "message": "The records were saved."
                });
                resultsToast.fire();
                var event = component.getEvent("refreshDataEvent")
                event.fire();
                component.set("v.specialConditionList",null)
            }
            else {
                var errors  = response.getError();
                let message = 'Unknown Error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("inside error " + JSON.stringify(errors[0]));
                    message = errors[0].message;
                }
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type":"error",
                    "message": message
                });
                resultsToast.fire();
                console.log("inside error response");
                button.set('v.disabled',false);
            }
        });
        $A.enqueueAction(action);
    },
})
// <!-- Controller--><!-- Controller-->