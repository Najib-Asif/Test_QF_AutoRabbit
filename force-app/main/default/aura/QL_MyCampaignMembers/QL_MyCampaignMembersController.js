({
    doInit: function (component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        // this function call on the component load first time     
        // get the page Number if it's not define, take 1 as default
        var page = component.get("v.page") || 1;
        // get the select option (drop-down) values.   
        var recordToDisply = component.find("recordSize").get("v.value");
        // call the helper function   
        helper.getCampaignMem(component,page,recordToDisply,userId,component.get("v.recordId"));
        
    },
    
    navigate: function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        // this function call on click on the previous page button  
        var page = component.get("v.page") || 1;
        // get the previous button label  
        var direction = event.getSource().get("v.label");
        // get the select option (drop-down) values.  
        var recordToDisply = component.find("recordSize").get("v.value");
        // set the current page,(using ternary operator.)  
        page = direction === "Previous Page" ? (page - 1) : (page + 1);
        // call the helper function
        helper.getCampaignMem(component,page,recordToDisply,userId,component.get("v.recordId"));
        
    },
    
    onSelectChange: function(component, event, helper) {
        // this function call on the select opetion change,	 
        var page = 1
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var recordToDisply = component.find("recordSize").get("v.value");
        helper.getCampaignMem(component,page,recordToDisply,userId,component.get("v.recordId"));
    },
 
    updateColumnSorting: function (component, event, helper) {
        console.log('Sorting enabled');
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    }
})