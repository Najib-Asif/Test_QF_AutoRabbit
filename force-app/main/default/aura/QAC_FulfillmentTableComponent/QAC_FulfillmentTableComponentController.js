({
	doInit : function(component, event, helper) {
		var action = component.get("c.getAllFFRecords");
        
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        console.log("caseId :" + component.get("v.recordId"));

		action.setCallback(this, function(data) {
            var output = data.getReturnValue();
            if(output){
				component.set("v.AllFulfillments", output);
                component.set("v.totalRecords",output.length);
            }
		});
		$A.enqueueAction(action);	
	},
    
    toggleTable : function(component, event, helper){
        
        var baseCount = component.get("v.numberOfRecordsVisible");

        if(component.get("v.toggleCount") == baseCount){
			component.set("v.toggleCount",component.get("v.totalRecords"));        
        }
        else{
			component.set("v.toggleCount",baseCount);        
        }
        
        var buttonstate = component.get('v.buttonstate');
        component.set('v.buttonstate', !buttonstate);

        /*
         * This code is to hide specific rows in table..
         * 
        // This will return the CHILD of Table as Thead and TBody
        // arr = component.find("ffTable").getElement().childNodes;
        // This will return exactly one element of the 2nd Child
        // var singleNode = component.find("ffTable").getElement().childNodes[1].childNodes[2];
         
        // to get the count of all the Records in the Table
        var tableRecordCount = component.find("ffTable").getElement().childNodes[1].children.length;
        console.log("length: " +tableRecordCount);
        
        // to get all the CHILDREN Nodes of the TBODY Tag of the Table
        var tableBody = [];
        tableBody = component.find("ffTable").getElement().childNodes[1].children;
        
        var i;
        for (i = baseCount; i < tableRecordCount; i++) {
            $A.util.toggleClass(tableBody[i],"toggleRecord");
        }
        */
    },
    
    refresh : function(component, event, helper){
        console.log("Component Refreshed");
        $A.get('e.force:refreshView').fire();
    },
	
    convert : function(component, event, helper) {
		console.log("inside toggle");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.custom;        
    	console.log('rec index: ' + index);   
        
		var selectedFF = component.get("v.AllFulfillments")[index];
		console.log("Selected FF :" + JSON.stringify(selectedFF));

        selectedFF.Status__c = 'Success';
		component.set("v.eachFulfillment", selectedFF);

        var updatedFF = component.get("v.eachFulfillment");
		console.log("Selected FF :" + JSON.stringify(updatedFF));
        
		helper.recordUpdate(component, updatedFF);
    }
})