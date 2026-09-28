({
    doInit : function(component, event, helper) {
        var specialConditionList = component.get("v.specialConditionMap")[component.get("v.type")];
        component.set("v.specialConditionList", specialConditionList);
        var fieldList = ["QEC_Origin__c","QEC_Destination__c", "QEC_Cabin__c", "QEC_Booking_Class__c"];
        var fieldObject = component.get("v.fieldMap")[component.get("v.type")];
        if(fieldObject != null) {
            fieldObject.forEach(function (item, index){
                fieldList.push(item.fieldName);
            })
        }
        component.set("v.fields",fieldList); 
    },
    removeRow : function(component, event, helper) {
        var recordId = event.target.name;
        var action = component.get("c.deleteRecord");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type":"success",
                    "message": "The record was deleted."
                });
                resultsToast.fire();
                var event = component.getEvent("refreshDataEvent")
                event.fire();
            }
        });
        $A.enqueueAction(action);
    }
})