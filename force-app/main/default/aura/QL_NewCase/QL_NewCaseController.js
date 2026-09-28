({
    doInit : function(component,event,helper){
       // alert('do init get called');
       helper.callToServer(
            component,
            "c.findRecordTypes",
            function(response) {
                //alert(JSON.parse(response));
                var jsonObject=JSON.parse(response);
                component.set('v.recordTypeList',jsonObject); 
                component.set('v.selectedRecordType',jsonObject[0].recordTypeId);
            },
              {objName: "Case"}
        );
    },
    
    onChange : function(component, event, helper) {
var value = event.getSource().get("v.text");
        component.set('v.selectedRecordType', value);
},
    defaultCloseAction : function(component, event, helper) {
        //$A.util.addClass(component, "hideModal");
        $A.util.addClass(component, "slds-hide");
    },
    onconfirm : function(component, event, helper){
        //alert('confirm get called');
        var selectedRecType=component.get('v.selectedRecordType');
       // alert('selected recordtype:'+selectedRecType);
      //  component.set("v.isOpen", true);
 
      var action = component.get("c.getRecTypeId");
      var recordTypeLabel = component.get('v.selectedRecordType');
      //  alert('selected recordTypeLabel:'+recordTypeLabel);
       var parentId = component.get('v.recordId');
      action.setParams({
         "recordTypeLabel": recordTypeLabel,
         "obj":"Case"
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
            var createRecordEvent = $A.get("e.force:createRecord");
            var RecTypeID  = response.getReturnValue();
            createRecordEvent.setParams({
               "entityApiName": 'Case',
               "recordTypeId": RecTypeID,
               'defaultFieldValues': {
                'AccountId': parentId
          }
            });
            createRecordEvent.fire();
             
         } else if (state == "INCOMPLETE") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Oops!",
               "message": "No Internet Connection"
            });
            toastEvent.fire();
             
         } else if (state == "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Error!",
               "message": "Please contact your administrator"
            });
            toastEvent.fire();
         }
      });
      $A.enqueueAction(action);
      
    },
    onCancel:function(component, event, helper) {
              $A.get("e.force:closeQuickAction").fire(); 
    }
    
})