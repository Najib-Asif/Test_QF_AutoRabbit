({
	getContactDetails : function(component, event, helper) {
		 var params = event.getParam('arguments');
         console.log('Param Value###'+params.contactDetail);
         component.set("v.objCon", params.contactDetail); 
	}
})