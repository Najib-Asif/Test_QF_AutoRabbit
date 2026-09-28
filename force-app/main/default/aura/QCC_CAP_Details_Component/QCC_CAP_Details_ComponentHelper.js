({
    getAddress : function(component) {
        var recID = component.get("v.recordId");
        console.log(recID);
        var action = component.get("c.fetchAddress");
        action.setParams({
            "recordId": recID,
        });
        
        action.setCallback(this, function(response) {
            this.doLayout(response, component);
        }); 
        $A.enqueueAction(action);
    },
    doLayout: function(response, component) {
        var data = response.getReturnValue();
        console.log("Adddress#####: ", data);
        component.set("v.lstAddRess", data);
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
       
    },
    getSelected: function(component){
        var recID = component.get("v.recordId");
        var data =   JSON.stringify(component.get("v.lstAddRess"));
        var action = component.get("c.updateSelected");
        action.setParams({
            "recordId": recID,
            "lstDispWrap":data
        });
        action.setCallback(this, function(response) {
            this.doLayout(response, component);
        }); 
        $A.enqueueAction(action);
    }
})