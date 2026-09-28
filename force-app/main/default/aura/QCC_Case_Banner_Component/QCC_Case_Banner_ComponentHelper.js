({
	getContact : function(cmp, caseId) {
		var action1 = cmp.get('c.getContact')
        action1.setParams({recId: caseId});
        
        action1.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            //alert('response.getState():'+response.getState());
            if (state === "SUCCESS") {
                cmp.set('v.caseRec', response.getReturnValue());
                //alert(JSON.stringify(response.getReturnValue()));
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                //alert('errors: ' + errors);
            }
        }));
        $A.enqueueAction(action1);
	}
})