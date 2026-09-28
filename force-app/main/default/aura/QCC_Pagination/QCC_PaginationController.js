({
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
    },
    prevPage: function(component, event, helper) {
        var c = Math.max(component.get("v.currentPageNumber")-1, 1);
        component.set("v.currentPageNumber", c);
    },
    nextPage: function(component, event, helper) {
        var b = Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber"));
        component.set("v.currentPageNumber", b);
    },
    lastPage: function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    }
})