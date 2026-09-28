({
    setFocusedTabLabel: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Refunds"
            });

            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom96",
                iconAlt: "Search"
            });
        })
    },
     getRecoveryList : function(component , recType) {
        var action = component.get('c.getRecoveries');
        action.setParams({
            "recType": recType
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var selected = component.find("recType").get("v.value");
                var toastEvent = $A.get("e.force:showToast");
                var recoveries = response.getReturnValue();
                if(selected === 'EFT Refund'){
                    component.set("v.displayEFT", true);
                    component.set("v.displayCC", false);
                }else{
                    component.set("v.displayCC", true);
                    component.set("v.displayEFT", false);
                }

                component.set('v.recoveries', recoveries);
                //pagination
                component.set("v.pageNumber",1);
                console.log('recoveries.length ' +recoveries.length);
                console.log('size ' + Math.floor((recoveries.length+4)/5));
                component.set("v.maxPage", Math.floor((recoveries.length+4)/5));
                this.renderPage(component);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "An unexpected error occured",
                    "type" : "error",
                    "message": "Failed to retrieve recoveries"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    renderPage: function(component) {
        var records = component.get("v.recoveries");
        if(records != null) {
            var pageNumber = component.get("v.pageNumber");
            var pageRecords = records.slice((pageNumber-1)*10, pageNumber*10);
            component.set("v.currentList", pageRecords);
        }
    },
    
})