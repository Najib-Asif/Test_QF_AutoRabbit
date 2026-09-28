({
    validateContractForm: function(component) {
        var validContract = true;

        
        // Show error messages if required fields are blank
        var allValid = component.find('contractField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
        // Verify we have a quote to attach it to
        var quote = component.get("v.quote");
        if($A.util.isEmpty(quote)) {
            validContract = false;
            console.log("Quick action context doesn't have a valid quote.");
        }

        return(validContract);
	}
    }
})