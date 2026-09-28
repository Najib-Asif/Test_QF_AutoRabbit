({
    getCheckboxValues: function(component, event, helper) {
        var action = component.get("c.retrieveCheckboxValues");
        action.setParams({
            "RecId":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            component.set('v.valueWC', returnValue.strWheelChair);
            component.set('v.valueMCNE', returnValue.strNoEquipment);
            component.set('v.valueMCPAP', returnValue.strCBAP);
            component.set('v.valueMCOD', returnValue.strOxygenDomestic);
            component.set('v.valueMCOIQ', returnValue.strIntQantas);
            component.set('v.valueMCOITO', returnValue.strIntTravel);
            component.set('v.valueMCS', returnValue.strMCStretcher);
            component.set('v.valueSD', returnValue.strServiceDog);
            component.set('v.valueBCB', returnValue.strBaggageCBBG);
            component.set('v.valueBMBW', returnValue.strBaggageMBW);
        });
        $A.enqueueAction(action);
    },
    
    saveCheckboxValues: function(component, event, helper) {
        var eventSource = event.getSource();
        var auraId = eventSource.getLocalId();
        var attributeName = auraId.replace("recordForm", "");
        var caseRecord = component.get("v.caseRecord");
        
        //Check whether case record should be updated or not.
        var isNew = false;
        if ($A.util.isUndefinedOrNull(caseRecord.QCC_Specific_Needs__c) || $A.util.isEmpty(caseRecord.QCC_Specific_Needs__c)) {
            isNew = true;
        }
        var successMessage = isNew ? "Specific Needs Record has been successfully created." : "Specific Needs Record has been successfully updated.";
        
        //Generate the Specific Needs record to be updated.
        var specificNeedRecord = {};
        specificNeedRecord.Id = event.getParam("id");
        var options = component.get("v.options" + attributeName);
        
        //Reset the checkbox based on the checkbox group
        for(var x = 0; x < options.length; x++) {
            specificNeedRecord[options[x].value] = false;
        }
        
        //Set the field value to true for those checkbox that is selected.
        var selectedValues = component.get("v.value" + attributeName);
        for (var x = 0; x < selectedValues.length; x++) {
            specificNeedRecord[selectedValues[x]] = true;
        }
        
        var action = component.get("c.updateSpecificNeedRecord");
        action.setParams({
            "caseRecordId": component.get("v.recordId"),
            "specificNeedRecord": JSON.stringify(specificNeedRecord),
            "isNew": isNew
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.find('notifLib').showToast({
                    "variant": "Success",
                    "title": "Success",
                    "message": successMessage 
                });
                window.location.reload();
            } else if(state === "ERROR"){
                console.log(response.getError());
            }
        });        
        $A.enqueueAction(action);
    },
    getFields: function(component, event, helper) {
        var action = component.get("c.getMetadataFields");
        action.setParams({
            //"RecId":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnValue = response.getReturnValue();
                for(var i=0 ; i < returnValue.length ; i++ ){
                    var fields = returnValue[i].fields;
                    var sectionName = returnValue[i].sectionName;
                    component.set("v.fields" + sectionName, fields);
                }
            }else{
                //error
            }
            
        });
        $A.enqueueAction(action);
    }
})