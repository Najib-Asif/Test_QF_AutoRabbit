({
    getContact : function(component) {
        var recID = component.get("v.recordId");
        console.log(recID);
        
     
        var action = component.get("c.fetchCustomerDetail");
        action.setParams({
            "recId": recID,
        });
		
        action.setCallback(this, function(response) {
            this.doLayout(response, component);
        }); 
        $A.enqueueAction(action);
    },
    doLayout: function(response, component) {
        var data = response.getReturnValue();
        component.set("v.objCon", data);
        console.log("The Data: ", data);
    }
})