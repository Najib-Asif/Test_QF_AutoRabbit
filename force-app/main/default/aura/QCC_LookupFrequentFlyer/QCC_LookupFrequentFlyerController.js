({
    onLoad : function(component, event) {
        var params = event.getParam('arguments');
        if (params) {
            var param1 = params.caseId;
            console.log('CaseIdFF##', param1)
            component.set("v.recId", param1);
        }
    },

	doLookup : function(component, event, helper) {
		var ffNumber = component.get("v.ffNumber");
        var ffNumberField = component.find("ffNumber");
        if(!ffNumber) {
            //helper.showPopover(component);
            ffNumberField.setCustomValidity("Complete this field");
            ffNumberField.reportValidity();
            return;
        }
        ffNumberField.setCustomValidity("");
        ffNumberField.reportValidity();

        var resetEvent = $A.get("e.c:QCC_ResetEvent");  
        /* Thom Phan - Add parameter to check where event is fired */  
        resetEvent.setParams({           
            "isResetFromLookupFF" : true            
        });    
        resetEvent.fire();

        /* Thom Phan - Add parameter to check where event is fired */
        var resetFormEvent = $A.get("e.c:QCC_ResetFormEvent");
        resetFormEvent.setParams({           
            "isResetFromLookupFF" : true            
        });
        resetFormEvent.fire();

        var caseId = component.get("v.recId");
        helper.executeAction(component);
	},

    /* Thom Phan - reset form when user click on Reset button => event from QCC_SearchContactInfo*/
    doReset: function(component, event, helper) {
        var isResetFromLookupFF = event.getParam("isResetFromLookupFF");      

        if(isResetFromLookupFF != true){ // undefined or false            
            component.set("v.ffNumber", "");
            component.set("v.lastName", "");

            var ffNumberField = component.find("ffNumber");
            ffNumberField.setCustomValidity("");
            ffNumberField.reportValidity();    
        }  
    },

})