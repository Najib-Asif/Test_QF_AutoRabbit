({
	doInit : function(component, event, helper) {
		helper.refreshMessage(component,helper);
        
        //execute refreshMessage() again after 1 min each
        window.setInterval($A.getCallback(function() {
        	helper.refreshMessage(component, helper)
    	}), 60000); 
	}
})