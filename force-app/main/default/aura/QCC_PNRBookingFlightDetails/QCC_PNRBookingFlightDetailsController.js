({
    doInit : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function(response) {
            var focusedTabId = response.tabId; 
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Booking Details"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:topic",
                iconAlt: "BD:"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        
        console.log(component.get("v.pageReference").state.c__recordId);
        if(component.get("v.pageReference").state.c__recordId){
            component.set("v.pnr",component.get("v.pageReference").state.c__pnr);
            //Jira CRM-6052
        	component.set("v.isNeedToFormatDate",component.get("v.pageReference").state.c__isNeedToFormatDate);
            component.set("v.creationDate",component.get("v.pageReference").state.c__creationDate);
        	component.set("v.recordId",component.get("v.pageReference").state.c__recordId);
        	component.set("v.archivalData",component.get("v.pageReference").state.c__archivalData);
        }
        
        helper.checkProfiles(component, event, helper);
        helper.getCompleteDetail(component);         
    },
    flightBasedSection : function(component, event, helper) {
        var history = event.getParam("history");
        component.set("v.isHistory", history);
        if(history) {
            var segmentTattoo = event.getParam("segmentId");
            console.log("Received component event with param = "+ segmentTattoo);
            component.set("v.segmentTattoo", segmentTattoo);
        }
        else {
            var segmentID = event.getParam("segmentId");
            console.log("Received component event with param = "+ segmentID);
            component.set("v.segmentID", segmentID);
        }
        
        //var passengerId = component.get("v.passengerID");
        helper.Refreshsection(component, true, history);
    },
    passengerBasedSection : function(component, event, helper) {
        var passengerID = event.getParam("passengerId");
        console.log("Received component event with param ==== "+ passengerID);
        component.set("v.passengerID", passengerID);
        var history = component.get("v.isHistory");
        helper.Refreshsection(component, false, history);
    },
    createCase : function(component, event, helper) {
        console.log("Create Case");
        var segment = component.get("v.segment");
        if(segment != null) {
            helper.showRecordType(component, event, helper);
        }
        else {
            window.alert('Case cannot be created without Flight information');
        }
    },
    addToCase : function(component, event, helper) {
        console.log("Add to Case");
        var segment = component.get("v.segment");
        if(segment != null) {
            helper.addBookingInfotoCase(component);
        }
        else {
            window.alert('No information to add to Case');
        }
    },
    updateSelectedLeg : function(component, event, helper){
        console.log(" in side legCreate Case");
        var legStatus = event.getParam("selectedLeg");
        var showCaseButton = event.getParam("showCaseButton");
        console.log("legStatus#####",legStatus);
        console.log("showCaseButton#####",showCaseButton);
        component.set("v.selectedLeg", legStatus);
        component.set("v.showLegButton", showCaseButton);
        helper.updateSelectedLeg(component);
        
        //helper.createCaseForBooking(component);
    },
    updateSelectedSSR : function(component, event, helper){
        console.log(" in side legCreate Case");
        var selectedSSR = event.getParam("selectedSSR");
        var showCaseButton = event.getParam("showCaseButton");
        console.log("legStatus#####",selectedSSR);
        console.log("showCaseButton#####",showCaseButton);
        component.set("v.selectedSSR", selectedSSR);
        component.set("v.showSSRButton", showCaseButton);
        helper.updateSelectedSSR(component);
        //helper.createCaseForBooking(component);
    },
    flightHistorySection: function(component, event, helper) {
        helper.getHistoryDetails(component);
    },
    refreshPage: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})