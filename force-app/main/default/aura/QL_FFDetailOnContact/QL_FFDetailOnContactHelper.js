({
    getContact: function(component, event, helper) {
        var recID = component.get("v.recordId");
        console.log('ContactIfd',recID);
        var action = component.get("c.fetchCustomerDetail");
        console.log('after method call');
        action.setParams({
            "recId": recID,
            "isPageLoad" : true
        });
        console.log('after method call1'+recID);
        action.setCallback(this, function(response) {
            console.log('after method call2');
            // this.doLayout(response, component);
            var state = response.getState();
            console.log("State####",state);
            if(state === "SUCCESS"){
                var contactInfo = response.getReturnValue();
                if(contactInfo != null){
                    component.set("v.objCon", contactInfo.objContact);
                    component.set("v.lstOtherProducts", contactInfo.lstOtherProducts); 
                    var ffdate = $A.localizationService.formatDate(contactInfo.objContact.QCC_Frequent_Flyer_Anniversary_Date__c, "DD/MM/YYYY"); 
                    var obj = component.get("v.objCon");
                    console.log('ffdate#######'+JSON.stringify(obj));
                    component.set("v.ffDate", ffdate); 
                }
            }else if (state === "ERROR") {
                var errorMsg = response.getError();;
                console.log(errorMsg);
                var error = "Error";
            } else if (state === "INCOMPLETE") {
                var errorMsg = "No resonse from server";
                console.log(errorMsg);
                var error = "Error";
            }
        });
        $A.enqueueAction(action);
    }
})