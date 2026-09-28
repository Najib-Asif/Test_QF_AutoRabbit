({
    doInit: function(component, event, helper) {
       helper.loadCategoryGroups(component); 
      // helper.loadCategories(component); 
    },
    handleCategoryGroupChange: function(component, event, helper) {
        helper.loadCategoryTree(component);
    },
    handleSelect: function(component, event, helper) {
        
       helper.handleSelect(component,event); 
    }
 
})