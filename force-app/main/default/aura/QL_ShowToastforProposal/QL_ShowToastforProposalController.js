({
    ShowToastMessage : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info Message',
            message: 'Please convert proposal to Contract.',
            key: 'info_alt',
            type: 'info'
        });
        toastEvent.fire();
    }
})