({
	doInit : function(component, event, helper) {
        helper.checkProfiles(component, event, helper);
		var action = component.get("c.getColumns");
        action.setParams({
            "componentName": "QCC_CaseSearchResult"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var cols = JSON.parse(response.getReturnValue());
                component.set("v.mycolumns", cols);
            } else if (state === "ERROR") {
                var errors = response.getError();    
                console.log("Error: "+errors);
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
	},
    
    getCases : function(component, event, helper) {        
        console.log('Handling QCC_ShowCasesEvent');
        var records = event.getParam("cases");
        console.log(records.length);
        if(records.length != 0) {
            component.set("v.noCasesFound", false);
            component.set("v.cases", records);
            component.set("v.maxPage", Math.floor((records.length+4)/5));            
            helper.renderPage(component);
        } else {
            var cases = [];
            component.set("v.noCasesFound", true);
            component.set("v.currentList", cases);
        }        
        component.set("v.searchCompleted", true);
        console.log(JSON.stringify(component.get("v.cases")));
        console.log(JSON.stringify(component.get("v.mycolumns")));
        console.log(component.get("v.noCasesFound"));
    },
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log(JSON.stringify(row));
        console.log('isLivePerson: ' + component.get("v.isLivePerson"));
        if(component.get("v.isLivePerson")) {
            var myEvent = $A.get("e.c:QCC_CaseSelect_LiveEngage");
            myEvent.setParams({"data": row});
            myEvent.fire();

            var url = location.href;
            var baseurl = url.substring(0, url.indexOf('/', 14));
            console.log('further details1' + url);
            console.log('further details2' + baseurl);
            console.log('further details3' + row);
            window.open(baseurl + '/lightning/r/Case/' + row.Id + '/view');
        } else {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": row.Id
            });
            //$A.get('e.force:refreshView').fire();
            navEvt.fire();
        }
    },
    
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },
    
    createCase: function(component, event, helper) {
        var modalBody;
        var createRecordEvent = $A.get("e.c:QCC_CreateRecordEvent");
        createRecordEvent.setParams({
            "recordTypeId": "01290000000ukakAAA"
        });
        console.log('Fire Event  QCC_CreateRecordEvent From Case Search Result Component');
        createRecordEvent.fire();
    },
    
    doReset : function(component, event, helper) {
        var cases = [];
        component.set("v.currentList", cases);
        component.set("v.searchCompleted", false);
    }
})