({
	doit : function(component, event, helper)
    {
        
        var flow = component.find("flowData");
        var inputVariables = [
        {
            name : 'varCaseId',
            type : 'String',
            value : component.get("v.recordId")
        }
    	];
    flow.startFlow("QCC_Search_Tab_for_NON_FF", inputVariables); 
    }, 
    handleStatusChange : function (cmp, event) {
        if (event.getParam('status') === "FINISHED") {
            $A.get('e.force:refreshView').fire();
            // location.reload();
        }
    }
    
})