({
 doInit: function(component, event, helper) {
  //call apex class method
  var action = component.get('c.getChildCase');
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
    
    navigateToRecord : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var rec = component.get("v.Exceptioncase.Cases")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: rec.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else{
            window.location.href = '/one/one.app#/sObject/'+rec.Id+'/view'
        }
    },
})