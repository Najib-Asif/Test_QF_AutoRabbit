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

    onFieldChange: function(component, event, helper) { 
        helper.checkIfValid(component, event, helper);
    },
                
})