({
	callToServer : function(component, method, callback, params) {
        //alert('Calling helper callToServer function');
var action = component.get(method);
        if(params){
            action.setParams(params);
        }
        //alert(JSON.stringify(params));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Processed successfully at server');
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
$A.enqueueAction(action);
    },
    
    fetchOpportunityfields: function(component, event, helper) {
    var action = component.get("c.fetchOpportunityfields");
      console.log('helper@@@@@@@'+component.get("v.recordId"));
       action.setParams({
            "AccId" : component.get("v.recordId")
        });
      action.setCallback(this, function(response) {
         component.set("v.Opprobj", response.getReturnValue());
      });
      $A.enqueueAction(action);
	}
    
})