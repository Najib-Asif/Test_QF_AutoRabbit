({
	doInit : function(component, event, helper) {
        //calling helper method from client-side controller
		helper.callApexMethod(component, event, helper) ;
        console.log('Iam into init$$$');
	}
})