({
    displayToast : function(myType,myTitle,myMessage,myDuration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : myTitle,
            message: myMessage,
            duration: myDuration,
            type: myType,
            mode: 'dismissible'
        });
        toastEvent.fire();	
    }
})