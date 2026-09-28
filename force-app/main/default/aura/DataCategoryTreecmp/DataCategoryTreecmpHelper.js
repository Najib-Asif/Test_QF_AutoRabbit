({
    loadCategoryGroups: function(component, event, helper) {
        var action = component.get("c.getCategoryGroups");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var groups = response.getReturnValue();
                var options = groups.map(function(group) {
                    return { label: group, value: group };
                });
                component.set("v.categoryGroups", options);
            } else {
                console.error("Error loading category groups: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    loadCategoryTree: function(component) {
        var action = component.get("c.getCategoryTree");
        
        action.setParams({
            groupName: component.get("v.selectedGroup")
        });
		console.log('INside loadCategry TRee');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.categoryTree", response.getReturnValue());
            } else {
                console.error("Error loading category tree: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    handleSelect: function (component, event) {
        console.log('Inside handleSelect');
        event.preventDefault();
        
        var selectedNodes = event.getParam("name");
        console.log('selectedCategoryName : '+selectedNodes);
        
        var selectedCategory = component.getEvent("categorySelected");
        selectedCategory.setParams({
                "selectedCategoryName": event.getParam("name"),
            "selectedCategoryGroupName" : component.get("v.selectedGroup")
            });
        selectedCategory.fire();
    }
})