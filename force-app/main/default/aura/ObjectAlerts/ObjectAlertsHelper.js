({
  getLabelForRecord : function(component, sObj){
    if(!component.get("v.objLabel")){
      var action = component.get("c.getSObjectLabel");
      action.setParams({
        sObjName : sObj
      });
      action.setCallback(this, function(response){
        var state = response.getState();
        if(state === "SUCCESS"){
          var label = response.getReturnValue();
            //use this code if we want to dynamically change the title  
            //to what object this componentis addded 
          //component.set("v.objLabel", label);
          component.set("v.objLabel", 'Contact');
        } else if(state === "ERROR"){
          console.log('Error: ' + JSON.stringify(response.error));
        } else {
          console.log('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
        }
      });
      $A.enqueueAction(action);
    }
  },
  getBadgesForRecord : function(component, recId, sObj) {
    var action = component.get("c.getIndicators");
    action.setParams({
      recId : recId,
      objectName : sObj
    });
    action.setCallback(this, function(response){
      var state = response.getState();
      if(state === "SUCCESS"){
        var badges = response.getReturnValue();
        component.set("v.badgeList", badges);
      } else if (state === "ERROR"){
        console.log('Error: ' + JSON.stringify(response.error));
      } else {
        console.log('Unknown problem, state: ' + state + ', error: ' + JSON.stringify(response.error));
      }
    });
    $A.enqueueAction(action);
  },
    
  getContactRecord : function(component, recId) {
    var action = component.get("c.getContactId");
    action.setParams({
      recId : recId
    });
    action.setCallback(this, function(response){
      var state = response.getState();
      if(state === "SUCCESS"){
        var resp = response.getReturnValue();
        component.set("v.contactId", resp);
        component.set("v.onContact", true);
      } else if (state === "ERROR"){
        console.log('Error: ' + JSON.stringify(response.error));
      } else {
        console.log('Unknown problem, state: ' + state + ', error: ' + JSON.stringify(response.error));
      }
    });
    $A.enqueueAction(action);
  },
  //future code here
})