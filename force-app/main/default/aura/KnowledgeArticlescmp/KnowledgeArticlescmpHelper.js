({
    
    handleCategorySelect: function(component, event) {
            console.log('Inside parent helper');
        // Get the selected node information from the event
        var selectedCategoryGroupName = event.getParam("selectedCategoryGroupName")+'__c';
        var selectedCategoryName = event.getParam("selectedCategoryName")+'__c';
        component.set("v.categoryGroupName",selectedCategoryGroupName);
        component.set("v.categoryName",selectedCategoryName);

        // Set the selected node value to the parent component's attribute
        console.log("selected Category Name: ", selectedCategoryName);
        this.fetchArticles(component);
        
    },
    
    fetchArticles: function(component) {
        var action = component.get("c.getKnowledgeArticles");

        // Set parameters
        action.setParams({
            categoryGroupName : component.get("v.categoryGroupName"),
            categoryName: component.get("v.categoryName")
        });
        
        
        // Set callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.knowledgeArticles", response.getReturnValue());
            } else {
                console.error("Error fetching knowledge articles: ", response.getError());
            }
        });
        
        $A.enqueueAction(action);
        /*
        component.set("v.columns", [
            { label: 'Title', fieldName: 'Title',wrapText: true },
            { label: 'Publish Status', fieldName: 'PublishStatus',wrapText: true },
            { label: 'Last Published Date', fieldName: 'LastPublishedDate',type: "date",
            	typeAttributes:{year: "numeric",
            					month: "2-digit",
            					day: "2-digit",
            					hour: "2-digit",
            					minute: "2-digit"
                               }},
            {label: '', type: 'button', initialWidth: 135, 
             typeAttributes: { label: 'View', name: 'view_details', title: 'View knowledge article'}}
        ]);
        */
    },
                  
    //method to open the FF in a new subtab
    showRowDetails : function(component,row) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Knowledge__kav/'+row.Id+'/view',
            focus: true
        }).catch(function(error) {
            console.log(error);
        });
        
    }
})