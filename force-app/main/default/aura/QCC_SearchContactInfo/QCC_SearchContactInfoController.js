({
    addContactInfo : function(component, event, helper) {
        component.set("v.firstName", event.getParam("firstName"));
        component.set("v.lastName", event.getParam("lastName"));
        component.set("v.email", event.getParam("email"));
        component.set("v.phone", event.getParam("phone"));
        component.set("v.ffNumber", event.getParam("ffNumber"));
        component.set("v.ffTier", event.getParam("ffTier"));
        component.set("v.capId", event.getParam("capId"));
        component.set("v.address", event.getParam("address"));
        component.set("v.ffTierSF", event.getParam("ffTierSF"));
        var firstName = component.find("firstName");
        firstName.set("v.disabled", true);
        var lastName = component.find("lastName");
        lastName.set("v.disabled", true);
    },
    
	doReset : function(component, event, helper) {
		component.set("v.firstName", "");
        component.set("v.lastName", "");
        component.set("v.email", "");
        component.set("v.phone", "");
        component.set("v.ffNumber", "");
        component.set("v.ffTierSF", "");
        component.set("v.ffTier", "");
        component.set("v.address","");
        component.set("v.phone_Country_Code__c","");
        component.set("v.phone_Area_Code__c","");
        component.set("v.phone_Line_Number__c","");
        component.set('v.checked', false);
        component.set("v.phone","");
        var firstName = component.find("firstName");
        firstName.set("v.disabled", false);
        var lastName = component.find("lastName");
        lastName.set("v.disabled", false);
        
        // reset the validation error elements
        helper.hideError(component, "firstName");
        helper.hideError(component, "lastName");
        helper.hideError(component, "email");
        helper.hideError(component, "phone");
        helper.hideError(component, "phone1");
        helper.hideError(component, "phone2");
        helper.hideError(component, "phone3");

        // Thom Phan - reset phone number radio button
        component.set("v.isPhoneNumber", true);
        
        var resetEvent = $A.get("e.c:QCC_ResetEvent");
        /* Thom Phan - Check where is event fired
            * isResetFromLookupFF/isResetFromLookupPNR = true => event is from search FF/PRN => don't need to reset FF/PRN form 
                                         => set isResetFromLookupFF/isResetFromLookupPNR = false in  QCC_ResetEvent
                                         => QCC_LookupFrequentFlyer/QCC_PNRSearch handle event will check this value to reset or not.
            * isResetFromLookupFF/isResetFromLookupPNR = false => event is not from search FF/PNR
        */
        var isResetFromLookupFF = event.getParam("isResetFromLookupFF");
        var isResetFromLookupPNR = event.getParam("isResetFromLookupPNR");
        
        resetEvent.setParams({           
            "isResetFromLookupFF" : isResetFromLookupFF,
            "isResetFromLookupPNR" : isResetFromLookupPNR
        });

        resetEvent.fire();
	},
    
    doSearch : function(component, event, helper) {
        if(helper.validateFields(component, event, helper)) {
            helper.searchCases(component, event, helper);
        } else {
            //component.set("v.showModal", true);
        }
    },
    
    createRecord : function(component, event, helper) {
        helper.createCase(component, event, helper);
    },
    onSelect: function(component , event , helper){
        //phone logic - start
        //Mobile or phone?
        var selected = event.getSource().get("v.label");
        var checked = component.get("v.checked");
        if(selected == 'Mobile') {
            component.set("v.checked" , true);
            component.set('v.phone_Area_Code__c', '');
            // Thom Phan - set phone number
            component.set("v.isPhoneNumber", false);
        }else{
            component.set("v.checked" , false);
            // Thom Phan - set phone number
            component.set("v.isPhoneNumber", true);
        }
        helper.combinePhoneNumber(component , null , helper);
    },
    onPhoneChange: function(component , event , helper){
        helper.combinePhoneNumber(component , event , helper);
    },
    
    removeMsg : function(component, event, helper) {
        console.log('Entered removeMsg');
        var emailField = component.find("email");
        emailField.setCustomValidity('');
        emailField.reportValidity();
        var phoneField = component.find("phone");
        phoneField.setCustomValidity('');
        phoneField.reportValidity();
        console.log('Exiting removeMsg');
    },
    doOpenContact : function(component, event, helper) {
         helper.findContact(component, event, helper);
    }
})