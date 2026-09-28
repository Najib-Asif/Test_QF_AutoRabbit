({
	 getSingleDetails : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Map Value###',params.singleDetail);
        component.set("v.singleRecInfo", params.singleDetail);
    }
})