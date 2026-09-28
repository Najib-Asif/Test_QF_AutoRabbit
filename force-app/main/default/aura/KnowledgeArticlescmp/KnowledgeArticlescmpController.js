({
    doInit: function(component, event, helper) {
        
       helper.fetchArticles(component); 
    },
    
    fetchArticles: function(component, event, helper) {
        
       helper.fetchArticles(component); 
    },
    
    handleCategoryNameChange: function(component, event, helper) {
        component.set("v.categoryName", event.getSource().get("v.value"));
    },
    
    handleCategorySelect: function(component, event, helper) {
        
       helper.handleCategorySelect(component,event); 
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('Roe Id----'+row.Id);
        helper.showRowDetails(component,row);
    }
 
})