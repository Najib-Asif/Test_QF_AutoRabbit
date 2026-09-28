({
    doInit : function(component, event, helper) { 

        helper.checkIfValid(component, event, helper);
        
        component.set('v.validate', function() {
        if(component.get("v.isValid")) {
            // If the component is valid...
            return { isValid: true };
        }
        else {
            // If the component is invalid...
            return { isValid: false, errorMessage: 'Please enter some valid input. Input is not optional.' };
        }})
    
    },

    handleOnload: function (component, event, helper) {
        var nameFieldValue = component.set("v.displayButtons","true");
        console.log('## displayButtons : ' + nameFieldValue);

        var spinner = component.find("LoadingSpinner");
        $A.util.addClass(spinner, "slds-hide");

    },
    
    onFieldChange: function(component, event, helper) { 
        helper.checkIfValid(component, event, helper);
    },
        
    handleButtonClick1 : function(component, event, helper) {
        component.set("v.h_navigationType", component.get("v.navigationType1"));
        helper.handleButtonClick(component, event, helper);
        component.set("v.fire1", true);
    },
    
    handleButtonClick2 : function(component, event, helper) {
        component.set("v.h_navigationType", component.get("v.navigationType2"));
        helper.handleButtonClick(component, event, helper);
        component.set("v.fire2", true);        
    },
        
})