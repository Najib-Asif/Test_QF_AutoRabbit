({
    getCaseSummary : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log('Param Value###'+JSON.stringify(params.caseDetail));
        component.set("v.objCon", params.caseDetail); 
    },
    handleContactDetlChange : function(component, event, helper) {
        console.log('CaseSummaryRecId***'+component.get("v.recordId"));
    	helper.fetchFlightDisruptionDetails(component, event, helper);
    },
    navigateToDisruptComp : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:QCC_CustomerDisruptionSummary",
            componentAttributes: {
                disruptionList : component.get("v.disruptRec"),
                conDetails : component.get("v.contactDetails"),
                recordId : component.get("v.recordId")
            }
            
        });
        evt.fire();
    }
})