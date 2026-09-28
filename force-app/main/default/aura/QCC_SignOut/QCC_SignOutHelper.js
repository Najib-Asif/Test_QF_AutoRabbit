({
    closeAllTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {            
            for(var i = 0; i < response.length;i++){
                var tab = response[i];
                console.log('tabId='+tab.tabId);
                if(tab.closeable && !tab.isSubtab){
                    workspaceAPI.closeTab({tabId: tab.tabId});
                }
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    reassignCases : function(component, event, helper) {
        var action = component.get('c.caseAssignedBack');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('Successfully reassign Cases!');
                window.location.replace(component.get('v.baseUrl')+"/secur/logout.jsp");
            }
        })
        $A.enqueueAction(action);
    },
    
    //Lora Mae Dapulang || GRAPHITE-1152: Case Status -Enhancement
    checkForInProgressCases : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Case Number', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_self'}}
        ]);
        
        var action = component.get('c.checkForInProgressCases');
        action.setCallback(this, function (response) {
            var state = response.getState();
            
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                result.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set('v.openCases', result);
                if (result.length > 0){
                    component.set('v.withOpenCases', true);
                }
                else {
                    component.set('v.withOpenCases', false);
                }
            }
        })
        $A.enqueueAction(action);
    },
    
    //GRAPHITE-1152: Case Status -Enhancement
    handleUtilityClick : function(component, response) {
        if (response.panelVisible) {
            this.checkForInProgressCases(component);
        }
    },    
})