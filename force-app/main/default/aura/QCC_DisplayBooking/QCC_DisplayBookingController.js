({
	doInit : function(component, event, helper) {
        console.log("Log Init");
        var main = component.find('main');
        $A.util.removeClass(main, 'small');
        $A.util.addClass(main, component.get("v.designHeight"));
        var pageNumber = component.get("v.pageNumber");
        helper.getLocalList(component, pageNumber);
    },
    showDetails: function (component, event, helper) {
        var closeItem = component.get('v.openItem');
        if (closeItem) {
            closeItem = closeItem.querySelector('[data-details]');
            $A.util.addClass(closeItem, 'slds-hide');
        }
        var selectedItem = event.currentTarget;
        component.set('v.openItem', selectedItem);
        var itemDetails = selectedItem.querySelector('[data-details]')
        $A.util.removeClass(itemDetails, 'slds-hide');
    },
    Next:function(component, event, helper){
        var pageNumber = component.get("v.pageNumber")+1;
        helper.showCurrentPageDate(component, pageNumber); 
    },
    Previous:function(component, event, helper){
        var pageNumber = component.get("v.pageNumber")-1;
        helper.showCurrentPageDate(component, pageNumber); 
    }
})