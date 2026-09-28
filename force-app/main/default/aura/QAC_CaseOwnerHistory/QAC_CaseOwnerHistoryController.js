({
	doInit : function(component, event, helper) {
		var action = component.get("c.returnCaseHistory");
        
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));

		action.setCallback(this, function(data) {
            var output = data.getReturnValue();
            if(output){
				component.set("v.casehistory", output);
            }
		});
		$A.enqueueAction(action);	
	},
    
    toggleTable : function(component, event, helper){
        
        // This will return the CHILD of Table as Thead and TBody
        // arr = component.find("ffTable").getElement().childNodes;
        // This will return exactly one element of the 2nd Child
        // var singleNode = component.find("ffTable").getElement().childNodes[1].childNodes[2];
        var baseCount = component.get("v.numberOfRecordsVisible");

        if(component.get("v.toggleCount") == baseCount){
			component.set("v.toggleCount",component.get("v.totalRecords"));        
        }
        else{
			component.set("v.toggleCount",baseCount);        
        }
        
        var buttonstate = component.get('v.buttonstate');
        component.set('v.buttonstate', !buttonstate);

        
    }
})