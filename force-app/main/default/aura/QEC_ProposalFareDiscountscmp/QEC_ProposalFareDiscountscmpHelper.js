({
    addModifiedRecords : function(component, event, helper){
        var modifiedArray = component.get("v.modifiedList");
        var target = event.target;
        var dataSelectedIndex = target.getAttribute("data-selected-Index");
        const listIndex = modifiedArray.findIndex( x => x.index == dataSelectedIndex );
        if (listIndex == '-1') { //Added as a part of CRM-8071
            let element = { index : dataSelectedIndex };
            if (target.name == 'Tier1') {
                element.tier1Value = target.value;
            } else if(target.name == 'Tier2') {
                element.tier2Value = target.value;
            }
            modifiedArray.push(element);
        } else {
            if (target.name == 'Tier1') {
                modifiedArray[listIndex].tier1Value = target.value;
            } else if(target.name == 'Tier2') {
                modifiedArray[listIndex].tier2Value = target.value;
            }
        }
        component.set("v.modifiedList", modifiedArray);
    },
    saveDiscounts : function(component, event, helper) {
        var action = component.get("c.saveDiscountObject");
        var dummyObject = component.get("v.modifiedList");
        var discountObject = component.get("v.fareDiscountsList");
        var modifiedArray = [];
        for(let i = 0; i < dummyObject.length; i++) {  //Added as a part of CRM-8071
            let element = { Id : discountObject[dummyObject[i].index].Id };
            if (dummyObject[i].tier1Value != 'undefined') {
                element.QL_Tier_1_Offering__c = dummyObject[i].tier1Value;
            }
            if (dummyObject[i].tier2Value != 'undefined') {
                element.Discount__c = dummyObject[i].tier2Value;
            }
            modifiedArray.push(element);
        }
        if(modifiedArray.length <= 0){
            var evt = $A.get("e.force:showToast");
                evt.setParams({
                    mode: 'sticky',
                    message: 'Please change at least one discount to proceed',
                    type : 'info',
                    duration:'50',
                    mode: 'dismissible'
                });
                evt.fire();
        }else{
        action.setParams({
            discountString: JSON.stringify(modifiedArray)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var successEvent = $A.get("e.force:showToast");
                successEvent.setParams({
                    mode: 'sticky',
                    message: 'Fare Discounts saved successfully',
                    type : 'success',
                    duration:'50',
                    mode: 'dismissible'
                });
                successEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            }else{
                var errorEvent = $A.get("e.force:showToast");
                errorEvent.setParams({
                    mode: 'sticky',
                    message: 'Please contact System Administrator',
                    type : 'error',
                    duration:'50',
                    mode: 'dismissible'
                });
                errorEvent.fire();
            }
        });
            $A.enqueueAction(action);
        }
        // component.set("v.modifiedList", null);
    },
    
    fetchProposal : function(component, event, helper) {
        var action = component.get("c.getFareDiscounts");
        var record_id = component.get("v.recordId");
        action.setParams({
            recordid: record_id
        });
        // Callback function to get the response
        action.setCallback(this, function(response) {
            var state = response.getState();
            var fareDiscountsList = [];
            if(state === 'SUCCESS') {
                var results = response.getReturnValue();
                if(results.length > 0 && typeof results[0].Fare_Structure_Lists__r != 'undefined'){
                    var childArray = results[0].Fare_Structure_Lists__r;
                    console.log('results '+childArray);
                    component.set("v.fareDiscountsList",childArray);
                }else{
                    var errorEvt = $A.get("e.force:showToast");
                    errorEvt.setParams({
                        mode: 'sticky',
                        message: 'Proposal does not have Fare Discounts',
                        type : 'error',
                        duration:'50',
                        mode: 'dismissible'
                    });
                    errorEvt.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else {
                console.log('Error in getting data');
            }
        });
        $A.enqueueAction(action);
    }
})