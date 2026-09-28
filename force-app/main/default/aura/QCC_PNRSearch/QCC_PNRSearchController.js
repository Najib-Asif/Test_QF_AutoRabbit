({
    onLoad : function(component, event) {
        var params = event.getParam('arguments');
        if (params) {
            var param1 = params.caseId;
            console.log('CaseId##', param1)
            component.set("v.recId", param1);
        }
    },
    
    onClick: function(component, event, helper) {
        /*var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {*/
        var pnr = component.get("v.pnr");
        var lastname = component.get("v.lastName");
        var allValid = true;
        var pnrField = component.find("pnr");
        var lnameField = component.find("lastName");
        if(!pnr) {
            pnrField.setCustomValidity("Complete this field");
            pnrField.reportValidity();
            allValid = false;
        } else {
            // check for length
            if(pnr.length != 6){
                pnrField.setCustomValidity($A.get("$Label.c.QCC_PNRLength"));
                pnrField.reportValidity();
                allValid = false;
            } else {
                pnrField.setCustomValidity("");
                pnrField.reportValidity();
            }
        }
        if(!lastname) {
            lnameField.setCustomValidity("Complete this field");
            lnameField.reportValidity();
            allValid = false;
        } else {
            lnameField.setCustomValidity("");
            lnameField.reportValidity();
        }
        
        if(allValid) {
            component.set("v.isLoading", true);
            helper.invokeCAPSearch(component);
        } 

        var resetEvent = $A.get("e.c:QCC_ResetEvent");  
        /* Thom Phan - Add parameter to check where event is fired */  
        resetEvent.setParams({           
            "isResetFromLookupPNR" : true            
        });    
        resetEvent.fire();

        /* Thom Phan - Add parameter to check where event is fired */
        var resetFormEvent = $A.get("e.c:QCC_ResetFormEvent");
        resetFormEvent.setParams({           
            "isResetFromLookupPNR" : true            
        });
        resetFormEvent.fire();

    },

    /* Thom Phan - reset form when user click on Reset button => event from QCC_SearchContactInfo*/
    doReset: function(component, event, helper) {   

        var isResetFromLookupPNR = event.getParam("isResetFromLookupPNR");      

        if(isResetFromLookupPNR != true){ // undefined or false      
            component.set("v.pnr", "");
            component.set("v.lastName", "");

            var pnrField = component.find("pnr");
            pnrField.setCustomValidity("");
            pnrField.reportValidity();

            var lnameField = component.find("lastName");
            lnameField.setCustomValidity("");
            lnameField.reportValidity();
        }
    },
})