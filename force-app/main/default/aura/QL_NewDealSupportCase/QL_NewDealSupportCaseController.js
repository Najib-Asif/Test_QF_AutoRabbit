({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchDSCasefields");
        action.setParams({
            "ContId" : component.get("v.recordId")
        });
        console.log("ContId :" + component.get("v.recordId"));
        
        action.setCallback(this, function(response) {
            
            // var output = response.getReturnValue();
            var state = response.getState();
            // console.log('####1'+response.getReturnValue());
            //console.log('$$$$'+response.getReturnValue().recID);
            //var recordID = response.getReturnValue().recID;
            
            var resultsToast = $A.get("e.force:showToast");
            var parentId = component.get('v.recordId');
            var val1  = response.getReturnValue();
            //  var val1  = (JSON.parse(component.get('v.DSCaseobj')))[0].val1;
            console.log('parentId*****'+parentId);
            //  var createRecordEvent = $A.get("e.force:createRecord");
             $A.get("e.force:closeQuickAction").fire();
            // resultsToast.fire();
            
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams(
                {
                    "entityApiName": 'Case',
                    "recordTypeId":'01290000001IINIAA4',
                    'defaultFieldValues': 
                    {
                        'Related_Contract__c':parentId,
                        'AccountId':val1
                    }
                }
            );
            createRecordEvent.fire();
            
        });
        
        $A.enqueueAction(action);
        
    }
})