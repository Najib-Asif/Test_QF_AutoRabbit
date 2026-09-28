({
	fetchCaseRelationships : function(component, caseId, isTab) {
        var maxRecordDisplay = 3;
        var action = component.get("c.fetchCaseRelationshipsByCaseId");      
        action.setParams({ "caseId" : caseId });     
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data !== null){
                component.set("v.caseRelationships", data);
                if(isTab === false){
                    component.set("v.totalCaseRelationships", data.length > maxRecordDisplay ? "3+": data.length);
                }else{
                    component.set("v.totalCaseRelationships", data.length);
                }
                if(data.length > 0){
                   component.set("v.showTable", true);
                }else{
                   component.set("v.showTable", false);
                }
            }
            if(isTab === true){
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Case Relationships"
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "standard:custom"
                    });
                })
            }
            component.set("v.isTab", isTab);
        }); 
        $A.enqueueAction(action);
    },
    onInit : function(component, helper) {
        var caseId = component.get("v.recordId");
        //alert(caseId);
       // if(typeof caseId == 'undefined' ){
          ///  var caseId = component.get("v.pageReference").state.c__CaseId;
       // }
       
        //caseId='50090000025TCMIAA4';
        var tabName = "Case_Relationship";
        var paramName = "CaseId";
        if(typeof caseId == 'undefined' ){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getEnclosingTabId().then(function(tabId) {
                workspaceAPI.getTabURL({
                        tabId: tabId
                    }).then(function(response) {
                        var url = response;
                        var allParams = url.substr(url.indexOf(tabName) + tabName.length+1).split('&');
                        var paramValue = '';
                        for(var i=0; i<allParams.length; i++) {
                            if(allParams[i].split('=')[0] == paramName){
                                paramValue = allParams[i].split('=')[1];
                                break;
                            }
                        }
                    
                 if(typeof caseId == 'undefined' ){
                     var caseId = component.get("v.pageReference").state.c__CaseId;
                      helper.fetchCaseRelationships(component, caseId, true);
                 }
                    else{
                        helper.fetchCaseRelationships(component, paramValue, true);
                    }
                    });
            });
        }else{
            this.fetchCaseRelationships(component, caseId, false);
        }
    }
})