({
	loadDataHelper : function(component, event, helper) {
        var table = component.find('tblFeeWaiver');
        table.set("v.isLoading", true);
		var action = component.get("c.getAllFeeWaiverData");
        action.setParams({
            "contactId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(!result.hasError){
                    component.set("v.data", result.feeWaiverRecords);
                    table.set("v.isLoading", false);
                    if (result.feeWaiverRecords.length >= 10) {
                        document.getElementById('divTable').style.height = '300px'
                    }
                }
            } else if (state === "ERROR") {
                var errorMsg = response.getError();;
                console.log(errorMsg);
                var error = "Error";
            }
        });
        $A.enqueueAction(action);
	}
})