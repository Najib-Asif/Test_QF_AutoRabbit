({
    createRecord: function(component, event, helper) {     
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 0
        );    
        var parentId = component.get('v.recordId');
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": 'Contact',
            'defaultFieldValues': {
                'AccountId': parentId
            }
        });
        createRecordEvent.fire();
    }      
})