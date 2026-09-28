({
	onLoad : function(component, event, helper) {
		var params = event.getParam('arguments');
        if (params) {
            var param1 = params.caseId;
            console.log('CaseId##', param1)
            component.set("v.recId", param1);
            var recordData = component.find("caseRecord");
            recordData.reloadRecord();
        }
	},
    onAssigntoContact: function(component, event, helper) {
		helper.assigntoGenericCon(component);
	},
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log('EEEEE '+JSON.stringify(eventParams));
        if(eventParams.changeType === "LOADED" || eventParams.changeType === "CHANGED") {
            helper.validateContact(component);           
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
})