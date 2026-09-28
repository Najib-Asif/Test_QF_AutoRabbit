({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchSAPfields");
        action.setParams({
            "AccId" : component.get("v.recordId")
        });
        console.log("AccId :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            
            var output = response.getReturnValue();
            var state = response.getState();
           // console.log('####1'+response.getReturnValue().val1);
            //console.log('$$$$'+response.getReturnValue().recID);
            //var recordID = response.getReturnValue().recID;
           
            var resultsToast = $A.get("e.force:showToast");
			var parentId = component.get('v.recordId');
            //var val1  = response.getReturnValue();
            
             
          //  console.log('val1******'+val1);
            console.log('parentId*****'+parentId);
          //  var createRecordEvent = $A.get("e.force:createRecord");
            
           
          //  $A.get("e.force:closeQuickAction").fire();
           // resultsToast.fire();
            
            var createRecordEvent = $A.get("e.force:createRecord");
           // var val1  = (JSON.parse(component.get('v.Opprobj')))[0].val1;
            var output= response.getReturnValue();
           // console.log('output*******'+output.fld_val1);
            createRecordEvent.setParams(
                {
               "entityApiName": 'Strategic_Account_Plan__c',
                             'defaultFieldValues': 
                    {
                		'Account__c':parentId,
                        'Account_Manager_user__c':output.fld_val2,
                        'Business_Overview__c':output.fld_val3
                        
                        
          			}
            	}
            );
            createRecordEvent.fire();
         
        });
    
        $A.enqueueAction(action);
        
    }
})