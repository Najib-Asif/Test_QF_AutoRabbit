({
	// Your renderer method overrides go here
    unrender : function (component, helper) {
        console.log('Component 2 unrender '); 
        return this.superUnrender();
    }
})