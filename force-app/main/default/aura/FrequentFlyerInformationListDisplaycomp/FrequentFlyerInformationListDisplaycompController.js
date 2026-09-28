({
	doInit : function(component, event, helper) {
		helper.FFInfo(component);
        helper.setUpColumns(component);
        helper.getUserProfile(component);
	},
    
    handleNewFFClick : function(component, event, helper){
        helper.navigateToFFCreatePage(component);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        helper.showRowDetails(component,row);
    }
})