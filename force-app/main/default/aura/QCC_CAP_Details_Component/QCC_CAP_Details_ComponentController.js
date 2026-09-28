({
	 doInit : function(component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");
        helper.getAddress(component); 
    },
    checkSelected: function(component, event, helper){
        var main = component.find('main');
        $A.util.removeClass(main, 'small');
        $A.util.addClass(main, component.get("v.designHeight"));
         helper.getSelected(component); 
    }
})