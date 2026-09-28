({
 doInit: function(component, event, helper) {
  //call apex class method
  var action = component.get('c.getCase');
  action.setParams({"CaseId" : component.get("v.recordId")});
  action.setCallback(this, function(response) {
   //store state of response
   var state = response.getState();
      if (state === "SUCCESS") {
    //set response value in Exceptioncase attribute on component.
    component.set('v.Exceptioncase', response.getReturnValue());
   }
  });
  $A.enqueueAction(action);
 },
})