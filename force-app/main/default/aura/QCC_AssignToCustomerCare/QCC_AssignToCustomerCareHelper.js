({
	displayToastMessage : function(iType, iTitle,iMessage, iDuration) {
		var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": iType,
            "title": iTitle,
            "message":iMessage,
            duration: iDuration
        });
        
        resultsToast.fire();
	}
})