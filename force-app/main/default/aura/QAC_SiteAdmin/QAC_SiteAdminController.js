({
    openTab : function(component, event, helper) 
    {
        var aHrefLinkTag = event.currentTarget;
        var accId = aHrefLinkTag.dataset.custom;
        console.log("Local Case Id**"+accId);
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: accId,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
                console.log("The url for this tab is: " + tabInfo.url);
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    fetchAccount : function(component, event, helper)
    {
        component.set("v.showSpinner", true);
        component.set("v.sfAccount", null);
        var action = component.get("c.sfAccDetails");
        helper.runControllerMethods(component,event,action,'fetchAccount');
    },
    
    validateData : function(component, event, helper)
    {
        component.set("v.showSpinner", true);
        var action = component.get("c.validateLDAP");
        helper.runControllerMethods(component,event,action,'validate');
    },
    
    createData : function(component, event, helper){
        component.set("v.showSpinner", true);
        var action = component.get("c.createLDAP");
        helper.runControllerMethods(component,event,action,'create');
    }
    
    /*resetData : function(component, event, helper){
        component.set("v.showSpinner", true);
        var action = component.get("c.resetLDAP");
        helper.runControllerMethods(component,event,action,'reset');
    }*/
})