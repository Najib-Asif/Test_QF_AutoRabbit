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
        helper.executeAction(component);
	},

    
	navigateToRecord : function(component, event, helper) {              
        var idx = event.currentTarget.getAttribute('data-record'); 
    	var contact = component.get("v.currentList")[idx];
        helper.saveContactClient(component , contact);       
    }
})