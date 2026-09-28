({
    refreshBookingOnSuccess : function(component, event) {
        var navigationItemAPI = component.find("navigationItemAPI");
        console.log("inside refresh of Booking");
        navigationItemAPI.refreshNavigationItem().then(function(response) {
            console.log("After Booking Flag:"+response);
        })
        .catch(function(error) {
            console.log(error);
        });
    },
	isFormValid : function(component)
	{
		return (component.find('requiredFields') || []
		).filter(function (i) 
			{
				var value = i.get('v.value');
				return !value || value == '' || value.trim().length === 0;
			}
		).map(function (i) 
			{
				//return myMap[i.get('v.fieldName')];
				return i.get('v.fieldName');
			}
		);
	},
	displayToast : function(myType,myTitle,myMessage,myDuration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : myTitle,
            message: myMessage,
            duration: myDuration,
            type: myType,
            mode: 'dismissible'
        });
        toastEvent.fire();	
    },
    fetchFieldNames : function(component,event)
    {
        var myMap = (component.find('requiredFields') || []).map(i => i.get('v.fieldName'));
		console.log('my map**'+JSON.stringify(myMap));
		
		var action = component.get("c.fieldMap");
		action.setParams({
            "fieldAPINames": myMap
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.requiredFieldsMap", storeResponse);
            }
        });
        $A.enqueueAction(action);
    }
})