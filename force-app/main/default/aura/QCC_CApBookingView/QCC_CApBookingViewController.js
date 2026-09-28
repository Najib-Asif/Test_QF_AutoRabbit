({
    doInit : function(component, event, helper) {
        console.log("Log Init");
        var pageNumber = component.get("v.pageNumber");
        helper.getLocalList(component, pageNumber);
    },
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        console.log("field#####",fieldName);
        console.log("sortdir&&&&&",sortDirection);
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    Next: function(component, event, helper){
        var pageNumber = component.get("v.pageNumber")+1;
        var maxRecord = component.get("v.maxRecord");
        helper.currentpageRecord(component, pageNumber, maxRecord); 
    },
    Previous: function(component, event, helper){
        var pageNumber = component.get("v.pageNumber")-1;
        var maxRecord = component.get("v.maxRecord");
        var interval = component.get("v.rowsPerPage")*2;
        if(maxRecord>interval){
            maxRecord -= interval;
        }else{
            maxRecord = 0
        }
        helper.currentpageRecord(component, pageNumber, maxRecord); 
    }
})