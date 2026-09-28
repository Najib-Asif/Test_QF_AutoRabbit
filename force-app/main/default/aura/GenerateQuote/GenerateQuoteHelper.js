({
    validateQuoteForm: function(component) {
        var validQuote = true;
        
        var nameField = component.find("quoteField");
        var name = nameField.get("v.value");
        if ($A.util.isEmpty(name)){
            console.log("Name can't be blank");
            validQuote = false;
        }
        
        var opp = component.get("v.opportunity");
        if($A.util.isEmpty(opp)) {
            validQuote = false;
            console.log("Quick action context doesn't have a valid opportunity.");
        }

        /*
        // Show error messages if required fields are blank
        var allValid = component.find('quoteField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
        // Verify we have an account to attach it to
        var opp = component.get("v.opportunity");
        if($A.util.isEmpty(opp)) {
            validQuote = false;
            console.log("Quick action context doesn't have a valid opportunity.");
        }*/

        return(validQuote);
	//}
    }
})