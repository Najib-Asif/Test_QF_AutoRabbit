({
	doInit : function(component, event, helper) {
        helper.onInit(component, helper);
	},
	openCaseTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: event.target.id,
            focus: true
        });
       // var a = component.get("v.recordId");
       // component.set("v.recordIdHidden",event.target.id);
       // alert("in");
       // alert(component.get("v.recordIdHidden"));
    },
    createCaseRelationship : function (component, event, helper) {
        var caseId = component.get("v.recordId");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Case_Relationships__c",
            "defaultFieldValues": {
                'Case_1__c' : caseId
            }
        });
        createRecordEvent.fire();
    },
    openCaseRelationshipSubtab : function (component, event, helper) {
       var urlEvent = $A.get("e.force:navigateToURL");
        component.get("v.isTab",true);
        urlEvent.setParams({
          "url": "/one/one.app#/n/Case_Relationship?c__CaseId=" + component.get("v.recordId")
        });
        urlEvent.fire();
        
    },
     onRecordIdChange : function(component, event, helper) {
        var newRecordId = component.get("v.recordId");
        console.log(newRecordId);
    }
})