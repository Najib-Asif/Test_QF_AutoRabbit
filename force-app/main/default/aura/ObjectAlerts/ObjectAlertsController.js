({
  doInit : function(component, event, helper) {
    var recId = component.get("v.recordId");
    var sObj = component.get("v.sObjectName");
      console.log('sObj ==== ', sObj);
      console.log('recId ==== ', recId);
    if(sObj){
      helper.getLabelForRecord(component, sObj);
      helper.getBadgesForRecord(component, recId, sObj);
      
    }
    if(sObj == 'Case'){  
      helper.getContactRecord(component,recId);
    }else if (sObj == 'Contact'){
      component.set("v.contactId", recId);
      component.set("v.onContact", true);
    }
  },
  //future code here
})